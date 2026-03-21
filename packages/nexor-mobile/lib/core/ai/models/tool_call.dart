import 'package:equatable/equatable.dart';

class ToolCall extends Equatable {
  final String id;
  final String name;
  final Map<String, dynamic> input;
  final DateTime timestamp;

  const ToolCall({
    required this.id,
    required this.name,
    required this.input,
    required this.timestamp,
  });

  factory ToolCall.fromJson(Map<String, dynamic> json) {
    return ToolCall(
      id: json['id'] as String,
      name: json['name'] as String,
      input: json['input'] as Map<String, dynamic>,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'input': input,
    };
  }

  @override
  List<Object?> get props => [id, name, input, timestamp];

  @override
  String toString() {
    return 'ToolCall(id: $id, name: $name, input: $input)';
  }
}
