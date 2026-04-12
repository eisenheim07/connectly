import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/connectivity_service.dart';
import 'connectivity_state.dart';

/// Cubit to manage connectivity state
class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  bool _isMonitoring = false;
  bool _lastEmittedState = true; // Track last emitted state

  ConnectivityCubit() : super(const ConnectivityInitial());

  /// Start monitoring internet connectivity
  void startMonitoring() {
    print('ConnectivityCubit: startMonitoring called, _isMonitoring: $_isMonitoring');
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    
    // Start periodic checks
    _connectivityService.startMonitoring((hasConnection) {
      print('ConnectivityCubit: Callback received - hasConnection: $hasConnection, current state: $state, _lastEmittedState: $_lastEmittedState');
      
      // Emit state change if different from last emitted state
      if (hasConnection != _lastEmittedState) {
        _lastEmittedState = hasConnection;
        if (hasConnection) {
          print('ConnectivityCubit: Emitting ConnectivityConnected');
          emit(const ConnectivityConnected());
        } else {
          print('ConnectivityCubit: Emitting ConnectivityDisconnected');
          emit(const ConnectivityDisconnected());
        }
      } else {
        print('ConnectivityCubit: State unchanged, not emitting');
      }
    });
  }

  /// Stop monitoring
  void stopMonitoring() {
    print('ConnectivityCubit: stopMonitoring called');
    _isMonitoring = false;
    _connectivityService.stopMonitoring();
  }

  /// Manually check connectivity (for retry button)
  Future<void> checkConnectivity() async {
    print('ConnectivityCubit: checkConnectivity called');
    emit(const ConnectivityChecking());
    
    final hasConnection = await _connectivityService.hasInternetConnection();
    print('ConnectivityCubit: checkConnectivity result - hasConnection: $hasConnection');
    
    _lastEmittedState = hasConnection;
    if (hasConnection) {
      emit(const ConnectivityConnected());
    } else {
      emit(const ConnectivityDisconnected());
    }
  }

  @override
  Future<void> close() {
    print('ConnectivityCubit: close called');
    stopMonitoring();
    return super.close();
  }
}
