import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/connectivity_service.dart';
import 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  bool _isMonitoring = false;
  bool _isPaused = false;
  bool _lastEmittedState = true;
  Timer? _debounceTimer;
  int _disconnectedCount = 0;

  ConnectivityCubit() : super(const ConnectivityInitial());

  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _isPaused = false;
    
    _connectivityService.startMonitoring((hasConnection) {
      if (_isPaused) return;
      
      _debounceTimer?.cancel();
      
      if (hasConnection) {
        _disconnectedCount = 0;
        if (!_lastEmittedState) {
          _lastEmittedState = true;
          emit(const ConnectivityConnected());
        }
      } else {
        _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
          if (!_isPaused && _lastEmittedState) {
            _lastEmittedState = false;
            emit(const ConnectivityDisconnected());
          }
        });
      }
    });
  }

  void pauseMonitoring() {
    _isPaused = true;
    _disconnectedCount = 0;
    _debounceTimer?.cancel();
  }

  void resumeMonitoring() {
    _isPaused = false;
    _disconnectedCount = 0;
    _debounceTimer?.cancel();
    
    Future.delayed(const Duration(milliseconds: 2000), () async {
      if (!_isPaused) {
        final hasConnection = await _connectivityService.hasInternetConnection();
        
        if (hasConnection && !_lastEmittedState) {
          _lastEmittedState = true;
          emit(const ConnectivityConnected());
        }
      }
    });
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _isPaused = false;
    _debounceTimer?.cancel();
    _connectivityService.stopMonitoring();
  }

  Future<void> recheckConnectivity() async {
    if (_isPaused) return;
    
    final hasConnection = await _connectivityService.hasInternetConnection();
    
    if (hasConnection) {
      _disconnectedCount = 0;
      if (!_lastEmittedState) {
        _lastEmittedState = true;
        emit(const ConnectivityConnected());
      }
    }
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
    _debounceTimer?.cancel();
    return super.close();
  }
}
