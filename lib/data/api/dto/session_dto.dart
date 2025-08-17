import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_dto.freezed.dart';
part 'session_dto.g.dart';

@freezed
class SessionResponseDto with _$SessionResponseDto {
  const factory SessionResponseDto({
    @JsonKey(name: 'session_id') required String sessionId,
    required List<SessionItemDto> items,
  }) = _SessionResponseDto;

  factory SessionResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SessionResponseDtoFromJson(json);
}

@freezed
class SessionItemDto with _$SessionItemDto {
  const factory SessionItemDto({
    @JsonKey(name: 'question_id') required String questionId,
  }) = _SessionItemDto;

  factory SessionItemDto.fromJson(Map<String, dynamic> json) =>
      _$SessionItemDtoFromJson(json);
}

@freezed
class AttemptDto with _$AttemptDto {
  const factory AttemptDto({
    @JsonKey(name: 'question_id') required String questionId,
    required String chosen,
    required bool correct,
    @JsonKey(name: 'time_ms') required int timeMs,
  }) = _AttemptDto;

  factory AttemptDto.fromJson(Map<String, dynamic> json) =>
      _$AttemptDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AttemptDtoToJson(this);
}

@freezed
class SubjectDto with _$SubjectDto {
  const factory SubjectDto({
    required String id,
    required String name,
  }) = _SubjectDto;

  factory SubjectDto.fromJson(Map<String, dynamic> json) =>
      _$SubjectDtoFromJson(json);
}

@freezed
class SyllabusNodeDto with _$SyllabusNodeDto {
  const factory SyllabusNodeDto({
    @JsonKey(name: 'node_id') required String nodeId,
    required String name,
    @JsonKey(name: 'parent_node_id') String? parentNodeId,
    List<String>? objectives,
  }) = _SyllabusNodeDto;

  factory SyllabusNodeDto.fromJson(Map<String, dynamic> json) =>
      _$SyllabusNodeDtoFromJson(json);
}
