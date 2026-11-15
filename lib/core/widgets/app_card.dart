import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../responsive/app_responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

/// Central responsive Card component with haptic feedback and optional scale animation
class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final BoxBorder? border;
  final double borderWidth;
  final double? borderRadius;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool animateOnPress;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.borderColor,
    this.border,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.shadows,
    this.onTap,
    this.onLongPress,
    this.animateOnPress = true,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);
    final radius = widget.borderRadius ?? resp.cardRadius;
    final cardBg = widget.color ?? AppColors.cardBg(context);
    final defaultBorder = isDark ? AppColors.borderDark : AppColors.borderLight;
    final effectiveBorder = widget.border ??
        Border.all(
          color: widget.borderColor ?? defaultBorder,
          width: widget.borderWidth,
        );
    final defaultShadows = AppShadows.card(isDark);

    Widget content = Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.gradient == null ? cardBg : null,
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(radius),
        border: effectiveBorder,
        boxShadow: widget.shadows ?? defaultShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap != null
                ? () {
                    HapticFeedback.lightImpact();
                    widget.onTap!();
                  }
                : null,
            onLongPress: widget.onLongPress != null
                ? () {
                    HapticFeedback.mediumImpact();
                    widget.onLongPress!();
                  }
                : null,
            splashColor: AppColors.primaryColor.withValues(alpha: 0.08),
            highlightColor: AppColors.primaryColor.withValues(alpha: 0.04),
            child: Padding(
              padding: widget.padding ?? resp.cardPadding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    if (widget.onTap != null && widget.animateOnPress) {
      return Listener(
        onPointerDown: (_) => setState(() => _isPressed = true),
        onPointerUp: (_) => setState(() => _isPressed = false),
        onPointerCancel: (_) => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: content,
        ),
      );
    }

    return content;
  }
}

