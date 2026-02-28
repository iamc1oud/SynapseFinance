from accounts.auth import JWTAuth
from accounts.schemas import ErrorResponse
from ninja import Router

from ..models import Account
from ..schemas import AccountResponse, CreateAccountRequest

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
def list_accounts(request):
    accounts = Account.objects.filter(user=request.auth, is_active=True)
    return 200, [AccountResponse.from_account(a) for a in accounts]


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
