from typing import Optional

from accounts.auth import JWTAuth
from ninja import Router

from ..models import Category
from ..schemas import CategoryResponse, CreateCategoryRequest

router = Router(tags=["Categories"])


@router.post(
    "/",
    response={201: CategoryResponse},
    auth=JWTAuth(),
    description="Create a new transaction category (e.g. Food, Transport, Salary).",
)
def create_category(request, payload: CreateCategoryRequest):
    category = Category.objects.create(
        user=request.auth,
        name=payload.name,
        icon=payload.icon,
        category_type=payload.category_type,
    )
    return 201, CategoryResponse.from_category(category)


@router.get(
    "/",
    response={200: list[CategoryResponse]},
    auth=JWTAuth(),
    description="List transaction categories. Optionally filter by type: 'expense' or 'income'.",
)
def list_categories(request, category_type: Optional[str] = None):
    qs = Category.objects.filter(user=request.auth)
    if category_type:
        qs = qs.filter(category_type=category_type)
    return 200, [CategoryResponse.from_category(c) for c in qs]
