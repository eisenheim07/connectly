import 'dart:convert';
import '../models/meeting_response.dart';
import '../services/api_service.dart';
import '../utils/app_constants.dart';

class MeetingRepository {
  final ApiService _apiService;

  MeetingRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<MeetingResponse> createAgentMeeting() async {
    return await _apiService.createMeeting(
      userType: AppConstants.userTypeAgent,
    );
  }

  Future<MeetingResponse> joinAsClient(String meetingId) async {
    return await _apiService.joinMeeting(
      userType: AppConstants.userTypeClient,
      meetingId: meetingId,
    );
  }

  Future<MeetingResponse> joinAsClientWithMediaPlacement(String meetingId, String mediaPlacementJson) async {
    final clientResponse = await _apiService.joinMeeting(
      userType: AppConstants.userTypeClient,
      meetingId: meetingId,
    );

    try {
      final mediaPlacementData = json.decode(mediaPlacementJson) as Map<String, dynamic>;
      final mediaPlacement = MediaPlacement.fromJson(mediaPlacementData);
      
      final completeMeeting = Meeting(
        meetingId: meetingId,
        externalMeetingId: clientResponse.data.meeting.externalMeetingId,
        mediaRegion: 'ap-southeast-1',
        mediaPlacement: mediaPlacement,
      );
      
      return MeetingResponse(
        status: clientResponse.status,
        message: clientResponse.message,
        data: MeetingData(
          meeting: completeMeeting,
          attendee: clientResponse.data.attendee,
        ),
      );
    } catch (e) {
      throw Exception('Invalid MediaPlacement JSON: $e');
    }
  }

  Future<MeetingResponse> joinAsClientWithFullResponse(String fullApiResponse) async {
    try {
      final responseData = json.decode(fullApiResponse) as Map<String, dynamic>;
      
      final data = responseData['data'] as Map<String, dynamic>;
      final meetingData = data['meeting'] as Map<String, dynamic>;
      final attendeeData = data['attendee'] as Map<String, dynamic>;
      
      final meetingId = meetingData['MeetingId'] as String;
      
      final clientResponse = await _apiService.joinMeeting(
        userType: AppConstants.userTypeClient,
        meetingId: meetingId,
      );

      final meeting = Meeting.fromJson(meetingData);
      
      return MeetingResponse(
        status: clientResponse.status,
        message: 'Joined meeting successfully',
        data: MeetingData(
          meeting: meeting,
          attendee: clientResponse.data.attendee,
        ),
      );
    } catch (e) {
      throw Exception('Invalid API response format: $e\n\nPlease paste the complete API response.');
    }
  }

  Future<MeetingResponse> joinWithMeetingDetails(String meetingDetailsJson) async {
    try {
      final details = json.decode(meetingDetailsJson) as Map<String, dynamic>;
      final meetingId = details['meetingId'] as String;
      final audioHostId = details['audioHostId'] as String;

      final clientResponse = await _apiService.joinMeeting(
        userType: AppConstants.userTypeClient,
        meetingId: meetingId,
      );

      String mediaServer = 'm1';
      if (audioHostId.contains('.k.m')) {
        final parts = audioHostId.split('.k.m');
        if (parts.length > 1) {
          final serverPart = parts[1].split('.')[0];
          mediaServer = 'm$serverPart';
        }
      }

      final mediaPlacement = MediaPlacement(
        audioHostUrl: '$audioHostId.k.m1.as1.app.chime.aws:3478',
        audioFallbackUrl: 'wss://wss.k.$mediaServer.as1.app.chime.aws:443/calls/$meetingId',
        signalingUrl: 'wss://signal.$mediaServer.as1.app.chime.aws/control/$meetingId',
        turnControlUrl: 'https://2954.cell.ap-southeast-1.meetings.chime.aws/v2/turn_sessions',
        screenDataUrl: 'wss://bitpw.$mediaServer.as1.app.chime.aws:443/v2/screen/$meetingId',
        screenViewingUrl: 'wss://bitpw.$mediaServer.as1.app.chime.aws:443/ws/connect?passcode=null&viewer_uuid=null&X-BitHub-Call-Id=$meetingId',
        screenSharingUrl: 'wss://bitpw.$mediaServer.as1.app.chime.aws:443/v2/screen/$meetingId',
        eventIngestionUrl: 'https://data.svc.as1.ingest.chime.aws/v1/client-events',
      );

      final completeMeeting = Meeting(
        meetingId: meetingId,
        externalMeetingId: clientResponse.data.meeting.externalMeetingId,
        mediaRegion: 'ap-southeast-1',
        mediaPlacement: mediaPlacement,
      );
      
      return MeetingResponse(
        status: clientResponse.status,
        message: 'Joined meeting successfully',
        data: MeetingData(
          meeting: completeMeeting,
          attendee: clientResponse.data.attendee,
        ),
      );
    } catch (e) {
      throw Exception('Invalid meeting details format: $e\n\nExpected: {"meetingId":"...","audioHostId":"..."}');
    }
  }

  Future<MeetingResponse> joinAsAgent(String meetingId) async {
    return await _apiService.joinMeeting(
      userType: AppConstants.userTypeAgent,
      meetingId: meetingId,
    );
  }

  void dispose() {
    _apiService.dispose();
  }
}
