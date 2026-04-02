import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/meeting_cubit.dart';
import '../cubits/meeting_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/button_widget.dart';
import '../widgets/shimmer_loading.dart';
import 'video_call_screen.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final TextEditingController _meetingIdController = TextEditingController();
  final TextEditingController _mediaPlacementController = TextEditingController();

  @override
  void dispose() {
    _meetingIdController.dispose();
    _mediaPlacementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Allow back to close app from home screen
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: AppColors.surface,
          appBar: const CustomAppBar(title: 'Connectly', showBackButton: false),
          body: BlocConsumer<MeetingCubit, MeetingState>(
            listener: (context, state) {
              if (state is MeetingError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
              }

              if (state is MeetingCreated) {
                _showMeetingCreatedBottomSheet(context, state);
              }
            },
            builder: (context, state) {
              if (state is MeetingLoading) {
                return const ShimmerLoading();
              }

              if (state is MeetingJoined) {
                return _buildMeetingJoinedView(context, state);
              }

              return _buildMainContent(context);
            },
          ),
        ),
      ),
    );
  }

  void _showMeetingCreatedBottomSheet(BuildContext context, MeetingCreated state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
          ),
          padding: EdgeInsets.only(left: 32.0, right: 32.0, top: 32.0, bottom: 32.0 + MediaQuery.of(bottomSheetContext).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(color: AppColors.onSurfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(2.0)),
              ),
              const SizedBox(height: 32.0),
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: AppColors.secondary, size: 48.0),
              ),
              const SizedBox(height: 24.0),
              Text('Meeting Created Successfully', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              Text(
                'Share this meeting ID with others to join',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.0),
                ),
                child: Column(
                  children: [
                    Text(
                      'Meeting ID',
                      style: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12.0, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8.0),
                    SelectableText(
                      state.meetingResponse.data.meeting.meetingId,
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 14.0),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    Divider(color: AppColors.onSurfaceVariant.withOpacity(0.2)),
                    const SizedBox(height: 16.0),
                    Text(
                      'Audio Host ID',
                      style: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12.0, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8.0),
                    SelectableText(
                      state.meetingResponse.data.meeting.mediaPlacement?.audioHostUrl.split('.').first ?? 'N/A',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 14.0),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButtonWidget(
                      text: 'Copy Details',
                      onPressed: () {
                        final meetingId = state.meetingResponse.data.meeting.meetingId;
                        final audioHostId = state.meetingResponse.data.meeting.mediaPlacement?.audioHostUrl.split('.').first ?? '';
                        final copyText = '{"meetingId":"$meetingId","audioHostId":"$audioHostId"}';
                        
                        Clipboard.setData(ClipboardData(text: copyText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Meeting details copied to clipboard'),
                            backgroundColor: AppColors.secondary,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: Icons.copy,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: 'Start Call',
                      onPressed: () {
                        // Close bottom sheet
                        Navigator.pop(bottomSheetContext);
                        
                        // Trigger loading state
                        context.read<MeetingCubit>().setLoading();
                        
                        // Navigate after delay
                        Future.delayed(const Duration(milliseconds: 1500), () {
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VideoCallScreen(meetingResponse: state.meetingResponse),
                              ),
                            ).then((_) {
                              // Reset to initial state when returning from video call
                              context.read<MeetingCubit>().reset();
                            });
                          }
                        });
                      },
                      icon: Icons.videocam,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 24.0 + MediaQuery.of(context).padding.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildHeroSection(context), const SizedBox(height: 40.0), _buildRecentMeetingsSection()],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _buildStartMeetingCard(context)),
              const SizedBox(width: 24.0),
              Expanded(flex: 5, child: _buildJoinMeetingCard(context)),
            ],
          );
        }

        return Column(children: [_buildStartMeetingCard(context), const SizedBox(height: 24.0), _buildJoinMeetingCard(context)]);
      },
    );
  }

  Widget _buildStartMeetingCard(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 320.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.onSurface.withOpacity(0.1), AppColors.surface]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Focus on the\nconversation.',
                      style: AppTypography.displayMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w900, height: 1.1),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Reliable, high-fidelity video conferencing designed for professional clarity.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurface.withOpacity(0.8), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),
                PrimaryButton(
                  text: 'Start New Meeting',
                  onPressed: () {
                    context.read<MeetingCubit>().createMeeting();
                  },
                  icon: Icons.videocam,
                  backgroundColor: AppColors.onSurface,
                  textColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinMeetingCard(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 380.0),
      padding: const EdgeInsets.all(40.0),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Join a Meeting', style: AppTypography.titleMedium.copyWith(fontSize: 20.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8.0),
          Text('Paste meeting details below', style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 24.0),
          TextField(
            controller: _mediaPlacementController,
            style: AppTypography.bodyMedium.copyWith(fontSize: 12.0),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '{"meetingId":"...","audioHostId":"..."}',
              hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant.withOpacity(0.5), fontSize: 11.0),
              filled: true,
              fillColor: AppColors.surfaceContainerHighest,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: AppColors.primary.withOpacity(0.4), width: 1.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            ),
          ),
          const SizedBox(height: 16.0),
          OutlinedButtonWidget(
            text: 'Join Meeting',
            onPressed: () {
              final meetingDetails = _mediaPlacementController.text.trim();
              
              if (meetingDetails.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please paste meeting details'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              
              // Join with meeting details
              context.read<MeetingCubit>().joinWithMeetingDetails(meetingDetails);
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMeetingsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Meetings', style: AppTypography.titleMedium.copyWith(fontSize: 20.0, fontWeight: FontWeight.bold)),
            TextButtonWidget(text: 'View History', onPressed: () {}),
          ],
        ),
        const SizedBox(height: 24.0),
        Column(
          children: [
            _buildMeetingCard(
              icon: Icons.groups,
              iconColor: AppColors.secondary,
              title: 'Product Sync: Q4 Roadmap',
              participants: 4,
              duration: '45m',
              time: '2 HOURS AGO',
              avatarCount: 2,
            ),
            const SizedBox(height: 24.0),
            _buildMeetingCard(
              icon: Icons.person,
              iconColor: AppColors.tertiary,
              title: '1:1 with Sarah J.',
              participants: 2,
              duration: '20m',
              time: 'YESTERDAY',
              avatarCount: 1,
            ),
            const SizedBox(height: 24.0),
            _buildMeetingCard(
              icon: Icons.campaign,
              iconColor: AppColors.primary,
              title: 'All-Hands Monthly',
              participants: 18,
              duration: '1h 12m',
              time: 'SEP 24',
              avatarCount: 16,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeetingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int participants,
    required String duration,
    required String time,
    required int avatarCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12.0)),
                child: Icon(icon, color: iconColor, size: 24.0),
              ),
              Text(
                time,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(fontSize: 18.0, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8.0),
          Text('$participants Participants • $duration duration', style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildAvatar(1),
                  if (avatarCount > 1) ...[Transform.translate(offset: const Offset(-12, 0), child: _buildAvatar(2))],
                  if (avatarCount > 2) Transform.translate(offset: const Offset(-24, 0), child: _buildAvatarCount(avatarCount - 2)),
                ],
              ),
              Container(
                width: 32.0,
                height: 32.0,
                decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                child: Icon(Icons.more_horiz, color: AppColors.primary, size: 20.0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(int index) {
    return Container(
      width: 32.0,
      height: 32.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceContainerHigh,
        border: Border.all(color: AppColors.surfaceContainerLow, width: 2.0),
      ),
      child: ClipOval(child: Icon(Icons.person, color: AppColors.onSurfaceVariant, size: 16.0)),
    );
  }

  Widget _buildAvatarCount(int count) {
    return Container(
      width: 32.0,
      height: 32.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceBright,
        border: Border.all(color: AppColors.surfaceContainerLow, width: 2.0),
      ),
      child: Center(
        child: Text('+$count', style: AppTypography.labelSmall.copyWith(fontSize: 10.0, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMeetingJoinedView(BuildContext context, MeetingJoined state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam, color: AppColors.secondary, size: 80.0),
            const SizedBox(height: 24.0),
            Text('Ready to Join', style: AppTypography.headlineSmall),
            const SizedBox(height: 40.0),
            PrimaryButton(
              text: 'Join Call',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => VideoCallScreen(meetingResponse: state.meetingResponse)));
              },
              width: 200.0,
              height: 56.0,
            ),
          ],
        ),
      ),
    );
  }
}
