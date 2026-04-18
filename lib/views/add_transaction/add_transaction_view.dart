import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/customer.dart';
import '../../models/transaction.dart';
import '../../themes/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/responsive.dart';

class AddTransactionView extends StatefulWidget {
  final TransactionType initialType;
  final int? preselectedCustomerId;

  const AddTransactionView({
    super.key,
    required this.initialType,
    this.preselectedCustomerId,
  });

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late TransactionType _selectedType;
  Customer? _selectedCustomer;
  bool _isSubmitting = false;
  String _amountWords = '';

  late final CustomerController _customerController;
  late final TransactionController _transactionController;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _customerController = Get.find<CustomerController>();
    _transactionController = Get.find<TransactionController>();
    _amountController.addListener(_updateAmountWords);

    if (widget.preselectedCustomerId != null) {
      _selectedCustomer = _customerController.customers.firstWhereOrNull(
        (c) => c.id == widget.preselectedCustomerId,
      );
    }
  }

  void _updateAmountWords() {
    final val = double.tryParse(_amountController.text.trim());
    setState(() {
      _amountWords =
          (val != null && val > 0) ? CurrencyFormatter.amountToWords(val) : '';
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateAmountWords);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      Get.snackbar('error'.tr, 'select_customer'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white);
      return;
    }

    setState(() => _isSubmitting = true);
    await _transactionController.addTransaction(
      customerId: _selectedCustomer!.id,
      amount: double.parse(_amountController.text.trim()),
      type: _selectedType,
      description: _descriptionController.text.trim(),
    );
    if (mounted) setState(() => _isSubmitting = false);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isGive = _selectedType == TransactionType.give;
    final primaryColor = isGive ? AppTheme.giveColor : AppTheme.gotColor;
    final isSmall = Responsive.isSmall(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isGive ? 'give_debit'.tr : 'got_credit'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: Responsive.pagePadding(context),
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dynamic Header Card
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: primaryColor.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: isSmall ? 35 : 45,
                            backgroundColor:
                                primaryColor.withValues(alpha: 0.15),
                            child: Icon(
                              isGive
                                  ? Icons.upload_rounded
                                  : Icons.download_rounded,
                              size: isSmall ? 35 : 45,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isGive ? 'money_gave'.tr : 'money_received'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Toggle
                    Row(
                      children: [
                        Expanded(
                          child: _TypeButton(
                            label: 'give'.tr,
                            icon: Icons.remove_circle_outline,
                            color: AppTheme.giveColor,
                            selected: isGive,
                            onTap: () => setState(
                                () => _selectedType = TransactionType.give),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _TypeButton(
                            label: 'got'.tr,
                            icon: Icons.add_circle_outline,
                            color: AppTheme.gotColor,
                            selected: !isGive,
                            onTap: () => setState(
                                () => _selectedType = TransactionType.got),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Input Fields
                    _buildLabel('customer'.tr),
                    Obx(() {
                      final customers = _customerController.customers;
                      return DropdownButtonFormField<Customer>(
                        value: _selectedCustomer,
                        isExpanded: true,
                        decoration: _inputDecoration(
                            Icons.person_rounded, primaryColor),
                        items: customers
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c.name)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCustomer = value),
                        validator: (value) =>
                            value == null ? 'select_customer'.tr : null,
                      );
                    }),
                    const SizedBox(height: 16),

                    _buildLabel('amount'.tr),
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor),
                      decoration: _inputDecoration(
                              Icons.account_balance_wallet_rounded,
                              primaryColor)
                          .copyWith(hintText: '0.00'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'enter_amount'.tr;
                        }
                        final parsed = double.tryParse(value.trim());
                        if (parsed == null || parsed <= 0) {
                          return 'valid_amount'.tr;
                        }
                        return null;
                      },
                    ),
                    if (_amountWords.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 6, right: 8, left: 8),
                        child: Text(
                          _amountWords,
                          style: TextStyle(
                            color: primaryColor.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    _buildLabel('description'.tr),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: _inputDecoration(
                              Icons.edit_note_rounded, primaryColor)
                          .copyWith(hintText: 'description_hint'.tr),
                    ),
                    const SizedBox(height: 32),

                    // Enhanced Submit Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(isGive
                                      ? Icons.send_rounded
                                      : Icons.call_received_rounded),
                                  const SizedBox(width: 12),
                                  Text(
                                    _isSubmitting
                                        ? 'saving'.tr
                                        : (isGive
                                            ? 'record_give'.tr
                                            : 'record_got'.tr),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
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
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon, Color color) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: color.withValues(alpha: 0.6)),
      filled: true,
      fillColor: Colors.grey.withValues(alpha: 0.05),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color.withValues(alpha: 0.4), width: 2),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700])),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? color : Colors.grey.withValues(alpha: 0.2),
              width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.grey, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
