from ninja import Schema
from pydantic import EmailStr, field_validator


class RegisterRequest(Schema):
    email: EmailStr
    password: str
    first_name: str = ""
    last_name: str = ""

    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters long")
        return v


class LoginRequest(Schema):
    email: EmailStr
    password: str


class RefreshTokenRequest(Schema):
    refresh_token: str


class TokenResponse(Schema):
    access_token: str
    refresh_token: str
    token_type: str = "Bearer"


class UserResponse(Schema):
    id: int
    email: str
    first_name: str
    last_name: str
    is_active: bool

    @staticmethod
    def from_user(user):
        return UserResponse(
            id=user.id,
            email=user.email,
            first_name=user.first_name,
            last_name=user.last_name,
            is_active=user.is_active,
        )


class AuthResponse(Schema):
    user: UserResponse
    tokens: TokenResponse


class MessageResponse(Schema):
    message: str


class ErrorResponse(Schema):
    detail: str
