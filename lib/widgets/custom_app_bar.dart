import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/size_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.title, this.showBackButton = false, this.onBackPressed, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceContainerHigh, width: SizeUtils.getHeight(1.0)),
        ),
      ),
      child: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.1),
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.onSurface, size: SizeUtils.getWidth(24.0)),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(title, style: AppTypography.headlineSmall),
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(SizeUtils.getHeight(44));
}
