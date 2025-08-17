import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/session_repository.dart';
import '../widgets/result_chart.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/app_button.dart';
import '../../../domain/entities/attempt.dart';

final resultsProvider = FutureProvider.family<ResultsData, String>((ref, sessionId) async {
  final sessionRepo = ref.read(sessionRepositoryProvider);
  final session = await sessionRepo.getSession(sessionId);
  final attempts = await sessionRepo.getSessionAttempts(sessionId);
  
  if (session == null) {
    throw Exception('Session not found');
  }
  
  return ResultsData(
    session: session,
    attempts: attempts,
    summary: _calculateSummary(attempts),
  );
});

class ResultsScreen extends ConsumerWidget {
  final String sessionId;

  const ResultsScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(resultsProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement sharing functionality
            },
          ),
        ],
      ),
      body: resultsAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stackTrace) => Center(
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
                'Failed to load results',
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
                text: 'Back to Home',
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
        data: (results) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getGradeColor(results.summary.grade),
                      _getGradeColor(results.summary.grade).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      results.summary.grade,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${results.summary.correctAttempts}/${results.summary.totalAttempts} Correct',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      results.summary.formattedAccuracy,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Session info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _DetailRow(
                        icon: Icons.school,
                        label: 'Mode',
                        value: results.session.modeDisplayName,
                      ),
                      _DetailRow(
                        icon: Icons.book,
                        label: 'Subject',
                        value: results.session.subject,
                      ),
                      if (results.session.topic != null)
                        _DetailRow(
                          icon: Icons.topic,
                          label: 'Topic',
                          value: results.session.topic!,
                        ),
                      _DetailRow(
                        icon: Icons.timer,
                        label: 'Duration',
                        value: results.session.formattedDuration,
                      ),
                      _DetailRow(
                        icon: Icons.calendar_today,
                        label: 'Completed',
                        value: _formatDateTime(results.session.endedAt!),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Performance chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Performance Breakdown',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: ResultChart(
                          correctCount: results.summary.correctAttempts,
                          incorrectCount: results.summary.incorrectAttempts,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Statistics
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistics',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Accuracy',
                              value: results.summary.formattedAccuracy,
                              color: Colors.green,
                              icon: Icons.check_circle,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              title: 'Avg. Time',
                              value: results.summary.formattedAverageTime,
                              color: Colors.blue,
                              icon: Icons.timer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Total Time',
                              value: results.summary.formattedTotalTime,
                              color: Colors.orange,
                              icon: Icons.schedule,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              title: 'Questions',
                              value: '${results.summary.totalAttempts}',
                              color: Colors.purple,
                              icon: Icons.quiz,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Navigate to detailed review
                      },
                      child: const Text('Review Answers'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: 'Practice Again',
                      onPressed: () => context.push('/practice/${results.session.subject}'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              AppButton(
                text: 'Back to Home',
                onPressed: () => context.go('/home'),
                variant: AppButtonVariant.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color,
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ResultsData {
  final session;
  final List<AttemptEntity> attempts;
  final AttemptSummary summary;

  ResultsData({
    required this.session,
    required this.attempts,
    required this.summary,
  });
}

AttemptSummary _calculateSummary(List<AttemptEntity> attempts) {
  final totalAttempts = attempts.length;
  final correctAttempts = attempts.where((a) => a.correct).length;
  final incorrectAttempts = totalAttempts - correctAttempts;
  final accuracy = totalAttempts > 0 ? correctAttempts / totalAttempts : 0.0;
  
  final totalTimeMs = attempts.fold<int>(0, (sum, a) => sum + a.timeMs);
  final averageTimeMs = totalAttempts > 0 ? totalTimeMs / totalAttempts : 0.0;
  
  return AttemptSummary(
    totalAttempts: totalAttempts,
    correctAttempts: correctAttempts,
    incorrectAttempts: incorrectAttempts,
    accuracy: accuracy,
    averageTime: Duration(milliseconds: averageTimeMs.round()),
    totalTime: Duration(milliseconds: totalTimeMs),
  );
}
