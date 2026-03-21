import 'package:flutter/material.dart';

class ToolExecutionIndicatorWidget extends StatelessWidget {
  final String toolName;
  final bool isExecuting;
  final String? result;

  const ToolExecutionIndicatorWidget({
    super.key,
    required this.toolName,
    this.isExecuting = false,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (isExecuting)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              result != null ? Icons.check_circle : Icons.build,
              size: 16,
              color: result != null ? Colors.green : Colors.blue,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.terminal, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      toolName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (isExecuting)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Executing...',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                if (result != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      result!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
