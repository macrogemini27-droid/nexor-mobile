import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

enum SortOption {
  nameAsc,
  nameDesc,
  dateNewest,
  dateOldest,
  sizeLargest,
  sizeSmallest,
  type,
}

enum FilterOption {
  all,
  filesOnly,
  foldersOnly,
  showHidden,
}

class SortFilterSheet extends StatefulWidget {
  final SortOption currentSort;
  final Set<FilterOption> currentFilters;
  final Function(SortOption) onSortChanged;
  final Function(Set<FilterOption>) onFiltersChanged;

  const SortFilterSheet({
    super.key,
    required this.currentSort,
    required this.currentFilters,
    required this.onSortChanged,
    required this.onFiltersChanged,
  });

  @override
  State<SortFilterSheet> createState() => _SortFilterSheetState();
}

class _SortFilterSheetState extends State<SortFilterSheet> {
  late SortOption _selectedSort;
  late Set<FilterOption> _selectedFilters;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
    _selectedFilters = Set.from(widget.currentFilters);
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
        return 'Name (A-Z)';
      case SortOption.nameDesc:
        return 'Name (Z-A)';
      case SortOption.dateNewest:
        return 'Date (Newest first)';
      case SortOption.dateOldest:
        return 'Date (Oldest first)';
      case SortOption.sizeLargest:
        return 'Size (Largest first)';
      case SortOption.sizeSmallest:
        return 'Size (Smallest first)';
      case SortOption.type:
        return 'Type';
    }
  }

  String _getFilterLabel(FilterOption option) {
    switch (option) {
      case FilterOption.all:
        return 'All files';
      case FilterOption.filesOnly:
        return 'Files only';
      case FilterOption.foldersOnly:
        return 'Folders only';
      case FilterOption.showHidden:
        return 'Show hidden files';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sort & Filter',
                style: AppTypography.h3,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  PhosphorIconsRegular.x,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Sort by',
            style: AppTypography.bodyBold.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...SortOption.values.map((option) {
            return RadioListTile<SortOption>(
              value: option,
              groupValue: _selectedSort,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSort = value);
                  widget.onSortChanged(value);
                }
              },
              title: Text(
                _getSortLabel(option),
                style: AppTypography.body,
              ),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            );
          }),
          const SizedBox(height: 24),
          Text(
            'Filter',
            style: AppTypography.bodyBold.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...FilterOption.values.map((option) {
            if (option == FilterOption.all) return const SizedBox.shrink();

            return CheckboxListTile(
              value: _selectedFilters.contains(option),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedFilters.add(option);
                  } else {
                    _selectedFilters.remove(option);
                  }
                });
                widget.onFiltersChanged(_selectedFilters);
              },
              title: Text(
                _getFilterLabel(option),
                style: AppTypography.body,
              ),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
