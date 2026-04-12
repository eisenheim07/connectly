import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/connectivity_cubit.dart';
import '../cubits/connectivity_state.dart';
import '../main.dart';
import 'no_internet_bottom_sheet.dart';

/// Wrapper widget that monitors connectivity and shows bottom sheet when disconnected
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isBottomSheetShown = false;

  @override
  void initState() {
    super.initState();
    print('ConnectivityWrapper: initState called');
    // Start monitoring connectivity when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('ConnectivityWrapper: Starting monitoring from postFrameCallback');
      context.read<ConnectivityCubit>().startMonitoring();
    });
  }

  void _showNoInternetBottomSheet() {
    print('ConnectivityWrapper: _showNoInternetBottomSheet called, _isBottomSheetShown: $_isBottomSheetShown, mounted: $mounted');
    if (!_isBottomSheetShown && mounted) {
      setState(() {
        _isBottomSheetShown = true;
      });

      print('ConnectivityWrapper: Showing bottom sheet using global navigator key');
      // Use global navigator key
      final navigatorContext = navigatorKey.currentContext;
      if (navigatorContext != null) {
        NoInternetBottomSheet.show(navigatorContext);
      } else {
        print('ConnectivityWrapper: Navigator context is null!');
      }
    }
  }

  void _hideNoInternetBottomSheet() {
    print('ConnectivityWrapper: _hideNoInternetBottomSheet called, _isBottomSheetShown: $_isBottomSheetShown, mounted: $mounted');
    if (_isBottomSheetShown && mounted) {
      setState(() {
        _isBottomSheetShown = false;
      });
      print('ConnectivityWrapper: Hiding bottom sheet using global navigator key');
      try {
        navigatorKey.currentState?.pop();
      } catch (e) {
        print('ConnectivityWrapper: Error popping bottom sheet: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConnectivityCubit, ConnectivityState>(
      listener: (context, state) {
        print('ConnectivityWrapper: BlocListener triggered with state: $state');
        if (state is ConnectivityDisconnected) {
          print('ConnectivityWrapper: State is ConnectivityDisconnected, calling _showNoInternetBottomSheet');
          _showNoInternetBottomSheet();
        } else if (state is ConnectivityConnected) {
          print('ConnectivityWrapper: State is ConnectivityConnected, calling _hideNoInternetBottomSheet');
          _hideNoInternetBottomSheet();
        }
      },
      builder: (context, state) {
        // Debug overlay to show connectivity state
        return Stack(
          children: [
            widget.child,
            // Debug indicator (remove in production)
            // Positioned(
            //   top: 50,
            //   right: 10,
            //   child: Container(
            //     padding: const EdgeInsets.all(8),
            //     decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
            //     child: Text('State: ${state.runtimeType}\nSheet: $_isBottomSheetShown', style: const TextStyle(color: Colors.white, fontSize: 10)),
            //   ),
            // ),
          ],
        );
      },
    );
  }
}
