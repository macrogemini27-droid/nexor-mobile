import 'package:equatable/equatable.dart';

class CommandResult extends Equatable {
  final String stdout;
  final String stderr;
  final int exitCode;
  final Duration executionTime;

  const CommandResult({
    required this.stdout,
    required this.stderr,
    required this.exitCode,
    required this.executionTime,
  });

  bool get isSuccess => exitCode == 0;
  bool get hasError => exitCode != 0 || stderr.isNotEmpty;

  String get output => stdout;
  String get error => stderr;

  @override
  List<Object?> get props => [stdout, stderr, exitCode, executionTime];

  @override
  String toString() {
    return 'CommandResult(exitCode: $exitCode, stdout: ${stdout.length} chars, stderr: ${stderr.length} chars, time: ${executionTime.inMilliseconds}ms)';
  }
}
