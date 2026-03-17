import 'package:injectable/injectable.dart';

import '../tools/tool_registry.dart';
import '../tools/tool_schemas.dart';

@module
abstract class AssistantModule {
  @lazySingleton
  ToolRegistry get toolRegistry {
    final registry = ToolRegistry();
    registry.registerAll(getAllTools());
    return registry;
  }
}
