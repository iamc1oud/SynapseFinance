
from ninja import NinjaAPI, Swagger

from django.contrib import admin
from django.urls import path, include, re_path
from accounts.router import router as accounts_router

api = NinjaAPI(title="Synapse Manager API", version="1.0", openapi_extra={"info": {"description": "Synapse Manager API"}})

api.add_router("/auth", accounts_router)

urlpatterns = [
    path("api/", api.urls)
]
