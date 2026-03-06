from typing import Optional

from accounts.auth import JWTAuth
from ninja import Router

from accounts.schemas import ErrorResponse

from ..models import Category
from ..schemas import CategoryResponse, CreateCategoryRequest

router = Router(tags=["Categories"])


@router.post(
    "",
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
    "",
    response={200: list[CategoryResponse]},
    auth=JWTAuth(),
    description="List transaction categories. Optionally filter by type and archived status.",
)
def list_categories(
    request,
    category_type: Optional[str] = None,
    is_archived: Optional[bool] = None,
):
    qs = Category.objects.filter(user=request.auth)
    if category_type:
        qs = qs.filter(category_type=category_type)
    if is_archived is not None:
        qs = qs.filter(is_archived=is_archived)
    return 200, [CategoryResponse.from_category(c) for c in qs]


@router.patch(
    "/{category_id}/archive",
    response={200: CategoryResponse, 404: ErrorResponse},
    auth=JWTAuth(),
    description="Archive a category. Archived categories are hidden from active lists.",
)
def archive_category(request, category_id: int):
    try:
        category = Category.objects.get(id=category_id, user=request.auth)
    except Category.DoesNotExist:
        return 404, {"detail": "Category not found."}
    category.is_archived = True
    category.save(update_fields=["is_archived"])
    return 200, CategoryResponse.from_category(category)


@router.patch(
    "/{category_id}/restore",
    response={200: CategoryResponse, 404: ErrorResponse},
    auth=JWTAuth(),
    description="Restore an archived category back to active.",
)
def restore_category(request, category_id: int):
    try:
        category = Category.objects.get(id=category_id, user=request.auth)
    except Category.DoesNotExist:
        return 404, {"detail": "Category not found."}
    category.is_archived = False
    category.save(update_fields=["is_archived"])
    return 200, CategoryResponse.from_category(category)
