enum SessionMode { practice, mock }

class Session {
  final String id;
  final SessionMode mode;
  final String subject;
  final String? topic;
  final DateTime startedAt;
  final DateTime? endedAt;
  final Duration? duration;
  final int? score;
  final List<String> questions;
  final Map<String, dynamic>? meta;

  const Session({
    required this.id,
    required this.mode,
    required this.subject,
    this.topic,
    required this.startedAt,
    this.endedAt,
    this.duration,
    this.score,
    this.questions = const [],
    this.meta,
  });

  Session copyWith({
    String? id,
    SessionMode? mode,
    String? subject,
    String? topic,
    DateTime? startedAt,
    DateTime? endedAt,
    Duration? duration,
    int? score,
    List<String>? questions,
    Map<String, dynamic>? meta,
  }) {
    return Session(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      duration: duration ?? this.duration,
      score: score ?? this.score,
      questions: questions ?? this.questions,
      meta: meta ?? this.meta,
    );
  }

  bool get isCompleted => endedAt != null;
  bool get isInProgress => !isCompleted;
  bool get isPracticeMode => mode == SessionMode.practice;
  bool get isMockMode => mode == SessionMode.mock;
  
  int get questionCount => questions.length;
  
  double get accuracy {
    if (score == null || questionCount == 0) return 0.0;
    return score! / questionCount;
  }
  
  Duration get elapsedTime {
    if (isCompleted && endedAt != null) {
      return endedAt!.difference(startedAt);
    }
    return DateTime.now().difference(startedAt);
  }
  
  Duration? get timeRemaining {
    if (!isMockMode || duration == null) return null;
    final elapsed = elapsedTime;
    final remaining = duration! - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Session &&
      other.id == id &&
      other.mode == mode &&
      other.subject == subject &&
      other.topic == topic &&
      other.startedAt == startedAt &&
      other.endedAt == endedAt &&
      other.duration == duration &&
      other.score == score &&
      other.questions == questions &&
      other.meta == meta;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      mode.hashCode ^
      subject.hashCode ^
      topic.hashCode ^
      startedAt.hashCode ^
      endedAt.hashCode ^
      duration.hashCode ^
      score.hashCode ^
      questions.hashCode ^
      meta.hashCode;
  }
}
