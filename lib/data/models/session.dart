import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';
part 'session.g.dart';

@freezed
class SessionModel with _$SessionModel {
  const factory SessionModel({
    required String id,
    required String mode, // practice | mock
    required String subject,
    String? topic,
    @JsonKey(name: 'started_at') required DateTime startedAt,
    @JsonKey(name: 'ended_at') DateTime? endedAt,
    int? score,
    @JsonKey(name: 'total_questions') @Default(0) int totalQuestions,
    @JsonKey(name: 'correct_answers') @Default(0) int correctAnswers,
    @JsonKey(name: 'time_spent_ms') int? timeSpentMs,
    @JsonKey(name: 'is_completed') @Default(false) bool isCompleted,
    @JsonKey(name: 'is_synced') @Default(false) bool isSynced,
    @JsonKey(name: 'meta_json') String? metaJson,
  }) = _SessionModel;

  factory SessionModel.fromJson(Map<String, dynamic> json) => _$SessionModelFromJson(json);
}

@freezed
class AttemptModel with _$AttemptModel {
  const factory AttemptModel({
    required String id,
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'question_id') required String questionId,
    required String chosen,
    required bool correct,
    @JsonKey(name: 'time_ms') required int timeMs,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'is_synced') @Default(false) bool isSynced,
  }) = _AttemptModel;

  factory AttemptModel.fromJson(Map<String, dynamic> json) => _$AttemptModelFromJson(json);
}

extension SessionModelExtension on SessionModel {
  Duration? get duration {
    if (endedAt != null) {
      return endedAt!.difference(startedAt);
    }
    return null;
  }
  
  Duration get timeSpent => Duration(milliseconds: timeSpentMs ?? 0);
  
  double get accuracy {
    if (totalQuestions == 0) return 0.0;
    return correctAnswers / totalQuestions;
  }
  
  String get formattedDuration {
    final dur = duration ?? timeSpent;
    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);
    final seconds = dur.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  bool get isPracticeMode => mode == 'practice';
  bool get isMockMode => mode == 'mock';
  
  SessionType get sessionType => isPracticeMode ? SessionType.practice : SessionType.mock;
}

extension AttemptModelExtension on AttemptModel {
  Duration get responseTime => Duration(milliseconds: timeMs);
  
  String get formattedResponseTime {
    final seconds = responseTime.inSeconds;
    if (seconds < 60) {
      return '${seconds}s';
    } else {
      final minutes = responseTime.inMinutes;
      final remainingSeconds = seconds.remainder(60);
      return '${minutes}m ${remainingSeconds}s';
    }
  }
}

enum SessionType {
  practice,
  mock;
  
  String get displayName {
    switch (this) {
      case SessionType.practice: return 'Practice';
      case SessionType.mock: return 'Mock Exam';
    }
  }
  
  String get icon {
    switch (this) {
      case SessionType.practice: return '📚';
      case SessionType.mock: return '🎯';
    }
  }
}
