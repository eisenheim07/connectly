import 'dart:collection';
import 'package:flutter/foundation.dart';

enum EventType {
  meetingCreated,
  meetingJoined,
  meetingLeft,
  videoStarted,
  videoStopped,
  audioMuted,
  audioUnmuted,
  cameraToggled,
  networkLost,
  networkRecovered,
  reconnecting,
  reconnected,
  attendeeJoined,
  attendeeLeft,
  permissionDenied,
  permissionGranted,
  error,
  warning,
  info,
}

enum ErrorSeverity {
  critical,
  high,
  medium,
  low,
  info,
}

class ChimeEvent {
  final String id;
  final DateTime timestamp;
  final EventType type;
  final String message;
  final Map<String, dynamic>? metadata;
  final ErrorSeverity severity;
  final String? stackTrace;

  ChimeEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.message,
    this.metadata,
    this.severity = ErrorSeverity.info,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'type': type.name,
        'message': message,
        'metadata': metadata,
        'severity': severity.name,
        'stackTrace': stackTrace,
      };

  @override
  String toString() {
    return '[${timestamp.toIso8601String()}] [${severity.name.toUpperCase()}] [${type.name}] $message';
  }
}

class EventLogger {
  static final EventLogger _instance = EventLogger._internal();
  factory EventLogger() => _instance;
  EventLogger._internal();

  final Queue<ChimeEvent> _events = Queue();
  final int _maxEvents = 50;
  final List<Function(ChimeEvent)> _listeners = [];

  List<ChimeEvent> get events => _events.toList();

  void addListener(Function(ChimeEvent) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(ChimeEvent) listener) {
    _listeners.remove(listener);
  }

  void log({
    required EventType type,
    required String message,
    Map<String, dynamic>? metadata,
    ErrorSeverity severity = ErrorSeverity.info,
    String? stackTrace,
  }) {
    try {
      final event = ChimeEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        type: type,
        message: message,
        metadata: metadata,
        severity: severity,
        stackTrace: stackTrace,
      );

      _events.addLast(event);

      if (_events.length > _maxEvents) {
        _events.removeFirst();
      }

      for (var listener in _listeners) {
        try {
          listener(event);
        } catch (e) {}
      }
    } catch (e) {}
  }

  void logInfo(String message, {Map<String, dynamic>? metadata}) {
    log(type: EventType.info, message: message, metadata: metadata, severity: ErrorSeverity.info);
  }

  void logWarning(String message, {Map<String, dynamic>? metadata}) {
    log(type: EventType.warning, message: message, metadata: metadata, severity: ErrorSeverity.medium);
  }

  void logError(String message, {Map<String, dynamic>? metadata, String? stackTrace}) {
    log(type: EventType.error, message: message, metadata: metadata, severity: ErrorSeverity.high, stackTrace: stackTrace);
  }

  void logCritical(String message, {Map<String, dynamic>? metadata, String? stackTrace}) {
    log(type: EventType.error, message: message, metadata: metadata, severity: ErrorSeverity.critical, stackTrace: stackTrace);
  }

  void clear() {
    _events.clear();
  }

  List<Map<String, dynamic>> exportEvents() {
    return _events.map((e) => e.toJson()).toList();
  }
}
