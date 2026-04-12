import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final Duration _checkInterval = const Duration(seconds: 3);

  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      final socket = await Socket.connect('8.8.8.8', 53, timeout: const Duration(seconds: 5));
      socket.destroy();
      return true;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  void startMonitoring(Function(bool) onConnectivityChanged) {
    stopMonitoring();
    
    hasInternetConnection().then((hasConnection) {
      onConnectivityChanged(hasConnection);
    });
    
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      hasInternetConnection().then((hasConnection) {
        onConnectivityChanged(hasConnection);
      });
    });
    
    _timer = Timer.periodic(_checkInterval, (timer) async {
      final hasConnection = await hasInternetConnection();
      onConnectivityChanged(hasConnection);
    });
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  void dispose() {
    stopMonitoring();
  }
}
