import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../providers/mock_provider.dart';
import '../widgets/timer_bar.dart';
import '../../../core/utils/constants.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/loading_indicator.dart';

class MockExamScreen extends HookConsumerWidget {
  final String subject;
  final String? sessionId;

  const MockExamScreen({
    super.key,
    required this.subject,
    this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockState = ref.watch(mockProvider(subject));
    
    // If we already have a sessionId, go directly to the exam
    useEffect(() {
      if (sessionId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/practice/$subject/session/$sessionId');
        });
      }
      return null;
    }, [sessionId]);

    return mockState.when(
      loading: () => const Scaffold(
        body: Center(child: LoadingIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Mock Exam')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to start mock exam',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Try Again',
                onPressed: () => ref.refresh(mockProvider(subject)),
              ),
            ],
          ),
        ),
      ),
      data: (state) {
        if (state.isStarted) {
          // Redirect to question screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/practice/$subject/session/${state.sessionId}');
          });
          return const Scaffold(
            body: Center(child: LoadingIndicator()),
          );
        }

        return _MockExamSetupScreen(subject: subject);
      },
    );
  }
}

class _MockExamSetupScreen extends ConsumerWidget {
  final String subject;

  const _MockExamSetupScreen({required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectName = Subjects.subjectNames[subject] ?? subject;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Exam'),
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
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Mock Exam',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subjectName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Exam details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exam Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _DetailRow(
                      icon: Icons.quiz,
                      title: 'Questions',
                      value: '${AppConstants.mockExamQuestions} questions',
                    ),
                    _DetailRow(
                      icon: Icons.timer,
                      title: 'Time Limit',
                      value: '${AppConstants.mockExamDurationMinutes} minutes',
                    ),
                    _DetailRow(
                      icon: Icons.school,
                      title: 'Subject',
                      value: subjectName,
                    ),
                    _DetailRow(
                      icon: Icons.assessment,
                      title: 'Scoring',
                      value: 'Instant results',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                          'Instructions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    ...[
                      'Answer all ${AppConstants.mockExamQuestions} questions within ${AppConstants.mockExamDurationMinutes} minutes',
                      'You can navigate between questions using the question palette',
                      'Flag difficult questions to review later',
                      'Submit your answers before time runs out',
                      'Results will be displayed immediately after submission',
                    ].map((instruction) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Expanded(
                            child: Text(
                              instruction,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
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
          text: 'Start Mock Exam',
          onPressed: () async {
            try {
              final sessionId = await ref.read(mockProvider(subject).notifier)
                  .startMockExam();
              
              if (context.mounted) {
                context.go('/practice/$subject/session/$sessionId');
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to start mock exam: $e'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
