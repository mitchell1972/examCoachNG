import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../core/utils/logger.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._internal();

  late FirebaseMessaging _messaging;
  late FirebaseAnalytics _analytics;

  FirebaseService._internal();

  Future<void> initialize() async {
    try {
      // Initialize Firebase Analytics
      _analytics = FirebaseAnalytics.instance;
      
      // Initialize Firebase Messaging
      _messaging = FirebaseMessaging.instance;
      
      // Request notification permissions
      await _requestNotificationPermissions();
      
      // Setup message handlers
      _setupMessageHandlers();
      
      Logger.info('Firebase service initialized');
    } catch (e) {
      Logger.error('Failed to initialize Firebase service', error: e);
      rethrow;
    }
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      Logger.info('Notification permission status: ${settings.authorizationStatus}');
    } catch (e) {
      Logger.error('Failed to request notification permissions', error: e);
    }
  }

  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger.info('Received foreground message: ${message.messageId}');
      _handleMessage(message);
    });

    // Handle messages when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Logger.info('App opened from background message: ${message.messageId}');
      _handleMessage(message);
    });

    // Handle messages when app is opened from terminated state
    FirebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        Logger.info('App opened from terminated state: ${message.messageId}');
        _handleMessage(message);
      }
    });
  }

  void _handleMessage(RemoteMessage message) {
    try {
      final data = message.data;
      
      // Log message data
      Logger.debug('Message data: $data');
      
      // Handle different message types
      if (data.containsKey('route')) {
        _handleDeepLink(data['route']);
      }
      
      if (data.containsKey('action')) {
        _handleAction(data['action'], data);
      }
    } catch (e) {
      Logger.error('Error handling Firebase message', error: e);
    }
  }

  void _handleDeepLink(String route) {
    // This would be handled by the deep link service
    Logger.info('Handling deep link from notification: $route');
  }

  void _handleAction(String action, Map<String, dynamic> data) {
    switch (action) {
      case 'daily_practice':
        Logger.info('Handling daily practice action');
        break;
      case 'streak_reminder':
        Logger.info('Handling streak reminder action');
        break;
      case 'new_content':
        Logger.info('Handling new content action');
        break;
      default:
        Logger.warning('Unknown notification action: $action');
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      Logger.debug('FCM Token obtained');
      return token;
    } catch (e) {
      Logger.error('Failed to get FCM token', error: e);
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      Logger.info('Subscribed to topic: $topic');
    } catch (e) {
      Logger.error('Failed to subscribe to topic: $topic', error: e);
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      Logger.info('Unsubscribed from topic: $topic');
    } catch (e) {
      Logger.error('Failed to unsubscribe from topic: $topic', error: e);
    }
  }

  // Analytics methods
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      Logger.debug('Analytics event logged: $name');
    } catch (e) {
      Logger.error('Failed to log analytics event: $name', error: e);
    }
  }

  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      Logger.debug('Analytics user ID set');
    } catch (e) {
      Logger.error('Failed to set analytics user ID', error: e);
    }
  }

  Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      Logger.debug('Analytics user property set: $name');
    } catch (e) {
      Logger.error('Failed to set analytics user property: $name', error: e);
    }
  }

  FirebaseAnalytics get analytics => _analytics;
  FirebaseMessaging get messaging => _messaging;
}
