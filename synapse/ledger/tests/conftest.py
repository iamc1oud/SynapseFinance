import pytest
from decimal import Decimal
from accounts.auth import create_access_token
from accounts.models import AppPreference, SubCurrency, User

from ledger.models import Account, Category, Tag


@pytest.fixture
def user(db):
    user_obj = User.objects.create_user(
        email="ledger@example.com",
        password="SecurePass123!",
        first_name="Ledger",
        last_name="User",
    )
    currency = SubCurrency.objects.create(currency='USD', user=user_obj)
    AppPreference.objects.create(user=user_obj, main_currency=currency, timezone='UTC')
    return user_obj


@pytest.fixture
def auth_headers(user):
    token = create_access_token(user.id)
    return {"HTTP_AUTHORIZATION": f"Bearer {token}"}


@pytest.fixture
def checking_account(user):
    return Account.objects.create(
        user=user,
        name="Main Checking",
        account_type="checking",
        balance=Decimal("12450.80"),
        currency="USD",
    )


@pytest.fixture
def savings_account(user):
    return Account.objects.create(
        user=user,
        name="High Yield Savings",
        account_type="savings",
        balance=Decimal("4200.00"),
        currency="USD",
    )


@pytest.fixture
def expense_category(user):
    return Category.objects.create(
        user=user,
        name="Food",
        icon="food",
        category_type="expense",
    )


@pytest.fixture
def income_category(user):
    return Category.objects.create(
        user=user,
        name="Salary",
        icon="salary",
        category_type="income",
    )


@pytest.fixture
def tag(user):
    return Tag.objects.create(user=user, name="Savings")
