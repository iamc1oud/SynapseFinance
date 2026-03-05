# PgBouncer Connection Pooling Setup

## Why PgBouncer?

PostgreSQL has a hard limit on concurrent connections (`max_connections`, default 100). Under high concurrency (e.g., 1000 simultaneous requests), the app exhausts all available connections and the database rejects new ones with:

```
FATAL: remaining connection slots are reserved for roles with the SUPERUSER attribute
```

PgBouncer sits between the app and PostgreSQL, multiplexing many client connections over a small pool of actual database connections.

## Architecture

```
App (up to 1000 connections) → PgBouncer (20 server connections) → PostgreSQL (max_connections=200)
```

## Configuration Files

### `docker/pgbouncer.ini`

| Setting | Value | Purpose |
|---------|-------|---------|
| `pool_mode` | `transaction` | Connections returned to pool after each transaction. Required for RLS with `SET LOCAL`. |
| `max_client_conn` | `1000` | Max connections PgBouncer accepts from the app |
| `default_pool_size` | `20` | Actual PostgreSQL connections per user/database pair |
| `min_pool_size` | `5` | Always keep at least 5 connections open |
| `reserve_pool_size` | `5` | Extra connections for burst traffic |
| `reserve_pool_timeout` | `3` | Seconds before using reserve pool |
| `server_lifetime` | `3600` | Reconnect server connections after 1 hour |
| `server_idle_timeout` | `600` | Close idle server connections after 10 minutes |
| `auth_type` | `md5` | Password authentication method |

### `docker/userlist.txt`

Contains credentials for users that PgBouncer authenticates:

```
"synapse_app" "synapse"    # Application user (RLS-enforced)
"synapse" "synapse"        # Superuser (migrations only)
```

### `docker-compose.yml` Changes

PgBouncer service added between `db` and `app`:

```yaml
pgbouncer:
  image: edoburu/pgbouncer:1.24.0-p0
  volumes:
    - ./docker/pgbouncer.ini:/etc/pgbouncer/pgbouncer.ini
    - ./docker/userlist.txt:/etc/pgbouncer/userlist.txt
  ports:
    - "6432:6432"
  depends_on:
    db:
      condition: service_healthy
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -h localhost -p 6432"]
    interval: 5s
    timeout: 5s
    retries: 5
```

App environment updated to connect through PgBouncer:

```yaml
POSTGRES_HOST: pgbouncer   # was: db
POSTGRES_PORT: 6432        # was: 5432
```

### Django Settings

```python
DATABASES = {
    'default': {
        ...
        'CONN_MAX_AGE': 0,  # Let PgBouncer handle pooling, don't persist Django-side
    },
}
```

`CONN_MAX_AGE` must be `0` with PgBouncer transaction pooling. If Django holds connections open, PgBouncer can't reclaim them for other clients.

## Transaction Pooling and RLS

`pool_mode = transaction` is critical for this project because Row-Level Security (RLS) uses `SET LOCAL`:

```sql
SET LOCAL app.current_user_id = '123';
```

`SET LOCAL` scopes the setting to the current transaction. With transaction pooling, each transaction gets a clean connection state, so RLS contexts don't leak between requests.

**Do NOT use `session` pool mode** — it would cause RLS context from one request to persist into subsequent requests from different users.

## Monitoring

Connect to PgBouncer admin console:

```bash
psql -h localhost -p 6432 -U synapse pgbouncer
```

Useful commands:

```sql
SHOW POOLS;      -- Pool stats per user/database
SHOW CLIENTS;    -- Connected client details
SHOW SERVERS;    -- Backend PostgreSQL connections
SHOW STATS;      -- Aggregate statistics
```

## Tuning Guide

| Scenario | Adjustment |
|----------|------------|
| More concurrent users | Increase `max_client_conn` |
| Queries queuing too long | Increase `default_pool_size` (and PostgreSQL `max_connections`) |
| Burst traffic spikes | Increase `reserve_pool_size`, lower `reserve_pool_timeout` |
| Memory pressure on PostgreSQL | Decrease `default_pool_size` |

**Rule of thumb:** `default_pool_size` should be less than PostgreSQL's `max_connections` minus a buffer for superuser/migration connections (keep ~10-20 reserved).

Current setup: `default_pool_size(20) + reserve(5) = 25` server connections, well within `max_connections=200`.
