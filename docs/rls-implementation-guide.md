# Row-Level Security (RLS) in Django + PostgreSQL

A step-by-step guide for implementing RLS in the MoneyManager project.

---

## Table of Contents

1. [Overview](#1-overview)
2. [How RLS Works](#2-how-rls-works)
3. [Step 1 - Set Up Database Roles (Critical)](#step-1---set-up-database-roles-critical)
4. [Step 2 - Configure Django for Dual Roles](#step-2---configure-django-for-dual-roles)
5. [Step 3 - Create the RLS Migration](#step-3---create-the-rls-migration)
6. [Step 4 - Build the RLS Middleware](#step-4---build-the-rls-middleware)
7. [Step 5 - Register the Middleware](#step-5---register-the-middleware)
8. [Step 6 - Add a UserScopedModel Mixin](#step-6---add-a-userscopedmodel-mixin)
9. [Step 7 - Add a UserScopedManager](#step-7---add-a-userscopedmanager)
10. [Step 8 - Apply the Mixin to Models](#step-8---apply-the-mixin-to-models)
11. [Step 9 - Handle the Test Environment](#step-9---handle-the-test-environment)
12. [Step 10 - Write Tests](#step-10---write-tests)
13. [How It All Fits Together](#how-it-all-fits-together)
14. [Checklist for New Models](#checklist-for-new-models)
15. [Gotchas and Tips](#gotchas-and-tips)

---

## 1. Overview

RLS adds a **database-level** access control layer so that even if application code has a bug (missing `.filter(user=...)`) the database itself will refuse to return another user's rows.

We combine two layers:

| Layer | What it does | Protects against |
|-------|-------------|-----------------|
| **PostgreSQL RLS policies** | DB rejects unauthorized rows | ORM bugs, raw SQL mistakes, admin panel leaks |
| **Django QuerySet manager** | ORM auto-filters by user | Keeps views clean, defense in depth |

---

## 2. How RLS Works

```
Request comes in
    |
    v
Middleware sets `app.current_user_id` on the DB connection  (SET LOCAL)
    |
    v
Django ORM runs a query
    |
    v
PostgreSQL checks RLS policy:
    "WHERE user_id = current_setting('app.current_user_id')::int"
    |
    v
Only matching rows are returned
```

`SET LOCAL` is scoped to the **current transaction**, so it auto-resets and can never leak between requests.

---

## Step 1 - Set Up Database Roles (Critical)

**PostgreSQL superusers ALWAYS bypass RLS** — even with `FORCE ROW LEVEL SECURITY`. The default `POSTGRES_USER` created by the Docker image is a superuser, so RLS will silently do nothing if the app connects with it.

The solution is two roles:

| Role | Type | Purpose |
|------|------|---------|
| `synapse` | superuser | Migrations, admin tasks, schema changes |
| `synapse_app` | regular user | App runtime — RLS is enforced |

### Create `docker/init-db.sql`

This runs automatically on first `docker-compose up` (via `docker-entrypoint-initdb.d`):

```sql
-- docker/init-db.sql

CREATE ROLE synapse_app WITH LOGIN PASSWORD 'synapse';
GRANT CONNECT ON DATABASE synapse TO synapse_app;
GRANT USAGE ON SCHEMA public TO synapse_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO synapse_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO synapse_app;

-- Grant on any tables that already exist
GRANT ALL ON ALL TABLES IN SCHEMA public TO synapse_app;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO synapse_app;
```

### Mount it in `docker-compose.yml`

```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: synapse
      POSTGRES_USER: synapse        # superuser — for migrations
      POSTGRES_PASSWORD: synapse
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./docker/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql  # <-- add this
```

### Update the app service to use `synapse_app`

```yaml
  app:
    environment:
      POSTGRES_USER: synapse_app       # non-superuser — RLS enforced
      POSTGRES_PASSWORD: synapse
      POSTGRES_SUPERUSER: synapse      # superuser — for migrations
      POSTGRES_SUPERUSER_PASSWORD: synapse
```

### For an existing database

If you already have a running database, run this manually (as `synapse` superuser):

```sql
CREATE ROLE synapse_app WITH LOGIN PASSWORD 'synapse';
GRANT CONNECT ON DATABASE synapse TO synapse_app;
GRANT USAGE ON SCHEMA public TO synapse_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO synapse_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO synapse_app;
GRANT ALL ON ALL TABLES IN SCHEMA public TO synapse_app;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO synapse_app;
```

### Verify the role is NOT a superuser

```sql
SELECT rolname, rolsuper FROM pg_roles WHERE rolname = 'synapse_app';
-- Expected: rolsuper = f
```

---

## Step 2 - Configure Django for Dual Roles

```python
# settings.py

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('POSTGRES_DB', 'synapse'),
        'USER': os.getenv('POSTGRES_USER', 'synapse_app'),      # non-superuser
        'PASSWORD': os.getenv('POSTGRES_PASSWORD', 'synapse'),
        'HOST': os.getenv('POSTGRES_HOST', 'localhost'),
        'PORT': os.getenv('POSTGRES_PORT', '5432'),
        'ATOMIC_REQUESTS': True,  # required for SET LOCAL
    },
    # Superuser connection for migrations (bypasses RLS).
    'superuser': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('POSTGRES_DB', 'synapse'),
        'USER': os.getenv('POSTGRES_SUPERUSER', 'synapse'),     # superuser
        'PASSWORD': os.getenv('POSTGRES_SUPERUSER_PASSWORD', 'synapse'),
        'HOST': os.getenv('POSTGRES_HOST', 'localhost'),
        'PORT': os.getenv('POSTGRES_PORT', '5432'),
    },
}
```

### Running migrations

Always run migrations with the superuser connection:

```bash
python manage.py migrate --database=superuser
```

The `synapse_app` role has `ALL` privileges on tables but cannot create/alter schema — that's the superuser's job.

---

## Step 3 - Create the RLS Migration

Create a new migration to enable RLS policies on all user-scoped tables.

```bash
python manage.py makemigrations accounts --empty -n enable_rls_policies
```

Edit the generated migration file:

```python
# accounts/migrations/XXXX_enable_rls_policies.py

from django.db import migrations

# Tables that have a user_id column and need RLS
RLS_TABLES = [
    "refresh_tokens",
    "sub_currencies",
    "user_preferences",
]


def enable_rls(apps, schema_editor):
    """Enable RLS on all user-scoped tables."""
    for table in RLS_TABLES:
        schema_editor.execute(f"ALTER TABLE {table} ENABLE ROW LEVEL SECURITY;")

        # Force RLS even for table owners (important!)
        schema_editor.execute(f"ALTER TABLE {table} FORCE ROW LEVEL SECURITY;")

        # Policy: users can only see their own rows
        schema_editor.execute(f"""
            CREATE POLICY user_isolation_policy ON {table}
                USING (user_id = current_setting('app.current_user_id', true)::int);
        """)


def disable_rls(apps, schema_editor):
    """Reverse: disable RLS on all tables."""
    for table in RLS_TABLES:
        schema_editor.execute(
            f"DROP POLICY IF EXISTS user_isolation_policy ON {table};"
        )
        schema_editor.execute(f"ALTER TABLE {table} DISABLE ROW LEVEL SECURITY;")


class Migration(migrations.Migration):

    dependencies = [
        # Set this to your latest migration
        ("accounts", "XXXX_previous_migration"),
    ]

    operations = [
        migrations.RunSQL(
            sql=migrations.RunSQL.noop,
            reverse_sql=migrations.RunSQL.noop,
        ),
        migrations.RunPython(enable_rls, reverse_code=disable_rls),
    ]
```

### What each SQL statement does

| Statement | Purpose |
|-----------|---------|
| `ENABLE ROW LEVEL SECURITY` | Turns on RLS for the table |
| `FORCE ROW LEVEL SECURITY` | Applies RLS even to the table owner role (without this, the DB owner bypasses RLS) |
| `CREATE POLICY ... USING (...)` | Defines the filter condition. `current_setting('app.current_user_id', true)` reads the session variable; `true` makes it return NULL instead of erroring if unset |

### About the `user_preferences` M2M table

The `sub_currencies` M2M through-table (auto-generated by Django for `AppPreference.sub_currencies`) does not have a direct `user_id` column. You have two options:

**Option A** - Don't apply RLS to the M2M table. Access it only through the parent models that already have RLS.

**Option B** - Create an explicit through-model with a `user_id` column and apply RLS to it.

Option A is simpler and sufficient for most cases. The M2M table is only accessed via `AppPreference` (which is already protected).

---

## Step 4 - Build the RLS Middleware

Create a new file: `synapse/accounts/middleware.py`

```python
# accounts/middleware.py

from django.db import connection, transaction
import logging

logger = logging.getLogger(__name__)


class RLSMiddleware:
    """
    Sets the current user ID as a PostgreSQL session variable
    so that RLS policies can filter rows by user.

    Uses SET LOCAL which scopes the variable to the current
    transaction only - it auto-resets after each request.

    Wraps the request in transaction.atomic() so SET LOCAL
    has an active transaction block.
    """

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Skip RLS for non-PostgreSQL databases (e.g. SQLite in tests)
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

        Django Ninja runs auth at the VIEW level (after middleware),
        so we decode the JWT here in middleware ourselves.
        """
        auth_header = request.META.get("HTTP_AUTHORIZATION", "")
        if not auth_header.startswith("Bearer "):
            return None

        token = auth_header.split(" ", 1)[1]

        try:
            from accounts.auth import verify_access_token
            user_id = verify_access_token(token)
            return user_id
        except Exception:
            return None
```

### Why `transaction.atomic()` in the middleware?

`SET LOCAL` only works inside a transaction. Even though `ATOMIC_REQUESTS` is set in Django settings, that wraps the **view** — but middleware runs **outside** that wrapper. So `SET LOCAL` would fail with:

```
SET LOCAL can only be used in transaction blocks
```

By wrapping `SET LOCAL` + `self.get_response(request)` together in `transaction.atomic()`, both the variable and the view queries share the same transaction.

### Why `SET LOCAL` and not `SET`?

| Command | Scope | Risk |
|---------|-------|------|
| `SET` | Entire connection (persists across requests if connection is pooled) | User A's ID could leak to User B's request |
| `SET LOCAL` | Current transaction only | Auto-resets when the transaction ends. Safe with connection pooling |

---

## Step 5 - Register the Middleware

```python
# settings.py

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'accounts.middleware.RLSMiddleware',  # <-- Add after auth middleware
]
```

Place it **after** `AuthenticationMiddleware` so session-based auth (e.g. admin panel) is resolved first.

---

## Step 6 - Add a UserScopedModel Mixin

This is the Django-level defense layer. Create a base mixin that all user-scoped models inherit from.

```python
# accounts/mixins.py

from django.db import models
from django.conf import settings


class UserScopedManager(models.Manager):
    """
    Manager that auto-filters querysets by the current user.
    Used as a Django-level complement to PostgreSQL RLS.
    """

    def for_user(self, user):
        return self.get_queryset().filter(user=user)


class UserScopedModel(models.Model):
    """
    Abstract base model for any model that belongs to a user.
    Provides:
      - A `user` ForeignKey
      - A `scoped` manager that can filter by user
      - The default manager remains unfiltered (for admin, migrations, etc.)
    """

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="%(class)s_set",
    )

    objects = models.Manager()        # Default manager (unfiltered)
    scoped = UserScopedManager()      # User-scoped manager

    class Meta:
        abstract = True
```

---

## Step 7 - Add a UserScopedManager

Already included in Step 6 above. Usage in views:

```python
# In a Django Ninja endpoint:

@router.get("/currencies", auth=JWTAuth())
def list_currencies(request):
    user = request.auth
    currencies = SubCurrency.scoped.for_user(user)
    return list(currencies)
```

Or if you want to make `objects` itself auto-scope (more aggressive):

```python
# Alternative: Override default manager to require user context

class StrictUserScopedManager(models.Manager):
    """
    Raises an error if you query without specifying a user.
    Prevents accidental unscoped queries.
    """

    def get_queryset(self):
        # Returns the full queryset - RLS at the DB level will still protect
        return super().get_queryset()

    def for_user(self, user):
        return self.get_queryset().filter(user=user)
```

The recommended approach is to keep `objects` as the default unfiltered manager (needed for admin, migrations, signals) and use `scoped.for_user(user)` explicitly in views.

---

## Step 8 - Apply the Mixin to Models

Update existing models to use the mixin:

```python
# accounts/models.py

from accounts.mixins import UserScopedModel

class SubCurrency(UserScopedModel):
    """
    No need to declare `user` here anymore - it comes from UserScopedModel.
    """
    currency = models.CharField(max_length=3, choices=CURRENCIES, default=settings.DEFAULT_CURRENCY)
    exchange_rate = models.DecimalField(max_digits=10, decimal_places=7, default=1.0)
    unit_position = models.CharField(max_length=10, choices=UNIT_POSITIONS, default=UNIT_POSITIONS[0][0])
    decimal_point = models.DecimalField(max_digits=10, decimal_places=7, default=1.0)

    class Meta:
        db_table = "sub_currencies"


class AppPreference(UserScopedModel):
    """
    Override the `user` field to be OneToOne instead of FK.
    """
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="preferences")
    language = models.CharField(max_length=10, choices=settings.LANGUAGES, default=settings.LANGUAGE_CODE)
    main_currency = models.ForeignKey(SubCurrency, on_delete=models.CASCADE, ...)
    sub_currencies = models.ManyToManyField(SubCurrency, ...)
    timezone = models.CharField(max_length=32, ...)

    class Meta:
        db_table = "user_preferences"
```

For any **new** model in future apps, just inherit from `UserScopedModel`:

```python
class Transaction(UserScopedModel):
    amount = models.DecimalField(...)
    description = models.TextField(...)
    # `user` FK is inherited automatically
```

---

## Step 9 - Handle the Test Environment

Tests use SQLite (in-memory), which doesn't support RLS. You need to handle this gracefully.

### Option A: Skip RLS middleware in tests (recommended)

The middleware already handles this with the `connection.vendor` check (see Step 4). When tests use SQLite, the middleware is a no-op.

### Option B: Use PostgreSQL for tests too

If you want to test RLS policies themselves:

```python
# test_settings.py - Use PostgreSQL for RLS tests

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "synapse_test",
        "USER": "synapse",
        "PASSWORD": "synapse",
        "HOST": "localhost",
        "PORT": "5432",
        "ATOMIC_REQUESTS": True,
    }
}
```

You can use a pytest marker to run RLS-specific tests only when PostgreSQL is available:

```python
# conftest.py
import pytest
from django.db import connection

requires_postgres = pytest.mark.skipif(
    connection.vendor != "postgresql",
    reason="RLS tests require PostgreSQL",
)
```

---

## Step 10 - Write Tests

### Test: User cannot see another user's data (Django-level)

```python
# accounts/tests/test_rls.py

import pytest
from accounts.models import SubCurrency, User


@pytest.mark.django_db
class TestUserIsolation:

    def test_scoped_manager_filters_by_user(self, user, another_user):
        """Verify .scoped.for_user() only returns that user's rows."""
        SubCurrency.objects.create(user=user, currency="USD")
        SubCurrency.objects.create(user=another_user, currency="EUR")

        user_currencies = SubCurrency.scoped.for_user(user)
        assert user_currencies.count() == 1
        assert user_currencies.first().currency == "USD"

    def test_default_manager_returns_all(self, user, another_user):
        """Default manager is unfiltered (for admin use)."""
        SubCurrency.objects.create(user=user, currency="USD")
        SubCurrency.objects.create(user=another_user, currency="EUR")

        all_currencies = SubCurrency.objects.all()
        assert all_currencies.count() == 2
```

### Test: RLS policy at database level (requires PostgreSQL)

```python
@requires_postgres
@pytest.mark.django_db(transaction=True)
class TestDatabaseRLS:

    def test_rls_blocks_cross_user_access(self, user, another_user):
        """
        With RLS active and app.current_user_id set,
        the database itself should filter rows.
        """
        from django.db import connection

        SubCurrency.objects.create(user=user, currency="USD")
        SubCurrency.objects.create(user=another_user, currency="EUR")

        # Set the session to user's ID
        with connection.cursor() as cursor:
            cursor.execute("SET LOCAL app.current_user_id = %s;", [str(user.id)])

        # Even with objects.all(), RLS should filter
        currencies = SubCurrency.objects.all()
        assert currencies.count() == 1
        assert currencies.first().user == user
```

---

## How It All Fits Together

```
                         REQUEST LIFECYCLE
                         =================

  Client sends request with JWT Bearer token
                    |
                    v
  +-----------------------------------------+
  |  Django Middleware Stack                 |
  |  ...                                    |
  |  AuthenticationMiddleware               |
  |  RLSMiddleware                          |
  |    -> Decodes JWT                       |
  |    -> SET LOCAL app.current_user_id = X |
  +-----------------------------------------+
                    |
                    v
  +-----------------------------------------+
  |  Django Ninja View                      |
  |  JWTAuth resolves request.auth = User   |
  |                                         |
  |  SubCurrency.scoped.for_user(user)      |
  |    -> Django adds WHERE user_id = X     |
  +-----------------------------------------+
                    |
                    v
  +-----------------------------------------+
  |  PostgreSQL                             |
  |  RLS policy ALSO enforces:              |
  |    WHERE user_id = current_user_id      |
  |                                         |
  |  Double protection!                     |
  +-----------------------------------------+
                    |
                    v
  Only the authenticated user's rows are returned
```

---

## Checklist for New Models

When adding a new model that stores user data:

- [ ] Inherit from `UserScopedModel`
- [ ] Add the table name to `RLS_TABLES` in the RLS migration (create a new migration)
- [ ] Use `Model.scoped.for_user(request.auth)` in all view queries
- [ ] Write a test that verifies user isolation
- [ ] If the model has no direct `user_id` column (e.g. it's accessed through a parent), decide if it needs its own RLS policy or if the parent's policy is sufficient

---

## Gotchas and Tips

### 1. Superuser / Admin bypass

**PostgreSQL superusers ALWAYS bypass RLS** — `FORCE ROW LEVEL SECURITY` does NOT apply to superusers. This is why we use a non-superuser role (`synapse_app`) for the app (see Step 1).

For the Django admin panel (which uses session auth, not JWT), the middleware won't find a Bearer token, so `app.current_user_id` stays unset. The RLS policy uses `current_setting('app.current_user_id', true)` which returns NULL when unset, meaning no rows match. To let the admin see all rows, add a bypass policy:

```sql
CREATE POLICY admin_bypass ON sub_currencies
    USING (current_setting('app.current_user_id', true) IS NULL);
```

This allows full access when no user ID is set.

### 2. Connection pooling

`SET LOCAL` is transaction-scoped, so it's safe with connection pooling (PgBouncer, etc.) as long as `ATOMIC_REQUESTS = True` is set. The variable resets when the transaction commits or rolls back.

### 3. Celery / background tasks

Background tasks (Celery, management commands) don't go through middleware. You need to manually set the user context:

```python
from django.db import connection

def process_user_data(user_id):
    with connection.cursor() as cursor:
        cursor.execute("SET LOCAL app.current_user_id = %s;", [str(user_id)])
    # Now RLS policies will apply for this user
```

Or create a context manager:

```python
from contextlib import contextmanager
from django.db import connection


@contextmanager
def rls_context(user_id):
    """Set RLS context for background tasks."""
    with connection.cursor() as cursor:
        cursor.execute("SET LOCAL app.current_user_id = %s;", [str(user_id)])
    try:
        yield
    finally:
        with connection.cursor() as cursor:
            cursor.execute("RESET app.current_user_id;")


# Usage:
with rls_context(user_id=42):
    transactions = Transaction.objects.all()  # RLS-filtered
```

### 4. Migrations

Migrations run outside of RLS context (no user ID set). The `current_setting('app.current_user_id', true)` with `true` as the second argument returns NULL when unset instead of raising an error. Combined with the admin bypass policy, migrations work fine.

### 5. Performance

RLS adds negligible overhead. PostgreSQL appends the policy condition to the query plan as a filter, similar to adding a `WHERE` clause. If your `user_id` columns are indexed (they are, since they're ForeignKeys), performance impact is minimal.

### 6. Debugging RLS

To check what policies are active on a table:

```sql
SELECT * FROM pg_policies WHERE tablename = 'sub_currencies';
```

To see the current session variable:

```sql
SELECT current_setting('app.current_user_id', true);
```

To temporarily disable RLS for debugging (superuser only):

```sql
SET row_security = off;
```
