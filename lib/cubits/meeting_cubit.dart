import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/meeting_repository.dart';
import 'meeting_state.dart';

class MeetingCubit extends Cubit<MeetingState> {
  final MeetingRepository _repository;

  MeetingCubit({MeetingRepository? repository})
      : _repository = repository ?? MeetingRepository(),
        super(const MeetingInitial());

  Future<void> createMeeting() async {
    emit(const MeetingLoading());
    try {
      final response = await _repository.createAgentMeeting();
      emit(MeetingCreated(response));
    } catch (e) {
      emit(MeetingError(e.toString()));
    }
  }

  Future<void> joinAsClient(String meetingId) async {
    emit(const MeetingLoading());
    try {
      final response = await _repository.joinAsClient(meetingId);
      emit(MeetingJoined(response));
    } catch (e) {
      emit(MeetingError(e.toString()));
    }
  }

  Future<void> joinAsClientWithMediaPlacement(String meetingId, String mediaPlacementJson) async {
    emit(const MeetingLoading());
    try {
      final response = await _repository.joinAsClientWithMediaPlacement(meetingId, mediaPlacementJson);
      emit(MeetingJoined(response));
    } catch (e) {
      emit(MeetingError(e.toString()));
    }
  }

  Future<void> joinAsClientWithFullResponse(String fullApiResponse) async {
    emit(const MeetingLoading());
    try {
      final response = await _repository.joinAsClientWithFullResponse(fullApiResponse);
      emit(MeetingJoined(response));
    } catch (e) {
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
