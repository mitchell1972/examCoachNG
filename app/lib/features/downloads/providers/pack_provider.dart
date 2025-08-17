import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/repositories/pack_repository.dart';
import '../../../data/models/pack_model.dart';
import '../../../data/db/database.dart';
import '../../../core/utils/logger.dart';

// Pack state
class PackState {
  final List<PackModel> availablePacks;
  final List<Pack> installedPacks;
  final bool isLoading;
  final String? error;

  const PackState({
    this.availablePacks = const [],
    this.installedPacks = const [],
    this.isLoading = false,
    this.error,
  });

  PackState copyWith({
    List<PackModel>? availablePacks,
    List<Pack>? installedPacks,
    bool? isLoading,
    String? error,
  }) {
    return PackState(
      availablePacks: availablePacks ?? this.availablePacks,
      installedPacks: installedPacks ?? this.installedPacks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Download states
enum DownloadStatus { queued, downloading, paused, completed, failed }

class DownloadItem {
  final String packId;
  final String packName;
  final DownloadStatus status;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;

  DownloadItem({
    required this.packId,
    required this.packName,
    required this.status,
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
  });

  DownloadItem copyWith({
    DownloadStatus? status,
    double? progress,
    int? downloadedBytes,
    int? totalBytes,
  }) {
    return DownloadItem(
      packId: packId,
      packName: packName,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }
}

// Pack notifier
class PackNotifier extends StateNotifier<PackState> {
  final PackRepository _packRepository;
  final AppDatabase _database = AppDatabase();
  final Map<String, DownloadItem> _downloadQueue = {};

  PackNotifier(this._packRepository) : super(const PackState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await loadInstalledPacks();
    await loadAvailablePacks();
  }

  Future<void> loadAvailablePacks() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Load manifest for all subjects
      final allPacks = <PackModel>[];
      for (final subject in ['ENG', 'MAT', 'PHY', 'CHE', 'BIO']) {
        try {
          final manifest = await _packRepository.getPackManifest(subject: subject);
          allPacks.addAll(manifest.packs);
        } catch (e) {
          Logger.warning('Failed to load packs for subject $subject', error: e);
        }
      }
      
      state = state.copyWith(
        availablePacks: allPacks,
        isLoading: false,
      );
      
      Logger.info('Loaded ${allPacks.length} available packs');
    } catch (e) {
      Logger.error('Failed to load available packs', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  Future<void> loadInstalledPacks() async {
    try {
      final installedPacks = await _packRepository.getInstalledPacks();
      state = state.copyWith(installedPacks: installedPacks);
      Logger.info('Loaded ${installedPacks.length} installed packs');
    } catch (e) {
      Logger.error('Failed to load installed packs', error: e);
    }
  }

  Future<void> downloadPack(PackModel pack) async {
    try {
      // Add to download queue
      _downloadQueue[pack.id] = DownloadItem(
        packId: pack.id,
        packName: '${pack.subject} - ${pack.topic}',
        status: DownloadStatus.queued,
      );
      
      // Start download
      _downloadQueue[pack.id] = _downloadQueue[pack.id]!.copyWith(
        status: DownloadStatus.downloading,
      );
      
      Logger.info('Starting download for pack: ${pack.id}');
      
      // Download and install pack
      await _packRepository.downloadAndInstallPack(pack);
      
      // Update download queue
      _downloadQueue[pack.id] = _downloadQueue[pack.id]!.copyWith(
        status: DownloadStatus.completed,
        progress: 1.0,
      );
      
      // Refresh installed packs
      await loadInstalledPacks();
      
      Logger.info('Pack downloaded and installed: ${pack.id}');
      
      // Remove from queue after a delay
      Future.delayed(const Duration(seconds: 2), () {
        _downloadQueue.remove(pack.id);
      });
      
    } catch (e) {
      Logger.error('Failed to download pack: ${pack.id}', error: e);
      
      if (_downloadQueue.containsKey(pack.id)) {
        _downloadQueue[pack.id] = _downloadQueue[pack.id]!.copyWith(
          status: DownloadStatus.failed,
        );
      }
    }
  }

  Future<void> deletePack(String packId) async {
    try {
      await _packRepository.deletePack(packId);
      await loadInstalledPacks();
      Logger.info('Pack deleted: $packId');
    } catch (e) {
      Logger.error('Failed to delete pack: $packId', error: e);
      state = state.copyWith(error: _getErrorMessage(e));
    }
  }

  Future<void> checkForUpdates(String packId) async {
    try {
      // Find installed pack
      final installedPack = state.installedPacks
          .where((pack) => pack.id == packId)
          .firstOrNull;
      
      if (installedPack == null) {
        throw Exception('Pack not found: $packId');
      }
      
      // Check for updates
      final hasUpdate = await _packRepository.isPackUpdateAvailable(
        packId,
        installedPack.version,
      );
      
      if (hasUpdate) {
        // Find the updated pack in available packs
        final updatedPack = state.availablePacks
            .where((pack) => pack.id == packId)
            .firstOrNull;
        
        if (updatedPack != null) {
          // Show update dialog or automatically download
          await downloadPack(updatedPack);
        }
      } else {
        Logger.info('No updates available for pack: $packId');
      }
    } catch (e) {
      Logger.error('Failed to check for updates: $packId', error: e);
      state = state.copyWith(error: _getErrorMessage(e));
    }
  }

  void pauseDownload(String packId) {
    if (_downloadQueue.containsKey(packId)) {
      _downloadQueue[packId] = _downloadQueue[packId]!.copyWith(
        status: DownloadStatus.paused,
      );
      Logger.info('Download paused: $packId');
    }
  }

  void cancelDownload(String packId) {
    _downloadQueue.remove(packId);
    Logger.info('Download cancelled: $packId');
  }

  void clearQueue() {
    _downloadQueue.clear();
    Logger.info('Download queue cleared');
  }

  Future<void> cleanup() async {
    try {
      // TODO: Implement cleanup logic
      // - Remove temporary files
      // - Clear cache
      // - Optimize database
      Logger.info('Cleanup completed');
    } catch (e) {
      Logger.error('Cleanup failed', error: e);
    }
  }

  List<DownloadItem> get downloadQueue => _downloadQueue.values.toList();

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}

// Pack provider
final packRepositoryProvider = Provider<PackRepository>((ref) {
  return PackRepository();
});

final packProvider = StateNotifierProvider<PackNotifier, PackState>((ref) {
  final packRepository = ref.watch(packRepositoryProvider);
  return PackNotifier(packRepository);
});

// Convenience providers
final availablePacksProvider = Provider<List<PackModel>>((ref) {
  return ref.watch(packProvider).availablePacks;
});

final installedPacksProvider = FutureProvider<List<Pack>>((ref) async {
  final packRepository = ref.watch(packRepositoryProvider);
  return packRepository.getInstalledPacks();
});

final downloadQueueProvider = Provider<List<DownloadItem>>((ref) {
  final packNotifier = ref.watch(packProvider.notifier);
  return packNotifier.downloadQueue;
});

final packIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(packProvider).isLoading;
});

final packErrorProvider = Provider<String?>((ref) {
  return ref.watch(packProvider).error;
});
