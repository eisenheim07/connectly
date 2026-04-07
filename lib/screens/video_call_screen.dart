import 'package:connectly/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/meeting_response.dart';
import '../services/chime_service.dart';
import '../services/network_resilience_manager.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/button_widget.dart';
import '../widgets/chime_video_view.dart';
import '../widgets/reconnection_banner.dart';
import 'event_log_screen.dart';

class VideoCallScreen extends StatefulWidget {
  final MeetingResponse meetingResponse;

  const VideoCallScreen({super.key, required this.meetingResponse});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final ChimeService _chimeService = ChimeService();
  final NetworkResilienceManager _networkManager = NetworkResilienceManager();

  bool _isVideoEnabled = true;
  bool _isAudioMuted = false;
  bool _isInitialized = false;
  bool _showControls = true;
  String? _errorMessage;
  NetworkConnectionState _connectionState = NetworkConnectionState.connected;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initializeMeeting();
    
    // Listen to network state changes
    _networkManager.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _connectionState = state;
        });
      }
    });
  }

  @override
  void dispose() {
    _chimeService.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    await _leaveMeeting();
    return true;
  }

  Future<void> _initializeMeeting() async {
    try {
      print('🎥 Initializing Chime meeting...');
      print('Meeting ID: ${widget.meetingResponse.data.meeting.meetingId}');
      print('Attendee ID: ${widget.meetingResponse.data.attendee.attendeeId}');
      print('Media Region: ${widget.meetingResponse.data.meeting.mediaRegion}');
      print('Media Placement: ${widget.meetingResponse.data.meeting.mediaPlacement}');

      // Check if we have all required data
      if (widget.meetingResponse.data.meeting.mediaPlacement == null) {
        throw Exception(
          'Meeting configuration incomplete. The backend API must return full meeting details including MediaPlacement when joining a meeting.',
        );
      }

      final success = await _chimeService.initializeMeeting(widget.meetingResponse);
      print('🎥 Initialize result: $success');

      if (success && mounted) {
        setState(() {
          _isInitialized = true;
          _showControls = true; // Ensure controls are visible
        });
        print('🎥 Meeting initialized, starting local video...');
        await _chimeService.startLocalVideo();
        print('🎥 Local video started');

        // Wait a bit for views to be created, then rebind tiles
        await Future.delayed(const Duration(milliseconds: 500));
        await _chimeService.rebindVideoTiles();
        print('🎥 Video tiles rebound');
      } else {
        print('❌ Failed to initialize meeting');
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to initialize meeting. Please try again.';
          });
        }
      }
    } catch (e) {
      print('❌ Error initializing meeting: $e');
      if (mounted) {
        setState(() {
          _errorMessage =
              'Cannot join meeting: Backend API is not returning complete meeting configuration. Please contact support or try creating a new meeting instead.';
        });
      }
    }
  }

  Future<void> _toggleVideo() async {
    try {
      if (_isVideoEnabled) {
        await _chimeService.stopLocalVideo();
      } else {
        await _chimeService.startLocalVideo();
      }
      setState(() {
        _isVideoEnabled = !_isVideoEnabled;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _toggleAudio() async {
    try {
      if (_isAudioMuted) {
        await _chimeService.unmuteLocalAudio();
      } else {
        await _chimeService.muteLocalAudio();
      }
      setState(() {
        _isAudioMuted = !_isAudioMuted;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _chimeService.switchCamera();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _leaveMeeting() async {
    try {
      await _chimeService.leaveMeeting();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) => context.flushBarErrorMessage(message: message);

  // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.error));

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Stack(
          children: [
            // Video View Container
            GestureDetector(
              onTap: _toggleControls,
              child: _buildVideoView(),
            ),

            // Reconnection Banner (at top)
            if (_isInitialized)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ReconnectionBanner(connectionState: _connectionState),
              ),

            // Top Bar
            if (_isInitialized && _showControls) _buildTopBar(),

            // Bottom Controls
            if (_isInitialized && _showControls) _buildBottomControls(),

            // Loading/Error Overlay
            if (!_isInitialized) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoView() {
    return Stack(
      children: [
        // Remote video (full screen)
        const Positioned.fill(
          child: ChimeVideoView(isLocalVideo: false),
        ),
        
        // Local video (picture-in-picture)
        Positioned(
          top: 80.0,
          right: 16.0,
          child: Container(
            width: 120.0,
            height: 160.0,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.surface.withOpacity(0.3),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: const ChimeVideoView(isLocalVideo: true),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 48.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.surface.withOpacity(0.8), AppColors.surface.withOpacity(0.0)],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: AppColors.secondary.withOpacity(0.4), width: 1.0),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'CONNECTED',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButtonWidget(
                  icon: Icons.event_note,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EventLogScreen()),
                    );
                  },
                  backgroundColor: AppColors.surface.withOpacity(0.6),
                  iconColor: AppColors.onSurface,
                ),
                const SizedBox(width: 8),
                IconButtonWidget(
                  icon: Icons.info_outline,
                  onPressed: () {
                    // Show meeting info
                  },
                  backgroundColor: AppColors.surface.withOpacity(0.6),
                  iconColor: AppColors.onSurface,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 40.0, bottom: 40.0 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [AppColors.surface.withOpacity(0.9), AppColors.surface.withOpacity(0.0)],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: _isAudioMuted ? Icons.mic_off : Icons.mic,
              label: _isAudioMuted ? 'Unmute' : 'Mute',
              onPressed: _toggleAudio,
              isActive: !_isAudioMuted,
            ),
            _buildControlButton(
              icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              label: _isVideoEnabled ? 'Stop Video' : 'Start Video',
              onPressed: _toggleVideo,
              isActive: _isVideoEnabled,
            ),
            _buildControlButton(icon: Icons.flip_camera_ios, label: 'Flip', onPressed: _switchCamera, isActive: true),
            _buildControlButton(icon: Icons.call_end, label: 'End', onPressed: _leaveMeeting, isActive: false, isEndCall: true),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isActive,
    bool isEndCall = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64.0,
          height: 64.0,
          decoration: BoxDecoration(
            color: isEndCall
                ? AppColors.error
                : isActive
                ? AppColors.glassBackground
                : AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: isActive && !isEndCall ? Border.all(color: AppColors.secondary.withOpacity(0.3), width: 2.0) : null,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: isEndCall
                  ? AppColors.onSurface
                  : isActive
                  ? AppColors.secondary
                  : AppColors.onSurfaceVariant,
              size: 28.0,
            ),
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: AppColors.surface.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage != null) ...[
              Icon(Icons.error_outline, size: 64.0, color: AppColors.error),
              const SizedBox(height: 24.0),
              Text('Connection Error', style: AppTypography.titleMedium),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Text(
                  _errorMessage!,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24.0),
              PrimaryButton(text: 'Go Back', onPressed: () => Navigator.of(context).pop()),
            ] else ...[
              const CircularProgressIndicator(color: AppColors.secondary),
              const SizedBox(height: 24.0),
              Text('Connecting to meeting...', style: AppTypography.titleMedium),
            ],
          ],
        ),
      ),
    );
  }
}
