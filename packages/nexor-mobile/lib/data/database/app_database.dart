import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/sessions_table.dart';
import 'tables/messages_table.dart';
import 'tables/message_parts_table.dart';
import 'daos/session_dao.dart';
import 'daos/message_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Sessions, Messages, MessageParts],
  daos: [SessionDao, MessageDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations here
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'opencode.db'));
    return NativeDatabase(file);
  });
}
