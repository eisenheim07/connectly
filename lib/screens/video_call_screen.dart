import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/video_call_cubit.dart';
import '../models/meeting_response.dart';
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
                onTap: () => context.read<VideoCallCubit>().toggleControls(),
                child: Stack(
                  children: [
                    // Video View Container
                    _buildVideoView(context, state),

                    // Reconnection Banner (at top)
                    Positioned(top: 0, left: 0, right: 0, child: ReconnectionBanner(connectionState: state.connectionState)),

                    // Top Bar
                    if (state.showControls) _buildTopBar(context),

                    // Bottom Controls
                    if (state.showControls) _buildBottomControls(context, state),
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

  Widget _buildVideoView(BuildContext context, VideoCallReady state) {
    final cubit = context.read<VideoCallCubit>();
    final isAgent = cubit.meetingResponse.data.attendee.externalUserId == 'agent';
    final remoteUserName = isAgent ? 'Client' : 'Agent';
    final localUserName = isAgent ? 'Agent' : 'Client';

    return Stack(
      children: [
        // Remote video (full screen) or placeholder
        Positioned.fill(child: state.hasRemoteVideo ? const ChimeVideoView(isLocalVideo: false) : _buildWaitingPlaceholder(remoteUserName)),

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
              boxShadow: [BoxShadow(color: AppColors.surface.withOpacity(0.3), blurRadius: 8.0, offset: const Offset(0, 2))],
            ),
            clipBehavior: Clip.antiAlias,
            child: state.isVideoLoading
                ? Container(
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
                          Text('Starting Camera...', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10.0)),
                        ],
                      ),
                    ),
                  )
                : state.isVideoEnabled
                ? const ChimeVideoView(isLocalVideo: true)
                : Container(
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
                                style: AppTypography.titleMedium.copyWith(color: AppColors.secondary, fontSize: 24.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text('Camera Off', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10.0)),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingPlaceholder(String userName) {
    return Container(
      color: AppColors.surfaceContainerHigh,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile avatar
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
                  style: AppTypography.displayLarge.copyWith(color: AppColors.secondary, fontSize: 56.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Text('Waiting for $userName to join...', style: AppTypography.titleMedium.copyWith(color: AppColors.onSurface, fontSize: 18.0)),
            const SizedBox(height: 12.0),
            // Animated loading indicator
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

  Widget _buildTopBar(BuildContext context) {
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
            IconButtonWidget(
              icon: Icons.info_outline,
              onPressed: () {},
              backgroundColor: AppColors.surface.withOpacity(0.6),
              iconColor: AppColors.onSurface,
            ),
          ],
        ),
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
          style: AppTypography.labelSmall.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w500),
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
              Text('Connection Error', style: AppTypography.titleMedium),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Text(
                  errorMessage,
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
