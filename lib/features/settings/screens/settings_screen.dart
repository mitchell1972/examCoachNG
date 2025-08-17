import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../widgets/loading_indicator.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: authState.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
        data: (state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile section
                if (state.user != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            child: Text(
                              state.user!.initials,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.user!.displayName,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  state.user!.phone,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // TODO: Navigate to profile edit
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // App settings section
                Text(
                  'App Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),

                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.school,
                      title: 'Selected Subjects',
                      subtitle: 'Manage your exam subjects',
                      onTap: () => context.push('/subjects'),
                    ),
                    _SettingsTile(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'Study reminders and alerts',
                      onTap: () => _showNotificationSettings(context),
                      trailing: Switch(
                        value: true, // TODO: Get from settings
                        onChanged: (value) {
                          // TODO: Update notification settings
                        },
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.download,
                      title: 'Downloads',
                      subtitle: 'Manage offline content',
                      onTap: () => context.push('/downloads'),
                    ),
                    _SettingsTile(
                      icon: Icons.dark_mode,
                      title: 'Dark Mode',
                      subtitle: 'Toggle app theme',
                      trailing: Switch(
                        value: false, // TODO: Get from theme settings
                        onChanged: (value) {
                          // TODO: Update theme
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Account section
                Text(
                  'Account',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),

                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.payment,
                      title: 'Billing & Subscription',
                      subtitle: 'Manage your subscription',
                      onTap: () => context.push('/billing'),
                    ),
                    _SettingsTile(
                      icon: Icons.security,
                      title: 'Privacy & Security',
                      subtitle: 'Data and privacy settings',
                      onTap: () => _showPrivacySettings(context),
                    ),
                    _SettingsTile(
                      icon: Icons.backup,
                      title: 'Backup & Sync',
                      subtitle: 'Cloud backup settings',
                      onTap: () => _showBackupSettings(context),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Support section
                Text(
                  'Support',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),

                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.help,
                      title: 'Help & FAQ',
                      subtitle: 'Get help and find answers',
                      onTap: () => _showHelp(context),
                    ),
                    _SettingsTile(
                      icon: Icons.feedback,
                      title: 'Send Feedback',
                      subtitle: 'Report issues or suggestions',
                      onTap: () => _showFeedback(context),
                    ),
                    _SettingsTile(
                      icon: Icons.info,
                      title: 'About',
                      subtitle: 'App version and legal info',
                      onTap: () => _showAbout(context),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showLogoutDialog(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(color: Theme.of(context).colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Logout'),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Daily reminders'),
              subtitle: const Text('Get reminded to practice daily'),
              value: true,
              onChanged: (value) {
                // TODO: Update notification settings
              },
            ),
            CheckboxListTile(
              title: const Text('Achievement notifications'),
              subtitle: const Text('Get notified of your achievements'),
              value: true,
              onChanged: (value) {
                // TODO: Update notification settings
              },
            ),
            CheckboxListTile(
              title: const Text('New content alerts'),
              subtitle: const Text('Get notified of new question packs'),
              value: false,
              onChanged: (value) {
                // TODO: Update notification settings
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Collection',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Analytics'),
              subtitle: const Text('Help improve the app'),
              value: true,
              onChanged: (value) {
                // TODO: Update analytics settings
              },
            ),
            CheckboxListTile(
              title: const Text('Crash reporting'),
              subtitle: const Text('Automatically report crashes'),
              value: true,
              onChanged: (value) {
                // TODO: Update crash reporting settings
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                // TODO: Navigate to data export
              },
              child: const Text('Export My Data'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBackupSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup & Sync'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text('Cloud Backup'),
              subtitle: const Text('Last backup: Never'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // TODO: Toggle cloud backup
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Manual backup
              },
              child: const Text('Backup Now'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & FAQ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text('• How do I download question packs?'),
            const Text('• How do I change my subjects?'),
            const Text('• How do mock exams work?'),
            const Text('• How do I track my progress?'),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                // TODO: Open full help/FAQ
              },
              child: const Text('View All FAQs'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Your feedback',
                hintText: 'Tell us what you think...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Report bug
                    },
                    child: const Text('Report Bug'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Send feedback
                    },
                    child: const Text('Send'),
                  ),
                ),
              ],
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

  void _showAbout(BuildContext context) {
    PackageInfo.fromPlatform().then((packageInfo) {
      showAboutDialog(
        context: context,
        applicationName: 'ExamCoach',
        applicationVersion: packageInfo.version,
        applicationIcon: const Icon(Icons.school, size: 64),
        children: [
          const Text('Your AI-powered exam preparation companion'),
          const SizedBox(height: 16),
          const Text('© 2025 ExamCoach. All rights reserved.'),
        ],
      );
    });
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
              context.go('/phone');
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            )
          : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
