import 'dart:async';
import 'dart:convert';

class SSEParser {
  /// Parse Server-Sent Events stream
  static Stream<Map<String, dynamic>> parse(Stream<String> stream) async* {
    String buffer = '';
    String? eventType;
    String? eventData;
    String? eventId;

    await for (final chunk in stream) {
      buffer += chunk;
      final lines = buffer.split('\n');
      
      // Keep the last incomplete line in the buffer
      buffer = lines.last;
      
      // Process complete lines
      for (int i = 0; i < lines.length - 1; i++) {
        final line = lines[i].trim();
        
        if (line.isEmpty) {
          // Empty line indicates end of event
          if (eventData != null) {
            try {
              final data = json.decode(eventData);
              yield {
                'type': eventType ?? 'message',
                'data': data,
                if (eventId != null) 'id': eventId,
              };
            } catch (e) {
              // Invalid JSON, skip this event
            }
            
            // Reset for next event
            eventType = null;
            eventData = null;
            eventId = null;
          }
        } else if (line.startsWith('event:')) {
          eventType = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          final data = line.substring(5).trim();
          eventData = eventData == null ? data : '$eventData\n$data';
        } else if (line.startsWith('id:')) {
          eventId = line.substring(3).trim();
        } else if (line.startsWith(':')) {
          // Comment line, ignore
          continue;
        }
      }
    }
    
    // Process any remaining data in buffer
    if (eventData != null) {
      try {
        final data = json.decode(eventData);
        yield {
          'type': eventType ?? 'message',
          'data': data,
          if (eventId != null) 'id': eventId,
        };
      } catch (e) {
        // Invalid JSON, skip
      }
    }
  }

  /// Parse SSE from raw bytes
  static Stream<Map<String, dynamic>> parseBytes(Stream<List<int>> byteStream) {
    final stringStream = byteStream.transform(utf8.decoder);
    return parse(stringStream);
  }
}
