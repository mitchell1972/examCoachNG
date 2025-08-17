import 'dart:async';
import 'package:uni_links/uni_links.dart';
import 'package:go_router/go_router.dart';

import '../core/env/env.dart';
import '../core/utils/logger.dart';

class DeepLinkService {
  static DeepLinkService? _instance;
  static DeepLinkService get instance => _instance ??= DeepLinkService._internal();

  StreamSubscription<Uri>? _linkSubscription;
  GoRouter? _router;

  DeepLinkService._internal();

  Future<void> initialize() async {
    try {
      // Set the router reference when available
      // This would be called from the app router provider
      
      // Listen for incoming links when app is already running
      _linkSubscription = linkStream.listen(
        _handleIncomingLink,
        onError: (err) {
          Logger.error('Deep link stream error', error: err);
        },
      );

      // Handle initial link when app is launched from a deep link
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        Logger.info('App launched with deep link: $initialUri');
        _handleIncomingLink(initialUri);
      }

      Logger.info('Deep link service initialized');
    } catch (e) {
      Logger.error('Failed to initialize deep link service', error: e);
    }
  }

  void setRouter(GoRouter router) {
    _router = router;
    Logger.debug('Router set for deep link service');
  }

  void _handleIncomingLink(Uri uri) {
    try {
      Logger.info('Handling deep link: $uri');

      // Validate the scheme
      if (uri.scheme != Env.deepLinkScheme) {
        Logger.warning('Invalid deep link scheme: ${uri.scheme}');
        return;
      }

      final path = uri.path;
      final queryParams = uri.queryParameters;

      Logger.debug('Deep link path: $path, params: $queryParams');

      // Route to appropriate screen based on path
      if (_router != null) {
        _routeDeepLink(path, queryParams);
      } else {
        Logger.warning('Router not available for deep link routing');
        // Store the link to handle later when router is available
        _pendingDeepLink = uri;
      }
    } catch (e) {
      Logger.error('Error handling deep link', error: e);
    }
  }

  Uri? _pendingDeepLink;

  void handlePendingDeepLink() {
    if (_pendingDeepLink != null && _router != null) {
      _handleIncomingLink(_pendingDeepLink!);
      _pendingDeepLink = null;
    }
  }

  void _routeDeepLink(String path, Map<String, String> queryParams) {
    try {
      switch (path) {
        case '/practice':
          final subject = queryParams['subject'];
          final topic = queryParams['topic'];
          if (subject != null) {
            _router!.go('/home/practice/$subject${topic != null ? '?topic=$topic' : ''}');
          }
          break;

        case '/mock':
          final subject = queryParams['subject'];
          if (subject != null) {
            _router!.go('/home/mock/$subject');
          }
          break;

        case '/results':
          final sessionId = queryParams['session_id'];
          if (sessionId != null) {
            _router!.go('/home/results/$sessionId');
          }
          break;

        case '/downloads':
          _router!.go('/home/downloads');
          break;

        case '/billing':
          _router!.go('/home/billing');
          break;

        case '/settings':
          _router!.go('/home/settings');
          break;

        case '/home':
        default:
          _router!.go('/home');
          break;
      }

      Logger.info('Deep link routed successfully: $path');
    } catch (e) {
      Logger.error('Error routing deep link', error: e);
      // Fallback to home screen
      _router?.go('/home');
    }
  }

  String generateDeepLink({
    required String path,
    Map<String, String>? params,
  }) {
    try {
      final uri = Uri(
        scheme: Env.deepLinkScheme,
        host: Env.deepLinkHost,
        path: path,
        queryParameters: params,
      );

      Logger.debug('Generated deep link: $uri');
      return uri.toString();
    } catch (e) {
      Logger.error('Error generating deep link', error: e);
      return '${Env.deepLinkScheme}://${Env.deepLinkHost}/home';
    }
  }

  String generatePracticeLink({
    required String subject,
    String? topic,
  }) {
    return generateDeepLink(
      path: '/practice',
      params: {
        'subject': subject,
        if (topic != null) 'topic': topic,
      },
    );
  }

  String generateMockLink({required String subject}) {
    return generateDeepLink(
      path: '/mock',
      params: {'subject': subject},
    );
  }

  String generateResultsLink({required String sessionId}) {
    return generateDeepLink(
      path: '/results',
      params: {'session_id': sessionId},
    );
  }

  void dispose() {
    try {
      _linkSubscription?.cancel();
      _linkSubscription = null;
      Logger.info('Deep link service disposed');
    } catch (e) {
      Logger.error('Error disposing deep link service', error: e);
    }
  }
}
