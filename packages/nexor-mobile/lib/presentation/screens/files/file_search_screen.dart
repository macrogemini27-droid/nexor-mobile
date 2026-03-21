import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../domain/entities/file_node.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/file/file_item.dart';
import 'providers/file_search_provider.dart';

class FileSearchScreen extends ConsumerStatefulWidget {
  final String serverId;

  const FileSearchScreen({
    super.key,
    required this.serverId,
  });

  @override
  ConsumerState<FileSearchScreen> createState() => _FileSearchScreenState();
}

class _FileSearchScreenState extends ConsumerState<FileSearchScreen> {
  final _searchController = TextEditingController();
  SearchType _searchType = SearchType.fileName;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value);
  }

  void _toggleSearchType() {
    setState(() {
      _searchType = _searchType == SearchType.fileName
          ? SearchType.content
          : SearchType.fileName;
    });
  }

  void _openFile(FileNode file) {
    if (file.isDirectory) {
      context.push(
        '/files?serverId=${widget.serverId}&path=${Uri.encodeComponent(file.path)}',
      );
    } else {
      context.push(
        '/files/viewer?serverId=${widget.serverId}&path=${Uri.encodeComponent(file.path)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = _query.isEmpty
        ? const AsyncValue<List<FileNode>>.data([])
        : ref.watch(fileSearchProvider(widget.serverId, _query, _searchType));

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
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: AppTypography.body,
          decoration: InputDecoration(
            hintText: _searchType == SearchType.fileName
                ? 'Search files...'
                : 'Search content...',
            hintStyle: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          IconButton(
            onPressed: _toggleSearchType,
            icon: Icon(
              _searchType == SearchType.fileName
                  ? PhosphorIconsRegular.file
                  : PhosphorIconsRegular.textAlignLeft,
              color: AppColors.primary,
            ),
            tooltip: _searchType == SearchType.fileName
                ? 'Search by filename'
                : 'Search in content',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
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
            child: Row(
              children: [
                Icon(
                  PhosphorIconsRegular.info,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _searchType == SearchType.fileName
                        ? 'Searching by filename'
                        : 'Searching in file contents (supports regex)',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: searchAsync.when(
              data: (results) {
                if (_query.isEmpty) {
                  return EmptyState(
                    icon: PhosphorIconsRegular.magnifyingGlass,
                    title: 'Search files',
                    message: _searchType == SearchType.fileName
                        ? 'Enter a filename to search'
                        : 'Enter a pattern to search in file contents',
                  );
                }

                if (results.isEmpty) {
                  return EmptyState(
                    icon: PhosphorIconsRegular.fileX,
                    title: 'No results',
                    message: 'No files found matching your search',
                  );
                }

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${results.length} result${results.length == 1 ? '' : 's'}',
                            style: AppTypography.bodyBold.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: results.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: AppColors.border,
                          indent: 52,
                        ),
                        itemBuilder: (context, index) {
                          final file = results[index];
                          return FileItem(
                            file: file,
                            onTap: () => _openFile(file),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIconsRegular.warningCircle,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Search failed',
                        style: AppTypography.h2,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
