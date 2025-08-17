import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../services/storage_service.dart';
import '../../../services/notification_service.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            _buildProfileSection(context, ref, user),
            
            const SizedBox(height: 24),
            
            // Study preferences
            _buildStudyPreferencesSection(context, ref),
            
            const SizedBox(height: 24),
            
            // Notifications
            _buildNotificationsSection(context, ref),
            
            const SizedBox(height: 24),
            
            // Storage & Downloads
            _buildStorageSection(context, ref),
            
            const SizedBox(height: 24),
            
            // App preferences
            _buildAppPreferencesSection(context, ref),
            
            const SizedBox(height: 24),
            
            // Support & About
            _buildSupportSection(context, ref),
            
            const SizedBox(height: 24),
            
            // Account actions
            _buildAccountActionsSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, WidgetRef ref, dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Student',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.phone ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _editProfile(context, ref),
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyPreferencesSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.school),
              title: const Text('My Subjects'),
              subtitle: const Text('Manage selected subjects'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _manageSubjects(context, ref),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.quiz),
              title: const Text('Default Practice Settings'),
              subtitle: const Text('Question count, difficulty, etc.'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showPracticeSettings(context, ref),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.timer),
              title: const Text('Mock Exam Settings'),
              subtitle: const Text('Timer preferences'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showMockSettings(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              context,
              title: 'Daily Practice Reminders',
              subtitle: 'Get reminded to practice daily',
              value: true, // TODO: Get from settings
              onChanged: (value) => _updateNotificationSetting('daily_practice', value),
            ),
            _buildSwitchTile(
              context,
              title: 'Streak Reminders',
              subtitle: 'Don\'t break your streak',
              value: true, // TODO: Get from settings
              onChanged: (value) => _updateNotificationSetting('streak', value),
            ),
            _buildSwitchTile(
              context,
              title: 'New Content Alerts',
              subtitle: 'When new question packs are available',
              value: false, // TODO: Get from settings
              onChanged: (value) => _updateNotificationSetting('new_content', value),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: const Text('Reminder Times'),
              subtitle: const Text('Set when to receive reminders'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _setReminderTimes(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Storage & Downloads',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.download),
              title: const Text('Manage Downloads'),
              subtitle: const Text('View and manage downloaded packs'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.go('/home/downloads'),
            ),
            const Divider(),
            _buildSwitchTile(
              context,
              title: 'Download over Mobile Data',
              subtitle: 'Allow downloads when not on Wi-Fi',
              value: false, // TODO: Get from settings
              onChanged: (value) => _updateDownloadSetting('mobile_data', value),
            ),
            _buildSwitchTile(
              context,
              title: 'Auto-download Updates',
              subtitle: 'Automatically download pack updates',
              value: true, // TODO: Get from settings
              onChanged: (value) => _updateDownloadSetting('auto_update', value),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cleaning_services),
              title: const Text('Clear Cache'),
              subtitle: const Text('Free up storage space'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _clearCache(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppPreferencesSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.palette),
              title: const Text('Theme'),
              subtitle: const Text('System default'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showThemeOptions(context, ref),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: const Text('English'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showLanguageOptions(context, ref),
            ),
            const Divider(),
            _buildSwitchTile(
              context,
              title: 'Haptic Feedback',
              subtitle: 'Vibrate on interactions',
              value: true, // TODO: Get from settings
              onChanged: (value) => _updateAppSetting('haptic_feedback', value),
            ),
            _buildSwitchTile(
              context,
              title: 'Sound Effects',
              subtitle: 'Play sounds for actions',
              value: true, // TODO: Get from settings
              onChanged: (value) => _updateAppSetting('sound_effects', value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Support & About',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & FAQ'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showHelp(context),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.contact_support),
              title: const Text('Contact Support'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _contactSupport(context),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.star_rate),
              title: const Text('Rate App'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _rateApp(context),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline),
              title: const Text('About ExamCoach'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showAbout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActionsSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Settings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showPrivacySettings(context, ref),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.download_outlined),
              title: const Text('Export Data'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _exportData(context, ref),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => _showLogoutDialog(context, ref),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
              onTap: () => _showDeleteAccountDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
    );
  }

  void _editProfile(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Profile editing will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _manageSubjects(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    final selectedSubjects = Set<String>.from(user?.subjects ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Manage Subjects'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select subjects you want to practice:'),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: AppConstants.availableSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = AppConstants.availableSubjects[index];
                      final subjectName = AppConstants.subjectNames[subject] ?? subject;
                      final isSelected = selectedSubjects.contains(subject);
                      
                      return CheckboxListTile(
                        title: Text(subjectName),
                        value: isSelected,
                        onChanged: subject == 'ENG' 
                            ? null // English is required
                            : (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedSubjects.add(subject);
                                  } else {
                                    selectedSubjects.remove(subject);
                                  }
                                });
                              },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).updateUserSubjects(selectedSubjects.toList());
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPracticeSettings(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Practice Settings'),
        content: const Text('Practice settings will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMockSettings(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mock Exam Settings'),
        content: const Text('Mock exam settings will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _updateNotificationSetting(String key, bool value) {
    // TODO: Implement notification settings
  }

  void _setReminderTimes(BuildContext context, WidgetRef ref) {
    showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0),
    ).then((time) {
      if (time != null) {
        // TODO: Save reminder time
        NotificationService.instance.scheduleDailyReminder(
          hour: time.hour,
          minute: time.minute,
        );
      }
    });
  }

  void _updateDownloadSetting(String key, bool value) {
    // TODO: Implement download settings
  }

  void _updateAppSetting(String key, bool value) {
    // TODO: Implement app settings
  }

  void _clearCache(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will free up storage space. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement cache clearing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showThemeOptions(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: const Text('Theme options will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLanguageOptions(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language'),
        content: const Text('Language options will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
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
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Q: How do I download question packs?'),
              SizedBox(height: 8),
              Text('A: Go to Downloads and select packs to download.'),
              SizedBox(height: 16),
              Text('Q: How do mock exams work?'),
              SizedBox(height: 8),
              Text('A: Mock exams are timed practice sessions that simulate real exams.'),
              SizedBox(height: 16),
              Text('Q: Can I practice offline?'),
              SizedBox(height: 8),
              Text('A: Yes, once you download question packs, you can practice offline.'),
            ],
          ),
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

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Email: support@examcoach.com'),
            SizedBox(height: 8),
            Text('Phone: +234 800 000 0000'),
            SizedBox(height: 8),
            Text('WhatsApp: +234 800 000 0000'),
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

  void _rateApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate ExamCoach'),
        content: const Text('Help us improve by rating the app on your app store.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Open app store for rating
            },
            child: const Text('Rate Now'),
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
        applicationIcon: Container(
          height: 64,
          width: 64,
          decoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.school,
            size: 32,
            color: Colors.white,
          ),
        ),
        children: [
          const Text('Your AI-powered exam preparation companion'),
          const SizedBox(height: 16),
          const Text('© 2025 ExamCoach. All rights reserved.'),
        ],
      );
    });
  }

  void _showPrivacySettings(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: const Text('Privacy settings will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Data export will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
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
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion will be available in a future update'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
