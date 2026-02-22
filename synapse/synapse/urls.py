
from ninja import NinjaAPI, Swagger

from django.contrib import admin
from django.urls import path, include, re_path

# Routers
from accounts.router import auth_router
from ledger.router import ledger_router

api = NinjaAPI(title="Synapse Manager API", version="1.0", openapi_extra={"info": {"description": "Synapse Manager API"}})

api.add_router("/auth", auth_router.router)
api.add_router("/ledger", ledger_router.router)

urlpatterns = [
    path("api/", api.urls)
]
