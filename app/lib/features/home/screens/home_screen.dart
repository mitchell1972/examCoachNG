import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../../downloads/providers/pack_provider.dart';
import '../../../services/connectivity_service.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final packsState = ref.watch(packProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Welcome, ${user?.name ?? 'Student'}'),
        actions: [
          // Connection status indicator
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
          
          // Profile menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'downloads':
                  context.go('/home/downloads');
                  break;
                case 'billing':
                  context.go('/home/billing');
                  break;
                case 'settings':
                  context.go('/home/settings');
                  break;
                case 'logout':
                  _showLogoutDialog(context, ref);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'downloads',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Downloads'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'billing',
                child: ListTile(
                  leading: Icon(Icons.payment),
                  title: Text('Subscription'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
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
              // Quick stats card
              _buildQuickStatsCard(context, ref),
              
              const SizedBox(height: 24),
              
              // Study modes section
              _buildStudyModesSection(context),
              
              const SizedBox(height: 24),
              
              // Subjects section
              _buildSubjectsSection(context, user?.subjects ?? []),
              
              const SizedBox(height: 24),
              
              // Recent activity
              _buildRecentActivitySection(context),
              
              const SizedBox(height: 80), // Bottom padding for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickPracticeDialog(context, user?.subjects ?? []),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: const Text('Quick Practice', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildQuickStatsCard(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.quiz,
                    label: 'Questions',
                    value: '0', // TODO: Implement actual stats
                    color: AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.trending_up,
                    label: 'Accuracy',
                    value: '0%', // TODO: Implement actual stats
                    color: AppTheme.successColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.schedule,
                    label: 'Time',
                    value: '0min', // TODO: Implement actual stats
                    color: AppTheme.warningColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStudyModesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Study Modes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildModeCard(
                context,
                title: 'Practice',
                description: 'Learn at your own pace',
                icon: Icons.school,
                color: AppTheme.primaryColor,
                onTap: () => _showSubjectSelectionDialog(context, 'practice'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildModeCard(
                context,
                title: 'Mock Exam',
                description: 'Timed exam simulation',
                icon: Icons.timer,
                color: AppTheme.secondaryColor,
                onTap: () => _showSubjectSelectionDialog(context, 'mock'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsSection(BuildContext context, List<String> userSubjects) {
    if (userSubjects.isEmpty) {
      return const EmptyStateDisplay(
        title: 'No Subjects Selected',
        message: 'Go to settings to select your subjects',
        icon: Icons.book_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Subjects',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/home/settings'),
              child: const Text('Manage'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: userSubjects.length,
          itemBuilder: (context, index) {
            final subject = userSubjects[index];
            return _buildSubjectCard(context, subject);
          },
        ),
      ],
    );
  }

  Widget _buildSubjectCard(BuildContext context, String subject) {
    final subjectName = AppConstants.subjectNames[subject] ?? subject;
    final icon = _getSubjectIcon(subject);
    
    return GestureDetector(
      onTap: () => _showSubjectOptionsDialog(context, subject),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subjectName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '0 questions', // TODO: Show actual count
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const EmptyStateDisplay(
          title: 'No Recent Activity',
          message: 'Start practicing to see your activity here',
          icon: Icons.history,
        ),
      ],
    );
  }

  void _showQuickPracticeDialog(BuildContext context, List<String> subjects) {
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select subjects in settings first'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Practice'),
        content: const Text('Choose a subject for quick practice'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final randomSubject = (subjects..shuffle()).first;
              context.go('/home/practice/$randomSubject');
            },
            child: const Text('Random Subject'),
          ),
        ],
      ),
    );
  }

  void _showSubjectSelectionDialog(BuildContext context, String mode) {
    final user = ProviderScope.containerOf(context).read(currentUserProvider);
    final subjects = user?.subjects ?? [];

    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select subjects in settings first'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Subject for ${mode.capitalize()}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              final subjectName = AppConstants.subjectNames[subject] ?? subject;
              
              return ListTile(
                leading: Icon(_getSubjectIcon(subject)),
                title: Text(subjectName),
                onTap: () {
                  Navigator.of(context).pop();
                  if (mode == 'practice') {
                    context.go('/home/practice/$subject');
                  } else {
                    context.go('/home/mock/$subject');
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSubjectOptionsDialog(BuildContext context, String subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppConstants.subjectNames[subject] ?? subject),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Practice Mode'),
              subtitle: const Text('Learn at your own pace'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/home/practice/$subject');
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Mock Exam'),
              subtitle: const Text('Timed exam simulation'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/home/mock/$subject');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
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
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
