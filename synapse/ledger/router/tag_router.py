from accounts.auth import JWTAuth
from ninja import Router

from ..models import Tag
from ..schemas import CreateTagRequest, TagResponse

router = Router(tags=["Tags"])


@router.post(
    "/",
    response={201: TagResponse},
    auth=JWTAuth(),
    description="Create a quick tag for organizing transactions (e.g. Rent, Savings, Emergency).",
)
def create_tag(request, payload: CreateTagRequest):
    tag = Tag.objects.create(user=request.auth, name=payload.name)
    return 201, TagResponse.from_tag(tag)


@router.get(
    "/",
    response={200: list[TagResponse]},
    auth=JWTAuth(),
    description="List all tags for the current user.",
)
def list_tags(request):
    tags = Tag.objects.filter(user=request.auth)
    return 200, [TagResponse.from_tag(t) for t in tags]
