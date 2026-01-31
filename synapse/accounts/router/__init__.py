# @router.post("/register", response={201: AuthResponse, 400: ErrorResponse})
# def register(request, payload: RegisterRequest):
#     """Register a new user account."""
#     # Check if email already exists
#     if User.objects.filter(email__iexact=payload.email).exists():
#         return 400, ErrorResponse(detail="Email already registered")

#     # Validate password
#     try:
#         validate_password(payload.password)
#     except ValidationError as e:
#         return 400, ErrorResponse(detail="; ".join(e.messages))

#     # Create user
#     user = User.objects.create_user(
#         email=payload.email,
#         password=payload.password,
#         first_name=payload.first_name,
#         last_name=payload.last_name,
#     )

#     # Create user default app preference
#     AppPreference.objects.create(user=user)

#     # Generate tokens
#     access_token, refresh_token = create_tokens(user)

#     return 201, AuthResponse(
#         user=UserResponse.from_user(user),
#         tokens=TokenResponse(access_token=access_token, refresh_token=refresh_token),
#     )


# @router.post("/login", response={200: AuthResponse, 401: ErrorResponse})
# def login(request, payload: LoginRequest):
#     """Authenticate user and return tokens."""
#     try:
#         user = User.objects.get(email__iexact=payload.email)
#     except User.DoesNotExist:
#         return 401, ErrorResponse(detail="Invalid email or password")

#     if not user.check_password(payload.password):
#         return 401, ErrorResponse(detail="Invalid email or password")

#     if not user.is_active:
#         return 401, ErrorResponse(detail="Account is disabled")

#     # Generate tokens
#     access_token, refresh_token = create_tokens(user)

#     return 200, AuthResponse(
#         user=UserResponse.from_user(user),
#         tokens=TokenResponse(access_token=access_token, refresh_token=refresh_token),
#     )


# @router.post("/refresh", response={200: TokenResponse, 401: ErrorResponse})
# def refresh(request, payload: RefreshTokenRequest):
#     """Get new access and refresh tokens using a valid refresh token."""
#     try:
#         access_token, new_refresh_token = refresh_tokens(payload.refresh_token)
#         return 200, TokenResponse(access_token=access_token, refresh_token=new_refresh_token)
#     except AuthenticationError as e:
#         return 401, ErrorResponse(detail=str(e))


# @router.post("/logout", response={200: MessageResponse}, auth=JWTAuth())
# def logout(request, payload: RefreshTokenRequest):
#     """Logout user by revoking the refresh token."""
#     revoke_refresh_token(payload.refresh_token)
#     return 200, MessageResponse(message="Successfully logged out")


# @router.post("/logout-all", response={200: MessageResponse}, auth=JWTAuth())
# def logout_all(request):
#     """Logout user from all devices by revoking all refresh tokens."""
#     revoke_all_user_tokens(request.auth)
#     return 200, MessageResponse(message="Successfully logged out from all devices")


# @router.get("/me", response={200: UserResponse}, auth=JWTAuth())
# def get_current_user(request):
#     """Get the current authenticated user's details."""
#     return 200, UserResponse.from_user(request.auth)
