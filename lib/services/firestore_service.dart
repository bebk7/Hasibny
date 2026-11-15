import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../models/merchant.dart';
import '../models/invoice.dart';
import '../models/merchant_shortage.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get _uid => _auth.currentUser?.uid ?? '';

  static CollectionReference<Map<String, dynamic>> get _customers =>
      _db.collection('users/$_uid/customers');
  static CollectionReference<Map<String, dynamic>> get _transactions =>
      _db.collection('users/$_uid/transactions');
  static CollectionReference<Map<String, dynamic>> get _merchants =>
      _db.collection('users/$_uid/merchants');
  static CollectionReference<Map<String, dynamic>> get _invoices =>
      _db.collection('users/$_uid/invoices');
  static CollectionReference<Map<String, dynamic>> get _shortages =>
      _db.collection('users/$_uid/shortages');

  // ─── Customers ─────────────────────────────────────────────────────────────
  
  static Future<String> addCustomer(Customer c) async {
    final doc = _customers.doc();
    c.firestoreId = doc.id;
    await doc.set(_customerToMap(c));
    return doc.id;
  }

  static Future<void> updateCustomer(Customer c) async {
    if (c.firestoreId == null) {
      await addCustomer(c);
      return;
    }
    await _customers.doc(c.firestoreId).set(_customerToMap(c));
  }

  static Future<void> deleteCustomer(String firestoreId, int localId) async {
    await _customers.doc(firestoreId).delete();
    final snap = await _transactions.where('customerId', isEqualTo: localId).get();
    final batch = _db.batch();
    for (final doc in snap.docs) batch.delete(doc.reference);
    await batch.commit();
  }

  static Map<String, dynamic> _customerToMap(Customer c) => {
        'id': c.id,
        'name': c.name,
        'phoneNumber': c.phoneNumber,
        'profilePicturePath': c.profilePicturePath,
        'currencyCode': c.currencyCode,
        'autoSendInvoiceWhatsApp': c.autoSendInvoiceWhatsApp,
        'whatsappNumber': c.whatsappNumber,
        'createdAt': c.createdAt.toIso8601String(),
        'updatedAt': c.updatedAt.toIso8601String(),
        'firestoreId': c.firestoreId,
      };

  static Customer customerFromMap(Map<String, dynamic> d) {
    final c = Customer(
      name: d['name'] ?? '',
      phoneNumber: d['phoneNumber'] ?? '',
      profilePicturePath: d['profilePicturePath'] as String?,
      currencyCode: d['currencyCode'] as String? ?? 'YER',
      autoSendInvoiceWhatsApp: d['autoSendInvoiceWhatsApp'] as bool? ?? false,
      whatsappNumber: d['whatsappNumber'] as String?,
    );
    c.id = (d['id'] as num).toInt();
    c.createdAt = DateTime.parse(d['createdAt'] as String);
    c.updatedAt = DateTime.parse(d['updatedAt'] as String);
    c.firestoreId = d['firestoreId'] as String?;
    c.isSynced = true;
    return c;
  }

  // ─── Transactions ──────────────────────────────────────────────────────────

  static Future<String> addTransaction(TransactionModel t) async {
    final doc = _transactions.doc();
    t.firestoreId = doc.id;
    await doc.set(_transactionToMap(t));
    return doc.id;
  }

  static Future<void> updateTransaction(TransactionModel t) async {
    if (t.firestoreId == null) {
      await addTransaction(t);
      return;
    }
    await _transactions.doc(t.firestoreId).set(_transactionToMap(t));
  }

  static Future<void> deleteTransaction(String firestoreId) async {
    await _transactions.doc(firestoreId).delete();
  }

  static Map<String, dynamic> _transactionToMap(TransactionModel t) => {
        'id': t.id,
        'amount': t.amount,
        'type': t.type.name,
        'description': t.description,
        'customerId': t.customerId,
        'currencyCode': t.currencyCode,
        'createdAt': t.createdAt.toIso8601String(),
        'firestoreId': t.firestoreId,
      };

  static TransactionModel transactionFromMap(Map<String, dynamic> d) {
    final t = TransactionModel(
      amount: (d['amount'] as num).toDouble(),
      type: d['type'] == 'give' ? TransactionType.give : TransactionType.got,
      description: d['description'] ?? '',
      customerId: (d['customerId'] as num).toInt(),
      currencyCode: d['currencyCode'] as String? ?? 'YER',
    );
    t.id = (d['id'] as num).toInt();
    t.createdAt = DateTime.parse(d['createdAt'] as String);
    t.firestoreId = d['firestoreId'] as String?;
    t.isSynced = true;
    return t;
  }

  // ─── Merchants ─────────────────────────────────────────────────────────────

  static Future<String> addMerchant(Merchant m) async {
    final doc = _merchants.doc();
    m.firestoreId = doc.id;
    await doc.set(_merchantToMap(m));
    return doc.id;
  }

  static Future<void> updateMerchant(Merchant m) async {
    if (m.firestoreId == null) {
      await addMerchant(m);
      return;
    }
    await _merchants.doc(m.firestoreId).set(_merchantToMap(m));
  }

  static Future<void> deleteMerchant(String firestoreId, int localId) async {
    await _merchants.doc(firestoreId).delete();
    final snap = await _invoices.where('merchantId', isEqualTo: localId).get();
    final batch = _db.batch();
    for (final doc in snap.docs) batch.delete(doc.reference);
    await batch.commit();
  }

  static Map<String, dynamic> _merchantToMap(Merchant m) => {
        'id': m.id,
        'name': m.name,
        'phone': m.phone,
        'address': m.address,
        'notes': m.notes,
        'createdAt': m.createdAt.toIso8601String(),
        'updatedAt': m.updatedAt.toIso8601String(),
        'firestoreId': m.firestoreId,
      };

  static Merchant merchantFromMap(Map<String, dynamic> d) {
    final m = Merchant(
      name: d['name'] ?? '',
      phone: d['phone'] ?? '',
      address: d['address'] ?? '',
      notes: d['notes'] as String?,
    );
    m.id = (d['id'] as num).toInt();
    m.createdAt = DateTime.parse(d['createdAt'] as String);
    m.updatedAt = DateTime.parse(d['updatedAt'] as String);
    m.firestoreId = d['firestoreId'] as String?;
    m.isSynced = true;
    return m;
  }

  // ─── Invoices ──────────────────────────────────────────────────────────────

  static Future<String> addInvoice(Invoice inv) async {
    final doc = _invoices.doc();
    inv.firestoreId = doc.id;
    await doc.set(_invoiceToMap(inv));
    return doc.id;
  }

  static Future<void> updateInvoice(Invoice inv) async {
    if (inv.firestoreId == null) {
      await addInvoice(inv);
      return;
    }
    await _invoices.doc(inv.firestoreId).set(_invoiceToMap(inv));
  }

  static Future<void> deleteInvoice(String firestoreId) async {
    await _invoices.doc(firestoreId).delete();
  }

  static Map<String, dynamic> _invoiceToMap(Invoice inv) => {
        'id': inv.id,
        'merchantId': inv.merchantId,
        'customerId': inv.customerId,
        'invoiceNumber': inv.invoiceNumber,
        'totalAmount': inv.totalAmount,
        'paidAmount': inv.paidAmount,
        'currencyCode': inv.currencyCode,
        'notes': inv.notes,
        'itemsJson': inv.itemsJson,
        'whatsappSendingEnabled': inv.whatsappSendingEnabled,
        'whatsappStatus': inv.whatsappStatus,
        'whatsappMessageId': inv.whatsappMessageId,
        'whatsappSentAt': inv.whatsappSentAt?.toIso8601String(),
        'whatsappError': inv.whatsappError,
        'pdfUrl': inv.pdfUrl,
        'idempotencyKey': inv.idempotencyKey,
        'date': inv.date.toIso8601String(),
        'createdAt': inv.createdAt.toIso8601String(),
        'updatedAt': inv.updatedAt.toIso8601String(),
        'firestoreId': inv.firestoreId,
      };

  static Invoice invoiceFromMap(Map<String, dynamic> d) {
    final inv = Invoice(
      merchantId: d['merchantId'] != null ? (d['merchantId'] as num).toInt() : null,
      customerId: d['customerId'] != null ? (d['customerId'] as num).toInt() : null,
      invoiceNumber: d['invoiceNumber'] ?? '',
      totalAmount: (d['totalAmount'] as num).toDouble(),
      paidAmount: (d['paidAmount'] as num? ?? 0).toDouble(),
      currencyCode: d['currencyCode'] as String? ?? 'YER',
      notes: d['notes'] as String?,
      itemsJson: d['itemsJson'] as String?,
      whatsappSendingEnabled: d['whatsappSendingEnabled'] as bool? ?? false,
      whatsappStatus: d['whatsappStatus'] as String? ?? 'none',
      whatsappMessageId: d['whatsappMessageId'] as String?,
      whatsappSentAt: d['whatsappSentAt'] != null
          ? DateTime.tryParse(d['whatsappSentAt'] as String)
          : null,
      whatsappError: d['whatsappError'] as String?,
      pdfUrl: d['pdfUrl'] as String?,
      idempotencyKey: d['idempotencyKey'] as String?,
    );
    inv.id = (d['id'] as num).toInt();
    inv.date = DateTime.parse(d['date'] as String);
    inv.createdAt = DateTime.parse(d['createdAt'] as String);
    inv.updatedAt = DateTime.parse(d['updatedAt'] as String);
    inv.firestoreId = d['firestoreId'] as String?;
    inv.isSynced = true;
    return inv;
  }

  // ─── Shortages ─────────────────────────────────────────────────────────────

  static Future<String> addShortage(MerchantShortage s) async {
    final doc = _shortages.doc();
    s.firestoreId = doc.id;
    await doc.set(_shortageToMap(s));
    return doc.id;
  }

  static Future<void> updateShortage(MerchantShortage s) async {
    if (s.firestoreId == null) {
      await addShortage(s);
      return;
    }
    await _shortages.doc(s.firestoreId).set(_shortageToMap(s));
  }

  static Future<void> deleteShortage(String firestoreId) async {
    await _shortages.doc(firestoreId).delete();
  }

  static Map<String, dynamic> _shortageToMap(MerchantShortage s) => {
        'id': s.id,
        'merchantId': s.merchantId,
        'productName': s.productName,
        'quantity': s.quantity,
        'note': s.note,
        'isResolved': s.isResolved,
        'createdAt': s.createdAt.toIso8601String(),
        'updatedAt': s.updatedAt.toIso8601String(),
        'firestoreId': s.firestoreId,
      };

  static MerchantShortage shortageFromMap(Map<String, dynamic> d) {
    final s = MerchantShortage(
      merchantId: d['merchantId'] != null ? (d['merchantId'] as num).toInt() : null,
      productName: d['productName'] ?? '',
      quantity: d['quantity'] != null ? (d['quantity'] as num).toDouble() : null,
      note: d['note'] as String?,
      isResolved: d['isResolved'] as bool? ?? false,
    );
    s.id = (d['id'] as num).toInt();
    s.createdAt = DateTime.parse(d['createdAt'] as String);
    s.updatedAt = DateTime.parse(d['updatedAt'] as String);
    s.firestoreId = d['firestoreId'] as String?;
    s.isSynced = true;
    return s;
  }

  // ─── Initial Download ──────────────────────────────────────────────────────

  static Future<Map<String, List<dynamic>>> downloadAll() async {
    if (_uid.isEmpty) return {};
    
    final customersSnap = await _customers.get();
    final transactionsSnap = await _transactions.get();
    final merchantsSnap = await _merchants.get();
    final invoicesSnap = await _invoices.get();
    final shortagesSnap = await _shortages.get();

    return {
      'customers': customersSnap.docs.map((d) => customerFromMap(d.data())).toList(),
      'transactions': transactionsSnap.docs.map((d) => transactionFromMap(d.data())).toList(),
      'merchants': merchantsSnap.docs.map((d) => merchantFromMap(d.data())).toList(),
      'invoices': invoicesSnap.docs.map((d) => invoiceFromMap(d.data())).toList(),
      'shortages': shortagesSnap.docs.map((d) => shortageFromMap(d.data())).toList(),
    };
  }

  static Future<bool> hasRemoteData() async {
    if (_uid.isEmpty) return false;
    try {
      final snap = await _customers.limit(1).get();
      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
