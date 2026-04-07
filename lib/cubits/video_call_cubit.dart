import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/meeting_response.dart';
import '../services/chime_service.dart';
import '../services/network_resilience_manager.dart';

// States
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

  const VideoCallReady({
    required this.isVideoEnabled,
    required this.isAudioMuted,
    required this.showControls,
    required this.hasRemoteVideo,
    this.isVideoLoading = false,
    required this.connectionState,
  });

  VideoCallReady copyWith({
    bool? isVideoEnabled,
    bool? isAudioMuted,
    bool? showControls,
    bool? hasRemoteVideo,
    bool? isVideoLoading,
    NetworkConnectionState? connectionState,
  }) {
    return VideoCallReady(
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      showControls: showControls ?? this.showControls,
      hasRemoteVideo: hasRemoteVideo ?? this.hasRemoteVideo,
      isVideoLoading: isVideoLoading ?? this.isVideoLoading,
      connectionState: connectionState ?? this.connectionState,
    );
  }

  @override
  List<Object?> get props => [isVideoEnabled, isAudioMuted, showControls, hasRemoteVideo, isVideoLoading, connectionState];
}

class VideoCallError extends VideoCallState {
  final String message;

  const VideoCallError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class VideoCallCubit extends Cubit<VideoCallState> {
  final ChimeService _chimeService;
  final NetworkResilienceManager _networkManager;
  final MeetingResponse meetingResponse;
  StreamSubscription<NetworkConnectionState>? _networkSubscription;

  VideoCallCubit({required this.meetingResponse, ChimeService? chimeService, NetworkResilienceManager? networkManager})
    : _chimeService = chimeService ?? ChimeService(),
      _networkManager = networkManager ?? NetworkResilienceManager(),
      super(const VideoCallInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    emit(const VideoCallLoading());

    try {
      // Listen for video tile events
      _chimeService.onVideoTileAdded = (tileId, attendeeId, isLocal) {
        if (!isLocal && state is VideoCallReady && !isClosed) {
          final currentState = state as VideoCallReady;
          emit(currentState.copyWith(hasRemoteVideo: true));
          print('🎥 Remote video tile added: $tileId');
        }
      };

      _chimeService.onVideoTileRemoved = (tileId) {
        if (state is VideoCallReady && !isClosed) {
          final currentState = state as VideoCallReady;
          emit(currentState.copyWith(hasRemoteVideo: false));
          print('🎥 Remote video tile removed: $tileId');
        }
      };

      // Listen to network state changes
      _networkSubscription = _networkManager.stateStream.listen((connectionState) {
        if (state is VideoCallReady && !isClosed) {
          final currentState = state as VideoCallReady;
          emit(currentState.copyWith(connectionState: connectionState));
        }
      });

      // Initialize meeting
      print('🎥 Initializing Chime meeting...');
      print('Meeting ID: ${meetingResponse.data.meeting.meetingId}');
      print('Attendee ID: ${meetingResponse.data.attendee.attendeeId}');
      print('Media Region: ${meetingResponse.data.meeting.mediaRegion}');
      print('Media Placement: ${meetingResponse.data.meeting.mediaPlacement}');

      if (meetingResponse.data.meeting.mediaPlacement == null) {
        throw Exception(
          'Meeting configuration incomplete. The backend API must return full meeting details including MediaPlacement when joining a meeting.',
        );
      }

      final success = await _chimeService.initializeMeeting(meetingResponse);
      print('🎥 Initialize result: $success');

      if (success) {
        emit(
          const VideoCallReady(
            isVideoEnabled: true,
            isAudioMuted: false,
            showControls: true,
            hasRemoteVideo: false,
            isVideoLoading: false,
            connectionState: NetworkConnectionState.connected,
          ),
        );

        print('🎥 Starting local video...');
        await _chimeService.startLocalVideo();
        print('🎥 Local video started');

        // Wait for views to be created, then rebind tiles
        await Future.delayed(const Duration(milliseconds: 500));
        await _chimeService.rebindVideoTiles();
        print('🎥 Video tiles rebound');
      } else {
        emit(const VideoCallError('Failed to initialize meeting'));
      }
    } catch (e) {
      print('❌ Error initializing meeting: $e');
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
        // Stopping video - no loader needed
        await _chimeService.stopLocalVideo();
        emit(currentState.copyWith(isVideoEnabled: false, isVideoLoading: false));
      } else {
        // Starting video - show loader
        emit(currentState.copyWith(isVideoLoading: true));
        await _chimeService.startLocalVideo();
        // Small delay to ensure camera is ready
        await Future.delayed(const Duration(milliseconds: 300));
        emit(currentState.copyWith(isVideoEnabled: true, isVideoLoading: false));
      }
    } catch (e) {
      print('❌ Error toggling video: $e');
      // Reset loading state on error
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
    } catch (e) {
      print('❌ Error toggling audio: $e');
    }
  }

  Future<void> switchCamera() async {
    try {
      await _chimeService.switchCamera();
    } catch (e) {
      print('❌ Error switching camera: $e');
    }
  }

  void toggleControls() {
    if (state is! VideoCallReady) return;

    final currentState = state as VideoCallReady;
    emit(currentState.copyWith(showControls: !currentState.showControls));
  }

  Future<void> leaveMeeting() async {
    try {
      await _chimeService.leaveMeeting();
    } catch (e) {
      print('❌ Error leaving meeting: $e');
    }
  }

  @override
  Future<void> close() {
    _networkSubscription?.cancel();
    _chimeService.dispose();
    return super.close();
  }
}
