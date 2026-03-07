from django.conf import settings
from django.db import models

from synapse.constants import CURRENCIES

FREQUENCY_CHOICES = (
    ("weekly", "Weekly"),
    ("monthly", "Monthly"),
    ("yearly", "Yearly"),
    ("custom", "Custom"),
)


class Subscription(models.Model):
    """A recurring transaction definition."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="subscriptions",
    )
    name = models.CharField(max_length=100)
    amount = models.DecimalField(max_digits=15, decimal_places=2)
    currency = models.CharField(
        max_length=3, choices=CURRENCIES, default=settings.DEFAULT_CURRENCY
    )
    frequency = models.CharField(max_length=10, choices=FREQUENCY_CHOICES)
    custom_interval_days = models.PositiveIntegerField(null=True, blank=True)
    category = models.ForeignKey(
        "ledger.Category",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="subscriptions",
    )
    account = models.ForeignKey(
        "ledger.Account",
        on_delete=models.CASCADE,
        related_name="subscriptions",
    )
    start_date = models.DateField()
    end_date = models.DateField(null=True, blank=True)
    next_due_date = models.DateField()
    is_active = models.BooleanField(default=True)
    reminder_enabled = models.BooleanField(default=False)
    reminder_days_before = models.PositiveIntegerField(default=1)
    note = models.TextField(blank=True)
    icon = models.CharField(max_length=50, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "subscriptions"
        ordering = ["next_due_date"]

    def __str__(self):
        return f"{self.name} - {self.amount} ({self.get_frequency_display()})"
