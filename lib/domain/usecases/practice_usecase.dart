import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/pack_repository.dart';
import '../entities/question_entity.dart';
import '../../core/utils/constants.dart';

final practiceUsecaseProvider = Provider<PracticeUsecase>((ref) {
  return PracticeUsecase(
    ref.read(sessionRepositoryProvider),
    ref.read(packRepositoryProvider),
  );
});

class PracticeUsecase {
  final SessionRepository _sessionRepository;
  final PackRepository _packRepository;
  
  PracticeUsecase(this._sessionRepository, this._packRepository);
  
  // Start a practice session
  Future<PracticeSession> startPracticeSession({
    required String subject,
    String? topic,
    int? questionCount,
  }) async {
    // Validate inputs
    if (!AppConstants.availableSubjects.contains(subject)) {
      throw PracticeException('Invalid subject selected');
    }
    
    final count = questionCount ?? AppConstants.practiceSessionQuestions;
    if (count <= 0 || count > 100) {
      throw PracticeException('Question count must be between 1 and 100');
    }
    
    // Check if questions are available
    final questions = await _packRepository.getQuestionsBySubject(subject, topic: topic);
    if (questions.isEmpty) {
      throw PracticeException('No questions available for this topic. Please download question packs first.');
    }
    
    // Create session
    final sessionData = await _sessionRepository.createPracticeSession(
      subject: subject,
      topic: topic,
      count: count,
    );
    
    // Convert to domain entities
    final questionEntities = sessionData.questions.map((q) => QuestionEntity(
      id: q.id,
      packId: q.packId,
      stem: q.stem,
      options: [q.a, q.b, q.c, q.d],
      correctAnswer: q.correct,
      explanation: q.explanation,
      difficulty: q.difficulty,
      syllabusNode: q.syllabusNode,
      imageUrl: q.imageUrl,
    )).toList();
    
    return PracticeSession(
      sessionId: sessionData.sessionId,
      subject: subject,
      topic: topic,
      questions: questionEntities,
      currentQuestionIndex: 0,
      totalQuestions: questionEntities.length,
      startTime: DateTime.now(),
    );
  }
  
  // Start a mock exam session
  Future<MockSession> startMockSession({
    required String subject,
    int? questionCount,
  }) async {
    // Validate inputs
    if (!AppConstants.availableSubjects.contains(subject)) {
      throw PracticeException('Invalid subject selected');
    }
    
    final count = questionCount ?? AppConstants.mockSessionQuestions;
    if (count <= 0 || count > 200) {
      throw PracticeException('Question count must be between 1 and 200');
    }
    
    // Create session
    final sessionData = await _sessionRepository.createMockSession(
      subject: subject,
      count: count,
    );
    
    // Convert to domain entities
    final questionEntities = sessionData.questions.map((q) => QuestionEntity(
      id: q.id,
      packId: q.packId,
      stem: q.stem,
      options: [q.a, q.b, q.c, q.d],
      correctAnswer: q.correct,
      explanation: q.explanation,
      difficulty: q.difficulty,
      syllabusNode: q.syllabusNode,
      imageUrl: q.imageUrl,
    )).toList();
    
    return MockSession(
      sessionId: sessionData.sessionId,
      subject: subject,
      questions: questionEntities,
      currentQuestionIndex: 0,
      totalQuestions: questionEntities.length,
      startTime: DateTime.now(),
      duration: const Duration(minutes: AppConstants.mockSessionDurationMinutes),
      flaggedQuestions: <int>{},
      answers: <int, String>{},
    );
  }
  
  // Submit an answer
  Future<void> submitAnswer({
    required String sessionId,
    required QuestionEntity question,
    required String answer,
    required Duration responseTime,
  }) async {
    final isCorrect = question.isCorrectAnswer(answer);
    
    await _sessionRepository.submitAttempt(
      sessionId: sessionId,
      questionId: question.id,
      chosen: answer,
      correct: isCorrect,
      timeMs: responseTime.inMilliseconds,
    );
  }
  
  // Complete a session
  Future<SessionSummary> completeSession(String sessionId) async {
    final result = await _sessionRepository.completeSession(sessionId);
    
    return SessionSummary(
      sessionId: result.sessionId,
      score: result.score,
      correctAnswers: result.correctAnswers,
      totalQuestions: result.totalQuestions,
      accuracy: result.accuracy,
      timeSpent: result.timeSpent,
      completedAt: DateTime.now(),
    );
  }
  
  // Get available topics for a subject
  Future<List<String>> getAvailableTopics(String subject) async {
    final packs = await _packRepository.getInstalledPacksBySubject(subject);
    return packs.map((pack) => pack.topic).toSet().toList()..sort();
  }
  
  // Check if questions are available for practice
  Future<bool> areQuestionsAvailable(String subject, {String? topic}) async {
    final questions = await _packRepository.getQuestionsBySubject(subject, topic: topic);
    return questions.isNotEmpty;
  }
}

class PracticeSession {
  final String sessionId;
  final String subject;
  final String? topic;
  final List<QuestionEntity> questions;
  final int currentQuestionIndex;
  final int totalQuestions;
  final DateTime startTime;
  final Map<int, String> answers;
  final Map<int, Duration> responseTimes;
  
  PracticeSession({
    required this.sessionId,
    required this.subject,
    this.topic,
    required this.questions,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.startTime,
    Map<int, String>? answers,
    Map<int, Duration>? responseTimes,
  })  : answers = answers ?? {},
        responseTimes = responseTimes ?? {};
  
  QuestionEntity get currentQuestion => questions[currentQuestionIndex];
  
  bool get isLastQuestion => currentQuestionIndex >= questions.length - 1;
  
  bool get isCompleted => currentQuestionIndex >= questions.length;
  
  int get answeredCount => answers.length;
  
  Duration get elapsedTime => DateTime.now().difference(startTime);
  
  PracticeSession copyWith({
    int? currentQuestionIndex,
    Map<int, String>? answers,
    Map<int, Duration>? responseTimes,
  }) {
    return PracticeSession(
      sessionId: sessionId,
      subject: subject,
      topic: topic,
      questions: questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions,
      startTime: startTime,
      answers: answers ?? this.answers,
      responseTimes: responseTimes ?? this.responseTimes,
    );
  }
  
  PracticeSession withAnswer(int questionIndex, String answer, Duration responseTime) {
    final newAnswers = Map<int, String>.from(answers);
    final newResponseTimes = Map<int, Duration>.from(responseTimes);
    
    newAnswers[questionIndex] = answer;
    newResponseTimes[questionIndex] = responseTime;
    
    return copyWith(
      answers: newAnswers,
      responseTimes: newResponseTimes,
    );
  }
  
  PracticeSession nextQuestion() {
    if (!isLastQuestion) {
      return copyWith(currentQuestionIndex: currentQuestionIndex + 1);
    }
    return this;
  }
}

class MockSession extends PracticeSession {
  final Duration duration;
  final Set<int> flaggedQuestions;
  final DateTime? pausedAt;
  final Duration pausedDuration;
  
  MockSession({
    required String sessionId,
    required String subject,
    required List<QuestionEntity> questions,
    required int currentQuestionIndex,
    required int totalQuestions,
    required DateTime startTime,
    required this.duration,
    Set<int>? flaggedQuestions,
    Map<int, String>? answers,
    Map<int, Duration>? responseTimes,
    this.pausedAt,
    Duration? pausedDuration,
  })  : flaggedQuestions = flaggedQuestions ?? <int>{},
        pausedDuration = pausedDuration ?? Duration.zero,
        super(
          sessionId: sessionId,
          subject: subject,
          questions: questions,
          currentQuestionIndex: currentQuestionIndex,
          totalQuestions: totalQuestions,
          startTime: startTime,
          answers: answers,
          responseTimes: responseTimes,
        );
  
  Duration get remainingTime {
    final elapsed = elapsedTime - pausedDuration;
    final remaining = duration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  bool get isTimeUp => remainingTime <= Duration.zero;
  
  bool get isPaused => pausedAt != null;
  
  int get flaggedCount => flaggedQuestions.length;
  
  bool isQuestionFlagged(int index) => flaggedQuestions.contains(index);
  
  MockSession toggleFlag(int questionIndex) {
    final newFlagged = Set<int>.from(flaggedQuestions);
    if (newFlagged.contains(questionIndex)) {
      newFlagged.remove(questionIndex);
    } else {
      newFlagged.add(questionIndex);
    }
    
    return MockSession(
      sessionId: sessionId,
      subject: subject,
      questions: questions,
      currentQuestionIndex: currentQuestionIndex,
      totalQuestions: totalQuestions,
      startTime: startTime,
      duration: duration,
      flaggedQuestions: newFlagged,
      answers: answers,
      responseTimes: responseTimes,
      pausedAt: pausedAt,
      pausedDuration: pausedDuration,
    );
  }
  
  MockSession jumpToQuestion(int index) {
    return MockSession(
      sessionId: sessionId,
      subject: subject,
      questions: questions,
      currentQuestionIndex: index,
      totalQuestions: totalQuestions,
      startTime: startTime,
      duration: duration,
      flaggedQuestions: flaggedQuestions,
      answers: answers,
      responseTimes: responseTimes,
      pausedAt: pausedAt,
      pausedDuration: pausedDuration,
    );
  }
}

class SessionSummary {
  final String sessionId;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracy;
  final Duration timeSpent;
  final DateTime completedAt;
  
  SessionSummary({
    required this.sessionId,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracy,
    required this.timeSpent,
    required this.completedAt,
  });
  
  String get formattedScore => '$score%';
  
  String get formattedAccuracy => '${(accuracy * 100).toStringAsFixed(1)}%';
  
  String get formattedTimeSpent {
    final hours = timeSpent.inHours;
    final minutes = timeSpent.inMinutes.remainder(60);
    final seconds = timeSpent.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  SessionGrade get grade {
    if (score >= 90) return SessionGrade.excellent;
    if (score >= 80) return SessionGrade.veryGood;
    if (score >= 70) return SessionGrade.good;
    if (score >= 60) return SessionGrade.satisfactory;
    if (score >= 50) return SessionGrade.pass;
    return SessionGrade.fail;
  }
}

enum SessionGrade {
  excellent,
  veryGood,
  good,
  satisfactory,
  pass,
  fail;
  
  String get displayName {
    switch (this) {
      case SessionGrade.excellent: return 'Excellent';
      case SessionGrade.veryGood: return 'Very Good';
      case SessionGrade.good: return 'Good';
      case SessionGrade.satisfactory: return 'Satisfactory';
      case SessionGrade.pass: return 'Pass';
      case SessionGrade.fail: return 'Fail';
    }
  }
  
  String get emoji {
    switch (this) {
      case SessionGrade.excellent: return '🏆';
      case SessionGrade.veryGood: return '🥇';
      case SessionGrade.good: return '🥈';
      case SessionGrade.satisfactory: return '🥉';
      case SessionGrade.pass: return '✅';
      case SessionGrade.fail: return '❌';
    }
  }
}

class PracticeException implements Exception {
  final String message;
  
  const PracticeException(this.message);
  
  @override
  String toString() => 'PracticeException: $message';
}
