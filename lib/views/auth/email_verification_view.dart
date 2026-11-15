import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/core.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  bool _canResend = true;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _resend() async {
    if (!_canResend) return;
    final ac = Get.find<AuthController>();
    final success = await ac.sendVerificationEmail();
    if (!mounted) return;

    if (success) {
      setState(() {
        _canResend = false;
        _resendCooldown = 60;
      });
      _cooldownTimer?.cancel();
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        setState(() {
          _resendCooldown--;
          if (_resendCooldown <= 0) {
            _canResend = true;
            t.cancel();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ac = Get.find<AuthController>();
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
        child: SafeArea(
          child: Center(
            child: AppPageContainer(
              maxWidth: 440,
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: resp.pagePadding,
                  vertical: resp.spacingMD,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Envelope glowing badge
                    Container(
                      width: resp.isSmall ? 72 : 84,
                      height: resp.isSmall ? 72 : 84,
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
                      child: Icon(
                        Icons.mark_email_unread_rounded,
                        color: Colors.white,
                        size: resp.isSmall ? 36 : 42,
                      ),
                    ),
                    SizedBox(height: resp.spacingMD),
                    Text(
                      'verify_email'.tr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: resp.font2XL,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: resp.spacingXS),
                    Obx(() => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: resp.spacingMD,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(resp.cardRadius),
                          ),
                          child: Text(
                            ac.userEmail,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white,
                              fontSize: resp.fontSM,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )),
                    SizedBox(height: resp.spacingSM),
                    Text(
                      'verify_email_hint'.tr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: resp.fontSM,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: resp.spacingLG),

                    // Verification Card
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(resp.cardRadius + 8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.35 : 0.18),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(resp.spacingMD + 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Check verification button
                          Obx(() => AppButton(
                                text: 'check_verified'.tr,
                                icon: Icons.check_circle_outline_rounded,
                                isLoading: ac.isCheckingVerification.value,
                                onPressed: ac.isCheckingVerification.value
                                    ? null
                                    : () => ac.checkEmailVerified(),
                              )),
                          SizedBox(height: resp.spacingSM),

                          // Resend button
                          AppButton(
                            text: _canResend
                                ? 'resend_verification'.tr
                                : '${'resend_cooldown'.tr} ${_resendCooldown}s',
                            icon: Icons.refresh_rounded,
                            variant: AppButtonVariant.outlined,
                            onPressed: _canResend ? _resend : null,
                          ),
                          SizedBox(height: resp.spacingMD),

                          Divider(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                          SizedBox(height: resp.spacingXS),

                          // Skip for now & continue offline
                          TextButton.icon(
                            onPressed: () async {
                              await ac.continueAsGuest();
                            },
                            icon: Icon(Icons.skip_next_rounded, size: resp.iconSM),
                            label: Text(
                              'skip_for_now'.tr,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: resp.fontSM,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Sign out link
                          TextButton.icon(
                            onPressed: () => ac.logout(),
                            icon: Icon(Icons.logout_rounded,
                                size: resp.iconXS, color: Colors.grey),
                            label: Text(
                              'back_to_login'.tr,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: resp.fontXS,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
