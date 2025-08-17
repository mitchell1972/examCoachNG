import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/download_provider.dart';
import '../widgets/pack_item.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/error_widget.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(downloadProvider);
    final installedPacksAsync = ref.watch(installedPacksProvider);
    final availablePacksAsync = ref.watch(availablePacksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(downloadProvider.notifier).refreshManifest();
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: const [
                Tab(text: 'Installed'),
                Tab(text: 'Available'),
              ],
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Installed packs tab
                  installedPacksAsync.when(
                    loading: () => const Center(child: LoadingIndicator()),
                    error: (error, stackTrace) => AppErrorWidget(
                      error: error.toString(),
                      onRetry: () => ref.refresh(installedPacksProvider),
                    ),
                    data: (packs) {
                      if (packs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.download,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No downloaded packs',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Download question packs to practice offline',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: packs.length,
                        itemBuilder: (context, index) {
                          final pack = packs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PackItem(
                              packId: pack.id,
                              title: pack.topic,
                              subject: pack.subject,
                              version: 'v${pack.version}',
                              size: pack.formattedSize,
                              isInstalled: true,
                              onDownload: null,
                              onDelete: () => _showDeleteDialog(context, ref, pack),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // Available packs tab
                  availablePacksAsync.when(
                    loading: () => const Center(child: LoadingIndicator()),
                    error: (error, stackTrace) => AppErrorWidget(
                      error: 'Failed to load available packs.\nMake sure you have an internet connection.',
                      onRetry: () => ref.refresh(availablePacksProvider),
                    ),
                    data: (availablePacks) {
                      return installedPacksAsync.when(
                        loading: () => const Center(child: LoadingIndicator()),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (installedPacks) {
                          final installedIds = installedPacks.map((p) => p.id).toSet();
                          final uninstalledPacks = availablePacks
                              .where((pack) => !installedIds.contains(pack.id))
                              .toList();

                          if (uninstalledPacks.isEmpty && availablePacks.isNotEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 64,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'All packs installed',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'You have downloaded all available question packs',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          if (availablePacks.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_off,
                                    size: 64,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No packs available',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Check your internet connection and try again',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: uninstalledPacks.length,
                            itemBuilder: (context, index) {
                              final pack = uninstalledPacks[index];
                              final downloadState = ref.watch(downloadProvider).valueOrNull;
                              final isDownloading = downloadState?.isDownloading(pack.id) ?? false;
                              final progress = downloadState?.getProgress(pack.id) ?? 0.0;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: PackItem(
                                  packId: pack.id,
                                  title: pack.topic,
                                  subject: pack.subject,
                                  version: 'v${pack.version}',
                                  size: pack.formattedSize,
                                  isInstalled: false,
                                  isDownloading: isDownloading,
                                  downloadProgress: progress,
                                  onDownload: isDownloading 
                                      ? null 
                                      : () => ref.read(downloadProvider.notifier).downloadPack(pack.id),
                                  onDelete: null,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, pack) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pack'),
        content: Text(
          'Are you sure you want to delete "${pack.topic}" pack? This will remove all downloaded questions for this topic.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(downloadProvider.notifier).deletePack(pack.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
