import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../core/core.dart';
import '../../models/app_currency.dart';
import '../../models/customer.dart';
import '../../models/transaction.dart';
import '../add_customer/add_customer_view.dart';

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

                  // Customer Selection with Search
                  _buildLabel('customer'.tr, isDark, resp),
                  FormField<Customer>(
                    initialValue: _selectedCustomer,
                    validator: (_) =>
                        _selectedCustomer == null ? 'select_customer'.tr : null,
                    builder: (FormFieldState<Customer> state) {
                        final hasError = state.hasError;
                        final curr = _selectedCustomer != null
                            ? AppCurrency.fromCode(_selectedCustomer!.currencyCode)
                            : null;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () async {
                                final chosen = await _openCustomerSearchSheet(
                                  context: context,
                                  resp: resp,
                                  primaryColor: primaryColor,
                                );
                                if (chosen != null && mounted) {
                                  setState(() {
                                    _selectedCustomer = chosen;
                                    _updateAmountWords();
                                  });
                                  state.didChange(chosen);
                                }
                              },
                              borderRadius: BorderRadius.circular(resp.cardRadius),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.person_rounded,
                                    color: primaryColor,
                                    size: resp.iconSM,
                                  ),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_selectedCustomer != null &&
                                          widget.preselectedCustomerId == null)
                                        IconButton(
                                          icon: Icon(
                                            Icons.clear_rounded,
                                            size: resp.iconSM,
                                            color: isDark
                                                ? AppColors.textMutedDark
                                                : AppColors.textMutedLight,
                                          ),
                                          tooltip: 'clear'.tr,
                                          onPressed: () {
                                            setState(() {
                                              _selectedCustomer = null;
                                              _updateAmountWords();
                                            });
                                            state.didChange(null);
                                          },
                                        ),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withValues(
                                              alpha: isDark ? 0.2 : 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.search_rounded,
                                          size: 16,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                  ),
                                  errorText: hasError ? state.errorText : null,
                                ),
                                child: _selectedCustomer == null
                                    ? Text(
                                        'search_customers'.tr,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          color: isDark
                                              ? AppColors.textMutedDark
                                              : AppColors.textMutedLight,
                                          fontSize: resp.fontMD,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  _selectedCustomer!.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Cairo',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: resp.fontMD,
                                                    color: isDark
                                                        ? AppColors.textPrimaryDark
                                                        : AppColors.textPrimaryLight,
                                                  ),
                                                ),
                                                if (_selectedCustomer!
                                                    .phoneNumber.isNotEmpty) ...[
                                                  const SizedBox(height: 1),
                                                  Text(
                                                    _selectedCustomer!.phoneNumber,
                                                    style: TextStyle(
                                                      fontFamily: 'Cairo',
                                                      fontSize: resp.fontXS,
                                                      color: isDark
                                                          ? AppColors.textSecondaryDark
                                                          : AppColors.textMutedLight,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          if (curr != null)
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: resp.spacingXS,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: primaryColor.withValues(
                                                    alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        resp.radiusXS),
                                              ),
                                              child: Text(
                                                '${curr.flag} ${curr.code}',
                                                style: TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize: resp.fontXS,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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

  Future<Customer?> _openCustomerSearchSheet({
    required BuildContext context,
    required AppResponsive resp,
    required Color primaryColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchCtrl = TextEditingController();

    return showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final viewInsets = MediaQuery.viewInsetsOf(context);
            final availableHeight =
                (resp.screenHeight - viewInsets.bottom - resp.safeTop)
                    .clamp(320.0, resp.screenHeight);

            final query = searchCtrl.text.trim();
            final allCustomers = _customerController.customers;
            final filtered = query.isEmpty
                ? allCustomers.toList()
                : allCustomers.where((c) {
                    final nameMatch = _matchesSearch(c.name, query);
                    final phoneMatch = _matchesSearch(c.phoneNumber, query);
                    return nameMatch || phoneMatch;
                  }).toList();

            return Padding(
              padding: EdgeInsets.only(bottom: viewInsets.bottom),
              child: Material(
                color: isDark ? AppColors.darkSurfaceColor : Colors.white,
                borderRadius: AppRadius.bottomSheetRadius(context),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: resp.maxContentWidth,
                    maxHeight: availableHeight * 0.90,
                  ),
                  child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: AppComponentSizes.dragHandleSize.width,
                          height: AppComponentSizes.dragHandleSize.height,
                          margin: const EdgeInsets.only(top: 14, bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Header
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: resp.spacingMD),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(resp.spacingXS),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(
                                    alpha: isDark ? 0.2 : 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_search_rounded,
                                color: primaryColor,
                                size: resp.iconSM,
                              ),
                            ),
                            SizedBox(width: resp.spacingSM),
                            Expanded(
                              child: Text(
                                'choose_customer'.tr,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: resp.fontLG,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white10
                                    : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${filtered.length} ${'customers'.tr}',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: resp.fontXS,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textMutedLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: resp.spacingSM),

                      // Search bar
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: resp.spacingMD),
                        child: TextField(
                          controller: searchCtrl,
                          autofocus: true,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: resp.fontMD,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'search_customers'.tr,
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: primaryColor,
                              size: resp.iconSM,
                            ),
                            suffixIcon: searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded,
                                        size: 18),
                                    onPressed: () {
                                      searchCtrl.clear();
                                      setSheetState(() {});
                                    },
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                          onChanged: (_) => setSheetState(() {}),
                        ),
                      ),
                      SizedBox(height: resp.spacingSM),
                      const Divider(height: 1),

                      // Customers list or Empty state
                      Flexible(
                        child: filtered.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 32, horizontal: 20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.person_off_rounded,
                                      size: 44,
                                      color: isDark
                                          ? Colors.white30
                                          : Colors.black26,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'no_customers_found'.tr,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: resp.fontMD,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textMutedLight,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Get.to(() => const AddCustomerView());
                                      },
                                      icon: const Icon(Icons.add_rounded,
                                          size: 18),
                                      label: Text('add_customer'.tr),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: primaryColor,
                                        side: BorderSide(
                                            color: primaryColor.withValues(
                                                alpha: 0.5)),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                    vertical: resp.spacingXS),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  indent: resp.spacingMD,
                                  endIndent: resp.spacingMD,
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                ),
                                itemBuilder: (context, index) {
                                  final customer = filtered[index];
                                  final isSelected =
                                      _selectedCustomer?.id == customer.id;
                                  final curr = AppCurrency.fromCode(
                                      customer.currencyCode);

                                  return ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: resp.spacingMD,
                                      vertical: 2,
                                    ),
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: isSelected
                                          ? primaryColor
                                          : (isDark
                                              ? Colors.white12
                                              : Colors.black.withValues(
                                                  alpha: 0.05)),
                                      child: Text(
                                        customer.name.isNotEmpty
                                            ? customer.name[0]
                                            : '?',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark
                                                  ? Colors.white70
                                                  : Colors.black87),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      customer.name,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: isSelected
                                            ? FontWeight.w900
                                            : FontWeight.w700,
                                        fontSize: resp.fontMD,
                                        color: isSelected
                                            ? primaryColor
                                            : (isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimaryLight),
                                      ),
                                    ),
                                    subtitle: customer.phoneNumber.isNotEmpty
                                        ? Text(
                                            customer.phoneNumber,
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: resp.fontSM,
                                              color: isDark
                                                  ? AppColors.textSecondaryDark
                                                  : AppColors.textMutedLight,
                                            ),
                                          )
                                        : null,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withValues(
                                                alpha: isDark ? 0.18 : 0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${curr.flag} ${curr.code}',
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: resp.fontXS,
                                              fontWeight: FontWeight.w800,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                        if (isSelected) ...[
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: primaryColor,
                                            size: 20,
                                          ),
                                        ],
                                      ],
                                    ),
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.pop(context, customer);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          },
        );
      },
    );
  }

  static bool _matchesSearch(String source, String query) {
    if (query.isEmpty) return true;
    final s = _normalizeSearchText(source);
    final q = _normalizeSearchText(query);
    return s.contains(q);
  }

  static String _normalizeSearchText(String text) {
    var result = text.toLowerCase().trim();
    // Normalize Arabic letters
    result = result
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
    // Normalize Arabic-Indic numbers to ASCII
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(arabic[i], english[i]);
    }
    return result;
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
