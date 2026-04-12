import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/connectivity_service.dart';
import 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  bool _isMonitoring = false;
  bool _lastEmittedState = true;

  ConnectivityCubit() : super(const ConnectivityInitial());

  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    
    _connectivityService.startMonitoring((hasConnection) {
      if (hasConnection != _lastEmittedState) {
        _lastEmittedState = hasConnection;
        if (hasConnection) {
          emit(const ConnectivityConnected());
        } else {
          emit(const ConnectivityDisconnected());
        }
      }
    });
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _connectivityService.stopMonitoring();
  }

  Future<void> checkConnectivity() async {
    emit(const ConnectivityChecking());
    
    final hasConnection = await _connectivityService.hasInternetConnection();
    
    _lastEmittedState = hasConnection;
    if (hasConnection) {
      emit(const ConnectivityConnected());
    } else {
      emit(const ConnectivityDisconnected());
    }
  }

  @override
  Future<void> close() {
    stopMonitoring();
    return super.close();
  }
}
