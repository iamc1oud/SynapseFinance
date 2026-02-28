from django.conf import settings
from django.db import models

from synapse.constants import CURRENCIES


ACCOUNT_TYPES = (
    ('checking', 'Checking'),
    ('savings', 'Savings'),
    ('credit', 'Credit Card'),
    ('cash', 'Cash'),
    ('investment', 'Investment'),
)

CATEGORY_TYPES = (
    ('expense', 'Expense'),
    ('income', 'Income'),
)

TRANSACTION_TYPES = (
    ('expense', 'Expense'),
    ('income', 'Income'),
    ('transfer', 'Transfer'),
)


class Account(models.Model):
    """Financial account such as Checking, Savings, Credit Card, etc."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='financial_accounts',
    )
    name = models.CharField(max_length=100)
    account_type = models.CharField(max_length=20, choices=ACCOUNT_TYPES)
    balance = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    currency = models.CharField(
        max_length=3, choices=CURRENCIES, default=settings.DEFAULT_CURRENCY,
    )
    icon = models.CharField(max_length=50, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'financial_accounts'

    def __str__(self):
        return f"{self.name} ({self.get_account_type_display()})"


class Category(models.Model):
    """Transaction category such as Food, Transport, Shopping, etc."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='categories',
    )
    name = models.CharField(max_length=50)
    icon = models.CharField(max_length=50, blank=True)
    category_type = models.CharField(
        max_length=10, choices=CATEGORY_TYPES, default='expense',
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'categories'
        verbose_name_plural = 'categories'

    def __str__(self):
        return f"{self.name} ({self.get_category_type_display()})"


class Tag(models.Model):
    """Quick tag for organizing transactions."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='tags',
    )
    name = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'tags'

    def __str__(self):
        return self.name


class Transaction(models.Model):
    """Financial transaction — expense, income, or transfer."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='transactions',
    )
    transaction_type = models.CharField(max_length=10, choices=TRANSACTION_TYPES)
    amount = models.DecimalField(max_digits=15, decimal_places=2)
    category = models.ForeignKey(
        Category,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='transactions',
    )
    account = models.ForeignKey(
        Account,
        on_delete=models.CASCADE,
        related_name='transactions',
    )
    to_account = models.ForeignKey(
        Account,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='incoming_transfers',
    )
    note = models.TextField(blank=True)
    date = models.DateField()
    tags = models.ManyToManyField(Tag, blank=True, related_name='transactions')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'transactions'
        ordering = ['-date', '-created_at']

    def __str__(self):
        return f"{self.get_transaction_type_display()}: {self.amount} on {self.date}"
