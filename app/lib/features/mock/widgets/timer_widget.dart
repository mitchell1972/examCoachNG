import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class TimerWidget extends StatelessWidget {
  final Duration? timeRemaining;
  final bool isPaused;
  final VoidCallback? onPause;
  final VoidCallback? onResume;

  const TimerWidget({
    super.key,
    this.timeRemaining,
    this.isPaused = false,
    this.onPause,
    this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    if (timeRemaining == null) {
      return const SizedBox.shrink();
    }

    final minutes = timeRemaining!.inMinutes;
    final seconds = timeRemaining!.inSeconds % 60;
    final timeText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    Color timerColor;
    IconData timerIcon;
    
    if (timeRemaining!.inMinutes <= 5) {
      timerColor = AppTheme.errorColor;
      timerIcon = Icons.warning;
    } else if (timeRemaining!.inMinutes <= 15) {
      timerColor = AppTheme.warningColor;
      timerIcon = Icons.schedule;
    } else {
      timerColor = AppTheme.successColor;
      timerIcon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: timerColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            timerIcon,
            color: timerColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            timeText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: timerColor,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          
          // Pause/Resume button
          GestureDetector(
            onTap: isPaused ? onResume : onPause,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: timerColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPaused ? Icons.play_arrow : Icons.pause,
                color: timerColor,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimerDisplay extends StatelessWidget {
  final Duration? timeRemaining;
  final bool showWarning;

  const TimerDisplay({
    super.key,
    this.timeRemaining,
    this.showWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    if (timeRemaining == null) {
      return const Text('--:--');
    }

    final minutes = timeRemaining!.inMinutes;
    final seconds = timeRemaining!.inSeconds % 60;
    final timeText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    Color textColor;
    if (timeRemaining!.inMinutes <= 5) {
      textColor = AppTheme.errorColor;
    } else if (timeRemaining!.inMinutes <= 15) {
      textColor = AppTheme.warningColor;
    } else {
      textColor = AppTheme.textPrimary;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showWarning && timeRemaining!.inMinutes <= 15) ...[
          Icon(
            Icons.warning,
            color: textColor,
            size: 16,
          ),
          const SizedBox(width: 4),
        ],
        Text(
          timeText,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class CircularTimerWidget extends StatelessWidget {
  final Duration? timeRemaining;
  final Duration totalDuration;
  final double size;

  const CircularTimerWidget({
    super.key,
    this.timeRemaining,
    required this.totalDuration,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (timeRemaining == null) {
      return SizedBox(
        height: size,
        width: size,
        child: const CircularProgressIndicator(value: 0),
      );
    }

    final progress = 1.0 - (timeRemaining!.inSeconds / totalDuration.inSeconds);
    final minutes = timeRemaining!.inMinutes;
    
    Color progressColor;
    if (timeRemaining!.inMinutes <= 5) {
      progressColor = AppTheme.errorColor;
    } else if (timeRemaining!.inMinutes <= 15) {
      progressColor = AppTheme.warningColor;
    } else {
      progressColor = AppTheme.primaryColor;
    }

    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        children: [
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              strokeWidth: 4,
            ),
          ),
          Center(
            child: Text(
              '$minutes',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
