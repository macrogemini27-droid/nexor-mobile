import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:math' show min;
import '../../../domain/entities/file_node.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'file_icon.dart';
import 'file_status_badge.dart';
import 'package:timeago/timeago.dart' as timeago;

class FileItem extends StatelessWidget {
  final FileNode file;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;
  final VoidCallback? onShare;
  final int index;

  const FileItem({
    super.key,
    required this.file,
    required this.onTap,
    this.onDelete,
    this.onRename,
    this.onShare,
    this.index = 0,
  });

  Color _getFileTypeColor() {
    if (file.isDirectory) return AppColors.primary;
    
    final ext = file.name.split('.').last.toLowerCase();
    switch (ext) {
      case 'dart':
      case 'js':
      case 'ts':
      case 'py':
      case 'java':
      case 'kt':
        return const Color(0xFF4CAF50); // Green for code
      case 'json':
      case 'yaml':
      case 'yml':
      case 'xml':
        return const Color(0xFFFF9800); // Orange for config
      case 'md':
      case 'txt':
      case 'doc':
        return const Color(0xFF2196F3); // Blue for docs
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'svg':
        return const Color(0xFFE91E63); // Pink for images
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cap animation delay to prevent UI lag with many files (max 300ms)
    final animationDelay = Duration(milliseconds: min(index * 30, 300));

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: animationDelay,
      child: Slidable(
        key: ValueKey(file.path),
        enabled: !file.isDirectory,
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            if (onShare != null)
              SlidableAction(
                onPressed: (_) => onShare!(),
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                icon: PhosphorIconsRegular.shareNetwork,
                label: 'Share',
                borderRadius: BorderRadius.circular(12),
              ),
            if (onRename != null)
              SlidableAction(
                onPressed: (_) => onRename!(),
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                icon: PhosphorIconsRegular.pencil,
                label: 'Rename',
                borderRadius: BorderRadius.circular(12),
              ),
            if (onDelete != null)
              SlidableAction(
                onPressed: (_) => onDelete!(),
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                icon: PhosphorIconsRegular.trash,
                label: 'Delete',
                borderRadius: BorderRadius.circular(12),
              ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // File Icon with colored background
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getFileTypeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: FileIcon(
                          path: file.path,
                          isDirectory: file.isDirectory,
                          size: 24,
                          color: _getFileTypeColor(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // File Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  file.name,
                                  style: AppTypography.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (file.gitStatus != null) ...[
                                const SizedBox(width: 8),
                                FileStatusBadge(status: file.gitStatus!),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (!file.isDirectory) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    file.formattedSize,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Icon(
                                PhosphorIconsRegular.clock,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timeago.format(file.modifiedAt, locale: 'en_short'),
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Arrow indicator
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: file.isDirectory
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        file.isDirectory
                            ? PhosphorIconsRegular.caretRight
                            : PhosphorIconsRegular.fileText,
                        size: 16,
                        color: file.isDirectory
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
