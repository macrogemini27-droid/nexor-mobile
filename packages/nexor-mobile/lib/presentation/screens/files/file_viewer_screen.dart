import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/file_type_detector.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/enhanced_error_state.dart';
import '../../widgets/file/code_block.dart';
import '../../widgets/file/file_info_bar.dart';
import 'providers/files_provider.dart';

class FileViewerScreen extends ConsumerStatefulWidget {
  final String serverId;
  final String filePath;

  const FileViewerScreen({
    super.key,
    required this.serverId,
    required this.filePath,
  });

  @override
  ConsumerState<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends ConsumerState<FileViewerScreen> {
  double _fontSize = 14;
  bool _showLineNumbers = true;
  bool _wrapLines = false;
  bool _forceLoadLargeFile = false;

  void _increaseFontSize() {
    if (_fontSize < 24) {
      setState(() => _fontSize += 2);
    }
  }

  void _decreaseFontSize() {
    if (_fontSize > 10) {
      setState(() => _fontSize -= 2);
    }
  }

  void _toggleLineNumbers() {
    setState(() => _showLineNumbers = !_showLineNumbers);
  }

  void _toggleWrapLines() {
    setState(() => _wrapLines = !_wrapLines);
  }

  Future<void> _copyContent(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Content copied to clipboard'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _shareContent(String content) async {
    await Share.share(
      content,
      subject: widget.filePath.split('/').last,
    );
  }

  void _openInNexor() {
    // FUTURE: Navigate to chat with file context
    // This will open a new chat session with the current file as context
    // allowing the AI to help with this specific file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening in Nexor chat...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileContentAsync = ref.watch(
      fileContentProvider(widget.serverId, widget.filePath),
    );

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.filePath.split('/').last,
              style: AppTypography.h3,
            ),
            Text(
              widget.filePath,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _toggleLineNumbers,
            icon: Icon(
              _showLineNumbers
                  ? PhosphorIconsFill.listNumbers
                  : PhosphorIconsRegular.listNumbers,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Toggle line numbers',
          ),
          IconButton(
            onPressed: _toggleWrapLines,
            icon: Icon(
              _wrapLines
                  ? PhosphorIconsFill.textAlignLeft
                  : PhosphorIconsRegular.textAlignLeft,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Toggle line wrap',
          ),
          PopupMenuButton<String>(
            icon: Icon(
              PhosphorIconsRegular.dotsThreeVertical,
              color: AppColors.textPrimary,
            ),
            color: AppColors.surface,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.copy,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 12),
                    Text('Copy content', style: AppTypography.body),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.shareNetwork,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 12),
                    Text('Share', style: AppTypography.body),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'nexor',
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.chatCircle,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Open in Nexor',
                      style: AppTypography.body.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              fileContentAsync.whenData((content) {
                switch (value) {
                  case 'copy':
                    _copyContent(content.content);
                    break;
                  case 'share':
                    _shareContent(content.content);
                    break;
                  case 'nexor':
                    _openInNexor();
                    break;
                }
              });
            },
          ),
        ],
      ),
      body: fileContentAsync.when(
        data: (fileContent) {
          if (fileContent.isLarge && !_forceLoadLargeFile) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIconsRegular.warningCircle,
                      size: 64,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Large File',
                      style: AppTypography.h2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This file is larger than 1MB and may take time to load.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Force load anyway - invalidate provider to reload file
                        setState(() {
                          _forceLoadLargeFile = true;
                        });
                        // Trigger reload
                        ref.invalidate(
                          fileContentProvider(widget.serverId, widget.filePath),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Load Anyway'),
                    ),
                  ],
                ),
              ),
            );
          }

          final language = FileTypeDetector.getLanguage(widget.filePath);

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
                    IconButton(
                      onPressed: _decreaseFontSize,
                      icon: Icon(
                        PhosphorIconsRegular.minus,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      tooltip: 'Decrease font size',
                    ),
                    Text(
                      '${_fontSize.toInt()}px',
                      style: AppTypography.body,
                    ),
                    IconButton(
                      onPressed: _increaseFontSize,
                      icon: Icon(
                        PhosphorIconsRegular.plus,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      tooltip: 'Increase font size',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: CodeBlock(
                    code: fileContent.content,
                    language: language,
                    fontSize: _fontSize,
                    showLineNumbers: _showLineNumbers,
                    wrapLines: _wrapLines,
                  ),
                ),
              ),
              FileInfoBar(
                lines: fileContent.lines,
                size: fileContent.formattedSize,
                language: language,
              ),
            ],
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) {
          final errorStr = error.toString();
          String userMessage = errorStr;

          if (errorStr.startsWith('Exception: ')) {
            userMessage = errorStr.substring('Exception: '.length);
          }

          final technicalDetails = 'Error: $errorStr\n\nStack Trace:\n$stack';

          return EnhancedErrorState(
            title: 'Failed to Load File',
            message: userMessage,
            technicalDetails: technicalDetails,
            onRetry: () => ref.invalidate(
              fileContentProvider(widget.serverId, widget.filePath),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}
