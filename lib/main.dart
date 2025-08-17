import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'app.dart';
import 'data/db/database.dart';
import 'services/notification_service.dart';
import 'services/deep_link_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize database
  final database = await _initializeDatabase();
  
  // Initialize services
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  final deepLinkService = DeepLinkService();
  await deepLinkService.initialize();
  
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: const ExamCoachApp(),
    ),
  );
}

Future<AppDatabase> _initializeDatabase() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'examcoach.db'));
  
  return AppDatabase(NativeDatabase.createInBackground(file));
}

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database must be overridden');
});
