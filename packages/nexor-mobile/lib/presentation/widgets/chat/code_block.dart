import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CodeBlock extends StatelessWidget {
  final String code;
  final String language;
  final String? fileName;

  const CodeBlock({
    super.key,
    required this.code,
    required this.language,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF252526),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsRegular.code,
                  size: 14,
                  color: const Color(0xFF858585),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fileName ?? language,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF858585),
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      PhosphorIconsRegular.copy,
                      size: 14,
                      color: const Color(0xFF858585),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: HighlightView(
              code,
              language: language,
              theme: vs2015Theme,
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
