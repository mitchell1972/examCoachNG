import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart';

part 'database.g.dart';

// Tables
class Packs extends Table {
  TextColumn get id => text()();
  TextColumn get subject => text()();
  TextColumn get topic => text()();
  IntColumn get version => integer()();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  DateTimeColumn get installedAt => dateTime().nullable()();
  TextColumn get checksum => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Questions extends Table {
  TextColumn get id => text()();
  TextColumn get packId => text()();
  TextColumn get stem => text()();
  TextColumn get a => text()();
  TextColumn get b => text()();
  TextColumn get c => text()();
  TextColumn get d => text()();
  TextColumn get correct => text()();
  TextColumn get explanation => text()();
  IntColumn get difficulty => integer().withDefault(const Constant(2))();
  TextColumn get syllabusNode => text()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get mode => text()(); // practice | mock
  TextColumn get subject => text()();
  TextColumn get topic => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get score => integer().nullable()();
  TextColumn get metaJson => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Attempts extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get questionId => text()();
  TextColumn get chosen => text()();
  BoolColumn get correct => boolean()();
  IntColumn get timeMs => integer()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class TopicStats extends Table {
  TextColumn get topic => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get correct => integer().withDefault(const Constant(0))();
  RealColumn get accuracy => real().withDefault(const Constant(0))();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {topic};
}

class Entitlements extends Table {
  TextColumn get plan => text()();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime()();
  TextColumn get source => text()(); // paystack | flutterwave | apple_iap
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  
  @override
  Set<Column> get primaryKey => {plan, startAt};
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation => text()(); // create|update|delete
  TextColumn get entity => text()(); // attempt|session|stats
  TextColumn get payload => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [
  Packs,
  Questions,
  Sessions,
  Attempts,
  TopicStats,
  Entitlements,
  SyncQueue,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Handle future schema migrations
      if (from < 2) {
        // Example migration for version 2
        // await m.addColumn(packs, packs.checksum);
      }
    },
  );

  // Pack methods
  Future<List<Pack>> getAllPacks() => select(packs).get();
  
  Future<List<Pack>> getPacksBySubject(String subject) => 
      (select(packs)..where((tbl) => tbl.subject.equals(subject))).get();
  
  Future<void> insertPack(PacksCompanion pack) => into(packs).insert(pack);
  
  Future<void> updatePack(Pack pack) => update(packs).replace(pack);
  
  Future<void> deletePack(String id) => 
      (delete(packs)..where((tbl) => tbl.id.equals(id))).go();

  // Question methods
  Future<List<Question>> getQuestionsByPack(String packId) =>
      (select(questions)..where((tbl) => tbl.packId.equals(packId))).get();
  
  Future<List<Question>> getQuestionsByTopic(String subject, String topic) =>
      (select(questions)
        ..join([innerJoin(packs, packs.id.equalsExp(questions.packId))])
        ..where(packs.subject.equals(subject) & packs.topic.equals(topic))
      ).map((row) => row.readTable(questions)).get();
  
  Future<void> insertQuestions(List<QuestionsCompanion> questionList) =>
      batch((batch) => batch.insertAll(questions, questionList));
  
  Future<void> deleteQuestionsByPack(String packId) =>
      (delete(questions)..where((tbl) => tbl.packId.equals(packId))).go();

  // Session methods
  Future<List<Session>> getAllSessions() => 
      (select(sessions)..orderBy([(t) => OrderingTerm.desc(t.startedAt)])).get();
  
  Future<Session?> getSessionById(String id) =>
      (select(sessions)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  
  Future<void> insertSession(SessionsCompanion session) =>
      into(sessions).insert(session);
  
  Future<void> updateSession(Session session) =>
      update(sessions).replace(session);

  // Attempt methods
  Future<List<Attempt>> getAttemptsBySession(String sessionId) =>
      (select(attempts)..where((tbl) => tbl.sessionId.equals(sessionId))).get();
  
  Future<List<Attempt>> getUnsyncedAttempts() =>
      (select(attempts)..where((tbl) => tbl.synced.equals(false))).get();
  
  Future<void> insertAttempt(AttemptsCompanion attempt) =>
      into(attempts).insert(attempt);
  
  Future<void> markAttemptsSynced(List<String> attemptIds) =>
      (update(attempts)
        ..where((tbl) => tbl.id.isIn(attemptIds))
      ).write(const AttemptsCompanion(synced: Value(true)));

  // Topic stats methods
  Future<TopicStat?> getTopicStats(String topic) =>
      (select(topicStats)..where((tbl) => tbl.topic.equals(topic))).getSingleOrNull();
  
  Future<void> updateTopicStats(TopicStatsCompanion stats) =>
      into(topicStats).insertOnConflictUpdate(stats);

  // Entitlement methods
  Future<List<Entitlement>> getActiveEntitlements() {
    final now = DateTime.now();
    return (select(entitlements)
      ..where((tbl) => tbl.active.equals(true) & tbl.endAt.isBiggerThanValue(now))
    ).get();
  }
  
  Future<void> insertEntitlement(EntitlementsCompanion entitlement) =>
      into(entitlements).insert(entitlement);

  // Sync queue methods
  Future<List<SyncQueueData>> getPendingSyncItems() =>
      (select(syncQueue)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
  
  Future<void> addToSyncQueue(SyncQueueCompanion item) =>
      into(syncQueue).insert(item);
  
  Future<void> removeSyncItem(int id) =>
      (delete(syncQueue)..where((tbl) => tbl.id.equals(id))).go();
  
  Future<void> incrementSyncRetry(int id) => 
      (update(syncQueue)..where((tbl) => tbl.id.equals(id)))
          .write(SyncQueueCompanion(retryCount: Value(retryCount + 1)));
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'examcoach.db'));

    // Make sqlite3 available on Android and iOS
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Create the sqlite3 database
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
