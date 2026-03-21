import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/datasources/local/database/app_database.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database for server management
  await HiveDatabase.init();

  runApp(
    const ProviderScope(
      child: NexorApp(),
    ),
  );
}
