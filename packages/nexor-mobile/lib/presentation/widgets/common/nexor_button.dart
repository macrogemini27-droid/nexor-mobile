import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/animations.dart';

enum NexorButtonVariant {
  primary,
  secondary,
  danger,
  ghost,
}

enum NexorButtonSize {
  small,
  medium,
  large,
}

/// Custom button widget with variants
class NexorButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final NexorButtonVariant variant;
  final NexorButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  const NexorButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = NexorButtonVariant.primary,
    this.size = NexorButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
  });

  @override
  State<NexorButton> createState() => _NexorButtonState();
}

class _NexorButtonState extends State<NexorButton> {
  bool _isPressed = false;

  Color get _backgroundColor {
    if (widget.onPressed == null) {
      return AppColors.surface;
    }

    switch (widget.variant) {
      case NexorButtonVariant.primary:
        return _isPressed ? AppColors.primaryDark : AppColors.primary;
      case NexorButtonVariant.secondary:
        return _isPressed ? AppColors.surfaceElevated : AppColors.surface;
      case NexorButtonVariant.danger:
        return _isPressed ? AppColors.error.withOpacity(0.8) : AppColors.error;
      case NexorButtonVariant.ghost:
        return _isPressed ? AppColors.overlay : Colors.transparent;
    }
  }

  Color get _foregroundColor {
    if (widget.onPressed == null) {
      return AppColors.textDisabled;
    }

    switch (widget.variant) {
      case NexorButtonVariant.primary:
      case NexorButtonVariant.danger:
        return Colors.white;
      case NexorButtonVariant.secondary:
      case NexorButtonVariant.ghost:
        return AppColors.textPrimary;
    }
  }

  BorderSide? get _borderSide {
    if (widget.variant == NexorButtonVariant.secondary) {
      return const BorderSide(color: AppColors.border);
    }
    return null;
  }

  double get _height {
    switch (widget.size) {
      case NexorButtonSize.small:
        return AppDimensions.buttonHeightSmall;
      case NexorButtonSize.medium:
        return AppDimensions.buttonHeightMedium;
      case NexorButtonSize.large:
        return AppDimensions.buttonHeightLarge;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case NexorButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: AppDimensions.space16);
      case NexorButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: AppDimensions.space24);
      case NexorButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: AppDimensions.space32);
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case NexorButtonSize.small:
        return AppTypography.buttonSmall;
      case NexorButtonSize.medium:
      case NexorButtonSize.large:
        return AppTypography.button;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onPressed != null && !widget.isLoading
          ? (_) => setState(() => _isPressed = false)
          : null,
      onTapCancel: widget.onPressed != null && !widget.isLoading
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        curve: AppAnimations.easeInOut,
        height: _height,
        width: widget.isFullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: _borderSide != null ? Border.fromBorderSide(_borderSide!) : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed != null && !widget.isLoading
                ? widget.onPressed
                : null,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            child: Padding(
              padding: _padding,
              child: Row(
                mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(_foregroundColor),
                      ),
                    )
                  else if (widget.icon != null)
                    Icon(
                      widget.icon,
                      size: AppDimensions.iconMedium,
                      color: _foregroundColor,
                    ),
                  if ((widget.isLoading || widget.icon != null) && widget.text.isNotEmpty)
                    const SizedBox(width: AppDimensions.space8),
                  if (widget.text.isNotEmpty)
                    Text(
                      widget.text,
                      style: _textStyle.copyWith(color: _foregroundColor),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
