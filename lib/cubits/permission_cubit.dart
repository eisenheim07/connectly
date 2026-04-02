import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_state.dart';

class PermissionCubit extends Cubit<PermissionState> {
  PermissionCubit() : super(const PermissionsGrantedState(cameraGranted: false, microphoneGranted: false));

  Future<void> checkPermissions() async {
    try {
      final cameraStatus = await Permission.camera.status;
      final microphoneStatus = await Permission.microphone.status;

      emit(PermissionsGrantedState(
        cameraGranted: cameraStatus.isGranted,
        microphoneGranted: microphoneStatus.isGranted,
      ));
    } catch (e) {
      emit(PermissionError('Failed to check permissions: $e'));
    }
  }

  Future<void> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      final microphoneStatus = await Permission.microphone.status;
      
      emit(PermissionsGrantedState(
        cameraGranted: status.isGranted,
        microphoneGranted: microphoneStatus.isGranted,
      ));
    } catch (e) {
      emit(PermissionError('Failed to request camera permission: $e'));
    }
  }

  Future<void> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      final cameraStatus = await Permission.camera.status;
      
      emit(PermissionsGrantedState(
        cameraGranted: cameraStatus.isGranted,
        microphoneGranted: status.isGranted,
      ));
    } catch (e) {
      emit(PermissionError('Failed to request microphone permission: $e'));
    }
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
