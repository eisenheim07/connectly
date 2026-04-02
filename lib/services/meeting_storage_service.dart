import 'dart:convert';
import '../models/meeting_response.dart';

/// In-memory storage for meeting configurations
/// In a production app, this would use a backend database or shared preferences
class MeetingStorageService {
  static final MeetingStorageService _instance = MeetingStorageService._internal();
  factory MeetingStorageService() => _instance;
  MeetingStorageService._internal();

  final Map<String, Meeting> _meetings = {};

  /// Store full meeting configuration when created
  void storeMeeting(Meeting meeting) {
    _meetings[meeting.meetingId] = meeting;
    print('📦 Stored meeting: ${meeting.meetingId}');
  }

  /// Retrieve full meeting configuration by ID
  Meeting? getMeeting(String meetingId) {
    final meeting = _meetings[meetingId];
    if (meeting != null) {
      print('📦 Retrieved meeting: $meetingId');
    } else {
      print('📦 Meeting not found: $meetingId');
    }
    return meeting;
  }

  /// Clear all stored meetings
  void clear() {
    _meetings.clear();
    print('📦 Cleared all meetings');
  }
}
