import 'dart:convert';
import '../models/meeting_response.dart';

class MeetingStorageService {
  static final MeetingStorageService _instance = MeetingStorageService._internal();
  factory MeetingStorageService() => _instance;
  MeetingStorageService._internal();

  final Map<String, Meeting> _meetings = {};

  void storeMeeting(Meeting meeting) {
    _meetings[meeting.meetingId] = meeting;
  }

  Meeting? getMeeting(String meetingId) {
    return _meetings[meetingId];
  }

  void clear() {
    _meetings.clear();
  }
}
