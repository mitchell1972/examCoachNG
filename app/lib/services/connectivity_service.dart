import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/utils/logger.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityService {
  static ConnectivityService? _instance;
  static ConnectivityService get instance => _instance ??= ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  ConnectivityStatus _status = ConnectivityStatus.offline;
  ConnectivityStatus get status => _status;

  final StreamController<ConnectivityStatus> _statusController = 
      StreamController<ConnectivityStatus>.broadcast();
  
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  ConnectivityService._internal();

  Future<void> initialize() async {
    try {
      // Check initial connectivity
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateStatus,
        onError: (error) {
          Logger.error('Connectivity stream error', error: error);
        },
      );

      Logger.info('Connectivity service initialized');
    } catch (e) {
      Logger.error('Failed to initialize connectivity service', error: e);
    }
  }

  void _updateStatus(ConnectivityResult result) {
    final previousStatus = _status;
    
    switch (result) {
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        _status = ConnectivityStatus.online;
        break;
      case ConnectivityResult.none:
      default:
        _status = ConnectivityStatus.offline;
        break;
    }

    // Only emit if status changed
    if (previousStatus != _status) {
      _statusController.add(_status);
      Logger.info('Connectivity status changed: ${_status.name}');
    }
  }

  bool get isOnline => _status == ConnectivityStatus.online;
  bool get isOffline => _status == ConnectivityStatus.offline;

  Future<bool> hasInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      Logger.error('Error checking internet connection', error: e);
      return false;
    }
  }

  void dispose() {
    try {
      _connectivitySubscription?.cancel();
      _statusController.close();
      Logger.info('Connectivity service disposed');
    } catch (e) {
      Logger.error('Error disposing connectivity service', error: e);
    }
  }
}

// Riverpod providers
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService.instance;
});

final connectivityProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (status) => status == ConnectivityStatus.online,
    loading: () => false,
    error: (_, __) => false,
  );
});
