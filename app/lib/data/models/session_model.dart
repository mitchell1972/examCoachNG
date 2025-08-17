import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/session.dart' as domain;

part 'session_model.freezed.dart';
part 'session_model.g.dart';

enum SessionMode { practice, mock }

@freezed
class SessionModel with _$SessionModel {
  const factory SessionModel({
    required String id,
    required SessionMode mode,
    required String subject,
    String? topic,
    required DateTime startedAt,
    DateTime? endedAt,
    Duration? duration,
    int? score,
    @Default([]) List<String> questions,
    Map<String, dynamic>? meta,
  }) = _SessionModel;

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);
}

extension SessionModelX on SessionModel {
  domain.Session toEntity() {
    return domain.Session(
      id: id,
      mode: mode == SessionMode.practice ? domain.SessionMode.practice : domain.SessionMode.mock,
      subject: subject,
      topic: topic,
      startedAt: startedAt,
      endedAt: endedAt,
      duration: duration,
      score: score,
      questions: questions,
      meta: meta,
    );
  }
}
