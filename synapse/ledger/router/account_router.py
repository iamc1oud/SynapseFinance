from typing import Optional

from accounts.auth import JWTAuth
from accounts.schemas import ErrorResponse
from ninja import Router

from ..models import Account
from ..schemas import AccountResponse, CreateAccountRequest, UpdateAccountRequest

router = Router(tags=["Accounts"])


@router.post(
    "/",
    response={201: AccountResponse, 400: ErrorResponse},
    auth=JWTAuth(),
    description="Create a new financial account (e.g. Main Checking, High Yield Savings).",
)
def create_account(request, payload: CreateAccountRequest):
    account = Account.objects.create(
        user=request.auth,
        name=payload.name,
        account_type=payload.account_type,
        balance=payload.balance,
        currency=payload.currency,
        icon=payload.icon,
    )
    return 201, AccountResponse.from_account(account)


@router.get(
    "/",
    response={200: list[AccountResponse]},
    auth=JWTAuth(),
    description="List all financial accounts for the current user.",
)
def list_accounts(request, is_active: Optional[bool] = None):
    qs = Account.objects.filter(user=request.auth)
    if is_active is not None:
        qs = qs.filter(is_active=is_active)
    else:
        qs = qs.filter(is_active=True)
    return 200, [AccountResponse.from_account(a) for a in qs]


@router.get(
    "/{account_id}",
    response={200: AccountResponse, 404: ErrorResponse},
    auth=JWTAuth(),
    description="Get details of a specific financial account including current balance.",
)
def get_account(request, account_id: int):
    try:
        account = Account.objects.get(id=account_id, user=request.auth)
    except Account.DoesNotExist:
        return 404, ErrorResponse(detail="Account not found")
    return 200, AccountResponse.from_account(account)


@router.patch(
    "/{account_id}",
    response={200: AccountResponse, 404: ErrorResponse},
    auth=JWTAuth(),
    description="Update a financial account's details (name, type, currency, icon).",
)
def update_account(request, account_id: int, payload: UpdateAccountRequest):
    try:
        account = Account.objects.get(id=account_id, user=request.auth)
    except Account.DoesNotExist:
        return 404, ErrorResponse(detail="Account not found")

    update_fields = []
    for field in ("name", "account_type", "currency", "icon"):
        value = getattr(payload, field)
        if value is not None:
            setattr(account, field, value)
            update_fields.append(field)

    if update_fields:
        account.save(update_fields=update_fields)

    return 200, AccountResponse.from_account(account)


@router.patch(
    "/{account_id}/archive",
    response={200: AccountResponse, 404: ErrorResponse},
    auth=JWTAuth(),
    description="Archive (soft-delete) a financial account.",
)
def archive_account(request, account_id: int):
    try:
        account = Account.objects.get(id=account_id, user=request.auth)
    except Account.DoesNotExist:
        return 404, ErrorResponse(detail="Account not found")
    account.is_active = False
    account.save(update_fields=["is_active"])
    return 200, AccountResponse.from_account(account)


@router.patch(
    "/{account_id}/restore",
    response={200: AccountResponse, 404: ErrorResponse},
    auth=JWTAuth(),
    description="Restore a previously archived financial account.",
)
def restore_account(request, account_id: int):
    try:
        account = Account.objects.get(id=account_id, user=request.auth)
    except Account.DoesNotExist:
        return 404, ErrorResponse(detail="Account not found")
    account.is_active = True
    account.save(update_fields=["is_active"])
    return 200, AccountResponse.from_account(account)
