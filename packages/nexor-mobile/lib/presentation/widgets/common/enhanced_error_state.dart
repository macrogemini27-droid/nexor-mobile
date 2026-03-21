import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/theme/typography.dart';

/// Enhanced error state widget with copy functionality
class EnhancedErrorState extends StatefulWidget {
  final String title;
  final String message;
  final String? technicalDetails;
  final VoidCallback? onRetry;
  final bool showCopyButton;

  const EnhancedErrorState({
    super.key,
    required this.title,
    required this.message,
    this.technicalDetails,
    this.onRetry,
    this.showCopyButton = true,
  });

  @override
  State<EnhancedErrorState> createState() => _EnhancedErrorStateState();
}

class _EnhancedErrorStateState extends State<EnhancedErrorState> {
  bool _showDetails = false;
  bool _copied = false;

  void _copyToClipboard() async {
    final buffer = StringBuffer();
    buffer.writeln('Error: ${widget.title}');
    buffer.writeln('Message: ${widget.message}');
    if (widget.technicalDetails != null) {
      buffer.writeln('\nTechnical Details:');
      buffer.writeln(widget.technicalDetails);
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    
    setState(() => _copied = true);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                PhosphorIconsRegular.check,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text('Error details copied to clipboard'),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.warningCircle,
                size: 48,
                color: AppColors.error,
              ),
            ),
            
            const SizedBox(height: AppDimensions.space24),
            
            // Title
            Text(
              widget.title,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppDimensions.space12),
            
            // Message Card
            Container(
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.info,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Error Details',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    widget.message,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Technical Details (Expandable)
            if (widget.technicalDetails != null) ...[
              const SizedBox(height: AppDimensions.space12),
              InkWell(
                onTap: () => setState(() => _showDetails = !_showDetails),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space12,
                    vertical: AppDimensions.space8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showDetails
                            ? PhosphorIconsRegular.caretUp
                            : PhosphorIconsRegular.caretDown,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _showDetails ? 'Hide Technical Details' : 'Show Technical Details',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (_showDetails) ...[
                const SizedBox(height: AppDimensions.space12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: SelectableText(
                    widget.technicalDetails!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ],
            
            const SizedBox(height: AppDimensions.space24),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Copy Button
                if (widget.showCopyButton)
                  OutlinedButton.icon(
                    onPressed: _copied ? null : _copyToClipboard,
                    icon: Icon(
                      _copied
                          ? PhosphorIconsRegular.check
                          : PhosphorIconsRegular.copy,
                      size: 18,
                    ),
                    label: Text(_copied ? 'Copied!' : 'Copy Error'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _copied ? AppColors.success : AppColors.primary,
                      side: BorderSide(
                        color: _copied ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ),
                
                // Retry Button
                if (widget.onRetry != null) ...[
                  if (widget.showCopyButton) const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: widget.onRetry,
                    icon: Icon(
                      PhosphorIconsRegular.arrowClockwise,
                      size: 18,
                    ),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
