import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../domain/entities/file_node.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'file_icon.dart';
import 'file_status_badge.dart';
import 'package:timeago/timeago.dart' as timeago;

class FileItem extends StatelessWidget {
  final FileNode file;
  final VoidCallback onTap;

  const FileItem({
    super.key,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            FileIcon(
              path: file.path,
              isDirectory: file.isDirectory,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          file.name,
                          style: AppTypography.body,
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (!file.isDirectory) ...[
                        Text(
                          file.formattedSize,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        timeago.format(file.modifiedAt, locale: 'en_short'),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              file.isDirectory
                  ? PhosphorIconsRegular.caretRight
                  : PhosphorIconsRegular.fileText,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
