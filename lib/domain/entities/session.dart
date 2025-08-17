import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';

@freezed
class SessionEntity with _$SessionEntity {
  const factory SessionEntity({
    required String id,
    required String mode,
    required String subject,
    String? topic,
    required DateTime startedAt,
    DateTime? endedAt,
    int? score,
    required List<String> questionIds,
  }) = _SessionEntity;

  const SessionEntity._();

  bool get isCompleted => endedAt != null;
  
  Duration get duration {
    if (endedAt != null) {
      return endedAt!.difference(startedAt);
    } else {
      return DateTime.now().difference(startedAt);
    }
  }

  String get formattedDuration {
    final duration = this.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  double? get scorePercentage {
    if (score == null || questionIds.isEmpty) return null;
    return (score! / questionIds.length) * 100;
  }

  String get modeDisplayName {
    switch (mode) {
      case 'practice':
        return 'Practice';
      case 'mock':
        return 'Mock Exam';
      default:
        return mode;
    }
  }
}

@freezed
class SessionProgress with _$SessionProgress {
  const factory SessionProgress({
    required int currentIndex,
    required int totalQuestions,
    required List<String> answeredQuestions,
    required List<String> flaggedQuestions,
    DateTime? startTime,
    Duration? timeLimit,
  }) = _SessionProgress;

  const SessionProgress._();

  bool get isCompleted => currentIndex >= totalQuestions;
  
  double get progressPercentage => 
      totalQuestions > 0 ? (currentIndex / totalQuestions) : 0.0;

  int get remainingQuestions => totalQuestions - currentIndex;
  
  bool isQuestionAnswered(String questionId) => 
      answeredQuestions.contains(questionId);
  
  bool isQuestionFlagged(String questionId) => 
      flaggedQuestions.contains(questionId);

  Duration? get remainingTime {
    if (timeLimit == null || startTime == null) return null;
    final elapsed = DateTime.now().difference(startTime!);
    final remaining = timeLimit! - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get isTimeUp {
    final remaining = remainingTime;
    return remaining != null && remaining <= Duration.zero;
  }
}
