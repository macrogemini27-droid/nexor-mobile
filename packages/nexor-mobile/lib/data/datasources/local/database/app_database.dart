import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/server/server_model.dart';
import '../../../models/file/file_node_model.dart';
import '../../../models/session/session_model.dart';
import '../../../models/session/message_model.dart';

/// Hive database setup and management for server/local data
class HiveDatabase {
  static const String serversBoxName = 'servers';
  static const String sessionsBoxName = 'sessions';
  static const String messagesBoxName = 'messages';

  /// Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ServerModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FileNodeModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SessionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(MessageModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(MessagePartModelAdapter());
    }
    
    // Open boxes
    await Hive.openBox<ServerModel>(serversBoxName);
    await Hive.openBox<SessionModel>(sessionsBoxName);
    await Hive.openBox<MessageModel>(messagesBoxName);
  }

  /// Get servers box with safety check
  static Box<ServerModel> get serversBox {
    if (!Hive.isBoxOpen(serversBoxName)) {
      throw StateError('Servers box is not open. Call HiveDatabase.init() first.');
    }
    return Hive.box<ServerModel>(serversBoxName);
  }

  /// Get sessions box with safety check
  static Box<SessionModel> get sessionsBox {
    if (!Hive.isBoxOpen(sessionsBoxName)) {
      throw StateError('Sessions box is not open. Call HiveDatabase.init() first.');
    }
    return Hive.box<SessionModel>(sessionsBoxName);
  }

  /// Get messages box with safety check
  static Box<MessageModel> get messagesBox {
    if (!Hive.isBoxOpen(messagesBoxName)) {
      throw StateError('Messages box is not open. Call HiveDatabase.init() first.');
    }
    return Hive.box<MessageModel>(messagesBoxName);
  }

  /// Close all boxes
  static Future<void> close() async {
    await Hive.close();
  }
}
