import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/customer_controller.dart';
import '../../models/app_currency.dart';
import '../../models/customer.dart';
import '../../services/contacts_service.dart';
import '../../core/core.dart';
import '../customer_details/customer_details_view.dart';

class AddCustomerView extends StatefulWidget {
  final Customer? customer;

  const AddCustomerView({super.key, this.customer});

  @override
  State<AddCustomerView> createState() => _AddCustomerViewState();
}

class _AddCustomerViewState extends State<AddCustomerView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late String _selectedCurrencyCode;
  late bool _autoSendWhatsApp;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController =
        TextEditingController(text: widget.customer?.phoneNumber ?? '');
    _whatsappController =
        TextEditingController(text: widget.customer?.whatsappNumber ?? '');
    _selectedCurrencyCode = widget.customer?.currencyCode ?? 'YER';
    _autoSendWhatsApp = widget.customer?.autoSendInvoiceWhatsApp ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _pickContact() async {
    HapticFeedback.lightImpact();
    final result = await ContactsService.pickContact();
    if (result != null) {
      setState(() {
        _nameController.text = result.name;
        _phoneController.text = result.phone;
        if (_whatsappController.text.isEmpty) {
          _whatsappController.text = result.phone;
        }
      });
    }
  }

  void _copyPrimaryPhoneToWhatsApp() {
    HapticFeedback.selectionClick();
    setState(() {
      _whatsappController.text = _phoneController.text.trim();
    });
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    try {
      final customerController = Get.find<CustomerController>();
      final whatsappNum = _whatsappController.text.trim();

      if (widget.customer != null) {
        if (customerController.customerExists(
          name: _nameController.text.trim(),
          currencyCode: _selectedCurrencyCode,
          excludeId: widget.customer!.id,
        )) {
          setState(() => _isSubmitting = false);
          Get.snackbar(
            'error'.tr,
            'customer_already_exists_currency'.tr,
            backgroundColor: AppColors.errorColor,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        final updated = widget.customer!;
        updated.name = _nameController.text.trim();
        updated.phoneNumber = _phoneController.text.trim();
        updated.currencyCode = _selectedCurrencyCode;
        updated.autoSendInvoiceWhatsApp = _autoSendWhatsApp;
        updated.whatsappNumber = whatsappNum.isNotEmpty ? whatsappNum : null;

        Get.back();
        customerController.updateCustomer(updated);
        return;
      } else {
        final customer = Customer(
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          currencyCode: _selectedCurrencyCode,
          autoSendInvoiceWhatsApp: _autoSendWhatsApp,
          whatsappNumber: whatsappNum.isNotEmpty ? whatsappNum : null,
        );
        final newId = await customerController.addCustomer(customer);
        if (newId != null) {
          Get.snackbar(
            'success'.tr,
            'customer_added_success'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.successColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          Get.off(() => CustomerDetailsView(customerId: newId));
        }
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(),
          backgroundColor: AppColors.errorColor, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final resp = AppResponsive.of(context);
    final isEditing = widget.customer != null;
    final isAr = Get.locale?.languageCode == 'ar';
    final avatarSize = resp.isSmall ? 76.0 : 88.0;

    return Scaffold(
      appBar: AppBar(
        title: AppAppBarTitle(
          isEditing ? 'edit_customer'.tr : 'add_customer'.tr,
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: resp.pageInsets,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: resp.maxContentWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Avatar Section
                    Center(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _nameController,
                        builder: (context, value, _) {
                          final initial = value.text.trim().isNotEmpty
                              ? value.text.trim()[0].toUpperCase()
                              : null;

                          return Container(
                            width: avatarSize,
                            height: avatarSize,
                            decoration: BoxDecoration(
                              color: AppColors.primaryOf(context).withValues(alpha: isDark ? 0.2 : 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryOf(context).withValues(alpha: 0.35),
                                width: AppSizes.borderHighlight,
                              ),
                            ),
                            child: Center(
                              child: initial != null
                                  ? Text(
                                      initial,
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: resp
                                            .fontSize(resp.isSmall ? 32 : 36),
                                        fontWeight: FontWeight.w900,
                                        color: isDark
                                            ? AppColors.darkPrimaryColor
                                            : AppColors.primaryColor,
                                      ),
                                    )
                                  : Icon(
                                      isEditing
                                          ? Icons.person_rounded
                                          : Icons.person_add_rounded,
                                      size: resp.isSmall ? 36 : 42,
                                      color: isDark
                                          ? AppColors.darkPrimaryColor
                                          : AppColors.primaryColor,
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: resp.spacingSM + 2),

                    // Pick from contacts button
                    if (!isEditing)
                      Center(
                        child: TextButton.icon(
                          onPressed: _pickContact,
                          icon: const Icon(Icons.contacts_rounded, size: 18),
                          label: Text(
                            'pick_from_contacts'.tr,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: resp.fontSize(13),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: isDark
                                ? AppColors.darkPrimaryColor
                                : AppColors.primaryColor,
                          ),
                        ),
                      ),
                    SizedBox(height: resp.isSmall ? 16 : 22),

                    // Customer Name Field
                    _buildFieldLabel('customer_name'.tr, isDark, resp),
                    SizedBox(height: resp.spacingSM),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: 'enter_full_name'.tr,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'enter_name_error'.tr;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: resp.isSmall ? 16 : 20),

                    // Phone Number Field
                    _buildFieldLabel('phone_number'.tr, isDark, resp),
                    SizedBox(height: resp.spacingSM),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final converted = PhoneNumberHelper.convertArabicDigitsToLatin(newValue.text);
                          if (converted == newValue.text) return newValue;
                          return newValue.copyWith(
                            text: converted,
                            selection: newValue.selection,
                            composing: TextRange.empty,
                          );
                        }),
                      ],
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: 'enter_phone'.tr,
                        hintTextDirection: TextDirection.ltr,
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'enter_phone_error'.tr;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: resp.isSmall ? 20 : 24),

                    // WhatsApp Invoice Settings Card
                    _buildWhatsAppSettingsCard(context, isDark, resp),
                    SizedBox(height: resp.isSmall ? 20 : 24),

                    // Account Currency Section
                    _buildFieldLabel('account_currency'.tr, isDark, resp),
                    SizedBox(height: resp.spacingSM + 2),
                    _buildCurrencySelector(context, isDark, resp),
                    SizedBox(height: resp.isSmall ? 24 : 32),

                    // Save Button
                    AppButton(
                      text: isEditing ? 'update'.tr : 'save'.tr,
                      icon: Icons.check_circle_rounded,
                      isLoading: _isSubmitting,
                      onPressed: _submitForm,
                    ),
                    SizedBox(height: resp.spacingLG),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsAppSettingsCard(
      BuildContext context, bool isDark, AppResponsive resp) {
    const waColor = Color(0xFF25D366);
    final isAr = Get.locale?.languageCode == 'ar';

    return Container(
      padding: resp.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(resp.cardRadius),
        border: Border.all(
          color: _autoSendWhatsApp
              ? waColor.withValues(alpha: 0.4)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width:
              _autoSendWhatsApp ? AppSizes.borderMedium : AppSizes.borderThin,
        ),
        boxShadow: AppShadows.subtle(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: waColor.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded,
                    color: waColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'whatsapp_invoice_settings'.tr,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.w800,
                    fontSize: resp.fontSize(14),
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: resp.spacingSM + 4),
          const Divider(height: 1),
          SizedBox(height: resp.spacingSM + 4),

          // WhatsApp Phone Input
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 4,
            children: [
              _buildFieldLabel('whatsapp_phone'.tr, isDark, resp),
              TextButton(
                onPressed: _copyPrimaryPhoneToWhatsApp,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'copy_from_primary_phone'.tr,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: resp.fontSize(12),
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkPrimaryColor
                        : AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _whatsappController,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            textAlign: isAr ? TextAlign.right : TextAlign.left,
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                final converted = PhoneNumberHelper.convertArabicDigitsToLatin(newValue.text);
                if (converted == newValue.text) return newValue;
                return newValue.copyWith(
                  text: converted,
                  selection: newValue.selection,
                  composing: TextRange.empty,
                );
              }),
            ],
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'whatsapp_phone_hint'.tr,
              hintTextDirection: TextDirection.ltr,
              prefixIcon:
                  const Icon(Icons.phone_iphone_rounded, color: waColor),
            ),
          ),
          SizedBox(height: resp.spacingSM + 4),

          // Auto-send Toggle Switch
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _autoSendWhatsApp,
              activeTrackColor: waColor.withValues(alpha: 0.5),
              activeThumbColor: waColor,
              title: Text(
                'auto_send_whatsapp_invoice'.tr,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: resp.fontSize(13),
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              subtitle: Text(
                'auto_send_whatsapp_desc'.tr,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: resp.fontSize(11),
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _autoSendWhatsApp = val;
                  if (val && _whatsappController.text.trim().isEmpty) {
                    _whatsappController.text = _phoneController.text.trim();
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(
      BuildContext context, bool isDark, AppResponsive resp) {
    final isAr = Get.locale?.languageCode == 'ar';

    return Column(
      children: AppCurrency.supportedCurrencies.map((curr) {
        final isSelected = _selectedCurrencyCode == curr.code;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: isSelected
                ? AppColors.primaryColor.withValues(alpha: isDark ? 0.18 : 0.08)
                : (isDark ? AppColors.darkCardColor : Colors.white),
            borderRadius: BorderRadius.circular(resp.cardRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(resp.cardRadius),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCurrencyCode = curr.code);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(resp.cardRadius),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : (isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight),
                    width:
                        isSelected ? AppSizes.borderThick : AppSizes.borderThin,
                  ),
                ),
                child: Row(
                  children: [
                    Text(curr.flag, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            curr.getName(isArabic: isAr),
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontWeight: FontWeight.w800,
                              fontSize: resp.fontSize(14),
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.darkPrimaryColor
                                      : AppColors.primaryColor)
                                  : (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight),
                            ),
                          ),
                          Text(
                            '${curr.code} (${curr.getSymbol(isArabic: isAr)})',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontSize: resp.fontSize(11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected
                          ? (isDark
                              ? AppColors.darkPrimaryColor
                              : AppColors.primaryColor)
                          : (isDark ? Colors.white30 : Colors.black26),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark, AppResponsive resp) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: resp.fontSize(13),
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }
}
