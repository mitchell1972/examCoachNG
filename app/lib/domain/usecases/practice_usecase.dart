import '../../data/repositories/session_repository.dart';
import '../../data/repositories/pack_repository.dart';
import '../../data/models/session_model.dart';
import '../../domain/entities/question.dart';
import '../../core/utils/logger.dart';

class PracticeUseCase {
  final SessionRepository _sessionRepository;
  final PackRepository _packRepository;

  PracticeUseCase(this._sessionRepository, this._packRepository);

  Future<SessionModel> startPracticeSession({
    required String subject,
    String? topic,
    int questionCount = 20,
  }) async {
    try {
      Logger.info('Starting practice session: $subject, topic: $topic');

      // Validate that packs are available for the subject
      final packs = await _packRepository.getPacksBySubject(subject);
      if (packs.isEmpty) {
        throw Exception('No question packs available for subject: $subject');
      }

      // If topic is specified, validate it exists
      if (topic != null) {
        final topicPack = packs.where((pack) => pack.topic == topic).toList();
        if (topicPack.isEmpty) {
          throw Exception('No questions available for topic: $topic');
        }
      }

      return await _sessionRepository.createPracticeSession(
        subject: subject,
        topic: topic,
        count: questionCount,
      );
    } catch (e) {
      Logger.error('Failed to start practice session', error: e);
      rethrow;
    }
  }

  Future<SessionModel> startMockSession({
    required String subject,
    int questionCount = 60,
  }) async {
    try {
      Logger.info('Starting mock session: $subject');

      // Validate that enough questions are available
      final packs = await _packRepository.getPacksBySubject(subject);
      if (packs.isEmpty) {
        throw Exception('No question packs available for subject: $subject');
      }

      int totalQuestions = 0;
      for (final pack in packs) {
        final questions = await _packRepository.getQuestionsByPack(pack.id);
        totalQuestions += questions.length;
      }

      if (totalQuestions < questionCount) {
        throw Exception(
          'Insufficient questions for mock exam. Available: $totalQuestions, Required: $questionCount'
        );
      }

      return await _sessionRepository.createMockSession(
        subject: subject,
        count: questionCount,
      );
    } catch (e) {
      Logger.error('Failed to start mock session', error: e);
      rethrow;
    }
  }

  Future<List<Question>> getSessionQuestions(String sessionId) async {
    try {
      final session = await _sessionRepository.getSessionById(sessionId);
      if (session == null) {
        throw Exception('Session not found: $sessionId');
      }

      final questions = <Question>[];
      for (final questionId in session.questions) {
        // Get all questions from all packs to find by ID
        final allPacks = await _packRepository.getInstalledPacks();
        for (final pack in allPacks) {
          final packQuestions = await _packRepository.getQuestionsByPack(pack.id);
          final question = packQuestions.where((q) => q.id == questionId).firstOrNull;
          if (question != null) {
            questions.add(question);
            break;
          }
        }
      }

      return questions;
    } catch (e) {
      Logger.error('Failed to get session questions', error: e);
      rethrow;
    }
  }

  Future<void> submitAnswer({
    required String sessionId,
    required String questionId,
    required String selectedAnswer,
    required int timeSpentMs,
  }) async {
    try {
      // Get question to determine correct answer
      final allPacks = await _packRepository.getInstalledPacks();
      Question? question;
      
      for (final pack in allPacks) {
        final packQuestions = await _packRepository.getQuestionsByPack(pack.id);
        question = packQuestions.where((q) => q.id == questionId).firstOrNull;
        if (question != null) break;
      }

      if (question == null) {
        throw Exception('Question not found: $questionId');
      }

      final isCorrect = question.isCorrectAnswer(selectedAnswer);

      await _sessionRepository.submitAttempt(
        sessionId: sessionId,
        questionId: questionId,
        chosen: selectedAnswer,
        correct: isCorrect,
        timeMs: timeSpentMs,
      );

      Logger.debug('Answer submitted: ${isCorrect ? 'correct' : 'incorrect'}');
    } catch (e) {
      Logger.error('Failed to submit answer', error: e);
      rethrow;
    }
  }

  Future<SessionResult> completeSession(String sessionId) async {
    try {
      Logger.info('Completing session: $sessionId');

      await _sessionRepository.completeSession(sessionId);

      // Get final session data
      final session = await _sessionRepository.getSessionById(sessionId);
      final attempts = await _sessionRepository.getSessionAttempts(sessionId);

      if (session == null) {
        throw Exception('Session not found after completion');
      }

      final correctAttempts = attempts.where((a) => a.correct).length;
      final totalAttempts = attempts.length;
      final accuracy = totalAttempts > 0 ? correctAttempts / totalAttempts : 0.0;
      
      final averageTimeMs = totalAttempts > 0 
          ? attempts.map((a) => a.timeMs).reduce((a, b) => a + b) ~/ totalAttempts
          : 0;

      return SessionResult(
        sessionId: sessionId,
        mode: session.mode == 'practice' ? SessionMode.practice : SessionMode.mock,
        subject: session.subject,
        topic: session.topic,
        score: correctAttempts,
        totalQuestions: totalAttempts,
        accuracy: accuracy,
        averageTimeMs: averageTimeMs,
        completedAt: session.endedAt ?? DateTime.now(),
      );
    } catch (e) {
      Logger.error('Failed to complete session', error: e);
      rethrow;
    }
  }

  Future<List<String>> getAvailableTopics(String subject) async {
    try {
      final packs = await _packRepository.getPacksBySubject(subject);
      final topics = packs.map((pack) => pack.topic).toSet().toList();
      topics.sort();
      return topics;
    } catch (e) {
      Logger.error('Failed to get available topics', error: e);
      rethrow;
    }
  }

  Future<Map<String, int>> getTopicQuestionCounts(String subject) async {
    try {
      final packs = await _packRepository.getPacksBySubject(subject);
      final topicCounts = <String, int>{};

      for (final pack in packs) {
        final questions = await _packRepository.getQuestionsByPack(pack.id);
        topicCounts[pack.topic] = (topicCounts[pack.topic] ?? 0) + questions.length;
      }

      return topicCounts;
    } catch (e) {
      Logger.error('Failed to get topic question counts', error: e);
      rethrow;
    }
  }
}

class SessionResult {
  final String sessionId;
  final SessionMode mode;
  final String subject;
  final String? topic;
  final int score;
  final int totalQuestions;
  final double accuracy;
  final int averageTimeMs;
  final DateTime completedAt;

  SessionResult({
    required this.sessionId,
    required this.mode,
    required this.subject,
    this.topic,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.averageTimeMs,
    required this.completedAt,
  });

  double get accuracyPercentage => accuracy * 100;
  
  String get accuracyText => '${accuracyPercentage.toStringAsFixed(1)}%';
  
  String get gradeText {
    if (accuracyPercentage >= 90) return 'Excellent';
    if (accuracyPercentage >= 80) return 'Very Good';
    if (accuracyPercentage >= 70) return 'Good';
    if (accuracyPercentage >= 60) return 'Average';
    if (accuracyPercentage >= 50) return 'Below Average';
    return 'Poor';
  }

  Duration get averageTime => Duration(milliseconds: averageTimeMs);
}
