from asgiref.sync import sync_to_async, async_to_sync
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.db import transaction
from accounts.models import SubCurrency
from accounts.middleware import rls_context
from ninja import Router
from django.conf import settings

from ..auth import (
    AuthenticationError,
    JWTAuth,
    create_tokens,
    refresh_tokens,
    revoke_all_user_tokens,
    revoke_refresh_token,
    verify_refresh_token,
)
from ..cache import check_password_cached
from ..models import User, AppPreference
from ..schemas import (
    AuthResponse,
    ErrorResponse,
    LoginRequest,
    MessageResponse,
    RefreshTokenRequest,
    RegisterRequest,
    TokenResponse,
    UpdateProfileRequest,
    UserResponse,
)

router = Router(tags=["Authentication"])

@router.post("/register", response={201: AuthResponse, 400: ErrorResponse})
def register(request, payload: RegisterRequest):
    """Register a new user account."""
    # Check if email already exists
    if User.objects.filter(email__iexact=payload.email).exists():
        return 400, ErrorResponse(detail="Email already registered")

    # Validate password
    try:
        validate_password(payload.password)
    except ValidationError as e:
        return 400, ErrorResponse(detail="; ".join(e.messages))

    # Create user
    user = User.objects.create_user(
        email=payload.email,
        password=payload.password,
        first_name=payload.first_name,
        last_name=payload.last_name,
    )

    # Set RLS context for the newly created user so inserts into
    # RLS-protected tables (sub_currencies, user_preferences, refresh_tokens) succeed.
    with transaction.atomic(), rls_context(user.pk):
        user_main_currency = SubCurrency.objects.create(currency=settings.DEFAULT_CURRENCY, user=user)
        AppPreference.objects.create(user=user, main_currency=user_main_currency)
        access_token, refresh_token = async_to_sync(create_tokens)(user)

    return 201, AuthResponse(
        user=UserResponse.from_user(user),
        tokens=TokenResponse(access_token=access_token, refresh_token=refresh_token),
    )


@router.post("/login", response={200: AuthResponse, 401: ErrorResponse})
async def login(request, payload: LoginRequest):
    """Authenticate user and return tokens."""
    try:
        user = await User.objects.aget(email__iexact=payload.email)
    except User.DoesNotExist:
        return 401, ErrorResponse(detail="Invalid email or password")

    if not await check_password_cached(user, payload.password):
        return 401, ErrorResponse(detail="Invalid email or password")

    if not user.is_active:
        return 401, ErrorResponse(detail="Account is disabled")

    access_token, refresh_token = await create_tokens(user)

    return 200, AuthResponse(
        user=UserResponse.from_user(user),
        tokens=TokenResponse(access_token=access_token, refresh_token=refresh_token),
    )


@router.post("/refresh", response={200: TokenResponse, 401: ErrorResponse})
def refresh(request, payload: RefreshTokenRequest):
    """Get new access and refresh tokens using a valid refresh token."""
    try:
        # Verify first to get the user for RLS context, then do the
        # revoke + create inside the RLS-scoped transaction.
        user = verify_refresh_token(payload.refresh_token)

        revoke_refresh_token(payload.refresh_token)
        access_token, new_refresh_token = async_to_sync(create_tokens)(user)
        return 200, TokenResponse(access_token=access_token, refresh_token=new_refresh_token)
    except AuthenticationError as e:
        return 401, ErrorResponse(detail=str(e))


@router.post("/logout", response={200: MessageResponse}, auth=JWTAuth())
def logout(request, payload: RefreshTokenRequest):
    """Logout user by revoking the refresh token."""
    revoke_refresh_token(payload.refresh_token)
    return 200, MessageResponse(message="Successfully logged out")


@router.post("/logout-all", response={200: MessageResponse}, auth=JWTAuth())
def logout_all(request):
    """Logout user from all devices by revoking all refresh tokens."""
    revoke_all_user_tokens(request.auth)
    return 200, MessageResponse(message="Successfully logged out from all devices")


@router.get("/me", response={200: UserResponse}, auth=JWTAuth())
def get_current_user(request):
    """Get the current authenticated user's details."""
    return 200, UserResponse.from_user(request.auth)


@router.patch("/me", response={200: UserResponse}, auth=JWTAuth())
def update_profile(request, payload: UpdateProfileRequest):
    """Update the current user's profile information."""
    user = request.auth
    update_fields = []
    for field in ("first_name", "last_name"):
        value = getattr(payload, field)
        if value is not None:
            setattr(user, field, value)
            update_fields.append(field)

    if update_fields:
        user.save(update_fields=update_fields)

    return 200, UserResponse.from_user(user)
