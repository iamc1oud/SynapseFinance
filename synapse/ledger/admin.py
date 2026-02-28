from django.contrib import admin

from .models import Account, Category, Tag, Transaction


@admin.register(Account)
class AccountAdmin(admin.ModelAdmin):
    list_display = ('name', 'account_type', 'balance', 'currency', 'user', 'is_active')
    list_filter = ('account_type', 'currency', 'is_active')
    search_fields = ('name', 'user__email')


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'category_type', 'icon', 'user')
    list_filter = ('category_type',)
    search_fields = ('name', 'user__email')


@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    list_display = ('name', 'user', 'created_at')
    search_fields = ('name', 'user__email')


@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('transaction_type', 'amount', 'account', 'category', 'date', 'user')
    list_filter = ('transaction_type', 'date')
    search_fields = ('note', 'user__email')
    raw_id_fields = ('account', 'to_account', 'category')
