import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../api/api_client.dart';
import '../api/dto/session_dto.dart';
import '../db/database.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/attempt.dart';
import '../../core/utils/constants.dart';

class SessionRepository {
  final ApiClient _apiClient;
  final AppDatabase _database;
  final Uuid _uuid = const Uuid();

  SessionRepository(this._apiClient, this._database);

  Future<SessionEntity> createSession({
    required String mode,
    required String subject,
    String? topic,
    required int count,
  }) async {
    try {
      // Try to create session on server first
      final response = await _apiClient.post(
        ApiEndpoints.sessions,
        data: {
          'mode': mode,
          'subject': subject,
          'topic': topic,
          'count': count,
        },
      );

      final sessionDto = SessionResponseDto.fromJson(response.data);
      final sessionEntity = SessionEntity(
        id: sessionDto.sessionId,
        mode: mode,
        subject: subject,
        topic: topic,
        startedAt: DateTime.now(),
        endedAt: null,
        score: null,
        questionIds: sessionDto.items.map((item) => item.questionId).toList(),
      );

      // Store session locally
      await _database.insertSession(SessionsCompanion(
        id: drift.Value(sessionEntity.id),
        mode: drift.Value(sessionEntity.mode),
        subject: drift.Value(sessionEntity.subject),
        topic: drift.Value(sessionEntity.topic),
        startedAt: drift.Value(sessionEntity.startedAt),
        metaJson: drift.Value(json.encode({
          'questionIds': sessionEntity.questionIds,
        })),
      ));

      return sessionEntity;
    } catch (e) {
      // Fallback to offline session creation
      return await _createOfflineSession(
        mode: mode,
        subject: subject,
        topic: topic,
        count: count,
      );
    }
  }

  Future<SessionEntity> _createOfflineSession({
    required String mode,
    required String subject,
    String? topic,
    required int count,
  }) async {
    final sessionId = _uuid.v4();
    
    // Get random questions from local database
    final questions = await _database.getRandomQuestions(
      subject: subject,
      topic: topic,
      count: count,
    );

    if (questions.isEmpty) {
      throw Exception('No questions available for $subject${topic != null ? ' - $topic' : ''}');
    }

    final sessionEntity = SessionEntity(
      id: sessionId,
      mode: mode,
      subject: subject,
      topic: topic,
      startedAt: DateTime.now(),
      endedAt: null,
      score: null,
      questionIds: questions.map((q) => q.id).toList(),
    );

    // Store session locally
    await _database.insertSession(SessionsCompanion(
      id: drift.Value(sessionEntity.id),
      mode: drift.Value(sessionEntity.mode),
      subject: drift.Value(sessionEntity.subject),
      topic: drift.Value(sessionEntity.topic),
      startedAt: drift.Value(sessionEntity.startedAt),
      metaJson: drift.Value(json.encode({
        'questionIds': sessionEntity.questionIds,
        'offline': true,
      })),
    ));

    return sessionEntity;
  }

  Future<SessionEntity?> getSession(String sessionId) async {
    final session = await _database.getSessionById(sessionId);
    if (session == null) return null;

    final metaData = session.metaJson != null 
        ? json.decode(session.metaJson!) as Map<String, dynamic>
        : <String, dynamic>{};

    return SessionEntity(
      id: session.id,
      mode: session.mode,
      subject: session.subject,
      topic: session.topic,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      score: session.score,
      questionIds: List<String>.from(metaData['questionIds'] ?? []),
    );
  }

  Future<void> submitAttempts(String sessionId, List<AttemptEntity> attempts) async {
    // Store attempts locally first
    final attemptsData = attempts.map((attempt) => AttemptsCompanion(
      id: drift.Value(attempt.id),
      sessionId: drift.Value(sessionId),
      questionId: drift.Value(attempt.questionId),
      chosen: drift.Value(attempt.chosen),
      correct: drift.Value(attempt.correct),
      timeMs: drift.Value(attempt.timeMs),
      createdAt: drift.Value(attempt.createdAt),
    )).toList();

    await _database.insertAttempts(attemptsData);

    // Update topic stats
    for (final attempt in attempts) {
      final question = await _database.getQuestionsByPack(''); // Get question to find topic
      // TODO: Implement proper topic extraction from question
      await _database.updateTopicStats('general', attempt.correct, attempt.timeMs);
    }

    try {
      // Try to sync with server
      await _apiClient.post(
        ApiEndpoints.attemptsBatch,
        data: {
          'session_id': sessionId,
          'attempts': attempts.map((a) => {
            'question_id': a.questionId,
            'chosen': a.chosen,
            'correct': a.correct,
            'time_ms': a.timeMs,
          }).toList(),
        },
      );
    } catch (e) {
      // If sync fails, attempts are already stored locally
      // They can be synced later when connection is restored
    }
  }

  Future<void> completeSession(String sessionId, int score) async {
    // Update local session
    await _database.updateSession(SessionsCompanion(
      id: drift.Value(sessionId),
      endedAt: drift.Value(DateTime.now()),
      score: drift.Value(score),
    ));

    try {
      // Try to submit to server
      await _apiClient.post(
        ApiEndpoints.sessionSubmit(sessionId),
        data: {
          'score': score,
          'breakdown_by_topic': {}, // TODO: Calculate topic breakdown
        },
      );
    } catch (e) {
      // Session completion is already stored locally
    }
  }

  Future<List<AttemptEntity>> getSessionAttempts(String sessionId) async {
    final attempts = await _database.getAttemptsBySession(sessionId);
    return attempts.map((a) => AttemptEntity(
      id: a.id,
      sessionId: a.sessionId,
      questionId: a.questionId,
      chosen: a.chosen,
      correct: a.correct,
      timeMs: a.timeMs,
      createdAt: a.createdAt,
    )).toList();
  }

  Future<List<SessionEntity>> getRecentSessions({int limit = 10}) async {
    final sessions = await _database.getRecentSessions(limit: limit);
    return sessions.map((session) {
      final metaData = session.metaJson != null 
          ? json.decode(session.metaJson!) as Map<String, dynamic>
          : <String, dynamic>{};

      return SessionEntity(
        id: session.id,
        mode: session.mode,
        subject: session.subject,
        topic: session.topic,
        startedAt: session.startedAt,
        endedAt: session.endedAt,
        score: session.score,
        questionIds: List<String>.from(metaData['questionIds'] ?? []),
      );
    }).toList();
  }
}

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final database = ref.read(databaseProvider);
  
  return SessionRepository(apiClient, database);
});
