import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../responsive/app_responsive.dart';
import '../theme/app_colors.dart';
import '../dimensions/app_radius.dart';
import '../dimensions/app_component_sizes.dart';

/// Central responsive Bottom Sheet container and show helper
class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final bool showDragHandle;
  final double? maxHeight;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.padding,
    this.showDragHandle = true,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final availableHeight =
        (resp.screenHeight - viewInsets.bottom).clamp(200.0, resp.screenHeight);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: resp.maxContentWidth,
          maxHeight: maxHeight ?? (availableHeight * 0.88),
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceColor : Colors.white,
          borderRadius: AppRadius.bottomSheetRadius(context),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.only(
              left: resp.isExtraCompact ? 14 : 20,
              right: resp.isExtraCompact ? 14 : 20,
              top: 14,
              bottom: viewPadding.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showDragHandle) ...[
                  Center(
                    child: Container(
                      width: AppComponentSizes.dragHandleSize.width,
                      height: AppComponentSizes.dragHandleSize.height,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
                if (title != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title!,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: resp.fontSize(16.5, min: 14.5, max: 19),
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                  SizedBox(height: resp.spacingSM),
                  const Divider(height: 1),
                  SizedBox(height: resp.spacingMD),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show responsive bottom sheet via GetX
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = true,
  }) {
    return Get.bottomSheet<T>(
      AppBottomSheet(
        title: title,
        child: child,
      ),
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}

