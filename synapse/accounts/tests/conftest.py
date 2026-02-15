import pytest
from accounts.models import User, AppPreference, SubCurrency


@pytest.fixture
def user_data():
    """Default user data for testing."""
    return {
        "email": "test@example.com",
        "password": "SecurePass123!",
        "first_name": "Test",
        "last_name": "User",
    }


@pytest.fixture
def user(db, user_data):
    """Create and return a test user."""
    user_obj = User.objects.create_user(**user_data)
    user_main_currency = SubCurrency.objects.create(currency='USD', user=user_obj)
    AppPreference.objects.create(user=user_obj, language='en-us', main_currency=user_main_currency, timezone='UTC')
    return user_obj


@pytest.fixture
def another_user(db):
    """Create another test user."""
    return User.objects.create_user(
        email="another@example.com",
        password="AnotherPass123!",
        first_name="Another",
        last_name="User",
    )


@pytest.fixture
def superuser(db):
    """Create and return a superuser."""
    return User.objects.create_superuser(
        email="admin@example.com",
        password="AdminPass123!",
    )


@pytest.fixture
def auth_headers(user):
    """Return authorization headers for the test user (Django test client format)."""
    from accounts.auth import create_access_token

    token = create_access_token(user.id)
    return {"HTTP_AUTHORIZATION": f"Bearer {token}"}


@pytest.fixture
def user_tokens(user):
    """Create and return tokens for the test user."""
    from accounts.auth import create_tokens

    access_token, refresh_token = create_tokens(user)
    return {"access_token": access_token, "refresh_token": refresh_token}
