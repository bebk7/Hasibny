import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

/// Represents a single step in a Guided Tour.
class GuidedTourStep {
  /// Unique identifier for this step within the tour
  final String id;

  /// GlobalKey of the target widget to highlight
  final GlobalKey targetKey;

  /// Feature title (supports localized text)
  final String title;

  /// Clear, concise description of the feature
  final String description;

  /// Optional thematic feature icon
  final IconData? icon;

  /// Explicit tooltip position relative to target (e.g. top or bottom)
  final TooltipPosition? tooltipPosition;

  /// Padding around the highlighted spotlight target
  final EdgeInsets targetPadding;

  /// Corner radius of the spotlight cut-out
  final BorderRadius? targetBorderRadius;

  /// Shape border override for circular or custom target cut-outs
  final ShapeBorder? targetShapeBorder;

  /// Optional callback invoked when target widget is tapped
  final VoidCallback? onTargetClick;

  /// Optional callback invoked when this step is shown
  final VoidCallback? onStepShown;

  /// Optional callback invoked when this step is dismissed/skipped
  final VoidCallback? onStepDismissed;

  /// Optional fully-custom tooltip content
  final Widget? customWidget;

  /// Optional scope name (defaults to tour scope)
  final String? scope;

  const GuidedTourStep({
    required this.id,
    required this.targetKey,
    required this.title,
    required this.description,
    this.icon,
    this.tooltipPosition,
    this.targetPadding = const EdgeInsets.all(8.0),
    this.targetBorderRadius,
    this.targetShapeBorder,
    this.onTargetClick,
    this.onStepShown,
    this.onStepDismissed,
    this.customWidget,
    this.scope,
  });
}
