import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/theme/typography.dart';

enum ServerStatus {
  online,
  offline,
  connecting,
}

/// Server status badge
class ServerStatusBadge extends StatelessWidget {
  final ServerStatus status;

  const ServerStatusBadge({
    super.key,
    required this.status,
  });

  Color get _color {
    switch (status) {
      case ServerStatus.online:
        return AppColors.online;
      case ServerStatus.offline:
        return AppColors.offline;
      case ServerStatus.connecting:
        return AppColors.connecting;
    }
  }

  String get _label {
    switch (status) {
      case ServerStatus.online:
        return 'Online';
      case ServerStatus.offline:
        return 'Offline';
      case ServerStatus.connecting:
        return 'Connecting';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space8,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(
          color: _color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.space4),
          Text(
            _label,
            style: AppTypography.labelSmall.copyWith(
              color: _color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
