# Generated manually

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ("ledger", "0001_initial"),
    ]

    operations = [
        migrations.CreateModel(
            name="Subscription",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("name", models.CharField(max_length=100)),
                ("amount", models.DecimalField(decimal_places=2, max_digits=15)),
                ("currency", models.CharField(default="USD", max_length=3)),
                (
                    "frequency",
                    models.CharField(
                        choices=[
                            ("weekly", "Weekly"),
                            ("monthly", "Monthly"),
                            ("yearly", "Yearly"),
                            ("custom", "Custom"),
                        ],
                        max_length=10,
                    ),
                ),
                (
                    "custom_interval_days",
                    models.PositiveIntegerField(blank=True, null=True),
                ),
                ("start_date", models.DateField()),
                ("end_date", models.DateField(blank=True, null=True)),
                ("next_due_date", models.DateField()),
                ("is_active", models.BooleanField(default=True)),
                ("reminder_enabled", models.BooleanField(default=False)),
                ("reminder_days_before", models.PositiveIntegerField(default=1)),
                ("note", models.TextField(blank=True)),
                ("icon", models.CharField(blank=True, max_length=50)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "user",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="subscriptions",
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
                (
                    "category",
                    models.ForeignKey(
                        blank=True,
                        null=True,
                        on_delete=django.db.models.deletion.SET_NULL,
                        related_name="subscriptions",
                        to="ledger.category",
                    ),
                ),
                (
                    "account",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="subscriptions",
                        to="ledger.account",
                    ),
                ),
            ],
            options={
                "db_table": "subscriptions",
                "ordering": ["next_due_date"],
            },
        ),
    ]
