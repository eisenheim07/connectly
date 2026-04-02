import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/meeting_response.dart';

/// Service to handle Amazon Chime SDK integration via platform channels
class ChimeService {
  static const MethodChannel _channel = MethodChannel('com.connectly/chime');

  /// Initialize Chime meeting with meeting response data
  Future<bool> initializeMeeting(MeetingResponse meetingResponse) async {
    try {
      final result = await _channel.invokeMethod('initializeMeeting', {
        'meetingId': meetingResponse.data.meeting.meetingId,
        'externalMeetingId': meetingResponse.data.meeting.externalMeetingId,
        'mediaRegion': meetingResponse.data.meeting.mediaRegion ?? 'us-east-1', // Default region if not provided
        'audioHostUrl': meetingResponse.data.meeting.mediaPlacement?.audioHostUrl,
        'audioFallbackUrl': meetingResponse.data.meeting.mediaPlacement?.audioFallbackUrl,
        'signalingUrl': meetingResponse.data.meeting.mediaPlacement?.signalingUrl,
        'turnControlUrl': meetingResponse.data.meeting.mediaPlacement?.turnControlUrl,
        'attendeeId': meetingResponse.data.attendee.attendeeId,
        'externalUserId': meetingResponse.data.attendee.externalUserId,
        'joinToken': meetingResponse.data.attendee.joinToken,
      });
      return result == true;
    } on PlatformException catch (e) {
      throw Exception('Failed to initialize meeting: ${e.message}');
    }
  }

  /// Start local video
  Future<bool> startLocalVideo() async {
    try {
      final result = await _channel.invokeMethod('startLocalVideo');
      return result == true;
    } on PlatformException catch (e) {
      throw Exception('Failed to start local video: ${e.message}');
    }
  }

  /// Stop local video
  Future<bool> stopLocalVideo() async {
    try {
      final result = await _channel.invokeMethod('stopLocalVideo');
      return result == true;
    } on PlatformException catch (e) {
      throw Exception('Failed to stop local video: ${e.message}');
    }
  }

  /// Mute local audio
  Future<bool> muteLocalAudio() async {
    try {
      final result = await _channel.invokeMethod('muteLocalAudio');
      return result == true;
    } on PlatformException catch (e) {
      throw Exception('Failed to mute audio: ${e.message}');
    }
  }

  /// Unmute local audio
  Future<bool> unmuteLocalAudio() async {
    try {
      final result = await _channel.invokeMethod('unmuteLocalAudio');
      return result == true;
    } on PlatformException catch (e) {
      throw Exception('Failed to unmute audio: ${e.message}');
    }
  }

  /// Switch camera (front/back)
  Future<bool> switchCamera() async {
    try {
      final result = await _channel.invokeMethod('switchCamera');
      return result == true;
    } on PlatformException catch (e) {
      throw Exception('Failed to switch camera: ${e.message}');
    }
  }

  /// Leave meeting
  Future<bool> leaveMeeting() async {
    try {
      final result = await _channel.invokeMethod('leaveMeeting');
      return result == true;
    } on PlatformException catch (e) {
      throw Exception('Failed to leave meeting: ${e.message}');
    }
  }

  /// Get list of active attendees
  Future<List<String>> getAttendees() async {
    try {
      final result = await _channel.invokeMethod('getAttendees');
      return List<String>.from(result as List);
    } on PlatformException catch (e) {
      throw Exception('Failed to get attendees: ${e.message}');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    // Silently handle dispose - plugin may not be fully implemented yet
    try {
      await _channel.invokeMethod('dispose');
    } catch (e) {
      // Ignore all errors during dispose - this is non-critical
    }
  }
}
