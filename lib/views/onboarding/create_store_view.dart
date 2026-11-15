import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../controllers/onboarding_controller.dart';
import '../../core/core.dart';
import '../../models/app_currency.dart';
import '../home/home_view.dart';

class CreateStoreView extends StatefulWidget {
  const CreateStoreView({super.key});

  @override
  State<CreateStoreView> createState() => _CreateStoreViewState();
}

class _CreateStoreViewState extends State<CreateStoreView> {
  final _formKey = GlobalKey<FormState>();
  final OnboardingController _controller = Get.find<OnboardingController>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  String _selectedCountryCode = '+967';
  String _selectedCurrencyCode = 'YER';
  String? _logoPath;
  bool _isSaving = false;

  static const List<Map<String, String>> _countryCodes = [
    {'flag': '🇾🇪', 'name': 'اليمن', 'code': '+967'},
    {'flag': '🇸🇦', 'name': 'السعودية', 'code': '+966'},
    {'flag': '🇦🇪', 'name': 'الإمارات', 'code': '+971'},
    {'flag': '🇪🇬', 'name': 'مصر', 'code': '+20'},
    {'flag': '🇴🇲', 'name': 'عُمان', 'code': '+968'},
    {'flag': '🇰🇼', 'name': 'الكويت', 'code': '+965'},
    {'flag': '🇶🇦', 'name': 'قطر', 'code': '+974'},
    {'flag': '🇧🇭', 'name': 'البحرين', 'code': '+973'},
    {'flag': '🇯🇴', 'name': 'الأردن', 'code': '+962'},
    {'flag': '🇺🇸', 'name': 'أمريكا', 'code': '+1'},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    HapticFeedback.lightImpact();
    final resp = AppResponsive.of(context);

    final source = await AppBottomSheet.show<ImageSource>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'اختيار شعار المتجر',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: resp.fontLG,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: resp.spacingLG),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _imageSourceOption(
                icon: Icons.photo_library_rounded,
                label: 'المعرض',
                onTap: () => Navigator.pop(context, ImageSource.gallery),
                resp: resp,
              ),
              _imageSourceOption(
                icon: Icons.camera_alt_rounded,
                label: 'الكاميرا',
                onTap: () => Navigator.pop(context, ImageSource.camera),
                resp: resp,
              ),
            ],
          ),
          SizedBox(height: resp.spacingSM),
        ],
      ),
    );

    if (source == null) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (picked == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final logoDir = Directory('${appDir.path}/store_logo');
      if (!await logoDir.exists()) await logoDir.create(recursive: true);

      final ext = p.extension(picked.path);
      final destPath = '${logoDir.path}/store_logo_${DateTime.now().millisecondsSinceEpoch}$ext';
      await File(picked.path).copy(destPath);

      setState(() {
        _logoPath = destPath;
      });
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

  Widget _imageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AppResponsive resp,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(resp.cardRadius),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: resp.spacingLG, vertical: resp.spacingMD),
        decoration: BoxDecoration(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(resp.cardRadius),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: resp.iconLG, color: const Color(0xFF00E5FF)),
            SizedBox(height: resp.spacingSM),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: resp.fontSM,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      final rawDigits = PhoneNumberHelper.stripNonDigits(_phoneCtrl.text.trim());
      final fullPhoneNumber = '$_selectedCountryCode$rawDigits';

      await _controller.createStoreProfile(
        name: _nameCtrl.text.trim(),
        fullPhoneNumber: fullPhoneNumber,
        address: _addressCtrl.text.trim(),
        defaultCurrencyCode: _selectedCurrencyCode,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        logoPath: _logoPath,
      );

      Get.snackbar(
        'success'.tr,
        'store_created_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      Get.offAll(() => const HomeView());
    } catch (e) {
      setState(() => _isSaving = false);
      Get.snackbar(
        'error'.tr,
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final logoSize = resp.isSmall ? 84.0 : 96.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1315),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1315),
        elevation: 0,
        title: Text(
          'create_store'.tr,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: resp.fontLG,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: resp.iconSM),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: AppPageContainer(
              isScrollable: false,
              maxWidth: 520,
              padding: EdgeInsets.zero,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: resp.pagePadding,
                    vertical: resp.spacingMD,
                  ),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // 1. Centered circular store logo placeholder
                    Center(
                      child: GestureDetector(
                        onTap: _pickLogo,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: logoSize,
                                  height: logoSize,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF161C20),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF2A343D),
                                      width: 2,
                                    ),
                                    image: _logoPath != null
                                        ? DecorationImage(
                                            image: FileImage(File(_logoPath!)),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _logoPath == null
                                      ? Center(
                                          child: Icon(
                                            Icons.storefront_rounded,
                                            size: resp.iconLG + 8,
                                            color: const Color(0xFF00E5FF),
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(resp.spacingXS),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00E5FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 16,
                                      color: Color(0xFF0F1315),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: resp.spacingSM),
                            Text(
                              'store_logo_label'.tr,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: resp.fontSM,
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: resp.spacingLG),

                    // 2. اسم المتجر (Required *)
                    _buildFieldLabel('اسم المتجر', isRequired: true, resp: resp),
                    SizedBox(height: resp.spacingSM),
                    TextFormField(
                      controller: _nameCtrl,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: resp.fontMD,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration(
                        hint: 'enter_store_name_hint'.tr,
                        icon: Icons.store_rounded,
                        resp: resp,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'store_name_validation'.tr;
                        }
                        if (value.trim().length > 60) {
                          return 'اسم المتجر طويل جداً (الحد الأقصى 60 حرفاً)';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: resp.spacingMD),

                    // 3. رقم الهاتف (Required *) with country code dropdown
                    _buildFieldLabel('رقم الهاتف', isRequired: true, resp: resp),
                    SizedBox(height: resp.spacingSM),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Country code dropdown
                        Container(
                          height: resp.inputHeight,
                          padding: EdgeInsets.symmetric(horizontal: resp.spacingSM),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161C20),
                            borderRadius: BorderRadius.circular(resp.inputRadius),
                            border: Border.all(color: const Color(0xFF2A343D)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCountryCode,
                              dropdownColor: const Color(0xFF161C20),
                              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5FF)),
                              items: _countryCodes.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item['code'],
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(item['flag'] ?? '', style: const TextStyle(fontSize: 18)),
                                      SizedBox(width: resp.spacingXS),
                                      Text(
                                        item['code'] ?? '',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: resp.fontSM,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedCountryCode = val);
                                }
                              },
                            ),
                          ),
                        ),

                        SizedBox(width: resp.spacingSM),

                        // Phone number field
                        Expanded(
                          child: TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            inputFormatters: const [
                              DigitsOnlyInputFormatter(),
                            ],
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white,
                              fontSize: resp.fontMD,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDecoration(
                              hint: '777123456',
                              icon: Icons.phone_rounded,
                              resp: resp,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'phone_validation'.tr;
                              }
                              final digitsOnly = PhoneNumberHelper.stripNonDigits(value);
                              if (digitsOnly.length < 6 || digitsOnly.length > 15) {
                                return 'phone_validation'.tr;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: resp.spacingMD),

                    // 4. العملة الافتراضية
                    _buildFieldLabel('currency'.tr, isRequired: true, resp: resp),
                    SizedBox(height: resp.spacingSM),
                    Container(
                      height: resp.inputHeight,
                      padding: EdgeInsets.symmetric(horizontal: resp.spacingMD),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161C20),
                        borderRadius: BorderRadius.circular(resp.inputRadius),
                        border: Border.all(color: const Color(0xFF2A343D)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCurrencyCode,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF161C20),
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5FF)),
                          items: AppCurrency.supportedCurrencies.map((c) {
                            return DropdownMenuItem<String>(
                              value: c.code,
                              child: Row(
                                children: [
                                  Text(c.flag, style: const TextStyle(fontSize: 18)),
                                  SizedBox(width: resp.spacingSM),
                                  Text(
                                    '${c.nameAr} (${c.code})',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: resp.fontMD,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCurrencyCode = val);
                            }
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: resp.spacingMD),

                    // 5. العنوان
                    _buildFieldLabel('address'.tr, isRequired: false, resp: resp),
                    SizedBox(height: resp.spacingSM),
                    TextFormField(
                      controller: _addressCtrl,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: resp.fontMD,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration(
                        hint: 'enter_store_address_hint'.tr,
                        icon: Icons.location_on_rounded,
                        resp: resp,
                      ),
                    ),

                    SizedBox(height: resp.spacingMD),

                    // 6. ملاحظات
                    _buildFieldLabel('notes'.tr, isRequired: false, resp: resp),
                    SizedBox(height: resp.spacingSM),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: resp.fontMD,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'notes_hint'.tr,
                        hintStyle: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: resp.fontSM,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF161C20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(resp.inputRadius),
                          borderSide: const BorderSide(color: Color(0xFF2A343D)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(resp.inputRadius),
                          borderSide: const BorderSide(color: Color(0xFF2A343D)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(resp.inputRadius),
                          borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
                        ),
                        contentPadding: EdgeInsets.all(resp.spacingMD),
                      ),
                    ),

                    SizedBox(height: resp.spacingXL),

                    // 7. زر الحفظ الرئيسي
                    SizedBox(
                      height: resp.buttonHeight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: const Color(0xFF0F1315),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(resp.buttonRadius),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isSaving ? null : _submitForm,
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Color(0xFF0F1315),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 20),
                                  SizedBox(width: resp.spacingSM),
                                  Text(
                                    'create_button'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w900,
                                      fontSize: resp.fontMD,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: resp.pagePadding),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {required bool isRequired, required AppResponsive resp}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: resp.fontSM,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: Color(0xFFFF5252),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required AppResponsive resp,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Cairo',
        color: Colors.white.withValues(alpha: 0.35),
        fontSize: resp.fontSM,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF00E5FF), size: resp.iconSM),
      filled: true,
      fillColor: const Color(0xFF161C20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(resp.inputRadius),
        borderSide: const BorderSide(color: Color(0xFF2A343D)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(resp.inputRadius),
        borderSide: const BorderSide(color: Color(0xFF2A343D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(resp.inputRadius),
        borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: resp.spacingMD, vertical: resp.spacingSM),
    );
  }
}
