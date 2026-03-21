import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class BreadcrumbNav extends StatelessWidget {
  final String currentPath;
  final Function(String) onNavigate;

  const BreadcrumbNav({
    super.key,
    required this.currentPath,
    required this.onNavigate,
  });

  List<String> _getPathSegments() {
    if (currentPath.isEmpty || currentPath == '/') {
      return ['Root'];
    }

    final segments = currentPath.split('/').where((s) => s.isNotEmpty).toList();
    return ['Root', ...segments];
  }

  String _getPathForIndex(int index) {
    if (index == 0) return '/';

    final segments = currentPath.split('/').where((s) => s.isNotEmpty).toList();
    return '/' + segments.sublist(0, index).join('/');
  }

  @override
  Widget build(BuildContext context) {
    final segments = _getPathSegments();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < segments.length; i++) ...[
              InkWell(
                onTap: () => onNavigate(_getPathForIndex(i)),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    segments[i],
                    style: AppTypography.body.copyWith(
                      color: i == segments.length - 1
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: i == segments.length - 1
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
              if (i < segments.length - 1)
                Icon(
                  PhosphorIconsRegular.caretRight,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
