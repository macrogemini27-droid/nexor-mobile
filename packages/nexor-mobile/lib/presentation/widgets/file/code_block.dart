import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import '../../../core/theme/colors.dart';

class CodeBlock extends StatelessWidget {
  final String code;
  final String language;
  final double fontSize;
  final bool showLineNumbers;
  final bool wrapLines;

  const CodeBlock({
    super.key,
    required this.code,
    required this.language,
    this.fontSize = 14,
    this.showLineNumbers = true,
    this.wrapLines = false,
  });

  @override
  Widget build(BuildContext context) {
    final lines = code.split('\n');
    final lineNumberWidth = (lines.length.toString().length * 10.0) + 20;

    return Container(
      color: const Color(0xFF1E1E1E),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showLineNumbers)
              Container(
                width: lineNumberWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF252526),
                  border: Border(
                    right: BorderSide(
                      color: AppColors.border.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    lines.length,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: fontSize,
                          color: const Color(0xFF858585),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Flexible(
              child: HighlightView(
                code,
                language: language,
                theme: vs2015Theme,
                padding: const EdgeInsets.all(16),
                textStyle: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: fontSize,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
