import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/invoice_controller.dart';
import '../../controllers/merchant_controller.dart';
import '../../core/core.dart';
import '../../models/app_currency.dart';
import '../../models/customer.dart';
import '../../models/invoice.dart';
import '../../models/merchant.dart';
import '../../services/whatsapp_service.dart';
import '../../widgets/amount_field.dart';

class AddInvoiceView extends StatefulWidget {
  final int? merchantId;
  final int? customerId;
  final Invoice? invoice;

  const AddInvoiceView({
    super.key,
    this.merchantId,
    this.customerId,
    this.invoice,
  });

  @override
  State<AddInvoiceView> createState() => _AddInvoiceViewState();
}

class _AddInvoiceViewState extends State<AddInvoiceView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numberCtrl;
  late final TextEditingController _paidCtrl;
  late final TextEditingController _notesCtrl;
  bool _saving = false;

  final List<InvoiceItem> _items = [];

  bool get isEditing => widget.invoice != null;

  double get _computedTotal =>
      _items.fold(0.0, (sum, item) => sum + item.total);

  @override
  void initState() {
    super.initState();
    final defaultNum = widget.invoice?.invoiceNumber ??
        'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    _numberCtrl = TextEditingController(text: defaultNum);
    _paidCtrl = TextEditingController(
        text: widget.invoice != null
            ? widget.invoice!.paidAmount.toString()
            : '0');
    _notesCtrl = TextEditingController(text: widget.invoice?.notes ?? '');

    if (widget.invoice != null) {
      _items.addAll(widget.invoice!.items);
    }
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _paidCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _addItem() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController();
    final resp = AppResponsive.of(context);

    AppDialog.show(
      context: context,
      maxWidth: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  child: Icon(
                    Icons.add_shopping_cart_rounded,
                    color: AppColors.primary,
                    size: resp.iconSM,
                  ),
                ),
                SizedBox(width: resp.spacingSM),
                Expanded(
                  child: Text(
                    'add_item'.tr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: resp.fontLG,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: resp.spacingMD),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
              decoration: InputDecoration(
                labelText: 'item_name'.tr,
                prefixIcon: Icon(Icons.inventory_2_rounded, size: resp.iconSM),
              ),
            ),
            SizedBox(height: resp.spacingSM),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [
                      DigitsOnlyInputFormatter(),
                    ],
                    style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                    decoration: InputDecoration(
                      labelText: 'quantity'.tr,
                      prefixIcon: Icon(Icons.numbers_rounded, size: resp.iconSM),
                    ),
                  ),
                ),
                SizedBox(width: resp.spacingSM),
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [
                      DigitsOnlyInputFormatter(),
                    ],
                    style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                    decoration: InputDecoration(
                      labelText: 'unit_price'.tr,
                      prefixIcon: Icon(Icons.payments_rounded, size: resp.iconSM),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: resp.spacingLG),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'cancel'.tr,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Get.back(),
                  ),
                ),
                SizedBox(width: resp.spacingSM),
                Expanded(
                  child: AppButton(
                    text: 'add'.tr,
                    icon: Icons.check_rounded,
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      final qty = double.tryParse(qtyCtrl.text.trim()) ?? 1;
                      final price =
                          double.tryParse(priceCtrl.text.trim()) ?? 0;
                      if (name.isEmpty || price <= 0) return;
                      setState(() {
                        _items.add(InvoiceItem(
                            name: name, quantity: qty, unitPrice: price));
                      });
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editItem(int index) {
    final item = _items[index];
    final nameCtrl = TextEditingController(text: item.name);
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    final priceCtrl = TextEditingController(text: item.unitPrice.toString());
    final resp = AppResponsive.of(context);

    AppDialog.show(
      context: context,
      maxWidth: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.primary,
                    size: resp.iconSM,
                  ),
                ),
                SizedBox(width: resp.spacingSM),
                Expanded(
                  child: Text(
                    'edit_item'.tr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: resp.fontLG,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: resp.spacingMD),
            TextField(
              controller: nameCtrl,
              style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
              decoration: InputDecoration(
                labelText: 'item_name'.tr,
                prefixIcon: Icon(Icons.inventory_2_rounded, size: resp.iconSM),
              ),
            ),
            SizedBox(height: resp.spacingSM),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [
                      DigitsOnlyInputFormatter(),
                    ],
                    style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                    decoration: InputDecoration(
                      labelText: 'quantity'.tr,
                      prefixIcon: Icon(Icons.numbers_rounded, size: resp.iconSM),
                    ),
                  ),
                ),
                SizedBox(width: resp.spacingSM),
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [
                      DigitsOnlyInputFormatter(),
                    ],
                    style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                    decoration: InputDecoration(
                      labelText: 'unit_price'.tr,
                      prefixIcon: Icon(Icons.payments_rounded, size: resp.iconSM),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: resp.spacingLG),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'cancel'.tr,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Get.back(),
                  ),
                ),
                SizedBox(width: resp.spacingSM),
                Expanded(
                  child: AppButton(
                    text: 'save'.tr,
                    icon: Icons.check_rounded,
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      final qty = double.tryParse(qtyCtrl.text.trim()) ?? 1;
                      final price =
                          double.tryParse(priceCtrl.text.trim()) ?? 0;
                      if (name.isEmpty || price <= 0) return;
                      setState(() {
                        _items[index] = InvoiceItem(
                            name: name, quantity: qty, unitPrice: price);
                      });
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'add_at_least_one_item'.tr,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    setState(() => _saving = true);

    final ic = Get.find<InvoiceController>();
    final total = _computedTotal;
    final paid = double.tryParse(_paidCtrl.text.trim()) ?? 0.0;

    Customer? customer;
    if ((widget.customerId ?? widget.invoice?.customerId) != null &&
        Get.isRegistered<CustomerController>()) {
      customer = Get.find<CustomerController>()
          .getCustomerById(widget.customerId ?? widget.invoice!.customerId!);
    }

    Merchant? merchant;
    if ((widget.merchantId ?? widget.invoice?.merchantId) != null &&
        Get.isRegistered<MerchantController>()) {
      merchant = Get.find<MerchantController>()
          .getMerchantById(widget.merchantId ?? widget.invoice!.merchantId!);
    }

    final currCode = customer?.currencyCode ??
        widget.invoice?.currencyCode ??
        'YER';

    if (paid > total + 0.0001 && total > 0) {
      setState(() => _saving = false);
      Get.snackbar(
        'warning'.tr,
        'paid_exceeds_total_error'.trParams({
          'total': CurrencyFormatter.format(total, currencyCode: currCode),
        }),
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    if (isEditing) {
      final inv = widget.invoice!;
      inv.invoiceNumber = _numberCtrl.text.trim();
      inv.totalAmount = total;
      inv.paidAmount = paid;
      inv.items = _items;
      inv.notes =
          _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();
      Get.back();
      ic.updateInvoice(inv);
    } else {
      final inv = Invoice(
        merchantId: widget.merchantId,
        customerId: widget.customerId,
        invoiceNumber: _numberCtrl.text.trim(),
        currencyCode: currCode,
        totalAmount: total,
        paidAmount: paid,
        notes:
            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      inv.items = _items;
      Get.back();
      ic.addInvoice(inv, customer: customer, merchant: merchant);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    Customer? customer;
    if ((widget.customerId ?? widget.invoice?.customerId) != null &&
        Get.isRegistered<CustomerController>()) {
      customer = Get.find<CustomerController>()
          .getCustomerById(widget.customerId ?? widget.invoice!.customerId!);
    }

    Merchant? merchant;
    if ((widget.merchantId ?? widget.invoice?.merchantId) != null &&
        Get.isRegistered<MerchantController>()) {
      merchant = Get.find<MerchantController>()
          .getMerchantById(widget.merchantId ?? widget.invoice!.merchantId!);
    }

    final currCode = customer?.currencyCode ??
        widget.invoice?.currencyCode ??
        'YER';

    final willAutoSend = customer != null &&
        WhatsAppService.shouldAutoSend(customer: customer);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: AppAppBarTitle(
          isEditing ? 'edit_invoice'.tr : 'add_invoice_title'.tr,
        ),
      ),
      body: AppPageContainer(
        maxWidth: 600,
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
                // Recipient banner
                if (customer != null || merchant != null)
                  AppCard(
                    margin: EdgeInsets.only(bottom: resp.spacingMD),
                    padding: EdgeInsets.all(resp.spacingSM + 2),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(resp.radiusSM),
                          ),
                          child: Icon(
                            customer != null
                                ? Icons.person_rounded
                                : Icons.storefront_rounded,
                            color: AppColors.primary,
                            size: resp.iconMD,
                          ),
                        ),
                        SizedBox(width: resp.spacingSM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer?.name ?? merchant?.name ?? '',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: resp.fontMD,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                () {
                                  final c = AppCurrency.fromCode(currCode);
                                  final isAr = Get.locale?.languageCode == 'ar';
                                  return '${'account_currency'.tr}: ${c.flag} ${c.getName(isArabic: isAr)} (${c.getSymbol(isArabic: isAr)})';
                                }(),
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: resp.fontXS,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (willAutoSend)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: resp.spacingSM,
                              vertical: resp.spacing2XS,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(resp.radiusSM),
                              border: Border.all(
                                color: const Color(0xFF25D366).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.chat_bubble_rounded,
                                    color: Color(0xFF25D366), size: 14),
                                SizedBox(width: resp.spacing2XS),
                                const Text(
                                  'WhatsApp',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF25D366),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                // Invoice number field
                TextFormField(
                  controller: _numberCtrl,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'enter_invoice_number'.tr
                      : null,
                  decoration: InputDecoration(
                    labelText: 'invoice_number'.tr,
                    hintText: 'enter_invoice_number'.tr,
                    prefixIcon: Icon(Icons.tag_rounded, size: resp.iconSM),
                  ),
                ),
                SizedBox(height: resp.spacingLG),

                // Items section header (Responsive)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 360;
                    final addBtn = TextButton.icon(
                      onPressed: _addItem,
                      icon: Icon(Icons.add_circle_outline_rounded, size: resp.iconSM - 2),
                      label: Text('add_item'.tr),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(resp.spacingXS),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(resp.radiusXS),
                                ),
                                child: Icon(Icons.format_list_bulleted_rounded,
                                    color: AppColors.primary, size: resp.iconSM - 2),
                              ),
                              SizedBox(width: resp.spacingSM),
                              Expanded(
                                child: Text(
                                  'invoice_items'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: resp.fontLG,
                                  ),
                                ),
                              ),
                              if (_items.isNotEmpty) ...[
                                SizedBox(width: resp.spacingSM),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: resp.spacingSM,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(resp.radiusSM),
                                  ),
                                  child: Text(
                                    '${_items.length}',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: resp.fontXS,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: addBtn,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(resp.spacingXS),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(resp.radiusXS),
                          ),
                          child: Icon(Icons.format_list_bulleted_rounded,
                              color: AppColors.primary, size: resp.iconSM - 2),
                        ),
                        SizedBox(width: resp.spacingSM),
                        Expanded(
                          child: Text(
                            'invoice_items'.tr,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: resp.fontLG,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_items.isNotEmpty) ...[
                          SizedBox(width: resp.spacingSM),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: resp.spacingSM,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(resp.radiusSM),
                            ),
                            child: Text(
                              '${_items.length}',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: resp.fontXS,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                        SizedBox(width: resp.spacingXS),
                        addBtn,
                      ],
                    );
                  },
                ),
                SizedBox(height: resp.spacingXS),

                // Items List or Empty Box
                if (_items.isEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: resp.spacingXL,
                      horizontal: resp.spacingMD,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.02)
                          : Colors.grey.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(resp.cardRadius),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 40,
                              color: isDark ? Colors.grey[600] : Colors.grey[400]),
                          SizedBox(height: resp.spacingSM),
                          Text(
                            'no_items_yet'.tr,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: isDark ? Colors.grey[400] : Colors.grey[500],
                              fontSize: resp.fontSM,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...List.generate(
                    _items.length,
                    (i) => _ItemTile(
                      item: _items[i],
                      currencyCode: currCode,
                      onDelete: () => setState(() => _items.removeAt(i)),
                      onEdit: () => _editItem(i),
                    ),
                  ),

                SizedBox(height: resp.spacingMD),

                // Computed total summary card
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: resp.spacingMD,
                    vertical: resp.spacingSM + 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.08),
                        AppColors.primary.withValues(alpha: 0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(resp.cardRadius),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calculate_outlined,
                              color: AppColors.primary, size: resp.iconSM),
                          SizedBox(width: resp.spacingSM),
                          Text(
                            'total_amount_label'.tr,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: resp.fontMD,
                            ),
                          ),
                        ],
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            CurrencyFormatter.format(_computedTotal,
                                currencyCode: currCode),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w900,
                              fontSize: resp.fontXL,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: resp.spacingMD),

                // Paid amount field
                AmountField(
                  controller: _paidCtrl,
                  label: 'paid_amount_label'.tr,
                  hint: '0',
                  icon: Icons.payments_rounded,
                  currencyCode: currCode,
                  validator: (val) {
                    if (val != null && val.trim().isNotEmpty) {
                      final p = double.tryParse(val.trim());
                      if (p != null && _computedTotal > 0 && p > _computedTotal + 0.0001) {
                        return 'paid_amount_cannot_exceed_total'.tr;
                      }
                    }
                    return null;
                  },
                ),

                SizedBox(height: resp.spacingMD),

                // Notes field
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                  decoration: InputDecoration(
                    labelText: 'notes'.tr,
                    hintText: 'enter_notes'.tr,
                    prefixIcon: Icon(Icons.notes_rounded, size: resp.iconSM),
                  ),
                ),

                SizedBox(height: resp.spacingXL),

                // Submit button
                AppButton(
                  text: isEditing ? 'save'.tr : 'add_invoice_title'.tr,
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: _saving,
                  onPressed: _saving ? null : _save,
                ),

                SizedBox(height: resp.pagePadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final InvoiceItem item;
  final String currencyCode;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ItemTile({
    required this.item,
    required this.currencyCode,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: resp.spacingSM),
      padding: EdgeInsets.symmetric(
        horizontal: resp.spacingSM + 2,
        vertical: resp.spacingSM,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(resp.cardRadius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: resp.fontMD,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: resp.spacingXS,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: resp.spacingXS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(resp.radiusXS),
                      ),
                      child: Text(
                        '${item.quantity} × ${CurrencyFormatter.format(item.unitPrice, currencyCode: currencyCode)}',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: resp.fontXS,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      '= ${CurrencyFormatter.format(item.total, currencyCode: currencyCode)}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: resp.fontXS + 1,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, size: resp.iconSM),
            padding: EdgeInsets.all(resp.spacingXS),
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
            color: AppColors.primary,
            onPressed: onEdit,
          ),
          SizedBox(width: resp.spacing2XS),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: AppColors.give, size: resp.iconSM),
            padding: EdgeInsets.all(resp.spacingXS),
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
