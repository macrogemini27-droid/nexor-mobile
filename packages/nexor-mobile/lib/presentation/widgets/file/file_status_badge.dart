import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class FileStatusBadge extends StatelessWidget {
  final String status;

  const FileStatusBadge({
    super.key,
    required this.status,
  });

  Color _getColor(String status) {
    switch (status.toLowerCase()) {
      case 'modified':
      case 'm':
        return AppColors.warning;
      case 'added':
      case 'a':
        return AppColors.success;
      case 'deleted':
      case 'd':
        return AppColors.error;
      case 'untracked':
      case 'u':
      case '?':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getLabel(String status) {
    switch (status.toLowerCase()) {
      case 'modified':
        return 'M';
      case 'added':
        return 'A';
      case 'deleted':
        return 'D';
      case 'untracked':
        return 'U';
      default:
        return status.substring(0, 1).toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(status);
    final label = _getLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}
