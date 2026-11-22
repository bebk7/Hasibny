import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';
import 'guided_tour_config.dart';
import 'guided_tour_storage.dart';

/// Elite Guided Tour Manager
/// Coordinates tour state, step navigation, persistent progress, and screen integration.
class GuidedTourManager extends GetxController {
  static GuidedTourManager? _instance;
  static GuidedTourManager get instance => _instance ??= GuidedTourManager._();

  GuidedTourManager._() {
    GuidedTourStorage.instance.init();
  }

  /// Storage engine
  final GuidedTourStorage storage = GuidedTourStorage.instance;

  /// Track pending delayed tour launch timers so they can be cancelled on dispose
  final Map<String, Timer> _pendingTimers = {};

  /// Currently active tour configuration
  final Rx<GuidedTourConfig?> currentTourConfig = Rx<GuidedTourConfig?>(null);

  /// Currently active step index within the active tour
  final RxInt currentStepIndex = 0.obs;

  /// Whether a tour is currently displaying on screen
  final RxBool isTourActive = false.obs;

  /// Active ShowcaseView instance
  ShowcaseView? activeShowcaseView;

  /// Automatically launches the tour if it's the user's first visit to the screen.
  /// Safe against disposed contexts and concurrent tour launches.
  Future<void> showIfFirstVisit(
    BuildContext context,
    GuidedTourConfig config, {
    Duration delay = const Duration(milliseconds: 650),
  }) async {
    if (!config.autoStartOnFirstVisit) return;
    if (!storage.isAutoToursEnabled.value) return;

    // Check persistence: if already seen (completed or skipped), do nothing
    final alreadySeen = await storage.hasTourBeenSeen(config.tourId);
    if (alreadySeen) return;

    // Post-frame delay to ensure UI has rendered and geometry is ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;
      if (isTourActive.value) return;

      final seen = await storage.hasTourBeenSeen(config.tourId);
      if (seen || !context.mounted) return;

      cancelPendingTour(config.tourId);

      // Immediately mark as seen so that if the app is closed or navigated, it won't re-trigger!
      await storage.markTourSeen(config.tourId);
      await storage.markGlobalTourSeen();

      if (delay == Duration.zero) {
        await startTour(context, config);
        return;
      }

      _pendingTimers[config.tourId] = Timer(delay, () async {
        _pendingTimers.remove(config.tourId);
        if (!context.mounted) return;
        if (isTourActive.value) return;
        final seenAfterDelay = await storage.hasTourBeenSeen(config.tourId);
        if (seenAfterDelay || !context.mounted) return;

        await startTour(context, config);
      });
    });
  }

  /// Cancels any scheduled timer for a tour (called on screen dispose)
  void cancelPendingTour(String tourId) {
    _pendingTimers[tourId]?.cancel();
    _pendingTimers.remove(tourId);
  }

  /// Cancels all pending tour timers
  void cancelAllPendingTours() {
    for (final timer in _pendingTimers.values) {
      timer.cancel();
    }
    _pendingTimers.clear();
  }

  /// Manually starts a tour with the provided configuration.
  Future<void> startTour(
    BuildContext context,
    GuidedTourConfig config, {
    bool force = false,
  }) async {
    if (isTourActive.value && !force) return;
    if (config.steps.isEmpty) return;

    currentTourConfig.value = config;
    currentStepIndex.value = 0;
    isTourActive.value = true;

    // Locate the ShowcaseView for this scope
    try {
      activeShowcaseView = ShowcaseView.getNamed(config.scope);
    } catch (_) {
      try {
        activeShowcaseView = ShowcaseView.get();
      } catch (_) {
        activeShowcaseView = null;
      }
    }

    if (activeShowcaseView != null) {
      activeShowcaseView!.startShowCase(config.stepKeys);
      config.onStepChange?.call(0, config.steps[0]);
    }
  }

  /// Advances to the next step or finishes if on the final step.
  void next() {
    final config = currentTourConfig.value;
    if (config == null) return;

    if (currentStepIndex.value < config.stepCount - 1) {
      currentStepIndex.value++;
      activeShowcaseView?.next();
      config.onStepChange?.call(currentStepIndex.value, config.steps[currentStepIndex.value]);
    } else {
      finish();
    }
  }

  /// Navigates to the previous step if available.
  void previous() {
    final config = currentTourConfig.value;
    if (config == null) return;

    if (currentStepIndex.value > 0) {
      currentStepIndex.value--;
      activeShowcaseView?.previous();
      config.onStepChange?.call(currentStepIndex.value, config.steps[currentStepIndex.value]);
    }
  }

  /// Skips / dismisses the current tour and marks it as skipped in storage.
  Future<void> skip() async {
    final config = currentTourConfig.value;
    if (config != null) {
      await storage.markTourSkipped(config.tourId);
      config.onDismiss?.call();
    }
    await storage.markGlobalTourSeen();
    activeShowcaseView?.dismiss();
    _cleanup();
  }

  /// Completes the tour, invokes finish callbacks, and marks completed in storage.
  Future<void> finish() async {
    final config = currentTourConfig.value;
    if (config != null) {
      await storage.markTourCompleted(config.tourId);
      config.onFinish?.call();
    }
    await storage.markGlobalTourSeen();
    activeShowcaseView?.dismiss();
    _cleanup();
  }

  /// Force replays a tour by resetting its persistent status and starting immediately.
  Future<void> replayTour(BuildContext context, GuidedTourConfig config) async {
    await storage.resetTour(config.tourId);
    if (!context.mounted) return;
    await startTour(context, config, force: true);
  }

  /// Resets a specific tour's persistent completion state.
  Future<void> resetTour(String tourId) async {
    await storage.resetTour(tourId);
  }

  /// Resets all tours across the entire application.
  Future<void> resetAllTours() async {
    await storage.resetAllTours();
  }

  /// Synchronizes step index from ShowcaseView event callbacks
  void handleShowcaseStart(int? index, GlobalKey key) {
    if (index != null && index >= 0) {
      currentStepIndex.value = index;
      final config = currentTourConfig.value;
      if (config != null && index < config.stepCount) {
        config.onStepChange?.call(index, config.steps[index]);
      }
    }
  }

  /// Handles internal showcase completion
  void handleShowcaseFinish() {
    final config = currentTourConfig.value;
    if (config != null) {
      storage.markTourCompleted(config.tourId);
      config.onFinish?.call();
    }
    storage.markGlobalTourSeen();
    _cleanup();
  }

  /// Handles internal showcase dismissal (e.g. barrier click)
  void handleShowcaseDismiss(GlobalKey? dismissedAt) {
    final config = currentTourConfig.value;
    if (config != null) {
      storage.markTourSkipped(config.tourId);
      config.onDismiss?.call();
    }
    storage.markGlobalTourSeen();
    _cleanup();
  }

  void _cleanup() {
    isTourActive.value = false;
    currentTourConfig.value = null;
    currentStepIndex.value = 0;
  }
}
