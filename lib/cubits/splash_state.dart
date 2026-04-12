import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashWaitingForInternet extends SplashState {
  const SplashWaitingForInternet();
}

class NavigateToPermission extends SplashState {
  const NavigateToPermission();
}

class NavigateToMeeting extends SplashState {
  const NavigateToMeeting();
}
