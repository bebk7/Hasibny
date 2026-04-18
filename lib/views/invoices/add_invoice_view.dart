import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/invoice_controller.dart';
import '../../models/invoice.dart';
import '../../themes/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/responsive.dart';
import '../../widgets/amount_field.dart';

class AddInvoiceView extends StatefulWidget {
  final int merchantId;
  final Invoice? invoice;
  const AddInvoiceView({super.key, required this.merchantId, this.invoice});

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
    _numberCtrl =
        TextEditingController(text: widget.invoice?.invoiceNumber ?? '');
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

    Get.dialog(
      AlertDialog(
        title: Text('add_item'.tr),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'item_name'.tr,
                  prefixIcon: const Icon(Icons.inventory_2_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: 'quantity'.tr,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: 'unit_price'.tr,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final qty = double.tryParse(qtyCtrl.text.trim()) ?? 1;
              final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
              if (name.isEmpty || price <= 0) return;
              setState(() {
                _items.add(InvoiceItem(
                    name: name, quantity: qty, unitPrice: price));
              });
              Get.back();
            },
            child: Text('add'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      Get.snackbar('error'.tr, 'add_at_least_one_item'.tr,
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
      return;
    }
    setState(() => _saving = true);

    final ic = Get.find<InvoiceController>();
    final total = _computedTotal;
    final paid = double.tryParse(_paidCtrl.text.trim()) ?? 0.0;

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
        invoiceNumber: _numberCtrl.text.trim(),
        totalAmount: total,
        paidAmount: paid,
        notes:
            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      inv.items = _items;
      Get.back();
      ic.addInvoice(inv);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'edit_invoice'.tr : 'add_invoice_title'.tr,
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
              _field(
                controller: _numberCtrl,
                label: 'invoice_number'.tr,
                hint: 'enter_invoice_number'.tr,
                icon: Icons.tag_rounded,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'enter_invoice_number'.tr
                    : null,
              ),
              const SizedBox(height: 20),

              // ─── Items section ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('invoice_items'.tr,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: Text('add_item'.tr),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (_items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.15)),
                  ),
                  child: Center(
                    child: Text('no_items_yet'.tr,
                        style: TextStyle(color: Colors.grey[400])),
                  ),
                )
              else
                ...List.generate(_items.length, (i) => _ItemTile(
                      item: _items[i],
                      onDelete: () => setState(() => _items.removeAt(i)),
                      onEdit: () => _editItem(i),
                    )),

              // ─── Total ────────────────────────────────────
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('total_amount_label'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(CurrencyFormatter.format(_computedTotal),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: AppTheme.primaryColor)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AmountField(
                controller: _paidCtrl,
                label: 'paid_amount_label'.tr,
                hint: '0',
                icon: Icons.payments_rounded,
              ),
              const SizedBox(height: 16),
              _field(
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
                          isEditing ? 'save'.tr : 'add_invoice_title'.tr,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _editItem(int index) {
    final item = _items[index];
    final nameCtrl = TextEditingController(text: item.name);
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    final priceCtrl = TextEditingController(text: item.unitPrice.toString());

    Get.dialog(
      AlertDialog(
        title: Text('edit_item'.tr),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'item_name'.tr,
                  prefixIcon: const Icon(Icons.inventory_2_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: 'quantity'.tr,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: 'unit_price'.tr,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final qty = double.tryParse(qtyCtrl.text.trim()) ?? 1;
              final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
              if (name.isEmpty || price <= 0) return;
              setState(() {
                _items[index] = InvoiceItem(
                    name: name, quantity: qty, unitPrice: price);
              });
              Get.back();
            },
            child: Text('save'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _field({
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

class _ItemTile extends StatelessWidget {
  final InvoiceItem item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  const _ItemTile(
      {required this.item, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.08),
          child: const Icon(Icons.inventory_2_rounded,
              size: 18, color: AppTheme.primaryColor),
        ),
        title: Text(item.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(
            '${item.quantity} × ${CurrencyFormatter.format(item.unitPrice)}',
            style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(CurrencyFormatter.format(item.total),
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: AppTheme.primaryColor)),
            const SizedBox(width: 4),
            InkWell(
              onTap: onEdit,
              child: const Icon(Icons.edit_outlined,
                  size: 18, color: Colors.grey),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onDelete,
              child: Icon(Icons.close, size: 18, color: Colors.red[300]),
            ),
          ],
        ),
      ),
    );
  }
}
