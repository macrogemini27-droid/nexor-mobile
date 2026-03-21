import 'package:flutter/material.dart';
import '../../../core/utils/file_type_detector.dart';

class FileIcon extends StatelessWidget {
  final String path;
  final bool isDirectory;
  final double size;
  final Color? color;

  const FileIcon({
    super.key,
    required this.path,
    required this.isDirectory,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final icon = FileTypeDetector.getIcon(path, isDirectory);
    final defaultColor = FileTypeDetector.getColor(path, isDirectory);

    return Icon(
      icon,
      size: size,
      color: color ?? defaultColor,
    );
  }
}
