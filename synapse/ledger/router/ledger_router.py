from ninja import Router

router = Router(tags=["Ledger API"])

@router.get("", description="Retrieve ledger data")
def get_ledger(request):
    return {"message": "Ledger data"}
