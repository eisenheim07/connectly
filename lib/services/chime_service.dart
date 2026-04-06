import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/meeting_response.dart';
import 'event_logger.dart';
import 'network_resilience_manager.dart';

/// Service to handle Amazon Chime SDK integration via platform channels
class ChimeService {
  static const MethodChannel _channel = MethodChannel('com.connectly/chime');
  final EventLogger _logger = EventLogger();
  final NetworkResilienceManager _networkManager = NetworkResilienceManager();

  /// Initialize Chime meeting with meeting response data
  Future<bool> initializeMeeting(MeetingResponse meetingResponse) async {
    try {
      _logger.log(
        type: EventType.meetingJoined,
        message: 'Initializing Chime meeting',
        metadata: {
          'meetingId': meetingResponse.data.meeting.meetingId,
          'attendeeId': meetingResponse.data.attendee.attendeeId,
          'mediaRegion': meetingResponse.data.meeting.mediaRegion,
        },
      );

      final result = await _channel.invokeMethod('initializeMeeting', {
        'meetingId': meetingResponse.data.meeting.meetingId,
        'externalMeetingId': meetingResponse.data.meeting.externalMeetingId,
        'mediaRegion': meetingResponse.data.meeting.mediaRegion ?? 'us-east-1',
        'audioHostUrl': meetingResponse.data.meeting.mediaPlacement?.audioHostUrl,
        'audioFallbackUrl': meetingResponse.data.meeting.mediaPlacement?.audioFallbackUrl,
        'signalingUrl': meetingResponse.data.meeting.mediaPlacement?.signalingUrl,
        'turnControlUrl': meetingResponse.data.meeting.mediaPlacement?.turnControlUrl,
        'attendeeId': meetingResponse.data.attendee.attendeeId,
        'externalUserId': meetingResponse.data.attendee.externalUserId,
        'joinToken': meetingResponse.data.attendee.joinToken,
      });

      if (result == true) {
        _logger.log(
          type: EventType.meetingJoined,
          message: 'Meeting initialized successfully',
          severity: ErrorSeverity.info,
        );
        _networkManager.onConnectionRecovered();
      }

      return result == true;
    } on PlatformException catch (e) {
      _logger.logError(
        'Failed to initialize meeting: ${e.message}',
        metadata: {'code': e.code, 'details': e.details},
        stackTrace: e.stacktrace,
      );
      throw Exception('Failed to initialize meeting: ${e.message}');
    } catch (e, stackTrace) {
      _logger.logCritical(
        'Unexpected error initializing meeting',
        metadata: {'error': e.toString()},
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }

  /// Start local video
  Future<bool> startLocalVideo() async {
    try {
      _logger.log(type: EventType.videoStarted, message: 'Starting local video');
      
      final result = await _channel.invokeMethod('startLocalVideo');
      
      if (result == true) {
        _logger.log(type: EventType.videoStarted, message: 'Local video started successfully');
      }
      
      return result == true;
    } on PlatformException catch (e) {
      _logger.logError('Failed to start local video: ${e.message}', metadata: {'code': e.code});
      throw Exception('Failed to start local video: ${e.message}');
    }
  }

  /// Stop local video
  Future<bool> stopLocalVideo() async {
    try {
      _logger.log(type: EventType.videoStopped, message: 'Stopping local video');
      
      final result = await _channel.invokeMethod('stopLocalVideo');
      
      if (result == true) {
        _logger.log(type: EventType.videoStopped, message: 'Local video stopped successfully');
      }
      
      return result == true;
    } on PlatformException catch (e) {
      _logger.logError('Failed to stop local video: ${e.message}');
      throw Exception('Failed to stop local video: ${e.message}');
    }
  }

  /// Mute local audio
  Future<bool> muteLocalAudio() async {
    try {
      _logger.log(type: EventType.audioMuted, message: 'Muting local audio');
      
      final result = await _channel.invokeMethod('muteLocalAudio');
      
      if (result == true) {
        _logger.log(type: EventType.audioMuted, message: 'Local audio muted successfully');
      }
      
      return result == true;
    } on PlatformException catch (e) {
      _logger.logError('Failed to mute audio: ${e.message}');
      throw Exception('Failed to mute audio: ${e.message}');
    }
  }

  /// Unmute local audio
  Future<bool> unmuteLocalAudio() async {
    try {
      _logger.log(type: EventType.audioUnmuted, message: 'Unmuting local audio');
      
      final result = await _channel.invokeMethod('unmuteLocalAudio');
      
      if (result == true) {
        _logger.log(type: EventType.audioUnmuted, message: 'Local audio unmuted successfully');
      }
      
      return result == true;
    } on PlatformException catch (e) {
      _logger.logError('Failed to unmute audio: ${e.message}');
      throw Exception('Failed to unmute audio: ${e.message}');
    }
  }

  /// Switch camera (front/back)
  Future<bool> switchCamera() async {
    try {
      _logger.log(type: EventType.cameraToggled, message: 'Switching camera');
      
      final result = await _channel.invokeMethod('switchCamera');
      
      if (result == true) {
        _logger.log(type: EventType.cameraToggled, message: 'Camera switched successfully');
      }
      
      return result == true;
    } on PlatformException catch (e) {
      _logger.logError('Failed to switch camera: ${e.message}');
      throw Exception('Failed to switch camera: ${e.message}');
    }
  }

  /// Leave meeting
  Future<bool> leaveMeeting() async {
    try {
      _logger.log(type: EventType.meetingLeft, message: 'Leaving meeting');
      
      final result = await _channel.invokeMethod('leaveMeeting');
      
      if (result == true) {
        _logger.log(type: EventType.meetingLeft, message: 'Left meeting successfully');
        _networkManager.reset();
      }
      
      return result == true;
    } on PlatformException catch (e) {
      _logger.logError('Failed to leave meeting: ${e.message}');
      throw Exception('Failed to leave meeting: ${e.message}');
    }
  }

  /// Get list of active attendees
  Future<List<String>> getAttendees() async {
    try {
      final result = await _channel.invokeMethod('getAttendees');
      return List<String>.from(result as List);
    } on PlatformException catch (e) {
      _logger.logError('Failed to get attendees: ${e.message}');
      throw Exception('Failed to get attendees: ${e.message}');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _channel.invokeMethod('dispose');
      _networkManager.reset();
    } catch (e) {
      // Silently handle dispose errors
      _logger.logWarning('Error during dispose: $e');
    }
  }
}
