import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class FileInfoBar extends StatelessWidget {
  final int lines;
  final String size;
  final String language;

  const FileInfoBar({
    super.key,
    required this.lines,
    required this.size,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _InfoItem(
            icon: PhosphorIconsRegular.textAlignLeft,
            label: '$lines lines',
          ),
          const SizedBox(width: 16),
          _InfoItem(
            icon: PhosphorIconsRegular.fileText,
            label: size,
          ),
          const SizedBox(width: 16),
          _InfoItem(
            icon: PhosphorIconsRegular.code,
            label: language,
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
