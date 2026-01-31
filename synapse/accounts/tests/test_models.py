import pytest
from django.db import IntegrityError

from accounts.models import RefreshToken, User


class TestUserManager:
    """Tests for the custom UserManager."""

    def test_create_user(self, db):
        """Test creating a regular user."""
        user = User.objects.create_user(
            email="newuser@example.com",
            password="testpass123",
            first_name="New",
            last_name="User",
        )

        assert user.email == "newuser@example.com"
        assert user.first_name == "New"
        assert user.last_name == "User"
        assert user.is_active is True
        assert user.is_staff is False
        assert user.is_superuser is False
        assert user.check_password("testpass123")

    def test_create_user_normalizes_email(self, db):
        """Test that email is normalized on user creation."""
        user = User.objects.create_user(
            email="Test@EXAMPLE.COM",
            password="testpass123",
        )

        assert user.email == "Test@example.com"

    def test_create_user_without_email_raises_error(self, db):
        """Test that creating user without email raises ValueError."""
        with pytest.raises(ValueError, match="Email address is required"):
            User.objects.create_user(email="", password="testpass123")

    def test_create_superuser(self, db):
        """Test creating a superuser."""
        superuser = User.objects.create_superuser(
            email="admin@example.com",
            password="adminpass123",
        )

        assert superuser.email == "admin@example.com"
        assert superuser.is_active is True
        assert superuser.is_staff is True
        assert superuser.is_superuser is True

    def test_create_superuser_without_is_staff_raises_error(self, db):
        """Test that superuser must have is_staff=True."""
        with pytest.raises(ValueError, match="Superuser must have is_staff=True"):
            User.objects.create_superuser(
                email="admin@example.com",
                password="adminpass123",
                is_staff=False,
            )

    def test_create_superuser_without_is_superuser_raises_error(self, db):
        """Test that superuser must have is_superuser=True."""
        with pytest.raises(ValueError, match="Superuser must have is_superuser=True"):
            User.objects.create_superuser(
                email="admin@example.com",
                password="adminpass123",
                is_superuser=False,
            )


class TestUserModel:
    """Tests for the User model."""

    def test_user_str(self, user):
        """Test user string representation."""
        assert str(user) == user.email

    def test_get_full_name_with_names(self, user):
        """Test get_full_name with first and last name."""
        assert user.get_full_name() == "Test User"

    def test_get_full_name_without_names(self, db):
        """Test get_full_name falls back to email."""
        user = User.objects.create_user(email="noname@example.com", password="pass123")
        assert user.get_full_name() == "noname@example.com"

    def test_get_short_name_with_first_name(self, user):
        """Test get_short_name returns first name."""
        assert user.get_short_name() == "Test"

    def test_get_short_name_without_first_name(self, db):
        """Test get_short_name falls back to email prefix."""
        user = User.objects.create_user(email="noname@example.com", password="pass123")
        assert user.get_short_name() == "noname"

    def test_email_uniqueness(self, user, db):
        """Test that duplicate emails are not allowed."""
        with pytest.raises(IntegrityError):
            User.objects.create_user(email=user.email, password="anotherpass")

    def test_user_date_joined_auto_set(self, user):
        """Test that date_joined is automatically set."""
        assert user.date_joined is not None


class TestRefreshTokenModel:
    """Tests for the RefreshToken model."""

    def test_refresh_token_str(self, user, user_tokens):
        """Test refresh token string representation."""
        token = RefreshToken.objects.get(user=user)
        assert str(token) == f"RefreshToken for {user.email}"

    def test_is_valid_for_new_token(self, user, user_tokens):
        """Test that a new token is valid."""
        token = RefreshToken.objects.get(user=user)
        assert token.is_valid is True
        assert token.is_expired is False
        assert token.revoked is False

    def test_is_valid_for_revoked_token(self, user, user_tokens):
        """Test that a revoked token is not valid."""
        token = RefreshToken.objects.get(user=user)
        token.revoked = True
        token.save()

        assert token.is_valid is False

    def test_refresh_token_cascade_delete(self, user, user_tokens):
        """Test that refresh tokens are deleted when user is deleted."""
        user_id = user.id
        user.delete()

        assert RefreshToken.objects.filter(user_id=user_id).count() == 0
