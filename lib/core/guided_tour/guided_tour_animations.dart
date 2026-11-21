import 'package:flutter/material.dart';

/// Centralized motion parameters for the Guided Tour System.
class GuidedTourAnimations {
  const GuidedTourAnimations._();

  // Durations
  static const Duration entranceDuration = Duration(milliseconds: 380);
  static const Duration exitDuration = Duration(milliseconds: 250);
  static const Duration stepTransitionDuration = Duration(milliseconds: 320);
  static const Duration progressBarDuration = Duration(milliseconds: 350);
  static const Duration spotlightBreathingDuration = Duration(milliseconds: 1800);

  // Curves
  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
  static const Curve stepTransitionCurve = Curves.easeInOutCubic;
  static const Curve progressCurve = Curves.easeOutQuad;
  static const Curve spotlightBreathingCurve = Curves.easeInOutSine;
}
