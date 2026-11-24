import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/lock_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../core/core.dart';
import '../../services/backup_service.dart';
import '../../services/export_service.dart';
import '../auth/auth_view.dart';
import '../lock/set_pin_view.dart';
import 'store_profile_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    GuidedTourManager.instance.cancelPendingTour(AppTours.settingsTourId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    final resp = AppResponsive.of(context);

    return Scaffold(
      appBar: AppBar(
        title: AppAppBarTitle('settings'.tr),
      ),
      body: AppPageContainer(
        maxWidth: 680,
        padding: EdgeInsets.zero,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            resp.pagePadding,
            resp.spacingSM,
            resp.pagePadding,
            resp.pagePadding + resp.bottomInset,
          ),
          children: [
            // Store Profile Section
            _buildSectionHeader(
              title: 'store_profile'.tr,
              icon: Icons.storefront_rounded,
              resp: resp,
            ),
            GuidedTourTarget(
              step: AppTours.buildSettingsTour().steps[0],
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Obx(() => _buildTile(
                      context: context,
                      icon: Icons.store_rounded,
                      color: AppColors.primary,
                      title: settingsController.storeName.value.isEmpty
                          ? 'store_profile'.tr
                          : settingsController.storeName.value,
                      subtitle: settingsController.storeName.value.isEmpty
                          ? 'store_profile_sub'.tr
                          : settingsController.storePhone.value.isEmpty
                              ? 'store_profile_sub'.tr
                              : '\u200E${settingsController.storePhone.value}',
                      trailing: Icon(resp.forwardIcon,
                          size: resp.iconSM, color: Colors.grey),
                      onTap: () => Get.to(() => const StoreProfileView()),
                      resp: resp,
                    )),
              ),
            ),
            SizedBox(height: resp.spacingMD),

            // App Settings Section
            _buildSectionHeader(
              title: 'app_settings'.tr,
              icon: Icons.tune_rounded,
              resp: resp,
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildTile(
                    context: context,
                    icon: Icons.language_rounded,
                    color: const Color(0xFF3B82F6),
                    title: 'language'.tr,
                    subtitle: 'language_sub'.tr,
                    trailing: Obx(() => Switch.adaptive(
                          value: settingsController.isArabic,
                          activeTrackColor: AppColors.primary,
                          onChanged: (_) => settingsController.toggleLanguage(),
                        )),
                    resp: resp,
                  ),
                  _buildDivider(context),
                  Obx(() => _buildTile(
                        context: context,
                        icon: Icons.currency_exchange_rounded,
                        color: AppColors.warning,
                        title: 'currency'.tr,
                        subtitle: settingsController.currencyLabel,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: resp.spacingSM,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(resp.radiusSM),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  settingsController.currentCurrency.value,
                                  style: TextStyle(
                                    fontSize: resp.fontXS,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: resp.spacing2XS),
                            Icon(resp.forwardIcon,
                                size: resp.iconSM - 2, color: Colors.grey),
                          ],
                        ),
                        onTap: () => _showCurrencyDialog(context),
                        resp: resp,
                      )),
                  _buildDivider(context),
                  Obx(() => _buildTile(
                        context: context,
                        icon: Icons.pin_outlined,
                        color: const Color(0xFF10B981),
                        title: 'number_format'.tr,
                        subtitle: settingsController.numberFormatLabel,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: resp.spacingSM,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(resp.radiusSM),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  SettingsController.numberFormats.firstWhere(
                                    (opt) => opt.code == settingsController.currentNumberFormat.value,
                                    orElse: () => SettingsController.numberFormats.first,
                                  ).preview,
                                  style: TextStyle(
                                    fontSize: resp.fontXS,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: resp.spacing2XS),
                            Icon(resp.forwardIcon,
                                size: resp.iconSM - 2, color: Colors.grey),
                          ],
                        ),
                        onTap: () => _showNumberFormatSheet(context),
                        resp: resp,
                      )),
                  _buildDivider(context),
                  Obx(() => _buildTile(
                        context: context,
                        icon: Icons.dark_mode_rounded,
                        color: const Color(0xFF8B5CF6),
                        title: 'dark_mode'.tr,
                        subtitle: 'dark_mode_sub'.tr,
                        trailing: Switch.adaptive(
                          value: settingsController.isDarkMode.value,
                          activeTrackColor: AppColors.primary,
                          onChanged: (_) => settingsController.toggleDarkMode(),
                        ),
                        resp: resp,
                      )),
                  _buildDivider(context),
                  Obx(() => _buildTile(
                        context: context,
                        icon: Icons.chat_bubble_rounded,
                        color: const Color(0xFF25D366),
                        title: 'enable_whatsapp_invoices'.tr,
                        subtitle: 'enable_whatsapp_invoices_desc'.tr,
                        trailing: Switch.adaptive(
                          value: settingsController.enableWhatsAppInvoices.value,
                          activeTrackColor: const Color(0xFF25D366),
                          onChanged: (val) =>
                              settingsController.setEnableWhatsAppInvoices(val),
                        ),
                        resp: resp,
                      )),
                  _buildDivider(context),
                  GuidedTourTarget(
                    step: AppTours.buildSettingsTour().steps[2],
                    child: _buildTile(
                      context: context,
                      icon: Icons.lock_person_rounded,
                      color: AppColors.success,
                      title: 'app_lock'.tr,
                      subtitle: 'app_lock_sub'.tr,
                      trailing: Icon(resp.forwardIcon,
                          size: resp.iconSM, color: Colors.grey),
                      onTap: () => _showAppLockDialog(context),
                      resp: resp,
                    ),
                  ),
                  _buildDivider(context),
                  GuidedTourTarget(
                    step: AppTours.buildSettingsTour().steps[3],
                    child: _buildTile(
                      context: context,
                      icon: Icons.help_outline_rounded,
                      color: const Color(0xFF8B5CF6),
                      title: 'tour_replay_title'.tr,
                      subtitle: 'tour_replay_subtitle'.tr,
                      trailing: Icon(resp.forwardIcon,
                          size: resp.iconSM, color: Colors.grey),
                      onTap: () => _showGuidedToursSheet(context),
                      resp: resp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: resp.spacingMD),

            // Data Management Section
            _buildSectionHeader(
              title: 'data_management'.tr,
              icon: Icons.storage_rounded,
              resp: resp,
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  GuidedTourTarget(
                    step: AppTours.buildSettingsTour().steps[1],
                    child: _buildTile(
                      context: context,
                      icon: Icons.security_rounded,
                      color: const Color(0xFF6366F1),
                      title: 'backup_restore_title'.tr,
                      subtitle: 'export_backup'.tr,
                      trailing: Icon(resp.forwardIcon,
                          size: resp.iconSM, color: Colors.grey),
                      onTap: () => _showBackupDialog(context),
                      resp: resp,
                    ),
                  ),
                  _buildDivider(context),
                  _buildTile(
                    context: context,
                    icon: Icons.visibility_rounded,
                    color: const Color(0xFF0EA5E9),
                    title: 'preview_pdf'.tr,
                    subtitle: 'preview_report_desc'.tr,
                    trailing: Icon(resp.forwardIcon,
                        size: resp.iconSM, color: Colors.grey),
                    onTap: () => _previewPDF(),
                    resp: resp,
                  ),
                  _buildDivider(context),
                  _buildTile(
                    context: context,
                    icon: Icons.picture_as_pdf_rounded,
                    color: AppColors.error,
                    title: 'export_pdf'.tr,
                    subtitle: 'export_pdf_sub'.tr,
                    trailing: Icon(resp.forwardIcon,
                        size: resp.iconSM, color: Colors.grey),
                    onTap: () => _exportToPDF(),
                    resp: resp,
                  ),
                  _buildDivider(context),
                  _buildTile(
                    context: context,
                    icon: Icons.table_chart_rounded,
                    color: const Color(0xFF0D9488),
                    title: 'preview_excel'.tr,
                    subtitle: 'preview_report_desc'.tr,
                    trailing: Icon(resp.forwardIcon,
                        size: resp.iconSM, color: Colors.grey),
                    onTap: () => _previewExcel(),
                    resp: resp,
                  ),
                  _buildDivider(context),
                  _buildTile(
                    context: context,
                    icon: Icons.grid_on_rounded,
                    color: AppColors.success,
                    title: 'export_excel'.tr,
                    subtitle: 'export_excel_sub'.tr,
                    trailing: Icon(resp.forwardIcon,
                        size: resp.iconSM, color: Colors.grey),
                    onTap: () => _exportToExcel(),
                    resp: resp,
                  ),
                ],
              ),
            ),
            SizedBox(height: resp.spacingMD),

            // Account Section
            _buildSectionHeader(
              title: 'account_section'.tr,
              icon: Icons.account_circle_rounded,
              resp: resp,
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Obx(() {
                final ac = Get.find<AuthController>();
                if (!ac.isLoggedIn) {
                  return Column(
                    children: [
                      _buildTile(
                        context: context,
                        icon: Icons.cloud_sync_outlined,
                        color: AppColors.primary,
                        title: 'guest_account'.tr,
                        subtitle: 'sign_in_backup_desc'.tr,
                        trailing: Icon(resp.forwardIcon,
                            size: resp.iconSM, color: Colors.grey),
                        onTap: () => Get.to(() => const AuthView()),
                        resp: resp,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          resp.spacingMD,
                          0,
                          resp.spacingMD,
                          resp.spacingSM + 2,
                        ),
                        child: AppButton(
                          text: 'sign_in_to_backup'.tr,
                          icon: Icons.login_rounded,
                          onPressed: () => Get.to(() => const AuthView()),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildTile(
                      context: context,
                      icon: Icons.verified_user_rounded,
                      color: AppColors.success,
                      title: 'logged_in_as'.tr,
                      subtitle: ac.userEmail,
                      resp: resp,
                    ),
                    _buildDivider(context),
                    _buildTile(
                      context: context,
                      icon: Icons.logout_rounded,
                      color: AppColors.give,
                      title: 'logout'.tr,
                      trailing: Icon(Icons.logout_rounded,
                          color: AppColors.give, size: resp.iconSM),
                      onTap: () => _showLogoutDialog(context),
                      resp: resp,
                    ),
                  ],
                );
              }),
            ),
            SizedBox(height: resp.spacingMD),

            // About Section
            _buildSectionHeader(
              title: 'about'.tr,
              icon: Icons.info_outline_rounded,
              resp: resp,
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildTile(
                    context: context,
                    icon: Icons.info_rounded,
                    color: Colors.blueGrey,
                    title: 'app_version'.tr,
                    subtitle: '1.0.0',
                    resp: resp,
                  ),
                  _buildDivider(context),
                  _buildTile(
                    context: context,
                    icon: Icons.support_agent_rounded,
                    color: const Color(0xFF06B6D4),
                    title: 'help_support'.tr,
                    trailing: Icon(resp.forwardIcon,
                        size: resp.iconSM, color: Colors.grey),
                    onTap: () => _showHelpDialog(context),
                    resp: resp,
                  ),
                  _buildDivider(context),
                  _buildTile(
                    context: context,
                    icon: Icons.gpp_maybe_rounded,
                    color: AppColors.warning,
                    title: 'privacy_policy'.tr,
                    trailing: Icon(resp.forwardIcon,
                        size: resp.iconSM, color: Colors.grey),
                    onTap: () => _showPrivacyDialog(context),
                    resp: resp,
                  ),
                ],
              ),
            ),
            SizedBox(height: resp.spacingMD),

            // Danger Zone
            _buildDangerZone(context, resp),
            SizedBox(height: resp.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required AppResponsive resp,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: resp.spacing2XS,
        right: resp.spacing2XS,
        bottom: resp.spacingSM,
        top: resp.spacing2XS,
      ),
      child: Row(
        children: [
          Icon(icon,
              size: resp.iconXS, color: AppColors.primary.withValues(alpha: 0.8)),
          SizedBox(width: resp.spacingSM),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: resp.fontSM,
                fontWeight: FontWeight.bold,
                color: AppColors.primary.withValues(alpha: 0.9),
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      indent: 64,
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.05),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required AppResponsive resp,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: resp.spacingMD,
        vertical: 3,
      ),
      leading: Container(
        padding: EdgeInsets.all(resp.spacingXS),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(resp.radiusSM),
        ),
        child: Icon(icon, color: color, size: resp.iconSM),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w600,
          fontSize: resp.fontMD,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: resp.fontXS,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: trailing,
    );
  }

  Widget _buildDangerZone(BuildContext context, AppResponsive resp) {
    return AppCard(
      padding: EdgeInsets.zero,
      border: Border.all(color: AppColors.give.withValues(alpha: 0.3)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(resp.spacingXS),
          decoration: BoxDecoration(
            color: AppColors.give.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(resp.radiusSM),
          ),
          child: Icon(Icons.delete_forever_rounded,
              color: AppColors.give, size: resp.iconSM),
        ),
        title: Text(
          'clear_all_data'.tr,
          style: TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.give,
            fontWeight: FontWeight.bold,
            fontSize: resp.fontMD,
          ),
        ),
        subtitle: Text(
          'clear_data_sub'.tr,
          style: TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.give.withValues(alpha: 0.8),
            fontSize: resp.fontXS,
          ),
        ),
        onTap: () => _showClearDataDialog(context),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    final resp = AppResponsive.of(context);

    AppBottomSheet.show(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'select_currency'.tr,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: resp.fontLG,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: resp.spacingMD),
          ...SettingsController.currencies.map((currency) => Obx(() {
                final isSelected =
                    settingsController.currentCurrency.value == currency.code;
                return Padding(
                  padding: EdgeInsets.only(bottom: resp.spacing2XS),
                  child: Material(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(resp.cardRadius * 0.75),
                    child: ListTile(
                      title: Text(
                        currency.label,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? AppColors.primary : null,
                          fontSize: resp.fontMD,
                        ),
                      ),
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: isSelected ? AppColors.primary : Colors.grey,
                        size: resp.iconSM,
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_rounded,
                              color: AppColors.primary, size: resp.iconSM)
                          : null,
                      onTap: () {
                        settingsController.setCurrency(currency.code);
                        Get.back();
                      },
                    ),
                  ),
                );
              })),
        ],
      ),
    );
  }

  void _showNumberFormatSheet(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    AppBottomSheet.show(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'select_number_format'.tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: resp.fontLG,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: resp.spacingMD),
          ...SettingsController.numberFormats.map((format) => Obx(() {
                final isSelected =
                    settingsController.currentNumberFormat.value == format.code;
                return Padding(
                  padding: EdgeInsets.only(bottom: resp.spacingXS),
                  child: Material(
                    color: isSelected
                        ? const Color(0xFF10B981).withValues(alpha: 0.08)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(resp.cardRadius * 0.75),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF10B981).withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: resp.spacingMD,
                        vertical: 2,
                      ),
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color:
                            isSelected ? const Color(0xFF10B981) : Colors.grey,
                        size: resp.iconSM,
                      ),
                      title: Text(
                        format.titleKey.tr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected ? const Color(0xFF10B981) : null,
                          fontSize: resp.fontMD,
                        ),
                      ),
                      subtitle: Text(
                        format.descKey.tr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: resp.fontXS,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white10
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          format.preview,
                          style: TextStyle(
                            fontSize: resp.fontXS,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFF10B981)
                                : (isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700]),
                          ),
                        ),
                      ),
                      onTap: () {
                        settingsController.setNumberFormat(format.code);
                        Get.back();
                      },
                    ),
                  ),
                );
              })),
        ],
      ),
    );
  }

  void _showAppLockDialog(BuildContext context) {
    final lc = Get.find<LockController>();
    final resp = AppResponsive.of(context);

    AppDialog.show(
      context: context,
      maxWidth: 400,
      child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(resp.spacingXS),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(resp.radiusSM),
                    ),
                    child: Icon(Icons.security_rounded,
                        color: AppColors.primary, size: resp.iconSM),
                  ),
                  SizedBox(width: resp.spacingSM),
                  Expanded(
                    child: Text(
                      'app_lock_settings'.tr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: resp.fontLG,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: resp.spacingMD),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.pin_rounded,
                    color: AppColors.primary, size: resp.iconSM),
                title: Text('enable_pin'.tr,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD)),
                trailing: Switch.adaptive(
                  value: lc.isPinEnabled.value,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) {
                    Get.back();
                    if (val) {
                      Get.to(() => const SetPinView());
                    } else {
                      lc.removePin();
                    }
                  },
                ),
              ),
              if (lc.bioAvailable.value) ...[
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.fingerprint_rounded,
                      color: AppColors.primary, size: resp.iconSM),
                  title: Text('enable_biometric'.tr,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD)),
                  subtitle: Text(
                    'biometric_explanation_desc'.tr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: resp.fontXS,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Switch.adaptive(
                    value: lc.isBioEnabled.value,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) async {
                      if (val) {
                        await lc.requestEnableBiometrics();
                      } else {
                        await lc.toggleBiometric(false);
                      }
                    },
                  ),
                ),
              ],
            ],
          )),
    );
  }

  void _showBackupDialog(BuildContext context) {
    final resp = AppResponsive.of(context);

    AppDialog.show(
      context: context,
      maxWidth: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(resp.spacingXS),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(resp.radiusSM),
                ),
                child: Icon(Icons.security_rounded,
                    color: AppColors.primary, size: resp.iconSM),
              ),
              SizedBox(width: resp.spacingSM),
              Expanded(
                child: Text(
                  'backup_restore_title'.tr,
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
            'backup_format'.tr,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: resp.fontSM,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: resp.spacingMD),
          // Export Encrypted Backup Option
          InkWell(
            borderRadius: BorderRadius.circular(resp.cardRadius),
            onTap: () {
              Get.back();
              _showExportBackupDialog(context);
            },
            child: Container(
              padding: EdgeInsets.all(resp.spacingSM + 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(resp.cardRadius),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_upload_rounded,
                      color: AppColors.primary, size: resp.iconMD),
                  SizedBox(width: resp.spacingSM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'export_backup'.tr,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: resp.fontMD,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'تصدير وحفظ ملف .abbackup مشفر في مجلد تختاره',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: resp.fontXS,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(resp.forwardIcon,
                      size: resp.iconSM - 2, color: AppColors.primary),
                ],
              ),
            ),
          ),
          SizedBox(height: resp.spacingSM),
          // Import & Restore Backup Option
          InkWell(
            borderRadius: BorderRadius.circular(resp.cardRadius),
            onTap: () {
              Get.back();
              _handleImportBackup(context);
            },
            child: Container(
              padding: EdgeInsets.all(resp.spacingSM + 2),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(resp.cardRadius),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_download_rounded,
                      color: AppColors.secondary, size: resp.iconMD),
                  SizedBox(width: resp.spacingSM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'import_backup'.tr,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: resp.fontMD,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'استيراد واستعادة بيانات من ملف مشفر',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: resp.fontXS,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(resp.forwardIcon,
                      size: resp.iconSM - 2, color: AppColors.secondary),
                ],
              ),
            ),
          ),
          SizedBox(height: resp.spacingMD),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => Get.back(),
              child: Text('cancel'.tr, style: const TextStyle(fontFamily: 'Cairo')),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportBackupDialog(BuildContext context) {
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscurePass = true;
    bool obscureConfirm = true;
    bool isExporting = false;
    final resp = AppResponsive.of(context);

    AppDialog.show(
      context: context,
      maxWidth: 420,
      child: StatefulBuilder(
        builder: (context, setState) {
          Future<void> executeExport({required bool isShare}) async {
            final pass = passCtrl.text.trim();
            final confirm = confirmCtrl.text.trim();
            if (pass.length < 6) {
              Get.snackbar(
                'error'.tr,
                'backup_password_too_short'.tr,
                backgroundColor: AppColors.error,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }
            if (pass != confirm) {
              Get.snackbar(
                'error'.tr,
                'backup_password_mismatch'.tr,
                backgroundColor: AppColors.error,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            setState(() => isExporting = true);
            try {
              if (isShare) {
                await BackupService.exportAndShareBackup(password: pass);
                Get.back();
                Get.snackbar(
                  'success'.tr,
                  'backup_export_success'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                );
              } else {
                final savedPath = await BackupService.exportAndSaveBackup(password: pass);
                if (savedPath != null) {
                  Get.back();
                  Get.snackbar(
                    'success'.tr,
                    'backup_saved_success'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 4),
                  );
                } else {
                  setState(() => isExporting = false);
                  Get.snackbar(
                    'info'.tr,
                    'backup_save_canceled'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.grey[800],
                    colorText: Colors.white,
                  );
                }
              }
            } catch (e) {
              setState(() => isExporting = false);
              Get.snackbar(
                'error'.tr,
                e.toString(),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.error,
                colorText: Colors.white,
              );
            }
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(resp.spacingXS),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(resp.radiusSM),
                    ),
                    child: Icon(Icons.lock_outline_rounded,
                        color: AppColors.primary, size: resp.iconSM),
                  ),
                  SizedBox(width: resp.spacingSM),
                  Expanded(
                    child: Text(
                      'export_backup'.tr,
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
              Container(
                padding: EdgeInsets.all(resp.spacingSM),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(resp.radiusSM),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: AppColors.warning, size: resp.iconSM),
                    SizedBox(width: resp.spacingSM),
                    Expanded(
                      child: Text(
                        'backup_password_warning'.tr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: resp.fontXS,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: resp.spacingMD),
              TextField(
                controller: passCtrl,
                obscureText: obscurePass,
                style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                decoration: InputDecoration(
                  labelText: 'backup_password'.tr,
                  hintText: 'backup_password_hint'.tr,
                  prefixIcon: Icon(Icons.password_rounded, size: resp.iconSM),
                  suffixIcon: IconButton(
                    icon: Icon(obscurePass ? Icons.visibility_off : Icons.visibility, size: resp.iconSM),
                    onPressed: () => setState(() => obscurePass = !obscurePass),
                  ),
                ),
              ),
              SizedBox(height: resp.spacingSM),
              TextField(
                controller: confirmCtrl,
                obscureText: obscureConfirm,
                style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                decoration: InputDecoration(
                  labelText: 'confirm_backup_password'.tr,
                  prefixIcon: Icon(Icons.lock_reset_rounded, size: resp.iconSM),
                  suffixIcon: IconButton(
                    icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, size: resp.iconSM),
                    onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                  ),
                ),
              ),
              SizedBox(height: resp.spacingLG),
              if (isExporting)
                const Center(child: AppLoading())
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppButton(
                      text: 'save_to_files'.tr,
                      icon: Icons.save_alt_rounded,
                      onPressed: () => executeExport(isShare: false),
                    ),
                    SizedBox(height: resp.spacingSM),
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
                            text: 'share_backup'.tr,
                            icon: Icons.share_rounded,
                            variant: AppButtonVariant.secondary,
                            onPressed: () => executeExport(isShare: true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleImportBackup(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['abbackup', 'json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      Uint8List? fileBytes = file.bytes;
      if (fileBytes == null && file.path != null) {
        fileBytes = await File(file.path!).readAsBytes();
      }

      if (fileBytes == null || fileBytes.isEmpty) {
        Get.snackbar(
          'error'.tr,
          'backup_invalid_file_format'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }

      final nonNullBytes = fileBytes;
      final passCtrl = TextEditingController();
      bool obscurePass = true;
      bool isRestoring = false;
      final resp = AppResponsive.of(context);

      AppDialog.show(
        context: context,
        maxWidth: 420,
        child: StatefulBuilder(
          builder: (dialogCtx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(resp.spacingXS),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(resp.radiusSM),
                    ),
                    child: Icon(Icons.warning_amber_rounded,
                        color: AppColors.error, size: resp.iconMD),
                  ),
                  SizedBox(width: resp.spacingSM),
                  Expanded(
                    child: Text(
                      'backup_import_confirm_title'.tr,
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
              Container(
                padding: EdgeInsets.all(resp.spacingSM),
                decoration: BoxDecoration(
                  color: AppColors.giveLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(resp.radiusSM),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'backup_import_confirm_desc'.tr,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: resp.fontSM,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: resp.spacingMD),
              TextField(
                controller: passCtrl,
                obscureText: obscurePass,
                style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                decoration: InputDecoration(
                  labelText: 'backup_password'.tr,
                  hintText: 'backup_password'.tr,
                  prefixIcon: Icon(Icons.password_rounded, size: resp.iconSM),
                  suffixIcon: IconButton(
                    icon: Icon(obscurePass ? Icons.visibility_off : Icons.visibility, size: resp.iconSM),
                    onPressed: () => setState(() => obscurePass = !obscurePass),
                  ),
                ),
              ),
              SizedBox(height: resp.spacingLG),
              if (isRestoring)
                const Center(child: AppLoading())
              else
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
                        text: 'import_backup'.tr,
                        icon: Icons.restore_rounded,
                        variant: AppButtonVariant.destructive,
                        onPressed: () async {
                          final pass = passCtrl.text.trim();
                          if (pass.isEmpty) {
                            Get.snackbar(
                              'error'.tr,
                              'backup_password_empty'.tr,
                              backgroundColor: AppColors.error,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          setState(() => isRestoring = true);
                          try {
                            final summary = await BackupService.restoreBackup(
                              backupBytes: nonNullBytes,
                              password: pass,
                            );
                            if (Get.isRegistered<DashboardController>()) {
                              await Get.find<DashboardController>().loadDashboardData();
                            }
                            Get.back();
                            AppDialog.show(
                              context: context,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle_rounded,
                                          color: AppColors.success, size: resp.iconLG),
                                      SizedBox(width: resp.spacingSM),
                                      Expanded(
                                        child: Text(
                                          'backup_import_success'.tr,
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.bold,
                                            fontSize: resp.fontLG,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: resp.spacingMD),
                                  Text(
                                    '${'customers'.tr}: ${summary.customersCount}\n'
                                    '${'transactions'.tr}: ${summary.transactionsCount}\n'
                                    '${'invoices'.tr}: ${summary.invoicesCount}\n'
                                    '${'merchants'.tr}: ${summary.merchantsCount}',
                                    style: TextStyle(fontFamily: 'Cairo', height: 1.5, fontSize: resp.fontMD),
                                  ),
                                  SizedBox(height: resp.spacingMD),
                                  AppButton(
                                    text: 'ok'.tr,
                                    onPressed: () => Get.back(),
                                  ),
                                ],
                              ),
                            );
                          } catch (e) {
                            setState(() => isRestoring = false);
                            Get.snackbar(
                              'error'.tr,
                              e.toString(),
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.error,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 4),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _previewPDF() async {
    final cc = Get.find<CustomerController>();
    final tc = Get.find<TransactionController>();
    ExportService.previewAllReportPDF(
      customers: cc.customers.toList(),
      balances: Map<int, double>.from(cc.customerBalances),
      transactions: tc.allTransactions.toList(),
    );
  }

  Future<void> _previewExcel() async {
    final cc = Get.find<CustomerController>();
    final tc = Get.find<TransactionController>();
    ExportService.previewAllReportExcel(
      customers: cc.customers.toList(),
      balances: Map<int, double>.from(cc.customerBalances),
      transactions: tc.allTransactions.toList(),
    );
  }

  Future<void> _exportToPDF() async =>
      _processExport(ExportService.exportAllToPDF);
  Future<void> _exportToExcel() async =>
      _processExport(ExportService.exportAllToExcel);

  Future<void> _processExport(Function exportMethod) async {
    final cc = Get.find<CustomerController>();
    final tc = Get.find<TransactionController>();
    Get.snackbar(
      'exporting'.tr,
      'please_wait'.tr,
      showProgressIndicator: true,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary.withValues(alpha: 0.8),
      colorText: Colors.white,
    );
    await exportMethod(
      customers: cc.customers.toList(),
      balances: Map<int, double>.from(cc.customerBalances),
      transactions: tc.allTransactions.toList(),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final resp = AppResponsive.of(context);

    AppDialog.show(
      context: context,
      maxWidth: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(resp.spacingXS),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(resp.radiusSM),
                ),
                child: Icon(Icons.support_agent_rounded,
                    color: AppColors.primary, size: resp.iconSM),
              ),
              SizedBox(width: resp.spacingSM),
              Expanded(
                child: Text(
                  'help_support'.tr,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: resp.fontLG,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: resp.spacingMD),
          Text(
            'help_content'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: resp.fontSM,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: resp.spacingLG),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionCircle(
                icon: Icons.email_rounded,
                label: 'Email',
                onTap: () =>
                    launchUrl(Uri.parse('mailto:labeeb.kaleessi@gmail.com')),
                resp: resp,
              ),
              _buildActionCircle(
                icon: Icons.phone_rounded,
                label: 'Call',
                onTap: () => launchUrl(Uri.parse('tel:+967774190100')),
                resp: resp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCircle({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AppResponsive resp,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(resp.cardRadius),
      child: Padding(
        padding: EdgeInsets.all(resp.spacingSM),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(resp.spacingMD),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: resp.iconMD),
            ),
            SizedBox(height: resp.spacingXS),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: resp.fontSM,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    final resp = AppResponsive.of(context);

    AppDialog.show(
      context: context,
      maxWidth: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(resp.spacingXS),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(resp.radiusSM),
                ),
                child: Icon(Icons.privacy_tip_rounded,
                    color: AppColors.primary, size: resp.iconSM),
              ),
              SizedBox(width: resp.spacingSM),
              Expanded(
                child: Text(
                  'privacy_policy'.tr,
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
            'privacy_content'.tr,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: resp.fontSM,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: resp.spacingLG),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'ok'.tr,
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    AppDialog.confirm(
      context: context,
      title: 'logout'.tr,
      message: 'logout_confirm'.tr,
      confirmLabel: 'logout'.tr,
      isDestructive: true,
      onConfirm: () async {
        await Get.find<AuthController>().logout();
      },
    );
  }

  void _showClearDataDialog(BuildContext context) {
    AppDialog.confirm(
      context: context,
      title: 'clear_all_data'.tr,
      message: 'clear_confirm'.tr,
      confirmLabel: 'delete_all'.tr,
      isDestructive: true,
      onConfirm: () async {
        try {
          final cc = Get.find<CustomerController>();
          final tc = Get.find<TransactionController>();
          final dc = Get.isRegistered<DashboardController>()
              ? Get.find<DashboardController>()
              : null;

          await cc.clearAllData();
          await tc.clearAllData();
          if (dc != null) {
            dc.refreshDashboard();
          }

          Get.snackbar(
            'data_cleared'.tr,
            'all_data_deleted'.tr,
            backgroundColor: AppColors.give,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            'error'.tr,
            '${'failed_clear_data'.tr}: $e',
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  void _showGuidedToursSheet(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);
    final manager = GuidedTourManager.instance;
    final dc = Get.find<DashboardController>();

    AppBottomSheet.show(
      context: context,
      title: 'tour_replay_title'.tr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: resp.spacingSM),
            child: Text(
              'tour_replay_subtitle'.tr,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: resp.fontSM,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
          ),
          SizedBox(height: resp.spacingSM),

          // Master Auto-Tours Toggle
          Obx(() {
            final isEnabled = manager.storage.isAutoToursEnabled.value;
            return Container(
              margin: EdgeInsets.symmetric(horizontal: resp.spacingSM, vertical: resp.spacing2XS),
              padding: EdgeInsets.symmetric(horizontal: resp.spacingSM, vertical: resp.spacing2XS),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceColor : AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(resp.radiusMD),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: isEnabled,
                activeTrackColor: AppColors.primary,
                title: Text(
                  'tour_auto_enabled_title'.tr,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: resp.fontSM,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  'tour_auto_enabled_desc'.tr,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: resp.fontXS,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                onChanged: (val) => manager.storage.setAutoToursEnabled(val),
              ),
            );
          }),
          SizedBox(height: resp.spacingSM),

          // Tour 1: Dashboard
          _buildTourReplayTile(
            context: context,
            resp: resp,
            isDark: isDark,
            title: 'tour_dashboard_title'.tr,
            stepCount: 5,
            icon: Icons.dashboard_rounded,
            color: AppColors.primary,
            onStart: () async {
              Navigator.pop(context);
              dc.selectedIndex.value = 0;
              await Future.delayed(const Duration(milliseconds: 300));
              if (mounted) {
                manager.replayTour(context, AppTours.buildDashboardTour());
              }
            },
          ),
          SizedBox(height: resp.spacingSM),

          // Tour 2: Customers
          _buildTourReplayTile(
            context: context,
            resp: resp,
            isDark: isDark,
            title: 'tour_customers_title'.tr,
            stepCount: 3,
            icon: Icons.people_rounded,
            color: const Color(0xFF10B981),
            onStart: () async {
              Navigator.pop(context);
              dc.selectedIndex.value = 1;
              await Future.delayed(const Duration(milliseconds: 300));
              if (mounted) {
                manager.replayTour(context, AppTours.buildCustomersTour());
              }
            },
          ),
          SizedBox(height: resp.spacingSM),

          // Tour 3: Transactions
          _buildTourReplayTile(
            context: context,
            resp: resp,
            isDark: isDark,
            title: 'tour_transactions_title'.tr,
            stepCount: 3,
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF3B82F6),
            onStart: () async {
              Navigator.pop(context);
              dc.selectedIndex.value = 2;
              await Future.delayed(const Duration(milliseconds: 300));
              if (mounted) {
                manager.replayTour(context, AppTours.buildTransactionsTour());
              }
            },
          ),
          SizedBox(height: resp.spacingSM),

          // Tour 4: Settings
          _buildTourReplayTile(
            context: context,
            resp: resp,
            isDark: isDark,
            title: 'tour_settings_title'.tr,
            stepCount: 4,
            icon: Icons.settings_rounded,
            color: const Color(0xFF8B5CF6),
            onStart: () async {
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 300));
              if (mounted) {
                manager.replayTour(context, AppTours.buildSettingsTour());
              }
            },
          ),
          SizedBox(height: resp.spacingLG),

          // Reset All Tours Button
          OutlinedButton.icon(
            onPressed: () {
              AppDialog.confirm(
                context: context,
                title: 'tour_reset_all'.tr,
                message: 'tour_reset_all_confirm'.tr,
                confirmLabel: 'confirm'.tr,
                cancelLabel: 'cancel'.tr,
                isDestructive: true,
                onConfirm: () async {
                  await manager.resetAllTours();
                  if (context.mounted) {
                    Navigator.pop(context);
                    Get.snackbar(
                      'success'.tr,
                      'tour_reset_success'.tr,
                      backgroundColor: AppColors.success,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              );
            },
            icon: const Icon(Icons.restart_alt_rounded, size: 20),
            label: Text(
              'tour_reset_all'.tr,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w700,
                fontSize: resp.fontSM,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          SizedBox(height: resp.spacingMD),
        ],
      ),
    );
  }

  Widget _buildTourReplayTile({
    required BuildContext context,
    required AppResponsive resp,
    required bool isDark,
    required String title,
    required int stepCount,
    required IconData icon,
    required Color color,
    required VoidCallback onStart,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: resp.spacingMD,
        vertical: resp.spacingSM,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          SizedBox(width: resp.spacingSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: resp.fontSM,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'tour_steps_count'.trParams({'count': stepCount.toString()}),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: resp.fontXS,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onStart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(60, 34),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            child: Text(
              'tour_start_tour'.tr,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
