import logging
from decimal import Decimal

import httpx

from synapse.constants import CURRENCIES

from .models import ExchangeRate

logger = logging.getLogger(__name__)

API_BASE = "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies"
FALLBACK_BASE = "https://latest.currency-api.pages.dev/v1/currencies"


def fetch_and_update_rates():
    """Fetch latest exchange rates for all supported currencies and upsert into DB."""
    currency_codes = [code for code, _ in CURRENCIES]
    updated = 0

    with httpx.Client(timeout=15) as client:
        for base in currency_codes:
            base_lower = base.lower()
            url = f"{API_BASE}/{base_lower}.json"

            try:
                resp = client.get(url)
                if resp.status_code != 200:
                    resp = client.get(f"{FALLBACK_BASE}/{base_lower}.json")
                resp.raise_for_status()
            except httpx.HTTPError as e:
                logger.warning("Failed to fetch rates for %s: %s", base, e)
                continue

            data = resp.json()
            rates = data.get(base_lower, {})

            for target in currency_codes:
                if target == base:
                    continue
                target_lower = target.lower()
                rate_value = rates.get(target_lower)
                if rate_value is None:
                    continue

                ExchangeRate.objects.update_or_create(
                    base_currency=base,
                    target_currency=target,
                    defaults={"rate": Decimal(str(rate_value))},
                )
                updated += 1

    logger.info("Updated %d exchange rate pairs", updated)
    return updated


def get_rate(from_currency: str, to_currency: str) -> Decimal | None:
    """Get the exchange rate between two currencies from the DB."""
    if from_currency == to_currency:
        return Decimal("1")
    try:
        er = ExchangeRate.objects.get(
            base_currency=from_currency,
            target_currency=to_currency,
        )
        return er.rate
    except ExchangeRate.DoesNotExist:
        return None


def convert_amount(
    amount: Decimal, from_currency: str, to_currency: str
) -> tuple[Decimal, Decimal] | None:
    """Convert amount from one currency to another.

    Returns (converted_amount, exchange_rate) or None if rate not found.
    """
    rate = get_rate(from_currency, to_currency)
    if rate is None:
        return None
    converted = (amount * rate).quantize(Decimal("0.01"))
    return converted, rate
