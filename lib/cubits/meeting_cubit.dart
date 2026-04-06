import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/meeting_repository.dart';
import '../services/event_logger.dart';
import 'meeting_state.dart';

class MeetingCubit extends Cubit<MeetingState> {
  final MeetingRepository _repository;
  final EventLogger _logger = EventLogger();

  MeetingCubit({MeetingRepository? repository})
      : _repository = repository ?? MeetingRepository(),
        super(const MeetingInitial());

  Future<void> createMeeting() async {
    emit(const MeetingLoading());
    try {
      _logger.logInfo('Creating new meeting');
      final response = await _repository.createAgentMeeting();
      _logger.log(
        type: EventType.meetingCreated,
        message: 'Meeting created successfully',
        metadata: {'meetingId': response.data.meeting.meetingId},
      );
      emit(MeetingCreated(response));
    } catch (e) {
      _logger.logError('Failed to create meeting', metadata: {'error': e.toString()});
      emit(MeetingError(e.toString()));
    }
  }

  Future<void> joinAsClient(String meetingId) async {
    emit(const MeetingLoading());
    try {
      _logger.logInfo('Joining meeting as client', metadata: {'meetingId': meetingId});
      final response = await _repository.joinAsClient(meetingId);
      _logger.log(
        type: EventType.meetingJoined,
        message: 'Joined meeting successfully',
        metadata: {'meetingId': meetingId},
      );
      emit(MeetingJoined(response));
    } catch (e) {
      _logger.logError('Failed to join meeting', metadata: {'meetingId': meetingId, 'error': e.toString()});
      emit(MeetingError(e.toString()));
    }
  }

  Future<void> joinAsClientWithMediaPlacement(String meetingId, String mediaPlacementJson) async {
    emit(const MeetingLoading());
    try {
      _logger.logInfo('Joining meeting with MediaPlacement', metadata: {'meetingId': meetingId});
      final response = await _repository.joinAsClientWithMediaPlacement(meetingId, mediaPlacementJson);
      _logger.log(
        type: EventType.meetingJoined,
        message: 'Joined meeting with MediaPlacement',
        metadata: {'meetingId': meetingId},
      );
      emit(MeetingJoined(response));
    } catch (e) {
      _logger.logError('Failed to join with MediaPlacement', metadata: {'error': e.toString()});
      emit(MeetingError(e.toString()));
    }
  }

  Future<void> joinAsClientWithFullResponse(String fullApiResponse) async {
    emit(const MeetingLoading());
    try {
      _logger.logInfo('Joining meeting with full API response');
      final response = await _repository.joinAsClientWithFullResponse(fullApiResponse);
      _logger.log(
        type: EventType.meetingJoined,
        message: 'Joined meeting with full response',
      );
      emit(MeetingJoined(response));
    } catch (e) {
      _logger.logError('Failed to join with full response', metadata: {'error': e.toString()});
      emit(MeetingError(e.toString()));
    }
  }

  Future<void> joinAsAgent(String meetingId) async {
    emit(const MeetingLoading());
    try {
      final response = await _repository.joinAsAgent(meetingId);
      emit(MeetingJoined(response));
    } catch (e) {
      emit(MeetingError(e.toString()));
    }
  }

  Future<void> joinWithMeetingDetails(String meetingDetailsJson) async {
    emit(const MeetingLoading());
    try {
      final response = await _repository.joinWithMeetingDetails(meetingDetailsJson);
      emit(MeetingJoined(response));
    } catch (e) {
      emit(MeetingError(e.toString()));
    }
  }

  void setLoading() {
    emit(const MeetingLoading());
  }

  void reset() {
    emit(const MeetingInitial());
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}
