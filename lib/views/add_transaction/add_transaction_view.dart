import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../core/core.dart';
import '../../models/app_currency.dart';
import '../../models/customer.dart';
import '../../models/transaction.dart';

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
  DateTime _selectedDateTime = DateTime.now();

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
    final curr = _selectedCustomer?.currencyCode ?? 'YER';
    final newWords = (val != null && val > 0)
        ? CurrencyFormatter.amountToWords(val, currencyCode: curr)
        : '';
    if (newWords != _amountWords && mounted) {
      setState(() => _amountWords = newWords);
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateAmountWords);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      Get.snackbar(
        'error'.tr,
        'select_customer'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final parsedAmount = double.tryParse(_amountController.text.trim());
    if (parsedAmount == null || parsedAmount <= 0) {
      Get.snackbar(
        'error'.tr,
        'valid_amount'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    await _transactionController.addTransaction(
      customerId: _selectedCustomer!.id,
      amount: parsedAmount,
      type: _selectedType,
      description: _descriptionController.text.trim(),
      currencyCode: _selectedCustomer!.currencyCode,
      createdAt: _selectedDateTime,
    );
    if (Get.isRegistered<CustomerController>()) {
      await Get.find<CustomerController>().loadCustomerBalances();
    }
    if (mounted) setState(() => _isSubmitting = false);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isGive = _selectedType == TransactionType.give;
    final primaryColor = isGive ? AppColors.give : AppColors.got;
    final selectedCurr = _selectedCustomer != null
        ? AppCurrency.fromCode(_selectedCustomer!.currencyCode)
        : null;

    final isAr = Get.locale?.languageCode == 'ar';
    final hour24 = _selectedDateTime.hour;
    final minute = _selectedDateTime.minute.toString().padLeft(2, '0');
    final isPm = hour24 >= 12;
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final period = isAr ? (isPm ? 'م' : 'ص') : (isPm ? 'PM' : 'AM');
    final timeStr = '${hour12.toString().padLeft(2, '0')}:$minute $period';
    final dateStr = '${_selectedDateTime.year}/${_selectedDateTime.month.toString().padLeft(2, '0')}/${_selectedDateTime.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: AppAppBarTitle(isGive ? 'give_debit'.tr : 'got_credit'.tr),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: AppPageContainer(
          maxWidth: 560,
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: resp.spacingSM,
              vertical: resp.spacingMD,
            ),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dynamic Header Card
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(
                      vertical: resp.spacingLG,
                      horizontal: resp.spacingMD,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: isDark ? 0.16 : 0.08),
                      borderRadius: BorderRadius.circular(resp.cardRadius),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: resp.isSmall ? 56 : 68,
                          height: resp.isSmall ? 56 : 68,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.14),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              isGive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                              size: resp.isSmall ? 28 : 34,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(height: resp.spacingSM),
                        Text(
                          isGive ? 'money_gave'.tr : 'money_received'.tr,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: resp.fontLG,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: resp.spacingMD),

                  // Quick Toggle
                  Row(
                    children: [
                      Expanded(
                        child: _TypeButton(
                          label: 'give'.tr,
                          icon: Icons.arrow_upward_rounded,
                          color: AppColors.give,
                          selected: isGive,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedType = TransactionType.give);
                          },
                        ),
                      ),
                      SizedBox(width: resp.spacingSM),
                      Expanded(
                        child: _TypeButton(
                          label: 'got'.tr,
                          icon: Icons.arrow_downward_rounded,
                          color: AppColors.got,
                          selected: !isGive,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedType = TransactionType.got);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: resp.spacingLG),

                  // Customer Selection
                  _buildLabel('customer'.tr, isDark, resp),
                  Obx(() {
                    final customers = _customerController.customers;

                    Customer? currentMatch;
                    if (_selectedCustomer != null) {
                      currentMatch = customers.firstWhereOrNull(
                          (c) => c.id == _selectedCustomer!.id);
                    } else if (widget.preselectedCustomerId != null) {
                      currentMatch = customers.firstWhereOrNull(
                          (c) => c.id == widget.preselectedCustomerId);
                    }

                    return DropdownButtonFormField<Customer>(
                      initialValue: currentMatch,
                      isExpanded: true,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                        fontSize: resp.fontMD,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_rounded, color: primaryColor, size: resp.iconSM),
                      ),
                      items: customers.map((c) {
                        final curr = AppCurrency.fromCode(c.currencyCode);
                        return DropdownMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: resp.spacingXS,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(resp.radiusXS),
                                ),
                                child: Text(
                                  '${curr.flag} ${curr.code}',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: resp.fontXS,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCustomer = value;
                          _updateAmountWords();
                        });
                      },
                      validator: (value) =>
                          value == null ? 'select_customer'.tr : null,
                    );
                  }),
                  SizedBox(height: resp.spacingMD),

                  // Amount Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('amount'.tr, isDark, resp),
                      if (selectedCurr != null)
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: resp.spacingSM,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(resp.radiusSM),
                            ),
                            child: Text(
                              '${selectedCurr.flag} ${selectedCurr.getName(isArabic: isAr)}',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: resp.fontXS,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [
                      DigitsOnlyInputFormatter(),
                    ],
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: resp.font2XL,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                      letterSpacing: -0.5,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.account_balance_wallet_rounded, color: primaryColor, size: resp.iconSM),
                      hintText: '0',
                      suffixText: selectedCurr?.getSymbol(isArabic: isAr) ?? '',
                      suffixStyle: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        fontSize: resp.fontMD,
                      ),
                    ),
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _amountWords.isNotEmpty
                        ? Container(
                            key: ValueKey(_amountWords),
                            margin: EdgeInsets.only(top: resp.spacingXS),
                            padding: EdgeInsets.symmetric(
                              horizontal: resp.spacingSM,
                              vertical: resp.spacingXS,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: isDark ? 0.16 : 0.08),
                              borderRadius: BorderRadius.circular(resp.radiusSM),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.spellcheck_rounded,
                                  size: resp.iconXS,
                                  color: primaryColor,
                                ),
                                SizedBox(width: resp.spacingSM),
                                Expanded(
                                  child: Text(
                                    _amountWords,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      color: primaryColor,
                                      fontSize: resp.fontSM,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(height: resp.spacingMD),

                  _buildLabel('description'.tr, isDark, resp),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                      fontSize: resp.fontMD,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.edit_note_rounded, color: primaryColor, size: resp.iconSM),
                      hintText: 'description_hint'.tr,
                    ),
                  ),
                  SizedBox(height: resp.spacingMD),

                  // Transaction Date & Time Selector
                  _buildLabel('transaction_time'.tr, isDark, resp),
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDateTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null && context.mounted) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _selectedDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(resp.cardRadius),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: resp.spacingMD,
                        vertical: resp.spacingSM + 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(resp.cardRadius),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: resp.iconSM,
                            color: primaryColor,
                          ),
                          SizedBox(width: resp.spacingSM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'transaction_time'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: resp.fontXS,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$dateStr  -  $timeStr',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: resp.fontSM,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.edit_calendar_rounded,
                            size: resp.iconSM,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: resp.spacingXL),

                  // Submit Button
                  AppButton(
                    text: isGive ? 'record_give'.tr : 'record_got'.tr,
                    icon: isGive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    customColor: primaryColor,
                    isLoading: _isSubmitting,
                    onPressed: _submitForm,
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
    return Padding(
      padding: EdgeInsetsDirectional.only(start: resp.spacing2XS, bottom: resp.spacingSM),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: resp.fontSM,
          fontWeight: FontWeight.w800,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
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
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(resp.cardRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: resp.spacingSM + 2,
          horizontal: resp.spacingSM,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color
              : (isDark ? color.withValues(alpha: 0.12) : color.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(resp.cardRadius),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : color,
              size: resp.iconSM,
            ),
            SizedBox(width: resp.spacingSM),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.w800,
                  fontSize: resp.fontMD,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
