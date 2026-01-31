from datetime import datetime, timedelta, timezone

import pytest

from accounts.auth import (
    AuthenticationError,
    JWTAuth,
    create_access_token,
    create_refresh_token,
    create_tokens,
    refresh_tokens,
    revoke_all_user_tokens,
    revoke_refresh_token,
    verify_access_token,
    verify_refresh_token,
)
from accounts.models import RefreshToken


class TestAccessToken:
    """Tests for access token creation and verification."""

    def test_create_access_token(self, user):
        """Test creating an access token."""
        token = create_access_token(user.id)

        assert token is not None
        assert isinstance(token, str)
        assert len(token) > 0

    def test_verify_access_token(self, user):
        """Test verifying a valid access token."""
        token = create_access_token(user.id)
        user_id = verify_access_token(token)

        assert user_id == user.id

    def test_verify_invalid_token(self):
        """Test that invalid token raises AuthenticationError."""
        with pytest.raises(AuthenticationError, match="Invalid token"):
            verify_access_token("invalid.token.here")

    def test_verify_expired_token(self, user, monkeypatch):
        """Test that expired token raises AuthenticationError."""
        from accounts import auth

        # Create a token that expires immediately
        monkeypatch.setattr(auth, "ACCESS_TOKEN_EXPIRE_MINUTES", -1)
        token = create_access_token(user.id)

        with pytest.raises(AuthenticationError, match="Token has expired"):
            verify_access_token(token)


class TestRefreshToken:
    """Tests for refresh token creation and verification."""

    def test_create_refresh_token(self, user):
        """Test creating a refresh token."""
        token = create_refresh_token(user)

        assert token is not None
        assert isinstance(token, str)
        assert RefreshToken.objects.filter(token=token, user=user).exists()

    def test_verify_refresh_token(self, user):
        """Test verifying a valid refresh token."""
        token = create_refresh_token(user)
        verified_user = verify_refresh_token(token)

        assert verified_user.pk == user.id

    def test_verify_invalid_refresh_token(self, db):
        """Test that invalid refresh token raises AuthenticationError."""
        with pytest.raises(AuthenticationError, match="Invalid refresh token"):
            verify_refresh_token("nonexistent_token")

    def test_verify_revoked_refresh_token(self, user):
        """Test that revoked refresh token raises AuthenticationError."""
        token = create_refresh_token(user)
        revoke_refresh_token(token)

        with pytest.raises(AuthenticationError, match="expired or revoked"):
            verify_refresh_token(token)

    def test_verify_expired_refresh_token(self, user, db):
        """Test that expired refresh token raises AuthenticationError."""
        token_str = "expired_token_123"
        RefreshToken.objects.create(
            user=user,
            token=token_str,
            expires_at=datetime.now(timezone.utc) - timedelta(days=1),
        )

        with pytest.raises(AuthenticationError, match="expired or revoked"):
            verify_refresh_token(token_str)


class TestTokenOperations:
    """Tests for token operations."""

    def test_create_tokens(self, user):
        """Test creating both access and refresh tokens."""
        access_token, refresh_token = create_tokens(user)

        assert access_token is not None
        assert refresh_token is not None
        assert verify_access_token(access_token) == user.id
        assert verify_refresh_token(refresh_token).pk == user.id

    def test_refresh_tokens_rotates_token(self, user):
        """Test that refreshing tokens rotates the refresh token."""
        _, old_refresh_token = create_tokens(user)

        new_access_token, new_refresh_token = refresh_tokens(old_refresh_token)

        # Old refresh token should be revoked
        old_token = RefreshToken.objects.get(token=old_refresh_token)
        assert old_token.revoked is True

        # New tokens should be valid
        assert verify_access_token(new_access_token) == user.id
        assert new_refresh_token != old_refresh_token

    def test_revoke_refresh_token(self, user):
        """Test revoking a refresh token."""
        token = create_refresh_token(user)
        result = revoke_refresh_token(token)

        assert result is True
        assert RefreshToken.objects.get(token=token).revoked is True

    def test_revoke_nonexistent_token(self, db):
        """Test revoking a nonexistent token returns False."""
        result = revoke_refresh_token("nonexistent_token")
        assert result is False

    def test_revoke_all_user_tokens(self, user):
        """Test revoking all refresh tokens for a user."""
        # Create multiple tokens
        create_refresh_token(user)
        create_refresh_token(user)
        create_refresh_token(user)

        count = revoke_all_user_tokens(user)

        assert count == 3
        assert RefreshToken.objects.filter(user=user, revoked=False).count() == 0


class TestJWTAuth:
    """Tests for JWTAuth bearer authentication."""

    def test_authenticate_valid_token(self, user, rf):
        """Test authenticating with a valid token."""
        token = create_access_token(user.id)
        auth = JWTAuth()

        request = rf.get("/")
        authenticated_user = auth.authenticate(request, token)

        assert authenticated_user is not None
        assert authenticated_user.pk == user.id

    def test_authenticate_invalid_token(self, rf, db):
        """Test that invalid token returns None."""
        auth = JWTAuth()

        request = rf.get("/")
        result = auth.authenticate(request, "invalid_token")

        assert result is None

    def test_authenticate_inactive_user(self, user, rf):
        """Test that inactive user returns None."""
        token = create_access_token(user.id)
        user.is_active = False
        user.save()

        auth = JWTAuth()
        request = rf.get("/")
        result = auth.authenticate(request, token)

        assert result is None

    def test_authenticate_deleted_user(self, user, rf):
        """Test that deleted user returns None."""
        token = create_access_token(user.id)
        user.delete()

        auth = JWTAuth()
        request = rf.get("/")
        result = auth.authenticate(request, token)

        assert result is None
