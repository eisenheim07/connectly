import 'dart:async';
import 'package:flutter/foundation.dart';
import 'event_logger.dart';

enum NetworkConnectionState {
  connected,
  disconnected,
  reconnecting,
  poor,
}

class NetworkResilienceManager {
  static final NetworkResilienceManager _instance = NetworkResilienceManager._internal();
  factory NetworkResilienceManager() => _instance;
  NetworkResilienceManager._internal();

  final EventLogger _logger = EventLogger();

  NetworkConnectionState _currentState = NetworkConnectionState.disconnected;
  DateTime? _lastDisconnectTime;
  DateTime? _lastReconnectAttempt;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _staleSessionTimer;
  bool _isReconnecting = false;

  static const int maxReconnectAttempts = 5;
  static const int baseRetryDelayMs = 1000; // 1 second
  static const int maxRetryDelayMs = 30000; // 30 seconds
  static const int staleSessionTimeoutMs = 60000; // 60 seconds

  final StreamController<NetworkConnectionState> _stateController = StreamController<NetworkConnectionState>.broadcast();
  Stream<NetworkConnectionState> get stateStream => _stateController.stream;
  NetworkConnectionState get currentState => _currentState;

  void onConnectionLost() {
    if (_currentState == NetworkConnectionState.disconnected) {
      _logger.logWarning('Duplicate disconnect event suppressed');
      return;
    }

    _lastDisconnectTime = DateTime.now();
    _updateState(NetworkConnectionState.disconnected);

    _logger.log(
      type: EventType.networkLost,
      message: 'Network connection lost',
      severity: ErrorSeverity.high,
      metadata: {'timestamp': _lastDisconnectTime!.toIso8601String()},
    );

    _startReconnectProcess();
  }

  void onConnectionRecovered() {
    _lastReconnectAttempt = null;
    _reconnectAttempts = 0;
    _isReconnecting = false;
    _cancelReconnectTimer();
    _cancelStaleSessionTimer();

    _updateState(NetworkConnectionState.connected);

    final downtime = _lastDisconnectTime != null ? DateTime.now().difference(_lastDisconnectTime!).inSeconds : 0;

    _logger.log(
      type: EventType.networkRecovered,
      message: 'Network connection recovered',
      severity: ErrorSeverity.info,
      metadata: {
        'downtime_seconds': downtime,
        'reconnect_attempts': _reconnectAttempts,
      },
    );
  }

  void onConnectionPoor() {
    if (_currentState == NetworkConnectionState.poor) return;

    _updateState(NetworkConnectionState.poor);

    _logger.log(
      type: EventType.warning,
      message: 'Network connection quality degraded',
      severity: ErrorSeverity.medium,
    );
  }

  void _startReconnectProcess() {
    if (_isReconnecting) {
      _logger.logWarning('Reconnect already in progress, suppressing duplicate');
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts = 0;
    _scheduleReconnect();
    _startStaleSessionTimer();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _logger.logError(
        'Max reconnect attempts reached',
        metadata: {'attempts': _reconnectAttempts},
      );
      _isReconnecting = false;
      return;
    }

    _reconnectAttempts++;
    final delay = _calculateBackoffDelay(_reconnectAttempts);

    _updateState(NetworkConnectionState.reconnecting);

    _logger.log(
      type: EventType.reconnecting,
      message: 'Attempting to reconnect (attempt $_reconnectAttempts/$maxReconnectAttempts)',
      severity: ErrorSeverity.medium,
      metadata: {
        'attempt': _reconnectAttempts,
        'delay_ms': delay,
        'next_retry_in': '${delay}ms',
      },
    );

    _reconnectTimer = Timer(Duration(milliseconds: delay), () {
      _lastReconnectAttempt = DateTime.now();
      _attemptReconnect();
    });
  }

  int _calculateBackoffDelay(int attempt) {
    final exponentialDelay = baseRetryDelayMs * (1 << (attempt - 1));
    final cappedDelay = exponentialDelay.clamp(baseRetryDelayMs, maxRetryDelayMs);
    
    final jitter = (cappedDelay * 0.2 * (DateTime.now().millisecond / 1000)).round();
    return cappedDelay + jitter;
  }

  void _attemptReconnect() {
    _logger.logInfo('Reconnect attempt triggered', metadata: {'attempt': _reconnectAttempts});

    if (_currentState != NetworkConnectionState.connected) {
      _scheduleReconnect();
    }
  }

  void _startStaleSessionTimer() {
    _cancelStaleSessionTimer();
    _staleSessionTimer = Timer(Duration(milliseconds: staleSessionTimeoutMs), () {
      if (_currentState != NetworkConnectionState.connected) {
        _logger.logCritical(
          'Session became stale - no connection for ${staleSessionTimeoutMs}ms',
          metadata: {
            'last_disconnect': _lastDisconnectTime?.toIso8601String(),
            'reconnect_attempts': _reconnectAttempts,
          },
        );
        _isReconnecting = false;
      }
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _cancelStaleSessionTimer() {
    _staleSessionTimer?.cancel();
    _staleSessionTimer = null;
  }

  void _updateState(NetworkConnectionState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _stateController.add(newState);
    }
  }

  void reset() {
    _cancelReconnectTimer();
    _cancelStaleSessionTimer();
    _reconnectAttempts = 0;
    _isReconnecting = false;
    _lastDisconnectTime = null;
    _lastReconnectAttempt = null;
    _updateState(NetworkConnectionState.disconnected);
  }

  void dispose() {
    _cancelReconnectTimer();
    _cancelStaleSessionTimer();
    _stateController.close();
  }
}
