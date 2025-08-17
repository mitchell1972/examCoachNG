import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/pack.dart';

part 'pack_dto.freezed.dart';
part 'pack_dto.g.dart';

@freezed
class PackManifestDto with _$PackManifestDto {
  const factory PackManifestDto({
    required List<PackManifestItemDto> packs,
  }) = _PackManifestDto;

  factory PackManifestDto.fromJson(Map<String, dynamic> json) =>
      _$PackManifestDtoFromJson(json);
}

@freezed
class PackManifestItemDto with _$PackManifestItemDto {
  const factory PackManifestItemDto({
    required String id,
    required String subject,
    required String topic,
    required int version,
    @JsonKey(name: 'size_bytes') required int sizeBytes,
    String? checksum,
  }) = _PackManifestItemDto;

  factory PackManifestItemDto.fromJson(Map<String, dynamic> json) =>
      _$PackManifestItemDtoFromJson(json);
}

@freezed
class PackContentDto with _$PackContentDto {
  const factory PackContentDto({
    required String id,
    required String subject,
    required String topic,
    required int version,
    required List<QuestionItemDto> items,
  }) = _PackContentDto;

  factory PackContentDto.fromJson(Map<String, dynamic> json) =>
      _$PackContentDtoFromJson(json);
}

@freezed
class QuestionItemDto with _$QuestionItemDto {
  const factory QuestionItemDto({
    required String id,
    required String stem,
    required Map<String, String> options,
    required String correct,
    required String explanation,
    required int difficulty,
    @JsonKey(name: 'syllabus_node') required String syllabusNode,
  }) = _QuestionItemDto;

  factory QuestionItemDto.fromJson(Map<String, dynamic> json) =>
      _$QuestionItemDtoFromJson(json);
}

extension PackManifestItemDtoExtension on PackManifestItemDto {
  PackManifestItem toDomain() {
    return PackManifestItem(
      id: id,
      subject: subject,
      topic: topic,
      version: version,
      sizeBytes: sizeBytes,
      checksum: checksum,
    );
  }
}
