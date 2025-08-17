import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/session_repository.dart';
import '../../../core/utils/constants.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/loading_indicator.dart';

class PracticeSetupScreen extends HookConsumerWidget {
  final String subject;
  final String? topic;

  const PracticeSetupScreen({
    super.key,
    required this.subject,
    this.topic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionCount = useState(20);
    final selectedTopic = useState<String?>(topic);
    final isLoading = useState(false);

    final subjectName = Subjects.subjectNames[subject] ?? subject;

    return Scaffold(
      appBar: AppBar(
        title: Text('Practice Setup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        subject,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                        Text(
                          'Practice Session',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Question count selection
            Text(
              'Number of Questions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              children: [10, 20, 30, 50].map((count) {
                final isSelected = questionCount.value == count;
                return FilterChip(
                  label: Text('$count questions'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      questionCount.value = count;
                    }
                  },
                  backgroundColor: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Topic selection (if available)
            Text(
              'Topic (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(Icons.topic),
                title: Text(selectedTopic.value ?? 'All Topics'),
                subtitle: const Text('Practice questions from all topics or select specific topic'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Show topic selection dialog
                  _showTopicSelectionDialog(context, selectedTopic);
                },
              ),
            ),

            const SizedBox(height: 32),

            // Practice mode info
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Practice Mode',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• No time limit - learn at your own pace\n'
                      '• Instant feedback after each question\n'
                      '• Detailed explanations for all answers\n'
                      '• Track your progress and weak areas',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        child: AppButton(
          text: 'Start Practice Session',
          isLoading: isLoading.value,
          onPressed: () async {
            isLoading.value = true;
            
            try {
              final sessionRepo = ref.read(sessionRepositoryProvider);
              final session = await sessionRepo.createSession(
                mode: 'practice',
                subject: subject,
                topic: selectedTopic.value,
                count: questionCount.value,
              );

              if (context.mounted) {
                context.go('/practice/$subject/session/${session.id}');
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to start practice session: $e'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            } finally {
              isLoading.value = false;
            }
          },
        ),
      ),
    );
  }

  void _showTopicSelectionDialog(BuildContext context, ValueNotifier<String?> selectedTopic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Topic'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Topics'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: selectedTopic.value,
                  onChanged: (value) {
                    selectedTopic.value = value;
                    Navigator.of(context).pop();
                  },
                ),
              ),
              // TODO: Add actual topics based on subject syllabus
              ...['Grammar', 'Comprehension', 'Literature', 'Writing'].map((topic) => 
                ListTile(
                  title: Text(topic),
                  leading: Radio<String>(
                    value: topic,
                    groupValue: selectedTopic.value,
                    onChanged: (value) {
                      selectedTopic.value = value;
                      Navigator.of(context).pop();
                    },
                  ),
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
        ],
      ),
    );
  }
}
