import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/theme/typography.dart';

/// Server info row widget
class ServerInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ServerInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconSmall,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: AppDimensions.space8),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
