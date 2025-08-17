import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../api/dio_client.dart';
import '../db/database.dart';
import '../models/session_model.dart';

class SessionRepository {
  final DioClient _dioClient = DioClient.instance;
  final AppDatabase _database = AppDatabase();
  final _uuid = const Uuid();
  
  Future<SessionModel> createPracticeSession({
    required String subject,
    String? topic,
    int count = AppConstants.defaultQuestionCount,
  }) async {
    try {
      Logger.info('Creating practice session: $subject, topic: $topic, count: $count');
      
      // Create local session first
      final sessionId = _uuid.v4();
      final now = DateTime.now();
      
      // Get questions from local database
      List<Question> availableQuestions;
      if (topic != null) {
        availableQuestions = await _database.getQuestionsByTopic(subject, topic);
      } else {
        final packs = await _database.getPacksBySubject(subject);
        availableQuestions = [];
        for (final pack in packs) {
          final questions = await _database.getQuestionsByPack(pack.id);
          availableQuestions.addAll(questions);
        }
      }
      
      if (availableQuestions.isEmpty) {
        throw Exception('No questions available for this subject/topic');
      }
      
      // Select random questions
      availableQuestions.shuffle(Random());
      final selectedQuestions = availableQuestions.take(count).toList();
      
      // Insert session into local database
      await _database.insertSession(SessionsCompanion.insert(
        id: sessionId,
        mode: 'practice',
        subject: subject,
        topic: Value(topic),
        startedAt: now,
        metaJson: Value(json.encode({
          'question_count': selectedQuestions.length,
          'question_ids': selectedQuestions.map((q) => q.id).toList(),
        })),
      ));
      
      // Try to sync with server (optional - works offline)
      try {
        await _dioClient.post(
          AppConstants.sessionsEndpoint,
          data: {
            'session_id': sessionId,
            'mode': 'practice',
            'subject': subject,
            'topic': topic,
            'count': selectedQuestions.length,
          },
        );
        Logger.info('Session synced with server');
      } catch (e) {
        Logger.warning('Failed to sync session with server (offline mode)', error: e);
      }
      
      return SessionModel(
        id: sessionId,
        mode: SessionMode.practice,
        subject: subject,
        topic: topic,
        startedAt: now,
        questions: selectedQuestions.map((q) => q.id).toList(),
      );
    } catch (e) {
      Logger.error('Error creating practice session', error: e);
      rethrow;
    }
  }
  
  Future<SessionModel> createMockSession({
    required String subject,
    int count = AppConstants.mockQuestionCount,
  }) async {
    try {
      Logger.info('Creating mock session: $subject, count: $count');
      
      final sessionId = _uuid.v4();
      final now = DateTime.now();
      
      // Get all questions for the subject
      final packs = await _database.getPacksBySubject(subject);
      List<Question> allQuestions = [];
      for (final pack in packs) {
        final questions = await _database.getQuestionsByPack(pack.id);
        allQuestions.addAll(questions);
      }
      
      if (allQuestions.length < count) {
        throw Exception('Not enough questions available for mock exam');
      }
      
      // Select questions with balanced difficulty
      final selectedQuestions = _selectBalancedQuestions(allQuestions, count);
      
      // Insert session into local database
      await _database.insertSession(SessionsCompanion.insert(
        id: sessionId,
        mode: 'mock',
        subject: subject,
        startedAt: now,
        metaJson: Value(json.encode({
          'question_count': selectedQuestions.length,
          'question_ids': selectedQuestions.map((q) => q.id).toList(),
          'duration_minutes': AppConstants.mockExamDuration,
          'end_time': now.add(const Duration(minutes: AppConstants.mockExamDuration)).toIso8601String(),
        })),
      ));
      
      // Try to sync with server
      try {
        await _dioClient.post(
          AppConstants.sessionsEndpoint,
          data: {
            'session_id': sessionId,
            'mode': 'mock',
            'subject': subject,
            'count': selectedQuestions.length,
          },
        );
        Logger.info('Mock session synced with server');
      } catch (e) {
        Logger.warning('Failed to sync mock session with server (offline mode)', error: e);
      }
      
      return SessionModel(
        id: sessionId,
        mode: SessionMode.mock,
        subject: subject,
        startedAt: now,
        duration: const Duration(minutes: AppConstants.mockExamDuration),
        questions: selectedQuestions.map((q) => q.id).toList(),
      );
    } catch (e) {
      Logger.error('Error creating mock session', error: e);
      rethrow;
    }
  }
  
  List<Question> _selectBalancedQuestions(List<Question> questions, int count) {
    // Group questions by difficulty
    final questionsByDifficulty = <int, List<Question>>{};
    for (final question in questions) {
      questionsByDifficulty.putIfAbsent(question.difficulty, () => []).add(question);
    }
    
    final selectedQuestions = <Question>[];
    final targetPerDifficulty = count ~/ questionsByDifficulty.length;
    int remaining = count;
    
    // Select proportionally from each difficulty level
    for (final entry in questionsByDifficulty.entries) {
      final difficulty = entry.key;
      final difficultyQuestions = entry.value..shuffle(Random());
      
      final takeCount = math.min(targetPerDifficulty, remaining);
      selectedQuestions.addAll(difficultyQuestions.take(takeCount));
      remaining -= takeCount;
      
      if (remaining == 0) break;
    }
    
    // Fill remaining slots randomly
    if (remaining > 0) {
      final allRemaining = questions.where((q) => !selectedQuestions.contains(q)).toList();
      allRemaining.shuffle(Random());
      selectedQuestions.addAll(allRemaining.take(remaining));
    }
    
    selectedQuestions.shuffle(Random());
    return selectedQuestions;
  }
  
  Future<void> submitAttempt({
    required String sessionId,
    required String questionId,
    required String chosen,
    required bool correct,
    required int timeMs,
  }) async {
    try {
      final attemptId = _uuid.v4();
      final now = DateTime.now();
      
      // Store attempt locally
      await _database.insertAttempt(AttemptsCompanion.insert(
        id: attemptId,
        sessionId: sessionId,
        questionId: questionId,
        chosen: chosen,
        correct: correct,
        timeMs: timeMs,
        createdAt: now,
        synced: const Value(false),
      ));
      
      // Update topic stats
      final question = await _database.getQuestionsByPack('')
          .then((questions) => questions.firstWhere((q) => q.id == questionId));
      
      final currentStats = await _database.getTopicStats(question.syllabusNode);
      final newAttempts = (currentStats?.attempts ?? 0) + 1;
      final newCorrect = (currentStats?.correct ?? 0) + (correct ? 1 : 0);
      final newAccuracy = newCorrect / newAttempts;
      
      await _database.updateTopicStats(TopicStatsCompanion(
        topic: Value(question.syllabusNode),
        attempts: Value(newAttempts),
        correct: Value(newCorrect),
        accuracy: Value(newAccuracy),
        lastSeenAt: Value(now),
      ));
      
      // Try to sync with server
      try {
        await _dioClient.post(
          '${AppConstants.attemptsEndpoint}/batch',
          data: {
            'session_id': sessionId,
            'attempts': [{
              'question_id': questionId,
              'chosen': chosen,
              'correct': correct,
              'time_ms': timeMs,
            }],
          },
        );
        
        // Mark as synced
        await _database.markAttemptsSynced([attemptId]);
        Logger.debug('Attempt synced with server');
      } catch (e) {
        Logger.warning('Failed to sync attempt (offline mode)', error: e);
      }
    } catch (e) {
      Logger.error('Error submitting attempt', error: e);
      rethrow;
    }
  }
  
  Future<void> completeSession(String sessionId) async {
    try {
      Logger.info('Completing session: $sessionId');
      
      final session = await _database.getSessionById(sessionId);
      if (session == null) {
        throw Exception('Session not found');
      }
      
      final attempts = await _database.getAttemptsBySession(sessionId);
      final score = attempts.where((a) => a.correct).length;
      final totalQuestions = attempts.length;
      
      // Update session with end time and score
      final updatedSession = session.copyWith(
        endedAt: Value(DateTime.now()),
        score: Value(score),
      );
      
      await _database.updateSession(updatedSession);
      
      // Try to sync completion with server
      try {
        await _dioClient.post(
          '${AppConstants.sessionsEndpoint}/$sessionId/submit',
          data: {
            'score': score,
            'total': totalQuestions,
            'breakdown_by_topic': await _getTopicBreakdown(attempts),
          },
        );
        Logger.info('Session completion synced with server');
      } catch (e) {
        Logger.warning('Failed to sync session completion (offline mode)', error: e);
      }
    } catch (e) {
      Logger.error('Error completing session', error: e);
      rethrow;
    }
  }
  
  Future<Map<String, Map<String, int>>> _getTopicBreakdown(List<Attempt> attempts) async {
    final breakdown = <String, Map<String, int>>{};
    
    for (final attempt in attempts) {
      // Get question to find topic
      final questions = await _database.getQuestionsByPack('');
      final question = questions.firstWhere((q) => q.id == attempt.questionId);
      final topic = question.syllabusNode;
      
      breakdown.putIfAbsent(topic, () => {'correct': 0, 'total': 0});
      breakdown[topic]!['total'] = breakdown[topic]!['total']! + 1;
      if (attempt.correct) {
        breakdown[topic]!['correct'] = breakdown[topic]!['correct']! + 1;
      }
    }
    
    return breakdown;
  }
  
  Future<List<Session>> getAllSessions() async {
    try {
      return await _database.getAllSessions();
    } catch (e) {
      Logger.error('Error getting all sessions', error: e);
      rethrow;
    }
  }
  
  Future<Session?> getSessionById(String sessionId) async {
    try {
      return await _database.getSessionById(sessionId);
    } catch (e) {
      Logger.error('Error getting session by ID', error: e);
      rethrow;
    }
  }
  
  Future<List<Attempt>> getSessionAttempts(String sessionId) async {
    try {
      return await _database.getAttemptsBySession(sessionId);
    } catch (e) {
      Logger.error('Error getting session attempts', error: e);
      rethrow;
    }
  }
}
