import hashlib

from asgiref.sync import sync_to_async
from django.conf import settings
from django.core.cache import cache

from .models import User


async def check_password_cached(user: User, password: str) -> bool:
    """
    Check a user's password with Redis caching.

    Cache key: pwd_ok:{user_id}:{sha256(password + stored_hash)}
    Only correct passwords are cached. Wrong passwords always run bcrypt.
    If Redis is down, falls back to bcrypt silently.
    """
    stored_hash = user.password
    digest = hashlib.sha256(
        (password + stored_hash).encode("utf-8")
    ).hexdigest()
    cache_key = f"pwd_ok:{user.pk}:{digest}"
    ttl = getattr(settings, "PASSWORD_CACHE_TTL", 300)

    # Try cache first, fall back to bcrypt on any Redis error
    try:
        cached = await sync_to_async(cache.get)(cache_key)
        if cached is not None:
            return True
    except Exception:
        pass

    # Cache miss: run the expensive bcrypt check
    is_correct = await sync_to_async(user.check_password)(password)

    if is_correct:
        try:
            await sync_to_async(cache.set)(cache_key, "1", ttl)
        except Exception:
            pass

    return is_correct
