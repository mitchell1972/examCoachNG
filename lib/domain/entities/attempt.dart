import 'package:freezed_annotation/freezed_annotation.dart';

part 'attempt.freezed.dart';

@freezed
class AttemptEntity with _$AttemptEntity {
  const factory AttemptEntity({
    required String id,
    required String sessionId,
    required String questionId,
    required String chosen,
    required bool correct,
    required int timeMs,
    required DateTime createdAt,
  }) = _AttemptEntity;

  const AttemptEntity._();

  Duration get timeTaken => Duration(milliseconds: timeMs);

  String get formattedTime {
    final seconds = timeMs / 1000;
    if (seconds < 60) {
      return '${seconds.toStringAsFixed(1)}s';
    } else {
      final minutes = (seconds / 60).floor();
      final remainingSeconds = (seconds % 60).floor();
      return '${minutes}m ${remainingSeconds}s';
    }
  }

  String get resultIcon => correct ? '✓' : '✗';
  
  String get resultText => correct ? 'Correct' : 'Incorrect';
}

@freezed
class AttemptSummary with _$AttemptSummary {
  const factory AttemptSummary({
    required int totalAttempts,
    required int correctAttempts,
    required int incorrectAttempts,
    required double accuracy,
    required Duration averageTime,
    required Duration totalTime,
    Map<String, int>? topicBreakdown,
  }) = _AttemptSummary;

  const AttemptSummary._();

  String get formattedAccuracy => '${(accuracy * 100).toStringAsFixed(1)}%';
  
  String get formattedAverageTime {
    final seconds = averageTime.inMilliseconds / 1000;
    return '${seconds.toStringAsFixed(1)}s';
  }

  String get formattedTotalTime {
    final minutes = totalTime.inMinutes;
    final seconds = totalTime.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String get grade {
    final percentage = accuracy * 100;
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }
}
