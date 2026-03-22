import '../../../domain/entities/file_content.dart';

class FileContentModel {
  final String content;
  final String language;
  final int lines;
  final int size;
  final String encoding;

  FileContentModel({
    required this.content,
    required this.language,
    required this.lines,
    required this.size,
    required this.encoding,
  });

  factory FileContentModel.fromJson(Map<String, dynamic> json) {
    return FileContentModel(
      content: json['content'] as String? ?? '',
      language: json['language'] as String? ?? 'plaintext',
      lines: json['lines'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      encoding: json['encoding'] as String? ?? 'utf-8',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'language': language,
      'lines': lines,
      'size': size,
      'encoding': encoding,
    };
  }

  FileContent toEntity() {
    return FileContent(
      content: content,
      language: language,
      lines: lines,
      size: size,
      encoding: encoding,
    );
  }

  factory FileContentModel.fromEntity(FileContent entity) {
    return FileContentModel(
      content: entity.content,
      language: entity.language,
      lines: entity.lines,
      size: entity.size,
      encoding: entity.encoding,
    );
  }
}
