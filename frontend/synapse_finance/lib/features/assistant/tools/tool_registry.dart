class ToolDefinition {
  final String name;
  final String description;
  final Map<String, dynamic> inputSchema;
  final bool isMutation;

  const ToolDefinition({
    required this.name,
    required this.description,
    required this.inputSchema,
    this.isMutation = false,
  });

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
    for (final t in tools) {
      _tools[t.name] = t;
    }
  }

  ToolDefinition? get(String name) => _tools[name];

  bool isMutation(String toolName) => _tools[toolName]?.isMutation ?? false;

  List<Map<String, dynamic>> getToolSchemas() =>
      _tools.values.map((t) => t.toOpenAISchema()).toList();
}
