import 'tool_context.dart';
import 'tool_result.dart';

abstract class Tool {
  /// Unique identifier for this tool
  String get id;

  /// Human-readable description of what this tool does
  String get description;

  /// JSON schema for the tool's parameters
  /// This follows the format expected by AI providers (Anthropic, OpenAI, etc.)
  Map<String, dynamic> get parameters;

  /// Execute the tool with the given arguments and context
  Future<ToolResult> execute(
    Map<String, dynamic> args,
    ToolContext context,
  );

  /// Convert tool to JSON format for AI provider
  Map<String, dynamic> toJson() {
    return {
      'name': id,
      'description': description,
      'input_schema': parameters,
    };
  }
}
