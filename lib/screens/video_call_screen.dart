import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/video_call_cubit.dart';
import '../models/meeting_response.dart';
import '../services/network_resilience_manager.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/button_widget.dart';
import '../widgets/chime_video_view.dart';
import '../widgets/reconnection_banner.dart';
import '../widgets/confirmation_bottom_sheet.dart';

class VideoCallScreen extends StatelessWidget {
  final MeetingResponse meetingResponse;

  const VideoCallScreen({super.key, required this.meetingResponse});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoCallCubit(meetingResponse: meetingResponse),
      child: const _VideoCallView(),
    );
  }
}

class _VideoCallView extends StatefulWidget {
  const _VideoCallView();

  @override
  State<_VideoCallView> createState() => _VideoCallViewState();
}

class _VideoCallViewState extends State<_VideoCallView> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final confirmed = await _showEndCallConfirmation(context);
    if (confirmed == true) {
      await context.read<VideoCallCubit>().leaveMeeting();
      return true;
    }
    return false;
  }

  Future<bool?> _showEndCallConfirmation(BuildContext context) {
    return ConfirmationBottomSheet.show(
      context: context,
      title: 'End Call?',
      message: 'Are you sure you want to end this call? This action cannot be undone.',
      confirmText: 'End Call',
      cancelText: 'Cancel',
      icon: Icons.call_end,
      iconColor: AppColors.onError,
      isDangerous: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: BlocBuilder<VideoCallCubit, VideoCallState>(
          builder: (context, state) {
            if (state is VideoCallLoading) {
              return _buildLoadingOverlay(null);
            }

            if (state is VideoCallError) {
              return _buildLoadingOverlay(state.message);
            }

            if (state is VideoCallReady) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.read<VideoCallCubit>().toggleControls(),
                child: Stack(
                  children: [
                    _buildRemoteVideoView(context, state),

                    _buildLocalVideoView(context, state),

                    Positioned(top: 0, left: 0, right: 0, child: ReconnectionBanner(connectionState: state.connectionState)),

                    if (state.showControls) _buildTopBar(context, state),

                    if (state.showControls) _buildBottomControls(context, state),

                    if (!state.showControls)
                      Positioned(
                        bottom: 20.0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            decoration: BoxDecoration(color: AppColors.surface.withOpacity(0.8), borderRadius: BorderRadius.circular(20.0)),
                            child: Text('Tap to show controls', style: AppTypography.labelSmallPrimary()),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildRemoteVideoView(BuildContext context, VideoCallReady state) {
    final cubit = context.read<VideoCallCubit>();
    final isAgent = cubit.meetingResponse.data.attendee.externalUserId == 'agent';
    final remoteUserName = isAgent ? 'Client' : 'Agent';

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(child: const ChimeVideoView(key: ValueKey('remote_video'), isLocalVideo: false)),
        ),

        if (!state.hasRemoteVideo)
          Positioned.fill(
            child: state.remoteParticipantLeft ? _buildParticipantLeftPlaceholder(remoteUserName) : _buildWaitingPlaceholder(remoteUserName),
          )
        else if (!state.remoteVideoEnabled)
          Positioned.fill(child: _buildCameraOffPlaceholder(remoteUserName)),
      ],
    );
  }

  Widget _buildLocalVideoView(BuildContext context, VideoCallReady state) {
    final cubit = context.read<VideoCallCubit>();
    final isAgent = cubit.meetingResponse.data.attendee.externalUserId == 'agent';
    final localUserName = isAgent ? 'Agent' : 'Client';

    return Positioned(
      top: 40.0,
      right: 16.0,
      child: Container(
        width: 120.0,
        height: 160.0,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 2.0),
          boxShadow: [BoxShadow(color: AppColors.surface.withOpacity(0.3), blurRadius: 8.0, offset: const Offset(0, 2))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(child: const ChimeVideoView(key: ValueKey('local_video'), isLocalVideo: true)),
            ),

            if (state.isVideoLoading)
              Positioned.fill(
                child: Container(
                  color: AppColors.surfaceContainerHigh,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40.0,
                          height: 40.0,
                          child: CircularProgressIndicator(strokeWidth: 3.0, valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary)),
                        ),
                        const SizedBox(height: 12.0),
                        Text('Starting Camera...', style: AppTypography.labelSmallSecondary()),
                      ],
                    ),
                  ),
                ),
              ),
            
            if (!state.isVideoEnabled && !state.isVideoLoading)
              Positioned.fill(
                child: Container(
                  color: AppColors.surfaceContainerHigh,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56.0,
                          height: 56.0,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.secondary, width: 2.0),
                          ),
                          child: Center(
                            child: Text(
                              localUserName[0].toUpperCase(),
                              style: AppTypography.headlineSmallSecondary(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text('Camera Off', style: AppTypography.labelSmallSecondary()),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingPlaceholder(String userName) {
    return Container(
      color: AppColors.surfaceContainerHigh,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.0,
              height: 120.0,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary, width: 3.0),
              ),
              child: Center(
                child: Text(
                  userName[0].toUpperCase(),
                  style: AppTypography.displayMediumSecondary(),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Text('Waiting for $userName to join...', style: AppTypography.titleLarge()),
            const SizedBox(height: 12.0),
            SizedBox(
              width: 24.0,
              height: 24.0,
              child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary.withOpacity(0.6))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraOffPlaceholder(String userName) {
    return Container(
      color: AppColors.surfaceContainerHigh,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.0,
              height: 120.0,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary, width: 3.0),
              ),
              child: Center(
                child: Text(
                  userName[0].toUpperCase(),
                  style: AppTypography.displayMediumSecondary(),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Text('$userName\'s Camera is Off', style: AppTypography.titleLarge()),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantLeftPlaceholder(String userName) {
    return Container(
      color: AppColors.surfaceContainerHigh,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.0,
              height: 120.0,
              decoration: BoxDecoration(
                color: AppColors.onSurfaceVariant.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.onSurfaceVariant, width: 3.0),
              ),
              child: Center(child: Icon(Icons.person_off_outlined, size: 56.0, color: AppColors.onSurfaceVariant)),
            ),
            const SizedBox(height: 24.0),
            Text('$userName has left the meeting', style: AppTypography.titleLarge()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, VideoCallReady state) {
    final connectionState = state.connectionState;
    
    String statusText;
    Color statusColor;
    Color backgroundColor;
    Color borderColor;
    
    switch (connectionState) {
      case NetworkConnectionState.connected:
        statusText = 'CONNECTED';
        statusColor = AppColors.secondary;
        backgroundColor = AppColors.secondary.withOpacity(0.2);
        borderColor = AppColors.secondary.withOpacity(0.4);
        break;
      case NetworkConnectionState.poor:
        statusText = 'POOR CONNECTION';
        statusColor = AppColors.statusWarning;
        backgroundColor = AppColors.statusWarning.withOpacity(0.2);
        borderColor = AppColors.statusWarning.withOpacity(0.4);
        break;
      case NetworkConnectionState.reconnecting:
        statusText = 'RECONNECTING';
        statusColor = AppColors.statusWarning;
        backgroundColor = AppColors.statusWarning.withOpacity(0.2);
        borderColor = AppColors.statusWarning.withOpacity(0.4);
        break;
      case NetworkConnectionState.disconnected:
        statusText = 'DISCONNECTED';
        statusColor = AppColors.statusError;
        backgroundColor = AppColors.statusError.withOpacity(0.2);
        borderColor = AppColors.statusError.withOpacity(0.4);
        break;
    }
    
    return Container(
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
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: Row(
              children: [
                Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8.0),
                Text(
                  statusText,
                  style: AppTypography.labelLarge(color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, VideoCallReady state) {
    final cubit = context.read<VideoCallCubit>();

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
              icon: state.isAudioMuted ? Icons.mic_off : Icons.mic,
              label: state.isAudioMuted ? 'Unmute' : 'Mute',
              onPressed: () => cubit.toggleAudio(),
              isActive: !state.isAudioMuted,
            ),
            _buildControlButton(
              icon: state.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              label: state.isVideoEnabled ? 'Stop Video' : 'Start Video',
              onPressed: () => cubit.toggleVideo(),
              isActive: state.isVideoEnabled,
            ),
            _buildControlButton(icon: Icons.flip_camera_ios, label: 'Flip', onPressed: () => cubit.switchCamera(), isActive: true),
            _buildControlButton(
              icon: Icons.call_end,
              label: 'End',
              onPressed: () async {
                final confirmed = await _showEndCallConfirmation(context);
                if (confirmed == true) {
                  await context.read<VideoCallCubit>().leaveMeeting();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              isActive: false,
              isEndCall: true,
            ),
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
                ? AppColors.onError
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
          style: AppTypography.labelMedium(),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay(String? errorMessage) {
    return Container(
      color: AppColors.surface.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (errorMessage != null) ...[
              Icon(Icons.error_outline, size: 64.0, color: AppColors.error),
              const SizedBox(height: 24.0),
              Text('Connection Error', style: AppTypography.titleMedium()),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Text(
                  errorMessage,
                  style: AppTypography.bodySmallSecondary(),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24.0),
              PrimaryButton(text: 'Go Back', onPressed: () => Navigator.of(context).pop()),
            ] else ...[
              const CircularProgressIndicator(color: AppColors.secondary),
              const SizedBox(height: 24.0),
              Text('Connecting to meeting...', style: AppTypography.titleMedium()),
            ],
          ],
        ),
      ),
    );
  }
}
