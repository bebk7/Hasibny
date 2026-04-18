import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../controllers/settings_controller.dart';
import '../../themes/app_theme.dart';
import '../../utils/responsive.dart';

class StoreProfileView extends StatefulWidget {
  const StoreProfileView({super.key});

  @override
  State<StoreProfileView> createState() => _StoreProfileViewState();
}

class _StoreProfileViewState extends State<StoreProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _taxCtrl;
  bool _saving = false;
  String? _selectedLogoPath;

  @override
  void initState() {
    super.initState();
    final sc = Get.find<SettingsController>();
    _nameCtrl = TextEditingController(text: sc.storeName.value);
    _phoneCtrl = TextEditingController(text: sc.storePhone.value);
    _addressCtrl = TextEditingController(text: sc.storeAddress.value);
    _emailCtrl = TextEditingController(text: sc.storeEmail.value);
    _taxCtrl = TextEditingController(text: sc.storeTaxNumber.value);
    _selectedLogoPath = sc.storeLogoPath.value.isNotEmpty ? sc.storeLogoPath.value : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _taxCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final picked = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 85);
    if (picked == null) return;

    // Copy to app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final logoDir = Directory('${appDir.path}/store_logo');
    if (!await logoDir.exists()) await logoDir.create(recursive: true);

    final ext = p.extension(picked.path);
    final newPath = '${logoDir.path}/logo$ext';
    await File(picked.path).copy(newPath);

    setState(() => _selectedLogoPath = newPath);
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('select_image_source'.tr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _sourceOption(Icons.camera_alt_rounded, 'camera'.tr, ImageSource.camera),
                  _sourceOption(Icons.photo_library_rounded, 'gallery'.tr, ImageSource.gallery),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceOption(IconData icon, String label, ImageSource source) {
    return InkWell(
      onTap: () => Navigator.pop(context, source),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _removeLogo() {
    setState(() => _selectedLogoPath = null);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Get.find<SettingsController>().saveStoreProfile(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      taxNumber: _taxCtrl.text.trim(),
      logoPath: _selectedLogoPath,
    );
    if (_selectedLogoPath == null) {
      await Get.find<SettingsController>().removeStoreLogo();
    }
    setState(() => _saving = false);
    Get.back();
    Get.snackbar(
      'success'.tr,
      'store_profile_saved'.tr,
      backgroundColor: AppTheme.successColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Get.find<SettingsController>().isArabic;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[50]
          : Colors.grey[900],
      appBar: AppBar(
        title: Text('store_profile'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_rounded, color: Colors.white),
              tooltip: 'save'.tr,
              onPressed: _save,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: Responsive.pagePadding(context),
          children: [
            const SizedBox(height: 12),
            _ProfileHeader(
              logoPath: _selectedLogoPath,
              onPickLogo: _pickLogo,
              onRemoveLogo: _removeLogo,
            ),
            const SizedBox(height: 20),
            _buildCard(
              context,
              icon: Icons.storefront_rounded,
              color: AppTheme.primaryColor,
              title: 'store_basic_info'.tr,
              children: [
                _buildField(
                  controller: _nameCtrl,
                  label: 'store_name'.tr,
                  hint: isAr ? 'مثال: متجر النور' : 'e.g. Al Noor Store',
                  icon: Icons.store_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'store_name_required'.tr : null,
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _phoneCtrl,
                  label: 'phone'.tr,
                  hint: isAr ? 'مثال: 967-777-123456' : 'e.g. +967-777-123456',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _emailCtrl,
                  label: 'email'.tr,
                  hint: 'store@example.com',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCard(
              context,
              icon: Icons.location_on_rounded,
              color: const Color(0xFF00695C),
              title: 'store_details'.tr,
              children: [
                _buildField(
                  controller: _addressCtrl,
                  label: 'address'.tr,
                  hint: isAr ? 'المدينة، الحي، الشارع' : 'City, District, Street',
                  icon: Icons.map_rounded,
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _taxCtrl,
                  label: 'tax_number'.tr,
                  hint: isAr ? 'الرقم الضريبي (اختياري)' : 'Tax / VAT number (optional)',
                  icon: Icons.receipt_long_rounded,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _PreviewHint(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: color)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String? logoPath;
  final VoidCallback onPickLogo;
  final VoidCallback onRemoveLogo;

  const _ProfileHeader({
    required this.logoPath,
    required this.onPickLogo,
    required this.onRemoveLogo,
  });

  @override
  Widget build(BuildContext context) {
    final sc = Get.find<SettingsController>();
    final hasLogo = logoPath != null && logoPath!.isNotEmpty && File(logoPath!).existsSync();

    return Obx(() {
      final name = sc.storeName.value;
      return Center(
        child: Column(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: onPickLogo,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: hasLogo
                          ? Image.file(
                              File(logoPath!),
                              fit: BoxFit.cover,
                              width: 110,
                              height: 110,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_rounded,
                                    size: 32, color: AppTheme.primaryColor),
                                const SizedBox(height: 4),
                                Text(
                                  'add_logo'.tr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                if (hasLogo)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: onRemoveLogo,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              name.isEmpty ? 'store_profile'.tr : name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: name.isEmpty ? Colors.grey : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'logo_hint'.tr,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _PreviewHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf_rounded,
              color: AppTheme.primaryColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'store_profile_pdf_hint'.tr,
              style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
