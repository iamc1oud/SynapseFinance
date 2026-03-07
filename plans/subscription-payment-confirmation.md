# Subscription Payment Confirmation & Auto-Record

**Status:** Proposal
**Date:** 2026-03-07
**Feature:** User-confirmed subscription payments that auto-record ledger transactions

---

## 1. Problem Statement

The current subscription system is purely informational. It tracks recurring costs and due dates but has **no integration with the ledger**. When a subscription payment is deducted (e.g. Netflix charges the user's card), there is no way to:

- Know whether the payment actually went through
- Automatically record it as an expense transaction
- Advance the `next_due_date` to the next billing cycle

Auto-recording without user consent would create phantom transactions for payments that may have failed, been refunded, or changed in amount.

---

## 2. Proposed Solution

A **user-confirmed payment flow** where the app prompts the user when a subscription is due, and only records the transaction after explicit confirmation.

### User Flow

```
1. User opens app / Recurring tab
2. Subscriptions with next_due_date <= today show a "Payment Due" indicator
3. User taps the subscription card → bottom sheet appears:
   ┌─────────────────────────────────────┐
   │  Netflix              Due Today     │
   │  $15.99 · Monthly                   │
   │  Account: Checking                  │
   │                                     │
   │  ┌─────────────────────────────┐    │
   │  │  ✓ Confirm Payment          │    │
   │  │  Records expense & advances │    │
   │  │  to next billing date       │    │
   │  └─────────────────────────────┘    │
   │                                     │
   │  ┌─────────────────────────────┐    │
   │  │  ⏭ Skip This Cycle          │    │
   │  │  Advances due date without  │    │
   │  │  recording a transaction    │    │
   │  └─────────────────────────────┘    │
   │                                     │
   │  ┌─────────────────────────────┐    │
   │  │  ✎ Edit Amount & Confirm    │    │
   │  │  For when the charge was    │    │
   │  │  different (price change)   │    │
   │  └─────────────────────────────┘    │
   └─────────────────────────────────────┘
4. On confirm → expense recorded, next_due_date advanced, card updated
5. On skip → only next_due_date advanced, no transaction created
```

---

## 3. Backend Changes

### 3.1 New Endpoint: Confirm Payment

```
POST /subscriptions/{id}/confirm-payment
```

**Request Body:**
```json
{
  "amount_override": null,       // optional: if user edits the amount
  "date_override": null          // optional: defaults to today
}
```

**What it does (atomic):**
1. Validates subscription exists, belongs to user, and is active
2. Creates a `Transaction` record:
   - `transaction_type = "expense"`
   - `amount` = subscription amount (or `amount_override` if provided)
   - `account` = subscription's linked account
   - `category` = subscription's linked category (nullable)
   - `note` = `"Recurring: {subscription.name}"`
   - `date` = `date_override` or `today`
3. Deducts balance from the linked `Account` (same as `create_expense`)
4. Advances `next_due_date` using `compute_next_due_date()`
5. If `end_date` is set and new `next_due_date > end_date`, sets `is_active = False`

**Response:** `200: SubscriptionResponse` (with updated `next_due_date`)

**File:** `synapse/subscriptions/router/subscription_router.py`

### 3.2 New Endpoint: Skip Cycle

```
PATCH /subscriptions/{id}/skip
```

**What it does:**
1. Validates subscription exists, belongs to user, and is active
2. Advances `next_due_date` using `compute_next_due_date()`
3. If `end_date` is set and new `next_due_date > end_date`, sets `is_active = False`
4. No transaction created, no balance change

**Response:** `200: SubscriptionResponse` (with updated `next_due_date`)

**File:** `synapse/subscriptions/router/subscription_router.py`

### 3.3 New Schema

```python
# synapse/subscriptions/schemas.py

class ConfirmPaymentRequest(Schema):
    amount_override: Optional[Decimal] = None
    date_override: Optional[date] = None
```

### 3.4 Updated List Endpoint

The existing `GET /subscriptions/` response already includes `next_due_date` and `is_active`. No schema changes needed — the frontend can compute `isDue` locally by comparing `next_due_date <= today`.

Optionally, add computed fields to `SubscriptionResponse`:

```python
is_due: bool          # next_due_date <= today and is_active
days_until_due: int   # (next_due_date - today).days
```

---

## 4. Frontend Changes

### 4.1 Domain Layer

**New use cases:**
- `confirm_subscription_payment_usecase.dart` — `ConfirmPaymentParams(id, amountOverride?, dateOverride?)` → `Subscription`
- `skip_subscription_cycle_usecase.dart` — `SkipCycleParams(id)` → `Subscription`

**Updated repository interface** (`subscription_repository.dart`):
```dart
Future<Either<Failure, Subscription>> confirmPayment({
  required int id,
  double? amountOverride,
  DateTime? dateOverride,
});
Future<Either<Failure, Subscription>> skipCycle({required int id});
```

### 4.2 Data Layer

**Updated API client** (`subscription_api_client.dart`):
```dart
Future<SubscriptionModel> confirmPayment(int id, {double? amountOverride, String? dateOverride});
Future<SubscriptionModel> skipCycle(int id);
```

### 4.3 Subscription Entity

Add computed getter:
```dart
bool get isDue => isActive && !nextDueDate.isAfter(DateTime.now());
```

### 4.4 Presentation — List Page Updates

**Visual indicator on due cards:**
- Orange/amber "DUE" badge next to the next-due-date text
- Slightly different card border color (amber tint) for due subscriptions
- Sort due subscriptions to the top of the list

**Tap action on due cards:**
- Opens a `DraggableScrollableSheet` bottom sheet with three options:
  1. **Confirm Payment** — calls `confirmPayment`, shows success snackbar
  2. **Skip This Cycle** — calls `skipCycle`, shows info snackbar
  3. **Edit Amount & Confirm** — shows inline amount text field, then confirms

### 4.5 Cubit Changes

**Updated `SubscriptionListCubit`:**
```dart
Future<void> confirmPayment(int id, {double? amountOverride}) async { ... }
Future<void> skipCycle(int id) async { ... }
```

Both methods update the subscription in the local list after the API call succeeds (replacing the old subscription with the returned one that has the new `next_due_date`).

---

## 5. File Change Summary

### New Files
| File | Description |
|------|-------------|
| `frontend/.../domain/usecases/confirm_payment_usecase.dart` | Confirm payment use case |
| `frontend/.../domain/usecases/skip_cycle_usecase.dart` | Skip cycle use case |

### Modified Files — Backend
| File | Change |
|------|--------|
| `synapse/subscriptions/schemas.py` | Add `ConfirmPaymentRequest`, optionally add `is_due`/`days_until_due` to response |
| `synapse/subscriptions/router/subscription_router.py` | Add `confirm-payment` and `skip` endpoints |

### Modified Files — Frontend
| File | Change |
|------|--------|
| `domain/entities/subscription.dart` | Add `isDue` getter |
| `domain/repositories/subscription_repository.dart` | Add `confirmPayment`, `skipCycle` methods |
| `data/datasources/subscription_api_client.dart` | Add API calls |
| `data/repositories/subscription_repository_impl.dart` | Implement new methods |
| `presentation/bloc/subscription_list_cubit.dart` | Add `confirmPayment`, `skipCycle` |
| `presentation/pages/subscription_list_page.dart` | Add due indicator, tap-to-confirm bottom sheet |

---

## 6. Edge Cases & Considerations

### 6.1 Multiple Missed Cycles
If the user hasn't opened the app for 3 months and a monthly subscription is due, `next_due_date` could be far in the past. Options:
- **Current approach:** Single confirm advances to the *next future* date (skips missed ones). This is correct — user probably already paid those via auto-debit.
- **Alternative:** Show how many cycles were missed and let user bulk-confirm. (Future enhancement.)

### 6.2 End Date Handling
When `next_due_date` advances past `end_date`, the subscription should auto-deactivate (`is_active = False`). Both `confirm-payment` and `skip` must check this.

### 6.3 Category Requirement
The `create_expense` endpoint requires a category. For subscriptions without a category, the confirm-payment endpoint should either:
- Create the transaction with `category=None` (Transaction model allows this)
- Or prompt the user to assign a category first

Since `Transaction.category` is nullable (`SET_NULL`), creating without a category is valid.

### 6.4 Concurrent Confirms
If user taps confirm twice quickly, the second call should be a no-op. The backend should check `next_due_date <= today` before processing — if already advanced, return current state without creating a duplicate transaction.

### 6.5 Amount Override
Price changes happen (Netflix raises prices). The "Edit Amount & Confirm" option lets the user record the actual charged amount. This does **not** update the subscription's base `amount` — it only affects the single transaction. The user can separately edit the subscription amount via the existing update endpoint.

---

## 7. Future Enhancements (Out of Scope)

These are not part of this implementation but designed to be compatible:

- **Push notifications** — A background service (Celery/APScheduler) checks subscriptions daily and sends push notifications for due/upcoming payments
- **Auto-confirm mode** — Per-subscription setting to auto-record without prompting (for trusted subscriptions)
- **Payment history** — Link transactions back to subscriptions via a `subscription_id` FK on Transaction (requires migration)
- **Spending insights** — "You spent $X on subscriptions this month" powered by the transaction linkage
- **LLM analysis** — "Your Netflix subscription increased 20% this year, consider downgrading"

---

## 8. Implementation Order

1. Backend: Add `ConfirmPaymentRequest` schema
2. Backend: Add `confirm-payment` endpoint (atomic transaction + advance)
3. Backend: Add `skip` endpoint
4. Frontend: Add `isDue` getter to Subscription entity
5. Frontend: Add use cases, repository methods, API client methods
6. Frontend: Update cubit with `confirmPayment` and `skipCycle`
7. Frontend: Update list page — due indicator + bottom sheet
8. Run `build_runner`, test end-to-end
