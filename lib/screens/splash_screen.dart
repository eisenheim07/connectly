import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/splash_cubit.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'home_screen.dart';

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
    return BlocListener<SplashCubit, bool>(
      listener: (context, shouldNavigate) {
        if (shouldNavigate) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Text(
            'Connectly',
            style: AppTypography.displayLarge,
          ),
        ),
      ),
    );
  }
}
