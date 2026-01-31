
from ninja import NinjaAPI, Swagger

from django.contrib import admin
from django.urls import path, include, re_path
from accounts.router import auth_router

api = NinjaAPI(title="Synapse Manager API", version="1.0", openapi_extra={"info": {"description": "Synapse Manager API"}})

api.add_router("/auth", auth_router.router)

urlpatterns = [
    path("api/", api.urls)
]
