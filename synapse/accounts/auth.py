import secrets
from datetime import datetime, timedelta, timezone

import jwt
from django.conf import settings
from ninja.security import HttpBearer

from .models import RefreshToken, User

# JWT Configuration
JWT_SECRET_KEY = getattr(settings, "JWT_SECRET_KEY", settings.SECRET_KEY)
JWT_ALGORITHM = getattr(settings, "JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = getattr(settings, "ACCESS_TOKEN_EXPIRE_MINUTES", 15)
REFRESH_TOKEN_EXPIRE_DAYS = getattr(settings, "REFRESH_TOKEN_EXPIRE_DAYS", 7)


class AuthenticationError(Exception):
    """Raised when authentication fails."""

    pass


def create_access_token(user_id: int) -> str:
    """Create a new JWT access token."""
    expires_at = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    payload = {
        "sub": str(user_id),
        "type": "access",
        "exp": expires_at,
        "iat": datetime.now(timezone.utc),
    }
    return jwt.encode(payload, JWT_SECRET_KEY, algorithm=JWT_ALGORITHM)


def create_refresh_token(user: User) -> str:
    """Create a new refresh token and store it in the database."""
    token = secrets.token_urlsafe(32)
    expires_at = datetime.now(timezone.utc) + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)

    RefreshToken.objects.create(
        user=user,
        token=token,
        expires_at=expires_at,
    )

    return token


def create_tokens(user: User) -> tuple[str, str]:
    """Create both access and refresh tokens for a user."""
    access_token = create_access_token(user.pk)
    refresh_token = create_refresh_token(user)
    return access_token, refresh_token


def verify_access_token(token: str) -> int:
    """Verify an access token and return the user ID."""
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        if payload.get("type") != "access":
            raise AuthenticationError("Invalid token type")
        return int(payload["sub"])
    except jwt.ExpiredSignatureError:
        raise AuthenticationError("Token has expired")
    except jwt.InvalidTokenError:
        raise AuthenticationError("Invalid token")


def verify_refresh_token(token: str) -> User:
    """Verify a refresh token and return the associated user."""
    try:
        refresh_token = RefreshToken.objects.select_related("user").get(token=token)
    except RefreshToken.DoesNotExist:
        raise AuthenticationError("Invalid refresh token")

    if not refresh_token.is_valid:
        raise AuthenticationError("Refresh token is expired or revoked")

    return refresh_token.user


def revoke_refresh_token(token: str) -> bool:
    """Revoke a refresh token."""
    try:
        refresh_token = RefreshToken.objects.get(token=token)
        refresh_token.revoked = True
        refresh_token.save(update_fields=["revoked"])
        return True
    except RefreshToken.DoesNotExist:
        return False


def revoke_all_user_tokens(user: User) -> int:
    """Revoke all refresh tokens for a user."""
    return RefreshToken.objects.filter(user=user, revoked=False).update(revoked=True)


def refresh_tokens(refresh_token_str: str) -> tuple[str, str]:
    """Use a refresh token to get new access and refresh tokens."""
    user = verify_refresh_token(refresh_token_str)

    # Revoke the old refresh token (rotation)
    revoke_refresh_token(refresh_token_str)

    # Create new tokens
    return create_tokens(user)


class JWTAuth(HttpBearer):
    """JWT Bearer token authentication for Django Ninja."""

    def authenticate(self, request, token: str) -> User | None:
        try:
            user_id = verify_access_token(token)
            user = User.objects.get(id=user_id, is_active=True)
            return user
        except (AuthenticationError, User.DoesNotExist):
            return None
