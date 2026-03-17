#!/usr/bin/env python3
"""Generate the AI Chat Assistant implementation guide PDF — Ollama edition."""

from fpdf import FPDF
import textwrap

class GuideDocument(FPDF):
    def __init__(self):
        super().__init__()
        self.set_auto_page_break(auto=True, margin=20)
        self.PRIMARY = (22, 163, 74)
        self.DARK = (15, 23, 42)
        self.GRAY = (100, 116, 139)
        self.LIGHT_BG = (241, 245, 249)
        self.ORANGE = (234, 88, 12)
        self.BLUE = (37, 99, 235)
        self.WHITE = (255, 255, 255)

    def header(self):
        if self.page_no() == 1:
            return
        self.set_font('Helvetica', 'I', 8)
        self.set_text_color(*self.GRAY)
        self.cell(0, 8, 'Synapse Finance - AI Chat Assistant Implementation Guide (Ollama)', align='L')
        self.cell(0, 8, f'Page {self.page_no()}', align='R', new_x="LMARGIN", new_y="NEXT")
        self.set_draw_color(*self.PRIMARY)
        self.set_line_width(0.3)
        self.line(10, self.get_y(), 200, self.get_y())
        self.ln(4)

    def footer(self):
        self.set_y(-15)
        self.set_font('Helvetica', 'I', 7)
        self.set_text_color(*self.GRAY)
        self.cell(0, 10, 'Confidential - Synapse Finance', align='C')

    def cover_page(self):
        self.add_page()
        self.ln(50)
        self.set_font('Helvetica', 'B', 32)
        self.set_text_color(*self.PRIMARY)
        self.cell(0, 15, 'AI Chat Assistant', align='C', new_x="LMARGIN", new_y="NEXT")
        self.set_font('Helvetica', '', 18)
        self.set_text_color(*self.DARK)
        self.cell(0, 12, 'Implementation Guide', align='C', new_x="LMARGIN", new_y="NEXT")
        self.ln(4)
        self.set_font('Helvetica', 'I', 13)
        self.set_text_color(*self.ORANGE)
        self.cell(0, 10, 'Self-Hosted Ollama Edition', align='C', new_x="LMARGIN", new_y="NEXT")
        self.ln(6)
        self.set_draw_color(*self.PRIMARY)
        self.set_line_width(1)
        self.line(70, self.get_y(), 140, self.get_y())
        self.ln(12)
        self.set_font('Helvetica', '', 12)
        self.set_text_color(*self.GRAY)
        self.cell(0, 8, 'Synapse Finance - Money Manager App', align='C', new_x="LMARGIN", new_y="NEXT")
        self.cell(0, 8, 'Step-by-Step Developer Guide', align='C', new_x="LMARGIN", new_y="NEXT")
        self.ln(20)
        self.set_font('Helvetica', '', 10)
        self.cell(0, 7, 'Date: March 2026', align='C', new_x="LMARGIN", new_y="NEXT")
        self.cell(0, 7, 'Version: 1.1', align='C', new_x="LMARGIN", new_y="NEXT")
        self.cell(0, 7, 'Stack: Flutter + Django + Ollama (self-hosted)', align='C', new_x="LMARGIN", new_y="NEXT")

    def section_title(self, title, level=1):
        self.ln(4)
        if level == 1:
            if self.get_y() > 40:
                self.add_page()
            self.set_font('Helvetica', 'B', 20)
            self.set_text_color(*self.PRIMARY)
            self.cell(0, 12, title, new_x="LMARGIN", new_y="NEXT")
            self.set_draw_color(*self.PRIMARY)
            self.set_line_width(0.8)
            self.line(10, self.get_y(), 200, self.get_y())
            self.ln(6)
        elif level == 2:
            self.ln(2)
            self.set_font('Helvetica', 'B', 14)
            self.set_text_color(*self.DARK)
            self.cell(0, 10, title, new_x="LMARGIN", new_y="NEXT")
            self.ln(2)
        elif level == 3:
            self.set_font('Helvetica', 'B', 11)
            self.set_text_color(*self.ORANGE)
            self.cell(0, 8, title, new_x="LMARGIN", new_y="NEXT")
            self.ln(1)

    def body_text(self, text):
        self.set_font('Helvetica', '', 10)
        self.set_text_color(*self.DARK)
        self.multi_cell(0, 5.5, text)
        self.ln(2)

    def bullet(self, text, indent=10):
        self.set_font('Helvetica', '', 10)
        self.set_text_color(*self.DARK)
        self.set_x(self.l_margin + indent)
        self.cell(5, 5.5, '-')
        w = self.w - self.l_margin - self.r_margin - indent - 5
        self.multi_cell(w, 5.5, text)
        self.ln(1)

    def code_block(self, code, language=""):
        self.ln(2)
        self.set_fill_color(*self.LIGHT_BG)
        self.set_font('Courier', '', 8)
        self.set_text_color(30, 41, 59)
        lines = code.strip().split('\n')
        block_height = len(lines) * 4.5 + 6
        if self.get_y() + block_height > 270:
            self.add_page()
        start_y = self.get_y()
        self.rect(10, start_y, 190, block_height, 'F')
        self.set_fill_color(*self.PRIMARY)
        self.rect(10, start_y, 2, block_height, 'F')
        self.set_y(start_y + 3)
        for line in lines:
            self.set_x(16)
            if len(line) > 100:
                line = line[:97] + '...'
            self.cell(0, 4.5, line, new_x="LMARGIN", new_y="NEXT")
        self.ln(5)

    def info_box(self, title, text):
        self.ln(2)
        self.set_fill_color(219, 234, 254)
        self.set_draw_color(*self.BLUE)
        start_y = self.get_y()
        lines = textwrap.wrap(text, width=85)
        box_h = len(lines) * 5 + 14
        if start_y + box_h > 270:
            self.add_page()
            start_y = self.get_y()
        self.rect(10, start_y, 190, box_h, 'F')
        self.set_line_width(0.5)
        self.line(10, start_y, 10, start_y + box_h)
        self.set_xy(14, start_y + 3)
        self.set_font('Helvetica', 'B', 9)
        self.set_text_color(*self.BLUE)
        self.cell(0, 5, f'INFO: {title}', new_x="LMARGIN", new_y="NEXT")
        self.set_font('Helvetica', '', 9)
        self.set_text_color(30, 64, 175)
        for line in lines:
            self.set_x(14)
            self.cell(0, 5, line, new_x="LMARGIN", new_y="NEXT")
        self.ln(5)

    def warning_box(self, text):
        self.ln(2)
        self.set_fill_color(254, 243, 199)
        start_y = self.get_y()
        lines = textwrap.wrap(text, width=85)
        box_h = len(lines) * 5 + 10
        if start_y + box_h > 270:
            self.add_page()
            start_y = self.get_y()
        self.rect(10, start_y, 190, box_h, 'F')
        self.set_fill_color(*self.ORANGE)
        self.rect(10, start_y, 2, box_h, 'F')
        self.set_xy(16, start_y + 3)
        self.set_font('Helvetica', 'B', 9)
        self.set_text_color(*self.ORANGE)
        self.cell(0, 5, 'WARNING', new_x="LMARGIN", new_y="NEXT")
        self.set_font('Helvetica', '', 9)
        self.set_text_color(146, 64, 14)
        for line in lines:
            self.set_x(16)
            self.cell(0, 5, line, new_x="LMARGIN", new_y="NEXT")
        self.ln(5)

    def file_path(self, path):
        self.set_font('Courier', '', 8)
        self.set_text_color(*self.BLUE)
        self.cell(0, 5, path, new_x="LMARGIN", new_y="NEXT")
        self.set_font('Helvetica', '', 10)
        self.set_text_color(*self.DARK)

    def table_header(self, cols, widths):
        self.set_fill_color(*self.PRIMARY)
        self.set_text_color(*self.WHITE)
        self.set_font('Helvetica', 'B', 8)
        for i, col in enumerate(cols):
            self.cell(widths[i], 7, col, border=1, fill=True, align='C')
        self.ln()
        self.set_text_color(*self.DARK)

    def table_row(self, cols, widths):
        self.set_font('Helvetica', '', 8)
        self.set_fill_color(*self.LIGHT_BG)
        for i, col in enumerate(cols):
            self.cell(widths[i], 7, col, border=1)
        self.ln()

    def step_box(self, step_num, title, description):
        self.ln(3)
        if self.get_y() > 250:
            self.add_page()
        start_y = self.get_y()
        self.set_fill_color(*self.PRIMARY)
        self.set_text_color(*self.WHITE)
        self.set_font('Helvetica', 'B', 11)
        cx = 18
        cy = start_y + 4
        self.ellipse(cx - 5, cy - 4, 10, 10, 'F')
        self.set_xy(cx - 4, cy - 3)
        self.cell(8, 7, str(step_num), align='C')
        self.set_xy(28, start_y)
        self.set_font('Helvetica', 'B', 11)
        self.set_text_color(*self.DARK)
        self.cell(0, 8, title, new_x="LMARGIN", new_y="NEXT")
        self.set_x(28)
        self.set_font('Helvetica', '', 9)
        self.set_text_color(*self.GRAY)
        self.multi_cell(165, 5, description)
        self.ln(2)


def build_pdf():
    pdf = GuideDocument()

    # COVER
    pdf.cover_page()

    # TABLE OF CONTENTS
    pdf.add_page()
    pdf.section_title('Table of Contents')
    toc = [
        ('1', 'Prerequisites & Ollama Setup'),
        ('2', 'Project Structure Setup'),
        ('3', 'Step 1 - Domain Entities (Chat Message Models)'),
        ('4', 'Step 2 - Tool System (Registry, Schemas, Executor)'),
        ('5', 'Step 3 - AI Service Layer (Ollama Integration)'),
        ('6', 'Step 4 - Chat Repository & Local Storage'),
        ('7', 'Step 5 - Chat Cubit (State Management)'),
        ('8', 'Step 6 - Chat UI (Page, Widgets, Input Bar)'),
        ('9', 'Step 7 - Interactive Confirmation Cards'),
        ('10', 'Step 8 - Command System (/ Commands)'),
        ('11', 'Step 9 - Memory & Persistence (SQLite)'),
        ('12', 'Step 10 - Thinking & Streaming UI'),
        ('13', 'Step 11 - Home Page Integration'),
        ('14', 'Step 12 - Dependency Injection Setup'),
        ('15', 'Step 13 - Testing Strategy'),
        ('16', 'Step 14 - Error Handling & Edge Cases'),
        ('17', 'Reference: Ollama API Formats'),
        ('18', 'Reference: System Prompt Template'),
        ('19', 'Reference: Complete Tool Schema Table'),
        ('20', 'Reference: File Checklist'),
    ]
    for num, title in toc:
        pdf.set_x(15)
        pdf.set_font('Helvetica', 'B', 10)
        pdf.set_text_color(*pdf.PRIMARY)
        pdf.cell(12, 7, num)
        pdf.set_font('Helvetica', '', 10)
        pdf.set_text_color(*pdf.DARK)
        dots = '.' * (60 - len(title))
        pdf.cell(0, 7, f'{title} {dots}', new_x="LMARGIN", new_y="NEXT")

    # ================================================================
    # SECTION 1: Prerequisites
    # ================================================================
    pdf.section_title('1. Prerequisites & Ollama Setup')

    pdf.section_title('Before You Begin', 2)
    pdf.body_text('Make sure you have the following ready:')
    pdf.bullet('Flutter SDK 3.x+ with Dart 3.x (sealed classes required)')
    pdf.bullet('Ollama installed on your host machine (macOS/Linux)')
    pdf.bullet('A model with tool/function calling support pulled in Ollama')
    pdf.bullet('The existing Synapse Finance app running locally with the Django backend')
    pdf.bullet('Familiarity with the existing codebase: Cubit pattern, Retrofit API clients, GetIt DI')

    pdf.section_title('Ollama Installation & Model Setup', 2)
    pdf.code_block("""# Install Ollama (macOS)
brew install ollama

# Or download from https://ollama.com/download

# Start Ollama server
ollama serve

# Pull a model with tool calling support (recommended)
ollama pull qwen2.5:14b

# Alternative lighter models:
ollama pull llama3.1:8b
ollama pull mistral:7b
ollama pull qwen2.5:7b

# Verify it's running
curl http://localhost:11434/v1/models""")

    pdf.section_title('Recommended Models for Tool Calling', 2)
    widths = [40, 25, 30, 95]
    pdf.table_header(['Model', 'Size', 'VRAM Needed', 'Tool Calling Quality'], widths)
    pdf.table_row(['qwen2.5:14b', '14B', '~10GB', 'Excellent - best for structured tool calls'], widths)
    pdf.table_row(['qwen2.5:7b', '7B', '~5GB', 'Good - lighter alternative'], widths)
    pdf.table_row(['llama3.1:8b', '8B', '~6GB', 'Good - solid general purpose'], widths)
    pdf.table_row(['mistral:7b', '7B', '~5GB', 'Decent - fast responses'], widths)
    pdf.table_row(['llama3.1:70b', '70B', '~40GB', 'Best quality, needs beefy GPU'], widths)

    pdf.info_box('Remote Ollama Access',
                 'To access Ollama from a phone/emulator on a different device, set OLLAMA_HOST=0.0.0.0 before running ollama serve. Then use your machine\'s IP (e.g., http://192.168.1.x:11434/v1) as the base URL in the app. For production, use a reverse proxy (nginx/caddy) with HTTPS.')

    pdf.section_title('For Remote/Network Access', 3)
    pdf.code_block("""# Allow external connections
OLLAMA_HOST=0.0.0.0 ollama serve

# Find your machine's IP
ifconfig | grep "inet " | grep -v 127.0.0.1

# Test from another device
curl http://<YOUR_IP>:11434/v1/models""")

    pdf.section_title('New Flutter Dependencies', 2)
    pdf.body_text('Add these to your pubspec.yaml (no LLM SDK needed - we use Dio directly):')
    pdf.code_block("""dependencies:
  # ... existing deps ...
  drift: ^2.22.1                 # SQLite ORM for chat history & memory
  sqlite3_flutter_libs: ^0.5.28  # SQLite native bindings
  flutter_markdown: ^0.7.6       # Render markdown in AI responses
  uuid: ^4.5.1                   # Generate unique message IDs

dev_dependencies:
  # ... existing dev deps ...
  drift_dev: ^2.22.1             # Drift code generation
  # build_runner already present""")

    pdf.body_text('Run after adding:')
    pdf.code_block("flutter pub get")

    pdf.info_box('No LLM SDK Needed',
                 'Since Ollama exposes an OpenAI-compatible REST API, we use the existing Dio HTTP client directly. No anthropic_sdk_dart or openai_dart package needed. This also means you can swap Ollama for any OpenAI-compatible provider (vLLM, LM Studio, etc.) by just changing the base URL.')

    # ================================================================
    # SECTION 2: Project Structure
    # ================================================================
    pdf.section_title('2. Project Structure Setup')

    pdf.body_text('Create the following directory structure under lib/features/assistant/. This follows the same clean architecture pattern used by the existing ledger and subscriptions features.')
    pdf.code_block("""lib/features/assistant/
|-- data/
|   |-- datasources/
|   |   |-- ai_service.dart              # Ollama API client
|   |   |-- chat_local_datasource.dart   # SQLite for messages & memory
|   |-- models/
|   |   |-- chat_message_model.dart
|   |   |-- user_memory_model.dart
|   |-- repositories/
|       |-- chat_repository_impl.dart
|-- domain/
|   |-- entities/
|   |   |-- chat_message.dart            # Sealed class hierarchy
|   |   |-- chat_session.dart
|   |   |-- user_memory.dart
|   |-- repositories/
|   |   |-- chat_repository.dart
|   |-- usecases/
|       |-- send_message_usecase.dart
|       |-- load_session_usecase.dart
|       |-- manage_memory_usecase.dart
|-- presentation/
|   |-- bloc/
|   |   |-- chat_cubit.dart
|   |   |-- chat_state.dart
|   |-- pages/
|   |   |-- chat_page.dart
|   |-- widgets/
|       |-- message_bubble.dart
|       |-- thinking_indicator.dart
|       |-- command_overlay.dart
|       |-- suggestion_chips.dart
|       |-- chat_input_bar.dart
|       |-- interactive_cards/
|           |-- transaction_confirm_card.dart
|           |-- transfer_confirm_card.dart
|           |-- spending_summary_card.dart
|           |-- delete_confirm_card.dart
|-- tools/
    |-- tool_registry.dart
    |-- tool_schemas.dart
    |-- tool_executor.dart
    |-- tools/
        |-- transaction_tools.dart
        |-- account_tools.dart
        |-- category_tools.dart
        |-- subscription_tools.dart
        |-- query_tools.dart""")

    pdf.body_text('Create all directories first:')
    pdf.code_block("""mkdir -p lib/features/assistant/{data/{datasources,models,repositories},\\
domain/{entities,repositories,usecases},\\
presentation/{bloc,pages,widgets/interactive_cards},\\
tools/tools}""")

    # ================================================================
    # SECTION 3: Domain Entities
    # ================================================================
    pdf.section_title('3. Step 1 - Domain Entities')

    pdf.body_text('Start with the domain layer. These are pure Dart classes with no dependencies on Flutter or external packages.')

    pdf.section_title('3.1 ChatMessage (Sealed Class Hierarchy)', 2)
    pdf.file_path('lib/features/assistant/domain/entities/chat_message.dart')
    pdf.body_text('This is the core data model. Using Dart 3 sealed classes lets you pattern-match on message types when rendering in the UI.')
    pdf.code_block("""import 'package:equatable/equatable.dart';

enum CardStatus { pending, confirmed, ignored, expired }
enum InteractiveCardType {
  transactionConfirm,
  transferConfirm,
  subscriptionConfirm,
  deleteConfirm,
}

sealed class ChatMessage extends Equatable {
  final String id;
  final DateTime timestamp;
  const ChatMessage({required this.id, required this.timestamp});
}

class UserMessage extends ChatMessage {
  final String text;
  const UserMessage({
    required super.id, required super.timestamp, required this.text,
  });
  @override
  List<Object?> get props => [id, timestamp, text];
}

class AiTextMessage extends ChatMessage {
  final String text;
  final List<String>? suggestions;
  const AiTextMessage({
    required super.id, required super.timestamp,
    required this.text, this.suggestions,
  });
  @override
  List<Object?> get props => [id, timestamp, text, suggestions];
}

class AiThinkingMessage extends ChatMessage {
  final String? thinkingText;
  final bool isComplete;
  const AiThinkingMessage({
    required super.id, required super.timestamp,
    this.thinkingText, this.isComplete = false,
  });
  @override
  List<Object?> get props => [id, timestamp, thinkingText, isComplete];
}

class AiToolCallMessage extends ChatMessage {
  final String toolName;
  final Map<String, dynamic> arguments;
  final dynamic result;
  const AiToolCallMessage({
    required super.id, required super.timestamp,
    required this.toolName, required this.arguments, this.result,
  });
  @override
  List<Object?> get props => [id, timestamp, toolName, arguments, result];
}

class InteractiveCardMessage extends ChatMessage {
  final InteractiveCardType cardType;
  final String toolName;
  final Map<String, dynamic> data;
  final CardStatus status;
  const InteractiveCardMessage({
    required super.id, required super.timestamp,
    required this.cardType, required this.toolName,
    required this.data, this.status = CardStatus.pending,
  });

  InteractiveCardMessage copyWith({CardStatus? status}) {
    return InteractiveCardMessage(
      id: id, timestamp: timestamp, cardType: cardType,
      toolName: toolName, data: data,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, timestamp, cardType, toolName, data, status];
}""")

    pdf.section_title('3.2 ChatSession & UserMemory', 2)
    pdf.file_path('lib/features/assistant/domain/entities/chat_session.dart')
    pdf.code_block("""import 'package:equatable/equatable.dart';

class ChatSession extends Equatable {
  final String id;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatSession({
    required this.id, this.title,
    required this.createdAt, required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, createdAt, updatedAt];
}""")

    pdf.file_path('lib/features/assistant/domain/entities/user_memory.dart')
    pdf.code_block("""import 'package:equatable/equatable.dart';

class UserMemory extends Equatable {
  final String id;
  final String key;       // e.g. 'preferred_account'
  final String value;     // e.g. 'Checking'
  final String source;    // 'inferred' or 'explicit'
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserMemory({
    required this.id, required this.key, required this.value,
    required this.source, required this.createdAt, required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, key, value, source];
}""")

    # ================================================================
    # SECTION 4: Tool System
    # ================================================================
    pdf.section_title('4. Step 2 - Tool System')

    pdf.body_text('The tool system bridges the LLM and your existing API. It has three parts: definitions (schemas), a registry (lookup), and an executor (maps to API clients).')

    pdf.section_title('4.1 Tool Definition & Registry', 2)
    pdf.file_path('lib/features/assistant/tools/tool_registry.dart')
    pdf.code_block("""class ToolDefinition {
  final String name;
  final String description;
  final Map<String, dynamic> inputSchema;
  final bool isMutation;  // true = requires user confirmation

  const ToolDefinition({
    required this.name,
    required this.description,
    required this.inputSchema,
    this.isMutation = false,
  });

  /// OpenAI function calling format (used by Ollama)
  Map<String, dynamic> toOpenAISchema() => {
    'type': 'function',
    'function': {
      'name': name,
      'description': description,
      'parameters': inputSchema,
    },
  };
}

class ToolRegistry {
  final Map<String, ToolDefinition> _tools = {};

  void register(ToolDefinition tool) => _tools[tool.name] = tool;
  void registerAll(List<ToolDefinition> tools) {
    for (final t in tools) _tools[t.name] = t;
  }

  ToolDefinition? get(String name) => _tools[name];
  bool isMutation(String toolName) => _tools[toolName]?.isMutation ?? false;

  /// Get tool schemas in OpenAI format for Ollama
  List<Map<String, dynamic>> getToolSchemas() =>
      _tools.values.map((t) => t.toOpenAISchema()).toList();
}""")

    pdf.warning_box('Ollama uses OpenAI-format tool schemas: {"type": "function", "function": {"name": ..., "parameters": ...}}. This is different from Claude\'s format. The toOpenAISchema() method handles this conversion.')

    pdf.section_title('4.2 Tool Schema Definitions', 2)
    pdf.file_path('lib/features/assistant/tools/tool_schemas.dart')
    pdf.code_block("""List<ToolDefinition> getAllTools() => [...readOnlyTools, ...mutationTools];

final readOnlyTools = [
  ToolDefinition(
    name: 'list_accounts',
    description: 'Get all user bank accounts with current balances.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
  ToolDefinition(
    name: 'list_transactions',
    description: 'Get transactions. Filter by type, account, category, date range.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'transaction_type': {
          'type': 'string',
          'enum': ['expense', 'income', 'transfer'],
        },
        'account_id': {'type': 'integer'},
        'category_id': {'type': 'integer'},
        'date_from': {'type': 'string', 'format': 'date'},
        'date_to': {'type': 'string', 'format': 'date'},
      },
    },
  ),
  ToolDefinition(
    name: 'spending_by_category',
    description: 'Get total spending grouped by category.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'transaction_type': {'type': 'string', 'enum': ['expense', 'income']},
        'date_from': {'type': 'string', 'format': 'date'},
        'date_to': {'type': 'string', 'format': 'date'},
      },
    },
  ),
  ToolDefinition(
    name: 'list_subscriptions',
    description: 'Get all recurring subscriptions.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
  ToolDefinition(
    name: 'list_categories',
    description: 'Get all expense and income categories.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
  ToolDefinition(
    name: 'list_tags',
    description: 'Get all user-defined tags.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
  ToolDefinition(
    name: 'get_currency_info',
    description: 'Get primary currency and exchange rates.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
];

final mutationTools = [
  ToolDefinition(
    name: 'create_expense',
    description: 'Record an expense. Deducts from the specified account.',
    isMutation: true,
    inputSchema: {
      'type': 'object',
      'properties': {
        'amount': {'type': 'number', 'description': 'Expense amount'},
        'account_id': {'type': 'integer', 'description': 'Account to deduct from'},
        'category_id': {'type': 'integer', 'description': 'Expense category ID'},
        'note': {'type': 'string', 'description': 'Optional note'},
        'date': {'type': 'string', 'format': 'date'},
        'currency': {'type': 'string'},
        'tag_ids': {'type': 'array', 'items': {'type': 'integer'}},
      },
      'required': ['amount', 'account_id', 'category_id'],
    },
  ),
  ToolDefinition(
    name: 'create_income',
    description: 'Record income. Adds to the specified account.',
    isMutation: true,
    inputSchema: {
      'type': 'object',
      'properties': {
        'amount': {'type': 'number'},
        'account_id': {'type': 'integer'},
        'category_id': {'type': 'integer'},
        'note': {'type': 'string'},
        'date': {'type': 'string', 'format': 'date'},
      },
      'required': ['amount', 'account_id', 'category_id'],
    },
  ),
  ToolDefinition(
    name: 'create_transfer',
    description: 'Transfer money between two accounts.',
    isMutation: true,
    inputSchema: {
      'type': 'object',
      'properties': {
        'amount': {'type': 'number'},
        'from_account_id': {'type': 'integer'},
        'to_account_id': {'type': 'integer'},
        'note': {'type': 'string'},
        'date': {'type': 'string', 'format': 'date'},
      },
      'required': ['amount', 'from_account_id', 'to_account_id'],
    },
  ),
  ToolDefinition(
    name: 'delete_transaction',
    description: 'Delete a transaction and reverse its balance effect.',
    isMutation: true,
    inputSchema: {
      'type': 'object',
      'properties': {'transaction_id': {'type': 'integer'}},
      'required': ['transaction_id'],
    },
  ),
];""")

    pdf.section_title('4.3 Tool Executor', 2)
    pdf.file_path('lib/features/assistant/tools/tool_executor.dart')
    pdf.body_text('Maps tool names to your existing Retrofit API client methods:')
    pdf.code_block("""import 'package:injectable/injectable.dart';

@lazySingleton
class ToolExecutor {
  final LedgerApiClient _ledgerApi;
  final SubscriptionApiClient _subscriptionApi;
  final CurrencyApiClient _currencyApi;

  ToolExecutor(this._ledgerApi, this._subscriptionApi, this._currencyApi);

  Future<Map<String, dynamic>> execute(
    String toolName, Map<String, dynamic> args,
  ) async {
    return switch (toolName) {
      'list_accounts'        => _listAccounts(),
      'list_transactions'    => _listTransactions(args),
      'spending_by_category' => _spendingByCategory(args),
      'list_categories'      => _listCategories(),
      'list_subscriptions'   => _listSubscriptions(),
      'list_tags'            => _listTags(),
      'get_currency_info'    => _getCurrencyInfo(),
      'create_expense'       => _createExpense(args),
      'create_income'        => _createIncome(args),
      'create_transfer'      => _createTransfer(args),
      'delete_transaction'   => _deleteTransaction(args),
      _ => throw Exception('Unknown tool: \$toolName'),
    };
  }

  Future<Map<String, dynamic>> _listAccounts() async {
    final accounts = await _ledgerApi.getAccounts();
    return {'accounts': accounts.map((a) => a.toJson()).toList()};
  }

  Future<Map<String, dynamic>> _listTransactions(Map<String, dynamic> a) async {
    final txns = await _ledgerApi.getTransactions(
      transactionType: a['transaction_type'],
      accountId: a['account_id'],
      categoryId: a['category_id'],
      dateFrom: a['date_from'],
      dateTo: a['date_to'],
    );
    return {'transactions': txns.map((t) => t.toJson()).toList()};
  }
  // ... implement remaining methods following same pattern
}""")

    pdf.warning_box('The ToolExecutor reuses your existing API clients. Do NOT create new HTTP calls. Auth token, error handling, and base URL are already configured in your Dio interceptors.')

    # ================================================================
    # SECTION 5: AI Service (Ollama)
    # ================================================================
    pdf.section_title('5. Step 3 - AI Service (Ollama)')

    pdf.body_text('The AI Service communicates with your self-hosted Ollama instance via the OpenAI-compatible API. This is the most critical file.')

    pdf.section_title('5.1 Response Chunk Models', 2)
    pdf.code_block("""sealed class AiResponseChunk {}

class AiTextChunk extends AiResponseChunk {
  final String text;
  AiTextChunk({required this.text});
}

class AiToolCallChunk extends AiResponseChunk {
  final String toolCallId;
  final String toolName;
  final Map<String, dynamic> arguments;
  AiToolCallChunk({
    required this.toolCallId,
    required this.toolName,
    required this.arguments,
  });
}

class AiDoneChunk extends AiResponseChunk {}""")

    pdf.section_title('5.2 Ollama AI Service Implementation', 2)
    pdf.file_path('lib/features/assistant/data/datasources/ai_service.dart')

    pdf.section_title('Understanding Ollama SSE Streaming Format', 3)
    pdf.body_text('Ollama streams responses as Server-Sent Events (SSE). Each line starts with "data: " followed by JSON. Here is what each chunk type looks like:')
    pdf.code_block("""// Text content chunk:
data: {"choices":[{"delta":{"content":"Hello"}}]}

// Tool call start (first chunk with tool info):
data: {"choices":[{"delta":{"tool_calls":[{
  "index":0, "id":"call_abc123",
  "function":{"name":"list_accounts","arguments":""}
}]}}]}

// Tool call arguments (subsequent chunks):
data: {"choices":[{"delta":{"tool_calls":[{
  "index":0, "function":{"arguments":"{\"accoun"}
}]}}]}

// Done:
data: [DONE]""")

    pdf.section_title('Full Implementation', 3)
    pdf.code_block("""import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../tools/tool_registry.dart';

@lazySingleton
class AiService {
  final Dio _dio;
  final ToolRegistry _toolRegistry;

  // Configurable Ollama connection
  String _baseUrl = 'http://localhost:11434/v1';
  String _model = 'qwen2.5:14b';

  AiService(this._toolRegistry)
    : _dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5), // LLM can be slow
      ));

  void configure({required String baseUrl, String? model}) {
    _baseUrl = baseUrl;
    if (model != null) _model = model;
  }

  /// Send message and stream response from Ollama
  Stream<AiResponseChunk> sendMessage({
    required List<Map<String, dynamic>> messages,
    required String systemPrompt,
  }) async* {
    final body = {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...messages,
      ],
      'tools': _toolRegistry.getToolSchemas(),
      'stream': true,
    };

    final response = await _dio.post(
      '\$_baseUrl/chat/completions',
      data: jsonEncode(body),
      options: Options(responseType: ResponseType.stream),
    );

    // Parse SSE stream
    yield* _parseSSEStream(response.data as ResponseBody);
  }

  /// Non-streaming call (for tool result follow-ups)
  Future<Map<String, dynamic>> sendMessageSync({
    required List<Map<String, dynamic>> messages,
    required String systemPrompt,
  }) async {
    final body = {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...messages,
      ],
      'tools': _toolRegistry.getToolSchemas(),
      'stream': false,
    };

    final response = await _dio.post(
      '\$_baseUrl/chat/completions',
      data: jsonEncode(body),
    );
    return response.data as Map<String, dynamic>;
  }

  Stream<AiResponseChunk> _parseSSEStream(ResponseBody body) async* {
    final lineBuffer = StringBuffer();
    // Track tool call arguments being accumulated
    final toolArgBuffers = <int, StringBuffer>{};
    final toolCallIds = <int, String>{};
    final toolCallNames = <int, String>{};

    await for (final bytes in body.stream) {
      lineBuffer.write(utf8.decode(bytes));
      final raw = lineBuffer.toString();
      final lines = raw.split('\\n');
      lineBuffer.clear();
      // Keep incomplete last line
      if (!raw.endsWith('\\n')) {
        lineBuffer.write(lines.removeLast());
      }

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith(':')) continue;
        if (!trimmed.startsWith('data: ')) continue;

        final data = trimmed.substring(6);
        if (data == '[DONE]') {
          // Flush any pending tool calls
          for (final idx in toolCallIds.keys) {
            final argsStr = toolArgBuffers[idx]?.toString() ?? '{}';
            Map<String, dynamic> args = {};
            try { args = jsonDecode(argsStr); } catch (_) {}
            yield AiToolCallChunk(
              toolCallId: toolCallIds[idx]!,
              toolName: toolCallNames[idx]!,
              arguments: args,
            );
          }
          yield AiDoneChunk();
          return;
        }

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final choices = json['choices'] as List?;
          if (choices == null || choices.isEmpty) continue;
          final delta = choices[0]['delta'] as Map<String, dynamic>?;
          if (delta == null) continue;

          // Text content
          if (delta.containsKey('content') && delta['content'] != null) {
            yield AiTextChunk(text: delta['content'] as String);
          }

          // Tool calls
          final toolCalls = delta['tool_calls'] as List?;
          if (toolCalls != null) {
            for (final tc in toolCalls) {
              final idx = tc['index'] as int? ?? 0;
              final fn = tc['function'] as Map<String, dynamic>?;
              if (fn == null) continue;

              // First chunk has id and name
              if (tc.containsKey('id') && tc['id'] != null) {
                toolCallIds[idx] = tc['id'] as String;
                toolCallNames[idx] = fn['name'] as String;
                toolArgBuffers[idx] = StringBuffer();
              }
              // Accumulate arguments
              if (fn.containsKey('arguments')) {
                toolArgBuffers[idx]?.write(fn['arguments'] as String);
              }
            }
          }

          // Check for finish_reason = 'tool_calls'
          final finish = choices[0]['finish_reason'];
          if (finish == 'tool_calls' || finish == 'stop') {
            // Flush tool calls
            for (final idx in toolCallIds.keys) {
              final argsStr = toolArgBuffers[idx]?.toString() ?? '{}';
              Map<String, dynamic> args = {};
              try { args = jsonDecode(argsStr); } catch (_) {}
              yield AiToolCallChunk(
                toolCallId: toolCallIds[idx]!,
                toolName: toolCallNames[idx]!,
                arguments: args,
              );
            }
            toolCallIds.clear();
            toolArgBuffers.clear();
            toolCallNames.clear();
            if (finish == 'stop') {
              yield AiDoneChunk();
              return;
            }
          }
        } catch (_) {
          // Skip malformed chunks
        }
      }
    }
  }
}""")

    pdf.info_box('Streaming vs Sync',
                 'Use streaming (sendMessage) for the initial user query so text appears progressively. Use sync (sendMessageSync) for the tool-result follow-up calls where you need the complete response before deciding what to do next. You can also use streaming for follow-ups if you want progressive display.')

    pdf.section_title('5.3 Sending Tool Results Back to Ollama', 2)
    pdf.body_text('After executing a tool, send the result back. Ollama uses OpenAI format for tool results:')
    pdf.code_block("""// Build messages for tool result follow-up:
final messagesWithToolResult = [
  ...previousMessages,

  // The assistant's tool call (from the LLM response)
  {
    'role': 'assistant',
    'tool_calls': [
      {
        'id': 'call_abc123',
        'type': 'function',
        'function': {
          'name': 'list_accounts',
          'arguments': '{}',
        },
      },
    ],
  },

  // Your tool result
  {
    'role': 'tool',
    'tool_call_id': 'call_abc123',
    'content': jsonEncode({
      'accounts': [
        {'name': 'Checking', 'balance': 5240, 'currency': 'INR'},
        {'name': 'Savings', 'balance': 12800, 'currency': 'INR'},
      ],
    }),
  },
];

// Send back to Ollama for summarization
final summary = await aiService.sendMessageSync(
  messages: messagesWithToolResult,
  systemPrompt: systemPrompt,
);""")

    # ================================================================
    # SECTION 6: Chat Repository
    # ================================================================
    pdf.section_title('6. Step 4 - Chat Repository & Local Storage')

    pdf.section_title('6.1 Repository Interface', 2)
    pdf.file_path('lib/features/assistant/domain/repositories/chat_repository.dart')
    pdf.code_block("""import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message.dart';
import '../entities/chat_session.dart';
import '../entities/user_memory.dart';

abstract class ChatRepository {
  Future<Either<Failure, ChatSession>> createSession();
  Future<Either<Failure, List<ChatSession>>> getSessions();
  Future<Either<Failure, void>> deleteSession(String id);
  Future<Either<Failure, List<ChatMessage>>> getMessages(String sessionId);
  Future<Either<Failure, void>> saveMessage(String sessionId, ChatMessage msg);
  Future<Either<Failure, void>> updateMessage(String sessionId, ChatMessage msg);
  Future<Either<Failure, List<UserMemory>>> getMemories();
  Future<Either<Failure, void>> saveMemory(UserMemory memory);
  Future<Either<Failure, void>> deleteMemory(String key);
}""")

    pdf.section_title('6.2 SQLite with Drift', 2)
    pdf.file_path('lib/features/assistant/data/datasources/chat_local_datasource.dart')
    pdf.code_block("""import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

part 'chat_local_datasource.g.dart';

class ChatSessions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(ChatSessions, #id)();
  TextColumn get role => text()();
  TextColumn get content => text()();     // JSON
  TextColumn get messageType => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get metadata => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class UserMemories extends Table {
  TextColumn get id => text()();
  TextColumn get key => text().unique()();
  TextColumn get value => text()();
  TextColumn get source => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [ChatSessions, ChatMessages, UserMemories])
class ChatDatabase extends _\$ChatDatabase {
  ChatDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('\${dir.path}/synapse_chat.db');
      return NativeDatabase(file);
    });
  }
}""")

    pdf.body_text('After creating this file, run code generation:')
    pdf.code_block("dart run build_runner build --delete-conflicting-outputs")

    # ================================================================
    # SECTION 7: Chat Cubit
    # ================================================================
    pdf.section_title('7. Step 5 - Chat Cubit (State Management)')

    pdf.body_text('The Chat Cubit is the brain. It manages messages, handles the LLM agentic loop, and coordinates tool execution.')

    pdf.section_title('7.1 Chat State', 2)
    pdf.file_path('lib/features/assistant/presentation/bloc/chat_state.dart')
    pdf.code_block("""import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isThinking;
  final String? currentThinkingText;
  final String currentAiText;
  final String? error;
  final String sessionId;

  const ChatState({
    this.messages = const [],
    this.isThinking = false,
    this.currentThinkingText,
    this.currentAiText = '',
    this.error,
    this.sessionId = '',
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isThinking,
    String? currentThinkingText,
    String? currentAiText,
    String? error,
    String? sessionId,
  }) => ChatState(
    messages: messages ?? this.messages,
    isThinking: isThinking ?? this.isThinking,
    currentThinkingText: currentThinkingText ?? this.currentThinkingText,
    currentAiText: currentAiText ?? this.currentAiText,
    error: error,
    sessionId: sessionId ?? this.sessionId,
  );

  @override
  List<Object?> get props =>
    [messages, isThinking, currentThinkingText, currentAiText, error, sessionId];
}""")

    pdf.section_title('7.2 Chat Cubit - The Agentic Loop', 2)
    pdf.file_path('lib/features/assistant/presentation/bloc/chat_cubit.dart')
    pdf.body_text('This is the most important file. The agentic loop handles: user message -> LLM call -> tool calls -> tool results -> LLM summarization.')
    pdf.code_block("""import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/ai_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../tools/tool_registry.dart';
import '../../tools/tool_executor.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final AiService _aiService;
  final ToolRegistry _toolRegistry;
  final ToolExecutor _toolExecutor;
  final _uuid = const Uuid();
  static const _maxIterations = 5;

  // Conversation history in OpenAI format for Ollama
  final List<Map<String, dynamic>> _messageHistory = [];

  ChatCubit(this._aiService, this._toolRegistry, this._toolExecutor)
    : super(const ChatState());

  Future<void> sendMessage(String text) async {
    final userMsg = UserMessage(
      id: _uuid.v4(), timestamp: DateTime.now(), text: text,
    );
    _addMessage(userMsg);
    _messageHistory.add({'role': 'user', 'content': text});
    emit(state.copyWith(isThinking: true, currentAiText: ''));

    try {
      await _runAgenticLoop(0);
    } catch (e) {
      _addMessage(AiTextMessage(
        id: _uuid.v4(), timestamp: DateTime.now(),
        text: 'Something went wrong: \${e.toString()}',
      ));
    } finally {
      emit(state.copyWith(isThinking: false));
    }
  }

  Future<void> _runAgenticLoop(int iteration) async {
    if (iteration >= _maxIterations) {
      _addMessage(AiTextMessage(
        id: _uuid.v4(), timestamp: DateTime.now(),
        text: 'Reached processing limit. Please try rephrasing.',
      ));
      return;
    }

    final systemPrompt = await _buildSystemPrompt();
    String textBuffer = '';
    final pendingToolCalls = <_PendingToolCall>[];

    await for (final chunk in _aiService.sendMessage(
      messages: _messageHistory,
      systemPrompt: systemPrompt,
    )) {
      switch (chunk) {
        case AiTextChunk(:final text):
          textBuffer += text;
          emit(state.copyWith(currentAiText: textBuffer));

        case AiToolCallChunk(:final toolCallId, :final toolName, :final arguments):
          if (_toolRegistry.isMutation(toolName)) {
            // Show interactive card - DON'T execute
            final cardType = _getCardType(toolName);
            _addMessage(InteractiveCardMessage(
              id: _uuid.v4(), timestamp: DateTime.now(),
              cardType: cardType, toolName: toolName, data: arguments,
            ));
          } else {
            pendingToolCalls.add(_PendingToolCall(
              id: toolCallId, name: toolName, arguments: arguments,
            ));
          }

        case AiDoneChunk():
          break;
      }
    }

    // Finalize text
    if (textBuffer.isNotEmpty) {
      _addMessage(AiTextMessage(
        id: _uuid.v4(), timestamp: DateTime.now(), text: textBuffer,
      ));
      _messageHistory.add({'role': 'assistant', 'content': textBuffer});
      emit(state.copyWith(currentAiText: ''));
    }

    // Execute read-only tool calls and continue loop
    if (pendingToolCalls.isNotEmpty) {
      // Add assistant's tool_calls to history
      _messageHistory.add({
        'role': 'assistant',
        'tool_calls': pendingToolCalls.map((tc) => {
          'id': tc.id,
          'type': 'function',
          'function': {
            'name': tc.name,
            'arguments': jsonEncode(tc.arguments),
          },
        }).toList(),
      });

      // Execute each tool and add results
      for (final tc in pendingToolCalls) {
        try {
          final result = await _toolExecutor.execute(tc.name, tc.arguments);
          _messageHistory.add({
            'role': 'tool',
            'tool_call_id': tc.id,
            'content': jsonEncode(result),
          });
        } catch (e) {
          _messageHistory.add({
            'role': 'tool',
            'tool_call_id': tc.id,
            'content': jsonEncode({'error': e.toString()}),
          });
        }
      }

      // Continue loop for LLM to summarize tool results
      await _runAgenticLoop(iteration + 1);
    }
  }

  Future<void> confirmCard(String messageId) async {
    final idx = state.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final card = state.messages[idx] as InteractiveCardMessage;
    if (card.status != CardStatus.pending) return;

    try {
      await _toolExecutor.execute(card.toolName, card.data);
      final updated = card.copyWith(status: CardStatus.confirmed);
      final msgs = List<ChatMessage>.from(state.messages);
      msgs[idx] = updated;
      msgs.add(AiTextMessage(
        id: _uuid.v4(), timestamp: DateTime.now(),
        text: 'Done! Transaction recorded successfully.',
      ));
      emit(state.copyWith(messages: msgs));
    } catch (e) {
      emit(state.copyWith(error: 'Failed: \${e.toString()}'));
    }
  }

  Future<void> ignoreCard(String messageId) async {
    final idx = state.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final card = state.messages[idx] as InteractiveCardMessage;
    final updated = card.copyWith(status: CardStatus.ignored);
    final msgs = List<ChatMessage>.from(state.messages);
    msgs[idx] = updated;
    emit(state.copyWith(messages: msgs));
  }

  InteractiveCardType _getCardType(String toolName) => switch (toolName) {
    'create_expense' || 'create_income' => InteractiveCardType.transactionConfirm,
    'create_transfer' => InteractiveCardType.transferConfirm,
    'delete_transaction' => InteractiveCardType.deleteConfirm,
    _ => InteractiveCardType.transactionConfirm,
  };

  void _addMessage(ChatMessage msg) {
    emit(state.copyWith(messages: [...state.messages, msg]));
  }

  Future<String> _buildSystemPrompt() async {
    return '''You are an AI finance assistant for Synapse Finance.
Help users manage money through natural language.
For ANY mutation (add expense, income, transfer, delete), use the tool.
Ask for missing required fields before calling mutation tools.
For queries, call the read tool and summarize results clearly.
Keep responses concise.''';
  }
}

class _PendingToolCall {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;
  _PendingToolCall({required this.id, required this.name, required this.arguments});
}""")

    pdf.warning_box('The agentic loop is recursive. After executing read-only tools, results go back to Ollama for summarization. Ollama may call more tools. The _maxIterations guard (5) prevents infinite loops.')

    # ================================================================
    # SECTION 8: Chat UI
    # ================================================================
    pdf.section_title('8. Step 6 - Chat UI')

    pdf.body_text('Build the UI layer. Start with ChatPage, then individual widgets.')

    pdf.section_title('8.1 ChatPage', 2)
    pdf.file_path('lib/features/assistant/presentation/pages/chat_page.dart')
    pdf.code_block("""class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  bool _showCommands = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state.messages.isEmpty && !state.isThinking) {
          return _buildEmptyState(context);
        }
        return Column(children: [
          _buildAppBar(context),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: state.messages.length + (state.isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.messages.length) {
                  return ThinkingIndicator(text: state.currentThinkingText);
                }
                return MessageBubble(
                  message: state.messages[index],
                  onConfirm: (id) => context.read<ChatCubit>().confirmCard(id),
                  onIgnore: (id) => context.read<ChatCubit>().ignoreCard(id),
                );
              },
            ),
          ),
          if (_showCommands) CommandOverlay(
            onCommandSelected: (cmd) {
              _textController.text = '';
              setState(() => _showCommands = false);
              context.read<ChatCubit>().sendMessage(cmd.systemPrompt);
            },
          ),
          ChatInputBar(
            controller: _textController,
            onSend: (text) {
              context.read<ChatCubit>().sendMessage(text);
              _textController.clear();
              _scrollToBottom();
            },
            onChanged: (t) => setState(() => _showCommands = t == '/'),
            isLoading: state.isThinking,
          ),
        ]);
      },
    );
  }

  Widget _buildEmptyState(BuildContext ctx) {
    // Bot avatar + title + command cards (match the design mockup)
    return Column(children: [
      _buildAppBar(ctx),
      const Spacer(),
      Icon(Icons.smart_toy, size: 64, color: Theme.of(ctx).primaryColor),
      const SizedBox(height: 16),
      const Text('How can I help with your finances?',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text("Type '/' to see available commands",
        style: TextStyle(color: Colors.grey[600])),
      const SizedBox(height: 24),
      _buildCommandCards(ctx),
      const Spacer(),
      ChatInputBar(
        controller: _textController,
        onSend: (t) => ctx.read<ChatCubit>().sendMessage(t),
        onChanged: (t) => setState(() => _showCommands = t == '/'),
        isLoading: false,
      ),
    ]);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}""")

    pdf.section_title('8.2 MessageBubble (Pattern Matching)', 2)
    pdf.file_path('lib/features/assistant/presentation/widgets/message_bubble.dart')
    pdf.code_block("""class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<String>? onConfirm;
  final ValueChanged<String>? onIgnore;

  const MessageBubble({super.key, required this.message, this.onConfirm, this.onIgnore});

  @override
  Widget build(BuildContext context) {
    return switch (message) {
      UserMessage(:final text) => _UserBubble(text: text),
      AiTextMessage(:final text, :final suggestions) =>
        _AiBubble(text: text, suggestions: suggestions),
      AiThinkingMessage(:final thinkingText) =>
        _ThinkingBubble(text: thinkingText),
      AiToolCallMessage(:final toolName) =>
        _ToolCallBubble(toolName: toolName),
      InteractiveCardMessage() => TransactionConfirmCard(
        card: message as InteractiveCardMessage,
        onConfirm: () => onConfirm?.call(message.id),
        onIgnore: () => onIgnore?.call(message.id),
      ),
    };
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text),
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  final String text;
  final List<String>? suggestions;
  const _AiBubble({required this.text, this.suggestions});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, right: 48),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use MarkdownBody(data: text) for markdown rendering
            Text(text),
            if (suggestions != null) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: suggestions!.map((s) =>
                ActionChip(label: Text(s), onPressed: () {}),
              ).toList()),
            ],
          ],
        ),
      ),
    );
  }
}""")

    pdf.section_title('8.3 ChatInputBar', 2)
    pdf.file_path('lib/features/assistant/presentation/widgets/chat_input_bar.dart')
    pdf.code_block("""class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final ValueChanged<String>? onChanged;
  final bool isLoading;

  const ChatInputBar({super.key, required this.controller,
    required this.onSend, this.onChanged, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
        ),
        child: Row(children: [
          Expanded(child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Ask follow-up...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onSubmitted: (text) {
              if (text.trim().isNotEmpty && !isLoading) {
                onSend(text.trim());
                controller.clear();
              }
            },
          )),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(isLoading ? Icons.hourglass_empty : Icons.arrow_upward,
              color: Theme.of(context).primaryColor),
            onPressed: isLoading ? null : () {
              final text = controller.text.trim();
              if (text.isNotEmpty) { onSend(text); controller.clear(); }
            },
          ),
        ]),
      ),
    );
  }
}""")

    # ================================================================
    # SECTION 9: Interactive Cards
    # ================================================================
    pdf.section_title('9. Step 7 - Interactive Confirmation Cards')

    pdf.body_text('Cards prevent accidental mutations. Each mutation tool renders a card with Confirm/Ignore buttons instead of auto-executing.')

    pdf.file_path('lib/features/assistant/presentation/widgets/interactive_cards/transaction_confirm_card.dart')
    pdf.code_block("""class TransactionConfirmCard extends StatelessWidget {
  final InteractiveCardMessage card;
  final VoidCallback onConfirm;
  final VoidCallback onIgnore;

  const TransactionConfirmCard({
    super.key, required this.card, required this.onConfirm, required this.onIgnore,
  });

  @override
  Widget build(BuildContext context) {
    final data = card.data;
    final isPending = card.status == CardStatus.pending;
    final isConfirmed = card.status == CardStatus.confirmed;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConfirmed ? Colors.green : Colors.grey.withOpacity(0.3),
          width: isConfirmed ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(card.toolName == 'create_expense' ? 'New Expense' : 'New Income',
              style: const TextStyle(fontWeight: FontWeight.bold)),
            _StatusBadge(status: card.status),
          ]),
          const Divider(),
          // Details
          Row(children: [
            _Detail('Amount', '\$\${data["amount"]}'),
            _Detail('Account', 'ID: \${data["account_id"]}'),
          ]),
          if (data['note'] != null)
            Text('Note: \${data["note"]}', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 12),
          // Buttons
          if (isPending) Row(children: [
            Expanded(child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Confirm & Add'),
            )),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(
              onPressed: onIgnore,
              child: const Text('Ignore'),
            )),
          ]),
          if (isConfirmed) const Row(children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Added successfully', style: TextStyle(color: Colors.green)),
          ]),
        ]),
      ),
    );
  }
}""")

    pdf.info_box('Enriching Card Data',
                 'Cards show account_id/category_id as raw IDs. Pre-fetch accounts and categories when chat loads, store in cubit state, and resolve IDs to names (e.g., "Checking" instead of "ID: 1").')

    # ================================================================
    # SECTION 10: Command System
    # ================================================================
    pdf.section_title('10. Step 8 - Command System')

    pdf.body_text('Commands are predefined shortcuts triggered by typing "/" in the input bar.')
    pdf.code_block("""class ChatCommand {
  final String name;
  final String description;
  final IconData icon;
  final String systemPrompt;
  const ChatCommand({
    required this.name, required this.description,
    required this.icon, required this.systemPrompt,
  });
}

const kBuiltInCommands = [
  ChatCommand(
    name: '/budget', description: 'Set or revise monthly budget',
    icon: Icons.pie_chart,
    systemPrompt: 'Help me set a monthly budget. Show current spending by '
      'category first, then suggest budget limits.',
  ),
  ChatCommand(
    name: '/goal', description: 'Create a new savings goal',
    icon: Icons.flag,
    systemPrompt: 'I want to create a savings goal. Ask about target '
      'amount, timeline, and which account to save from.',
  ),
  ChatCommand(
    name: '/bills', description: 'Review recurring bills',
    icon: Icons.receipt_long,
    systemPrompt: 'Show my upcoming bills and subscriptions. '
      'Highlight any that are due or overdue.',
  ),
  ChatCommand(
    name: '/pf', description: 'Portfolio check',
    icon: Icons.account_balance,
    systemPrompt: 'Give a portfolio overview: all accounts with balances, '
      'total assets, liabilities, and net worth.',
  ),
  ChatCommand(
    name: '/spend', description: 'Spending analysis',
    icon: Icons.analytics,
    systemPrompt: 'Analyze my spending for the current month. '
      'Break down by category.',
  ),
  ChatCommand(
    name: '/add', description: 'Quick add transaction',
    icon: Icons.add_circle,
    systemPrompt: 'I want to add a transaction. Ask: expense/income/transfer? '
      'Amount? Account? Category?',
  ),
];""")

    # ================================================================
    # SECTION 11: Memory
    # ================================================================
    pdf.section_title('11. Step 9 - Memory & Persistence')

    pdf.body_text('Memory gives the assistant context across sessions.')
    pdf.code_block("""class MemoryManager {
  final ChatDatabase _db;
  MemoryManager(this._db);

  Future<String> getMemoryContext() async {
    final memories = await _db.select(_db.userMemories).get();
    if (memories.isEmpty) return '';
    final buffer = StringBuffer('User preferences:\\n');
    for (final m in memories) {
      buffer.writeln('- \${m.key}: \${m.value}');
    }
    return buffer.toString();
  }

  Future<void> saveMemory(String key, String value,
    {String source = 'inferred'}) async {
    await _db.into(_db.userMemories).insertOnConflictUpdate(
      UserMemoriesCompanion.insert(
        id: const Uuid().v4(), key: key, value: value,
        source: source, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> extractFromConversation(List<ChatMessage> messages) async {
    for (final msg in messages) {
      if (msg is InteractiveCardMessage && msg.status == CardStatus.confirmed) {
        if (msg.data.containsKey('account_id')) {
          await saveMemory('last_used_account', msg.data['account_id'].toString());
        }
      }
    }
  }
}""")

    # ================================================================
    # SECTION 12: Thinking UI
    # ================================================================
    pdf.section_title('12. Step 10 - Thinking & Streaming UI')

    pdf.file_path('lib/features/assistant/presentation/widgets/thinking_indicator.dart')
    pdf.code_block("""class ThinkingIndicator extends StatefulWidget {
  final String? text;
  const ThinkingIndicator({super.key, this.text});
  @override
  State<ThinkingIndicator> createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<ThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, right: 64),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => Row(
                  children: List.generate(3, (i) {
                    final v = (_ctrl.value - i * 0.2).clamp(0.0, 1.0);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor
                          .withOpacity(0.3 + 0.7 * (1 - (v * 2 - 1).abs())),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Text('Thinking...', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            ]),
            if (widget.text != null) ...[
              const SizedBox(height: 8),
              Text(widget.text!, style: TextStyle(
                color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic,
              )),
            ],
          ],
        ),
      ),
    );
  }
}""")

    # ================================================================
    # SECTION 13: Home Page Integration
    # ================================================================
    pdf.section_title('13. Step 11 - Home Page Integration')

    pdf.body_text('Replace the _AssistantTab placeholder with the new ChatPage:')
    pdf.code_block("""// home_page.dart - BEFORE:
late final _tabs = [
  const _AssistantTab(),     // REMOVE
  // ...
];

// AFTER:
import '../../../assistant/presentation/pages/chat_page.dart';
import '../../../assistant/presentation/bloc/chat_cubit.dart';
import '../../../../core/di/injection.dart';

late final _tabs = [
  BlocProvider(
    create: (_) => getIt<ChatCubit>(),
    child: const ChatPage(),
  ),
  // ... existing tabs unchanged
];

// DELETE the _AssistantTab class at bottom of file""")

    pdf.warning_box('Keep _AssistantTab until ChatPage is functional. Toggle between them during development.')

    # ================================================================
    # SECTION 14: DI Setup
    # ================================================================
    pdf.section_title('14. Step 12 - Dependency Injection')

    pdf.code_block("""// Add @injectable / @lazySingleton annotations:

@lazySingleton
class AiService { ... }

@lazySingleton
class ToolRegistry {
  ToolRegistry() { registerAll(getAllTools()); }
}

@lazySingleton
class ToolExecutor { ... }

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository { ... }

@lazySingleton
class MemoryManager { ... }

@lazySingleton
class ChatDatabase extends _\$ChatDatabase { ... }

@injectable
class ChatCubit extends Cubit<ChatState> { ... }""")

    pdf.body_text('After adding annotations, regenerate:')
    pdf.code_block("dart run build_runner build --delete-conflicting-outputs")

    pdf.section_title('Ollama Configuration in Settings', 2)
    pdf.code_block("""// Add to Settings page: Ollama host URL + model selection
import 'package:shared_preferences/shared_preferences.dart';

const _kOllamaUrlKey = 'ollama_base_url';
const _kOllamaModelKey = 'ollama_model';

Future<void> saveOllamaConfig(String url, String model) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kOllamaUrlKey, url);
  await prefs.setString(_kOllamaModelKey, model);
}

// On app startup:
final prefs = await SharedPreferences.getInstance();
final url = prefs.getString(_kOllamaUrlKey) ?? 'http://localhost:11434/v1';
final model = prefs.getString(_kOllamaModelKey) ?? 'qwen2.5:14b';
getIt<AiService>().configure(baseUrl: url, model: model);""")

    pdf.info_box('No API Key Needed',
                 'Unlike cloud LLM providers, self-hosted Ollama does not require an API key by default. Just point the app to your Ollama server URL. If you enable OLLAMA_API_KEY on your server, add an Authorization header in AiService._dio.')

    # ================================================================
    # SECTION 15: Testing
    # ================================================================
    pdf.section_title('15. Step 13 - Testing Strategy')

    pdf.section_title('Key Test Cases', 2)
    pdf.code_block("""// test/features/assistant/tools/tool_executor_test.dart
class MockLedgerApi extends Mock implements LedgerApiClient {}

void main() {
  late ToolExecutor executor;
  late MockLedgerApi mockLedgerApi;

  setUp(() {
    mockLedgerApi = MockLedgerApi();
    executor = ToolExecutor(mockLedgerApi, ...);
  });

  test('list_accounts calls getAccounts', () async {
    when(() => mockLedgerApi.getAccounts())
      .thenAnswer((_) async => [/* mock */]);
    final result = await executor.execute('list_accounts', {});
    verify(() => mockLedgerApi.getAccounts()).called(1);
  });

  test('unknown tool throws', () {
    expect(() => executor.execute('unknown', {}), throwsException);
  });
}

// test/features/assistant/bloc/chat_cubit_test.dart
test('mutation tool shows card, does not execute', () async {
  when(() => mockRegistry.isMutation('create_expense')).thenReturn(true);
  when(() => mockAiService.sendMessage(any(), any()))
    .thenAnswer((_) => Stream.fromIterable([
      AiToolCallChunk(toolCallId: '1', toolName: 'create_expense',
        arguments: {'amount': 12, 'account_id': 1, 'category_id': 2}),
      AiDoneChunk(),
    ]));

  await cubit.sendMessage('Add 12 dollar coffee');

  final card = cubit.state.messages.last;
  expect(card, isA<InteractiveCardMessage>());
  expect((card as InteractiveCardMessage).status, CardStatus.pending);
  verifyNever(() => mockExecutor.execute(any(), any()));
});""")

    # ================================================================
    # SECTION 16: Error Handling
    # ================================================================
    pdf.section_title('16. Step 14 - Error Handling & Edge Cases')

    pdf.section_title('Ollama-Specific Errors', 2)
    pdf.code_block("""// In ChatCubit.sendMessage try-catch:

} on DioException catch (e) {
  String errorMsg;
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout) {
    errorMsg = 'Cannot connect to Ollama at \$_baseUrl. '
      'Make sure Ollama is running (ollama serve).';
  } else if (e.response?.statusCode == 404) {
    errorMsg = 'Model "\$_model" not found. '
      'Pull it first: ollama pull \$_model';
  } else {
    errorMsg = 'Ollama error: \${e.message}';
  }
  _addMessage(AiTextMessage(
    id: _uuid.v4(), timestamp: DateTime.now(), text: errorMsg,
  ));
}""")

    pdf.section_title('Edge Cases Checklist', 2)
    pdf.bullet('Ollama not running: Show connection error with "ollama serve" hint')
    pdf.bullet('Model not pulled: Show 404 error with "ollama pull <model>" hint')
    pdf.bullet('Slow inference: receiveTimeout is set to 5 minutes; show thinking indicator')
    pdf.bullet('Tool calling not supported: Some models skip tools; handle gracefully')
    pdf.bullet('Double-tap confirm: Check status == pending before executing')
    pdf.bullet('Empty tool results: LLM should say "No transactions found"')
    pdf.bullet('Concurrent sends: Disable input while isThinking == true')
    pdf.bullet('App backgrounding: Save session state (WidgetsBindingObserver)')
    pdf.bullet('Max iterations: Guard at 5 to prevent infinite agentic loops')

    # ================================================================
    # SECTION 17: Ollama API Formats Reference
    # ================================================================
    pdf.section_title('17. Reference: Ollama API Formats')

    pdf.section_title('Request Format', 2)
    pdf.code_block("""POST http://localhost:11434/v1/chat/completions
Content-Type: application/json

{
  "model": "qwen2.5:14b",
  "stream": true,
  "messages": [
    {"role": "system", "content": "You are a finance assistant..."},
    {"role": "user", "content": "How much did I spend on food?"}
  ],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "spending_by_category",
        "description": "Get spending totals by category",
        "parameters": {
          "type": "object",
          "properties": {
            "transaction_type": {"type": "string", "enum": ["expense", "income"]},
            "date_from": {"type": "string", "format": "date"},
            "date_to": {"type": "string", "format": "date"}
          }
        }
      }
    }
  ]
}""")

    pdf.section_title('Streaming Response Format', 2)
    pdf.code_block("""// Text chunk:
data: {"choices":[{"index":0,"delta":{"content":"Here is"},"finish_reason":null}]}

// Tool call chunk (first):
data: {"choices":[{"index":0,"delta":{"tool_calls":[{
  "index":0,"id":"call_abc","type":"function",
  "function":{"name":"spending_by_category","arguments":""}
}]},"finish_reason":null}]}

// Tool call arguments (streamed):
data: {"choices":[{"index":0,"delta":{"tool_calls":[{
  "index":0,"function":{"arguments":"{\"transaction_type\":\"expense\"}"}
}]},"finish_reason":null}]}

// Finish:
data: {"choices":[{"index":0,"delta":{},"finish_reason":"tool_calls"}]}
data: [DONE]""")

    pdf.section_title('Tool Result Format (send back)', 2)
    pdf.code_block("""// Include in messages array:
{
  "role": "assistant",
  "tool_calls": [{
    "id": "call_abc",
    "type": "function",
    "function": {"name": "spending_by_category", "arguments": "{...}"}
  }]
},
{
  "role": "tool",
  "tool_call_id": "call_abc",
  "content": "{\"data\": [{\"category\": \"Food\", \"total\": 3500}]}"
}""")

    # ================================================================
    # SECTION 18: System Prompt
    # ================================================================
    pdf.section_title('18. Reference: System Prompt Template')
    pdf.code_block("""const systemPromptTemplate = '''
You are an AI finance assistant for Synapse Finance.
You help users manage their money through natural language.

CURRENT DATE: {current_date}

USER CONTEXT:
- Primary currency: {primary_currency}
- Accounts: {accounts_summary}
- Categories: {categories_summary}
{memory_context}

RULES:
1. For ANY action that creates, modifies, or deletes data, you MUST use
   the appropriate tool call. Never just describe the action in text.
2. Before calling a mutation tool, ensure ALL required fields are known.
   If any are missing, ASK the user. Do not guess.
3. For read-only queries, call the tool and summarize results in a
   friendly, concise way.
4. Respect the user's primary currency. If they say "500" without a
   currency, assume {primary_currency}.
5. When showing amounts, format them with the currency symbol.
6. If the user asks about something outside personal finance,
   politely redirect.
7. Keep responses concise.
8. When multiple accounts exist, always clarify which one to use.

AVAILABLE COMMANDS:
/budget - Budget management
/goal - Savings goals
/bills - Recurring bills
/pf - Portfolio overview
/spend - Spending analysis
/add - Quick add transaction
''';""")

    # ================================================================
    # SECTION 19: Tool Schema Table
    # ================================================================
    pdf.section_title('19. Reference: Complete Tool Schema Table')

    pdf.section_title('Read-Only Tools (Auto-execute)', 2)
    widths = [35, 55, 55, 45]
    pdf.table_header(['Tool Name', 'Description', 'API Endpoint', 'Parameters'], widths)
    for t in [
        ('list_accounts', 'Get all accounts', 'GET /api/ledger/accounts/', 'None'),
        ('list_transactions', 'Get filtered txns', 'GET /api/ledger/transactions/', 'type, acct, cat, dates'),
        ('get_transaction', 'Get single txn', 'GET .../transactions/{id}', 'transaction_id'),
        ('list_categories', 'Get all categories', 'GET /api/ledger/categories/', 'None'),
        ('list_subscriptions', 'Get subscriptions', 'GET /api/subscriptions/', 'None'),
        ('spending_by_category', 'Spending by category', 'GET .../spending-by-category', 'type, dates'),
        ('list_tags', 'Get all tags', 'GET /api/ledger/tags/', 'None'),
        ('get_currency_info', 'Get currencies', 'GET /api/currencies/user', 'None'),
    ]:
        pdf.table_row(list(t), widths)

    pdf.ln(8)
    pdf.section_title('Mutation Tools (Require Confirmation Card)', 2)
    widths2 = [35, 50, 55, 50]
    pdf.table_header(['Tool Name', 'Description', 'API Endpoint', 'Required Fields'], widths2)
    for t in [
        ('create_expense', 'Record expense', 'POST .../expense', 'amount, account_id, category_id'),
        ('create_income', 'Record income', 'POST .../income', 'amount, account_id, category_id'),
        ('create_transfer', 'Transfer funds', 'POST .../transfer', 'amount, from_id, to_id'),
        ('delete_transaction', 'Delete + reverse', 'DELETE .../transactions/{id}', 'transaction_id'),
    ]:
        pdf.table_row(list(t), widths2)

    # ================================================================
    # SECTION 20: File Checklist
    # ================================================================
    pdf.section_title('20. Reference: Implementation Checklist')

    checklist = [
        ('DOMAIN LAYER', [
            'domain/entities/chat_message.dart',
            'domain/entities/chat_session.dart',
            'domain/entities/user_memory.dart',
            'domain/repositories/chat_repository.dart',
            'domain/usecases/send_message_usecase.dart',
            'domain/usecases/load_session_usecase.dart',
            'domain/usecases/manage_memory_usecase.dart',
        ]),
        ('TOOL SYSTEM', [
            'tools/tool_registry.dart',
            'tools/tool_schemas.dart',
            'tools/tool_executor.dart',
        ]),
        ('DATA LAYER', [
            'data/datasources/ai_service.dart (Ollama client)',
            'data/datasources/chat_local_datasource.dart (Drift DB)',
            'data/models/chat_message_model.dart',
            'data/models/user_memory_model.dart',
            'data/repositories/chat_repository_impl.dart',
        ]),
        ('PRESENTATION', [
            'presentation/bloc/chat_state.dart',
            'presentation/bloc/chat_cubit.dart',
            'presentation/pages/chat_page.dart',
            'presentation/widgets/message_bubble.dart',
            'presentation/widgets/chat_input_bar.dart',
            'presentation/widgets/thinking_indicator.dart',
            'presentation/widgets/command_overlay.dart',
            'presentation/widgets/suggestion_chips.dart',
        ]),
        ('INTERACTIVE CARDS', [
            'widgets/interactive_cards/transaction_confirm_card.dart',
            'widgets/interactive_cards/transfer_confirm_card.dart',
            'widgets/interactive_cards/spending_summary_card.dart',
            'widgets/interactive_cards/delete_confirm_card.dart',
        ]),
        ('INTEGRATION', [
            'Modify pubspec.yaml (drift, flutter_markdown, uuid)',
            'Modify home_page.dart (replace _AssistantTab)',
            'Add DI annotations to all new classes',
            'Run build_runner (drift + injectable)',
            'Add Ollama config in Settings page',
        ]),
        ('TESTING', [
            'test tool_executor_test.dart',
            'test chat_cubit_test.dart',
            'test memory_manager_test.dart',
            'Integration test: end-to-end chat flow',
        ]),
    ]

    for section, items in checklist:
        pdf.section_title(section, 3)
        for item in items:
            pdf.set_font('Helvetica', '', 9)
            pdf.set_text_color(*pdf.DARK)
            pdf.set_x(15)
            pdf.cell(6, 5, '[ ]')
            pdf.cell(0, 5, item, new_x="LMARGIN", new_y="NEXT")
        pdf.ln(4)

    # Final page
    pdf.add_page()
    pdf.ln(60)
    pdf.set_font('Helvetica', 'B', 18)
    pdf.set_text_color(*pdf.PRIMARY)
    pdf.cell(0, 12, 'Implementation Order Summary', align='C', new_x="LMARGIN", new_y="NEXT")
    pdf.ln(8)

    phases = [
        ('Phase 1: Core Chat (MVP)', 'Domain entities, tool system, Ollama AI service, basic chat UI, tool-use loop. Get a working chat that can answer "How much did I spend this month?" using real API data via Ollama.'),
        ('Phase 2: Interactive Cards', 'Mutation tools, confirmation cards, confirm/ignore flow. Users say "Add a 500 rupee coffee expense" and confirm via card.'),
        ('Phase 3: Commands & UX', 'Command overlay (/budget, /spend, etc.), suggestion chips, thinking indicator, markdown rendering, empty state design.'),
        ('Phase 4: Memory', 'SQLite setup with Drift, session persistence, memory extraction, system prompt injection with user context.'),
        ('Phase 5: Polish', 'Error handling (Ollama connection, model not found), offline mode, settings (Ollama URL, model picker), testing.'),
    ]

    for i, (title, desc) in enumerate(phases, 1):
        pdf.step_box(i, title, desc)

    pdf.ln(20)
    pdf.set_font('Helvetica', 'I', 10)
    pdf.set_text_color(*pdf.GRAY)
    pdf.cell(0, 8, 'Start with Phase 1. Get it working end-to-end before moving to Phase 2.', align='C', new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 8, 'Each phase builds on the previous one. Do not skip ahead.', align='C', new_x="LMARGIN", new_y="NEXT")
    pdf.ln(10)
    pdf.set_font('Helvetica', 'B', 10)
    pdf.set_text_color(*pdf.ORANGE)
    pdf.cell(0, 8, 'Ollama Tip: Test tool calling manually first with curl before coding.', align='C', new_x="LMARGIN", new_y="NEXT")
    pdf.ln(15)
    pdf.set_font('Helvetica', 'B', 12)
    pdf.set_text_color(*pdf.PRIMARY)
    pdf.cell(0, 8, 'Good luck building! Ship it!', align='C', new_x="LMARGIN", new_y="NEXT")

    return pdf


if __name__ == '__main__':
    pdf = build_pdf()
    out = '/Users/ajay/Documents/SynapseApps/MoneyManager/plans/AI-Chat-Assistant-Implementation-Guide.pdf'
    pdf.output(out)
    print(f'PDF generated: {out}')
    print(f'Pages: {pdf.page_no()}')
