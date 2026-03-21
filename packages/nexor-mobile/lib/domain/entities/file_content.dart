import 'package:equatable/equatable.dart';

class FileContent extends Equatable {
  final String content;
  final String language;
  final int lines;
  final int size;
  final String encoding;

  const FileContent({
    required this.content,
    required this.language,
    required this.lines,
    required this.size,
    required this.encoding,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  bool get isLarge => size > 1024 * 1024; // > 1MB

  @override
  List<Object?> get props => [content, language, lines, size, encoding];
}
