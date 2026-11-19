import 'dart:convert';
import 'package:isar_community/isar.dart';

part 'invoice.g.dart';

class InvoiceItem {
  String name;
  double quantity;
  double unitPrice;

  InvoiceItem({
    required this.name,
    this.quantity = 1,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  Map<String, dynamic> toMap() => {
        'name': name,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };

  factory InvoiceItem.fromMap(Map<String, dynamic> m) => InvoiceItem(
        name: m['name'] ?? '',
        quantity: (m['quantity'] ?? 1).toDouble(),
        unitPrice: (m['unitPrice'] ?? 0).toDouble(),
      );
}

@Collection()
class Invoice {
  Id id = Isar.autoIncrement;

  String? firestoreId;
  bool isSynced = false;

  @Index()
  int? merchantId;

  @Index()
  int? customerId;

  late String invoiceNumber;
  late double totalAmount;
  late double paidAmount;

  /// Currency code is immutable per invoice (YER, SAR, USD)
  String currencyCode = 'YER';

  String? notes;
  String? itemsJson;

  // ─── WhatsApp Delivery Tracking ──────────────────────────────────────────
  bool whatsappSendingEnabled = false;

  /// Delivery status: 'none' | 'pending' | 'sending' | 'sent' | 'failed'
  String whatsappStatus = 'none';

  String? whatsappMessageId;
  DateTime? whatsappSentAt;
  String? whatsappError;
  String? pdfUrl;

  /// Unique token per dispatch operation to prevent duplicate WhatsApp deliveries
  String? idempotencyKey;

  @Index()
  late DateTime date;

  late DateTime createdAt;
  late DateTime updatedAt;

  Invoice({
    this.merchantId,
    this.customerId,
    required this.invoiceNumber,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.currencyCode = 'YER',
    this.notes,
    this.itemsJson,
    this.whatsappSendingEnabled = false,
    this.whatsappStatus = 'none',
    this.whatsappMessageId,
    this.whatsappSentAt,
    this.whatsappError,
    this.pdfUrl,
    this.idempotencyKey,
  }) {
    date = DateTime.now();
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  bool get isCustomerInvoice => customerId != null;
  bool get isMerchantInvoice => merchantId != null;

  double get remainingAmount => (totalAmount - paidAmount).clamp(0.0, double.infinity);

  bool get isFullyPaid => paidAmount >= totalAmount;

  double get paymentPercentage =>
      totalAmount > 0 ? (paidAmount / totalAmount).clamp(0.0, 1.0) : 0.0;

  @ignore
  List<InvoiceItem> get items {
    if (itemsJson == null || itemsJson!.isEmpty) return [];
    try {
      final list = jsonDecode(itemsJson!) as List;
      return list
          .map((e) => InvoiceItem.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  set items(List<InvoiceItem> value) {
    itemsJson = jsonEncode(value.map((e) => e.toMap()).toList());
  }
}
