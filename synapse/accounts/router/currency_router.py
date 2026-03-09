from django.db import transaction

from accounts.auth import JWTAuth
from accounts.exchange_service import fetch_and_update_rates
from accounts.models import AppPreference, ExchangeRate, SubCurrency
from accounts.schemas import (
    AddSubCurrencyRequest,
    ChangePrimaryCurrencyRequest,
    ErrorResponse,
    ExchangeRateResponse,
    SubCurrencyResponse,
    UpdateExchangeRateRequest,
    UserCurrenciesResponse,
)
from ledger.models import Account, Transaction
from ninja import Router
from subscriptions.models import Subscription
from synapse.constants import ALL_FIAT_CURRENCIES, CURRENCIES

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


@router.delete(
    "/subcurrency/{subcurrency_id}",
    response={200: dict, 400: ErrorResponse},
    auth=JWTAuth(),
    description="Remove a sub-currency from the user's preferences.",
)
def delete_sub_currency(request, subcurrency_id: int):
    user = request.auth

    try:
        pref = AppPreference.objects.get(user=user)
    except AppPreference.DoesNotExist:
        return 400, ErrorResponse(detail="User preferences not found")

    if pref.main_currency_id == subcurrency_id:
        return 400, ErrorResponse(detail="Cannot remove your main currency")

    sc = pref.sub_currencies.filter(id=subcurrency_id).first()
    if not sc:
        return 400, ErrorResponse(detail="Sub-currency not found")

    pref.sub_currencies.remove(sc)
    sc.delete()

    return 200, {"detail": "Sub-currency removed"}


@router.put(
    "/subcurrency/{subcurrency_id}/rate",
    response={200: SubCurrencyResponse, 400: ErrorResponse},
    auth=JWTAuth(),
    description="Manually update the exchange rate on a sub-currency.",
)
def update_sub_currency_rate(request, subcurrency_id: int, payload: UpdateExchangeRateRequest):
    user = request.auth

    try:
        sc = SubCurrency.objects.get(id=subcurrency_id, user=user)
    except SubCurrency.DoesNotExist:
        return 400, ErrorResponse(detail="Sub-currency not found")

    sc.exchange_rate = payload.exchange_rate
    sc.save(update_fields=["exchange_rate"])

    return 200, SubCurrencyResponse.from_sub_currency(sc)


@router.post(
    "/refresh-rates",
    response={200: list[ExchangeRateResponse], 400: ErrorResponse},
    auth=JWTAuth(),
    description="Refresh exchange rates from external API and return updated rates.",
)
def refresh_rates(request):
    user = request.auth

    fetch_and_update_rates()

    try:
        pref = AppPreference.objects.select_related("main_currency").prefetch_related(
            "sub_currencies"
        ).get(user=user)
    except AppPreference.DoesNotExist:
        return 400, ErrorResponse(detail="User preferences not found")

    currency_codes = {pref.main_currency.currency}
    for sc in pref.sub_currencies.all():
        currency_codes.add(sc.currency)

    rates = ExchangeRate.objects.filter(
        base_currency__in=currency_codes,
        target_currency__in=currency_codes,
    )

    return 200, [ExchangeRateResponse.from_exchange_rate(r) for r in rates]


@router.post(
    "/change-primary",
    response={200: UserCurrenciesResponse, 400: ErrorResponse},
    auth=JWTAuth(),
    description="Change the primary currency. WARNING: This deletes all user transactions, accounts, subscriptions, and sub-currencies.",
)
def change_primary_currency(request, payload: ChangePrimaryCurrencyRequest):
    user = request.auth

    if payload.currency not in ALL_FIAT_CURRENCIES:
        return 400, ErrorResponse(detail=f"Invalid currency: {payload.currency}")

    try:
        pref = AppPreference.objects.select_related("main_currency").get(user=user)
    except AppPreference.DoesNotExist:
        return 400, ErrorResponse(detail="User preferences not found")

    if pref.main_currency.currency == payload.currency:
        return 400, ErrorResponse(detail=f"{payload.currency} is already your primary currency")

    with transaction.atomic():
        # Delete all user financial data
        Transaction.objects.filter(user=user).delete()
        Account.objects.filter(user=user).delete()
        Subscription.objects.filter(user=user).delete()

        # Create new main currency first (before deleting old ones)
        new_main = SubCurrency.objects.create(
            user=user,
            currency=payload.currency,
        )

        # Point pref to the new main currency before deleting old ones
        AppPreference.objects.filter(user=user).update(main_currency=new_main)

        # Now safe to clear old sub-currencies (old main_currency FK no longer references them)
        pref.sub_currencies.clear()
        SubCurrency.objects.filter(user=user).exclude(id=new_main.id).delete()

        pref.sub_currencies.add(new_main)

    main_resp = SubCurrencyResponse.from_sub_currency(new_main, is_main=True)
    return 200, UserCurrenciesResponse(main_currency=main_resp, sub_currencies=[])
