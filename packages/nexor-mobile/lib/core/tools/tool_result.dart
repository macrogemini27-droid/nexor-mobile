import 'package:equatable/equatable.dart';

class ToolResult extends Equatable {
  final String title;
  final String output;
  final int? exitCode;
  final Map<String, dynamic> metadata;
  final bool isError;

  const ToolResult({
    required this.title,
    required this.output,
    this.exitCode,
    this.metadata = const {},
    this.isError = false,
  });

  factory ToolResult.success({
    required String title,
    required String output,
    Map<String, dynamic> metadata = const {},
  }) {
    return ToolResult(
      title: title,
      output: output,
      metadata: metadata,
      isError: false,
    );
  }

  factory ToolResult.error({
    required String title,
    required String output,
    int? exitCode,
    Map<String, dynamic> metadata = const {},
  }) {
    return ToolResult(
      title: title,
      output: output,
      exitCode: exitCode,
      metadata: metadata,
      isError: true,
    );
  }

  bool get isSuccess => !isError;

  ToolResult copyWith({
    String? title,
    String? output,
    int? exitCode,
    Map<String, dynamic>? metadata,
    bool? isError,
  }) {
    return ToolResult(
      title: title ?? this.title,
      output: output ?? this.output,
      exitCode: exitCode ?? this.exitCode,
      metadata: metadata ?? this.metadata,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object?> get props => [title, output, exitCode, metadata, isError];

  @override
  String toString() {
    return 'ToolResult(title: $title, isError: $isError, exitCode: $exitCode)';
  }
}
