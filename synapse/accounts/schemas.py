from typing import Optional

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
    avatar_url: str
    is_active: bool

    @staticmethod
    def from_user(user):
        return UserResponse(
            id=user.id,
            email=user.email,
            first_name=user.first_name,
            last_name=user.last_name,
            avatar_url=user.avatar_url,
            is_active=user.is_active,
        )


class AuthResponse(Schema):
    user: UserResponse
    tokens: TokenResponse


class MessageResponse(Schema):
    message: str


class UpdateProfileRequest(Schema):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    avatar_url: Optional[str] = None


class ErrorResponse(Schema):
    detail: str


# ── Currency Schemas ────────────────────────────────────────────────────────

class SubCurrencyResponse(Schema):
    id: int
    currency: str
    exchange_rate: float
    unit_position: str
    is_main: bool = False

    @staticmethod
    def from_sub_currency(sub_currency, is_main=False):
        return SubCurrencyResponse(
            id=sub_currency.id,
            currency=sub_currency.currency,
            exchange_rate=float(sub_currency.exchange_rate),
            unit_position=sub_currency.unit_position,
            is_main=is_main,
        )


class UserCurrenciesResponse(Schema):
    main_currency: SubCurrencyResponse
    sub_currencies: list[SubCurrencyResponse]


class ExchangeRateResponse(Schema):
    base_currency: str
    target_currency: str
    rate: float

    @staticmethod
    def from_exchange_rate(er):
        return ExchangeRateResponse(
            base_currency=er.base_currency,
            target_currency=er.target_currency,
            rate=float(er.rate),
        )


class AddSubCurrencyRequest(Schema):
    currency: str
    unit_position: str = "front"
