import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to check internet connectivity
/// Uses connectivity_plus package and socket connection verification
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final Duration _checkInterval = const Duration(seconds: 3);

  /// Check if internet is actually available (not just connected to network)
  Future<bool> hasInternetConnection() async {
    try {
      // First check if device has network connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      print('ConnectivityService: Connectivity result: $connectivityResult');
      
      if (connectivityResult.contains(ConnectivityResult.none)) {
        print('ConnectivityService: No network connection');
        return false;
      }

      // Then verify actual internet access by connecting to Google DNS
      final socket = await Socket.connect('8.8.8.8', 53, timeout: const Duration(seconds: 3));
      socket.destroy();
      print('ConnectivityService: Internet available - socket connected');
      return true;
    } on SocketException catch (e) {
      print('ConnectivityService: No internet - SocketException: $e');
      return false;
    } on TimeoutException catch (e) {
      print('ConnectivityService: No internet - TimeoutException: $e');
      return false;
    } catch (e) {
      print('ConnectivityService: No internet - Exception: $e');
      return false;
    }
  }

  /// Start periodic connectivity check
  void startMonitoring(Function(bool) onConnectivityChanged) {
    print('ConnectivityService: Starting monitoring');
    stopMonitoring();
    
    // Check immediately first
    hasInternetConnection().then((hasConnection) {
      print('ConnectivityService: Initial check - hasConnection: $hasConnection');
      onConnectivityChanged(hasConnection);
    });
    
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      print('ConnectivityService: Connectivity changed: $results');
      hasInternetConnection().then((hasConnection) {
        print('ConnectivityService: After connectivity change - hasConnection: $hasConnection');
        onConnectivityChanged(hasConnection);
      });
    });
    
    // Also do periodic checks every 3 seconds
    _timer = Timer.periodic(_checkInterval, (timer) async {
      print('ConnectivityService: Periodic check at ${DateTime.now()}');
      final hasConnection = await hasInternetConnection();
      print('ConnectivityService: Periodic result - hasConnection: $hasConnection');
      onConnectivityChanged(hasConnection);
    });
  }

  /// Stop monitoring
  void stopMonitoring() {
    print('ConnectivityService: Stopping monitoring');
    _timer?.cancel();
    _timer = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
  }
}
