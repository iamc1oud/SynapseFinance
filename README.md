# Synapse Finance

A full-stack personal finance manager with multi-currency support, subscription tracking, and category-based spending analytics.

## Architecture

```
MoneyManager/
├── synapse/              # Django backend (Python 3.13)
│   ├── accounts/         # Auth, user preferences, currency management
│   ├── ledger/           # Accounts, transactions, categories, tags
│   ├── subscriptions/    # Recurring payment tracking
│   └── synapse/          # Project config, constants, middleware
├── frontend/             # Flutter mobile app
│   └── synapse_finance/
├── docker/               # PgBouncer config, DB init scripts
├── docs/                 # Documentation
└── designs/              # UI mockups
```

## Tech Stack

### Backend

| Layer | Technology |
|-------|-----------|
| Framework | Django 6.0 + Django Ninja 1.5 |
| Database | PostgreSQL 16 with Row-Level Security |
| Auth | JWT (PyJWT) |
| Server | Uvicorn (async, 4 workers) |
| Cache | Redis 7 |
| Connection Pool | PgBouncer |

Row-Level Security (RLS) enforces per-user data isolation at the database level. Dual database connections are used: a default connection with RLS policies applied, and a superuser connection for migrations.

### Frontend

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.10+ |
| State Management | flutter_bloc (Cubit) |
| HTTP | Dio + Retrofit |
| DI | GetIt + Injectable |
| Routing | GoRouter |
| Storage | flutter_secure_storage, shared_preferences |
| Error Handling | dartz (Either) |

Clean Architecture: `domain/` (entities, repositories, usecases) → `data/` (models, datasources, repository impls) → `presentation/` (bloc, pages, widgets).

## API Overview

All endpoints are JWT-authenticated and served under `/api/`.

| Module | Base Path | Key Endpoints |
|--------|-----------|--------------|
| Auth | `/api/auth/` | register, login, refresh, logout, me |
| Accounts | `/api/ledger/accounts/` | CRUD, archive/restore |
| Transactions | `/api/ledger/transactions/` | expense, income, transfer, spending-by-category |
| Categories | `/api/ledger/categories/` | CRUD, archive/restore |
| Tags | `/api/ledger/tags/` | CRUD |
| Subscriptions | `/api/subscriptions/` | CRUD, toggle active, monthly cost summary |
| Currencies | `/api/currencies/` | user currencies, sub-currencies, exchange rates, change primary |

## Key Features

- **Multi-currency** — 147 fiat currencies supported. Set a primary currency, add sub-currencies with live or manual exchange rates.
- **Exchange rate conversion** — Transactions in foreign currencies are auto-converted. Rates can be overridden per-transaction.
- **Subscription tracking** — Weekly, monthly, yearly, or custom billing cycles with next-due-date calculation.
- **Category analytics** — Spending summaries grouped by category with date range filtering.
- **Account archival** — Soft-delete with 30-day retention before permanent removal.
- **Atomic transactions** — All financial mutations use database transactions for consistency.

## Development Setup

### Prerequisites

- Docker & Docker Compose
- Flutter SDK (3.10+)
- Python 3.13+ (for local backend development without Docker)

### Run with Docker

```bash
docker compose up -d
```

This starts:
- **PostgreSQL 16** on port `5432`
- **PgBouncer** on port `6432` (connection pooling)
- **Redis 7** on port `6379`
- **Django app** on port `8000` (Uvicorn with hot-reload)

### Run Backend Locally

```bash
cd synapse
pip install -r requirements.txt   # or: uv sync
python manage.py migrate
uvicorn synapse.asgi:application --reload --port 8000
```

### Run Frontend

```bash
cd frontend/synapse_finance
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### API Docs

With the backend running, interactive API documentation is available at:

```
http://localhost:8000/api/docs
```

## Project Conventions

- **Backend**: Django Ninja routers, Pydantic schemas, RLS middleware for data isolation.
- **Frontend**: One feature per folder under `lib/features/`. Each feature follows Clean Architecture layers. State is managed with Cubits (not full BLoC events). DI is auto-generated via `build_runner` + `injectable`.
- **Commits**: Conventional commits (`feat:`, `fix:`, `refactor:`, etc.).
