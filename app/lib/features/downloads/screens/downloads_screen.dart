import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';
import '../providers/pack_provider.dart';
import '../../../services/connectivity_service.dart';

class DownloadsScreen extends HookConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packsState = ref.watch(packProvider);
    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Downloads'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          // Connection status
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOnline ? Colors.green.shade100 : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: isOnline ? Colors.green.shade700 : Colors.orange.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isOnline ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (isOnline) {
            await ref.refresh(packProvider.future);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Storage info card
              _buildStorageInfoCard(context, ref),
              
              const SizedBox(height: 24),
              
              // Download queue
              _buildDownloadQueue(context, ref),
              
              const SizedBox(height: 24),
              
              // Available packs section
              _buildAvailablePacksSection(context, ref, packsState, isOnline),
              
              const SizedBox(height: 24),
              
              // Installed packs section
              _buildInstalledPacksSection(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStorageInfoCard(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Storage Usage',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStorageItem(
                    context,
                    label: 'Downloaded',
                    value: '0 MB', // TODO: Calculate actual usage
                    color: AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStorageItem(
                    context,
                    label: 'Available',
                    value: '∞', // TODO: Get device storage
                    color: AppTheme.successColor,
                  ),
                ),
                Expanded(
                  child: _buildStorageItem(
                    context,
                    label: 'Packs',
                    value: '0', // TODO: Count installed packs
                    color: AppTheme.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlineButton(
                    onPressed: () => _showCleanupDialog(context, ref),
                    icon: Icons.cleaning_services,
                    child: const Text('Cleanup'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlineButton(
                    onPressed: () => _showStorageSettings(context),
                    icon: Icons.settings,
                    child: const Text('Settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageItem(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadQueue(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(downloadQueueProvider);
    
    if (downloadState.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Download Queue',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => ref.read(packProvider.notifier).clearQueue(),
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...downloadState.map((download) => _buildDownloadItem(context, ref, download)),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadItem(BuildContext context, WidgetRef ref, DownloadItem download) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  download.packName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  download.status == DownloadStatus.downloading ? Icons.pause : Icons.cancel,
                  size: 20,
                ),
                onPressed: () {
                  if (download.status == DownloadStatus.downloading) {
                    ref.read(packProvider.notifier).pauseDownload(download.packId);
                  } else {
                    ref.read(packProvider.notifier).cancelDownload(download.packId);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: download.progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    download.status == DownloadStatus.downloading
                        ? AppTheme.primaryColor
                        : download.status == DownloadStatus.completed
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(download.progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getStatusText(download.status),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${(download.downloadedBytes / 1024 / 1024).toStringAsFixed(1)} MB',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailablePacksSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue packsState,
    bool isOnline,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Packs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isOnline)
              TextButton.icon(
                onPressed: () => ref.refresh(packProvider.future),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (!isOnline)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.wifi_off,
                  color: AppTheme.warningColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No internet connection. Connect to download new packs.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.warningColor,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          packsState.when(
            data: (packs) {
              if (packs.isEmpty) {
                return const EmptyStateDisplay(
                  title: 'No Packs Available',
                  message: 'Check your internet connection and try again',
                  icon: Icons.download,
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: packs.length,
                itemBuilder: (context, index) {
                  final pack = packs[index];
                  return _buildPackCard(context, ref, pack, false);
                },
              );
            },
            loading: () => const LoadingWidget(
              message: 'Loading available packs...',
              showMessage: true,
            ),
            error: (error, stack) => InlineErrorDisplay(
              message: 'Failed to load packs: $error',
              onRetry: () => ref.refresh(packProvider.future),
            ),
          ),
      ],
    );
  }

  Widget _buildInstalledPacksSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Installed Packs',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Consumer(
          builder: (context, ref, child) {
            final installedPacks = ref.watch(installedPacksProvider);
            
            return installedPacks.when(
              data: (packs) {
                if (packs.isEmpty) {
                  return const EmptyStateDisplay(
                    title: 'No Installed Packs',
                    message: 'Download packs to practice offline',
                    icon: Icons.download_outlined,
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: packs.length,
                  itemBuilder: (context, index) {
                    final pack = packs[index];
                    return _buildPackCard(context, ref, pack, true);
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, stack) => InlineErrorDisplay(
                message: 'Failed to load installed packs',
                onRetry: () => ref.refresh(installedPacksProvider.future),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPackCard(BuildContext context, WidgetRef ref, dynamic pack, bool isInstalled) {
    final subjectName = AppConstants.subjectNames[pack.subject] ?? pack.subject;
    final sizeText = '${(pack.sizeBytes / 1024 / 1024).toStringAsFixed(1)} MB';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getSubjectIcon(pack.subject),
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subjectName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Topic
            Text(
              pack.topic,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Version and size
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'v${pack.version}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  sizeText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // Action button
            SizedBox(
              width: double.infinity,
              child: isInstalled
                  ? OutlineButton(
                      onPressed: () => _showPackOptions(context, ref, pack),
                      child: const Text('Manage'),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => ref.read(packProvider.notifier).downloadPack(pack),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPackOptions(BuildContext context, WidgetRef ref, dynamic pack) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Pack Details'),
              onTap: () {
                Navigator.pop(context);
                _showPackDetails(context, pack);
              },
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Check for Updates'),
              onTap: () {
                Navigator.pop(context);
                ref.read(packProvider.notifier).checkForUpdates(pack.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Pack', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, ref, pack);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPackDetails(BuildContext context, dynamic pack) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pack.topic),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Subject', AppConstants.subjectNames[pack.subject] ?? pack.subject),
            _buildDetailRow('Version', pack.version.toString()),
            _buildDetailRow('Size', '${(pack.sizeBytes / 1024 / 1024).toStringAsFixed(1)} MB'),
            if (pack.installedAt != null)
              _buildDetailRow('Installed', _formatDate(pack.installedAt!)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, dynamic pack) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Pack'),
        content: Text('Are you sure you want to remove "${pack.topic}"? This will delete all downloaded content.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(packProvider.notifier).deletePack(pack.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showCleanupDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Cleanup'),
        content: const Text('Remove temporary files and optimize storage usage?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(packProvider.notifier).cleanup();
            },
            child: const Text('Cleanup'),
          ),
        ],
      ),
    );
  }

  void _showStorageSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Settings'),
        content: const Text('Storage settings will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'ENG':
        return Icons.translate;
      case 'MAT':
        return Icons.calculate;
      case 'PHY':
        return Icons.science;
      case 'CHE':
        return Icons.biotech;
      case 'BIO':
        return Icons.local_florist;
      case 'ECO':
        return Icons.trending_up;
      case 'GOV':
        return Icons.account_balance;
      case 'HIS':
        return Icons.history_edu;
      case 'GEO':
        return Icons.public;
      case 'LIT':
        return Icons.menu_book;
      default:
        return Icons.book;
    }
  }

  String _getStatusText(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.queued:
        return 'Queued';
      case DownloadStatus.downloading:
        return 'Downloading...';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.failed:
        return 'Failed';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
