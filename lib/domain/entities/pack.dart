import 'package:freezed_annotation/freezed_annotation.dart';

part 'pack.freezed.dart';

@freezed
class PackEntity with _$PackEntity {
  const factory PackEntity({
    required String id,
    required String subject,
    required String topic,
    required int version,
    required int sizeBytes,
    DateTime? installedAt,
  }) = _PackEntity;

  const PackEntity._();

  bool get isInstalled => installedAt != null;
  
  String get formattedSize {
    final sizeInMB = sizeBytes / (1024 * 1024);
    if (sizeInMB >= 1) {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    } else {
      final sizeInKB = sizeBytes / 1024;
      return '${sizeInKB.toStringAsFixed(0)} KB';
    }
  }
}

@freezed
class PackManifestItem with _$PackManifestItem {
  const factory PackManifestItem({
    required String id,
    required String subject,
    required String topic,
    required int version,
    required int sizeBytes,
    String? checksum,
  }) = _PackManifestItem;

  const PackManifestItem._();

  String get formattedSize {
    final sizeInMB = sizeBytes / (1024 * 1024);
    if (sizeInMB >= 1) {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    } else {
      final sizeInKB = sizeBytes / 1024;
      return '${sizeInKB.toStringAsFixed(0)} KB';
    }
  }
}

@freezed
class PackDownloadState with _$PackDownloadState {
  const factory PackDownloadState({
    @Default(false) bool isDownloading,
    @Default(0.0) double progress,
    String? error,
  }) = _PackDownloadState;
}
