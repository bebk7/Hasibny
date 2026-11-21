import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../typography/app_typography.dart';

import 'guided_tour_step.dart';
import 'guided_tour_theme.dart';
import 'guided_tour_animations.dart';

/// Elite Custom Tooltip Widget
/// Renders a glassmorphic, animated, and responsive card anchored to the spotlight.
class GuidedTourTooltip extends StatelessWidget {
  final GuidedTourStep step;
  final int currentStepIndex;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;
  final VoidCallback onFinish;

  const GuidedTourTooltip({
    super.key,
    required this.step,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
    required this.onFinish,
  });

  bool get isFirstStep => currentStepIndex == 0;
  bool get isLastStep => currentStepIndex >= totalSteps - 1;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final clampedScaler = media.textScaler.clamp(maxScaleFactor: 1.25);
    final screenWidth = media.size.width;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // Responsive maxWidth: adapt from small phones (320px) to tablets
    final cardWidth = min(screenWidth - 32.0, 380.0);

    return MediaQuery(
      data: media.copyWith(textScaler: clampedScaler),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: cardWidth,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: GuidedTourTheme.cardBackground(context),
              borderRadius: BorderRadius.circular(GuidedTourTheme.cardRadius),
              border: Border.all(
                color: GuidedTourTheme.cardBorderColor(context),
                width: GuidedTourTheme.cardBorderWidth,
              ),
              boxShadow: GuidedTourTheme.cardShadows(context),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(GuidedTourTheme.cardRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: GuidedTourTheme.cardBlurSigma,
                  sigmaY: GuidedTourTheme.cardBlurSigma,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header: Icon + Title + Step Badge
                      _buildHeader(context, isRtl),

                      const SizedBox(height: 12),

                      // Animated Progress Bar
                      _buildProgressBar(context),

                      const SizedBox(height: 14),

                      // Step Description with AnimatedSwitcher
                      AnimatedSwitcher(
                        duration: GuidedTourAnimations.stepTransitionDuration,
                        switchInCurve: GuidedTourAnimations.stepTransitionCurve,
                        switchOutCurve: GuidedTourAnimations.stepTransitionCurve,
                        child: Text(
                          step.description,
                          key: ValueKey('desc_${step.id}'),
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.92),
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Action Buttons Footer
                      _buildFooter(context, isRtl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isRtl) {
    return Row(
      children: [
        // Optional Feature Icon Badge
        if (step.icon != null) ...[
          Container(
            width: GuidedTourTheme.iconBadgeSize,
            height: GuidedTourTheme.iconBadgeSize,
            decoration: GuidedTourTheme.iconBadgeDecoration(context),
            child: Icon(
              step.icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
        ],

        // Feature Title
        Expanded(
          child: AnimatedSwitcher(
            duration: GuidedTourAnimations.stepTransitionDuration,
            switchInCurve: GuidedTourAnimations.stepTransitionCurve,
            switchOutCurve: GuidedTourAnimations.stepTransitionCurve,
            child: Align(
              key: ValueKey('title_${step.id}'),
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                step.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Step Counter Pill Badge (e.g. 1 / 4)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: GuidedTourTheme.stepBadgeDecoration(context),
          child: Text(
            '${currentStepIndex + 1} / $totalSteps',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final progress = totalSteps > 0 ? (currentStepIndex + 1) / totalSteps : 1.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(GuidedTourTheme.progressBarHeight / 2),
      child: Container(
        height: GuidedTourTheme.progressBarHeight,
        color: GuidedTourTheme.progressBarTrackColor,
        child: TweenAnimationBuilder<double>(
          duration: GuidedTourAnimations.progressBarDuration,
          curve: GuidedTourAnimations.progressCurve,
          tween: Tween<double>(begin: 0.0, end: progress),
          builder: (context, animatedValue, child) {
            return FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: animatedValue.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: GuidedTourTheme.progressBarGradient(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isRtl) {
    final nextLabel = isLastStep ? 'tour_finish'.tr : 'tour_next'.tr;
    final prevLabel = 'tour_prev'.tr;
    final skipLabel = 'tour_skip'.tr;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Skip Button
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            onSkip();
          },
          style: GuidedTourTheme.skipButtonStyle(context),
          child: Text(
            skipLabel,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 6),

        // Actions Group (Prev + Next/Finish)
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isFirstStep) ...[
                Flexible(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onPrevious();
                    },
                    style: GuidedTourTheme.prevButtonStyle(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            prevLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (isLastStep) {
                      onFinish();
                    } else {
                      onNext();
                    }
                  },
                  style: GuidedTourTheme.nextButtonStyle(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          nextLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        isLastStep
                            ? Icons.check_circle_rounded
                            : (isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
