import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../themes/app_theme.dart';

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
      duration: const Duration(seconds: 20),
    );

    _cardAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardSlide = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _cardAnimCtrl, curve: Curves.easeOutCubic),
    );
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardAnimCtrl, curve: Curves.easeOut),
    );

    // Defer heavy animations to after first frame
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
    _cardAnimCtrl.reset();
    setState(() => _isLogin = !_isLogin);
    _cardAnimCtrl.forward();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    final ac = Get.find<AuthController>();
    if (_isLogin) {
      final success = await ac.login(email: _emailCtrl.text, password: _passwordCtrl.text);
      if (success && mounted && Navigator.canPop(context)) {
        Get.back();
      }
    } else {
      final success = await ac.register(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        storeName: _storeNameCtrl.text.trim(),
      );
      if (success && mounted && Navigator.canPop(context)) {
        Get.back();
      }
    }
  }

  void _forgotPassword() {
    if (_emailCtrl.text.trim().isEmpty) {
      Get.snackbar('error'.tr, 'enter_email_first'.tr,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.find<AuthController>().resetPassword(_emailCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: Navigator.canPop(context)
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            )
          : null,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
          // Animated gradient background
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
                            const Color(0xFF0D1B2A),
                            const Color(0xFF1B263B),
                            const Color(0xFF0D1B2A),
                          ]
                        : [
                            AppTheme.primaryColor,
                            const Color(0xFF1565C0),
                            const Color(0xFF0D47A1),
                          ],
                  ),
                ),
              );
            },
          ),

          // Floating shapes
          ...List.generate(6, (i) => _FloatingShape(index: i, size: size)),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28),
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
                    children: [
                      const SizedBox(height: 40),
                      _buildLogo(),
                      const SizedBox(height: 40),
                      _buildCard(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
              Image.asset(
                'assets/images/logo.png',
                width: 56,
                height: 56,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'app_title'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            shadows: [
              Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'auth_tagline'.tr,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    final ac = Get.find<AuthController>();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            // Tab header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                    AppTheme.primaryColor.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Row(
                children: [
                  _buildTab('login'.tr, _isLogin, () {
                    if (!_isLogin) _toggleMode();
                  }),
                  _buildTab('register'.tr, !_isLogin, () {
                    if (_isLogin) _toggleMode();
                  }),
                ],
              ),
            ),

            // Form
            Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isLogin ? 'login_subtitle'.tr : 'register_subtitle'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Store Name (register only)
                    if (!_isLogin) ...[
                      _buildTextField(
                        controller: _storeNameCtrl,
                        label: 'store_name'.tr,
                        icon: Icons.storefront_rounded,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'store_name_required'.tr;
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Email
                    _buildTextField(
                      controller: _emailCtrl,
                      label: 'email'.tr,
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'email_required'.tr;
                        if (!v.contains('@')) return 'invalid_email'.tr;
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Password
                    _buildTextField(
                      controller: _passwordCtrl,
                      label: 'password'.tr,
                      icon: Icons.lock_rounded,
                      obscure: _obscure,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: Theme.of(context).hintColor,
                          size: 22,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'password_required'.tr;
                        if (v.length < 6) return 'password_min'.tr;
                        return null;
                      },
                    ),

                    // Confirm password (register only)
                    if (!_isLogin) ...[
                      const SizedBox(height: 18),
                      _buildTextField(
                        controller: _confirmPassCtrl,
                        label: 'confirm_password'.tr,
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscureConfirm,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                            color: Theme.of(context).hintColor,
                            size: 22,
                          ),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        validator: (v) {
                          if (v != _passwordCtrl.text) return 'passwords_not_match'.tr;
                          return null;
                        },
                      ),
                    ],

                    // Forgot password
                    if (_isLogin) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'forgot_password'.tr,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Submit button
                    Obx(() => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 54,
                          child: ElevatedButton(
                            onPressed: ac.isLoading.value ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: ac.isLoading.value ? 0 : 4,
                              shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
                            ),
                            child: ac.isLoading.value
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isLogin ? Icons.login_rounded : Icons.person_add_rounded,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _isLogin ? 'login'.tr : 'register'.tr,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppTheme.primaryColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? AppTheme.primaryColor : Theme.of(Get.context!).hintColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 4),
          child: Icon(icon, size: 22, color: AppTheme.primaryColor.withValues(alpha: 0.7)),
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    _shapeSize = 40 + rng.nextDouble() * 80;
    _durationMs = 8000 + rng.nextInt(8000);

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _durationMs),
    );

    // Defer animation start
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
        final dx = math.sin(_ctrl.value * math.pi * 2) * 30;
        final dy = math.cos(_ctrl.value * math.pi * 2) * 30;
        return Positioned(
          left: _startX + dx,
          top: _startY + dy,
          child: Opacity(
            opacity: 0.08,
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
