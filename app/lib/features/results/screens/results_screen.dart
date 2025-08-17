import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/db/database.dart';
import '../widgets/result_chart.dart';

class ResultsScreen extends HookConsumerWidget {
  final String sessionId;

  const ResultsScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Results'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'share':
                  _shareResults(context);
                  break;
                case 'restart':
                  _restartPractice(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share Results'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'restart',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Practice Again'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<ResultsData?>(
        future: _loadSessionResults(sessionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: LoadingWidget(
                size: 48,
                message: 'Loading results...',
                showMessage: true,
              ),
            );
          }

          if (snapshot.hasError) {
            return ErrorDisplay(
              title: 'Failed to Load Results',
              message: snapshot.error.toString(),
              onRetry: () {
                // Trigger rebuild
                (context as Element).markNeedsBuild();
              },
            );
          }

          final results = snapshot.data;
          if (results == null) {
            return const ErrorDisplay(
              title: 'Results Not Found',
              message: 'The session results could not be found.',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Score card
                _buildScoreCard(context, results),
                
                const SizedBox(height: 24),
                
                // Performance chart
                _buildPerformanceChart(context, results),
                
                const SizedBox(height: 24),
                
                // Session details
                _buildSessionDetails(context, results),
                
                const SizedBox(height: 24),
                
                // Topic breakdown
                if (results.topicBreakdown.isNotEmpty)
                  _buildTopicBreakdown(context, results),
                
                const SizedBox(height: 24),
                
                // Action buttons
                _buildActionButtons(context, results),
                
                const SizedBox(height: 80), // Bottom padding
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, ResultsData results) {
    final accuracy = (results.score / results.totalQuestions * 100);
    final grade = _getGrade(accuracy);
    
    Color scoreColor;
    if (accuracy >= 80) {
      scoreColor = AppTheme.successColor;
    } else if (accuracy >= 60) {
      scoreColor = AppTheme.warningColor;
    } else {
      scoreColor = AppTheme.errorColor;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Score circle
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withOpacity(0.1),
                border: Border.all(color: scoreColor, width: 4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${results.score}',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    '/ ${results.totalQuestions}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Accuracy percentage
            Text(
              '${accuracy.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Grade
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scoreColor.withOpacity(0.3)),
              ),
              child: Text(
                grade,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scoreColor,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Subject and mode
            Text(
              '${AppConstants.subjectNames[results.subject] ?? results.subject} - ${results.mode.capitalize()}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart(BuildContext context, ResultsData results) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ResultChart(
                correct: results.score,
                incorrect: results.totalQuestions - results.score,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionDetails(BuildContext context, ResultsData results) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              icon: Icons.access_time,
              label: 'Duration',
              value: _formatDuration(results.duration),
            ),
            _buildDetailRow(
              context,
              icon: Icons.speed,
              label: 'Average Time',
              value: _formatDuration(results.averageTime),
            ),
            _buildDetailRow(
              context,
              icon: Icons.calendar_today,
              label: 'Completed',
              value: _formatDateTime(results.completedAt),
            ),
            if (results.topic != null)
              _buildDetailRow(
                context,
                icon: Icons.topic,
                label: 'Topic',
                value: results.topic!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicBreakdown(BuildContext context, ResultsData results) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Topic Performance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...results.topicBreakdown.entries.map((entry) {
              final topic = entry.key;
              final stats = entry.value;
              final accuracy = stats['correct'] / stats['total'] * 100;
              
              return _buildTopicItem(context, topic, stats['correct'], stats['total'], accuracy);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicItem(
    BuildContext context,
    String topic,
    int correct,
    int total,
    double accuracy,
  ) {
    Color accuracyColor;
    if (accuracy >= 80) {
      accuracyColor = AppTheme.successColor;
    } else if (accuracy >= 60) {
      accuracyColor = AppTheme.warningColor;
    } else {
      accuracyColor = AppTheme.errorColor;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  topic,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$correct/$total (${accuracy.toStringAsFixed(1)}%)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: accuracyColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: accuracy / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(accuracyColor),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ResultsData results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          onPressed: () => _restartPractice(context),
          icon: Icons.refresh,
          child: const Text('Practice Again'),
        ),
        const SizedBox(height: 12),
        OutlineButton(
          onPressed: () => context.go('/home'),
          icon: Icons.home,
          child: const Text('Back to Home'),
        ),
      ],
    );
  }

  Future<ResultsData?> _loadSessionResults(String sessionId) async {
    try {
      final database = AppDatabase();
      final sessionRepository = SessionRepository();
      
      final session = await database.getSessionById(sessionId);
      if (session == null) return null;
      
      final attempts = await database.getAttemptsBySession(sessionId);
      
      final score = attempts.where((a) => a.correct).length;
      final totalQuestions = attempts.length;
      
      final duration = session.endedAt != null 
          ? session.endedAt!.difference(session.startedAt)
          : Duration.zero;
      
      final averageTimeMs = attempts.isNotEmpty
          ? attempts.map((a) => a.timeMs).reduce((a, b) => a + b) ~/ attempts.length
          : 0;
      
      // Calculate topic breakdown
      final topicBreakdown = <String, Map<String, int>>{};
      for (final attempt in attempts) {
        // Get question to find topic - simplified for now
        final topic = 'General'; // Would need to look up actual topic
        topicBreakdown.putIfAbsent(topic, () => {'correct': 0, 'total': 0});
        topicBreakdown[topic]!['total'] = topicBreakdown[topic]!['total']! + 1;
        if (attempt.correct) {
          topicBreakdown[topic]!['correct'] = topicBreakdown[topic]!['correct']! + 1;
        }
      }
      
      return ResultsData(
        sessionId: sessionId,
        subject: session.subject,
        topic: session.topic,
        mode: session.mode,
        score: score,
        totalQuestions: totalQuestions,
        duration: duration,
        averageTime: Duration(milliseconds: averageTimeMs),
        completedAt: session.endedAt ?? DateTime.now(),
        topicBreakdown: topicBreakdown,
      );
    } catch (e) {
      throw Exception('Failed to load session results: $e');
    }
  }

  String _getGrade(double accuracy) {
    if (accuracy >= 90) return 'Excellent';
    if (accuracy >= 80) return 'Very Good';
    if (accuracy >= 70) return 'Good';
    if (accuracy >= 60) return 'Average';
    if (accuracy >= 50) return 'Below Average';
    return 'Poor';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _shareResults(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _restartPractice(BuildContext context) {
    // TODO: Navigate to practice with same parameters
    context.go('/home');
  }
}

class ResultsData {
  final String sessionId;
  final String subject;
  final String? topic;
  final String mode;
  final int score;
  final int totalQuestions;
  final Duration duration;
  final Duration averageTime;
  final DateTime completedAt;
  final Map<String, Map<String, int>> topicBreakdown;

  ResultsData({
    required this.sessionId,
    required this.subject,
    this.topic,
    required this.mode,
    required this.score,
    required this.totalQuestions,
    required this.duration,
    required this.averageTime,
    required this.completedAt,
    this.topicBreakdown = const {},
  });
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
