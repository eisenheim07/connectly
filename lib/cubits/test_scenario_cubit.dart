import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/event_logger.dart';
import '../services/network_resilience_manager.dart';
import 'test_scenario_state.dart';

class TestScenarioCubit extends Cubit<TestScenarioState> {
  final EventLogger _logger = EventLogger();
  final NetworkResilienceManager _networkManager = NetworkResilienceManager();
  Timer? _countdownTimer;

  TestScenarioCubit() : super(const TestScenarioInitial());

  void startTest(String testName, int duration, VoidCallback onComplete) {
    emit(TestScenarioRunning(testName: testName, countdown: duration));
    
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = state as TestScenarioRunning;
      final newCountdown = currentState.countdown - 1;
      
      if (newCountdown <= 0) {
        timer.cancel();
        onComplete();
        emit(const TestScenarioInitial());
      } else {
        emit(TestScenarioRunning(testName: testName, countdown: newCountdown));
      }
    });
  }

  // Test 1: Late Join
  void testLateJoin() {
    _logger.log(
      type: EventType.info,
      message: '🧪 TEST: User B joins 20 seconds late',
      severity: ErrorSeverity.info,
      metadata: {'test': 'late_join', 'delay': '20s'},
    );

    _logger.log(
      type: EventType.meetingCreated,
      message: 'User A created meeting',
      metadata: {'timestamp': DateTime.now().toIso8601String()},
    );

    startTest('Late Join Test', 20, () {
      _logger.log(
        type: EventType.attendeeJoined,
        message: 'User B joined meeting (20 seconds late)',
        severity: ErrorSeverity.info,
        metadata: {'delay_seconds': 20, 'attendee': 'User B'},
      );
      emit(TestScenarioCompleted(testName: 'Late Join Test'));
    });
  }

  // Test 2: Camera Toggle
  void testCameraToggle() {
    _logger.log(
      type: EventType.info,
      message: '🧪 TEST: Camera toggle sequence',
      severity: ErrorSeverity.info,
    );

    _logger.log(
      type: EventType.videoStopped,
      message: 'User A turned off camera',
      metadata: {'action': 'camera_off'},
    );

    startTest('Camera Toggle Test', 5, () {
      _logger.log(
        type: EventType.videoStarted,
        message: 'User A turned camera back on',
        metadata: {'action': 'camera_on', 'downtime_seconds': 5},
      );
      emit(TestScenarioCompleted(testName: 'Camera Toggle Test'));
    });
  }

  // Test 3: Network Loss
  void testNetworkLoss() {
    _logger.log(
      type: EventType.info,
      message: '🧪 TEST: Network loss for 10 seconds',
      severity: ErrorSeverity.high,
    );

    _networkManager.onConnectionLost();
    _logger.log(
      type: EventType.networkLost,
      message: 'User A lost network connection',
      severity: ErrorSeverity.high,
      metadata: {'expected_duration': '10s'},
    );

    int reconnectAttempt = 0;
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (reconnectAttempt < 4) {
        reconnectAttempt++;
        _logger.log(
          type: EventType.reconnecting,
          message: 'Reconnection attempt $reconnectAttempt/5',
          severity: ErrorSeverity.medium,
          metadata: {'attempt': reconnectAttempt},
        );
      }
      
      if (reconnectAttempt >= 4) {
        timer.cancel();
      }
    });

    startTest('Network Loss Test', 10, () {
      _networkManager.onConnectionRecovered();
      _logger.log(
        type: EventType.networkRecovered,
        message: 'Network connection restored',
        severity: ErrorSeverity.info,
        metadata: {'downtime_seconds': 10, 'reconnect_attempts': 4},
      );
      emit(TestScenarioCompleted(testName: 'Network Loss Test'));
    });
  }

  // Test 4: App Background
  void testAppBackground() {
    _logger.log(
      type: EventType.info,
      message: '🧪 TEST: App backgrounded for 15 seconds',
      severity: ErrorSeverity.medium,
    );

    _logger.log(
      type: EventType.warning,
      message: 'App moved to background',
      severity: ErrorSeverity.medium,
      metadata: {'lifecycle': 'paused'},
    );

    _logger.log(
      type: EventType.videoStopped,
      message: 'Video paused (app backgrounded)',
      metadata: {'reason': 'app_background'},
    );

    startTest('App Background Test', 15, () {
      _logger.log(
        type: EventType.info,
        message: 'App returned to foreground',
        metadata: {'lifecycle': 'resumed', 'background_duration': '15s'},
      );

      _logger.log(
        type: EventType.videoStarted,
        message: 'Video resumed',
        metadata: {'reason': 'app_foreground'},
      );

      _logger.log(
        type: EventType.reconnecting,
        message: 'Reconnecting to meeting session',
        severity: ErrorSeverity.medium,
      );

      Future.delayed(const Duration(seconds: 2), () {
        _logger.log(
          type: EventType.reconnected,
          message: 'Successfully reconnected to meeting',
          severity: ErrorSeverity.info,
        );
      });

      emit(TestScenarioCompleted(testName: 'App Background Test'));
    });
  }

  // Test 5: Leave & Rejoin
  void testLeaveRejoin() {
    _logger.log(
      type: EventType.info,
      message: '🧪 TEST: User B leaves and rejoins',
      severity: ErrorSeverity.info,
    );

    _logger.log(
      type: EventType.attendeeLeft,
      message: 'User B left the meeting',
      metadata: {'attendee': 'User B', 'reason': 'user_initiated'},
    );

    _logger.log(
      type: EventType.videoStopped,
      message: 'User B video tile removed',
      metadata: {'attendee': 'User B'},
    );

    startTest('Leave & Rejoin Test', 8, () {
      _logger.log(
        type: EventType.attendeeJoined,
        message: 'User B rejoined the meeting',
        severity: ErrorSeverity.info,
        metadata: {'attendee': 'User B', 'rejoin': true},
      );

      _logger.log(
        type: EventType.videoStarted,
        message: 'User B video tile added',
        metadata: {'attendee': 'User B'},
      );

      emit(TestScenarioCompleted(testName: 'Leave & Rejoin Test'));
    });
  }

  // Test 6: Permission Flow
  void testPermissionFlow() {
    _logger.log(
      type: EventType.info,
      message: '🧪 TEST: Microphone permission flow',
      severity: ErrorSeverity.high,
    );

    _logger.log(
      type: EventType.permissionDenied,
      message: 'Microphone permission denied by user',
      severity: ErrorSeverity.high,
      metadata: {'permission': 'microphone', 'attempt': 1},
    );

    _logger.log(
      type: EventType.error,
      message: 'Cannot start audio - permission required',
      severity: ErrorSeverity.high,
    );

    startTest('Permission Flow Test', 5, () {
      _logger.log(
        type: EventType.info,
        message: 'Showing permission rationale to user',
        metadata: {'permission': 'microphone'},
      );

      Future.delayed(const Duration(seconds: 2), () {
        _logger.log(
          type: EventType.permissionGranted,
          message: 'Microphone permission granted',
          severity: ErrorSeverity.info,
          metadata: {'permission': 'microphone', 'attempt': 2},
        );

        _logger.log(
          type: EventType.audioUnmuted,
          message: 'Audio started successfully',
          severity: ErrorSeverity.info,
        );
      });

      emit(TestScenarioCompleted(testName: 'Permission Flow Test'));
    });
  }

  // Test 7: Poor Connection
  void testPoorConnection() {
    _logger.log(
      type: EventType.info,
      message: '🧪 TEST: Poor connection quality',
      severity: ErrorSeverity.medium,
    );

    _networkManager.onConnectionPoor();
    _logger.log(
      type: EventType.warning,
      message: 'Connection quality degraded',
      severity: ErrorSeverity.medium,
      metadata: {'quality': 'poor', 'packet_loss': '15%'},
    );

    startTest('Poor Connection Test', 7, () {
      _networkManager.onConnectionRecovered();
      _logger.log(
        type: EventType.networkRecovered,
        message: 'Connection quality improved',
        severity: ErrorSeverity.info,
        metadata: {'quality': 'good'},
      );

      emit(TestScenarioCompleted(testName: 'Poor Connection Test'));
    });
  }

  // Test 8: Duplicate Reconnect
  void testDuplicateReconnect() {
    _logger.log(
      type: EventType.info,
      message: '🧪 TEST: Duplicate reconnect suppression',
      severity: ErrorSeverity.medium,
    );

    _networkManager.onConnectionLost();
    _logger.log(
      type: EventType.networkLost,
      message: 'Connection lost',
      severity: ErrorSeverity.high,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _networkManager.onConnectionLost();
      _logger.log(
        type: EventType.warning,
        message: 'Duplicate disconnect event suppressed',
        severity: ErrorSeverity.low,
      );
    });

    startTest('Duplicate Reconnect Test', 5, () {
      _networkManager.onConnectionRecovered();
      _logger.log(
        type: EventType.networkRecovered,
        message: 'Connection recovered',
        severity: ErrorSeverity.info,
      );

      emit(TestScenarioCompleted(testName: 'Duplicate Reconnect Test'));
    });
  }

  // Run all tests sequentially
  Future<void> runAllTests() async {
    final tests = [
      testLateJoin,
      testCameraToggle,
      testNetworkLoss,
      testAppBackground,
      testLeaveRejoin,
      testPermissionFlow,
      testPoorConnection,
      testDuplicateReconnect,
    ];

    for (var test in tests) {
      test();
      // Wait for test to complete
      await Future.delayed(Duration(seconds: (state as TestScenarioRunning).countdown + 2));
    }

    emit(const TestScenarioAllCompleted());
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
