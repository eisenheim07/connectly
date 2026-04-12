import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/meeting_response.dart';
import '../services/chime_service.dart';
import '../services/network_resilience_manager.dart';

abstract class VideoCallState extends Equatable {
  const VideoCallState();

  @override
  List<Object?> get props => [];
}

class VideoCallInitial extends VideoCallState {
  const VideoCallInitial();
}

class VideoCallLoading extends VideoCallState {
  const VideoCallLoading();
}

class VideoCallReady extends VideoCallState {
  final bool isVideoEnabled;
  final bool isAudioMuted;
  final bool showControls;
  final bool hasRemoteVideo;
  final bool isVideoLoading;
  final NetworkConnectionState connectionState;
  final bool remoteVideoEnabled;
  final bool remoteParticipantLeft;

  const VideoCallReady({
    required this.isVideoEnabled,
    required this.isAudioMuted,
    required this.showControls,
    required this.hasRemoteVideo,
    this.isVideoLoading = false,
    required this.connectionState,
    this.remoteVideoEnabled = false,
    this.remoteParticipantLeft = false,
  });

  VideoCallReady copyWith({
    bool? isVideoEnabled,
    bool? isAudioMuted,
    bool? showControls,
    bool? hasRemoteVideo,
    bool? isVideoLoading,
    NetworkConnectionState? connectionState,
    bool? remoteVideoEnabled,
    bool? remoteParticipantLeft,
  }) {
    return VideoCallReady(
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      showControls: showControls ?? this.showControls,
      hasRemoteVideo: hasRemoteVideo ?? this.hasRemoteVideo,
      isVideoLoading: isVideoLoading ?? this.isVideoLoading,
      connectionState: connectionState ?? this.connectionState,
      remoteVideoEnabled: remoteVideoEnabled ?? this.remoteVideoEnabled,
      remoteParticipantLeft: remoteParticipantLeft ?? this.remoteParticipantLeft,
    );
  }

  @override
  List<Object?> get props => [isVideoEnabled, isAudioMuted, showControls, hasRemoteVideo, isVideoLoading, connectionState, remoteVideoEnabled, remoteParticipantLeft];
}

class VideoCallError extends VideoCallState {
  final String message;

  const VideoCallError(this.message);

  @override
  List<Object?> get props => [message];
}

class VideoCallCubit extends Cubit<VideoCallState> {
  final ChimeService _chimeService;
  final NetworkResilienceManager _networkManager;
  final MeetingResponse meetingResponse;
  StreamSubscription<NetworkConnectionState>? _networkSubscription;
  
  int? _localTileId;
  int? _remoteTileId;
  
  bool _remoteParticipantJoined = false;

  VideoCallCubit({required this.meetingResponse, ChimeService? chimeService, NetworkResilienceManager? networkManager})
    : _chimeService = chimeService ?? ChimeService(),
      _networkManager = networkManager ?? NetworkResilienceManager(),
      super(const VideoCallInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    emit(const VideoCallLoading());

    try {
      _chimeService.onVideoTileAdded = (tileId, attendeeId, isLocal) async {
        if (state is VideoCallReady && !isClosed) {
          final currentState = state as VideoCallReady;
          if (isLocal) {
            _localTileId = tileId;
            
            if (currentState.isVideoLoading || !currentState.isVideoEnabled) {
              emit(currentState.copyWith(isVideoEnabled: true, isVideoLoading: false));
            }
          } else {
            _remoteTileId = tileId;
            _remoteParticipantJoined = true;
            
            emit(currentState.copyWith(
              hasRemoteVideo: true, 
              remoteVideoEnabled: true,
              remoteParticipantLeft: false,
            ));
          }
        }
      };

      _chimeService.onVideoTileRemoved = (tileId) {
        if (state is VideoCallReady && !isClosed) {
          final currentState = state as VideoCallReady;
          
          if (tileId == _remoteTileId) {
            _remoteTileId = null;
            
            if (_remoteParticipantJoined) {
              emit(currentState.copyWith(remoteVideoEnabled: false));
            } else {
              emit(currentState.copyWith(hasRemoteVideo: false, remoteVideoEnabled: false));
            }
          } else if (tileId == _localTileId) {
            _localTileId = null;
          }
        }
      };

      _chimeService.onAttendeeLeft = (attendeeId) {
        if (state is VideoCallReady && !isClosed) {
          final currentState = state as VideoCallReady;
          if (attendeeId != meetingResponse.data.attendee.attendeeId) {
            emit(currentState.copyWith(
              hasRemoteVideo: false,
              remoteVideoEnabled: false,
              remoteParticipantLeft: true,
            ));
            _remoteParticipantJoined = false;
            _remoteTileId = null;
          }
        }
      };

      _networkSubscription = _networkManager.stateStream.listen((connectionState) {
        if (state is VideoCallReady && !isClosed) {
          final currentState = state as VideoCallReady;
          emit(currentState.copyWith(connectionState: connectionState));
        }
      });

      if (meetingResponse.data.meeting.mediaPlacement == null) {
        throw Exception(
          'Meeting configuration incomplete. The backend API must return full meeting details including MediaPlacement when joining a meeting.',
        );
      }

      final success = await _chimeService.initializeMeeting(meetingResponse);

      if (success) {
        emit(
          const VideoCallReady(
            isVideoEnabled: false,
            isAudioMuted: false,
            showControls: true,
            hasRemoteVideo: false,
            isVideoLoading: true,
            connectionState: NetworkConnectionState.connected,
            remoteVideoEnabled: false,
            remoteParticipantLeft: false,
          ),
        );

        await _chimeService.startLocalVideo();

        await Future.delayed(const Duration(milliseconds: 800));
        await _chimeService.rebindVideoTiles();
        
        await Future.delayed(const Duration(milliseconds: 500));
        await _chimeService.rebindVideoTiles();
      } else {
        emit(const VideoCallError('Failed to initialize meeting'));
      }
    } catch (e) {
      emit(
        VideoCallError(
          'Cannot join meeting: Backend API is not returning complete meeting configuration. Please contact support or try creating a new meeting instead.',
        ),
      );
    }
  }

  Future<void> toggleVideo() async {
    if (state is! VideoCallReady) return;

    final currentState = state as VideoCallReady;
    try {
      if (currentState.isVideoEnabled) {
        await _chimeService.stopLocalVideo();
        emit(currentState.copyWith(isVideoEnabled: false, isVideoLoading: false));
      } else {
        emit(currentState.copyWith(isVideoLoading: true, isVideoEnabled: false));
        await _chimeService.startLocalVideo();
      }
    } catch (e) {
      if (state is VideoCallReady) {
        final errorState = state as VideoCallReady;
        emit(errorState.copyWith(isVideoLoading: false));
      }
    }
  }

  Future<void> toggleAudio() async {
    if (state is! VideoCallReady) return;

    final currentState = state as VideoCallReady;
    try {
      if (currentState.isAudioMuted) {
        await _chimeService.unmuteLocalAudio();
      } else {
        await _chimeService.muteLocalAudio();
      }
      emit(currentState.copyWith(isAudioMuted: !currentState.isAudioMuted));
    } catch (e) {}
  }

  Future<void> switchCamera() async {
    try {
      await _chimeService.switchCamera();
    } catch (e) {}
  }

  void toggleControls() {
    if (state is! VideoCallReady) return;

    final currentState = state as VideoCallReady;
    emit(currentState.copyWith(showControls: !currentState.showControls));
  }

  Future<void> leaveMeeting() async {
    try {
      await _chimeService.leaveMeeting();
    } catch (e) {}
  }

  @override
  Future<void> close() {
    _networkSubscription?.cancel();
    _chimeService.dispose();
    return super.close();
  }
}
