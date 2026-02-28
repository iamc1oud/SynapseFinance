class TestLedgerModel:
    """Test for the Ledger model."""

    def test_ledger_str(self, ledger):
        """Test user string representation."""
        assert str(ledger) == ""
