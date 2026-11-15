import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../responsive/app_responsive.dart';
import '../theme/app_colors.dart';
import '../dimensions/app_radius.dart';
import '../typography/app_typography.dart';
import 'app_button.dart';

/// Central responsive Dialog container and convenience show methods
class AppDialog extends StatelessWidget {
  final Widget? title;
  final Widget content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  const AppDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.padding,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCardColor : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.dialog(context)),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: resp.isExtraCompact ? 12 : (resp.isSmall ? 16 : 24),
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? resp.dialogWidth,
          maxHeight: resp.screenHeight * 0.85,
        ),
        child: Padding(
          padding: padding ?? resp.dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                DefaultTextStyle(
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: resp.fontSize(18, min: 16, max: 21),
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  child: title!,
                ),
                SizedBox(height: resp.spacingSM),
              ],
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: content,
                ),
              ),
              if (actions != null && actions!.isNotEmpty) ...[
                SizedBox(height: resp.spacingMD),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Show responsive dialog with arbitrary content or child widget
  static Future<T?> show<T>({
    required BuildContext context,
    Widget? child,
    Widget? content,
    Widget? title,
    List<Widget>? actions,
    EdgeInsetsGeometry? padding,
    double? maxWidth,
    bool barrierDismissible = true,
  }) {
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);
    final effectiveContent = child ?? content ?? const SizedBox.shrink();

    return Get.dialog<T>(
      Dialog(
        backgroundColor: isDark ? AppColors.darkCardColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog(context)),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: resp.isExtraCompact ? 12 : (resp.isSmall ? 16 : 24),
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? resp.dialogWidth,
            maxHeight: resp.screenHeight * 0.85,
          ),
          child: Padding(
            padding: padding ?? resp.dialogPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) ...[
                  DefaultTextStyle(
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: resp.fontSize(18, min: 16, max: 21),
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    child: title,
                  ),
                  SizedBox(height: resp.spacingSM),
                ],
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: effectiveContent,
                  ),
                ),
                if (actions != null && actions.isNotEmpty) ...[
                  SizedBox(height: resp.spacingMD),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// Show standard responsive confirmation dialog
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    Color? confirmColor,
    bool isDestructive = false,
    VoidCallback? onConfirm,
  }) {
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);

    return Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog(context)),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: resp.isSmall ? 16 : 24,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: resp.dialogWidth),
          child: Padding(
            padding: resp.dialogPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: resp.fontSize(18, min: 16, max: 20),
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                SizedBox(height: resp.spacingSM),
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: resp.fontSize(14, min: 12, max: 16),
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: resp.spacingLG),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(
                        cancelLabel ?? 'cancel'.tr,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: resp.fontSize(14),
                        ),
                      ),
                    ),
                    SizedBox(width: resp.spacingSM),
                    AppButton(
                      text: confirmLabel ?? 'confirm'.tr,
                      isFullWidth: false,
                      variant: isDestructive
                          ? AppButtonVariant.destructive
                          : AppButtonVariant.primary,
                      customColor: confirmColor,
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () {
                        Get.back(result: true);
                        onConfirm?.call();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

