import '../../domain/entities/message.dart';

class MessageParser {
  static List<MessagePart> parse(String content) {
    final parts = <MessagePart>[];

    // Regex patterns
    final codeBlockPattern = RegExp(
      r'```(\w+)?\n([\s\S]*?)```',
      multiLine: true,
    );

    int lastIndex = 0;

    // Find all code blocks
    final matches = codeBlockPattern.allMatches(content).toList();

    for (final match in matches) {
      // Add text before code block
      if (match.start > lastIndex) {
        final text = content.substring(lastIndex, match.start);
        if (text.trim().isNotEmpty) {
          parts.add(MessagePart(
            id: 'text-${parts.length}',
            type: 'text',
            content: text,
          ));
        }
      }

      // Check if it's a diff
      final language = match.group(1) ?? 'plaintext';
      final code = match.group(2) ?? '';

      if (language == 'diff') {
        parts.add(MessagePart(
          id: 'diff-${parts.length}',
          type: 'diff',
          content: code,
          metadata: {'language': 'diff'},
        ));
      } else {
        parts.add(MessagePart(
          id: 'code-${parts.length}',
          type: 'code',
          content: code,
          metadata: {'language': language},
        ));
      }

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < content.length) {
      final text = content.substring(lastIndex);
      if (text.trim().isNotEmpty) {
        parts.add(MessagePart(
          id: 'text-${parts.length}',
          type: 'text',
          content: text,
        ));
      }
    }

    // If no parts were found, treat entire content as text
    if (parts.isEmpty && content.trim().isNotEmpty) {
      parts.add(MessagePart(
        id: 'text-0',
        type: 'text',
        content: content,
      ));
    }

    return parts;
  }

  static String extractFileName(String content) {
    // Try to extract filename from common patterns
    final patterns = [
      RegExp(r'File:\s*`([^`]+)`'),
      RegExp(r'file:\s*`([^`]+)`'),
      RegExp(r'`([^`]+)`\s*:'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(content);
      if (match != null) {
        return match.group(1) ?? '';
      }
    }

    return '';
  }
}
