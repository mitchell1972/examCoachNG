import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  final StreamController<ConnectivityStatus> _statusController = 
      StreamController<ConnectivityStatus>.broadcast();

  Stream<ConnectivityStatus> get statusStream => _statusController.stream;
  
  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;
  ConnectivityStatus get currentStatus => _currentStatus;

  bool get isOnline => _currentStatus == ConnectivityStatus.online;
  bool get isOffline => _currentStatus == ConnectivityStatus.offline;

  Future<void> initialize() async {
    try {
      // Check initial connectivity
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);

      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateStatus,
        onError: (error) {
          if (kDebugMode) {
            print('Connectivity error: $error');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize connectivity service: $e');
      }
    }
  }

  void _updateStatus(ConnectivityResult result) {
    final previousStatus = _currentStatus;
    
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        _currentStatus = ConnectivityStatus.online;
        break;
      case ConnectivityResult.none:
        _currentStatus = ConnectivityStatus.offline;
        break;
      default:
        _currentStatus = ConnectivityStatus.unknown;
    }

    if (previousStatus != _currentStatus) {
      if (kDebugMode) {
        print('Connectivity changed: ${_currentStatus.name}');
      }
      
      _statusController.add(_currentStatus);
      
      // Handle connectivity change events
      _handleConnectivityChange(previousStatus, _currentStatus);
    }
  }

  void _handleConnectivityChange(
    ConnectivityStatus previous, 
    ConnectivityStatus current,
  ) {
    if (previous == ConnectivityStatus.offline && 
        current == ConnectivityStatus.online) {
      // Came back online - trigger sync operations
      _onConnectionRestored();
    } else if (previous == ConnectivityStatus.online && 
               current == ConnectivityStatus.offline) {
      // Went offline - handle gracefully
      _onConnectionLost();
    }
  }

  void _onConnectionRestored() {
    if (kDebugMode) {
      print('Connection restored - triggering sync operations');
    }
    
    // Notify listeners that connection is restored
    // This could trigger:
    // - Syncing pending attempts
    // - Checking for pack updates
    // - Refreshing entitlements
    // - Uploading cached analytics
  }

  void _onConnectionLost() {
    if (kDebugMode) {
      print('Connection lost - switching to offline mode');
    }
    
    // Notify listeners that connection is lost
    // This could trigger:
    // - Showing offline indicators
    // - Disabling network-dependent features
    // - Switching to cached data
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking internet connection: $e');
      }
      return false;
    }
  }

  Future<ConnectivityResult> getConnectivityResult() async {
    return await _connectivity.checkConnectivity();
  }

  String getConnectivityStatusText() {
    switch (_currentStatus) {
      case ConnectivityStatus.online:
        return 'Online';
      case ConnectivityStatus.offline:
        return 'Offline';
      case ConnectivityStatus.unknown:
        return 'Unknown';
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _statusController.close();
  }
}

enum ConnectivityStatus {
  online,
  offline,
  unknown,
}

// Provider for connectivity service
import 'package:hooks_riverpod/hooks_riverpod.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.read(connectivityServiceProvider);
  return service.statusStream;
});
