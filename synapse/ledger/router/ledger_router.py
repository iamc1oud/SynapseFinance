from ninja import Router

from .account_router import router as account_router
from .category_router import router as category_router
from .tag_router import router as tag_router
from .transaction_router import router as transaction_router

router = Router()

router.add_router("/accounts", account_router)
router.add_router("/categories", category_router)
router.add_router("/tags", tag_router)
router.add_router("/transactions", transaction_router)
