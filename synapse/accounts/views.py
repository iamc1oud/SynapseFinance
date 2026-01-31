from django.shortcuts import render
from django.http import JsonResponse
from functools import wraps

def internal_only(view_func):
    @wraps(view_func)
    def wrapper(request, *args, **kwargs):
        if request.headers.get("X-INTERNAL-TOKEN") != "secret":
            return JsonResponse({"error": "Unauthorized"}, status=401)
        return view_func(request, *args, **kwargs)
    return wrapper

@internal_only
def sample_view(request):
    """A sample view endpoint that returns a JSON response."""
    return JsonResponse({"message": "Hello from accounts!", "status": "ok"})
