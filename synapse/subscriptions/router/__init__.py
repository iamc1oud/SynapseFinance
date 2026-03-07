from ninja import Router

from .subscription_router import router as subscription_router

router = Router()
router.add_router("/", subscription_router)
