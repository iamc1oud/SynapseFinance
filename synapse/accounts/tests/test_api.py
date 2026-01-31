import pytest
from django.test import Client

from accounts.models import RefreshToken, User


@pytest.fixture
def client():
    """Return a Django test client."""
    return Client()


class TestRegisterEndpoint:
    """Tests for the /auth/register endpoint."""

    def test_register_success(self, client, db):
        """Test successful user registration."""
        response = client.post(
            "/api/auth/register",
            data={
                "email": "newuser@example.com",
                "password": "SecurePass123!",
                "first_name": "New",
                "last_name": "User",
            },
            content_type="application/json",
        )

        assert response.status_code == 201
        data = response.json()
        assert data["user"]["email"] == "newuser@example.com"
        assert data["user"]["first_name"] == "New"
        assert data["user"]["last_name"] == "User"
        assert "access_token" in data["tokens"]
        assert "refresh_token" in data["tokens"]
        assert data["tokens"]["token_type"] == "Bearer"

    def test_register_creates_user_in_database(self, client, db):
        """Test that registration creates user in database."""
        client.post(
            "/api/auth/register",
            data={
                "email": "dbuser@example.com",
                "password": "SecurePass123!",
            },
            content_type="application/json",
        )

        assert User.objects.filter(email="dbuser@example.com").exists()

    def test_register_duplicate_email(self, client, user):
        """Test registration with existing email fails."""
        response = client.post(
            "/api/auth/register",
            data={
                "email": user.email,
                "password": "AnotherPass123!",
            },
            content_type="application/json",
        )

        assert response.status_code == 400
        assert "already registered" in response.json()["detail"]

    def test_register_weak_password(self, client, db):
        """Test registration with weak password fails."""
        response = client.post(
            "/api/auth/register",
            data={
                "email": "weakpass@example.com",
                "password": "123",
            },
            content_type="application/json",
        )

        # 422 for schema validation (password too short)
        assert response.status_code == 422

    def test_register_invalid_email(self, client, db):
        """Test registration with invalid email fails."""
        response = client.post(
            "/api/auth/register",
            data={
                "email": "not-an-email",
                "password": "SecurePass123!",
            },
            content_type="application/json",
        )

        assert response.status_code == 422


class TestLoginEndpoint:
    """Tests for the /auth/login endpoint."""

    def test_login_success(self, client, user, user_data):
        """Test successful login."""
        response = client.post(
            "/api/auth/login",
            data={
                "email": user_data["email"],
                "password": user_data["password"],
            },
            content_type="application/json",
        )

        assert response.status_code == 200
        data = response.json()
        assert data["user"]["email"] == user_data["email"]
        assert "access_token" in data["tokens"]
        assert "refresh_token" in data["tokens"]

    def test_login_wrong_password(self, client, user, user_data):
        """Test login with wrong password fails."""
        response = client.post(
            "/api/auth/login",
            data={
                "email": user_data["email"],
                "password": "WrongPassword123!",
            },
            content_type="application/json",
        )

        assert response.status_code == 401
        assert "Invalid email or password" in response.json()["detail"]

    def test_login_nonexistent_user(self, client, db):
        """Test login with nonexistent email fails."""
        response = client.post(
            "/api/auth/login",
            data={
                "email": "nonexistent@example.com",
                "password": "SomePass123!",
            },
            content_type="application/json",
        )

        assert response.status_code == 401
        assert "Invalid email or password" in response.json()["detail"]

    def test_login_inactive_user(self, client, user, user_data):
        """Test login with inactive user fails."""
        user.is_active = False
        user.save()

        response = client.post(
            "/api/auth/login",
            data={
                "email": user_data["email"],
                "password": user_data["password"],
            },
            content_type="application/json",
        )

        assert response.status_code == 401
        assert "disabled" in response.json()["detail"]

    def test_login_case_insensitive_email(self, client, user, user_data):
        """Test login is case-insensitive for email."""
        response = client.post(
            "/api/auth/login",
            data={
                "email": user_data["email"].upper(),
                "password": user_data["password"],
            },
            content_type="application/json",
        )

        assert response.status_code == 200


class TestRefreshEndpoint:
    """Tests for the /auth/refresh endpoint."""

    def test_refresh_success(self, client, user_tokens):
        """Test successful token refresh."""
        response = client.post(
            "/api/auth/refresh",
            data={"refresh_token": user_tokens["refresh_token"]},
            content_type="application/json",
        )

        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data
        assert data["refresh_token"] != user_tokens["refresh_token"]

    def test_refresh_invalid_token(self, client, db):
        """Test refresh with invalid token fails."""
        response = client.post(
            "/api/auth/refresh",
            data={"refresh_token": "invalid_token"},
            content_type="application/json",
        )

        assert response.status_code == 401

    def test_refresh_revoked_token(self, client, user_tokens):
        """Test refresh with revoked token fails."""
        RefreshToken.objects.filter(token=user_tokens["refresh_token"]).update(
            revoked=True
        )

        response = client.post(
            "/api/auth/refresh",
            data={"refresh_token": user_tokens["refresh_token"]},
            content_type="application/json",
        )

        assert response.status_code == 401

    def test_refresh_rotates_token(self, client, user_tokens):
        """Test that refresh rotates the token."""
        old_token = user_tokens["refresh_token"]

        client.post(
            "/api/auth/refresh",
            data={"refresh_token": old_token},
            content_type="application/json",
        )

        # Old token should be revoked
        assert RefreshToken.objects.get(token=old_token).revoked is True


class TestLogoutEndpoint:
    """Tests for the /auth/logout endpoint."""

    def test_logout_success(self, client, user_tokens, auth_headers):
        """Test successful logout."""
        response = client.post(
            "/api/auth/logout",
            data={"refresh_token": user_tokens["refresh_token"]},
            content_type="application/json",
            **auth_headers,
        )

        assert response.status_code == 200
        assert "Successfully logged out" in response.json()["message"]

    def test_logout_revokes_token(self, client, user_tokens, auth_headers):
        """Test that logout revokes the refresh token."""
        client.post(
            "/api/auth/logout",
            data={"refresh_token": user_tokens["refresh_token"]},
            content_type="application/json",
            **auth_headers,
        )

        token = RefreshToken.objects.get(token=user_tokens["refresh_token"])
        assert token.revoked is True

    def test_logout_without_auth(self, client, user_tokens):
        """Test logout without authentication fails."""
        response = client.post(
            "/api/auth/logout",
            data={"refresh_token": user_tokens["refresh_token"]},
            content_type="application/json",
        )

        assert response.status_code == 401


class TestLogoutAllEndpoint:
    """Tests for the /auth/logout-all endpoint."""

    def test_logout_all_success(self, client, user, auth_headers):
        """Test successful logout from all devices."""
        from accounts.auth import create_refresh_token

        # Create multiple refresh tokens
        create_refresh_token(user)
        create_refresh_token(user)

        response = client.post(
            "/api/auth/logout-all",
            content_type="application/json",
            **auth_headers,
        )

        assert response.status_code == 200
        assert "all devices" in response.json()["message"]

    def test_logout_all_revokes_all_tokens(self, client, user, auth_headers):
        """Test that logout-all revokes all refresh tokens."""
        from accounts.auth import create_refresh_token

        create_refresh_token(user)
        create_refresh_token(user)

        client.post(
            "/api/auth/logout-all",
            content_type="application/json",
            **auth_headers,
        )

        active_tokens = RefreshToken.objects.filter(user=user, revoked=False).count()
        assert active_tokens == 0

    def test_logout_all_without_auth(self, client, db):
        """Test logout-all without authentication fails."""
        response = client.post(
            "/api/auth/logout-all",
            content_type="application/json",
        )

        assert response.status_code == 401


class TestMeEndpoint:
    """Tests for the /auth/me endpoint."""

    def test_me_success(self, client, user, auth_headers):
        """Test getting current user details."""
        response = client.get("/api/auth/me", **auth_headers)

        assert response.status_code == 200
        data = response.json()
        assert data["email"] == user.email
        assert data["first_name"] == user.first_name
        assert data["last_name"] == user.last_name

    def test_me_without_auth(self, client, db):
        """Test getting user details without authentication fails."""
        response = client.get("/api/auth/me")

        assert response.status_code == 401

    def test_me_with_invalid_token(self, client, db):
        """Test getting user details with invalid token fails."""
        response = client.get(
            "/api/auth/me",
            HTTP_AUTHORIZATION="Bearer invalid_token",
        )

        assert response.status_code == 401
