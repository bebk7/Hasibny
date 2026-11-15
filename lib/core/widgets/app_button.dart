import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../responsive/app_responsive.dart';
import '../theme/app_colors.dart';
import '../typography/app_typography.dart';

enum AppButtonVariant { primary, secondary, outlined, destructive, ghost, got }

/// Central responsive Button component with touch target accessibility and haptic feedback
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonVariant variant;
  final Color? customColor;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.variant = AppButtonVariant.primary,
    this.customColor,
    this.height,
    this.padding,
    this.borderRadius,
  });

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.customColor,
    this.height,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.customColor,
    this.height,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.destructive({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.customColor,
    this.height,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.destructive;

  const AppButton.ghost({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customColor,
    this.height,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.ghost;

  const AppButton.got({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.customColor,
    this.height,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.got;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final radius = widget.borderRadius ?? resp.buttonRadius;
    final btnHeight = widget.height ?? resp.buttonHeight;

    Color bgColor;
    Color textColor;
    Border? border;
    Gradient? gradient;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        bgColor = widget.customColor ?? AppColors.primaryColor;
        textColor = Colors.white;
        gradient = widget.customColor == null ? AppColors.primaryGradient : null;
        break;
      case AppButtonVariant.secondary:
        bgColor = widget.customColor?.withValues(alpha: 0.1) ??
            (isDark
                ? AppColors.primaryColor.withValues(alpha: 0.15)
                : AppColors.primaryColor.withValues(alpha: 0.08));
        textColor = widget.customColor ??
            (isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor);
        break;
      case AppButtonVariant.outlined:
        bgColor = Colors.transparent;
        textColor = widget.customColor ??
            (isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor);
        border = Border.all(
          color: widget.customColor?.withValues(alpha: 0.5) ??
              (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 1.2,
        );
        break;
      case AppButtonVariant.destructive:
        bgColor = widget.customColor ?? AppColors.giveColor;
        textColor = Colors.white;
        gradient = widget.customColor == null ? AppColors.giveGradient : null;
        break;
      case AppButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = widget.customColor ??
            (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
        break;
      case AppButtonVariant.got:
        bgColor = widget.customColor ?? AppColors.gotColor;
        textColor = Colors.white;
        gradient = widget.customColor == null ? AppColors.gotGradient : null;
        break;
    }

    if (!isEnabled) {
      bgColor = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05);
      textColor = isDark ? Colors.white38 : Colors.black26;
      border = null;
      gradient = null;
    }

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: resp.isSmall ? 18 : 20, color: textColor),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              color: textColor,
              fontSize: resp.fontSize(resp.isSmall ? 14 : 15, min: 12, max: 17),
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );

    Widget button = Container(
      height: btnHeight,
      constraints: BoxConstraints(
        minWidth: widget.isFullWidth ? double.infinity : 80,
      ),
      decoration: BoxDecoration(
        color: gradient == null ? bgColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: border,
        boxShadow: (isEnabled &&
                (widget.variant == AppButtonVariant.primary ||
                    widget.variant == AppButtonVariant.destructive ||
                    widget.variant == AppButtonVariant.got))
            ? [
                BoxShadow(
                  color: (widget.variant == AppButtonVariant.primary
                          ? AppColors.primaryColor
                          : (widget.variant == AppButtonVariant.got
                              ? AppColors.gotColor
                              : AppColors.giveColor))
                      .withValues(alpha: 0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled
              ? () {
                  HapticFeedback.lightImpact();
                  widget.onPressed!();
                }
              : null,
          borderRadius: BorderRadius.circular(radius),
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Padding(
            padding: widget.padding ??
                EdgeInsets.symmetric(
                  horizontal: resp.isSmall ? 16.0 : 20.0,
                  vertical: 8.0,
                ),
            child: content,
          ),
        ),
      ),
    );

    if (widget.isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    if (isEnabled) {
      return Listener(
        onPointerDown: (_) => setState(() => _isPressed = true),
        onPointerUp: (_) => setState(() => _isPressed = false),
        onPointerCancel: (_) => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: button,
        ),
      );
    }

    return button;
  }
}

