from accounts.auth import JWTAuth
from accounts.models import AppPreference, ExchangeRate, SubCurrency
from accounts.schemas import (
    AddSubCurrencyRequest,
    ErrorResponse,
    ExchangeRateResponse,
    SubCurrencyResponse,
    UserCurrenciesResponse,
)
from ninja import Router
from synapse.constants import CURRENCIES

router = Router(tags=["Currencies"])

VALID_CURRENCY_CODES = {code for code, _ in CURRENCIES}


@router.get(
    "/user",
    response={200: UserCurrenciesResponse, 404: ErrorResponse},
    auth=JWTAuth(),
    description="Get the current user's main currency and sub-currencies.",
)
def get_user_currencies(request):
    user = request.auth
    try:
        pref = AppPreference.objects.select_related("main_currency").prefetch_related(
            "sub_currencies"
        ).get(user=user)
    except AppPreference.DoesNotExist:
        return 404, ErrorResponse(detail="User preferences not found")

    main = SubCurrencyResponse.from_sub_currency(pref.main_currency, is_main=True)
    subs = [
        SubCurrencyResponse.from_sub_currency(sc)
        for sc in pref.sub_currencies.all()
        if sc.id != pref.main_currency_id
    ]

    return 200, UserCurrenciesResponse(main_currency=main, sub_currencies=subs)


@router.get(
    "/rates",
    response={200: list[ExchangeRateResponse]},
    auth=JWTAuth(),
    description="Get current exchange rates for the user's currencies.",
)
def get_exchange_rates(request):
    user = request.auth
    try:
        pref = AppPreference.objects.select_related("main_currency").prefetch_related(
            "sub_currencies"
        ).get(user=user)
    except AppPreference.DoesNotExist:
        return 200, []

    currency_codes = {pref.main_currency.currency}
    for sc in pref.sub_currencies.all():
        currency_codes.add(sc.currency)

    rates = ExchangeRate.objects.filter(
        base_currency__in=currency_codes,
        target_currency__in=currency_codes,
    )

    return 200, [ExchangeRateResponse.from_exchange_rate(r) for r in rates]


@router.post(
    "/subcurrency",
    response={201: SubCurrencyResponse, 400: ErrorResponse},
    auth=JWTAuth(),
    description="Add a sub-currency to the user's preferences.",
)
def add_sub_currency(request, payload: AddSubCurrencyRequest):
    user = request.auth

    if payload.currency not in VALID_CURRENCY_CODES:
        return 400, ErrorResponse(detail=f"Invalid currency: {payload.currency}")

    try:
        pref = AppPreference.objects.get(user=user)
    except AppPreference.DoesNotExist:
        return 400, ErrorResponse(detail="User preferences not found")

    existing = pref.sub_currencies.filter(currency=payload.currency).first()
    if existing:
        return 400, ErrorResponse(detail=f"{payload.currency} is already added")

    if pref.main_currency.currency == payload.currency:
        return 400, ErrorResponse(detail=f"{payload.currency} is your main currency")

    sc = SubCurrency.objects.create(
        user=user,
        currency=payload.currency,
        unit_position=payload.unit_position,
    )
    pref.sub_currencies.add(sc)

    return 201, SubCurrencyResponse.from_sub_currency(sc)
