import pytest
from decimal import Decimal
from datetime import date
from django.test import Client

from ledger.models import Account, Transaction


@pytest.fixture
def client():
    return Client()


# ── Account Endpoints ────────────────────────────────────────────────────────

@pytest.mark.django_db
class TestAccountEndpoints:
    def test_create_account(self, client, auth_headers):
        response = client.post(
            "/api/ledger/accounts/",
            data={"name": "My Savings", "account_type": "savings", "balance": "1000.00", "currency": "USD"},
            content_type="application/json",
            **auth_headers,
        )
        assert response.status_code == 201
        data = response.json()
        assert data["name"] == "My Savings"
        assert data["account_type"] == "savings"
        assert Decimal(data["balance"]) == Decimal("1000.00")

    def test_list_accounts(self, client, auth_headers, checking_account, savings_account):
        response = client.get("/api/ledger/accounts/", **auth_headers)
        assert response.status_code == 200
        assert len(response.json()) == 2

    def test_get_account(self, client, auth_headers, checking_account):
        response = client.get(f"/api/ledger/accounts/{checking_account.id}", **auth_headers)
        assert response.status_code == 200
        assert response.json()["name"] == "Main Checking"

    def test_get_account_not_found(self, client, auth_headers):
        response = client.get("/api/ledger/accounts/99999", **auth_headers)
        assert response.status_code == 404

    def test_requires_auth(self, client):
        response = client.get("/api/ledger/accounts/")
        assert response.status_code == 401


# ── Category Endpoints ───────────────────────────────────────────────────────

@pytest.mark.django_db
class TestCategoryEndpoints:
    def test_create_expense_category(self, client, auth_headers):
        response = client.post(
            "/api/ledger/categories/",
            data={"name": "Transport", "icon": "car", "category_type": "expense"},
            content_type="application/json",
            **auth_headers,
        )
        assert response.status_code == 201
        assert response.json()["name"] == "Transport"

    def test_list_categories_all(self, client, auth_headers, expense_category, income_category):
        response = client.get("/api/ledger/categories/", **auth_headers)
        assert response.status_code == 200
        assert len(response.json()) == 2

    def test_list_categories_filter_by_type(self, client, auth_headers, expense_category, income_category):
        response = client.get("/api/ledger/categories/?category_type=expense", **auth_headers)
        assert response.status_code == 200
        assert all(c["category_type"] == "expense" for c in response.json())


# ── Tag Endpoints ────────────────────────────────────────────────────────────

@pytest.mark.django_db
class TestTagEndpoints:
    def test_create_tag(self, client, auth_headers):
        response = client.post(
            "/api/ledger/tags/",
            data={"name": "Emergency"},
            content_type="application/json",
            **auth_headers,
        )
        assert response.status_code == 201
        assert response.json()["name"] == "Emergency"

    def test_list_tags(self, client, auth_headers, tag):
        response = client.get("/api/ledger/tags/", **auth_headers)
        assert response.status_code == 200
        assert len(response.json()) == 1
        assert response.json()[0]["name"] == "Savings"


# ── Transaction: Expense ─────────────────────────────────────────────────────

@pytest.mark.django_db
class TestExpenseEndpoint:
    def test_create_expense(self, client, auth_headers, checking_account, expense_category):
        initial_balance = checking_account.balance
        response = client.post(
            "/api/ledger/transactions/expense",
            data={
                "amount": "50.00",
                "account_id": checking_account.id,
                "category_id": expense_category.id,
                "date": "2023-10-24",
                "note": "Lunch",
            },
            content_type="application/json",
            **auth_headers,
        )
        assert response.status_code == 201
        data = response.json()
        assert data["transaction_type"] == "expense"
        assert Decimal(data["amount"]) == Decimal("50.00")
        assert data["account"]["name"] == "Main Checking"

        checking_account.refresh_from_db()
        assert checking_account.balance == initial_balance - Decimal("50.00")

    def test_expense_wrong_category_type(self, client, auth_headers, checking_account, income_category):
        response = client.post(
            "/api/ledger/transactions/expense",
            data={
                "amount": "50.00",
                "account_id": checking_account.id,
                "category_id": income_category.id,
                "date": "2023-10-24",
            },
            content_type="application/json",
            **auth_headers,
        )
        assert response.status_code == 400
        assert "category" in response.json()["detail"].lower()

    def test_expense_with_tags(self, client, auth_headers, checking_account, expense_category, tag):
        response = client.post(
            "/api/ledger/transactions/expense",
            data={
                "amount": "30.00",
                "account_id": checking_account.id,
                "category_id": expense_category.id,
                "date": "2023-10-24",
                "tag_ids": [tag.id],
            },
            content_type="application/json",
            **auth_headers,
        )
        assert response.status_code == 201
        assert len(response.json()["tags"]) == 1


# ── Transaction: Income ──────────────────────────────────────────────────────

@pytest.mark.django_db
class TestIncomeEndpoint:
    def test_create_income(self, client, auth_headers, checking_account, income_category):
        initial_balance = checking_account.balance
        response = client.post(
            "/api/ledger/transactions/income",
            data={
                "amount": "3000.00",
                "account_id": checking_account.id,
                "category_id": income_category.id,
                "date": "2023-10-24",
                "note": "Monthly salary",
            },
            content_type="application/json",
            **auth_headers,
        )
        assert response.status_code == 201
        data = response.json()
        assert data["transaction_type"] == "income"

        checking_account.refresh_from_db()
        assert checking_account.balance == initial_balance + Decimal("3000.00")


# ── Transaction: Transfer ─────────────────────────────────────────────────────

@pytest.mark.django_db
class TestTransferEndpoint:
    def test_create_transfer(self, client, auth_headers, checking_account, savings_account):
        checking_initial = checking_account.balance
        savings_initial = savings_account.balance

        response = client.post(
            "/api/ledger/transactions/transfer",
            data={
                "amount": "2450.00",
                "from_account_id": checking_account.id,
                "to_account_id": savings_account.id,
                "date": "2023-10-24",
                "note": "Monthly savings",
            },
            content_type="application/json",
            **auth_headers,
        )
        assert response.status_code == 201
        data = response.json()
        assert data["transaction_type"] == "transfer"
        assert data["account"]["name"] == "Main Checking"
        assert data["to_account"]["name"] == "High Yield Savings"

        checking_account.refresh_from_db()
        savings_account.refresh_from_db()
        assert checking_account.balance == checking_initial - Decimal("2450.00")
        assert savings_account.balance == savings_initial + Decimal("2450.00")

    def test_transfer_same_account(self, client, auth_headers, checking_account):
        response = client.post(
            "/api/ledger/transactions/transfer",
            data={
                "amount": "100.00",
                "from_account_id": checking_account.id,
                "to_account_id": checking_account.id,
                "date": "2023-10-24",
            },
            content_type="application/json",
            **auth_headers,
        )
        assert response.status_code == 400


# ── Transaction: List / Detail / Delete ──────────────────────────────────────

@pytest.mark.django_db
class TestTransactionListDetailDelete:
    def _create_expense(self, client, auth_headers, account, category):
        client.post(
            "/api/ledger/transactions/expense",
            data={"amount": "25.00", "account_id": account.id, "category_id": category.id, "date": "2023-10-24"},
            content_type="application/json",
            **auth_headers,
        )

    def test_list_transactions(self, client, auth_headers, checking_account, expense_category):
        self._create_expense(client, auth_headers, checking_account, expense_category)
        self._create_expense(client, auth_headers, checking_account, expense_category)
        response = client.get("/api/ledger/transactions/", **auth_headers)
        assert response.status_code == 200
        assert len(response.json()) == 2

    def test_filter_by_type(self, client, auth_headers, checking_account, expense_category, income_category):
        self._create_expense(client, auth_headers, checking_account, expense_category)
        client.post(
            "/api/ledger/transactions/income",
            data={"amount": "500.00", "account_id": checking_account.id, "category_id": income_category.id, "date": "2023-10-24"},
            content_type="application/json",
            **auth_headers,
        )
        response = client.get("/api/ledger/transactions/?transaction_type=expense", **auth_headers)
        assert all(t["transaction_type"] == "expense" for t in response.json())

    def test_get_transaction_detail(self, client, auth_headers, checking_account, expense_category):
        self._create_expense(client, auth_headers, checking_account, expense_category)
        txn = Transaction.objects.first()
        response = client.get(f"/api/ledger/transactions/{txn.id}", **auth_headers)
        assert response.status_code == 200
        assert response.json()["id"] == txn.id

    def test_delete_reverses_balance(self, client, auth_headers, checking_account, expense_category):
        balance_before = checking_account.balance
        create_response = client.post(
            "/api/ledger/transactions/expense",
            data={"amount": "100.00", "account_id": checking_account.id, "category_id": expense_category.id, "date": "2023-10-24"},
            content_type="application/json",
            **auth_headers,
        )
        txn_id = create_response.json()["id"]

        response = client.delete(f"/api/ledger/transactions/{txn_id}", **auth_headers)
        assert response.status_code == 200

        checking_account.refresh_from_db()
        assert checking_account.balance == balance_before

    def test_delete_not_found(self, client, auth_headers):
        response = client.delete("/api/ledger/transactions/99999", **auth_headers)
        assert response.status_code == 404
