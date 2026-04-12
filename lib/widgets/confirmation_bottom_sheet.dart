import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'button_widget.dart';

class ConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? iconColor;
  final bool isDangerous;

  const ConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.icon,
    this.iconColor,
    this.isDangerous = false,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    String cancelText = 'Cancel',
    IconData? icon,
    Color? iconColor,
    bool isDangerous = false,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) => ConfirmationBottomSheet(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor,
        isDangerous: isDangerous,
        onConfirm: () => Navigator.pop(bottomSheetContext, true),
        onCancel: () => Navigator.pop(bottomSheetContext, false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        padding: EdgeInsets.only(
          left: 32.0,
          right: 32.0,
          top: 32.0,
          bottom: 32.0 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: AppColors.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            const SizedBox(height: 32.0),

            // Icon
            if (icon != null) ...[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.error).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.error,
                  size: 48.0,
                ),
              ),
              const SizedBox(height: 24.0),
            ],

            // Title
            Text(
              title,
              style: AppTypography.headlineSmallBold(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),

            // Message
            Text(
              message,
              style: AppTypography.bodyMediumSecondary(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButtonWidget(
                    text: cancelText,
                    onPressed: onCancel ?? () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: isDangerous
                      ? DangerButton(
                          text: confirmText,
                          onPressed: onConfirm,
                        )
                      : PrimaryButton(
                          text: confirmText,
                          onPressed: onConfirm,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
