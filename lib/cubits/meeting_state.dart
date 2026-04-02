import 'package:equatable/equatable.dart';
import '../models/meeting_response.dart';

abstract class MeetingState extends Equatable {
  const MeetingState();

  @override
  List<Object?> get props => [];
}

class MeetingInitial extends MeetingState {
  const MeetingInitial();
}

class MeetingLoading extends MeetingState {
  const MeetingLoading();
}

class MeetingCreated extends MeetingState {
  final MeetingResponse meetingResponse;

  const MeetingCreated(this.meetingResponse);

  @override
  List<Object?> get props => [meetingResponse];
}

class MeetingJoined extends MeetingState {
  final MeetingResponse meetingResponse;

  const MeetingJoined(this.meetingResponse);

  @override
  List<Object?> get props => [meetingResponse];
}

class MeetingError extends MeetingState {
  final String message;

  const MeetingError(this.message);

  @override
  List<Object?> get props => [message];
}
