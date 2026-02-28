from datetime import date
from typing import Optional

from accounts.auth import JWTAuth
from accounts.schemas import ErrorResponse, MessageResponse
from django.db import transaction
from django.db.models import F, Sum
from ninja import Router

from ..models import Account, Category, Tag, Transaction
from ..schemas import (
    CategorySpendingResponse,
    CategoryTransactionGroupResponse,
    CreateExpenseRequest,
    CreateIncomeRequest,
    CreateTransferRequest,
    TransactionResponse,
)

router = Router(tags=["Transactions"])


@router.post(
    "/expense",
    response={201: TransactionResponse, 400: ErrorResponse},
    auth=JWTAuth(),
    description="Record an expense — deducts amount from the specified account.",
)
def create_expense(request, payload: CreateExpenseRequest):
    user = request.auth

    try:
        account = Account.objects.get(id=payload.account_id, user=user)
    except Account.DoesNotExist:
        return 400, ErrorResponse(detail="Account not found")

    try:
        category = Category.objects.get(
            id=payload.category_id, user=user, category_type='expense',
        )
    except Category.DoesNotExist:
        return 400, ErrorResponse(detail="Expense category not found")

    with transaction.atomic():
        Account.objects.filter(id=account.pk).update(
            balance=F('balance') - payload.amount,
        )
        txn = Transaction.objects.create(
            user=user,
            transaction_type='expense',
            amount=payload.amount,
            account=account,
            category=category,
            note=payload.note,
            date=payload.date,
        )
        if payload.tag_ids:
            tags = Tag.objects.filter(id__in=payload.tag_ids, user=user)
            txn.tags.set(tags)

    txn.refresh_from_db()
    return 201, TransactionResponse.from_transaction(txn)


@router.post(
    "/income",
    response={201: TransactionResponse, 400: ErrorResponse},
    auth=JWTAuth(),
    description="Record income — adds amount to the specified account.",
)
def create_income(request, payload: CreateIncomeRequest):
    user = request.auth

    try:
        account = Account.objects.get(id=payload.account_id, user=user)
    except Account.DoesNotExist:
        return 400, ErrorResponse(detail="Account not found")

    try:
        category = Category.objects.get(
            id=payload.category_id, user=user, category_type='income',
        )
    except Category.DoesNotExist:
        return 400, ErrorResponse(detail="Income category not found")

    with transaction.atomic():
        Account.objects.filter(id=account.pk).update(
            balance=F('balance') + payload.amount,
        )
        txn = Transaction.objects.create(
            user=user,
            transaction_type='income',
            amount=payload.amount,
            account=account,
            category=category,
            note=payload.note,
            date=payload.date,
        )
        if payload.tag_ids:
            tags = Tag.objects.filter(id__in=payload.tag_ids, user=user)
            txn.tags.set(tags)

    txn.refresh_from_db()
    return 201, TransactionResponse.from_transaction(txn)


@router.post(
    "/transfer",
    response={201: TransactionResponse, 400: ErrorResponse},
    auth=JWTAuth(),
    description="Transfer money between two accounts — deducts from source, adds to destination.",
)
def create_transfer(request, payload: CreateTransferRequest):
    user = request.auth

    try:
        from_account = Account.objects.get(id=payload.from_account_id, user=user)
    except Account.DoesNotExist:
        return 400, ErrorResponse(detail="Source account not found")

    try:
        to_account = Account.objects.get(id=payload.to_account_id, user=user)
    except Account.DoesNotExist:
        return 400, ErrorResponse(detail="Destination account not found")

    if from_account.pk == to_account.pk:
        return 400, ErrorResponse(detail="Cannot transfer to the same account")

    with transaction.atomic():
        Account.objects.filter(id=from_account.pk).update(
            balance=F('balance') - payload.amount,
        )
        Account.objects.filter(id=to_account.pk).update(
            balance=F('balance') + payload.amount,
        )
        txn = Transaction.objects.create(
            user=user,
            transaction_type='transfer',
            amount=payload.amount,
            account=from_account,
            to_account=to_account,
            note=payload.note,
            date=payload.date,
        )
        if payload.tag_ids:
            tags = Tag.objects.filter(id__in=payload.tag_ids, user=user)
            txn.tags.set(tags)

    txn.refresh_from_db()
    return 201, TransactionResponse.from_transaction(txn)


@router.get(
    "/",
    response={200: list[TransactionResponse]},
    auth=JWTAuth(),
    description=(
        "List transactions for the current user. "
        "Filter by transaction_type (expense/income/transfer), "
        "account_id, category_id, or date range (date_from, date_to)."
    ),
)
def list_transactions(
    request,
    transaction_type: Optional[str] = None,
    account_id: Optional[int] = None,
    category_id: Optional[int] = None,
    date_from: Optional[date] = None,
    date_to: Optional[date] = None,
):
    qs = Transaction.objects.filter(user=request.auth).select_related(
        'account', 'to_account', 'category',
    ).prefetch_related('tags')

    if transaction_type:
        qs = qs.filter(transaction_type=transaction_type)
    if account_id:
        qs = qs.filter(account_id=account_id)
    if category_id:
        qs = qs.filter(category_id=category_id)
    if date_from:
        qs = qs.filter(date__gte=date_from)
    if date_to:
        qs = qs.filter(date__lte=date_to)

    return 200, [TransactionResponse.from_transaction(t) for t in qs]


@router.get(
    "/spending-by-category",
    response={200: list[CategorySpendingResponse]},
    auth=JWTAuth(),
    description=(
        "Return total expense spending grouped by category, ordered highest to lowest. "
        "Optionally filter by date range (date_from, date_to). "
        "Only includes expense transactions."
    ),
)
def spending_by_category(
    request,
    date_from: Optional[date] = None,
    date_to: Optional[date] = None,
):
    qs = Transaction.objects.filter(
        user=request.auth,
        transaction_type='expense',
    ).select_related('category')

    if date_from:
        qs = qs.filter(date__gte=date_from)
    if date_to:
        qs = qs.filter(date__lte=date_to)

    rows = (
        qs.values('category__id', 'category__name', 'category__icon')
        .annotate(total=Sum('amount'))
        .order_by('-total')
    )

    return 200, [
        CategorySpendingResponse(
            category_id=r['category__id'],
            category_name=r['category__name'],
            category_icon=r['category__icon'] or '',
            total=r['total'],
        )
        for r in rows
        if r['category__id'] is not None
    ]


@router.get(
    "/by-category",
    response={200: list[CategoryTransactionGroupResponse]},
    auth=JWTAuth(),
    description=(
        "Return expense transactions grouped by category. "
        "Each group contains the category name, icon, total amount, and all matching transactions. "
        "Optionally filter by date range (date_from, date_to). "
        "Groups are ordered by total spending descending."
    ),
)
def transactions_by_category(
    request,
    date_from: Optional[date] = None,
    date_to: Optional[date] = None,
):
    from collections import defaultdict

    qs = Transaction.objects.filter(
        user=request.auth,
        transaction_type='expense',
    ).select_related('account', 'to_account', 'category').prefetch_related('tags')

    if date_from:
        qs = qs.filter(date__gte=date_from)
    if date_to:
        qs = qs.filter(date__lte=date_to)

    groups: dict = defaultdict(lambda: {'category': None, 'total': 0, 'transactions': []})

    for txn in qs.order_by('-date', '-created_at'):
        if txn.category is None:
            continue
        cid = txn.category.id
        groups[cid]['category'] = txn.category
        groups[cid]['total'] += txn.amount
        groups[cid]['transactions'].append(txn)

    sorted_groups = sorted(groups.values(), key=lambda g: g['total'], reverse=True)

    return 200, [
        CategoryTransactionGroupResponse(
            category_id=g['category'].id,
            category_name=g['category'].name,
            category_icon=g['category'].icon or '',
            total=g['total'],
            transactions=[TransactionResponse.from_transaction(t) for t in g['transactions']],
        )
        for g in sorted_groups
    ]


@router.get(
    "/{transaction_id}",
    response={200: TransactionResponse, 404: ErrorResponse},
    auth=JWTAuth(),
    description="Get details of a specific transaction.",
)
def get_transaction(request, transaction_id: int):
    try:
        txn = Transaction.objects.select_related(
            'account', 'to_account', 'category',
        ).prefetch_related('tags').get(id=transaction_id, user=request.auth)
    except Transaction.DoesNotExist:
        return 404, ErrorResponse(detail="Transaction not found")
    return 200, TransactionResponse.from_transaction(txn)


@router.delete(
    "/{transaction_id}",
    response={200: MessageResponse, 404: ErrorResponse},
    auth=JWTAuth(),
    description="Delete a transaction and reverse its effect on account balances.",
)
def delete_transaction(request, transaction_id: int):
    try:
        txn = Transaction.objects.get(id=transaction_id, user=request.auth)
    except Transaction.DoesNotExist:
        return 404, ErrorResponse(detail="Transaction not found")

    with transaction.atomic():
        # Reverse balance changes
        if txn.transaction_type == 'expense':
            Account.objects.filter(id=txn.account.pk).update(
                balance=F('balance') + txn.amount,
            )
        elif txn.transaction_type == 'income':
            Account.objects.filter(id=txn.account.pk).update(
                balance=F('balance') - txn.amount,
            )
        elif txn.transaction_type == 'transfer':
            Account.objects.filter(id=txn.account.pk).update(
                balance=F('balance') + txn.amount,
            )
            if txn.to_account.pk:
                Account.objects.filter(id=txn.to_account.pk).update(
                    balance=F('balance') - txn.amount,
                )
        txn.delete()

    return 200, MessageResponse(message="Transaction deleted")
