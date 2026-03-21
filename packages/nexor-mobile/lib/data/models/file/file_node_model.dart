import 'package:hive/hive.dart';
import '../../../domain/entities/file_node.dart';

part 'file_node_model.g.dart';

@HiveType(typeId: 1)
class FileNodeModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String path;

  @HiveField(2)
  final bool isDirectory;

  @HiveField(3)
  final int size;

  @HiveField(4)
  final DateTime modifiedAt;

  @HiveField(5)
  final String? gitStatus;

  @HiveField(6)
  final String? mimeType;

  FileNodeModel({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    required this.modifiedAt,
    this.gitStatus,
    this.mimeType,
  });

  factory FileNodeModel.fromJson(Map<String, dynamic> json) {
    return FileNodeModel(
      name: json['name'] as String,
      path: json['path'] as String,
      isDirectory: json['isDirectory'] as bool,
      size: json['size'] as int? ?? 0,
      modifiedAt: json['modifiedAt'] != null
          ? DateTime.parse(json['modifiedAt'] as String)
          : DateTime.now(),
      gitStatus: json['gitStatus'] as String?,
      mimeType: json['mimeType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'isDirectory': isDirectory,
      'size': size,
      'modifiedAt': modifiedAt.toIso8601String(),
      'gitStatus': gitStatus,
      'mimeType': mimeType,
    };
  }

  FileNode toEntity() {
    return FileNode(
      name: name,
      path: path,
      isDirectory: isDirectory,
      size: size,
      modifiedAt: modifiedAt,
      gitStatus: gitStatus,
      mimeType: mimeType,
    );
  }

  factory FileNodeModel.fromEntity(FileNode entity) {
    return FileNodeModel(
      name: entity.name,
      path: entity.path,
      isDirectory: entity.isDirectory,
      size: entity.size,
      modifiedAt: entity.modifiedAt,
      gitStatus: entity.gitStatus,
      mimeType: entity.mimeType,
    );
  }
}
