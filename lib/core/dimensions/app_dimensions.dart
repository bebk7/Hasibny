import 'package:flutter/material.dart';
import 'app_spacing.dart';
import 'app_radius.dart';
import 'app_icon_sizes.dart';
import 'app_component_sizes.dart';
import 'app_sizes.dart';

/// Central facade for all design dimensions
class AppDimensions {
  AppDimensions._();

  static const spacing = AppSpacing;
  static const radius = AppRadius;
  static const icons = AppIconSizes;
  static const components = AppComponentSizes;
  static const sizes = AppSizes;

  // Shortcuts
  static EdgeInsets pagePadding(BuildContext context) =>
      AppSpacing.page(context);

  static EdgeInsets tabPadding(BuildContext context) =>
      AppSpacing.tab(context);

  static EdgeInsets cardPadding(BuildContext context) =>
      AppSpacing.card(context);

  static EdgeInsets dialogPadding(BuildContext context) =>
      AppSpacing.dialog(context);

  static double cardRadius(BuildContext context) =>
      AppRadius.card(context);

  static double buttonHeight(BuildContext context) =>
      AppComponentSizes.buttonHeight(context);

  static double inputHeight(BuildContext context) =>
      AppComponentSizes.inputHeight(context);

  static double iconSize(BuildContext context) =>
      AppIconSizes.standard(context);

  static double fabSize(BuildContext context) =>
      AppComponentSizes.fabSize(context);

  static double avatarRadius(BuildContext context) =>
      AppComponentSizes.avatarRadius(context);

  static BoxConstraints dialogConstraints(BuildContext context) =>
      AppComponentSizes.dialogConstraints(context);
}

