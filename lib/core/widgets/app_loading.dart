import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../typography/app_typography.dart';
import '../responsive/app_responsive.dart';

/// Central loading indicator widget
class AppLoading extends StatelessWidget {
  final String? message;
  final double size;

  const AppLoading({
    super.key,
    this.message,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
              ),
            ),
          ),
          if (message != null && message!.isNotEmpty) ...[
            SizedBox(height: resp.spacingMD),
            Text(
              message!,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: resp.fontSize(14),
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

