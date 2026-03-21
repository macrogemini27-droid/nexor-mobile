import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/theme/typography.dart';
import '../../widgets/common/nexor_app_bar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/enhanced_error_state.dart';
import '../../widgets/file/file_item.dart';
import '../../widgets/file/file_list_shimmer.dart';
import '../../widgets/file/breadcrumb_nav.dart';
import '../../widgets/file/file_info_bar.dart';
import '../../widgets/file/sort_filter_sheet.dart';
import '../../../domain/entities/file_node.dart';
import 'providers/files_provider.dart';

class FileBrowserScreen extends ConsumerStatefulWidget {
  final String serverId;
  final String? initialPath;

  const FileBrowserScreen({
    super.key,
    required this.serverId,
    this.initialPath,
  });

  @override
  ConsumerState<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends ConsumerState<FileBrowserScreen> {
  late String _currentPath;
  SortOption _sortOption = SortOption.nameAsc;
  Set<FilterOption> _filters = {};

  @override
  void initState() {
    super.initState();
    _currentPath = widget.initialPath ?? '/';
  }

  void _navigateToPath(String path) {
    setState(() => _currentPath = path);
  }

  void _openFile(FileNode file) {
    if (file.isDirectory) {
      _navigateToPath(file.path);
    } else {
      context.push(
        '/files/viewer?serverId=${widget.serverId}&path=${Uri.encodeComponent(file.path)}',
      );
    }
  }

  void _openSearch() {
    context.push('/files/search?serverId=${widget.serverId}');
  }

  void _openSortFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SortFilterSheet(
        currentSort: _sortOption,
        currentFilters: _filters,
        onSortChanged: (sort) {
          setState(() => _sortOption = sort);
        },
        onFiltersChanged: (filters) {
          setState(() => _filters = filters);
        },
      ),
    );
  }

  List<FileNode> _applySortAndFilter(List<FileNode> files) {
    var filtered = files.toList();

    // Apply filters
    if (_filters.contains(FilterOption.filesOnly)) {
      filtered = filtered.where((f) => !f.isDirectory).toList();
    }
    if (_filters.contains(FilterOption.foldersOnly)) {
      filtered = filtered.where((f) => f.isDirectory).toList();
    }
    if (!_filters.contains(FilterOption.showHidden)) {
      filtered = filtered.where((f) => !f.isHidden).toList();
    }

    // Apply sort
    switch (_sortOption) {
      case SortOption.nameAsc:
        filtered.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case SortOption.nameDesc:
        filtered.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
      case SortOption.dateNewest:
        filtered.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return b.modifiedAt.compareTo(a.modifiedAt);
        });
        break;
      case SortOption.dateOldest:
        filtered.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return a.modifiedAt.compareTo(b.modifiedAt);
        });
        break;
      case SortOption.sizeLargest:
        filtered.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return b.size.compareTo(a.size);
        });
        break;
      case SortOption.sizeSmallest:
        filtered.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return a.size.compareTo(b.size);
        });
        break;
      case SortOption.type:
        filtered.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return a.extension.compareTo(b.extension);
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(filesProvider(widget.serverId, _currentPath));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            PhosphorIconsRegular.caretLeft,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          'Files',
          style: AppTypography.h2,
        ),
        actions: [
          IconButton(
            onPressed: _openSearch,
            icon: Icon(
              PhosphorIconsRegular.magnifyingGlass,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Search',
          ),
          IconButton(
            onPressed: _openSortFilter,
            icon: Icon(
              PhosphorIconsRegular.funnelSimple,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Sort & Filter',
          ),
          IconButton(
            onPressed: () {
              ref.invalidate(filesProvider(widget.serverId, _currentPath));
            },
            icon: Icon(
              PhosphorIconsRegular.arrowClockwise,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          BreadcrumbNav(
            currentPath: _currentPath,
            onNavigate: _navigateToPath,
          ),
          Expanded(
            child: filesAsync.when(
              data: (files) {
                if (files.isEmpty) {
                  return EmptyState(
                    icon: PhosphorIconsRegular.folder,
                    title: 'No files',
                    message: 'This directory is empty',
                  );
                }

                final filteredFiles = _applySortAndFilter(files);

                if (filteredFiles.isEmpty) {
                  return EmptyState(
                    icon: PhosphorIconsRegular.funnel,
                    title: 'No results',
                    message: 'No files match your filters',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                        filesProvider(widget.serverId, _currentPath));
                  },
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredFiles.length,
                    itemBuilder: (context, index) {
                      final file = filteredFiles[index];
                      return FileItem(
                        file: file,
                        onTap: () => _openFile(file),
                        index: index,
                        onDelete: file.isDirectory ? null : () {
                          // FUTURE: Implement file deletion
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Delete feature coming soon'),
                            ),
                          );
                        },
                        onRename: file.isDirectory ? null : () {
                          // FUTURE: Implement file rename
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Rename feature coming soon'),
                            ),
                          );
                        },
                        onShare: file.isDirectory ? null : () {
                          // FUTURE: Implement file sharing
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Share feature coming soon'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const FileListShimmer(),
              error: (error, stack) {
                // Extract user-friendly message and technical details
                final errorStr = error.toString();
                String userMessage = errorStr;

                // Parse Exception format: "Exception: message"
                if (errorStr.startsWith('Exception: ')) {
                  userMessage = errorStr.substring('Exception: '.length);
                }

                // Add stack trace as technical details
                final technicalDetails =
                    'Error: $errorStr\n\nStack Trace:\n$stack';

                return EnhancedErrorState(
                  title: 'Failed to Load Files',
                  message: userMessage,
                  technicalDetails: technicalDetails,
                  onRetry: () {
                    ref.invalidate(
                        filesProvider(widget.serverId, _currentPath));
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // FUTURE: Open current directory in Nexor chat
          // This will create a new chat session with the current directory as context
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening in Nexor...'),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: Icon(
          PhosphorIconsRegular.chatCircle,
          color: Colors.white,
        ),
        label: const Text(
          'Open in Nexor',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
