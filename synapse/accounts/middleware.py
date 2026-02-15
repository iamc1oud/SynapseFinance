from contextlib import contextmanager

from django.db import connection, transaction
import logging

logger = logging.getLogger(__name__)


@contextmanager
def rls_context(user_id):
    """
    Set the RLS user context for operations outside the middleware
    (e.g. login, register, background tasks).

    Usage:
        with rls_context(user.id):
            RefreshToken.objects.create(user=user, ...)
    """
    if connection.vendor != "postgresql":
        yield
        return

    with connection.cursor() as cursor:
        cursor.execute("SET LOCAL app.current_user_id = %s", [str(user_id)])
    try:
        yield
    finally:
        with connection.cursor() as cursor:
            cursor.execute("RESET app.current_user_id")

class RLSMiddleware:
    """
    Sets the current user ID for RLS policies.

    Uses SET LOCAL which scopes the variables to the current transaction only.
    Wraps the request in a transaction so SET LOCAL has an active transaction block.
    """

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if connection.vendor != "postgresql":
            return self.get_response(request)

        user_id = self._get_user_id(request)

        if user_id is not None:
            with transaction.atomic():
                with connection.cursor() as cursor:
                    cursor.execute("SET LOCAL app.current_user_id = %s", [str(user_id)])
                response = self.get_response(request)
            return response

        return self.get_response(request)

    def _get_user_id(self, request):
        """
        Extract user ID from the request.

        We use JWT auth via Django Ninja (not Django Sessions). we will decode the token here.
        """

        auth_header: str = request.META.get("HTTP_AUTHORIZATION", "")
        if not auth_header.startswith("Bearer "):
            return None

        token = auth_header.split(" ", 1)[1]

        try:
            from accounts.auth import verify_access_token
            user_id = verify_access_token(token)

            return user_id
        except Exception:
            return None
