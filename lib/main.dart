import 'package:connectly/utils/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'cubits/splash_cubit.dart';
import 'cubits/meeting_cubit.dart';
import 'cubits/permission_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SplashCubit()),
        BlocProvider(create: (context) => MeetingCubit()),
        BlocProvider(create: (context) => PermissionCubit()),
      ],
      child: MaterialApp(
        title: 'Connectly',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        builder: (context, child) {
          SizeUtils.init(context);
          // Limit text scale to prevent text from being too large on different devices
          final mediaQuery = MediaQuery.of(context);
          final constrainedTextScale = mediaQuery.textScaler.clamp(
            minScaleFactor: 0.8,
            maxScaleFactor: 1.2,
          );
          
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: constrainedTextScale),
            child: child!,
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}
