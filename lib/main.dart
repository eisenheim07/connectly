import 'package:connectly/utils/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'cubits/splash_cubit.dart';
import 'cubits/meeting_cubit.dart';
import 'cubits/permission_cubit.dart';
import 'cubits/connectivity_cubit.dart';
import 'widgets/connectivity_wrapper.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
        BlocProvider(create: (context) => ConnectivityCubit()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Connectly',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            builder: (builderContext, child) {
              SizeUtils.init(builderContext);
              final mediaQuery = MediaQuery.of(builderContext);
              final constrainedTextScale = mediaQuery.textScaler.clamp(
                minScaleFactor: 0.8,
                maxScaleFactor: 1.2,
              );
              
              return MediaQuery(
                data: mediaQuery.copyWith(textScaler: constrainedTextScale),
                child: ConnectivityWrapper(child: child!),
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
