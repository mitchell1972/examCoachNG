import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TimerBar extends HookWidget {
  final Duration totalDuration;
  final Duration remainingTime;
  final VoidCallback? onTimeUp;
  final bool isPaused;

  const TimerBar({
    super.key,
    required this.totalDuration,
    required this.remainingTime,
    this.onTimeUp,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = remainingTime.inMilliseconds / totalDuration.inMilliseconds;
    final isWarning = remainingTime.inMinutes < 10;
    final isCritical = remainingTime.inMinutes < 5;

    // Format time display
    String formatTime(Duration duration) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    Color getTimerColor() {
      if (isCritical) return Colors.red;
      if (isWarning) return Colors.orange;
      return Theme.of(context).colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isPaused ? Icons.pause : Icons.timer,
                size: 20,
                color: getTimerColor(),
              ),
              const SizedBox(width: 8),
              Text(
                isPaused ? 'PAUSED' : 'Time Remaining',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: getTimerColor(),
                ),
              ),
              const Spacer(),
              Text(
                formatTime(remainingTime),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: getTimerColor(),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(getTimerColor()),
          ),
          if (isWarning) ...[
            const SizedBox(height: 4),
            Text(
              isCritical 
                  ? 'Less than 5 minutes remaining!' 
                  : 'Less than 10 minutes remaining',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: getTimerColor(),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
