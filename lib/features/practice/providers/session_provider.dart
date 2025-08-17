import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/pack_repository.dart';
import '../../../domain/entities/session.dart';
import '../../../domain/entities/question.dart';
import '../../../domain/entities/attempt.dart';

final sessionProvider = AsyncNotifierProvider.family<SessionNotifier, SessionState, String>((ref, sessionId) {
  return SessionNotifier(sessionId);
});

final questionProvider = FutureProvider.family<List<QuestionEntity>, SessionQuestionsParams>((ref, params) async {
  final packRepo = ref.read(packRepositoryProvider);
  return await packRepo.getRandomQuestions(
    subject: params.subject,
    topic: params.topic,
    count: params.count,
    excludeIds: params.excludeIds,
  );
});

class SessionNotifier extends FamilyAsyncNotifier<SessionState, String> {
  final String sessionId;
  final Uuid _uuid = const Uuid();

  SessionNotifier(this.sessionId);

  @override
  Future<SessionState> build(String arg) async {
    final sessionRepo = ref.read(sessionRepositoryProvider);
    final session = await sessionRepo.getSession(sessionId);
    
    if (session == null) {
      return SessionState.notFound();
    }

    final attempts = await sessionRepo.getSessionAttempts(sessionId);
    final packRepo = ref.read(packRepositoryProvider);
    
    // Get questions for this session
    final questions = <QuestionEntity>[];
    for (final questionId in session.questionIds) {
      // Find questions by iterating through packs (simplified approach)
      final allPacks = await packRepo.getInstalledPacks();
      bool found = false;
      for (final pack in allPacks) {
        final packQuestions = await packRepo.getQuestionsFromPack(pack.id);
        final question = packQuestions.where((q) => q.id == questionId).firstOrNull;
        if (question != null) {
          questions.add(question);
          found = true;
          break;
        }
      }
    }

    final progress = SessionProgress(
      currentIndex: 0,
      totalQuestions: questions.length,
      answeredQuestions: attempts.map((a) => a.questionId).toList(),
      flaggedQuestions: [],
      startTime: session.startedAt,
      timeLimit: session.mode == 'mock' ? const Duration(minutes: 60) : null,
    );

    return SessionState.loaded(
      session: session,
      questions: questions,
      attempts: attempts,
      progress: progress,
    );
  }

  Future<void> submitAnswer({
    required String questionId,
    required String selectedOption,
    required bool isCorrect,
    required int timeMs,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.isLoaded) return;

    final attempt = AttemptEntity(
      id: _uuid.v4(),
      sessionId: sessionId,
      questionId: questionId,
      chosen: selectedOption,
      correct: isCorrect,
      timeMs: timeMs,
      createdAt: DateTime.now(),
    );

    // Update local state immediately
    final updatedAttempts = [...currentState.attempts, attempt];
    final updatedProgress = currentState.progress.copyWith(
      answeredQuestions: [...currentState.progress.answeredQuestions, questionId],
    );

    state = AsyncValue.data(currentState.copyWith(
      attempts: updatedAttempts,
      progress: updatedProgress,
    ));

    // Submit to repository
    final sessionRepo = ref.read(sessionRepositoryProvider);
    await sessionRepo.submitAttempts(sessionId, [attempt]);
  }

  Future<void> flagQuestion(String questionId) async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.isLoaded) return;

    final updatedFlagged = [...currentState.progress.flaggedQuestions];
    if (updatedFlagged.contains(questionId)) {
      updatedFlagged.remove(questionId);
    } else {
      updatedFlagged.add(questionId);
    }

    final updatedProgress = currentState.progress.copyWith(
      flaggedQuestions: updatedFlagged,
    );

    state = AsyncValue.data(currentState.copyWith(
      progress: updatedProgress,
    ));
  }

  Future<void> navigateToQuestion(int index) async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.isLoaded) return;

    final updatedProgress = currentState.progress.copyWith(
      currentIndex: index,
    );

    state = AsyncValue.data(currentState.copyWith(
      progress: updatedProgress,
    ));
  }

  Future<void> completeSession() async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.isLoaded) return;

    final correctAttempts = currentState.attempts.where((a) => a.correct).length;
    final score = currentState.attempts.isNotEmpty 
        ? (correctAttempts / currentState.attempts.length * 100).round()
        : 0;

    final sessionRepo = ref.read(sessionRepositoryProvider);
    await sessionRepo.completeSession(sessionId, score);

    final completedSession = currentState.session.copyWith(
      endedAt: DateTime.now(),
      score: score,
    );

    state = AsyncValue.data(currentState.copyWith(
      session: completedSession,
    ));
  }
}

class SessionState {
  final SessionEntity? session;
  final List<QuestionEntity> questions;
  final List<AttemptEntity> attempts;
  final SessionProgress progress;
  final bool isLoaded;

  const SessionState({
    this.session,
    this.questions = const [],
    this.attempts = const [],
    required this.progress,
    this.isLoaded = false,
  });

  factory SessionState.notFound() {
    return SessionState(
      progress: SessionProgress(
        currentIndex: 0,
        totalQuestions: 0,
        answeredQuestions: [],
        flaggedQuestions: [],
      ),
    );
  }

  factory SessionState.loaded({
    required SessionEntity session,
    required List<QuestionEntity> questions,
    required List<AttemptEntity> attempts,
    required SessionProgress progress,
  }) {
    return SessionState(
      session: session,
      questions: questions,
      attempts: attempts,
      progress: progress,
      isLoaded: true,
    );
  }

  SessionState copyWith({
    SessionEntity? session,
    List<QuestionEntity>? questions,
    List<AttemptEntity>? attempts,
    SessionProgress? progress,
    bool? isLoaded,
  }) {
    return SessionState(
      session: session ?? this.session,
      questions: questions ?? this.questions,
      attempts: attempts ?? this.attempts,
      progress: progress ?? this.progress,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  QuestionEntity? get currentQuestion {
    if (progress.currentIndex < questions.length) {
      return questions[progress.currentIndex];
    }
    return null;
  }

  AttemptEntity? getAttemptForQuestion(String questionId) {
    return attempts.where((a) => a.questionId == questionId).firstOrNull;
  }
}

class SessionQuestionsParams {
  final String subject;
  final String? topic;
  final int count;
  final List<String>? excludeIds;

  const SessionQuestionsParams({
    required this.subject,
    this.topic,
    required this.count,
    this.excludeIds,
  });
}
