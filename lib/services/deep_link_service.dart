import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uni_links/uni_links.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  StreamSubscription<Uri>? _linkSubscription;
  final StreamController<Uri> _linkController = StreamController<Uri>.broadcast();

  Stream<Uri> get linkStream => _linkController.stream;

  Future<void> initialize() async {
    try {
      // Handle app launch from deep link
      final initialLink = await getInitialUri();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }

      // Listen for incoming links when app is already running
      _linkSubscription = linkStream.listen(
        (uri) => _handleDeepLink(uri),
        onError: (err) {
          if (kDebugMode) {
            print('Deep link error: $err');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize deep links: $e');
      }
    }
  }

  void _handleDeepLink(Uri uri) {
    if (kDebugMode) {
      print('Received deep link: $uri');
    }

    // Parse the deep link and emit to stream
    _linkController.add(uri);
  }

  DeepLinkData? parseDeepLink(Uri uri) {
    if (uri.scheme != 'examcoach') {
      return null;
    }

    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) {
      return null;
    }

    final action = pathSegments.first;
    
    switch (action) {
      case 'practice':
        return _parsePracticeLink(pathSegments, uri.queryParameters);
      case 'mock':
        return _parseMockLink(pathSegments, uri.queryParameters);
      case 'results':
        return _parseResultsLink(pathSegments, uri.queryParameters);
      case 'subject':
        return _parseSubjectLink(pathSegments, uri.queryParameters);
      default:
        return DeepLinkData(
          type: DeepLinkType.unknown,
          route: '/',
        );
    }
  }

  DeepLinkData _parsePracticeLink(List<String> pathSegments, Map<String, String> queryParams) {
    if (pathSegments.length < 2) {
      return DeepLinkData(
        type: DeepLinkType.practice,
        route: '/practice/ENG', // Default to English
      );
    }

    final subject = pathSegments[1];
    final topic = queryParams['topic'];
    
    String route = '/practice/$subject';
    if (topic != null) {
      route += '?topic=$topic';
    }

    return DeepLinkData(
      type: DeepLinkType.practice,
      route: route,
      subject: subject,
      topic: topic,
    );
  }

  DeepLinkData _parseMockLink(List<String> pathSegments, Map<String, String> queryParams) {
    if (pathSegments.length < 2) {
      return DeepLinkData(
        type: DeepLinkType.mock,
        route: '/mock/ENG', // Default to English
      );
    }

    final subject = pathSegments[1];
    final sessionId = queryParams['session'];
    
    String route = '/mock/$subject';
    if (sessionId != null) {
      route += '?sessionId=$sessionId';
    }

    return DeepLinkData(
      type: DeepLinkType.mock,
      route: route,
      subject: subject,
      sessionId: sessionId,
    );
  }

  DeepLinkData _parseResultsLink(List<String> pathSegments, Map<String, String> queryParams) {
    if (pathSegments.length < 2) {
      return DeepLinkData(
        type: DeepLinkType.unknown,
        route: '/home',
      );
    }

    final sessionId = pathSegments[1];
    
    return DeepLinkData(
      type: DeepLinkType.results,
      route: '/results/$sessionId',
      sessionId: sessionId,
    );
  }

  DeepLinkData _parseSubjectLink(List<String> pathSegments, Map<String, String> queryParams) {
    if (pathSegments.length < 2) {
      return DeepLinkData(
        type: DeepLinkType.subjects,
        route: '/subjects',
      );
    }

    final subject = pathSegments[1];
    
    return DeepLinkData(
      type: DeepLinkType.practice,
      route: '/practice/$subject',
      subject: subject,
    );
  }

  String generatePracticeLink({
    required String subject,
    String? topic,
  }) {
    String link = 'examcoach://practice/$subject';
    if (topic != null) {
      link += '?topic=$topic';
    }
    return link;
  }

  String generateMockLink({
    required String subject,
    String? sessionId,
  }) {
    String link = 'examcoach://mock/$subject';
    if (sessionId != null) {
      link += '?session=$sessionId';
    }
    return link;
  }

  String generateResultsLink(String sessionId) {
    return 'examcoach://results/$sessionId';
  }

  void dispose() {
    _linkSubscription?.cancel();
    _linkController.close();
  }
}

class DeepLinkData {
  final DeepLinkType type;
  final String route;
  final String? subject;
  final String? topic;
  final String? sessionId;

  const DeepLinkData({
    required this.type,
    required this.route,
    this.subject,
    this.topic,
    this.sessionId,
  });

  @override
  String toString() {
    return 'DeepLinkData(type: $type, route: $route, subject: $subject, topic: $topic, sessionId: $sessionId)';
  }
}

enum DeepLinkType {
  practice,
  mock,
  results,
  subjects,
  unknown,
}
