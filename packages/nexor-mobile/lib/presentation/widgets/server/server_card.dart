import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../domain/entities/server.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/theme/typography.dart';
import '../common/nexor_card.dart';
import 'server_status_badge.dart';
import 'server_info_row.dart';

/// Server card widget
class ServerCard extends StatelessWidget {
  final Server server;
  final ServerStatus status;
  final VoidCallback? onTap;
  final VoidCallback? onConnect;
  final VoidCallback? onBrowseFiles;
  final VoidCallback? onTest;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ServerCard({
    super.key,
    required this.server,
    this.status = ServerStatus.offline,
    this.onTap,
    this.onConnect,
    this.onBrowseFiles,
    this.onTest,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return NexorCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.name,
                      style: AppTypography.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.space4),
                    Text(
                      server.url,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              ServerStatusBadge(status: status),
            ],
          ),

          const SizedBox(height: AppDimensions.space16),

          // Info rows
          if (server.username != null) ...[
            ServerInfoRow(
              icon: PhosphorIconsRegular.user,
              label: 'User:',
              value: server.username!,
            ),
            const SizedBox(height: AppDimensions.space8),
          ],
          if (server.lastUsedAt != null) ...[
            ServerInfoRow(
              icon: PhosphorIconsRegular.clock,
              label: 'Last used:',
              value: timeago.format(server.lastUsedAt!),
            ),
            const SizedBox(height: AppDimensions.space8),
          ],
          ServerInfoRow(
            icon: PhosphorIconsRegular.calendar,
            label: 'Created:',
            value: timeago.format(server.createdAt),
          ),

          const SizedBox(height: AppDimensions.space16),

          // Actions
          Row(
            children: [
              if (onConnect != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onConnect,
                    icon: Icon(PhosphorIconsRegular.plugsConnected, size: 18),
                    label: const Text('Connect'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.space12,
                      ),
                    ),
                  ),
                ),
              if (onConnect != null && (onBrowseFiles != null || onTest != null))
                const SizedBox(width: AppDimensions.space8),
              if (onBrowseFiles != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onBrowseFiles,
                    icon: Icon(PhosphorIconsRegular.folder, size: 18),
                    label: const Text('Files'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.space12,
                      ),
                    ),
                  ),
                ),
              if (onBrowseFiles != null && onTest != null)
                const SizedBox(width: AppDimensions.space8),
              if (onTest != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTest,
                    icon: Icon(PhosphorIconsRegular.pulse, size: 18),
                    label: const Text('Test'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.space12,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: AppDimensions.space8),
              IconButton(
                onPressed: onEdit,
                icon: Icon(PhosphorIconsRegular.pencilSimple),
                color: AppColors.textSecondary,
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(PhosphorIconsRegular.trash),
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
