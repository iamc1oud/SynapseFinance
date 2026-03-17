# AI Chat Assistant — Product Requirements Document

**Status:** Proposal
**Date:** 2026-03-16
**Feature:** AI-powered chat assistant with MCP-backed tool calling, interactive components, and conversational memory

---

## 1. Problem Statement

Users currently manage their finances through dedicated screens — adding transactions, checking budgets, reviewing subscriptions. Each action requires navigating to a specific page, filling forms, and tapping through multi-step flows. This creates friction for common tasks like:

- "Log a $12 coffee expense from my checking account"
- "How much did I spend on food this month?"
- "Show me my recurring subscriptions"

The **Assistant tab** (tab 0 in the home page) is already reserved but shows only a placeholder. We need to build a full conversational AI interface that lets users interact with their financial data through natural language, backed by MCP (Model Context Protocol) tool calling against our existing Django API.

---

## 2. Goals

1. **Natural language finance management** — Users can add transactions, query spending, check balances, and manage subscriptions through chat
2. **Interactive confirmation components** — Actions that mutate data (add expense, confirm subscription) render as rich, interactive cards that require explicit user confirmation before executing
3. **Extensible command system** — Built-in `/` commands for common actions, with the ability to add new commands without changing the chat infrastructure
4. **Conversational memory** — LLM retains context within a session and across sessions for personalized responses
5. **Transparent AI reasoning** — Optional thinking/streaming content so users can see what the AI is doing

---

## 3. Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                        Flutter App                            │
│                                                               │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│  │ Chat UI      │  │ Message      │  │ Interactive          │ │
│  │ (Bubbles,    │←→│ Models       │←→│ Components           │ │
│  │  Input Bar)  │  │ (Text, Card, │  │ (TransactionCard,    │ │
│  │              │  │  Thinking)   │  │  SpendingSummary...) │ │
│  └──────┬───────┘  └──────────────┘  └──────────────────────┘ │
│         │                                                     │
│  ┌──────▼───────┐                                             │
│  │ Chat Cubit   │ ← manages messages, streaming, commands     │
│  └──────┬───────┘                                             │
│         │                                                     │
│  ┌──────▼───────────────────────────────────────────────────┐ │
│  │                  AI Service Layer                         │ │
│  │  ┌────────────┐  ┌───────────────┐  ┌─────────────────┐  │ │
│  │  │ LLM Client │  │ Tool Registry │  │ Memory Manager  │  │ │
│  │  │ (API call)  │  │ (MCP tools)   │  │ (local store)   │  │ │
│  │  └─────┬──────┘  └───────┬───────┘  └────────┬────────┘  │ │
│  └────────┼────────────────┼────────────────────┼───────────┘ │
│           │                │                    │             │
└───────────┼────────────────┼────────────────────┼─────────────┘
            │                │                    │
            ▼                ▼                    ▼
     ┌─────────────┐  ┌──────────────┐   ┌──────────────┐
     │ LLM Provider │  │ Django API   │   │ Local SQLite │
     │ (Claude API) │  │ (existing)   │   │ (memory DB)  │
     └─────────────┘  └──────────────┘   └──────────────┘
```

### Key Design Decisions

1. **LLM runs via self-hosted Ollama** — The Flutter app calls a self-hosted Ollama instance (OpenAI-compatible API at `http://<host>:11434/v1`). The LLM decides which tools to call, and the app executes them against our Django backend. No MCP server needed — we define tool schemas in the app and map them to our existing REST API.

2. **Tool execution is local** — When the LLM returns a tool call (e.g., `create_expense`), the Flutter app executes it using the existing Retrofit API clients. This reuses all existing auth, error handling, and data layer code.

3. **Interactive components for mutations** — Any tool call that mutates data (POST/PUT/DELETE) is NOT auto-executed. Instead, it renders as an interactive card in the chat. The user must tap "Confirm" to execute. Read-only queries (GET) execute automatically.

4. **Memory is local-first** — Conversation history and user preferences stored in local SQLite via `drift` (or `sqflite`). Relevant context is injected into the LLM system prompt per request.

---

## 4. Feature Breakdown

### 4.1 Chat UI

**Empty State (Current Placeholder → New Design)**

```
┌─────────────────────────────────────┐
│  ≡   AI Chat Assistant           👤  │
│                                      │
│                                      │
│          🤖 (Bot Avatar)             │
│                                      │
│   How can I help with your           │
│          finances?                   │
│                                      │
│   Type '/' to see available          │
│   commands for budgeting,            │
│   goals, and more.                   │
│                                      │
│  ┌─── BASIC COMMANDS ─────────────┐  │
│  │ 📊 /budget                     │  │
│  │    Set or revise monthly budget│  │
│  │                                │  │
│  │ 🎯 /goal                      │  │
│  │    Create a new savings goal   │  │
│  │                                │  │
│  │ 📋 /bills                     │  │
│  │    Add one-time or recurring   │  │
│  │                                │  │
│  │ 📈 /pf                        │  │
│  │    Portfolio check             │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────┐ ▶   │
│  │ /                          │     │
│  └────────────────────────────┘     │
└──────────────────────────────────────┘
```

**Active Chat State**

```
┌──────────────────────────────────────┐
│  ≡   AI Finance Expert      ↗  •••  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ Check my recent recurring      │  │
│  │ subscriptions.                 │  │
│  └────────────────────────────────┘  │
│                                      │
│  ✨ ANSWER                          │
│                                      │
│  I've analyzed your recent spending  │
│  patterns. I found a recurring       │
│  subscription for Cloud Storage      │
│  at $9.99/mo that started 3 months   │
│  ago.                                │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ 📋 Transaction Extraction      │  │
│  │    FINANCIAL EVENT DETECTED    │  │
│  │                                │  │
│  │  Merchant      Amount          │  │
│  │  Cloud Storage $9.99/mo        │  │
│  │                                │  │
│  │  Category      Frequency       │  │
│  │  Tech Services Monthly         │  │
│  │                                │  │
│  │ [Confirm & Add] [Ignore]       │  │
│  └────────────────────────────────┘  │
│                                      │
│  Would you like me to look for       │
│  other similar recurring charges?    │
│                                      │
│  [Portfolio Review] [Savings Goal]   │
│                                      │
│  ┌─────────────────────────────┐ ↑  │
│  │ + Ask follow-up...          │    │
│  └─────────────────────────────┘    │
│  ⚡ PRO SEARCH ON    5/5 QUERIES    │
└──────────────────────────────────────┘
```

**UI Components:**

| Component | Description |
|-----------|-------------|
| `ChatPage` | Main page replacing `_AssistantTab` |
| `MessageBubble` | User message (right-aligned, dark) and AI message (left-aligned) |
| `ThinkingIndicator` | Animated dots or streaming thinking text while AI processes |
| `CommandOverlay` | Bottom sheet listing available `/` commands when user types `/` |
| `SuggestionChips` | Horizontal scrollable row of quick-action chips below AI responses |
| `ChatInputBar` | Text field with send button, attachment icon, and `/` command trigger |

### 4.2 Message Types

Messages in the chat are polymorphic — each type renders differently:

```dart
sealed class ChatMessage {
  final String id;
  final DateTime timestamp;
}

class UserMessage extends ChatMessage {
  final String text;
}

class AiTextMessage extends ChatMessage {
  final String text;
  final List<String>? suggestions;   // Quick-reply chips
}

class AiThinkingMessage extends ChatMessage {
  final String? thinkingText;        // Streaming thinking content
  final bool isComplete;
}

class AiToolCallMessage extends ChatMessage {
  final String toolName;
  final Map<String, dynamic> arguments;
  final dynamic result;              // null until executed
}

class InteractiveCardMessage extends ChatMessage {
  final InteractiveCardType cardType;
  final Map<String, dynamic> data;
  final CardStatus status;           // pending, confirmed, ignored, expired
}

enum CardStatus { pending, confirmed, ignored, expired }
```

### 4.3 Built-in Commands

Commands are shortcuts that translate into structured prompts for the LLM:

| Command | Description | Maps To |
|---------|-------------|---------|
| `/budget` | Set or revise monthly budget | "Help me set a monthly budget. Show my current spending summary first." |
| `/goal` | Create a new savings goal | "I want to create a new savings goal. Ask me about the target amount and timeline." |
| `/bills` | Add or review recurring bills | "Show my upcoming bills and subscriptions. Highlight any that are due." |
| `/pf` | Portfolio check | "Give me a portfolio overview: net worth, total assets, total liabilities, and account balances." |
| `/spend` | Spending analysis | "Analyze my spending for the current month. Break it down by category." |
| `/add` | Quick add transaction | "I want to add a new transaction. Ask me the details." |

Commands are defined declaratively and can be extended:

```dart
class ChatCommand {
  final String name;
  final String description;
  final IconData icon;
  final String systemPrompt;       // Injected into LLM call
}
```

### 4.4 MCP Tool Definitions

Tools are defined as JSON schemas that map to our existing API clients. The LLM sees these as available functions:

#### Read-Only Tools (Auto-execute)

| Tool Name | Description | API Mapping |
|-----------|-------------|-------------|
| `list_transactions` | Get user's transactions with optional filters (type, account, category, date range) | `GET /api/ledger/transactions/` |
| `get_transaction` | Get a specific transaction by ID | `GET /api/ledger/transactions/{id}` |
| `list_accounts` | Get all user accounts with balances | `GET /api/ledger/accounts/` |
| `list_categories` | Get all categories (expense and income) | `GET /api/ledger/categories/` |
| `list_subscriptions` | Get all recurring subscriptions | `GET /api/subscriptions/` |
| `spending_by_category` | Get spending totals grouped by category | `GET /api/ledger/transactions/spending-by-category` |
| `transactions_by_category` | Get transactions grouped by category | `GET /api/ledger/transactions/by-category` |
| `list_tags` | Get all user-defined tags | `GET /api/ledger/tags/` |
| `get_currency_info` | Get user's currencies and exchange rates | `GET /api/currencies/user` |

#### Mutation Tools (Require User Confirmation via Interactive Card)

| Tool Name | Description | API Mapping | Card Type |
|-----------|-------------|-------------|-----------|
| `create_expense` | Record an expense transaction | `POST /api/ledger/transactions/expense` | TransactionConfirmCard |
| `create_income` | Record an income transaction | `POST /api/ledger/transactions/income` | TransactionConfirmCard |
| `create_transfer` | Transfer between accounts | `POST /api/ledger/transactions/transfer` | TransferConfirmCard |
| `create_subscription` | Add a recurring subscription | `POST /api/subscriptions/` | SubscriptionConfirmCard |
| `delete_transaction` | Delete a transaction | `DELETE /api/ledger/transactions/{id}` | DeleteConfirmCard |

#### Tool Schema Example

```json
{
  "name": "create_expense",
  "description": "Record an expense transaction. Deducts the amount from the specified account.",
  "input_schema": {
    "type": "object",
    "properties": {
      "amount": { "type": "number", "description": "The expense amount" },
      "account_id": { "type": "integer", "description": "The account to deduct from" },
      "category_id": { "type": "integer", "description": "The expense category" },
      "note": { "type": "string", "description": "Optional description" },
      "date": { "type": "string", "format": "date", "description": "Transaction date (YYYY-MM-DD), defaults to today" },
      "currency": { "type": "string", "description": "Currency code (e.g., USD, EUR). Defaults to account currency" },
      "tag_ids": { "type": "array", "items": { "type": "integer" }, "description": "Optional tag IDs" }
    },
    "required": ["amount", "account_id", "category_id"]
  }
}
```

### 4.5 Interactive Confirmation Cards

When the LLM calls a mutation tool, instead of executing immediately, the app renders an interactive card:

**Transaction Confirm Card:**
```
┌────────────────────────────────────────┐
│ 📋 New Expense                Pending  │
│    TRANSACTION PREVIEW                 │
│                                        │
│  Amount         Account                │
│  $12.00         Checking               │
│                                        │
│  Category       Date                   │
│  Food & Drink   Today                  │
│                                        │
│  Note: Morning coffee at Starbucks     │
│                                        │
│ [🟠 Confirm & Add]    [Cancel]         │
└────────────────────────────────────────┘
```

**Card Lifecycle:**

1. **Pending** — Card is shown with Confirm/Cancel buttons. User can edit fields inline.
2. **Confirmed** — User taps Confirm. API call is made. Card updates to show success state (checkmark, green border). Buttons are replaced with "Added successfully" text.
3. **Cancelled/Ignored** — User taps Cancel. Card grays out. No API call.
4. **Expired** — If a new conversation starts or session times out, pending cards expire.

**Post-confirmation update:**
```dart
// After confirm, the card message updates:
InteractiveCardMessage(
  cardType: InteractiveCardType.transactionConfirm,
  data: { ... },
  status: CardStatus.confirmed,  // was: pending
)
```

This prevents duplicate submissions — the confirm button is only active when `status == pending`.

### 4.6 Conversation Memory

**Two levels of memory:**

#### Session Memory (Short-term)
- Full conversation history within the current chat session
- Sent to LLM as message history for context continuity
- Cleared when user starts a "New Chat"
- Stored in-memory (Cubit state)

#### Persistent Memory (Long-term)
- Key facts the LLM learns about the user across sessions
- Examples: "User's primary account is Checking", "User categorizes Uber rides as Transport", "User prefers INR"
- Stored in local SQLite database
- Injected into the system prompt on each LLM call

**Memory Schema (SQLite):**

```sql
CREATE TABLE chat_sessions (
  id TEXT PRIMARY KEY,
  title TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE TABLE chat_messages (
  id TEXT PRIMARY KEY,
  session_id TEXT REFERENCES chat_sessions(id),
  role TEXT,          -- 'user', 'assistant', 'tool_call', 'tool_result'
  content TEXT,       -- JSON for structured messages
  message_type TEXT,  -- 'text', 'thinking', 'tool_call', 'interactive_card'
  timestamp TIMESTAMP,
  metadata TEXT       -- JSON: tool name, card status, etc.
);

CREATE TABLE user_memory (
  id TEXT PRIMARY KEY,
  key TEXT UNIQUE,     -- e.g., 'preferred_account', 'default_currency'
  value TEXT,
  source TEXT,         -- 'inferred' or 'explicit'
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

**System Prompt with Memory Context:**
```
You are an AI finance assistant for Synapse Finance. You help users manage
their money through natural language.

User context:
- Primary currency: INR
- Accounts: Checking ($5,240), Savings ($12,800), Credit Card (-$430)
- Preferred expense account: Checking
- Common categories: Food & Drink, Transport, Tech Services

Available tools: [... tool schemas ...]

Rules:
- For mutations (expenses, income, transfers), ALWAYS use the tool call —
  never just describe the action in text.
- Ask for missing required fields before calling a mutation tool.
- For queries, call the appropriate read tool and summarize the results
  in a user-friendly way.
- Amounts should respect the user's primary currency unless specified.
```

### 4.7 Thinking/Streaming Content

When the user enables "Show AI Thinking" (toggle in chat settings):

1. The LLM response streams in with `thinking` blocks visible
2. Displayed as a collapsible section above the answer:

```
┌────────────────────────────────────────┐
│ 🧠 Thinking...                    ▼   │
│                                        │
│ The user wants to know coffee          │
│ spending. I need to:                   │
│ 1. Call spending_by_category for       │
│    current month                       │
│ 2. Filter for "Food & Drink" or       │
│    "Coffee" category                   │
│ 3. Summarize the total                 │
│                                        │
│ Let me call list_transactions with     │
│ category filter...                     │
└────────────────────────────────────────┘
```

3. After response completes, thinking section auto-collapses to one line: "🧠 Thought for 3 seconds"

---

## 5. Backend Changes

### 5.1 No MCP Server Required (Phase 1)

The Flutter app defines tool schemas locally and maps tool calls to existing REST API endpoints. No backend changes needed for core chat functionality — we reuse the existing API.

### 5.2 New Endpoint: Chat Context (Phase 2 — Optional)

If we want server-side memory or analytics:

```
GET /api/assistant/context
```

Returns user's financial summary for LLM context injection:
```json
{
  "accounts_summary": [...],
  "top_categories_this_month": [...],
  "upcoming_subscriptions": [...],
  "recent_transactions_count": 42
}
```

This reduces multiple API calls to one for building the system prompt.

### 5.3 New Endpoint: Natural Language Query (Phase 3 — Optional)

```
POST /api/assistant/query
```

For complex financial queries that benefit from server-side SQL:
```json
{
  "query": "How much did I spend on coffee in the last 3 months compared to the previous 3 months?"
}
```

Server translates to optimized SQL, returns structured data. This avoids sending raw transaction data to the LLM for aggregation.

---

## 6. Frontend Changes

### 6.1 New Feature Module

```
lib/features/assistant/
├── data/
│   ├── datasources/
│   │   ├── ai_service.dart              # LLM API client (Claude)
│   │   └── chat_local_datasource.dart   # SQLite for messages & memory
│   ├── models/
│   │   ├── chat_message_model.dart      # Serializable message models
│   │   └── user_memory_model.dart       # Persistent memory model
│   └── repositories/
│       └── chat_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── chat_message.dart            # Sealed class hierarchy
│   │   ├── chat_session.dart
│   │   └── user_memory.dart
│   ├── repositories/
│   │   └── chat_repository.dart
│   └── usecases/
│       ├── send_message_usecase.dart
│       ├── load_session_usecase.dart
│       └── manage_memory_usecase.dart
├── presentation/
│   ├── bloc/
│   │   ├── chat_cubit.dart              # Main chat state management
│   │   └── chat_state.dart
│   ├── pages/
│   │   └── chat_page.dart               # Replaces _AssistantTab
│   └── widgets/
│       ├── message_bubble.dart
│       ├── thinking_indicator.dart
│       ├── command_overlay.dart
│       ├── suggestion_chips.dart
│       ├── chat_input_bar.dart
│       └── interactive_cards/
│           ├── transaction_confirm_card.dart
│           ├── transfer_confirm_card.dart
│           ├── subscription_confirm_card.dart
│           ├── spending_summary_card.dart
│           └── delete_confirm_card.dart
└── tools/
    ├── tool_registry.dart               # Maps tool names → executors
    ├── tool_schemas.dart                # JSON tool definitions for LLM
    ├── tool_executor.dart               # Executes tools via API clients
    └── tools/
        ├── transaction_tools.dart       # create_expense, create_income, etc.
        ├── account_tools.dart           # list_accounts
        ├── category_tools.dart          # list_categories
        ├── subscription_tools.dart      # list_subscriptions
        └── query_tools.dart             # spending_by_category, etc.
```

### 6.2 New Dependencies

```yaml
# pubspec.yaml additions
dependencies:
  drift: ^2.x.x                # SQLite for chat history & memory
  sqlite3_flutter_libs: ^0.5.x # SQLite native bindings
  flutter_markdown: ^0.x.x     # Render markdown in AI responses
  uuid: ^4.x.x                 # Generate message IDs
  # No LLM SDK needed — we use Dio directly against Ollama's OpenAI-compatible API
```

### 6.3 AI Service Layer (Ollama — OpenAI-compatible API)

The AI Service uses Dio to call Ollama's OpenAI-compatible endpoint. Ollama supports tool/function calling via the same format as OpenAI.

```dart
// ai_service.dart — Core LLM integration via Ollama

class AiService {
  final Dio _dio;
  final ToolRegistry _toolRegistry;
  final MemoryManager _memoryManager;

  // Ollama base URL — configurable in settings
  String _baseUrl = 'http://localhost:11434/v1';
  String _model = 'qwen2.5:14b';  // or llama3.1, mistral, etc.

  AiService(this._toolRegistry, this._memoryManager)
    : _dio = Dio();

  void configure({required String baseUrl, String? model}) {
    _baseUrl = baseUrl;
    if (model != null) _model = model;
  }

  /// Send a message and get a streamed response
  Stream<AiResponseChunk> sendMessage({
    required String userMessage,
    required List<ChatMessage> history,
    List<ChatCommand>? activeCommands,
  }) async* {
    final systemPrompt = await _buildSystemPrompt();
    final tools = _toolRegistry.getOpenAIToolSchemas();
    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ..._buildMessageHistory(history),
      {'role': 'user', 'content': userMessage},
    ];

    final body = {
      'model': _model,
      'messages': messages,
      'tools': tools,
      'stream': true,
    };

    final response = await _dio.post(
      '$_baseUrl/chat/completions',
      data: body,
      options: Options(responseType: ResponseType.stream),
    );

    // Parse SSE stream (OpenAI format)
    await for (final chunk in _parseSSEStream(response)) {
      yield chunk;
    }
  }
}
```

**Key difference from Claude API:** Ollama uses OpenAI-compatible format:
- Tools use `{"type": "function", "function": {"name": ..., "parameters": ...}}` format
- Streaming uses SSE with `data: {"choices": [{"delta": {...}}]}` format
- Tool results are sent as `{"role": "tool", "tool_call_id": ..., "content": ...}`
- System prompt is a message with `role: "system"` (not a separate field)

```dart
// In ToolRegistry, add OpenAI format conversion:
List<Map<String, dynamic>> getOpenAIToolSchemas() =>
    _tools.values.map((t) => {
      'type': 'function',
      'function': {
        'name': t.name,
        'description': t.description,
        'parameters': t.inputSchema,
      },
    }).toList();
```

### 6.4 Tool Registry & Executor

```dart
// tool_registry.dart

class ToolRegistry {
  final Map<String, ToolDefinition> _tools = {};

  void register(ToolDefinition tool) => _tools[tool.name] = tool;

  List<Map<String, dynamic>> getToolSchemas() =>
      _tools.values.map((t) => t.toSchema()).toList();

  bool isMutation(String toolName) =>
      _tools[toolName]?.isMutation ?? false;
}

// tool_executor.dart

class ToolExecutor {
  final LedgerApiClient _ledgerApi;
  final SubscriptionApiClient _subscriptionApi;
  final CurrencyApiClient _currencyApi;

  Future<dynamic> execute(String toolName, Map<String, dynamic> args) async {
    return switch (toolName) {
      'list_transactions'       => _ledgerApi.getTransactions(...),
      'create_expense'          => _ledgerApi.createExpense(...),
      'list_accounts'           => _ledgerApi.getAccounts(),
      'spending_by_category'    => _ledgerApi.getSpendingByCategory(...),
      'list_subscriptions'      => _subscriptionApi.getSubscriptions(),
      _ => throw UnknownToolException(toolName),
    };
  }
}
```

### 6.5 Chat Cubit Flow

```dart
// Simplified flow for sendMessage:

Future<void> sendMessage(String text) async {
  // 1. Add user message to state
  emit(state.addMessage(UserMessage(text: text)));

  // 2. Show thinking indicator
  emit(state.copyWith(isThinking: true));

  // 3. Stream LLM response
  await for (final chunk in _aiService.sendMessage(
    userMessage: text,
    history: state.messages,
  )) {
    switch (chunk) {
      case AiThinkingChunk(:final text):
        emit(state.updateThinking(text));

      case AiTextChunk(:final text):
        emit(state.appendAiText(text));

      case AiToolCallChunk(:final toolName, :final arguments):
        if (_toolRegistry.isMutation(toolName)) {
          // Render interactive card — don't execute yet
          emit(state.addMessage(InteractiveCardMessage(
            toolName: toolName,
            data: arguments,
            status: CardStatus.pending,
          )));
        } else {
          // Auto-execute read-only tools
          final result = await _toolExecutor.execute(toolName, arguments);
          // Send result back to LLM for summarization
          // (continue the tool-use loop)
        }
    }
  }

  // 4. Persist to local DB
  await _chatRepository.saveMessages(state.messages);

  // 5. Update memory if LLM learned something new
  await _memoryManager.extractAndSave(state.messages);
}

Future<void> confirmCard(String messageId) async {
  final card = state.findMessage(messageId) as InteractiveCardMessage;

  // Execute the mutation
  final result = await _toolExecutor.execute(card.toolName, card.data);

  // Update card status
  emit(state.updateCardStatus(messageId, CardStatus.confirmed));

  // Add success message
  emit(state.addMessage(AiTextMessage(
    text: "Done! ${_describeAction(card.toolName, result)}",
  )));
}
```

### 6.6 Router & DI Updates

```dart
// app_router.dart — No new routes needed; ChatPage replaces _AssistantTab in HomePages tabs

// injection.dart — Register new dependencies
@module
abstract class AssistantModule {
  @lazySingleton
  AiService get aiService;

  @lazySingleton
  ToolRegistry get toolRegistry;

  @lazySingleton
  ToolExecutor get toolExecutor;

  @lazySingleton
  ChatRepository get chatRepository;

  @lazySingleton
  MemoryManager get memoryManager;

  @factory
  ChatCubit get chatCubit;
}
```

### 6.7 Home Page Integration

Replace `_AssistantTab` with the new `ChatPage`:

```dart
// home_page.dart changes:

late final _tabs = [
  BlocProvider(
    create: (_) => getIt<ChatCubit>(),
    child: const ChatPage(),
  ),
  // ... existing tabs unchanged
];
```

---

## 7. Ollama Integration Details

### 7.1 Ollama Setup & Configuration

- Ollama runs on a self-hosted machine (local or remote server)
- Default API: `http://localhost:11434` (Ollama native) or `http://localhost:11434/v1` (OpenAI-compatible)
- No API key required for local Ollama (unless configured with `OLLAMA_API_KEY`)
- Store Ollama base URL in `flutter_secure_storage` or app preferences
- For remote access, expose Ollama via `OLLAMA_HOST=0.0.0.0` and use the server's IP/domain

### 7.2 Model Selection

Recommended models with tool/function calling support:
- **`qwen2.5:14b`** — Best tool calling support, good reasoning (recommended)
- **`llama3.1:8b`** — Lightweight, decent tool calling
- **`mistral:7b`** — Fast responses, function calling support
- **`qwen2.5:7b`** — Smaller Qwen, still good tool calling
- Model is configurable in Settings page
- Pull models via `ollama pull <model>` on the host machine

### 7.3 OpenAI-Compatible API Format

Ollama's `/v1/chat/completions` endpoint follows OpenAI format:

```json
{
  "model": "qwen2.5:14b",
  "messages": [
    {"role": "system", "content": "..."},
    {"role": "user", "content": "..."}
  ],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "list_accounts",
        "description": "...",
        "parameters": { "type": "object", "properties": {} }
      }
    }
  ],
  "stream": true
}
```

Tool call responses come as:
```json
{
  "choices": [{
    "message": {
      "tool_calls": [{
        "id": "call_123",
        "type": "function",
        "function": { "name": "list_accounts", "arguments": "{}" }
      }]
    }
  }]
}
```

Send tool results back as:
```json
{"role": "tool", "tool_call_id": "call_123", "content": "{...json result...}"}
```

### 7.4 Token Management

- Context window depends on model (Qwen2.5 = 128K, Llama3.1 = 128K)
- Self-hosted = no rate limits, but VRAM is the bottleneck
- Keep conversation history within context window limits
- Summarize older messages when approaching the limit
- System prompt + tools + memory ≈ 2-3K tokens baseline

---

## 8. Edge Cases & Considerations

### 8.1 Offline Mode
- Chat requires internet (LLM API call)
- Show "You're offline" message with retry button
- Cached conversation history is still viewable

### 8.2 Tool Call Failures
- If a tool call fails (API error), show error in chat: "I couldn't fetch your transactions. The server returned an error. Please try again."
- Do not retry automatically — let user decide

### 8.3 Ambiguous User Input
- If the LLM can't determine the account/category, it should ask: "Which account should I use? You have Checking ($5,240) and Savings ($12,800)."
- The tool schema has `required` fields that force the LLM to gather all info before calling

### 8.4 Concurrent Card Confirmations
- Each card has a unique ID
- Confirming one card does not affect others
- Cards in `pending` state have active buttons; `confirmed`/`ignored` cards are read-only

### 8.5 Multi-Currency
- The LLM should be aware of the user's primary currency and sub-currencies
- When creating transactions, respect the account's currency
- Include exchange rate info in tool responses

### 8.6 Security
- Self-hosted Ollama means all LLM inference stays on your own infrastructure — no data leaves your network
- Conversation data stored locally on device only
- Tool calls are scoped to the authenticated user's data (backend RLS enforces this)
- If Ollama is exposed remotely, use HTTPS reverse proxy (nginx/caddy) and consider `OLLAMA_API_KEY`

---

## 9. File Change Summary

### New Files

| File | Description |
|------|-------------|
| `features/assistant/data/datasources/ai_service.dart` | Claude API integration with streaming |
| `features/assistant/data/datasources/chat_local_datasource.dart` | SQLite persistence for messages & memory |
| `features/assistant/data/models/chat_message_model.dart` | Serializable message models |
| `features/assistant/data/models/user_memory_model.dart` | Persistent memory model |
| `features/assistant/data/repositories/chat_repository_impl.dart` | Repository implementation |
| `features/assistant/domain/entities/chat_message.dart` | Sealed message class hierarchy |
| `features/assistant/domain/entities/chat_session.dart` | Session entity |
| `features/assistant/domain/entities/user_memory.dart` | Memory entity |
| `features/assistant/domain/repositories/chat_repository.dart` | Repository interface |
| `features/assistant/domain/usecases/send_message_usecase.dart` | Send message use case |
| `features/assistant/domain/usecases/load_session_usecase.dart` | Load chat session |
| `features/assistant/domain/usecases/manage_memory_usecase.dart` | Memory CRUD |
| `features/assistant/presentation/bloc/chat_cubit.dart` | Chat state management |
| `features/assistant/presentation/bloc/chat_state.dart` | Chat state definition |
| `features/assistant/presentation/pages/chat_page.dart` | Main chat page |
| `features/assistant/presentation/widgets/message_bubble.dart` | Message rendering |
| `features/assistant/presentation/widgets/thinking_indicator.dart` | AI thinking animation |
| `features/assistant/presentation/widgets/command_overlay.dart` | `/` command menu |
| `features/assistant/presentation/widgets/suggestion_chips.dart` | Quick-reply chips |
| `features/assistant/presentation/widgets/chat_input_bar.dart` | Input field |
| `features/assistant/presentation/widgets/interactive_cards/transaction_confirm_card.dart` | Expense/income confirm |
| `features/assistant/presentation/widgets/interactive_cards/transfer_confirm_card.dart` | Transfer confirm |
| `features/assistant/presentation/widgets/interactive_cards/spending_summary_card.dart` | Spending display card |
| `features/assistant/presentation/widgets/interactive_cards/delete_confirm_card.dart` | Delete confirm |
| `features/assistant/tools/tool_registry.dart` | Tool registration and schema |
| `features/assistant/tools/tool_schemas.dart` | JSON tool definitions |
| `features/assistant/tools/tool_executor.dart` | Tool execution mapping |
| `features/assistant/tools/tools/transaction_tools.dart` | Transaction tool definitions |
| `features/assistant/tools/tools/account_tools.dart` | Account tool definitions |
| `features/assistant/tools/tools/category_tools.dart` | Category tool definitions |
| `features/assistant/tools/tools/subscription_tools.dart` | Subscription tool definitions |
| `features/assistant/tools/tools/query_tools.dart` | Query tool definitions |

### Modified Files

| File | Change |
|------|--------|
| `pubspec.yaml` | Add drift, flutter_markdown, uuid dependencies |
| `home_page.dart` | Replace `_AssistantTab` with `ChatPage` in BlocProvider |
| `core/di/injection.dart` | Register assistant module dependencies |
| `core/di/injection.config.dart` | Auto-generated after build_runner |

---

## 10. Implementation Phases

### Phase 1: Core Chat (MVP) — ~2 weeks
1. Set up `assistant` feature module structure
2. Implement `ChatPage` UI with message bubbles, input bar
3. Integrate Claude API (direct call from Flutter)
4. Define read-only tool schemas (list_transactions, list_accounts, etc.)
5. Implement `ToolExecutor` mapping to existing API clients
6. Basic tool-use loop: user asks → LLM calls tool → results summarized
7. Replace `_AssistantTab` with `ChatPage`

### Phase 2: Interactive Cards — ~1 week
8. Implement mutation tool schemas (create_expense, create_income, etc.)
9. Build `InteractiveCardMessage` and card widgets
10. Implement confirm/cancel flow with card status updates
11. Post-confirmation state update (prevent re-submission)

### Phase 3: Commands & UX Polish — ~1 week
12. Implement `/` command overlay with command definitions
13. Add suggestion chips after AI responses
14. Add thinking/streaming indicator
15. Markdown rendering in AI responses
16. Empty state with command menu (as in design mockup)

### Phase 4: Memory & Persistence — ~1 week
17. Set up SQLite with drift for chat_sessions, chat_messages, user_memory
18. Persist conversation history
19. Implement memory extraction from conversations
20. Inject memory into system prompt
21. Chat session management (new chat, history list)

### Phase 5: Polish & Optimization — ~1 week
22. Token management and conversation summarization
23. Error handling and offline states
24. Rate limiting UI
25. Settings: API key, model selection, thinking toggle
26. Testing

---

## 11. Future Enhancements (Out of Scope)

- **Voice input** — Speech-to-text for hands-free expense logging
- **Image receipt scanning** — Use vision model to extract transaction data from receipts
- **Proactive insights** — AI sends push notifications: "You've spent 80% of your food budget with 10 days left"
- **Multi-modal responses** — Charts and graphs rendered inline in chat
- **Backend proxy mode** — Route LLM calls through Django for centralized model management and analytics
- **Shared financial assistant** — Multi-user households sharing one assistant context
- **Plugin system** — Third-party tool definitions (bank integrations, investment tracking)
