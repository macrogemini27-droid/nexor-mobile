import 'package:drift/drift.dart';
import 'sessions_table.dart';

@DataClassName('MessageEntity')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()
      .named('session_id')
      .references(Sessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text()(); // 'user' or 'assistant'
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
