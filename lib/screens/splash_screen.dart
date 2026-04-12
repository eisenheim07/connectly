import 'package:connectly/screens/permission_screen.dart';
import 'package:connectly/screens/meeting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/splash_cubit.dart';
import '../cubits/splash_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    context.read<SplashCubit>().startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is NavigateToPermission) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PermissionScreen()),
          );
        } else if (state is NavigateToMeeting) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MeetingScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Text(
            'Connectly',
            style: AppTypography.displayLarge(),
          ),
        ),
      ),
    );
  }
}
