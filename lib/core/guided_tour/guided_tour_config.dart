import 'package:flutter/material.dart';
import 'guided_tour_step.dart';

/// Configuration for an entire Guided Tour sequence on a screen.
class GuidedTourConfig {
  /// Unique identifier used for persistence (e.g. 'dashboard_tour')
  final String tourId;

  /// Human-readable title of the tour
  final String title;

  /// Ordered sequence of steps in this tour
  final List<GuidedTourStep> steps;

  /// Optional scope name (defaults to tourId)
  final String scope;

  /// Overlay opacity (0.0 to 1.0)
  final double overlayOpacity;

  /// Background blur value (default 2.0)
  final double blurValue;

  /// Whether to disable the breathing spotlight movement animation
  final bool disableMovingAnimation;

  /// Whether to automatically prompt/start on first visit
  final bool autoStartOnFirstVisit;

  /// Callback when all steps in tour are completed
  final VoidCallback? onFinish;

  /// Callback when user skips or dismisses tour
  final VoidCallback? onDismiss;

  /// Callback on each step navigation
  final void Function(int index, GuidedTourStep step)? onStepChange;

  GuidedTourConfig({
    required this.tourId,
    required this.title,
    required this.steps,
    String? scope,
    this.overlayOpacity = 0.65,
    this.blurValue = 2.0,
    this.disableMovingAnimation = false,
    this.autoStartOnFirstVisit = true,
    this.onFinish,
    this.onDismiss,
    this.onStepChange,
  }) : scope = scope ?? tourId;

  /// Returns list of all GlobalKeys for the steps
  List<GlobalKey> get stepKeys => steps.map((s) => s.targetKey).toList();

  /// Step count
  int get stepCount => steps.length;
}
