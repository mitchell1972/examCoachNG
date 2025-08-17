import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/repositories/session_repository.dart';
import '../../../domain/entities/session.dart';
import '../../../core/utils/constants.dart';

final mockProvider = AsyncNotifierProvider.family<MockNotifier, MockState, String>((ref, subject) {
  return MockNotifier(subject);
});

class MockNotifier extends FamilyAsyncNotifier<MockState, String> {
  final String subject;

  MockNotifier(this.subject);

  @override
  Future<MockState> build(String arg) async {
    return MockState.initial();
  }

  Future<String> startMockExam() async {
    state = const AsyncValue.loading();

    try {
      final sessionRepo = ref.read(sessionRepositoryProvider);
      final session = await sessionRepo.createSession(
        mode: 'mock',
        subject: subject,
        topic: null,
        count: AppConstants.mockExamQuestions,
      );

      state = AsyncValue.data(MockState.started(
        sessionId: session.id,
        startTime: DateTime.now(),
        timeLimit: const Duration(minutes: AppConstants.mockExamDurationMinutes),
      ));

      return session.id;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  void updateRemainingTime(Duration remaining) {
    final currentState = state.valueOrNull;
    if (currentState != null && currentState.isStarted) {
      state = AsyncValue.data(currentState.copyWith(
        remainingTime: remaining,
      ));
    }
  }

  Future<void> pauseExam() async {
    final currentState = state.valueOrNull;
    if (currentState != null && currentState.isStarted) {
      state = AsyncValue.data(currentState.copyWith(
        isPaused: true,
      ));
    }
  }

  Future<void> resumeExam() async {
    final currentState = state.valueOrNull;
    if (currentState != null && currentState.isStarted) {
      state = AsyncValue.data(currentState.copyWith(
        isPaused: false,
      ));
    }
  }

  Future<void> submitExam() async {
    final currentState = state.valueOrNull;
    if (currentState?.sessionId != null) {
      final sessionRepo = ref.read(sessionRepositoryProvider);
      // The session completion will be handled by the session provider
    }
  }
}

class MockState {
  final String? sessionId;
  final DateTime? startTime;
  final Duration? timeLimit;
  final Duration? remainingTime;
  final bool isPaused;

  const MockState({
    this.sessionId,
    this.startTime,
    this.timeLimit,
    this.remainingTime,
    this.isPaused = false,
  });

  factory MockState.initial() {
    return const MockState();
  }

  factory MockState.started({
    required String sessionId,
    required DateTime startTime,
    required Duration timeLimit,
  }) {
    return MockState(
      sessionId: sessionId,
      startTime: startTime,
      timeLimit: timeLimit,
      remainingTime: timeLimit,
    );
  }

  bool get isStarted => sessionId != null;
  
  bool get isTimeUp => remainingTime != null && remainingTime!.inSeconds <= 0;

  MockState copyWith({
    String? sessionId,
    DateTime? startTime,
    Duration? timeLimit,
    Duration? remainingTime,
    bool? isPaused,
  }) {
    return MockState(
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      timeLimit: timeLimit ?? this.timeLimit,
      remainingTime: remainingTime ?? this.remainingTime,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}
