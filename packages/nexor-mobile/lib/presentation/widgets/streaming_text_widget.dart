import 'package:flutter/material.dart';

class StreamingTextWidget extends StatefulWidget {
  final String text;
  final bool isStreaming;
  final TextStyle? style;

  const StreamingTextWidget({
    super.key,
    required this.text,
    this.isStreaming = false,
    this.style,
  });

  @override
  State<StreamingTextWidget> createState() => _StreamingTextWidgetState();
}

class _StreamingTextWidgetState extends State<StreamingTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    if (widget.isStreaming) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(StreamingTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStreaming != oldWidget.isStreaming) {
      if (widget.isStreaming) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.text,
            style: widget.style,
          ),
        ),
        if (widget.isStreaming)
          FadeTransition(
            opacity: _controller,
            child: Container(
              width: 8,
              height: 16,
              margin: const EdgeInsets.only(left: 4, top: 2),
              decoration: BoxDecoration(
                color: widget.style?.color ?? Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }
}
