import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../domain/entities/message.dart';
import '../../../core/theme/colors.dart';
import 'code_block.dart';
import 'typing_indicator.dart';

class AIMessage extends StatelessWidget {
  final Message message;
  final bool isStreaming;
  final VoidCallback? onRegenerate;

  const AIMessage({
    super.key,
    required this.message,
    this.isStreaming = false,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIconsRegular.robot,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.parts != null && message.parts!.isNotEmpty)
                        ..._buildParts(context)
                      else
                        MarkdownBody(
                          data: message.content,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(fontSize: 15),
                            code: TextStyle(
                              backgroundColor: AppColors.background,
                              fontFamily: 'JetBrainsMono',
                            ),
                          ),
                        ),
                      if (isStreaming) ...[
                        const SizedBox(height: 8),
                        const TypingIndicator(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      timeago.format(message.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: message.content),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIconsRegular.copy,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Copy',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onRegenerate != null && !isStreaming) ...[
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: onRegenerate,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIconsRegular.arrowClockwise,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Regenerate',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  List<Widget> _buildParts(BuildContext context) {
    final widgets = <Widget>[];

    for (var i = 0; i < message.parts!.length; i++) {
      final part = message.parts![i];

      if (i > 0) {
        widgets.add(const SizedBox(height: 12));
      }

      if (part.isCode) {
        widgets.add(
          CodeBlock(
            code: part.content,
            language: part.language ?? 'plaintext',
            fileName: part.fileName,
          ),
        );
      } else if (part.isText) {
        widgets.add(
          MarkdownBody(
            data: part.content,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 15),
              code: TextStyle(
                backgroundColor: AppColors.background,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}
