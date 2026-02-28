import pytest
from django.test import Client


@pytest.fixture
def client():
    """Returns a Django test client instance."""
    return Client()


class TestLedgerEndpoint:
    """Test for the /ledger endpoint."""
