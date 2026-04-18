import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller.dart';
import '../../models/merchant.dart';
import '../../themes/app_theme.dart';
import '../../utils/responsive.dart';

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
    if (!_formKey.currentState!.validate()) return;
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
        notes:
            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      Get.back();
      mc.addMerchant(m);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'edit_merchant'.tr : 'add_merchant_title'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: Responsive.pagePadding(context),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _buildField(
                controller: _nameCtrl,
                label: 'merchant_name'.tr,
                hint: 'enter_merchant_name'.tr,
                icon: Icons.store_rounded,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'enter_name_error'.tr : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _phoneCtrl,
                label: 'phone_number'.tr,
                hint: 'enter_phone'.tr,
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _addressCtrl,
                label: 'address'.tr,
                hint: 'enter_address'.tr,
                icon: Icons.location_on_rounded,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _notesCtrl,
                label: 'notes'.tr,
                hint: 'enter_notes'.tr,
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          isEditing ? 'save'.tr : 'add_merchant_title'.tr,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
