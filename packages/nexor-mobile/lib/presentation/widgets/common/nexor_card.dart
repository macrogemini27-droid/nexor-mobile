import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/colors.dart';
import '../../../core/theme/dimensions.dart';

/// Card with glassmorphism effect
class NexorCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool enableGlass;

  const NexorCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.enableGlass = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: enableGlass ? AppColors.glass : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: enableGlass
            ? Border.all(
                color: AppColors.glassBorder,
                width: AppDimensions.borderWidth,
              )
            : null,
      ),
      child: enableGlass
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: child,
              ),
            )
          : child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: content,
        ),
      );
    }

    return content;
  }
}
