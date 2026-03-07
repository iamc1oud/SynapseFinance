from datetime import date, timedelta
from decimal import Decimal

from accounts.auth import JWTAuth
from accounts.schemas import ErrorResponse, MessageResponse
from dateutil.relativedelta import relativedelta
from ninja import Router

from ledger.models import Account, Category

from ..models import Subscription
from ..schemas import (
    CreateSubscriptionRequest,
    SubscriptionResponse,
    SubscriptionSummaryResponse,
    UpdateSubscriptionRequest,
)

router = Router(tags=["Subscriptions"])


def compute_next_due_date(start_date, frequency, custom_interval_days=None):
    """Calculate the next due date from today based on frequency."""
    today = date.today()
    current = start_date
    if current > today:
        return current
    while current <= today:
        if frequency == "weekly":
            current += timedelta(weeks=1)
        elif frequency == "monthly":
            current += relativedelta(months=1)
        elif frequency == "yearly":
            current += relativedelta(years=1)
        elif frequency == "custom" and custom_interval_days:
            current += timedelta(days=custom_interval_days)
        else:
            break
    return current


def normalize_to_monthly(amount, frequency, custom_interval_days=None):
    """Convert any frequency amount to its monthly equivalent."""
    if frequency == "monthly":
        return amount
    elif frequency == "weekly":
        return amount * Decimal("52") / Decimal("12")
    elif frequency == "yearly":
        return amount / Decimal("12")
    elif frequency == "custom" and custom_interval_days:
        return amount * Decimal("30") / Decimal(str(custom_interval_days))
    return amount


@router.get(
    "/",
    response={200: SubscriptionSummaryResponse},
    auth=JWTAuth(),
    description="List all subscriptions with monthly cost summary.",
)
def list_subscriptions(request):
    qs = (
        Subscription.objects.filter(user=request.auth)
        .select_related("account", "category")
    )

    subs = list(qs)
    active_subs = [s for s in subs if s.is_active]
    total_monthly = sum(
        normalize_to_monthly(s.amount, s.frequency, s.custom_interval_days)
        for s in active_subs
    )

    return 200, SubscriptionSummaryResponse(
        total_monthly_cost=total_monthly.quantize(Decimal("0.01"))
        if total_monthly
        else Decimal("0.00"),
        active_count=len(active_subs),
        subscriptions=[SubscriptionResponse.from_subscription(s) for s in subs],
    )


@router.post(
    "/",
    response={201: SubscriptionResponse, 400: ErrorResponse},
    auth=JWTAuth(),
    description="Create a new subscription.",
)
def create_subscription(request, payload: CreateSubscriptionRequest):
    # Validate account ownership
    try:
        account = Account.objects.get(id=payload.account_id, user=request.auth)
    except Account.DoesNotExist:
        return 400, ErrorResponse(detail="Account not found")

    # Validate category ownership if provided
    category = None
    if payload.category_id:
        try:
            category = Category.objects.get(
                id=payload.category_id, user=request.auth
            )
        except Category.DoesNotExist:
            return 400, ErrorResponse(detail="Category not found")

    # Validate frequency
    if payload.frequency not in ("weekly", "monthly", "yearly", "custom"):
        return 400, ErrorResponse(detail="Invalid frequency")

    if payload.frequency == "custom" and not payload.custom_interval_days:
        return 400, ErrorResponse(
            detail="custom_interval_days is required for custom frequency"
        )

    next_due = compute_next_due_date(
        payload.start_date, payload.frequency, payload.custom_interval_days
    )

    sub = Subscription.objects.create(
        user=request.auth,
        name=payload.name,
        amount=payload.amount,
        currency=payload.currency,
        frequency=payload.frequency,
        custom_interval_days=payload.custom_interval_days,
        category=category,
        account=account,
        start_date=payload.start_date,
        end_date=payload.end_date,
        next_due_date=next_due,
        reminder_enabled=payload.reminder_enabled,
        reminder_days_before=payload.reminder_days_before,
        note=payload.note,
        icon=payload.icon,
    )

    return 201, SubscriptionResponse.from_subscription(sub)


@router.get(
    "/{subscription_id}",
    response={200: SubscriptionResponse, 404: ErrorResponse},
    auth=JWTAuth(),
    description="Get a single subscription.",
)
def get_subscription(request, subscription_id: int):
    try:
        sub = Subscription.objects.select_related("account", "category").get(
            id=subscription_id, user=request.auth
        )
    except Subscription.DoesNotExist:
        return 404, ErrorResponse(detail="Subscription not found")
    return 200, SubscriptionResponse.from_subscription(sub)


@router.patch(
    "/{subscription_id}",
    response={200: SubscriptionResponse, 400: ErrorResponse, 404: ErrorResponse},
    auth=JWTAuth(),
    description="Update a subscription.",
)
def update_subscription(
    request, subscription_id: int, payload: UpdateSubscriptionRequest
):
    try:
        sub = Subscription.objects.select_related("account", "category").get(
            id=subscription_id, user=request.auth
        )
    except Subscription.DoesNotExist:
        return 404, ErrorResponse(detail="Subscription not found")

    update_fields = []

    # Handle account change
    if payload.account_id is not None:
        try:
            account = Account.objects.get(id=payload.account_id, user=request.auth)
        except Account.DoesNotExist:
            return 400, ErrorResponse(detail="Account not found")
        sub.account = account
        update_fields.append("account")

    # Handle category change
    if payload.category_id is not None:
        try:
            category = Category.objects.get(
                id=payload.category_id, user=request.auth
            )
        except Category.DoesNotExist:
            return 400, ErrorResponse(detail="Category not found")
        sub.category = category
        update_fields.append("category")

    # Handle simple fields
    for field in (
        "name",
        "amount",
        "currency",
        "frequency",
        "custom_interval_days",
        "start_date",
        "end_date",
        "reminder_enabled",
        "reminder_days_before",
        "note",
        "icon",
    ):
        value = getattr(payload, field)
        if value is not None:
            setattr(sub, field, value)
            update_fields.append(field)

    # Recompute next_due_date if frequency or start_date changed
    if any(f in update_fields for f in ("frequency", "start_date", "custom_interval_days")):
        sub.next_due_date = compute_next_due_date(
            sub.start_date, sub.frequency, sub.custom_interval_days
        )
        update_fields.append("next_due_date")

    if update_fields:
        sub.save(update_fields=update_fields)

    return 200, SubscriptionResponse.from_subscription(sub)


@router.delete(
    "/{subscription_id}",
    response={200: MessageResponse, 404: ErrorResponse},
    auth=JWTAuth(),
    description="Delete a subscription.",
)
def delete_subscription(request, subscription_id: int):
    try:
        sub = Subscription.objects.get(id=subscription_id, user=request.auth)
    except Subscription.DoesNotExist:
        return 404, ErrorResponse(detail="Subscription not found")
    sub.delete()
    return 200, MessageResponse(message="Subscription deleted")


@router.patch(
    "/{subscription_id}/toggle",
    response={200: SubscriptionResponse, 404: ErrorResponse},
    auth=JWTAuth(),
    description="Toggle a subscription's active state.",
)
def toggle_subscription(request, subscription_id: int):
    try:
        sub = Subscription.objects.select_related("account", "category").get(
            id=subscription_id, user=request.auth
        )
    except Subscription.DoesNotExist:
        return 404, ErrorResponse(detail="Subscription not found")
    sub.is_active = not sub.is_active
    sub.save(update_fields=["is_active"])
    return 200, SubscriptionResponse.from_subscription(sub)
