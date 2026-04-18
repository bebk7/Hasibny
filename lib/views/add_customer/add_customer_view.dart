import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/customer_controller.dart';
import '../../models/customer.dart';
import '../../services/contacts_service.dart';
import '../../themes/app_theme.dart';
import '../../utils/responsive.dart';

class AddCustomerView extends StatefulWidget {
  const AddCustomerView({super.key});

  @override
  State<AddCustomerView> createState() => _AddCustomerViewState();
}

class _AddCustomerViewState extends State<AddCustomerView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickContact() async {
    final result = await ContactsService.pickContact();
    if (result != null) {
      setState(() {
        _nameController.text = result.name;
        _phoneController.text = result.phone;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final customer = Customer(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    try {
      final customerController = Get.find<CustomerController>();
      await customerController.addCustomer(customer);
      Get.back();
      Get.snackbar(
        'success'.tr,
        'customer_added_success'.tr, // تأكد من إضافة هذا المفتاح في الترجمة
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successColor.withValues(alpha: 0.1),
        colorText: AppTheme.successColor,
      );
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(),
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = Responsive.isSmall(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('add_customer'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context)
            .unfocus(), // إغلاق الكيبورد عند الضغط خارج الحقول
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: Responsive.pagePadding(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // Avatar Section
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.2),
                              width: 2),
                        ),
                        child: CircleAvatar(
                          radius: isSmall ? 45 : 55,
                          backgroundColor:
                              AppTheme.primaryColor.withValues(alpha: 0.05),
                          child: Icon(
                            Icons.person_add_rounded,
                            size: isSmall ? 40 : 50,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Pick from contacts button
                TextButton.icon(
                  onPressed: _pickContact,
                  icon: const Icon(Icons.contacts_rounded),
                  label: Text('pick_from_contacts'.tr),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: isSmall ? 16 : 24),

                // Name Input Area
                _buildFieldLabel('customer_name'.tr),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'enter_full_name'.tr,
                    prefixIcon: const Icon(Icons.person_rounded),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.05),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'enter_name_error'.tr;
                    }
                    return null;
                  },
                ),
                SizedBox(height: isSmall ? 16 : 24),

                // Phone Input Area
                _buildFieldLabel('phone_number'.tr),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'enter_phone'.tr,
                    prefixIcon: const Icon(Icons.phone_rounded),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.05),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'enter_phone_error'.tr;
                    }
                    return null;
                  },
                ),
                SizedBox(height: isSmall ? 40 : 60),

                // Action Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isSmall ? 52 : 58,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 3, color: Colors.white),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.save_rounded),
                              const SizedBox(width: 10),
                              Text(
                                'save'.tr,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }
}
