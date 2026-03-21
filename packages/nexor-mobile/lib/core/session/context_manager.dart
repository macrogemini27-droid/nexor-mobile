class ContextManager {
  static const int _maxContextTokens = 100000; // Approximate token limit
  static const int _charsPerToken = 4; // Rough estimate

  /// Check if context is within limits
  bool isWithinLimits(String context) {
    final estimatedTokens = context.length ~/ _charsPerToken;
    return estimatedTokens <= _maxContextTokens;
  }

  /// Truncate context to fit within limits
  /// Keeps most recent messages and removes oldest ones
  String truncateContext(String context, {int maxTokens = _maxContextTokens}) {
    final maxChars = maxTokens * _charsPerToken;
    
    if (context.length <= maxChars) {
      return context;
    }

    // Keep the last maxChars characters
    return context.substring(context.length - maxChars);
  }

  /// Estimate token count for a string
  int estimateTokens(String text) {
    return text.length ~/ _charsPerToken;
  }

  /// Calculate total tokens in message history
  int calculateHistoryTokens(List<String> messages) {
    final totalChars = messages.fold<int>(0, (sum, msg) => sum + msg.length);
    return totalChars ~/ _charsPerToken;
  }

  /// Trim message history to fit within token limit
  List<T> trimHistory<T>(
    List<T> messages,
    int Function(T) getLength, {
    int maxTokens = _maxContextTokens,
  }) {
    final maxChars = maxTokens * _charsPerToken;
    int totalChars = 0;
    final result = <T>[];

    // Add messages from newest to oldest until we hit the limit
    for (int i = messages.length - 1; i >= 0; i--) {
      final msgLength = getLength(messages[i]);
      if (totalChars + msgLength > maxChars && result.isNotEmpty) {
        break;
      }
      result.insert(0, messages[i]);
      totalChars += msgLength;
    }

    return result;
  }
}
