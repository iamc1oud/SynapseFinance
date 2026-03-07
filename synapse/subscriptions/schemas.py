from datetime import date
from decimal import Decimal
from typing import Optional

from ninja import Schema

from ledger.schemas import AccountResponse, CategoryResponse


class CreateSubscriptionRequest(Schema):
    name: str
    amount: Decimal
    currency: str = "USD"
    frequency: str  # weekly, monthly, yearly, custom
    custom_interval_days: Optional[int] = None
    category_id: Optional[int] = None
    account_id: int
    start_date: date
    end_date: Optional[date] = None
    reminder_enabled: bool = False
    reminder_days_before: int = 1
    note: str = ""
    icon: str = ""


class UpdateSubscriptionRequest(Schema):
    name: Optional[str] = None
    amount: Optional[Decimal] = None
    currency: Optional[str] = None
    frequency: Optional[str] = None
    custom_interval_days: Optional[int] = None
    category_id: Optional[int] = None
    account_id: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    reminder_enabled: Optional[bool] = None
    reminder_days_before: Optional[int] = None
    note: Optional[str] = None
    icon: Optional[str] = None


class SubscriptionResponse(Schema):
    id: int
    name: str
    amount: Decimal
    currency: str
    frequency: str
    custom_interval_days: Optional[int]
    category: Optional[CategoryResponse] = None
    account: AccountResponse
    start_date: date
    end_date: Optional[date]
    next_due_date: date
    is_active: bool
    reminder_enabled: bool
    reminder_days_before: int
    note: str
    icon: str

    @staticmethod
    def from_subscription(sub):
        return SubscriptionResponse(
            id=sub.id,
            name=sub.name,
            amount=sub.amount,
            currency=sub.currency,
            frequency=sub.frequency,
            custom_interval_days=sub.custom_interval_days,
            category=(
                CategoryResponse.from_category(sub.category)
                if sub.category
                else None
            ),
            account=AccountResponse.from_account(sub.account),
            start_date=sub.start_date,
            end_date=sub.end_date,
            next_due_date=sub.next_due_date,
            is_active=sub.is_active,
            reminder_enabled=sub.reminder_enabled,
            reminder_days_before=sub.reminder_days_before,
            note=sub.note,
            icon=sub.icon,
        )


class SubscriptionSummaryResponse(Schema):
    total_monthly_cost: Decimal
    active_count: int
    subscriptions: list[SubscriptionResponse]
