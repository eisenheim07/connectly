import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/connectivity_cubit.dart';
import '../cubits/connectivity_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/size_utils.dart';
import 'button_widget.dart';

class NoInternetBottomSheet extends StatelessWidget {
  const NoInternetBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (bottomSheetContext) => WillPopScope(onWillPop: () async => false, child: const NoInternetBottomSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(SizeUtils.getSize(24.0)), topRight: Radius.circular(SizeUtils.getSize(24.0))),
      ),
      padding: EdgeInsets.only(
        left: SizeUtils.getSize(32.0),
        right: SizeUtils.getSize(32.0),
        top: SizeUtils.getSize(16.0),
        bottom: SizeUtils.getSize(32.0) + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: SizeUtils.getSize(40.0),
            height: SizeUtils.getSize(4.0),
            decoration: BoxDecoration(
              color: AppColors.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(SizeUtils.getSize(2.0)),
            ),
          ),
          SizedBox(height: SizeUtils.getSize(32.0)),

          Container(
            width: SizeUtils.getSize(80.0),
            height: SizeUtils.getSize(80.0),
            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.wifi_off, color: AppColors.error, size: SizeUtils.getSize(48.0)),
          ),
          SizedBox(height: SizeUtils.getSize(24.0)),

          Text('No Internet Connection', style: AppTypography.headlineSmallBold(), textAlign: TextAlign.center),
          SizedBox(height: SizeUtils.getSize(8.0)),

          Text('Please check your internet connection and try again.', style: AppTypography.bodyMediumSecondary(), textAlign: TextAlign.center),
          SizedBox(height: SizeUtils.getSize(32.0)),

          BlocBuilder<ConnectivityCubit, ConnectivityState>(
            builder: (context, state) {
              final isChecking = state is ConnectivityChecking;

              return PrimaryButton(
                text: isChecking ? 'Checking...' : 'Try Again',
                onPressed: isChecking
                    ? null
                    : () {
                        context.read<ConnectivityCubit>().checkConnectivity();
                      },
                icon: isChecking ? null : Icons.refresh,
                width: double.infinity,
              );
            },
          ),
        ],
      ),
    );
  }
}
