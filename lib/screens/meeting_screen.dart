import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/meeting_cubit.dart';
import '../cubits/meeting_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/custom_app_bar.dart';

class MeetingScreen extends StatelessWidget {
  const MeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const CustomAppBar(title: 'Connectly', showBackButton: false),
      body: BlocConsumer<MeetingCubit, MeetingState>(
        listener: (context, state) {
          if (state is MeetingError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
          }
        },
        builder: (context, state) {
          if (state is MeetingLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
          }

          if (state is MeetingCreated) {
            return _buildMeetingCreatedView(context, state);
          }

          if (state is MeetingJoined) {
            return _buildMeetingJoinedView(context, state);
          }

          return _buildMainContent(context);
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildHeroSection(context), const SizedBox(height: 40.0), _buildRecentMeetingsSection()],
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
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<MeetingCubit>().createMeeting();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.onSurface,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.videocam, size: 24.0),
                  label: Text(
                    'Start New Meeting',
                    style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinMeetingCard(BuildContext context) {
    final TextEditingController meetingIdController = TextEditingController();

    return Container(
      constraints: const BoxConstraints(minHeight: 320.0),
      padding: const EdgeInsets.all(40.0),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Join a Meeting', style: AppTypography.titleMedium.copyWith(fontSize: 20.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8.0),
          Text('Enter a code or link provided by the organizer.', style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 24.0),
          TextField(
            controller: meetingIdController,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Enter code (e.g. abc-def-ghi)',
              hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant.withOpacity(0.5)),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final meetingId = meetingIdController.text.trim();
                if (meetingId.isNotEmpty) {
                  context.read<MeetingCubit>().joinAsClient(meetingId);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.onSurface,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0),
                  side: BorderSide(color: AppColors.outlineVariant.withOpacity(0.2), width: 1.0),
                ),
                elevation: 0,
              ),
              child: Text('Join Meeting', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
            ),
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
            TextButton(
              onPressed: () {},
              child: Text(
                'View History',
                style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
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

  Widget _buildMeetingCreatedView(BuildContext context, MeetingCreated state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: AppColors.secondary, size: 80.0),
            const SizedBox(height: 24.0),
            Text('Meeting Created', style: AppTypography.headlineSmall),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12.0)),
              child: Column(
                children: [
                  Text('Meeting ID', style: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8.0),
                  SelectableText(state.meetingResponse.data.meeting.meetingId, style: AppTypography.titleMedium),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            Text('Share this ID with others to join', style: AppTypography.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to video call screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.onSecondary,
                minimumSize: const Size(200.0, 56.0),
              ),
              child: Text('Start Call', style: AppTypography.labelMedium.copyWith(color: AppColors.onSecondary)),
            ),
          ],
        ),
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
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to video call screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.onSecondary,
                minimumSize: const Size(200.0, 56.0),
              ),
              child: Text('Join Call', style: AppTypography.labelMedium.copyWith(color: AppColors.onSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
