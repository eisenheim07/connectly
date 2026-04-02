import 'package:equatable/equatable.dart';

abstract class PermissionState extends Equatable {
  const PermissionState();

  @override
  List<Object?> get props => [];
}

class PermissionInitial extends PermissionState {
  const PermissionInitial();
}

class PermissionChecking extends PermissionState {
  const PermissionChecking();
}

class PermissionsGrantedState extends PermissionState {
  final bool cameraGranted;
  final bool microphoneGranted;

  const PermissionsGrantedState({
    required this.cameraGranted,
    required this.microphoneGranted,
  });

  bool get allGranted => cameraGranted && microphoneGranted;

  @override
  List<Object?> get props => [cameraGranted, microphoneGranted];
}

class PermissionError extends PermissionState {
  final String message;

  const PermissionError(this.message);

  @override
  List<Object?> get props => [message];
}
