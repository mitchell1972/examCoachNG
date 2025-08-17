import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/pack_repository.dart';
import '../../../domain/usecases/practice_usecase.dart';
import '../../../data/models/session_model.dart';
import '../../../domain/entities/question.dart';
import '../../../core/utils/logger.dart';

// Repository providers
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});

final packRepositoryProvider = Provider<PackRepository>((ref) {
  return PackRepository();
});

// Use case provider
final practiceUseCaseProvider = Provider<PracticeUseCase>((ref) {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final packRepo = ref.watch(packRepositoryProvider);
  return PracticeUseCase(sessionRepo, packRepo);
});

// Practice state
class PracticeState {
  final SessionModel? session;
  final List<Question> questions;
  final int currentQuestionIndex;
  final Map<String, String> answers;
  final Map<String, int> timings;
  final bool isLoading;
  final String? error;
  final bool isCompleted;

  const PracticeState({
    this.session,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.timings = const {},
    this.isLoading = false,
    this.error,
    this.isCompleted = false,
  });

  PracticeState copyWith({
    SessionModel? session,
    List<Question>? questions,
    int? currentQuestionIndex,
    Map<String, String>? answers,
    Map<String, int>? timings,
    bool? isLoading,
    String? error,
    bool? isCompleted,
  }) {
    return PracticeState(
      session: session ?? this.session,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      timings: timings ?? this.timings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Question? get currentQuestion {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[currentQuestionIndex];
  }

  String? get currentAnswer {
    final question = currentQuestion;
    if (question == null) return null;
    return answers[question.id];
  }

  bool get hasNext => currentQuestionIndex < questions.length - 1;
  bool get hasPrevious => currentQuestionIndex > 0;
  int get answeredCount => answers.length;
  double get progress => questions.isEmpty ? 0.0 : (currentQuestionIndex + 1) / questions.length;
}

// Practice notifier
class PracticeNotifier extends StateNotifier<PracticeState> {
  final PracticeUseCase _practiceUseCase;
  DateTime? _questionStartTime;

  PracticeNotifier(this._practiceUseCase) : super(const PracticeState());

  Future<void> startSession({
    required String subject,
    String? topic,
    int questionCount = 20,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final session = await _practiceUseCase.startPracticeSession(
        subject: subject,
        topic: topic,
        questionCount: questionCount,
      );

      final questions = await _practiceUseCase.getSessionQuestions(session.id);

      state = state.copyWith(
        session: session,
        questions: questions,
        isLoading: false,
        currentQuestionIndex: 0,
      );

      _startQuestionTimer();
      Logger.info('Practice session started: ${session.id}');
    } catch (e) {
      Logger.error('Failed to start practice session', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  void _startQuestionTimer() {
    _questionStartTime = DateTime.now();
  }

  void selectAnswer(String answer) {
    final question = state.currentQuestion;
    if (question == null) return;

    final newAnswers = Map<String, String>.from(state.answers);
    newAnswers[question.id] = answer;

    state = state.copyWith(answers: newAnswers);
  }

  Future<void> submitCurrentAnswer() async {
    final question = state.currentQuestion;
    final session = state.session;
    final answer = state.currentAnswer;

    if (question == null || session == null || answer == null) return;

    try {
      final timeSpent = _getQuestionTime();
      
      await _practiceUseCase.submitAnswer(
        sessionId: session.id,
        questionId: question.id,
        selectedAnswer: answer,
        timeSpentMs: timeSpent,
      );

      // Record timing
      final newTimings = Map<String, int>.from(state.timings);
      newTimings[question.id] = timeSpent;
      state = state.copyWith(timings: newTimings);

      Logger.debug('Answer submitted for question: ${question.id}');
    } catch (e) {
      Logger.error('Failed to submit answer', error: e);
      // Don't update state with error for individual answer submission
      // The answer is still recorded locally
    }
  }

  int _getQuestionTime() {
    if (_questionStartTime == null) return 0;
    return DateTime.now().difference(_questionStartTime!).inMilliseconds;
  }

  void nextQuestion() {
    if (!state.hasNext) return;

    submitCurrentAnswer();
    
    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
    
    _startQuestionTimer();
  }

  void previousQuestion() {
    if (!state.hasPrevious) return;

    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex - 1,
    );
    
    _startQuestionTimer();
  }

  void goToQuestion(int index) {
    if (index < 0 || index >= state.questions.length) return;

    if (index == state.currentQuestionIndex) return;

    // Submit current answer if moving to different question
    if (state.currentAnswer != null) {
      submitCurrentAnswer();
    }

    state = state.copyWith(currentQuestionIndex: index);
    _startQuestionTimer();
  }

  Future<SessionResult?> completeSession() async {
    final session = state.session;
    if (session == null) return null;

    try {
      state = state.copyWith(isLoading: true);

      // Submit final answer if exists
      if (state.currentAnswer != null) {
        await submitCurrentAnswer();
      }

      final result = await _practiceUseCase.completeSession(session.id);
      
      state = state.copyWith(
        isLoading: false,
        isCompleted: true,
      );

      Logger.info('Practice session completed: ${session.id}');
      return result;
    } catch (e) {
      Logger.error('Failed to complete session', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      return null;
    }
  }

  Future<List<String>> getAvailableTopics(String subject) async {
    try {
      return await _practiceUseCase.getAvailableTopics(subject);
    } catch (e) {
      Logger.error('Failed to get available topics', error: e);
      return [];
    }
  }

  Future<Map<String, int>> getTopicQuestionCounts(String subject) async {
    try {
      return await _practiceUseCase.getTopicQuestionCounts(subject);
    } catch (e) {
      Logger.error('Failed to get topic question counts', error: e);
      return {};
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetSession() {
    state = const PracticeState();
    _questionStartTime = null;
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}

// Practice provider
final practiceProvider = StateNotifierProvider<PracticeNotifier, PracticeState>((ref) {
  final practiceUseCase = ref.watch(practiceUseCaseProvider);
  return PracticeNotifier(practiceUseCase);
});

// Convenience providers
final currentQuestionProvider = Provider<Question?>((ref) {
  return ref.watch(practiceProvider).currentQuestion;
});

final practiceProgressProvider = Provider<double>((ref) {
  return ref.watch(practiceProvider).progress;
});

final practiceIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(practiceProvider).isLoading;
});

final practiceErrorProvider = Provider<String?>((ref) {
  return ref.watch(practiceProvider).error;
});

// Topic-specific providers
final topicsProvider = FutureProvider.family<List<String>, String>((ref, subject) async {
  final practiceUseCase = ref.watch(practiceUseCaseProvider);
  return practiceUseCase.getAvailableTopics(subject);
});

final topicCountsProvider = FutureProvider.family<Map<String, int>, String>((ref, subject) async {
  final practiceUseCase = ref.watch(practiceUseCaseProvider);
  return practiceUseCase.getTopicQuestionCounts(subject);
});
