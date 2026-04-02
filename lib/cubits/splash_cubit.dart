import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashInitial());

  Future<void> startTimer() async {
    emit(const SplashLoading());
    await Future.delayed(const Duration(seconds: 2));
    await _checkPermissionsAndNavigate();
  }

  Future<void> _checkPermissionsAndNavigate() async {
    try {
      final cameraStatus = await Permission.camera.status;
      final microphoneStatus = await Permission.microphone.status;

      if (cameraStatus.isGranted && microphoneStatus.isGranted) {
        emit(const NavigateToMeeting());
      } else {
        emit(const NavigateToPermission());
      }
    } catch (e) {
      emit(const NavigateToPermission());
    }
  }
}
