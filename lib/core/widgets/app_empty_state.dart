import 'package:flutter/material.dart';
import '../responsive/app_responsive.dart';
import '../theme/app_colors.dart';
import '../typography/app_typography.dart';
import 'app_button.dart';

/// Central responsive empty state widget
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final Color? iconColor;
  final bool isCompact;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.iconColor,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);
    final color = iconColor ?? AppColors.primaryOf(context);

    final avatarSize = resp.isShort
        ? 44.0
        : (isCompact ? 56.0 : (resp.isSmall ? 68.0 : 80.0));
    final iconSz = resp.isShort
        ? 22.0
        : (isCompact ? 26.0 : (resp.isSmall ? 32.0 : 38.0));

    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: resp.isSmall ? 20.0 : 32.0,
          vertical: resp.isShort ? 8.0 : (isCompact ? 20.0 : 32.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.15 : 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.18),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: iconSz,
                  color: color,
                ),
              ),
            ),
            SizedBox(height: isCompact ? 10 : 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w700,
                fontSize: isCompact ? 14 : resp.fontSize(resp.isSmall ? 15 : 17),
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                letterSpacing: -0.2,
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: isCompact ? 12 : resp.fontSize(13),
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: isCompact ? 14 : 20),
              AppButton(
                text: actionLabel!,
                icon: actionIcon ?? Icons.add_rounded,
                onPressed: onAction,
                isFullWidth: false,
                height: resp.isSmall ? 44 : 48,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

