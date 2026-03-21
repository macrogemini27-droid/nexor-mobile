import 'package:drift/drift.dart';

@DataClassName('SessionEntity')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get serverId => text().named('server_id').nullable()();
  TextColumn get directory => text().nullable()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
