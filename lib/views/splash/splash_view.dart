import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/core.dart';
import '../../themes/app_theme.dart';

/// A premium, animated splash screen for the Hasibny (دفتر الحسابات) app.
///
/// Displays a coordinated animation sequence:
/// 1. Logo fades in + scales up (85% → 100%) with a subtle glow
/// 2. App name fades in + slides up
/// 3. Tagline fades in + slides up
/// 4. Loading indicator appears
///
/// The [onInitialize] future controls when the splash transitions out.
/// When initialization completes, the splash plays an exit animation
/// and calls [onComplete].
class SplashView extends StatefulWidget {
  /// A future that resolves when app initialization is complete.
  /// If null, the splash will animate but never auto-dismiss.
  final Future<void> Function()? onInitialize;

  /// Called when the splash animation sequence is done AND initialization
  /// has completed. The parent should navigate away in this callback.
  final VoidCallback? onComplete;

  /// Called if initialization throws an error.
  final void Function(Object error, StackTrace stack)? onError;

  const SplashView({
    super.key,
    this.onInitialize,
    this.onComplete,
    this.onError,
  });

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  // ── Animation controllers ──
  late final AnimationController _logoController;
  late final AnimationController _titleController;
  late final AnimationController _taglineController;
  late final AnimationController _loaderController;
  late final AnimationController _exitController;
  late final AnimationController _shimmerController;

  // ── Animations ──
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoGlowOpacity;

  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;

  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;

  late final Animation<double> _loaderFade;

  late final Animation<double> _exitFade;

  late final Animation<double> _shimmerPosition;

  bool _hasError = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    // Check for reduced motion preference
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures;
    _reduceMotion = platformBrightness.reduceMotion;

    final fast = _reduceMotion;

    // ── Logo: 700ms fade+scale ──
    _logoController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: fast ? 100 : 700),
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutCubic,
      ),
    );
    _logoGlowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Title: 400ms fade+slide ──
    _titleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: fast ? 100 : 400),
    );
    _titleFade = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOut,
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutCubic,
    ));

    // ── Tagline: 350ms fade+slide ──
    _taglineController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: fast ? 100 : 350),
    );
    _taglineFade = CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeOut,
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeOutCubic,
    ));

    // ── Loader: 300ms fade ──
    _loaderController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: fast ? 100 : 300),
    );
    _loaderFade = CurvedAnimation(
      parent: _loaderController,
      curve: Curves.easeOut,
    );

    // ── Exit: 350ms fade out ──
    _exitController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: fast ? 50 : 350),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeIn,
      ),
    );

    // ── Shimmer on logo container: continuous subtle shine ──
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _shimmerPosition = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _startSequence() async {
    // Small delay to let the widget mount and first frame render,
    // ensuring smooth transition from native splash.
    if (!_reduceMotion) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted) return;

    // Start logo animation
    _logoController.forward();

    // After logo starts appearing, start the title
    await Future.delayed(Duration(milliseconds: _reduceMotion ? 50 : 350));
    if (!mounted) return;
    _titleController.forward();

    // After title starts, start tagline
    await Future.delayed(Duration(milliseconds: _reduceMotion ? 50 : 250));
    if (!mounted) return;
    _taglineController.forward();

    // After tagline, show loader
    await Future.delayed(Duration(milliseconds: _reduceMotion ? 50 : 200));
    if (!mounted) return;
    _loaderController.forward();

    // Start subtle shimmer on the logo
    if (!_reduceMotion) {
      _shimmerController.repeat();
    }

    // Run initialization
    _runInitialization();
  }

  Future<void> _runInitialization() async {
    if (widget.onInitialize == null) return;

    try {
      await widget.onInitialize!();
      if (!mounted) return;
      _performExit();
    } catch (e, stack) {
      if (!mounted) return;
      setState(() => _hasError = true);
      widget.onError?.call(e, stack);
    }
  }

  void _performExit() {
    // Stop shimmer
    _shimmerController.stop();

    // Play exit animation then call onComplete
    _exitController.forward().then((_) {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _titleController.dispose();
    _taglineController.dispose();
    _loaderController.dispose();
    _exitController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Force immersive system UI on the splash
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1E3A8A),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;

    // Responsive sizing
    final logoContainerSize = (shortestSide * 0.28).clamp(80.0, 140.0);
    final logoPadding = (logoContainerSize * 0.18).clamp(12.0, 24.0);
    final titleFontSize = (shortestSide * 0.065).clamp(20.0, 32.0);
    final brandFontSize = (shortestSide * 0.038).clamp(12.0, 18.0);
    final taglineFontSize = (shortestSide * 0.032).clamp(11.0, 15.0);
    final gapAfterLogo = (size.height * 0.025).clamp(16.0, 32.0);
    final gapAfterTitle = (size.height * 0.006).clamp(4.0, 10.0);
    final gapAfterBrand = (size.height * 0.015).clamp(8.0, 20.0);
    final loaderSize = (shortestSide * 0.055).clamp(20.0, 28.0);

    return AnimatedBuilder(
      animation: _exitFade,
      builder: (context, child) => Opacity(
        opacity: _exitFade.value,
        child: child,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F1B3D), // Deeper navy at top
                Color(0xFF1E3A8A), // Hero gradient start
                Color(0xFF2563EB), // Primary blue
                Color(0xFF3B82F6), // Lighter blue at bottom
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Use a Column with flexible spacing instead of
                // hardcoded heights — this prevents overflow on
                // short screens and stays centered on tall ones.
                return Column(
                  children: [
                    // Top flexible space (takes ~35% of available)
                    Flexible(flex: 35, child: Container()),

                    // ── Logo ──
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _logoController,
                        _shimmerController,
                      ]),
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: _buildLogoContainer(
                              logoContainerSize,
                              logoPadding,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: gapAfterLogo),

                    // ── App Name (Arabic) ──
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleFade,
                        child: Text(
                          ' حاسبني ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.white,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: gapAfterTitle),

                    // ── Brand Name (English) ──
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleFade,
                        child: Text(
                          'HASIBNY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: brandFontSize,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3.0,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: gapAfterBrand),

                    // ── Tagline ──
                    SlideTransition(
                      position: _taglineSlide,
                      child: FadeTransition(
                        opacity: _taglineFade,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'إدارة حساباتك بذكاء وسهولة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: taglineFontSize,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom flexible space (takes ~30% of available)
                    Flexible(flex: 30, child: Container()),

                    // ── Loading Indicator / Error ──
                    FadeTransition(
                      opacity: _loaderFade,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: (size.height * 0.04).clamp(16.0, 40.0),
                        ),
                        child: _hasError
                            ? _buildErrorIndicator(taglineFontSize)
                            : SizedBox(
                                width: loaderSize,
                                height: loaderSize,
                                child: CircularProgressIndicator(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  strokeWidth: 2.0,
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoContainer(double containerSize, double padding) {
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          // Outer ambient shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
          // Primary color glow – fades in with logo
          BoxShadow(
            color: AppTheme.primaryColor
                .withValues(alpha: 0.25 * _logoGlowOpacity.value),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          children: [
            // Logo image
            Padding(
              padding: EdgeInsets.all(padding),
              child: Image.asset(
                'assets/images/hasibnyLogo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppTheme.primaryColor,
                  size: containerSize * 0.45,
                ),
              ),
            ),
            // Subtle shimmer overlay (only if not reduce motion)
            if (!_reduceMotion)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shimmerPosition,
                  builder: (context, _) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                          stops: [
                            (_shimmerPosition.value - 0.3).clamp(0.0, 1.0),
                            _shimmerPosition.value.clamp(0.0, 1.0),
                            (_shimmerPosition.value + 0.3).clamp(0.0, 1.0),
                          ],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Container(color: Colors.white),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIndicator(double fontSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: Colors.white.withValues(alpha: 0.7),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          'حدث خطأ أثناء التحميل',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() => _hasError = false);
            _runInitialization();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'إعادة المحاولة',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
