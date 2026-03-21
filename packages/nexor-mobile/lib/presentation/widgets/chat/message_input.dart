import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/colors.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback? onAttach;
  final bool enabled;

  const MessageInput({
    super.key,
    required this.onSend,
    this.onAttach,
    this.enabled = true,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
    });
  }

  void _handleSend() {
    if (_hasText && widget.enabled) {
      final text = _controller.text.trim();
      _controller.clear();
      widget.onSend(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.onAttach != null)
              IconButton(
                onPressed: widget.enabled ? widget.onAttach : null,
                icon: Icon(
                  PhosphorIconsRegular.paperclip,
                  color: widget.enabled
                      ? AppColors.textSecondary
                      : AppColors.textSecondary.withOpacity(0.5),
                ),
              ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 120,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _hasText && widget.enabled
                    ? AppColors.primary
                    : AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _hasText && widget.enabled ? _handleSend : null,
                icon: Icon(
                  _hasText
                      ? PhosphorIcons.paperPlaneTilt(
                          PhosphorIconsStyle.fill,
                        )
                      : PhosphorIconsRegular.microphone,
                  color: _hasText && widget.enabled
                      ? Colors.white
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
