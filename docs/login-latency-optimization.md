# Login Endpoint Latency Optimization Guide

## Benchmark Baseline (Django dev server, 100 concurrent users)

| Metric              | Value    |
|---------------------|----------|
| Successful (200)    | 52/100   |
| Server errors (500) | 22       |
| Timeouts            | 23       |
| Avg latency         | 6,634ms  |
| Throughput           | 7.4 req/s |

Root causes identified:
- **Single-threaded dev server** (`manage.py runserver`) — cannot handle concurrent requests
- **Bcrypt `check_password`** — CPU-intensive, blocks worker for ~200-300ms per call
- **No DB connection pooling** — each request opens a new connection, exhausting PostgreSQL under load

---

## Step 1: Replace Django Dev Server with Uvicorn

The dev server is single-threaded. Uvicorn with multiple workers allows concurrent request handling.

### Install

Add to `pyproject.toml`:
```toml
"uvicorn[standard]>=0.34.0",
```

### Update Dockerfile

```dockerfile
CMD ["uv", "run", "uvicorn", "synapse.asgi:application", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

### Worker count guideline

`workers = (2 * CPU_CORES) + 1`

For dev (Docker on Mac): 4 workers is a good starting point.

**Expected impact:** ~4x throughput improvement.

---

## Step 2: Add DB Connection Pooling

Without pooling, 100 concurrent requests = 100 new DB connections, which exhausts PostgreSQL's `max_connections` (default ~100) and causes 500 errors.

### Install

Add to `pyproject.toml`:
```toml
"django-db-connection-pool>=1.2.5",
```

### Update `settings.py`

```python
DATABASES = {
    'default': {
        'ENGINE': 'dj_db_conn_pool.backends.postgresql',  # pooled backend
        'NAME': os.getenv('POSTGRES_DB', 'synapse'),
        'USER': os.getenv('POSTGRES_USER', 'synapse_app'),
        'PASSWORD': os.getenv('POSTGRES_PASSWORD', 'synapse'),
        'HOST': os.getenv('POSTGRES_HOST', 'localhost'),
        'PORT': os.getenv('POSTGRES_PORT', '5432'),
        'POOL_OPTIONS': {
            'POOL_SIZE': 10,       # persistent connections
            'MAX_OVERFLOW': 20,    # extra connections under burst
        },
    },
}
```

**Expected impact:** Eliminates 500 errors from connection exhaustion.

---

## Step 3: Lower Bcrypt Cost (Security Trade-off)

Django defaults to bcrypt with 14 rounds. Each `check_password` call takes ~200-300ms. Lowering rounds speeds this up.

### Option A: Reduce bcrypt rounds

Add to `settings.py`:
```python
PASSWORD_HASHERS = [
    "django.contrib.auth.hashers.BCryptSHA256PasswordHasher",
]
```

Then create a custom hasher:
```python
# accounts/hashers.py
from django.contrib.auth.hashers import BCryptSHA256PasswordHasher

class FastBCryptHasher(BCryptSHA256PasswordHasher):
    rounds = 10  # default is 14; each round halves the time
```

```python
# settings.py
PASSWORD_HASHERS = [
    "accounts.hashers.FastBCryptHasher",
    "django.contrib.auth.hashers.BCryptSHA256PasswordHasher",  # reads old hashes
]
```

### Option B: Switch to Argon2 (recommended by OWASP)

```toml
# pyproject.toml
"argon2-cffi>=23.1.0",
```

```python
# settings.py
PASSWORD_HASHERS = [
    "django.contrib.auth.hashers.Argon2PasswordHasher",
    "django.contrib.auth.hashers.BCryptSHA256PasswordHasher",  # reads old hashes
]
```

> Note: Existing passwords will be re-hashed on next login automatically.

**Expected impact:** ~2-4x faster per login request.

---

## Step 4: Add Rate Limiting on Login

Prevents thundering herd and brute-force attacks from overwhelming workers.

### Using Django Ninja throttling

```python
from ninja.throttling import AnonRateThrottle

login_throttle = AnonRateThrottle("10/minute")

@router.post("/login", response={200: AuthResponse, 401: ErrorResponse}, throttle=[login_throttle])
def login(request, payload: LoginRequest):
    ...
```

**Expected impact:** Prevents server overload under burst traffic.

---

## Step 5: Increase PostgreSQL max_connections

Default is ~100. With pooling + multiple workers, increase this to be safe.

### In `docker-compose.yml`:

```yaml
db:
  image: postgres:16-alpine
  command: postgres -c max_connections=200
```

**Expected impact:** Prevents DB-level connection refusal.

---

## Summary

| Change                     | Latency Impact              | Effort  |
|----------------------------|-----------------------------|---------|
| Uvicorn + 4 workers       | ~4x throughput              | Low     |
| DB connection pooling      | Eliminates 500 errors       | Low     |
| Lower bcrypt rounds        | ~2-4x faster per login      | Low     |
| Rate limiting              | Prevents overload           | Low     |
| Increase max_connections   | Prevents DB errors          | Trivial |

**Priority order:** Step 1 > Step 2 > Step 5 > Step 3 > Step 4
