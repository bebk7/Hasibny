import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller.dart';
import '../../core/core.dart';
import '../../models/merchant.dart';

class AddMerchantView extends StatefulWidget {
  final Merchant? merchant;
  const AddMerchantView({super.key, this.merchant});

  @override
  State<AddMerchantView> createState() => _AddMerchantViewState();
}

class _AddMerchantViewState extends State<AddMerchantView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;
  bool _saving = false;

  bool get isEditing => widget.merchant != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.merchant?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.merchant?.phone ?? '');
    _addressCtrl = TextEditingController(text: widget.merchant?.address ?? '');
    _notesCtrl = TextEditingController(text: widget.merchant?.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    setState(() => _saving = true);

    final mc = Get.find<MerchantController>();

    if (isEditing) {
      final m = widget.merchant!;
      m.name = _nameCtrl.text.trim();
      m.phone = _phoneCtrl.text.trim();
      m.address = _addressCtrl.text.trim();
      m.notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();
      Get.back();
      mc.updateMerchant(m);
    } else {
      final m = Merchant(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      Get.back();
      mc.addMerchant(m);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarSize = resp.isSmall ? 72.0 : 84.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'edit_merchant'.tr : 'add_merchant_title'.tr,
          style: AppTypography.pageTitle(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: AppPageContainer(
          maxWidth: 520,
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: resp.spacingSM,
              vertical: resp.spacingMD,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar / Store Icon
                  Center(
                    child: Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withValues(alpha: isDark ? 0.22 : 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.store_rounded,
                          size: resp.iconLG + 6,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: resp.spacingLG),

                  // Merchant Name Field
                  _buildLabel('merchant_name'.tr, isDark, resp),
                  SizedBox(height: resp.spacingXS),
                  TextFormField(
                    controller: _nameCtrl,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      fontSize: resp.fontMD,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'enter_merchant_name'.tr,
                      prefixIcon: Icon(Icons.store_rounded, size: resp.iconSM),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'enter_name_error'.tr
                        : null,
                  ),
                  SizedBox(height: resp.spacingMD),

                  // Phone Number Field
                  _buildLabel('phone_number'.tr, isDark, resp),
                  SizedBox(height: resp.spacingXS),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      fontSize: resp.fontMD,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'enter_phone'.tr,
                      prefixIcon: Icon(Icons.phone_rounded, size: resp.iconSM),
                    ),
                  ),
                  SizedBox(height: resp.spacingMD),

                  // Address Field
                  _buildLabel('address'.tr, isDark, resp),
                  SizedBox(height: resp.spacingXS),
                  TextFormField(
                    controller: _addressCtrl,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                      fontSize: resp.fontMD,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'enter_address'.tr,
                      prefixIcon:
                          Icon(Icons.location_on_rounded, size: resp.iconSM),
                    ),
                  ),
                  SizedBox(height: resp.spacingMD),

                  // Notes Field
                  _buildLabel('notes'.tr, isDark, resp),
                  SizedBox(height: resp.spacingXS),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                      fontSize: resp.fontMD,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'enter_notes'.tr,
                      prefixIcon: Icon(Icons.notes_rounded, size: resp.iconSM),
                    ),
                  ),
                  SizedBox(height: resp.spacingXL),

                  // Submit Button
                  AppButton(
                    text: isEditing ? 'save'.tr : 'add_merchant_title'.tr,
                    icon: Icons.check_circle_rounded,
                    isLoading: _saving,
                    onPressed: _save,
                  ),
                  SizedBox(height: resp.pagePadding),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark, AppResponsive resp) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: resp.fontSM,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }
}
