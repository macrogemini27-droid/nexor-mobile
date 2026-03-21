import 'package:equatable/equatable.dart';

enum AIMessageRole {
  user,
  assistant,
  system,
}

class AIMessage extends Equatable {
  final AIMessageRole role;
  final List<AIMessageContent> content;
  final Map<String, dynamic> metadata;

  const AIMessage({
    required this.role,
    required this.content,
    this.metadata = const {},
  });

  factory AIMessage.text({
    required AIMessageRole role,
    required String text,
  }) {
    return AIMessage(
      role: role,
      content: [AIMessageContent.text(text)],
    );
  }

  factory AIMessage.user(String text) {
    return AIMessage.text(role: AIMessageRole.user, text: text);
  }

  factory AIMessage.assistant(String text) {
    return AIMessage.text(role: AIMessageRole.assistant, text: text);
  }

  factory AIMessage.system(String text) {
    return AIMessage.text(role: AIMessageRole.system, text: text);
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role.name,
      'content': content.map((c) => c.toJson()).toList(),
      if (metadata.isNotEmpty) 'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [role, content, metadata];
}

abstract class AIMessageContent extends Equatable {
  const AIMessageContent();

  factory AIMessageContent.text(String text) = TextContent;
  factory AIMessageContent.toolUse(String id, String name, Map<String, dynamic> input) = ToolUseContent;
  factory AIMessageContent.toolResult(String toolUseId, String content) = ToolResultContent;

  Map<String, dynamic> toJson();
}

class TextContent extends AIMessageContent {
  final String text;

  const TextContent(this.text);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'text',
      'text': text,
    };
  }

  @override
  List<Object?> get props => [text];
}

class ToolUseContent extends AIMessageContent {
  final String id;
  final String name;
  final Map<String, dynamic> input;

  const ToolUseContent(this.id, this.name, this.input);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'tool_use',
      'id': id,
      'name': name,
      'input': input,
    };
  }

  @override
  List<Object?> get props => [id, name, input];
}

class ToolResultContent extends AIMessageContent {
  final String toolUseId;
  final String content;
  final bool isError;

  const ToolResultContent(this.toolUseId, this.content, {this.isError = false});

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'tool_result',
      'tool_use_id': toolUseId,
      'content': content,
      if (isError) 'is_error': true,
    };
  }

  @override
  List<Object?> get props => [toolUseId, content, isError];
}
