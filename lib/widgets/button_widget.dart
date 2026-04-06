import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/size_utils.dart';

/// Primary Button - Solid background with high emphasis
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: SizeUtils.getSize(20.0)),
              SizedBox(width: SizeUtils.getSize(8.0)),
              Text(
                text,
                style: AppTypography.labelMedium.copyWith(
                  color: textColor ?? AppColors.onSecondary,
                  fontWeight: fontWeight ?? FontWeight.bold,
                  fontSize: fontSize ?? SizeUtils.getFontSize(14.0),
                ),
              ),
            ],
          )
        : Text(
            text,
            style: AppTypography.labelMedium.copyWith(
              color: textColor ?? AppColors.onSecondary,
              fontWeight: fontWeight ?? FontWeight.bold,
              fontSize: fontSize ?? SizeUtils.getFontSize(14.0),
            ),
          );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.secondary,
          foregroundColor: textColor ?? AppColors.onSecondary,
          padding: padding ?? EdgeInsets.symmetric(
            horizontal: SizeUtils.getSize(24.0),
            vertical: SizeUtils.getSize(14.0),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? SizeUtils.getSize(100.0)),
          ),
          elevation: 0,
          disabledBackgroundColor: AppColors.surfaceContainerHigh,
          disabledForegroundColor: AppColors.onSurfaceVariant,
        ),
        child: buttonChild,
      ),
    );
  }
}

/// Outlined Button - Transparent background with border
class OutlinedButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final IconData? icon;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderWidth;

  const OutlinedButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.borderColor,
    this.textColor,
    this.icon,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: SizeUtils.getSize(18.0)),
              SizedBox(width: SizeUtils.getSize(8.0)),
              Text(
                text,
                style: AppTypography.labelMedium.copyWith(
                  color: textColor ?? AppColors.onSurface,
                  fontWeight: fontWeight ?? FontWeight.bold,
                  fontSize: fontSize ?? SizeUtils.getFontSize(14.0),
                ),
              ),
            ],
          )
        : Text(
            text,
            style: AppTypography.labelMedium.copyWith(
              color: textColor ?? AppColors.onSurface,
              fontWeight: fontWeight ?? FontWeight.bold,
              fontSize: fontSize ?? SizeUtils.getFontSize(14.0),
            ),
          );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: textColor ?? AppColors.onSurface,
          padding: padding ?? EdgeInsets.symmetric(vertical: SizeUtils.getSize(14.0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? SizeUtils.getSize(100.0)),
            side: BorderSide(
              color: borderColor ?? AppColors.outlineVariant.withOpacity(0.2),
              width: borderWidth ?? 1.0,
            ),
          ),
          elevation: 0,
        ),
        child: buttonChild,
      ),
    );
  }
}

/// Text Button - No background, just text
class TextButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;

  const TextButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: padding ?? EdgeInsets.zero,
      ),
      child: Text(
        text,
        style: AppTypography.labelMedium.copyWith(
          color: textColor ?? AppColors.primary,
          fontWeight: fontWeight ?? FontWeight.w600,
          fontSize: fontSize ?? SizeUtils.getFontSize(12.0),
        ),
      ),
    );
  }
}

/// Icon Button - Circular button with icon only
class IconButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final double? iconSize;

  const IconButtonWidget({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? SizeUtils.getSize(48.0);
    final buttonIconSize = iconSize ?? SizeUtils.getSize(24.0);
    
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceContainerLow,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor ?? AppColors.onSurface,
          size: buttonIconSize,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

/// Permission Button - Special button for permission cards
class PermissionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isGranted;
  final IconData? icon;

  const PermissionButton({
    super.key,
    required this.text,
    this.onPressed,
    required this.isGranted,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isGranted ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isGranted ? AppColors.surfaceContainerHigh : AppColors.secondary,
          foregroundColor: isGranted ? AppColors.onSurfaceVariant : AppColors.onSecondary,
          padding: EdgeInsets.symmetric(vertical: SizeUtils.getSize(14.0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeUtils.getSize(100.0)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? (isGranted ? Icons.check_circle : Icons.lock_open),
              size: SizeUtils.getSize(20.0),
            ),
            SizedBox(width: SizeUtils.getSize(8.0)),
            Text(
              text,
              style: AppTypography.labelMedium.copyWith(
                color: isGranted ? AppColors.onSurfaceVariant : AppColors.onSecondary,
                fontWeight: FontWeight.bold,
                fontSize: SizeUtils.getFontSize(14.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
