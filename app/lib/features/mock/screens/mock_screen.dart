import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../providers/mock_provider.dart';

class MockScreen extends HookConsumerWidget {
  final String subject;

  const MockScreen({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectName = AppConstants.subjectNames[subject] ?? subject;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Mock Exam: $subjectName'),
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
            
            // Exam info card
            _buildExamInfoCard(context),
            
            const SizedBox(height: 24),
            
            // Instructions card
            _buildInstructionsCard(context),
            
            const SizedBox(height: 32),
            
            // Start exam button
            _buildStartButton(context, ref),
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
                color: AppTheme.secondaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timer,
                color: AppTheme.secondaryColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$subjectName Mock Exam',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Realistic exam simulation',
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

  Widget _buildExamInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exam Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    icon: Icons.quiz,
                    label: 'Questions',
                    value: '${AppConstants.mockQuestionCount}',
                    color: AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    icon: Icons.schedule,
                    label: 'Duration',
                    value: '${AppConstants.mockExamDuration} min',
                    color: AppTheme.warningColor,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    icon: Icons.flag,
                    label: 'Passing',
                    value: '50%',
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
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

  Widget _buildInstructionsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Instructions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInstructionItem(
              context,
              '1. You have ${AppConstants.mockExamDuration} minutes to complete ${AppConstants.mockQuestionCount} questions.',
            ),
            _buildInstructionItem(
              context,
              '2. Each question has four options (A, B, C, D). Choose the best answer.',
            ),
            _buildInstructionItem(
              context,
              '3. You can flag questions for review and navigate between questions.',
            ),
            _buildInstructionItem(
              context,
              '4. The exam will auto-submit when time expires.',
            ),
            _buildInstructionItem(
              context,
              '5. Once submitted, you cannot change your answers.',
            ),
            const SizedBox(height: 16),
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
                    Icons.warning_amber_outlined,
                    color: AppTheme.warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ensure you have a stable internet connection and enough battery.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildInstructionItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            height: 4,
            width: 4,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final mockState = ref.watch(mockProvider);
        
        return PrimaryButton(
          onPressed: mockState.isLoading ? null : () => _showStartConfirmation(context, ref),
          isLoading: mockState.isLoading,
          icon: Icons.play_arrow,
          size: ButtonSize.large,
          child: const Text('Start Mock Exam'),
        );
      },
    );
  }

  void _showStartConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Start Mock Exam'),
        content: const Text(
          'Are you ready to start the mock exam? '
          'You will have 60 minutes to complete 60 questions. '
          'The timer will start immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not Ready'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startMockExam(context, ref);
            },
            child: const Text('Start Now'),
          ),
        ],
      ),
    );
  }

  void _startMockExam(BuildContext context, WidgetRef ref) {
    final mockNotifier = ref.read(mockProvider.notifier);
    
    mockNotifier.startSession(subject: subject).then((_) {
      final state = ref.read(mockProvider);
      if (state.error == null && state.questions.isNotEmpty) {
        context.go('/home/mock/$subject/question');
      }
    });
  }
}
