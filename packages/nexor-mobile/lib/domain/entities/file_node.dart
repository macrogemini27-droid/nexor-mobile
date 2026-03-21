import 'package:equatable/equatable.dart';

class FileNode extends Equatable {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime modifiedAt;
  final String? gitStatus;
  final String? mimeType;

  const FileNode({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    required this.modifiedAt,
    this.gitStatus,
    this.mimeType,
  });

  String get extension {
    if (isDirectory) return '';
    final parts = path.split('.');
    return parts.length > 1 ? parts.last : '';
  }

  String get parentPath {
    if (path.isEmpty || path == '/') return '/';
    final lastSlash = path.lastIndexOf('/');
    if (lastSlash <= 0) return '/';
    return path.substring(0, lastSlash);
  }

  bool get isHidden => name.startsWith('.');

  String get formattedSize {
    if (isDirectory) return '';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  List<Object?> get props => [
        name,
        path,
        isDirectory,
        size,
        modifiedAt,
        gitStatus,
        mimeType,
      ];
}
