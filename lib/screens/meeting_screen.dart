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

          return _buildInitialView(context);
        },
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Start or Join a Meeting', style: AppTypography.headlineSmall),
          const SizedBox(height: 40.0),
          ElevatedButton(
            onPressed: () {
              context.read<MeetingCubit>().createMeeting();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.onSecondary,
              minimumSize: const Size(200.0, 56.0),
            ),
            child: Text('Create Meeting', style: AppTypography.labelMedium.copyWith(color: AppColors.onSecondary)),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              _showJoinMeetingDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerHigh,
              foregroundColor: AppColors.onSurface,
              minimumSize: const Size(200.0, 56.0),
            ),
            child: Text('Join Meeting', style: AppTypography.labelMedium),
          ),
        ],
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

  void _showJoinMeetingDialog(BuildContext context) {
    final TextEditingController meetingIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Join Meeting', style: AppTypography.titleMedium),
        content: TextField(
          controller: meetingIdController,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Enter Meeting ID',
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel', style: AppTypography.labelMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final meetingId = meetingIdController.text.trim();
              if (meetingId.isNotEmpty) {
                Navigator.of(dialogContext).pop();
                context.read<MeetingCubit>().joinAsClient(meetingId);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: AppColors.onSecondary),
            child: Text('Join', style: AppTypography.labelMedium.copyWith(color: AppColors.onSecondary)),
          ),
        ],
      ),
    );
  }
}
