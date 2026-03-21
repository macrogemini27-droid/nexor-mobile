import 'tool.dart';
import 'tool_context.dart';
import 'tool_result.dart';

class ToolRegistry {
  final Map<String, Tool> _tools = {};

  /// Register a tool
  void register(Tool tool) {
    _tools[tool.id] = tool;
  }

  /// Unregister a tool
  void unregister(String toolId) {
    _tools.remove(toolId);
  }

  /// Get a tool by ID
  Tool? getTool(String toolId) {
    return _tools[toolId];
  }

  /// Check if a tool is registered
  bool hasTool(String toolId) {
    return _tools.containsKey(toolId);
  }

  /// Get all registered tools
  List<Tool> getAllTools() {
    return _tools.values.toList();
  }

  /// Get tool definitions in JSON format for AI providers
  List<Map<String, dynamic>> getToolDefinitions() {
    return _tools.values.map((tool) => tool.toJson()).toList();
  }

  /// Execute a tool by ID
  Future<ToolResult> executeTool(
    String toolId,
    Map<String, dynamic> args,
    ToolContext context,
  ) async {
    final tool = getTool(toolId);
    if (tool == null) {
      return ToolResult.error(
        title: 'Tool not found',
        output: 'Tool "$toolId" is not registered',
      );
    }

    try {
      return await tool.execute(args, context);
    } catch (e, stackTrace) {
      return ToolResult.error(
        title: 'Tool execution failed',
        output: 'Error executing tool "$toolId": $e\n\nStack trace:\n$stackTrace',
      );
    }
  }

  /// Clear all registered tools
  void clear() {
    _tools.clear();
  }

  /// Get count of registered tools
  int get count => _tools.length;
}
