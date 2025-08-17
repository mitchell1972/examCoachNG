import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._internal();

  late FlutterLocalNotificationsPlugin _notifications;

  NotificationService._internal();

  Future<void> initialize() async {
    try {
      _notifications = FlutterLocalNotificationsPlugin();

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channels for Android
      await _createNotificationChannels();

      Logger.info('Notification service initialized');
    } catch (e) {
      Logger.error('Failed to initialize notification service', error: e);
      rethrow;
    }
  }

  Future<void> _createNotificationChannels() async {
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Daily practice channel
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            AppConstants.dailyPracticeChannelId,
            'Daily Practice',
            description: 'Daily practice reminders',
            importance: Importance.defaultImportance,
          ),
        );

        // Streak reminder channel
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            AppConstants.streakReminderChannelId,
            'Streak Reminders',
            description: 'Study streak reminders',
            importance: Importance.high,
          ),
        );

        // New content channel
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            AppConstants.newContentChannelId,
            'New Content',
            description: 'New question packs and content',
            importance: Importance.defaultImportance,
          ),
        );

        // Achievement channel
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            AppConstants.achievementChannelId,
            'Achievements',
            description: 'Achievement notifications',
            importance: Importance.defaultImportance,
          ),
        );

        // Payment channel
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            AppConstants.paymentChannelId,
            'Payments',
            description: 'Payment and subscription notifications',
            importance: Importance.high,
          ),
        );

        Logger.info('Notification channels created');
      }
    } catch (e) {
      Logger.error('Failed to create notification channels', error: e);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    try {
      final payload = response.payload;
      Logger.info('Notification tapped with payload: $payload');

      if (payload != null) {
        // Handle notification tap - this would typically navigate to a specific screen
        _handleNotificationPayload(payload);
      }
    } catch (e) {
      Logger.error('Error handling notification tap', error: e);
    }
  }

  void _handleNotificationPayload(String payload) {
    // Parse payload and handle navigation
    // This would be coordinated with the router/navigation service
    Logger.debug('Handling notification payload: $payload');
  }

  Future<void> showDailyPracticeReminder() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        AppConstants.dailyPracticeChannelId,
        'Daily Practice',
        channelDescription: 'Daily practice reminders',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        1,
        'Daily Practice Reminder',
        'Ready to practice? Let\'s keep your streak going!',
        details,
        payload: 'daily_practice',
      );

      Logger.info('Daily practice reminder shown');
    } catch (e) {
      Logger.error('Failed to show daily practice reminder', error: e);
    }
  }

  Future<void> showStreakReminder(int streakDays) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        AppConstants.streakReminderChannelId,
        'Streak Reminders',
        channelDescription: 'Study streak reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        2,
        'Keep Your Streak!',
        'You\'re on a $streakDays day streak. Don\'t break it now!',
        details,
        payload: 'streak_reminder',
      );

      Logger.info('Streak reminder shown for $streakDays days');
    } catch (e) {
      Logger.error('Failed to show streak reminder', error: e);
    }
  }

  Future<void> showNewContentNotification(String contentTitle) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        AppConstants.newContentChannelId,
        'New Content',
        channelDescription: 'New question packs and content',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        3,
        'New Content Available',
        contentTitle,
        details,
        payload: 'new_content',
      );

      Logger.info('New content notification shown: $contentTitle');
    } catch (e) {
      Logger.error('Failed to show new content notification', error: e);
    }
  }

  Future<void> showAchievementNotification(String achievement) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        AppConstants.achievementChannelId,
        'Achievements',
        channelDescription: 'Achievement notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        4,
        'Achievement Unlocked!',
        achievement,
        details,
        payload: 'achievement',
      );

      Logger.info('Achievement notification shown: $achievement');
    } catch (e) {
      Logger.error('Failed to show achievement notification', error: e);
    }
  }

  Future<void> showPaymentNotification(String message) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        AppConstants.paymentChannelId,
        'Payments',
        channelDescription: 'Payment and subscription notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        5,
        'Payment Update',
        message,
        details,
        payload: 'payment',
      );

      Logger.info('Payment notification shown: $message');
    } catch (e) {
      Logger.error('Failed to show payment notification', error: e);
    }
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    try {
      await _notifications.zonedSchedule(
        100,
        'Daily Practice Reminder',
        'Time for your daily practice session!',
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.dailyPracticeChannelId,
            'Daily Practice',
            channelDescription: 'Daily practice reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_practice_scheduled',
      );

      Logger.info('Daily reminder scheduled for $hour:$minute');
    } catch (e) {
      Logger.error('Failed to schedule daily reminder', error: e);
    }
  }

  TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz = TimeZone();
    final now = TZDateTime.now(tz.local);
    TZDateTime scheduledDate = TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      Logger.info('All notifications cancelled');
    } catch (e) {
      Logger.error('Failed to cancel all notifications', error: e);
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      Logger.info('Notification cancelled: $id');
    } catch (e) {
      Logger.error('Failed to cancel notification: $id', error: e);
    }
  }
}

// Import for timezone handling
import 'package:timezone/timezone.dart' as tz;

typedef TZDateTime = tz.TZDateTime;
typedef TimeZone = tz.TimeZone;
