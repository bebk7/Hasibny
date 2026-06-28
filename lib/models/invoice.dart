// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types
import 'dart:convert';
import 'package:isar/isar.dart';

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

  @Index()
  late int merchantId;

  late String invoiceNumber;
  late double totalAmount;
  late double paidAmount;

  String? notes;
  String? itemsJson;

  @Index()
  late DateTime date;

  late DateTime createdAt;
  late DateTime updatedAt;
  
  @Index()
  String? firestoreId;
  
  bool isSynced = false;

  Invoice({
    required this.merchantId,
    required this.invoiceNumber,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.notes,
    this.itemsJson,
  }) {
    date = DateTime.now();
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  double get remainingAmount => totalAmount - paidAmount;

  bool get isFullyPaid => paidAmount >= totalAmount;

  double get paymentPercentage =>
      totalAmount > 0 ? (paidAmount / totalAmount).clamp(0.0, 1.0) : 0.0;

  @ignore
  List<InvoiceItem> get items {
    if (itemsJson == null || itemsJson!.isEmpty) return [];
    final list = jsonDecode(itemsJson!) as List;
    return list.map((e) => InvoiceItem.fromMap(e as Map<String, dynamic>)).toList();
  }

  set items(List<InvoiceItem> value) {
    itemsJson = jsonEncode(value.map((e) => e.toMap()).toList());
  }
}
