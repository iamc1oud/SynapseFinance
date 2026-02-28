import pytest
from decimal import Decimal

from ledger.models import Account, Category, Tag, Transaction


@pytest.mark.django_db
class TestAccountModel:
    def test_create_account(self, user):
        account = Account.objects.create(
            user=user,
            name="Checking",
            account_type="checking",
            balance=Decimal("1000.00"),
            currency="USD",
        )
        assert account.id is not None
        assert str(account) == "Checking (Checking)"

    def test_account_default_balance(self, user):
        account = Account.objects.create(
            user=user, name="Empty", account_type="cash",
        )
        assert account.balance == Decimal("0")

    def test_account_is_active_default(self, user):
        account = Account.objects.create(
            user=user, name="Active", account_type="savings",
        )
        assert account.is_active is True


@pytest.mark.django_db
class TestCategoryModel:
    def test_create_expense_category(self, user):
        cat = Category.objects.create(
            user=user, name="Food", icon="food", category_type="expense",
        )
        assert cat.id is not None
        assert str(cat) == "Food (Expense)"

    def test_create_income_category(self, user):
        cat = Category.objects.create(
            user=user, name="Salary", category_type="income",
        )
        assert cat.get_category_type_display() == "Income"


@pytest.mark.django_db
class TestTagModel:
    def test_create_tag(self, user):
        tag = Tag.objects.create(user=user, name="Emergency")
        assert tag.id is not None
        assert str(tag) == "Emergency"


@pytest.mark.django_db
class TestTransactionModel:
    def test_expense_str(self, checking_account, expense_category, user):
        from datetime import date
        txn = Transaction.objects.create(
            user=user,
            transaction_type="expense",
            amount=Decimal("50.00"),
            account=checking_account,
            category=expense_category,
            date=date(2023, 10, 24),
        )
        assert "Expense" in str(txn)
        assert "50.00" in str(txn)

    def test_transfer_has_to_account(self, checking_account, savings_account, user):
        from datetime import date
        txn = Transaction.objects.create(
            user=user,
            transaction_type="transfer",
            amount=Decimal("500.00"),
            account=checking_account,
            to_account=savings_account,
            date=date(2023, 10, 24),
        )
        assert txn.to_account == savings_account

    def test_ordering_by_date_desc(self, checking_account, expense_category, user):
        from datetime import date
        Transaction.objects.create(
            user=user, transaction_type="expense", amount=10,
            account=checking_account, category=expense_category,
            date=date(2023, 10, 1),
        )
        Transaction.objects.create(
            user=user, transaction_type="expense", amount=20,
            account=checking_account, category=expense_category,
            date=date(2023, 10, 24),
        )
        txns = list(Transaction.objects.filter(user=user))
        assert txns[0].amount == 20
        assert txns[1].amount == 10
