import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';
import 'guided_tour_animations.dart';
import 'guided_tour_manager.dart';

import 'guided_tour_step.dart';
import 'guided_tour_theme.dart';
import 'guided_tour_tooltip.dart';

/// Elite Guided Tour Scope Widget
/// Wraps a screen or sub-tree with a registered ShowcaseView instance and lifecycle management.
class GuidedTourScope extends StatefulWidget {
  final Widget child;
  final String? scope;
  final double overlayOpacity;
  final double blurValue;
  final bool disableMovingAnimation;

  const GuidedTourScope({
    super.key,
    required this.child,
    this.scope,
    this.overlayOpacity = GuidedTourTheme.defaultOverlayOpacity,
    this.blurValue = GuidedTourTheme.defaultOverlayBlur,
    this.disableMovingAnimation = false,
  });

  static GuidedTourScopeState? maybeOf(BuildContext context) {
    final scopeWidget = context.dependOnInheritedWidgetOfExactType<_GuidedTourScopeInherited>();
    return scopeWidget?.state;
  }

  static GuidedTourScopeState of(BuildContext context) {
    final state = maybeOf(context);
    assert(state != null, 'No GuidedTourScope found in context');
    return state!;
  }

  @override
  State<GuidedTourScope> createState() => GuidedTourScopeState();
}

class GuidedTourScopeState extends State<GuidedTourScope> {
  late final String scopeName;
  late final ShowcaseView showcaseView;

  @override
  void initState() {
    super.initState();
    scopeName = widget.scope ?? 'guided_tour_scope_${identityHashCode(this)}';
    showcaseView = ShowcaseView.register(
      scope: scopeName,
      overlayOpacity: widget.overlayOpacity,
      blurValue: widget.blurValue,
      disableMovingAnimation: widget.disableMovingAnimation,
      onStart: (index, key) {
        GuidedTourManager.instance.handleShowcaseStart(index, key);
      },
      onFinish: () {
        GuidedTourManager.instance.handleShowcaseFinish();
      },
      onDismiss: (dismissedAt) {
        GuidedTourManager.instance.handleShowcaseDismiss(dismissedAt);
      },
    );
  }

  @override
  void dispose() {
    showcaseView.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GuidedTourScopeInherited(
      state: this,
      child: widget.child,
    );
  }
}

class _GuidedTourScopeInherited extends InheritedWidget {
  final GuidedTourScopeState state;

  const _GuidedTourScopeInherited({
    required this.state,
    required super.child,
  });

  @override
  bool updateShouldNotify(_GuidedTourScopeInherited oldWidget) =>
      state != oldWidget.state;
}

/// Target widget wrapper for a Guided Tour Step.
/// Automatically connects to the active ShowcaseView and renders the elite tooltip.
class GuidedTourTarget extends StatelessWidget {
  final GuidedTourStep step;
  final Widget child;
  final double? overlayOpacity;
  final double? blurValue;
  final bool? disableMovingAnimation;

  const GuidedTourTarget({
    super.key,
    required this.step,
    required this.child,
    this.overlayOpacity,
    this.blurValue,
    this.disableMovingAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final scopeState = GuidedTourScope.maybeOf(context);
    final effectiveScope = step.scope ?? scopeState?.scopeName;

    // Safety check: if no ShowcaseView is registered in the environment (e.g. isolated view tests),
    // safely return the child directly without crashing.
    bool canShowcase = false;
    try {
      if (effectiveScope != null) {
        ShowcaseView.getNamed(effectiveScope);
      } else {
        ShowcaseView.get();
      }
      canShowcase = true;
    } catch (_) {
      canShowcase = false;
    }

    if (!canShowcase) {
      return child;
    }

    final targetRadius = step.targetBorderRadius ??
        BorderRadius.circular(GuidedTourTheme.defaultSpotlightRadius);

    final targetBorder = step.targetShapeBorder ??
        RoundedRectangleBorder(borderRadius: targetRadius);

    return Showcase.withWidget(
      key: step.targetKey,
      scope: effectiveScope,
      targetPadding: step.targetPadding,
      targetBorderRadius: targetRadius,
      targetShapeBorder: targetBorder,
      overlayOpacity: overlayOpacity ?? GuidedTourTheme.defaultOverlayOpacity,
      blurValue: blurValue ?? GuidedTourTheme.defaultOverlayBlur,
      movingAnimationDuration: GuidedTourAnimations.spotlightBreathingDuration,
      disableMovingAnimation: disableMovingAnimation ?? false,
      tooltipPosition: step.tooltipPosition,
      onBarrierClick: () => GuidedTourManager.instance.skip(),
      onTargetClick: step.onTargetClick,
      disposeOnTap: step.onTargetClick != null ? false : null,
      container: step.customWidget ??
          Obx(() {
            final mgr = GuidedTourManager.instance;
            final currentConfig = mgr.currentTourConfig.value;
            final currentIdx = mgr.currentStepIndex.value;
            final total = currentConfig?.stepCount ?? 1;

            return GuidedTourTooltip(
              step: step,
              currentStepIndex: currentIdx,
              totalSteps: total,
              onNext: mgr.next,
              onPrevious: mgr.previous,
              onSkip: mgr.skip,
              onFinish: mgr.finish,
            );
          }),
      child: child,
    );
  }
}
