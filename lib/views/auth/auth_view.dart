import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/core.dart';
import '../home/home_view.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _storeNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isLogin = true;
  bool _obscure = true;
  bool _obscureConfirm = true;

  late AnimationController _bgAnimCtrl;
  late AnimationController _cardAnimCtrl;
  late Animation<double> _cardSlide;
  late Animation<double> _cardFade;

  @override
  void initState() {
    super.initState();
    _bgAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );

    _cardAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _cardAnimCtrl, curve: Curves.easeOutCubic),
    );
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardAnimCtrl, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _bgAnimCtrl.repeat();
        _cardAnimCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    _bgAnimCtrl.dispose();
    _cardAnimCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() {
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
    _cardAnimCtrl.reset();
    _formKey.currentState?.reset();
    setState(() => _isLogin = !_isLogin);
    _cardAnimCtrl.forward();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    final ac = Get.find<AuthController>();
    if (_isLogin) {
      await ac.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
    } else {
      await ac.register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        storeName: _storeNameCtrl.text.trim(),
      );
    }
  }

  void _forgotPassword() {
    FocusScope.of(context).unfocus();
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar(
        'error'.tr,
        'enter_email_first'.tr,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.find<AuthController>().resetPassword(email);
  }

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Animated Background mesh
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _bgAnimCtrl,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(
                              math.cos(_bgAnimCtrl.value * 2 * math.pi),
                              math.sin(_bgAnimCtrl.value * 2 * math.pi),
                            ),
                            end: Alignment(
                              -math.cos(_bgAnimCtrl.value * 2 * math.pi),
                              -math.sin(_bgAnimCtrl.value * 2 * math.pi),
                            ),
                            colors: isDark
                                ? [
                                    const Color(0xFF0B0F19),
                                    const Color(0xFF1E293B),
                                    const Color(0xFF0F172A),
                                  ]
                                : [
                                    AppColors.primary,
                                    const Color(0xFF1D4ED8),
                                    const Color(0xFF1E40AF),
                                  ],
                          ),
                        ),
                      );
                    },
                  ),
                  ...List.generate(
                      5, (i) => _FloatingShape(index: i, size: size)),
                ],
              ),
            ),
          ),

          // Main Interactive Content
          SafeArea(
            child: Center(
              child: AppPageContainer(
                maxWidth: 460,
                padding: EdgeInsets.zero,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: resp.pagePadding,
                    vertical: resp.spacingMD,
                  ),
                  child: AnimatedBuilder(
                    animation: _cardAnimCtrl,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _cardSlide.value),
                        child: Opacity(
                          opacity: _cardFade.value,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: resp.spacing2XS),
                        _buildLogo(context, resp),
                        SizedBox(height: resp.spacingLG),
                        _buildCard(context, resp),
                        SizedBox(height: resp.spacingMD),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context, AppResponsive resp) {
    final logoSize = resp.isShort ? 66.0 : (resp.isSmall ? 74.0 : 84.0);
    final iconSize = resp.isShort ? 30.0 : (resp.isSmall ? 34.0 : 40.0);

    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/hasibnyLogo.png',
                width: logoSize * 0.58,
                height: logoSize * 0.58,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: resp.isShort ? 6 : 10),
        Text(
          'app_title'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: resp.font2XL,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: resp.spacingMD, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(resp.cardRadius),
          ),
          child: Text(
            'auth_tagline'.tr,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: resp.fontXS,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, AppResponsive resp) {
    final ac = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(resp.cardRadius + 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.18),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(resp.cardRadius + 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Segmented Tab header
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.02),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildTab('login'.tr, _isLogin, () {
                    if (!_isLogin) _toggleMode();
                  }, resp),
                  _buildTab('register'.tr, !_isLogin, () {
                    if (_isLogin) _toggleMode();
                  }, resp),
                ],
              ),
            ),

            // Form Content
            Padding(
              padding: EdgeInsets.all(resp.spacingMD + 2),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isLogin ? 'login_subtitle'.tr : 'register_subtitle'.tr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: resp.fontSM,
                        color: Theme.of(context).hintColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: resp.spacingMD),

                    // Store Name (register only)
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _storeNameCtrl,
                        style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'store_name_required'.tr;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'store_name'.tr,
                          prefixIcon: Icon(Icons.storefront_rounded, size: resp.iconSM),
                        ),
                      ),
                      SizedBox(height: resp.spacingSM),
                    ],

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                      validator: (v) {
                        if (v == null || !v.contains('@')) {
                          return 'invalid_email'.tr;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'email_required'.tr,
                        prefixIcon: Icon(Icons.email_rounded, size: resp.iconSM),
                      ),
                    ),
                    SizedBox(height: resp.spacingSM),

                    // Password
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return 'password_min'.tr;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'password'.tr,
                        prefixIcon: Icon(Icons.lock_rounded, size: resp.iconSM),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            size: resp.iconSM,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),

                    // Confirm password (register only)
                    if (!_isLogin) ...[
                      SizedBox(height: resp.spacingSM),
                      TextFormField(
                        controller: _confirmPassCtrl,
                        obscureText: _obscureConfirm,
                        style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                        validator: (v) {
                          if (v != _passwordCtrl.text) {
                            return 'passwords_not_match'.tr;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'confirm_password'.tr,
                          prefixIcon: Icon(Icons.lock_outline_rounded, size: resp.iconSM),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              size: resp.iconSM,
                            ),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                      ),
                    ],

                    // Forgot password
                    if (_isLogin) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'forgot_password'.tr,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: AppColors.primary,
                              fontSize: resp.fontXS,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: resp.spacingMD),

                    // Submit button
                    Obx(() => AppButton(
                          text: _isLogin ? 'login'.tr : 'register'.tr,
                          icon: _isLogin
                              ? Icons.login_rounded
                              : Icons.person_add_rounded,
                          isLoading: ac.isLoading.value,
                          onPressed: ac.isLoading.value ? null : _submit,
                        )),
                    SizedBox(height: resp.spacingMD),

                    // Divider with 'or'
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: resp.spacingSM),
                          child: Text(
                            'or'.tr,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: resp.fontXS,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: resp.spacingSM),

                    // Continue as Guest button
                    AppButton(
                      text: 'continue_as_guest'.tr,
                      icon: Icons.person_outline_rounded,
                      variant: AppButtonVariant.outlined,
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        await ac.continueAsGuest();
                        if (context.mounted) {
                          if (Navigator.canPop(context)) {
                            Get.back();
                          } else {
                            Get.offAll(() => const HomeView());
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isActive, VoidCallback onTap, AppResponsive resp) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(vertical: resp.spacingSM + 2),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: resp.fontMD,
                color: isActive ? AppColors.primary : null,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingShape extends StatefulWidget {
  final int index;
  final Size size;
  const _FloatingShape({required this.index, required this.size});

  @override
  State<_FloatingShape> createState() => _FloatingShapeState();
}

class _FloatingShapeState extends State<_FloatingShape>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late double _startX, _startY, _shapeSize;
  late int _durationMs;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(widget.index);
    _startX = rng.nextDouble() * widget.size.width;
    _startY = rng.nextDouble() * widget.size.height;
    _shapeSize = 40 + rng.nextDouble() * 70;
    _durationMs = 9000 + rng.nextInt(7000);

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _durationMs),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final dx = math.sin(_ctrl.value * math.pi * 2) * 24;
        final dy = math.cos(_ctrl.value * math.pi * 2) * 24;
        return Positioned(
          left: _startX + dx,
          top: _startY + dy,
          child: Opacity(
            opacity: 0.07,
            child: Container(
              width: _shapeSize,
              height: _shapeSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  widget.index.isEven ? _shapeSize / 2 : _shapeSize / 4,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
