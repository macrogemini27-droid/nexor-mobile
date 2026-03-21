import 'package:equatable/equatable.dart';

enum AIStreamEventType {
  messageStart,
  contentBlockStart,
  contentBlockDelta,
  contentBlockStop,
  messageStop,
  error,
}

abstract class AIStreamEvent extends Equatable {
  final AIStreamEventType type;

  const AIStreamEvent(this.type);

  @override
  List<Object?> get props => [type];
}

class MessageStartEvent extends AIStreamEvent {
  final String messageId;
  final Map<String, dynamic> metadata;

  const MessageStartEvent({
    required this.messageId,
    this.metadata = const {},
  }) : super(AIStreamEventType.messageStart);

  @override
  List<Object?> get props => [type, messageId, metadata];
}

class ContentBlockStartEvent extends AIStreamEvent {
  final int index;
  final String blockType;
  final Map<String, dynamic> data;

  const ContentBlockStartEvent({
    required this.index,
    required this.blockType,
    this.data = const {},
  }) : super(AIStreamEventType.contentBlockStart);

  @override
  List<Object?> get props => [type, index, blockType, data];
}

class ContentBlockDeltaEvent extends AIStreamEvent {
  final int index;
  final String deltaType;
  final String? text;
  final Map<String, dynamic>? partialJson;

  const ContentBlockDeltaEvent({
    required this.index,
    required this.deltaType,
    this.text,
    this.partialJson,
  }) : super(AIStreamEventType.contentBlockDelta);

  @override
  List<Object?> get props => [type, index, deltaType, text, partialJson];
}

class ContentBlockStopEvent extends AIStreamEvent {
  final int index;

  const ContentBlockStopEvent({
    required this.index,
  }) : super(AIStreamEventType.contentBlockStop);

  @override
  List<Object?> get props => [type, index];
}

class MessageStopEvent extends AIStreamEvent {
  final String stopReason;
  final Map<String, dynamic> usage;

  const MessageStopEvent({
    required this.stopReason,
    this.usage = const {},
  }) : super(AIStreamEventType.messageStop);

  @override
  List<Object?> get props => [type, stopReason, usage];
}

class ErrorEvent extends AIStreamEvent {
  final String error;
  final String? message;

  const ErrorEvent({
    required this.error,
    this.message,
  }) : super(AIStreamEventType.error);

  @override
  List<Object?> get props => [type, error, message];
}
