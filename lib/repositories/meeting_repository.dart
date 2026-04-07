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
    // Get client token from API
    final clientResponse = await _apiService.joinMeeting(
      userType: AppConstants.userTypeClient,
      meetingId: meetingId,
    );

    print("CLIENT 1.0 ===>>> $clientResponse");

    // Parse the MediaPlacement JSON
    try {
      final mediaPlacementData = json.decode(mediaPlacementJson) as Map<String, dynamic>;
      final mediaPlacement = MediaPlacement.fromJson(mediaPlacementData);
      
      // Create a complete meeting object with the provided MediaPlacement
      final completeMeeting = Meeting(
        meetingId: meetingId,
        externalMeetingId: clientResponse.data.meeting.externalMeetingId,
        mediaRegion: 'ap-southeast-1', // Default region
        mediaPlacement: mediaPlacement,
      );
      
      // Return response with complete meeting config
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
      // Parse the full API response
      final responseData = json.decode(fullApiResponse) as Map<String, dynamic>;
      
      // Extract meeting data
      final data = responseData['data'] as Map<String, dynamic>;
      final meetingData = data['meeting'] as Map<String, dynamic>;
      final attendeeData = data['attendee'] as Map<String, dynamic>;
      
      // Extract meeting ID
      final meetingId = meetingData['MeetingId'] as String;
      
      // Get client token from API (to get client attendee, not agent attendee)
      final clientResponse = await _apiService.joinMeeting(
        userType: AppConstants.userTypeClient,
        meetingId: meetingId,
      );

      print("CLIENT 1.1 ===>>> $clientResponse");

      // Parse the meeting object from the pasted response
      final meeting = Meeting.fromJson(meetingData);
      
      // Return response with meeting config from pasted response + client attendee from API
      return MeetingResponse(
        status: clientResponse.status,
        message: 'Joined meeting successfully',
        data: MeetingData(
          meeting: meeting, // Full meeting config from pasted response
          attendee: clientResponse.data.attendee, // Client attendee from API
        ),
      );
    } catch (e) {
      throw Exception('Invalid API response format: $e\n\nPlease paste the complete API response.');
    }
  }

  Future<MeetingResponse> joinWithMeetingDetails(String meetingDetailsJson) async {
    try {
      // Parse the meeting details JSON
      final details = json.decode(meetingDetailsJson) as Map<String, dynamic>;
      final meetingId = details['meetingId'] as String;
      final audioHostId = details['audioHostId'] as String;
      
      print('🔧 Reconstructing MediaPlacement:');
      print('   Meeting ID: $meetingId');
      print('   Audio Host ID: $audioHostId');

      // Get client token from API
      final clientResponse = await _apiService.joinMeeting(
        userType: AppConstants.userTypeClient,
        meetingId: meetingId,
      );

      print("CLIENT 1.2 ===>>> $clientResponse");

      // Extract media server identifier from audioHostId (e.g., m1, m2, m3)
      // audioHostId format: "8ab31f3854e3b75f4dd89b89c25ce8b7.k.m1.as1.app.chime.aws"
      String mediaServer = 'm1'; // default
      if (audioHostId.contains('.k.m')) {
        final parts = audioHostId.split('.k.m');
        if (parts.length > 1) {
          final serverPart = parts[1].split('.')[0];
          mediaServer = 'm$serverPart';
        }
      }

      print('   Media Server: $mediaServer');

      // Reconstruct MediaPlacement using the pattern
      // audioHostId already contains full domain, just add port
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
      
      print('   ✅ MediaPlacement reconstructed:');
      print('      audioHostUrl: ${mediaPlacement.audioHostUrl}');
      print('      signalingUrl: ${mediaPlacement.signalingUrl}');

      // Create complete meeting object
      final completeMeeting = Meeting(
        meetingId: meetingId,
        externalMeetingId: clientResponse.data.meeting.externalMeetingId,
        mediaRegion: 'ap-southeast-1',
        mediaPlacement: mediaPlacement,
      );
      
      // Return response with complete meeting config
      return MeetingResponse(
        status: clientResponse.status,
        message: 'Joined meeting successfully',
        data: MeetingData(
          meeting: completeMeeting,
          attendee: clientResponse.data.attendee,
        ),
      );
    } catch (e) {
      print('❌ Error in joinWithMeetingDetails: $e');
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
