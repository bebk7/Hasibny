import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/onboarding_controller.dart';
import '../../core/core.dart';
import '../home/home_view.dart';
import 'create_store_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final OnboardingController _controller = Get.find<OnboardingController>();

  Future<void> _handleImportBackup() async {
    HapticFeedback.lightImpact();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty || result.files.single.path == null) {
        return;
      }

      final filePath = result.files.single.path!;
      final file = File(filePath);

      // Validate file extension
      if (!filePath.toLowerCase().endsWith('.abbackup')) {
        Get.snackbar(
          'error'.tr,
          'backup_file_invalid_ext'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }

      if (!mounted) return;
      _showPasswordDialog(file);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void _showPasswordDialog(File backupFile) {
    final passwordCtrl = TextEditingController();
    bool obscure = true;
    final resp = AppResponsive.of(context);

    AppDialog.show(
      context: context,
      maxWidth: 420,
      child: StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(resp.spacingXS),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(resp.radiusSM),
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      color: const Color(0xFF00E5FF),
                      size: resp.iconSM,
                    ),
                  ),
                  SizedBox(width: resp.spacingSM),
                  Expanded(
                    child: Text(
                      'backup_password_prompt'.tr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: resp.fontLG,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: resp.spacingSM),
              Text(
                'backup_password_prompt_desc'.tr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: resp.fontXS,
                  color: Colors.grey[400],
                  height: 1.5,
                ),
              ),
              SizedBox(height: resp.spacingMD),
              TextField(
                controller: passwordCtrl,
                obscureText: obscure,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: resp.fontMD,
                ),
                decoration: InputDecoration(
                  hintText: 'password'.tr,
                  prefixIcon: Icon(Icons.password_rounded, size: resp.iconSM),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: resp.iconSM,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        obscure = !obscure;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: resp.spacingLG),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'cancel'.tr,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  SizedBox(width: resp.spacingSM),
                  Expanded(
                    child: AppButton(
                      text: 'confirm'.tr,
                      onPressed: () {
                        final password = passwordCtrl.text.trim();
                        if (password.isEmpty) {
                          Get.snackbar(
                            'error'.tr,
                            'backup_password_empty'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.error,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                          return;
                        }
                        Get.back();
                        _startRestore(backupFile, password);
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _startRestore(File backupFile, String password) async {
    // Show loading dialog
    AppDialog.show(
      context: context,
      barrierDismissible: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLoading(),
            const SizedBox(height: 16),
            Text(
              'restoring_backup_wait'.tr,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final summary = await _controller.restoreBackup(
        backupFile: backupFile,
        password: password,
      );

      // Dismiss loader
      if (Get.isDialogOpen ?? false) Get.back();

      // Show success
      Get.snackbar(
        'success'.tr,
        '${'backup_restore_success'.tr} (${summary.customersCount} عميل، ${summary.invoicesCount} فاتورة)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      // Navigate to normal application
      Get.offAll(() => const HomeView());
    } catch (e) {
      // Dismiss loader
      if (Get.isDialogOpen ?? false) Get.back();

      Get.snackbar(
        'error'.tr,
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final logoSize = resp.isSmall ? 88.0 : 104.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1315),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: AppPageContainer(
            maxWidth: 520,
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: resp.pagePadding,
                vertical: resp.spacingMD,
              ),
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: resp.spacingSM),

                  // App Logo Header with subtle glowing container
                  Center(
                    child: Container(
                      width: logoSize,
                      height: logoSize,
                      padding: EdgeInsets.all(resp.spacingSM + 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161C20),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                            blurRadius: 28,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.account_balance_wallet_rounded,
                          size: resp.iconLG + 6,
                          color: const Color(0xFF00E5FF),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: resp.spacingLG),

                  // Title
                  Text(
                    'onboarding_welcome_title'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w900,
                      fontSize: resp.fontXL,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),

                  SizedBox(height: resp.spacingXS),

                  // Description
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: resp.spacingMD),
                    child: Text(
                      'onboarding_welcome_desc'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: resp.fontSM,
                        color: Colors.white.withValues(alpha: 0.65),
                        height: 1.5,
                      ),
                    ),
                  ),

                  SizedBox(height: resp.spacingXL),

                  // Section Prompt
                  Text(
                    'choose_to_start'.tr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: resp.fontSM,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),

                  SizedBox(height: resp.spacingSM),

                  // Option 1: Create New Store
                  _OptionCard(
                    icon: Icons.add_business_rounded,
                    iconColor: const Color(0xFF00E5FF),
                    title: 'create_new_store'.tr,
                    description: 'create_store_desc'.tr,
                    isHighlighted: true,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.to(
                        () => const CreateStoreView(),
                        transition: Transition.cupertino,
                      );
                    },
                  ),

                  SizedBox(height: resp.spacingSM),

                  // Option 2: Restore Backup
                  _OptionCard(
                    icon: Icons.settings_backup_restore_rounded,
                    iconColor: const Color(0xFF38BDF8),
                    title: 'import_backup'.tr,
                    description: 'import_backup_desc'.tr,
                    isHighlighted: false,
                    onTap: _handleImportBackup,
                  ),

                  SizedBox(height: resp.spacingXL),

                  // Developer footer note
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'By ',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: resp.fontXS,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        Text(
                          'Labeeb Qaulisi',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: resp.fontXS,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00E5FF),
                          ),
                        ),
                        Text(
                          ' • @bebk7',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: resp.fontXS,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: resp.spacingSM),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161C20),
        borderRadius: BorderRadius.circular(resp.cardRadius),
        border: Border.all(
          color: isHighlighted
              ? const Color(0xFF00E5FF).withValues(alpha: 0.35)
              : const Color(0xFF2A343D),
          width: isHighlighted ? 1.5 : 1.0,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(resp.cardRadius),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(resp.spacingMD),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(resp.radiusSM),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: resp.iconMD,
                  ),
                ),
                SizedBox(width: resp.spacingSM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: resp.fontMD,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: resp.fontXS,
                          color: Colors.white.withValues(alpha: 0.6),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: resp.spacingXS),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: resp.iconXS,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
