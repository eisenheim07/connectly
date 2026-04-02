import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import '../cubits/permission_cubit.dart';
import '../cubits/permission_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'meeting_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final frontCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);

      _cameraController = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocListener<PermissionCubit, PermissionState>(
        listener: (context, state) {
          if (state is PermissionsGrantedState && state.cameraGranted && !_isCameraInitialized) {
            _initializeCamera();
          }
        },
        child: BlocBuilder<PermissionCubit, PermissionState>(
          builder: (context, state) {
            final permissionStatus = state is PermissionsGrantedState
                ? state
                : const PermissionsGrantedState(cameraGranted: false, microphoneGranted: false);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 48.0),
                    _buildPermissionCard(
                      context: context,
                      icon: Icons.videocam,
                      iconColor: AppColors.secondary,
                      title: 'Camera Access',
                      description: 'Required for high-definition video broadcasting. Your feed is encrypted end-to-end.',
                      isGranted: permissionStatus.cameraGranted,
                      onPressed: () {
                        context.read<PermissionCubit>().requestCameraPermission();
                      },
                    ),
                    const SizedBox(height: 24.0),
                    _buildPermissionCard(
                      context: context,
                      icon: Icons.mic,
                      iconColor: AppColors.secondary,
                      title: 'Microphone Access',
                      description: 'Enables high-fidelity spatial audio and active noise cancellation during your call.',
                      isGranted: permissionStatus.microphoneGranted,
                      onPressed: () {
                        context.read<PermissionCubit>().requestMicrophonePermission();
                      },
                    ),
                    const SizedBox(height: 48.0),
                    _buildPreviewSection(permissionStatus),
                    const SizedBox(height: 48.0),
                    _buildContinueButton(context, permissionStatus),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ready to join?', style: AppTypography.displayMedium),
        const SizedBox(height: 16.0),
        Text(
          'To provide the best editorial quality video and crystalline audio, we need your permission to access local hardware.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildPermissionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onPressed,
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
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12.0)),
                child: Icon(icon, color: iconColor, size: 32.0),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(color: AppColors.tertiaryContainer.withOpacity(0.2), borderRadius: BorderRadius.circular(20.0)),
                child: Text(
                  'REQUIRED',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.tertiary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          Text(title, style: AppTypography.titleMedium),
          const SizedBox(height: 8.0),
          Text(description, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isGranted ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isGranted ? AppColors.surfaceContainerHigh : AppColors.secondary,
                foregroundColor: isGranted ? AppColors.onSurfaceVariant : AppColors.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isGranted) const Icon(Icons.check_circle, size: 20.0) else const Icon(Icons.lock_open, size: 20.0),
                  const SizedBox(width: 8.0),
                  Text(
                    isGranted ? 'Access Granted' : 'Allow $title',
                    style: AppTypography.labelMedium.copyWith(
                      color: isGranted ? AppColors.onSurfaceVariant : AppColors.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(PermissionsGrantedState status) {
    return Container(
      height: 300.0,
      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(16.0)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: [
            if (_isCameraInitialized && _cameraController != null)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _cameraController!.value.previewSize!.height,
                    height: _cameraController!.value.previewSize!.width,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120.0,
                      height: 120.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outlineVariant, width: 2.0, style: BorderStyle.solid),
                      ),
                      child: const Icon(Icons.videocam_off, color: AppColors.onSurfaceVariant, size: 48.0),
                    ),
                    const SizedBox(height: 24.0),
                    Text('Waiting for camera permission...', style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            Positioned(
              top: 16.0,
              left: 16.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(color: AppColors.surface.withOpacity(0.8), borderRadius: BorderRadius.circular(8.0)),
                child: Row(
                  children: [
                    Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(color: _isCameraInitialized ? AppColors.secondary : AppColors.tertiary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      _isCameraInitialized ? 'LIVE PREVIEW' : 'OFFLINE PREVIEW',
                      style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, PermissionsGrantedState status) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: status.allGranted
                ? () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MeetingScreen()));
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: status.allGranted ? AppColors.secondary : AppColors.surfaceContainerHigh,
              foregroundColor: status.allGranted ? AppColors.onSecondary : AppColors.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch, color: status.allGranted ? AppColors.onSecondary : AppColors.onSurfaceVariant.withOpacity(0.4)),
                const SizedBox(width: 12.0),
                Text(
                  'Enter Meeting Space',
                  style: AppTypography.labelMedium.copyWith(
                    color: status.allGranted ? AppColors.onSecondary : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          'By entering, you agree to our Privacy Policy regarding temporary media processing.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant.withOpacity(0.6)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
