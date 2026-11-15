import 'package:flutter/material.dart';
import '../responsive/app_responsive.dart';
import '../theme/app_colors.dart';
import '../typography/app_typography.dart';

/// Central Section Header component
class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTrailingTap;
  final String? actionText;
  final IconData? icon;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTrailingTap,
    this.actionText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: resp.isSmall ? 6.0 : 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: resp.isSmall ? 18 : 20,
                    color: AppColors.primaryOf(context),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: resp.fontSize(resp.isSmall ? 15 : 16),
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: resp.fontSize(resp.isSmall ? 11 : 12),
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (actionText != null && onTrailingTap != null)
            InkWell(
              onTap: onTrailingTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionText!,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: resp.fontSize(resp.isSmall ? 12 : 13),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      resp.forwardIcon,
                      size: resp.isSmall ? 14 : 16,
                      color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

