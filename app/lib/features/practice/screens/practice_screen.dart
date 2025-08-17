import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';
import '../providers/practice_provider.dart';

class PracticeScreen extends HookConsumerWidget {
  final String subject;
  final String? topic;

  const PracticeScreen({
    super.key,
    required this.subject,
    this.topic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectName = AppConstants.subjectNames[subject] ?? subject;
    final topicsAsync = ref.watch(topicsProvider(subject));
    final topicCountsAsync = ref.watch(topicCountsProvider(subject));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Practice: $subjectName'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Subject header
            _buildSubjectHeader(context, subject, subjectName),
            
            const SizedBox(height: 24),
            
            // Quick start section
            _buildQuickStartSection(context, ref),
            
            const SizedBox(height: 24),
            
            // Topics section
            _buildTopicsSection(context, ref, topicsAsync, topicCountsAsync),
            
            const SizedBox(height: 24),
            
            // Custom practice section
            _buildCustomPracticeSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectHeader(BuildContext context, String subject, String subjectName) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getSubjectIcon(subject),
                color: AppTheme.primaryColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose your practice mode',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStartSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Start',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickStartCard(
                    context,
                    title: 'Random Mix',
                    description: '20 questions from all topics',
                    icon: Icons.shuffle,
                    onTap: () => _startPractice(context, ref, null, 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickStartCard(
                    context,
                    title: 'Short Practice',
                    description: '10 quick questions',
                    icon: Icons.flash_on,
                    onTap: () => _startPractice(context, ref, null, 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStartCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<String>> topicsAsync,
    AsyncValue<Map<String, int>> topicCountsAsync,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Practice by Topic',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            topicsAsync.when(
              data: (topics) {
                if (topics.isEmpty) {
                  return const EmptyStateDisplay(
                    title: 'No Topics Available',
                    message: 'Please download question packs first',
                    icon: Icons.download,
                  );
                }

                return topicCountsAsync.when(
                  data: (counts) => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topics.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      final questionCount = counts[topic] ?? 0;
                      
                      return _buildTopicListTile(
                        context,
                        ref,
                        topic: topic,
                        questionCount: questionCount,
                      );
                    },
                  ),
                  loading: () => const LoadingWidget(message: 'Loading topic counts...'),
                  error: (error, stack) => InlineErrorDisplay(
                    message: 'Failed to load topic counts',
                    onRetry: () => ref.refresh(topicCountsProvider(subject)),
                  ),
                );
              },
              loading: () => const LoadingWidget(message: 'Loading topics...'),
              error: (error, stack) => InlineErrorDisplay(
                message: 'Failed to load topics',
                onRetry: () => ref.refresh(topicsProvider(subject)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicListTile(
    BuildContext context,
    WidgetRef ref, {
    required String topic,
    required int questionCount,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Icon(
          Icons.book_outlined,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        topic,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '$questionCount questions available',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: questionCount > 0
          ? () => _startPractice(context, ref, topic, 20)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      tileColor: AppTheme.surfaceColor,
    );
  }

  Widget _buildCustomPracticeSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom Practice',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set your own question count and preferences',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              onPressed: () => _showCustomPracticeDialog(context, ref),
              variant: ButtonVariant.outline,
              icon: Icons.tune,
              child: const Text('Customize Practice'),
            ),
          ],
        ),
      ),
    );
  }

  void _startPractice(
    BuildContext context,
    WidgetRef ref,
    String? selectedTopic,
    int questionCount,
  ) {
    final practiceNotifier = ref.read(practiceProvider.notifier);
    
    // Start the session and navigate
    practiceNotifier.startSession(
      subject: subject,
      topic: selectedTopic,
      questionCount: questionCount,
    ).then((_) {
      // Navigate to question screen
      context.go('/home/practice/$subject/question');
    }).catchError((error) {
      // Error handling is done in the provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start practice: $error'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    });
  }

  void _showCustomPracticeDialog(BuildContext context, WidgetRef ref) {
    int selectedCount = 20;
    String? selectedTopic;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Custom Practice'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Number of Questions',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [5, 10, 15, 20, 30, 50].map((count) {
                    final isSelected = selectedCount == count;
                    return ChoiceChip(
                      label: Text('$count'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => selectedCount = count);
                        }
                      },
                      backgroundColor: AppTheme.surfaceColor,
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Topic (Optional)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, child) {
                    final topicsAsync = ref.watch(topicsProvider(subject));
                    return topicsAsync.when(
                      data: (topics) => DropdownButtonFormField<String?>(
                        value: selectedTopic,
                        hint: const Text('All topics (random)'),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All topics (random)'),
                          ),
                          ...topics.map((topic) => DropdownMenuItem(
                            value: topic,
                            child: Text(topic),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() => selectedTopic = value);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      loading: () => const LoadingWidget(size: 16),
                      error: (error, stack) => const Text(
                        'Failed to load topics',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  },
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
                Navigator.of(context).pop();
                _startPractice(context, ref, selectedTopic, selectedCount);
              },
              child: const Text('Start Practice'),
            ),
          ],
        ),
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
