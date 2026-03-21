import 'dart:convert';

class EncodingHandler {
  /// Detect encoding of bytes
  static String detectEncoding(List<int> bytes) {
    // Check for UTF-8 BOM
    if (bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF) {
      return 'utf-8-bom';
    }

    // Check for UTF-16 BE BOM
    if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
      return 'utf-16-be';
    }

    // Check for UTF-16 LE BOM
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
      return 'utf-16-le';
    }

    // Try to decode as UTF-8
    try {
      utf8.decode(bytes, allowMalformed: false);
      return 'utf-8';
    } catch (e) {
      // Not valid UTF-8
    }

    // Default to ASCII/Latin-1
    return 'latin-1';
  }

  /// Decode bytes to string with proper encoding
  static String decode(List<int> bytes) {
    final encoding = detectEncoding(bytes);

    switch (encoding) {
      case 'utf-8-bom':
        // Skip BOM and decode
        return utf8.decode(bytes.sublist(3));
      case 'utf-8':
        return utf8.decode(bytes, allowMalformed: true);
      case 'latin-1':
        return latin1.decode(bytes);
      default:
        // Fallback to UTF-8 with malformed handling
        return utf8.decode(bytes, allowMalformed: true);
    }
  }

  /// Encode string to bytes with UTF-8
  static List<int> encode(String text) {
    return utf8.encode(text);
  }

  /// Check if string is valid UTF-8
  static bool isValidUtf8(String text) {
    try {
      final bytes = utf8.encode(text);
      utf8.decode(bytes, allowMalformed: false);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sanitize string for safe display
  static String sanitize(String text) {
    // Remove null characters
    text = text.replaceAll('\x00', '');
    
    // Replace control characters (except newline, tab, carriage return)
    text = text.replaceAllMapped(
      RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'),
      (match) => '',
    );
    
    return text;
  }

  /// Normalize line endings to \n
  static String normalizeLineEndings(String text) {
    // Convert Windows (CRLF) to Unix (LF)
    text = text.replaceAll('\r\n', '\n');
    // Convert old Mac (CR) to Unix (LF)
    text = text.replaceAll('\r', '\n');
    return text;
  }
}
