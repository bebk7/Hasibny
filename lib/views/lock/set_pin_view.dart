import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/lock_controller.dart';
import '../../core/core.dart';

class SetPinView extends StatefulWidget {
  const SetPinView({super.key});

  @override
  State<SetPinView> createState() => _SetPinViewState();
}

class _SetPinViewState extends State<SetPinView>
    with SingleTickerProviderStateMixin {
  final LockController _lc = Get.find<LockController>();
  final List<String> _pin = [];
  final List<String> _confirm = [];
  bool _confirming = false;
  bool _hasError = false;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onKey(String key) {
    final current = _confirming ? _confirm : _pin;
    if (current.length >= 4) return;
    HapticFeedback.selectionClick();
    setState(() {
      current.add(key);
      _hasError = false;
    });
    if (current.length == 4) {
      if (!_confirming) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _confirming = true);
        });
      } else {
        _checkMatch();
      }
    }
  }

  void _onDelete() {
    final current = _confirming ? _confirm : _pin;
    if (current.isEmpty) {
      if (_confirming) {
        setState(() {
          _confirming = false;
          _confirm.clear();
        });
      }
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      current.removeLast();
      _hasError = false;
    });
  }

  Future<void> _checkMatch() async {
    if (_pin.join() == _confirm.join()) {
      await _lc.setPin(_pin.join());
      Get.back();
      Get.snackbar(
        'success'.tr,
        'pin_set_success'.tr,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0.0);
      setState(() {
        _hasError = true;
        _confirm.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final current = _confirming ? _confirm : _pin;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: AppAppBarTitle('set_pin'.tr),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isShort = constraints.maxHeight < 680;
            final keySize = (isShort ? 58.0 : 70.0).clamp(48.0, 72.0);
            final iconContainerSize = isShort ? 58.0 : 70.0;

            return Center(
              child: AppPageContainer(
                maxWidth: 380,
                padding: EdgeInsets.zero,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxWidth: 380,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: resp.spacingLG,
                        vertical: resp.spacingMD,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon indicator
                          Container(
                            width: iconContainerSize,
                            height: iconContainerSize,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _confirming
                                  ? Icons.verified_user_rounded
                                  : Icons.pin_rounded,
                              size: isShort ? 26 : 32,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: isShort ? resp.spacingSM : resp.spacingMD),
                          Text(
                            _confirming
                                ? 'confirm_pin'.tr
                                : 'enter_new_pin'.tr,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: isShort ? resp.fontXL : resp.font2XL,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: resp.spacing2XS),
                          Text(
                            _confirming
                                ? 're_enter_pin_hint'.tr
                                : 'choose_pin_hint'.tr,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: resp.fontSM,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          SizedBox(height: isShort ? resp.spacingMD : resp.spacingXL),

                          // PIN dots
                          AnimatedBuilder(
                            animation: _shakeAnim,
                            builder: (context, child) => Transform.translate(
                              offset: Offset(_shakeAnim.value, 0),
                              child: child,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (i) {
                                final filled = i < current.length;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin: EdgeInsets.symmetric(horizontal: resp.spacingSM),
                                  width: filled ? 18 : 14,
                                  height: filled ? 18 : 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _hasError
                                        ? AppColors.give
                                        : (filled
                                            ? AppColors.primary
                                            : Colors.transparent),
                                    border: Border.all(
                                      color: _hasError
                                          ? AppColors.give
                                          : (filled
                                              ? AppColors.primary
                                              : (isDark
                                                  ? Colors.grey[600]!
                                                  : Colors.grey[400]!)),
                                      width: 2,
                                    ),
                                    boxShadow: filled && !_hasError
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                );
                              }),
                            ),
                          ),
                          if (_hasError) ...[
                            SizedBox(height: resp.spacingSM),
                            Text(
                              'pin_mismatch'.tr,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.give,
                                fontSize: resp.fontSM,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          SizedBox(height: isShort ? resp.spacingLG : resp.spacingXL),

                          // Numpad
                          _buildNumpad(keySize, isShort, resp),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNumpad(double keySize, bool isShort, AppResponsive resp) {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', 'del'],
        ])
          Padding(
            padding: EdgeInsets.symmetric(vertical: isShort ? 3 : 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row
                  .map((k) => _buildKey(k, keySize, isShort, resp))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildKey(String key, double keySize, bool isShort, AppResponsive resp) {
    if (key.isEmpty) {
      return SizedBox(width: keySize, height: keySize);
    }
    if (key == 'del') {
      return _KeyButton(
        size: keySize,
        onTap: _onDelete,
        child: Icon(Icons.backspace_outlined, size: resp.iconSM),
      );
    }
    return _KeyButton(
      size: keySize,
      onTap: () => _onKey(key),
      child: Text(
        key,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: isShort ? resp.fontXL : resp.font2XL,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _KeyButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final double size;

  const _KeyButton({
    required this.onTap,
    required this.child,
    required this.size,
  });

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _pressed
                ? AppColors.primary.withValues(alpha: 0.15)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03)),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}
