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
