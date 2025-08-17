import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'schema.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Packs,
  Questions,
  Sessions,
  Attempts,
  TopicStats,
  Entitlements,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Handle future schema migrations
    },
  );

  // Pack operations
  Future<void> insertPack(PacksCompanion pack) async {
    await into(packs).insertOnConflictUpdate(pack);
  }

  Future<List<Pack>> getAllPacks() async {
    return await select(packs).get();
  }

  Future<Pack?> getPackById(String id) async {
    final query = select(packs)..where((p) => p.id.equals(id));
    return await query.getSingleOrNull();
  }

  Future<void> deletePack(String id) async {
    await (delete(packs)..where((p) => p.id.equals(id))).go();
    await (delete(questions)..where((q) => q.packId.equals(id))).go();
  }

  // Question operations
  Future<void> insertQuestions(List<QuestionsCompanion> questionList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(questions, questionList);
    });
  }

  Future<List<Question>> getQuestionsByPack(String packId) async {
    final query = select(questions)..where((q) => q.packId.equals(packId));
    return await query.get();
  }

  Future<List<Question>> getRandomQuestions({
    required String subject,
    String? topic,
    required int count,
    List<String>? excludeIds,
  }) async {
    var query = selectOnly(questions)
      ..addColumns([questions.id, questions.packId, questions.stem, 
                   questions.a, questions.b, questions.c, questions.d,
                   questions.correct, questions.explanation, questions.difficulty,
                   questions.syllabusNode])
      ..join([
        innerJoin(packs, packs.id.equalsExp(questions.packId))
      ])
      ..where(packs.subject.equals(subject));

    if (topic != null) {
      query = query..where(packs.topic.equals(topic));
    }

    if (excludeIds != null && excludeIds.isNotEmpty) {
      query = query..where(questions.id.isNotIn(excludeIds));
    }

    query = query..orderBy([OrderingTerm.random()]);
    query = query..limit(count);

    final result = await query.get();
    return result.map((row) => Question(
      id: row.read(questions.id)!,
      packId: row.read(questions.packId)!,
      stem: row.read(questions.stem)!,
      a: row.read(questions.a)!,
      b: row.read(questions.b)!,
      c: row.read(questions.c)!,
      d: row.read(questions.d)!,
      correct: row.read(questions.correct)!,
      explanation: row.read(questions.explanation)!,
      difficulty: row.read(questions.difficulty)!,
      syllabusNode: row.read(questions.syllabusNode)!,
    )).toList();
  }

  // Session operations
  Future<void> insertSession(SessionsCompanion session) async {
    await into(sessions).insertOnConflictUpdate(session);
  }

  Future<Session?> getSessionById(String id) async {
    final query = select(sessions)..where((s) => s.id.equals(id));
    return await query.getSingleOrNull();
  }

  Future<List<Session>> getRecentSessions({int limit = 10}) async {
    final query = select(sessions)
      ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
      ..limit(limit);
    return await query.get();
  }

  Future<void> updateSession(SessionsCompanion session) async {
    await (update(sessions)..where((s) => s.id.equals(session.id.value))).write(session);
  }

  // Attempt operations
  Future<void> insertAttempts(List<AttemptsCompanion> attemptList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(attempts, attemptList);
    });
  }

  Future<List<Attempt>> getAttemptsBySession(String sessionId) async {
    final query = select(attempts)..where((a) => a.sessionId.equals(sessionId));
    return await query.get();
  }

  // Topic stats operations
  Future<void> updateTopicStats(String topic, bool correct, int timeMs) async {
    final existing = await (select(topicStats)..where((t) => t.topic.equals(topic))).getSingleOrNull();
    
    if (existing != null) {
      final newAttempts = existing.attempts + 1;
      final newCorrect = existing.correct + (correct ? 1 : 0);
      final newAccuracy = newCorrect / newAttempts;
      
      await (update(topicStats)..where((t) => t.topic.equals(topic))).write(
        TopicStatsCompanion(
          attempts: Value(newAttempts),
          correct: Value(newCorrect),
          accuracy: Value(newAccuracy),
          lastSeenAt: Value(DateTime.now()),
        ),
      );
    } else {
      await into(topicStats).insert(
        TopicStatsCompanion(
          topic: Value(topic),
          attempts: const Value(1),
          correct: Value(correct ? 1 : 0),
          accuracy: Value(correct ? 1.0 : 0.0),
          lastSeenAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<List<TopicStat>> getAllTopicStats() async {
    return await select(topicStats).get();
  }

  // Entitlement operations
  Future<void> insertEntitlement(EntitlementsCompanion entitlement) async {
    await into(entitlements).insertOnConflictUpdate(entitlement);
  }

  Future<Entitlement?> getActiveEntitlement() async {
    final query = select(entitlements)
      ..where((e) => e.endAt.isBiggerThanValue(DateTime.now()))
      ..orderBy([(e) => OrderingTerm.desc(e.endAt)])
      ..limit(1);
    return await query.getSingleOrNull();
  }

  Future<void> clearExpiredEntitlements() async {
    await (delete(entitlements)..where((e) => e.endAt.isSmallerThanValue(DateTime.now()))).go();
  }
}

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database provider must be overridden in main.dart');
});
