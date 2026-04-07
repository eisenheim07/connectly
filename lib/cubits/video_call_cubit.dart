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
  final bool remoteVideoEnabled; // Track if remote participant's video is on
  final bool remoteParticipantLeft; // Track if remote participant left the meeting

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

// Cubit
class VideoCallCubit extends Cubit<VideoCallState> {
  final ChimeService _chimeService;
  final NetworkResilienceManager _networkManager;
  final MeetingResponse meetingResponse;
  StreamSubscription<NetworkConnectionState>? _networkSubscription;
  
  // Track tile IDs to distinguish local from remote
  int? _localTileId;
  int? _remoteTileId;
  
  // Track if remote participant has joined (even if video is off)
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
      // Listen for video tile events
      _chimeService.onVideoTileAdded = (tileId, attendeeId, isLocal) async {
        if (state is VideoCallReady && !isClosed) {
          final currentState = state as VideoCallReady;
          if (isLocal) {
            // Local video tile added - track it and ensure video is shown
            _localTileId = tileId;
            print('🎥 Local video tile added: $tileId');
            
            // Show video whether it's initial load or restarting after stop
            if (currentState.isVideoLoading || !currentState.isVideoEnabled) {
              emit(currentState.copyWith(isVideoEnabled: true, isVideoLoading: false));
            }
          } else {
            // Remote video tile added - track it and mark participant as joined
            _remoteTileId = tileId;
            _remoteParticipantJoined = true;
            
            print('🎥 Remote video tile added: $tileId (participant joined)');
            emit(currentState.copyWith(
              hasRemoteVideo: true, 
              remoteVideoEnabled: true,
              remoteParticipantLeft: false, // Reset left status when they join
            ));
            
            // Don't rebind here - tiles are already bound when added
            print('🎥 Remote participant video is now visible');
          }
        }
      };

      _chimeService.onVideoTileRemoved = (tileId) {
        if (state is VideoCallReady && !isClosed) {
          final currentState = state as VideoCallReady;
          
          // Check if it's the remote tile being removed
          if (tileId == _remoteTileId) {
            _remoteTileId = null;
            print('🎥 Remote video tile removed: $tileId');
            
            if (_remoteParticipantJoined) {
              // Participant is still in call, just stopped video
              emit(currentState.copyWith(remoteVideoEnabled: false));
              print('   -> Remote participant stopped video (still in call)');
            } else {
              // Participant never joined
              emit(currentState.copyWith(hasRemoteVideo: false, remoteVideoEnabled: false));
              print('   -> Remote participant never joined');
            }
          } else if (tileId == _localTileId) {
            _localTileId = null;
            print('🎥 Local video tile removed: $tileId');
            // Don't change hasRemoteVideo for local tile removal
          } else {
            print('🎥 Unknown video tile removed: $tileId');
          }
        }
      };

      // Listen for when remote attendee leaves the meeting
      _chimeService.onAttendeeLeft = (attendeeId) {
        if (state is VideoCallReady && !isClosed) {
          final currentState = state as VideoCallReady;
          // Check if it's not our own attendee ID
          if (attendeeId != meetingResponse.data.attendee.attendeeId) {
            print('👋 Remote attendee left: $attendeeId');
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
            isVideoEnabled: false, // Start with video disabled until tile is added
            isAudioMuted: false,
            showControls: true,
            hasRemoteVideo: false,
            isVideoLoading: true, // Show loading while starting video
            connectionState: NetworkConnectionState.connected,
            remoteVideoEnabled: false,
            remoteParticipantLeft: false,
          ),
        );

        print('🎥 Starting local video...');
        await _chimeService.startLocalVideo();
        print('🎥 Local video started');

        // Wait longer for views to be created, then rebind tiles multiple times
        await Future.delayed(const Duration(milliseconds: 800));
        await _chimeService.rebindVideoTiles();
        print('🎥 Video tiles rebound (attempt 1)');
        
        // Rebind again after another delay to catch any late-created views
        await Future.delayed(const Duration(milliseconds: 500));
        await _chimeService.rebindVideoTiles();
        print('🎥 Video tiles rebound (attempt 2)');
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
        // Stopping video - tile will be removed
        await _chimeService.stopLocalVideo();
        // Don't clear _localTileId here - let onVideoTileRemoved handle it
        emit(currentState.copyWith(isVideoEnabled: false, isVideoLoading: false));
      } else {
        // Starting video - show loader, wait for tile to be added via callback
        emit(currentState.copyWith(isVideoLoading: true, isVideoEnabled: false));
        await _chimeService.startLocalVideo();
        // Don't set isVideoEnabled here - let onVideoTileAdded handle it
        // The callback will set isVideoEnabled: true when the tile is actually added
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
