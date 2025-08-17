import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

enum ButtonVariant { primary, secondary, outline, text }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget buttonChild = isLoading
        ? SizedBox(
            height: _getIconSize(),
            width: _getIconSize(),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: _getIconSize()),
                  const SizedBox(width: 8),
                  child,
                ],
              )
            : child;

    final buttonStyle = _getButtonStyle(theme);

    Widget button = switch (variant) {
      ButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        ),
      ButtonVariant.secondary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        ),
      ButtonVariant.outline => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        ),
      ButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        ),
    };

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    final padding = _getPadding();
    final minimumSize = _getMinimumSize();
    
    return switch (variant) {
      ButtonVariant.primary => ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primaryColor,
          foregroundColor: foregroundColor ?? Colors.white,
          padding: padding,
          minimumSize: minimumSize,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ButtonVariant.secondary => ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.secondaryColor,
          foregroundColor: foregroundColor ?? Colors.white,
          padding: padding,
          minimumSize: minimumSize,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
        ),
      ButtonVariant.outline => OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? AppTheme.primaryColor,
          padding: padding,
          minimumSize: minimumSize,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: backgroundColor ?? AppTheme.primaryColor,
            width: 1.5,
          ),
        ),
      ButtonVariant.text => TextButton.styleFrom(
          foregroundColor: foregroundColor ?? AppTheme.primaryColor,
          padding: padding,
          minimumSize: minimumSize,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
    };
  }

  EdgeInsets _getPadding() {
    return switch (size) {
      ButtonSize.small => const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ButtonSize.medium => const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ButtonSize.large => const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    };
  }

  Size _getMinimumSize() {
    return switch (size) {
      ButtonSize.small => const Size(0, 36),
      ButtonSize.medium => const Size(0, 48),
      ButtonSize.large => const Size(0, 56),
    };
  }

  double _getIconSize() {
    return switch (size) {
      ButtonSize.small => 16,
      ButtonSize.medium => 20,
      ButtonSize.large => 24,
    };
  }
}

// Convenience constructors
class PrimaryButton extends CustomButton {
  const PrimaryButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.size,
    super.isLoading,
    super.icon,
    super.fullWidth,
  }) : super(variant: ButtonVariant.primary);
}

class SecondaryButton extends CustomButton {
  const SecondaryButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.size,
    super.isLoading,
    super.icon,
    super.fullWidth,
  }) : super(variant: ButtonVariant.secondary);
}

class OutlineButton extends CustomButton {
  const OutlineButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.size,
    super.isLoading,
    super.icon,
    super.fullWidth,
  }) : super(variant: ButtonVariant.outline);
}

class TextOnlyButton extends CustomButton {
  const TextOnlyButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.size,
    super.isLoading,
    super.icon,
    super.fullWidth = false,
  }) : super(variant: ButtonVariant.text);
}
