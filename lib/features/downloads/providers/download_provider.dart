import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/repositories/pack_repository.dart';
import '../../../domain/entities/pack.dart';

final downloadProvider = AsyncNotifierProvider<DownloadNotifier, DownloadState>(() {
  return DownloadNotifier();
});

final installedPacksProvider = FutureProvider<List<PackEntity>>((ref) async {
  final packRepo = ref.read(packRepositoryProvider);
  return await packRepo.getInstalledPacks();
});

final availablePacksProvider = FutureProvider<List<PackManifestItem>>((ref) async {
  final packRepo = ref.read(packRepositoryProvider);
  
  try {
    // Get manifest for all subjects or specific subject
    final manifest = await packRepo.getPackManifest();
    return manifest;
  } catch (e) {
    // Return empty list if offline or error
    return <PackManifestItem>[];
  }
});

class DownloadNotifier extends AsyncNotifier<DownloadState> {
  @override
  Future<DownloadState> build() async {
    return const DownloadState();
  }

  Future<void> downloadPack(String packId) async {
    state = AsyncValue.data(state.valueOrNull?.copyWith(
      downloadingPacks: {...?state.valueOrNull?.downloadingPacks, packId},
      downloadProgress: {...?state.valueOrNull?.downloadProgress, packId: 0.0},
    ) ?? DownloadState(
      downloadingPacks: {packId},
      downloadProgress: {packId: 0.0},
    ));

    try {
      final packRepo = ref.read(packRepositoryProvider);
      await packRepo.downloadAndInstallPack(
        packId,
        onProgress: (progress) {
          final currentState = state.valueOrNull;
          if (currentState != null) {
            state = AsyncValue.data(currentState.copyWith(
              downloadProgress: {
                ...currentState.downloadProgress,
                packId: progress,
              },
            ));
          }
        },
      );

      // Download completed
      final currentState = state.valueOrNull;
      if (currentState != null) {
        final newDownloading = Set<String>.from(currentState.downloadingPacks)
          ..remove(packId);
        final newProgress = Map<String, double>.from(currentState.downloadProgress)
          ..remove(packId);

        state = AsyncValue.data(currentState.copyWith(
          downloadingPacks: newDownloading,
          downloadProgress: newProgress,
        ));
      }

      // Refresh installed packs
      ref.invalidate(installedPacksProvider);

    } catch (error, stackTrace) {
      // Remove from downloading state on error
      final currentState = state.valueOrNull;
      if (currentState != null) {
        final newDownloading = Set<String>.from(currentState.downloadingPacks)
          ..remove(packId);
        final newProgress = Map<String, double>.from(currentState.downloadProgress)
          ..remove(packId);

        state = AsyncValue.data(currentState.copyWith(
          downloadingPacks: newDownloading,
          downloadProgress: newProgress,
          error: error.toString(),
        ));
      }

      rethrow;
    }
  }

  Future<void> deletePack(String packId) async {
    try {
      final packRepo = ref.read(packRepositoryProvider);
      await packRepo.deletePack(packId);
      
      // Refresh installed packs
      ref.invalidate(installedPacksProvider);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshManifest() async {
    try {
      final packRepo = ref.read(packRepositoryProvider);
      await packRepo.updateLastSyncTime();
      
      // Refresh available packs
      ref.invalidate(availablePacksProvider);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearError() {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(error: null));
    }
  }
}

class DownloadState {
  final Set<String> downloadingPacks;
  final Map<String, double> downloadProgress;
  final String? error;

  const DownloadState({
    this.downloadingPacks = const {},
    this.downloadProgress = const {},
    this.error,
  });

  bool isDownloading(String packId) => downloadingPacks.contains(packId);
  
  double getProgress(String packId) => downloadProgress[packId] ?? 0.0;

  DownloadState copyWith({
    Set<String>? downloadingPacks,
    Map<String, double>? downloadProgress,
    String? error,
  }) {
    return DownloadState(
      downloadingPacks: downloadingPacks ?? this.downloadingPacks,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      error: error,
    );
  }
}
