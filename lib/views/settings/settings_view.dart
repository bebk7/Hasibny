import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/lock_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../services/export_service.dart';
import '../../themes/app_theme.dart';
import '../../utils/responsive.dart';
import '../../controllers/auth_controller.dart';
import '../lock/set_pin_view.dart';
import 'store_profile_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[50]
          : Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'settings'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: Responsive.pagePadding(context),
        children: [
          _buildSection(
            context,
            title: 'store_profile'.tr,
            icon: Icons.storefront_rounded,
            items: [
              Obx(() => _buildTile(
                    icon: Icons.store_rounded,
                    color: AppTheme.primaryColor,
                    title: settingsController.storeName.value.isEmpty
                        ? 'store_profile'.tr
                        : settingsController.storeName.value,
                    subtitle: settingsController.storeName.value.isEmpty
                        ? 'store_profile_sub'.tr
                        : settingsController.storePhone.value.isEmpty
                            ? 'store_profile_sub'.tr
                            : settingsController.storePhone.value,
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Get.to(() => const StoreProfileView()),
                  )),
            ],
          ),
          _buildSection(
            context,
            title: 'app_settings'.tr,
            icon: Icons.tune_rounded,
            items: [
              _buildTile(
                icon: Icons.language_rounded,
                color: Colors.blue,
                title: 'language'.tr,
                subtitle: 'language_sub'.tr,
                trailing: Obx(() => Switch.adaptive(
                      value: settingsController.isArabic,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (_) => settingsController.toggleLanguage(),
                    )),
              ),
              _buildTile(
                icon: Icons.currency_exchange_rounded,
                color: Colors.orange,
                title: 'currency'.tr,
                subtitle: settingsController.currencyLabel,
                onTap: () => _showCurrencyDialog(context),
              ),
              Obx(() => _buildTile(
                    icon: Icons.dark_mode_rounded,
                    color: Colors.purple,
                    title: 'dark_mode'.tr,
                    subtitle: 'dark_mode_sub'.tr,
                    trailing: Switch.adaptive(
                      value: settingsController.isDarkMode.value,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (_) => settingsController.toggleDarkMode(),
                    ),
                  )),
              _buildTile(
                icon: Icons.lock_person_rounded,
                color: Colors.teal,
                title: 'app_lock'.tr,
                subtitle: 'app_lock_sub'.tr,
                onTap: () => _showAppLockDialog(context),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'data_management'.tr,
            icon: Icons.storage_rounded,
            items: [
              _buildTile(
                icon: Icons.cloud_done_rounded,
                color: Colors.indigo,
                title: 'backup_data'.tr,
                subtitle: 'backup_data_sub'.tr,
                onTap: () => _showBackupDialog(context),
              ),
              _buildTile(
                icon: Icons.picture_as_pdf_rounded,
                color: Colors.redAccent,
                title: 'export_pdf'.tr,
                subtitle: 'export_pdf_sub'.tr,
                onTap: () => _exportToPDF(),
              ),
              _buildTile(
                icon: Icons.grid_on_rounded,
                color: Colors.green,
                title: 'export_excel'.tr,
                subtitle: 'export_excel_sub'.tr,
                onTap: () => _exportToExcel(),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'about'.tr,
            icon: Icons.alternate_email_rounded,
            items: [
              _buildTile(
                icon: Icons.info_rounded,
                color: Colors.blueGrey,
                title: 'app_version'.tr,
                subtitle: '1.0.0',
              ),
              _buildTile(
                icon: Icons.support_agent_rounded,
                color: Colors.cyan,
                title: 'help_support'.tr,
                onTap: () => _showHelpDialog(context),
              ),
              _buildTile(
                icon: Icons.gpp_maybe_rounded,
                color: Colors.amber[800]!,
                title: 'privacy_policy'.tr,
                onTap: () => _showPrivacyDialog(context),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'account_section'.tr,
            icon: Icons.account_circle_rounded,
            items: [
              Obx(() {
                final ac = Get.find<AuthController>();
                return _buildTile(
                  icon: Icons.person_rounded,
                  color: Colors.indigo,
                  title: 'logged_in_as'.tr,
                  subtitle: ac.userEmail,
                );
              }),
              _buildTile(
                icon: Icons.logout_rounded,
                color: Colors.red,
                title: 'logout'.tr,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDangerZone(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title,
      required IconData icon,
      required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: AppTheme.primaryColor.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor.withValues(alpha: 0.8),
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 0.5,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final isLast = index == items.length - 1;
              return Column(
                children: [
                  items[index],
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 60,
                      color: Colors.grey.withValues(alpha: 0.08),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 13))
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right_rounded, color: Colors.grey[400])
              : null),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: ListTile(
        leading: Icon(Icons.delete_forever_rounded, color: Colors.red[700]),
        title: Text('clear_all_data'.tr,
            style:
                TextStyle(color: const Color(0xFFD41C1C), fontWeight: FontWeight.bold)),
        subtitle:
            Text('clear_data_sub'.tr, style: TextStyle(color: const Color.fromARGB(255, 124, 66, 66))),
        onTap: () => _showClearDataDialog(context),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text('select_currency'.tr,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...SettingsController.currencies.map((currency) => Obx(() {
                  return RadioListTile<String>(
                    title: Text(currency.label),
                    value: currency.code,
                    groupValue: settingsController.currentCurrency.value,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (val) {
                      settingsController.setCurrency(val!);
                      Get.back();
                    },
                  );
                })),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAppLockDialog(BuildContext context) {
    final lc = Get.find<LockController>();
    Get.defaultDialog(
      title: 'app_lock_settings'.tr,
      titlePadding: const EdgeInsets.only(top: 20),
      contentPadding: const EdgeInsets.all(12),
      radius: 20,
      content: Obx(() => Column(
            children: [
              _buildDialogToggle(
                icon: Icons.pin_rounded,
                title: 'enable_pin'.tr,
                value: lc.isPinEnabled.value,
                onChanged: (val) {
                  Get.back();
                  if (val) {
                    Get.to(() => const SetPinView());
                  } else {
                    lc.removePin();
                  }
                },
              ),
              if (lc.bioAvailable.value) ...[
                const Divider(),
                _buildDialogToggle(
                  icon: Icons.fingerprint_rounded,
                  title: 'enable_biometric'.tr,
                  value: lc.isBioEnabled.value,
                  onChanged: (val) => lc.toggleBiometric(val),
                ),
              ],
            ],
          )),
    );
  }

  Widget _buildDialogToggle(
      {required IconData icon,
      required String title,
      required bool value,
      required Function(bool) onChanged}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Switch.adaptive(
          value: value,
          activeColor: AppTheme.primaryColor,
          onChanged: onChanged),
    );
  }

  void _showBackupDialog(BuildContext context) => Get.defaultDialog(
        title: 'backup_title'.tr,
        middleText: 'backup_format'.tr,
        radius: 20,
        confirm: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: const StadiumBorder()),
          onPressed: () {
            Get.back();
            Get.snackbar('success'.tr, 'backup_success'.tr,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.successColor,
                colorText: Colors.white);
          },
          child: Text('backup'.tr, style: const TextStyle(color: Colors.white)),
        ),
      );

  Future<void> _exportToPDF() async =>
      _processExport(ExportService.exportAllToPDF);
  Future<void> _exportToExcel() async =>
      _processExport(ExportService.exportAllToExcel);

  Future<void> _processExport(Function exportMethod) async {
    final cc = Get.find<CustomerController>();
    final tc = Get.find<TransactionController>();
    Get.snackbar('exporting'.tr, 'please_wait'.tr,
        showProgressIndicator: true,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.8),
        colorText: Colors.white);
    await exportMethod(
      customers: cc.customers.toList(),
      balances: Map<int, double>.from(cc.customerBalances),
      transactions: tc.allTransactions.toList(),
    );
  }

  void _showHelpDialog(BuildContext context) => Get.defaultDialog(
        title: 'help_support'.tr,
        content: Column(
          children: [
            Text('help_content'.tr, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionCircle(
                  icon: Icons.email_rounded,
                  label: 'Email',
                  onTap: () =>
                      launchUrl(Uri.parse('mailto:labeeb.kaleessi@gmail.com')),
                ),
                _buildActionCircle(
                  icon: Icons.phone_rounded,
                  label: 'Call',
                  onTap: () => launchUrl(Uri.parse('tel:+967774190100')),
                ),
              ],
            ),
          ],
        ),
        radius: 20,
      );

  Widget _buildActionCircle({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) => Get.defaultDialog(
      title: 'privacy_policy'.tr,
      content: Text('privacy_content'.tr),
      radius: 20);

  void _showLogoutDialog(BuildContext context) => Get.defaultDialog(
        title: 'logout'.tr,
        middleText: 'logout_confirm'.tr,
        radius: 20,
        textConfirm: 'logout'.tr,
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,
        textCancel: 'cancel'.tr,
        onConfirm: () async {
          Get.back();
          await Get.find<AuthController>().logout();
        },
      );

  void _showClearDataDialog(BuildContext context) => Get.defaultDialog(
        title: 'clear_all_data'.tr,
        middleText: 'clear_confirm'.tr,
        titleStyle: const TextStyle(color: Colors.red),
        radius: 20,
        textConfirm: 'delete_all'.tr,
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,
        onConfirm: () async {
          Get.back();
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

            Get.snackbar('data_cleared'.tr, 'all_data_deleted'.tr,
                backgroundColor: Colors.red, colorText: Colors.white);
          } catch (e) {
            Get.snackbar('error'.tr, '${'failed_clear_data'.tr}: $e',
                backgroundColor: AppTheme.errorColor, colorText: Colors.white);
          }
        },
      );
}
