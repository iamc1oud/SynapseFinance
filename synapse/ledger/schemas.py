from datetime import date
from decimal import Decimal
from typing import Optional

from ninja import Schema


# ── Account Schemas ──────────────────────────────────────────────────────────

class CreateAccountRequest(Schema):
    """Create a new financial account (e.g. Checking, Savings)."""
    name: str
    account_type: str  # checking, savings, credit, cash, investment
    balance: Decimal = Decimal("0.00")
    currency: str = "USD"
    icon: str = ""


class AccountResponse(Schema):
    id: int
    name: str
    account_type: str
    balance: Decimal
    currency: str
    icon: str
    is_active: bool

    @staticmethod
    def from_account(account):
        return AccountResponse(
            id=account.id,
            name=account.name,
            account_type=account.account_type,
            balance=account.balance,
            currency=account.currency,
            icon=account.icon,
            is_active=account.is_active,
        )


# ── Category Schemas ─────────────────────────────────────────────────────────

class CreateCategoryRequest(Schema):
    """Create a new transaction category (e.g. Food, Transport)."""
    name: str
    icon: str = ""
    category_type: str = "expense"  # expense or income


class CategoryResponse(Schema):
    id: int
    name: str
    icon: str
    category_type: str

    @staticmethod
    def from_category(category):
        return CategoryResponse(
            id=category.id,
            name=category.name,
            icon=category.icon,
            category_type=category.category_type,
        )


# ── Tag Schemas ──────────────────────────────────────────────────────────────

class CreateTagRequest(Schema):
    """Create a quick tag for organizing transactions."""
    name: str


class TagResponse(Schema):
    id: int
    name: str

    @staticmethod
    def from_tag(tag):
        return TagResponse(id=tag.id, name=tag.name)


# ── Transaction Schemas ──────────────────────────────────────────────────────

class CreateExpenseRequest(Schema):
    """Record an expense — money spent from an account."""
    amount: Decimal
    account_id: int
    category_id: int
    date: date
    note: str = ""
    tag_ids: list[int] = []


class CreateIncomeRequest(Schema):
    """Record income — money received into an account."""
    amount: Decimal
    account_id: int
    category_id: int
    date: date
    note: str = ""
    tag_ids: list[int] = []


class CreateTransferRequest(Schema):
    """Transfer money between two accounts."""
    amount: Decimal
    from_account_id: int
    to_account_id: int
    date: date
    note: str = ""
    tag_ids: list[int] = []


class TransactionResponse(Schema):
    id: int
    transaction_type: str
    amount: Decimal
    account: AccountResponse
    to_account: Optional[AccountResponse] = None
    category: Optional[CategoryResponse] = None
    note: str
    date: date
    tags: list[TagResponse] = []
    created_at: str

    @staticmethod
    def from_transaction(txn):
        return TransactionResponse(
            id=txn.id,
            transaction_type=txn.transaction_type,
            amount=txn.amount,
            account=AccountResponse.from_account(txn.account),
            to_account=(
                AccountResponse.from_account(txn.to_account)
                if txn.to_account else None
            ),
            category=(
                CategoryResponse.from_category(txn.category)
                if txn.category else None
            ),
            note=txn.note,
            date=txn.date,
            tags=[TagResponse.from_tag(t) for t in txn.tags.all()],
            created_at=txn.created_at.isoformat(),
        )
