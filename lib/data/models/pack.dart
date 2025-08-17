import 'package:freezed_annotation/freezed_annotation.dart';

part 'pack.freezed.dart';
part 'pack.g.dart';

@freezed
class PackManifest with _$PackManifest {
  const factory PackManifest({
    required List<PackInfo> packs,
  }) = _PackManifest;

  factory PackManifest.fromJson(Map<String, dynamic> json) => _$PackManifestFromJson(json);
}

@freezed
class PackInfo with _$PackInfo {
  const factory PackInfo({
    required String id,
    required String subject,
    required String topic,
    required int version,
    @JsonKey(name: 'size_bytes') required int sizeBytes,
    String? checksum,
  }) = _PackInfo;

  factory PackInfo.fromJson(Map<String, dynamic> json) => _$PackInfoFromJson(json);
}

@freezed
class PackContent with _$PackContent {
  const factory PackContent({
    required String id,
    required String subject,
    required String topic,
    required int version,
    required List<PackItem> items,
  }) = _PackContent;

  factory PackContent.fromJson(Map<String, dynamic> json) => _$PackContentFromJson(json);
}

@freezed
class PackItem with _$PackItem {
  const factory PackItem({
    required String id,
    required String stem,
    required Map<String, String> options,
    required String correct,
    required String explanation,
    @Default(2) int difficulty,
    @JsonKey(name: 'syllabus_node') required String syllabusNode,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _PackItem;

  factory PackItem.fromJson(Map<String, dynamic> json) => _$PackItemFromJson(json);
}

// Extension for local database Pack entity
extension PackInfoExtension on PackInfo {
  String get displayName => '$subject - $topic';
  
  String get formattedSize {
    if (sizeBytes < 1024) return '${sizeBytes}B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
  
  bool get isLargeDownload => sizeBytes > 5 * 1024 * 1024; // 5MB
}
