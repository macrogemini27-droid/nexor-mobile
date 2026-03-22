import 'package:flutter/material.dart';
import '../../core/errors/error_types.dart';

class ErrorDisplay extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final VoidCallback? onReconnect;
  final VoidCallback? onDismiss;

  const ErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
    this.onReconnect,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorInfo = _getErrorInfo(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              errorInfo.icon,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              errorInfo.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorInfo.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (errorInfo.details != null) ...[
              const SizedBox(height: 8),
              Text(
                errorInfo.details!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            _buildActions(context, errorInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, _ErrorInfo info) {
    final actions = <Widget>[];

    if (info.retryable && onRetry != null) {
      actions.add(
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      );
    }

    if (info.needsReconnect && onReconnect != null) {
      actions.add(
        ElevatedButton.icon(
          onPressed: onReconnect,
          icon: const Icon(Icons.wifi),
          label: const Text('Reconnect'),
        ),
      );
    }

    if (onDismiss != null) {
      actions.add(
        TextButton(
          onPressed: onDismiss,
          child: const Text('Go Back'),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: actions,
    );
  }

  _ErrorInfo _getErrorInfo(Object error) {
    if (error is NetworkException) {
      return _ErrorInfo(
        icon: Icons.wifi_off,
        title: 'Network Error',
        message: error.message,
        details: error.details,
        retryable: true,
        needsReconnect: false,
      );
    }

    if (error is ConnectionException) {
      return _ErrorInfo(
        icon: Icons.cloud_off,
        title: 'Connection Failed',
        message: error.message,
        details: error.details,
        retryable: true,
        needsReconnect: true,
      );
    }

    if (error is AuthException) {
      return _ErrorInfo(
        icon: Icons.lock,
        title: 'Authentication Failed',
        message: error.message,
        details: error.details,
        retryable: false,
        needsReconnect: true,
      );
    }

    if (error is FileNotFoundException) {
      return _ErrorInfo(
        icon: Icons.search_off,
        title: 'File Not Found',
        message: 'The requested file could not be found',
        details: error.path,
        retryable: false,
        needsReconnect: false,
      );
    }

    if (error is PermissionException) {
      return _ErrorInfo(
        icon: Icons.block,
        title: 'Permission Denied',
        message: 'You do not have permission to access this file',
        details: error.path,
        retryable: false,
        needsReconnect: false,
      );
    }

    if (error is OperationTimeoutException) {
      return _ErrorInfo(
        icon: Icons.timer_off,
        title: 'Operation Timed Out',
        message: 'The operation took too long to complete',
        details: error.operation,
        retryable: true,
        needsReconnect: false,
      );
    }

    if (error is PathValidationException) {
      return _ErrorInfo(
        icon: Icons.security,
        title: 'Invalid Path',
        message: error.message,
        details: error.details,
        retryable: false,
        needsReconnect: false,
      );
    }

    if (error is BinaryFileException) {
      return _ErrorInfo(
        icon: Icons.insert_drive_file,
        title: 'Binary File',
        message: 'This file cannot be displayed as text',
        details: 'Size: ${error.size} bytes',
        retryable: false,
        needsReconnect: false,
      );
    }

    if (error is SftpException) {
      return _ErrorInfo(
        icon: Icons.error_outline,
        title: 'SFTP Error',
        message: error.message,
        details: error.details,
        retryable: true,
        needsReconnect: false,
      );
    }

    if (error is AppException) {
      return _ErrorInfo(
        icon: Icons.error_outline,
        title: 'Error',
        message: error.message,
        details: error.details,
        retryable: error.retryable,
        needsReconnect: false,
      );
    }

    return _ErrorInfo(
      icon: Icons.error_outline,
      title: 'Unexpected Error',
      message: 'An unexpected error occurred',
      details: error.toString(),
      retryable: false,
      needsReconnect: false,
    );
  }
}

class _ErrorInfo {
  final IconData icon;
  final String title;
  final String message;
  final String? details;
  final bool retryable;
  final bool needsReconnect;

  _ErrorInfo({
    required this.icon,
    required this.title,
    required this.message,
    this.details,
    required this.retryable,
    required this.needsReconnect,
  });
}
