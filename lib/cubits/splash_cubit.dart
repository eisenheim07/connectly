import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/connectivity_service.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final ConnectivityService _connectivityService = ConnectivityService.instance;

  SplashCubit() : super(const SplashInitial());

  Future<void> startTimer() async {
    emit(const SplashLoading());
    await Future.delayed(const Duration(seconds: 2));
    await _checkConnectivityAndNavigate();
  }

  Future<void> _checkConnectivityAndNavigate() async {
    try {
      final hasInternet = await _connectivityService.hasInternetConnection();
      
      if (!hasInternet) {
        emit(const SplashWaitingForInternet());
        return;
      }

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

  Future<void> retryNavigation() async {
    emit(const SplashLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    await _checkConnectivityAndNavigate();
  }
}
