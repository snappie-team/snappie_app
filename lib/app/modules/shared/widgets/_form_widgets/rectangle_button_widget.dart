import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  icon,
}

enum RectangleButtonSize {
  small,
  medium,
  large,
}

class RectangleButtonWidget extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final ButtonType type;
  final RectangleButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Widget? icon;
  final bool iconRight;
  final double? iconSpacing;
  final TextStyle? textStyle;
  final double? elevation;
  final Color? shadowColor;

  const RectangleButtonWidget({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = RectangleButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.icon,
    this.iconRight = false,
    this.iconSpacing,
    this.textStyle,
    this.elevation,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isDisabled && !isLoading && onPressed != null;
    
    return Container(
      width: width,
      height: height ?? _getHeight(),
      margin: margin,
      child: _buildButton(isEnabled),
    );
  }

  Widget _buildButton(bool isEnabled) {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: textColor ?? AppColors.textOnPrimary,
            disabledBackgroundColor: AppColors.surfaceContainer,
            disabledForegroundColor: AppColors.textTertiary,
            elevation: elevation ?? 2,
            shadowColor: shadowColor ?? AppColors.shadowLight,
            padding: padding ?? _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
          ),
          child: _buildContent(),
        );
      
      case ButtonType.secondary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.surfaceContainer,
            foregroundColor: textColor ?? AppColors.textPrimary,
            disabledBackgroundColor: AppColors.surfaceContainer.withOpacity(0.5),
            disabledForegroundColor: AppColors.textTertiary,
            elevation: elevation ?? 1,
            shadowColor: shadowColor ?? AppColors.shadowLight,
            padding: padding ?? _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
          ),
          child: _buildContent(),
        );
      
      case ButtonType.outline:
        return OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppColors.primary,
            disabledForegroundColor: AppColors.textTertiary,
            padding: padding ?? _getPadding(),
            side: BorderSide(
              color: isEnabled 
                  ? (borderColor ?? AppColors.primary)
                  : AppColors.border.withOpacity(0.3),
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
          ),
          child: _buildContent(),
        );
      
      case ButtonType.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? AppColors.primary,
            disabledForegroundColor: AppColors.textTertiary,
            padding: padding ?? _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
          ),
          child: _buildContent(),
        );
      
      case ButtonType.icon:
        return IconButton(
          onPressed: isEnabled ? onPressed : null,
          // TODO: Add add.svg icon to assets/iconsvg/
          icon: icon ?? const Icon(Icons.add),
          color: textColor ?? AppColors.primary,
          disabledColor: AppColors.textTertiary,
          iconSize: _getIconSize(),
          padding: padding ?? EdgeInsets.all(_getIconPadding()),
          style: IconButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
          ),
        );
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        width: _getLoadingSize(),
        height: _getLoadingSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            textColor ?? AppColors.textOnPrimary,
          ),
        ),
      );
    }

    final content = child ?? (text != null ? Text(
      text!,
      style: textStyle ?? TextStyle(
        fontSize: _getFontSize(),
        fontWeight: FontWeight.w500,
      ),
    ) : const SizedBox.shrink());

    if (icon != null && type != ButtonType.icon) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: iconRight ? [
          content,
          SizedBox(width: iconSpacing ?? 8),
          icon!,
        ] : [
          icon!,
          SizedBox(width: iconSpacing ?? 8),
          content,
        ],
      );
    }

    return content;
  }

  double _getHeight() {
    switch (size) {
      case RectangleButtonSize.small:
        return 36;
      case RectangleButtonSize.medium:
        return 44;
      case RectangleButtonSize.large:
        return 52;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case RectangleButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case RectangleButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case RectangleButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    }
  }

  double _getFontSize() {
    switch (size) {
      case RectangleButtonSize.small:
        return 12;
      case RectangleButtonSize.medium:
        return 14;
      case RectangleButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case RectangleButtonSize.small:
        return 16;
      case RectangleButtonSize.medium:
        return 20;
      case RectangleButtonSize.large:
        return 24;
    }
  }

  double _getIconPadding() {
    switch (size) {
      case RectangleButtonSize.small:
        return 6;
      case RectangleButtonSize.medium:
        return 8;
      case RectangleButtonSize.large:
        return 12;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case RectangleButtonSize.small:
        return 16;
      case RectangleButtonSize.medium:
        return 20;
      case RectangleButtonSize.large:
        return 24;
    }
  }
}
