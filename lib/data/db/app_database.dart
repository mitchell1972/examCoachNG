import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'schema.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Packs,
    Questions,
    Sessions,
    Attempts,
    TopicStats,
    Entitlements,
    SyncQueue,
    StudyReminders,
    UserSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      
      // Create indexes for better performance
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_questions_pack_id ON questions(pack_id);
      ''');
      
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_attempts_session_id ON attempts(session_id);
      ''');
      
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_attempts_question_id ON attempts(question_id);
      ''');
      
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_sessions_subject ON sessions(subject);
      ''');
      
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_sync_queue_entity ON sync_queue(entity);
      ''');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Handle schema migrations in future versions
      if (from < 2) {
        // Add migration logic here
      }
    },
  );

  // Pack operations
  Future<List<Pack>> getAllPacks() => select(packs).get();
  
  Future<List<Pack>> getActivePacksBySubject(String subject) =>
      (select(packs)..where((p) => p.subject.equals(subject) & p.isActive.equals(true))).get();
  
  Future<void> insertPack(PacksCompanion pack) =>
      into(packs).insert(pack, mode: InsertMode.insertOrReplace);
  
  Future<void> deactivatePack(String packId) =>
      (update(packs)..where((p) => p.id.equals(packId))).write(const PacksCompanion(isActive: Value(false)));

  // Question operations
  Future<List<Question>> getQuestionsByPackId(String packId) =>
      (select(questions)..where((q) => q.packId.equals(packId) & q.isActive.equals(true))).get();
  
  Future<List<Question>> getQuestionsBySubjectAndTopic(String subject, String? topic) {
    final query = select(questions).join([
      innerJoin(packs, packs.id.equalsExp(questions.packId))
    ])..where(packs.subject.equals(subject) & packs.isActive.equals(true) & questions.isActive.equals(true));
    
    if (topic != null) {
      query.where(packs.topic.equals(topic));
    }
    
    return query.map((row) => row.readTable(questions)).get();
  }
  
  Future<void> insertQuestions(List<QuestionsCompanion> questionList) =>
      batch((batch) {
        batch.insertAll(questions, questionList, mode: InsertMode.insertOrReplace);
      });

  // Session operations
  Future<void> insertSession(SessionsCompanion session) =>
      into(sessions).insert(session, mode: InsertMode.insertOrReplace);
  
  Future<Session?> getSessionById(String sessionId) =>
      (select(sessions)..where((s) => s.id.equals(sessionId))).getSingleOrNull();
  
  Future<List<Session>> getRecentSessions({int limit = 10}) =>
      (select(sessions)
        ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
        ..limit(limit))
        .get();

  Future<void> updateSession(String sessionId, SessionsCompanion updates) =>
      (update(sessions)..where((s) => s.id.equals(sessionId))).write(updates);

  // Attempt operations
  Future<void> insertAttempt(AttemptsCompanion attempt) =>
      into(attempts).insert(attempt, mode: InsertMode.insertOrReplace);
  
  Future<void> insertAttempts(List<AttemptsCompanion> attemptList) =>
      batch((batch) {
        batch.insertAll(attempts, attemptList, mode: InsertMode.insertOrReplace);
      });
  
  Future<List<Attempt>> getAttemptsBySessionId(String sessionId) =>
      (select(attempts)..where((a) => a.sessionId.equals(sessionId))).get();

  // Topic stats operations
  Future<void> updateTopicStats(String subject, String topic, bool correct) async {
    final existing = await (select(topicStats)
      ..where((ts) => ts.subject.equals(subject) & ts.topic.equals(topic)))
      .getSingleOrNull();
    
    if (existing != null) {
      final newAttempts = existing.attempts + 1;
      final newCorrect = existing.correct + (correct ? 1 : 0);
      final newAccuracy = newCorrect / newAttempts;
      
      await (update(topicStats)
        ..where((ts) => ts.subject.equals(subject) & ts.topic.equals(topic)))
        .write(TopicStatsCompanion(
          attempts: Value(newAttempts),
          correct: Value(newCorrect),
          accuracy: Value(newAccuracy),
          lastSeenAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ));
    } else {
      await into(topicStats).insert(TopicStatsCompanion(
        subject: Value(subject),
        topic: Value(topic),
        attempts: const Value(1),
        correct: Value(correct ? 1 : 0),
        accuracy: Value(correct ? 1.0 : 0.0),
        lastSeenAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ));
    }
  }
  
  Future<List<TopicStat>> getTopicStatsBySubject(String subject) =>
      (select(topicStats)..where((ts) => ts.subject.equals(subject))).get();

  // Entitlement operations
  Future<void> insertEntitlement(EntitlementsCompanion entitlement) =>
      into(entitlements).insert(entitlement, mode: InsertMode.insertOrReplace);
  
  Future<Entitlement?> getActiveEntitlement() async {
    final now = DateTime.now();
    return await (select(entitlements)
      ..where((e) => e.isActive.equals(true) & e.endAt.isBiggerThanValue(now))
      ..orderBy([(e) => OrderingTerm.desc(e.endAt)])
      ..limit(1))
      .getSingleOrNull();
  }

  // Sync queue operations
  Future<void> addToSyncQueue(String operation, String entity, String payload) =>
      into(syncQueue).insert(SyncQueueCompanion(
        operation: Value(operation),
        entity: Value(entity),
        payload: Value(payload),
        createdAt: Value(DateTime.now()),
      ));
  
  Future<List<SyncQueueData>> getPendingSyncItems({int limit = 50}) =>
      (select(syncQueue)
        ..orderBy([(sq) => OrderingTerm.asc(sq.createdAt)])
        ..limit(limit))
        .get();
  
  Future<void> removeSyncQueueItem(int id) =>
      (delete(syncQueue)..where((sq) => sq.id.equals(id))).go();

  // Settings operations
  Future<void> setSetting(String key, String value) =>
      into(userSettings).insert(
        UserSettingsCompanion(
          key: Value(key),
          value: Value(value),
          updatedAt: Value(DateTime.now()),
        ),
        mode: InsertMode.insertOrReplace,
      );
  
  Future<String?> getSetting(String key) async {
    final result = await (select(userSettings)..where((us) => us.key.equals(key))).getSingleOrNull();
    return result?.value;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'examcoach.db'));
    
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;
    
    return NativeDatabase.createInBackground(file);
  });
}
