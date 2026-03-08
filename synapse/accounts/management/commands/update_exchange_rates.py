from django.core.management.base import BaseCommand

from accounts.exchange_service import fetch_and_update_rates


class Command(BaseCommand):
    help = "Fetch latest exchange rates from fawazahmed0/exchange-api and update the database."

    def handle(self, *args, **options):
        self.stdout.write("Fetching exchange rates...")
        count = fetch_and_update_rates()
        self.stdout.write(self.style.SUCCESS(f"Updated {count} exchange rate pairs."))
