import 'package:drift/drift.dart';
import 'messages_table.dart';

@DataClassName('MessagePartEntity')
class MessageParts extends Table {
  TextColumn get id => text()();
  TextColumn get messageId => text()
      .named('message_id')
      .references(Messages, #id, onDelete: KeyAction.cascade)();
  TextColumn get type =>
      text()(); // 'text', 'tool_call', 'tool_result', 'reasoning'
  TextColumn get content => text()();
  TextColumn get metadata => text().nullable()(); // JSON string

  @override
  Set<Column> get primaryKey => {id};
}
