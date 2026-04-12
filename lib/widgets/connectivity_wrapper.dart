import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/connectivity_cubit.dart';
import '../cubits/connectivity_state.dart';
import '../main.dart';
import 'no_internet_bottom_sheet.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> with WidgetsBindingObserver {
  bool _isBottomSheetShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConnectivityCubit>().startMonitoring();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      context.read<ConnectivityCubit>().resumeMonitoring();
    } else if (state == AppLifecycleState.paused) {
      if (_isBottomSheetShown) {
        _hideNoInternetBottomSheet();
      }
      context.read<ConnectivityCubit>().pauseMonitoring();
    }
  }

  void _showNoInternetBottomSheet() {
    if (!_isBottomSheetShown && mounted) {
      setState(() {
        _isBottomSheetShown = true;
      });
      
      final navigatorContext = navigatorKey.currentContext;
      if (navigatorContext != null) {
        NoInternetBottomSheet.show(navigatorContext);
      }
    }
  }

  void _hideNoInternetBottomSheet() {
    if (_isBottomSheetShown && mounted) {
      setState(() {
        _isBottomSheetShown = false;
      });
      try {
        navigatorKey.currentState?.pop();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      listener: (context, state) {
        if (state is ConnectivityDisconnected) {
          _showNoInternetBottomSheet();
        } else if (state is ConnectivityConnected) {
          _hideNoInternetBottomSheet();
        }
      },
      child: widget.child,
    );
  }
}
