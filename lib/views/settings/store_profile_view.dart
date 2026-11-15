import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../controllers/settings_controller.dart';
import '../../core/core.dart';

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
    _selectedLogoPath =
        sc.storeLogoPath.value.isNotEmpty ? sc.storeLogoPath.value : null;
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

    final picked = await picker.pickImage(
        source: source, maxWidth: 512, maxHeight: 512, imageQuality: 85);
    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final logoDir = Directory('${appDir.path}/store_logo');
    if (!await logoDir.exists()) await logoDir.create(recursive: true);

    final ext = p.extension(picked.path);
    final newPath = '${logoDir.path}/logo$ext';
    await File(picked.path).copy(newPath);

    setState(() => _selectedLogoPath = newPath);
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    final resp = AppResponsive.of(context);

    return await AppBottomSheet.show<ImageSource>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'select_image_source'.tr,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: resp.fontLG,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: resp.spacingLG),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _sourceOption(
                  Icons.camera_alt_rounded, 'camera'.tr, ImageSource.camera, resp),
              _sourceOption(Icons.photo_library_rounded, 'gallery'.tr,
                  ImageSource.gallery, resp),
            ],
          ),
          SizedBox(height: resp.spacingSM),
        ],
      ),
    );
  }

  Widget _sourceOption(
      IconData icon, String label, ImageSource source, AppResponsive resp) {
    return InkWell(
      onTap: () => Navigator.pop(context, source),
      borderRadius: BorderRadius.circular(resp.cardRadius),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: resp.spacingLG,
          vertical: resp.spacingMD,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(resp.cardRadius),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: resp.iconLG, color: AppColors.primary),
            SizedBox(height: resp.spacingSM),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: resp.fontSM,
              ),
            ),
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
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isAr = Get.find<SettingsController>().isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'store_profile'.tr,
          style: AppTypography.pageTitle(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check_rounded, size: resp.iconSM),
            tooltip: 'save'.tr,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: AppPageContainer(
          maxWidth: 560,
          padding: EdgeInsets.zero,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: resp.spacingSM,
              vertical: resp.spacingMD,
            ),
            children: [
              _ProfileHeader(
                logoPath: _selectedLogoPath,
                onPickLogo: _pickLogo,
                onRemoveLogo: _removeLogo,
              ),
              SizedBox(height: resp.spacingLG),

              // Basic Info Card
              AppCard(
                padding: EdgeInsets.all(resp.spacingMD),
                child: Column(
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
                          child: Icon(Icons.storefront_rounded,
                              color: AppColors.primary, size: resp.iconSM),
                        ),
                        SizedBox(width: resp.spacingSM),
                        Text(
                          'store_basic_info'.tr,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: resp.fontMD,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: resp.spacingMD),
                    TextFormField(
                      controller: _nameCtrl,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'store_name_required'.tr
                          : null,
                      decoration: InputDecoration(
                        labelText: 'store_name'.tr,
                        hintText:
                            isAr ? 'مثال: متجر النور' : 'e.g. Al Noor Store',
                        prefixIcon: Icon(Icons.store_rounded, size: resp.iconSM),
                      ),
                    ),
                    SizedBox(height: resp.spacingSM),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                      decoration: InputDecoration(
                        labelText: 'phone'.tr,
                        hintText: isAr
                            ? 'مثال: 967-777-123456'
                            : 'e.g. +967-777-123456',
                        prefixIcon: Icon(Icons.phone_rounded, size: resp.iconSM),
                      ),
                    ),
                    SizedBox(height: resp.spacingSM),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                      decoration: InputDecoration(
                        labelText: 'email'.tr,
                        hintText: 'store@example.com',
                        prefixIcon: Icon(Icons.email_rounded, size: resp.iconSM),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: resp.spacingMD),

              // Details Card
              AppCard(
                padding: EdgeInsets.all(resp.spacingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(resp.spacingXS),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(resp.radiusSM),
                          ),
                          child: Icon(Icons.location_on_rounded,
                              color: const Color(0xFF0D9488), size: resp.iconSM),
                        ),
                        SizedBox(width: resp.spacingSM),
                        Text(
                          'store_details'.tr,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: resp.fontMD,
                            color: const Color(0xFF0D9488),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: resp.spacingMD),
                    TextFormField(
                      controller: _addressCtrl,
                      maxLines: 2,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                      decoration: InputDecoration(
                        labelText: 'address'.tr,
                        hintText: isAr
                            ? 'المدينة، الحي، الشارع'
                            : 'City, District, Street',
                        prefixIcon: Icon(Icons.map_rounded, size: resp.iconSM),
                      ),
                    ),
                    SizedBox(height: resp.spacingSM),
                    TextFormField(
                      controller: _taxCtrl,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                      decoration: InputDecoration(
                        labelText: 'tax_number'.tr,
                        hintText: isAr
                            ? 'الرقم الضريبي (اختياري)'
                            : 'Tax / VAT number (optional)',
                        prefixIcon: Icon(Icons.receipt_long_rounded, size: resp.iconSM),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: resp.spacingMD),

              // PDF Hint
              _PreviewHint(),
              SizedBox(height: resp.spacingLG),

              // Save AppButton
              AppButton(
                text: 'save'.tr,
                icon: Icons.check_rounded,
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
              SizedBox(height: resp.pagePadding),
            ],
          ),
        ),
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
    final resp = AppResponsive.of(context);
    final hasLogo = logoPath != null &&
        logoPath!.isNotEmpty &&
        File(logoPath!).existsSync();
    final logoSize = resp.isSmall ? 88.0 : 100.0;

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
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: hasLogo
                          ? Image.file(
                              File(logoPath!),
                              fit: BoxFit.cover,
                              width: logoSize,
                              height: logoSize,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_rounded,
                                    size: resp.iconLG, color: AppColors.primary),
                                const SizedBox(height: 4),
                                Text(
                                  'add_logo'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: resp.fontXS,
                                    color: AppColors.primary,
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
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.give,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: resp.spacingSM),
            Text(
              name.isEmpty ? 'store_profile'.tr : name,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: resp.fontLG,
                fontWeight: FontWeight.bold,
                color: name.isEmpty ? Colors.grey : null,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'logo_hint'.tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: resp.fontXS,
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
    final resp = AppResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(resp.spacingSM + 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(resp.cardRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(resp.spacingXS),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(resp.radiusSM),
            ),
            child: Icon(Icons.picture_as_pdf_rounded,
                color: AppColors.primary, size: resp.iconSM),
          ),
          SizedBox(width: resp.spacingSM),
          Expanded(
            child: Text(
              'store_profile_pdf_hint'.tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.primary,
                fontSize: resp.fontXS,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
