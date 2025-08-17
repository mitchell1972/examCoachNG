import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/pack_repository.dart';
import '../../../domain/usecases/practice_usecase.dart';
import '../../../data/models/session_model.dart';
import '../../../domain/entities/question.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/app_constants.dart';

// Mock state
class MockState {
  final SessionModel? session;
  final List<Question> questions;
  final int currentQuestionIndex;
  final Map<String, String> answers;
  final Set<String> flaggedQuestions;
  final Duration? timeRemaining;
  final bool isPaused;
  final bool isLoading;
  final String? error;
  final bool isCompleted;
  final bool isSubmitted;

  const MockState({
    this.session,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.flaggedQuestions = const {},
    this.timeRemaining,
    this.isPaused = false,
    this.isLoading = false,
    this.error,
    this.isCompleted = false,
    this.isSubmitted = false,
  });

  MockState copyWith({
    SessionModel? session,
    List<Question>? questions,
    int? currentQuestionIndex,
    Map<String, String>? answers,
    Set<String>? flaggedQuestions,
    Duration? timeRemaining,
    bool? isPaused,
    bool? isLoading,
    String? error,
    bool? isCompleted,
    bool? isSubmitted,
  }) {
    return MockState(
      session: session ?? this.session,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      flaggedQuestions: flaggedQuestions ?? this.flaggedQuestions,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isPaused: isPaused ?? this.isPaused,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isCompleted: isCompleted ?? this.isCompleted,
      isSubmitted: isSubmitted ?? this.isSubmitted,
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
  int get flaggedCount => flaggedQuestions.length;
  double get progress => questions.isEmpty ? 0.0 : (currentQuestionIndex + 1) / questions.length;
  
  bool get isTimeUp => timeRemaining != null && timeRemaining! <= Duration.zero;
}

// Mock notifier
class MockNotifier extends StateNotifier<MockState> {
  final PracticeUseCase _practiceUseCase;
  Timer? _timer;
  DateTime? _sessionEndTime;

  MockNotifier(this._practiceUseCase) : super(const MockState());

  Future<void> startSession({
    required String subject,
    int questionCount = AppConstants.mockQuestionCount,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final session = await _practiceUseCase.startMockSession(
        subject: subject,
        questionCount: questionCount,
      );

      final questions = await _practiceUseCase.getSessionQuestions(session.id);

      // Calculate end time
      _sessionEndTime = DateTime.now().add(const Duration(minutes: AppConstants.mockExamDuration));
      
      state = state.copyWith(
        session: session,
        questions: questions,
        isLoading: false,
        currentQuestionIndex: 0,
        timeRemaining: const Duration(minutes: AppConstants.mockExamDuration),
      );

      _startTimer();
      Logger.info('Mock session started: ${session.id}');
    } catch (e) {
      Logger.error('Failed to start mock session', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isPaused || _sessionEndTime == null) return;

      final now = DateTime.now();
      final remaining = _sessionEndTime!.difference(now);

      if (remaining <= Duration.zero) {
        // Time's up - auto submit
        timer.cancel();
        state = state.copyWith(
          timeRemaining: Duration.zero,
          isCompleted: true,
        );
        _autoSubmitSession();
      } else {
        state = state.copyWith(timeRemaining: remaining);
      }
    });
  }

  void pauseTimer() {
    state = state.copyWith(isPaused: true);
  }

  void resumeTimer() {
    state = state.copyWith(isPaused: false);
  }

  void selectAnswer(String answer) {
    final question = state.currentQuestion;
    if (question == null || state.isCompleted) return;

    final newAnswers = Map<String, String>.from(state.answers);
    newAnswers[question.id] = answer;

    state = state.copyWith(answers: newAnswers);
    
    // Auto-save answer
    _submitAnswer(question.id, answer);
  }

  void toggleFlag() {
    final question = state.currentQuestion;
    if (question == null) return;

    final newFlagged = Set<String>.from(state.flaggedQuestions);
    if (newFlagged.contains(question.id)) {
      newFlagged.remove(question.id);
    } else {
      newFlagged.add(question.id);
    }

    state = state.copyWith(flaggedQuestions: newFlagged);
  }

  Future<void> _submitAnswer(String questionId, String answer) async {
    final session = state.session;
    if (session == null) return;

    try {
      await _practiceUseCase.submitAnswer(
        sessionId: session.id,
        questionId: questionId,
        selectedAnswer: answer,
        timeSpentMs: 1000, // Mock timing for now
      );
    } catch (e) {
      Logger.error('Failed to submit answer', error: e);
      // Don't update state - answer is still recorded locally
    }
  }

  void goToQuestion(int index) {
    if (index < 0 || index >= state.questions.length || state.isCompleted) return;
    state = state.copyWith(currentQuestionIndex: index);
  }

  void nextQuestion() {
    if (!state.hasNext || state.isCompleted) return;
    state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
  }

  void previousQuestion() {
    if (!state.hasPrevious || state.isCompleted) return;
    state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
  }

  Future<void> _autoSubmitSession() async {
    final session = state.session;
    if (session == null || state.isSubmitted) return;

    try {
      await _practiceUseCase.completeSession(session.id);
      state = state.copyWith(isSubmitted: true);
      Logger.info('Mock session auto-submitted due to timeout');
    } catch (e) {
      Logger.error('Failed to auto-submit session', error: e);
    }
  }

  Future<SessionResult?> submitSession() async {
    final session = state.session;
    if (session == null || state.isSubmitted) return null;

    try {
      state = state.copyWith(isLoading: true);
      
      _timer?.cancel();
      
      final result = await _practiceUseCase.completeSession(session.id);
      
      state = state.copyWith(
        isLoading: false,
        isCompleted: true,
        isSubmitted: true,
      );

      Logger.info('Mock session submitted: ${session.id}');
      return result;
    } catch (e) {
      Logger.error('Failed to submit session', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetSession() {
    _timer?.cancel();
    _sessionEndTime = null;
    state = const MockState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}

// Mock provider
final mockProvider = StateNotifierProvider<MockNotifier, MockState>((ref) {
  final practiceUseCase = ref.watch(practiceUseCaseProvider);
  return MockNotifier(practiceUseCase);
});

// Convenience providers
final currentMockQuestionProvider = Provider<Question?>((ref) {
  return ref.watch(mockProvider).currentQuestion;
});

final mockTimeRemainingProvider = Provider<Duration?>((ref) {
  return ref.watch(mockProvider).timeRemaining;
});

final mockIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(mockProvider).isLoading;
});

final mockErrorProvider = Provider<String?>((ref) {
  return ref.watch(mockProvider).error;
});

final mockProgressProvider = Provider<double>((ref) {
  return ref.watch(mockProvider).progress;
});
