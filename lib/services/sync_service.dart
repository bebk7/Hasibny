import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../models/merchant.dart';
import '../models/invoice.dart';
import '../models/merchant_shortage.dart';
import '../themes/app_theme.dart';
import 'database_service.dart';

class SyncService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;
  static bool get _isAuthenticated => _auth.currentUser != null;

  // ─── Collection refs ───────────────────────────────────────────────────────
  static CollectionReference<Map<String, dynamic>>? get _customers {
    final uid = _uid;
    return uid == null ? null : _db.collection('users/$uid/customers');
  }

  static CollectionReference<Map<String, dynamic>>? get _transactions {
    final uid = _uid;
    return uid == null ? null : _db.collection('users/$uid/transactions');
  }

  static CollectionReference<Map<String, dynamic>>? get _merchants {
    final uid = _uid;
    return uid == null ? null : _db.collection('users/$uid/merchants');
  }

  static CollectionReference<Map<String, dynamic>>? get _invoices {
    final uid = _uid;
    return uid == null ? null : _db.collection('users/$uid/invoices');
  }

  static CollectionReference<Map<String, dynamic>>? get _shortages {
    final uid = _uid;
    return uid == null ? null : _db.collection('users/$uid/shortages');
  }

  // ─── Upload individual entities ────────────────────────────────────────────

  static void uploadCustomer(Customer c) {
    if (!_isAuthenticated) return;
    _customers?.doc('${c.id}').set({
      'id': c.id,
      'name': c.name,
      'phoneNumber': c.phoneNumber,
      'profilePicturePath': c.profilePicturePath,
      'createdAt': c.createdAt.toIso8601String(),
      'updatedAt': c.updatedAt.toIso8601String(),
    }).catchError(_onError);
  }

  static void deleteCustomerRemote(int id) {
    if (!_isAuthenticated) return;
    _customers?.doc('$id').delete().catchError(_onError);
    _transactions?.where('customerId', isEqualTo: id).get().then((snap) {
      final batch = _db.batch();
      for (final d in snap.docs) batch.delete(d.reference);
      batch.commit();
    }).catchError(_onError);
  }

  static void uploadTransaction(TransactionModel t) {
    if (!_isAuthenticated) return;
    _transactions?.doc('${t.id}').set({
      'id': t.id,
      'amount': t.amount,
      'type': t.type.name,
      'description': t.description,
      'customerId': t.customerId,
      'createdAt': t.createdAt.toIso8601String(),
    }).catchError(_onError);
  }

  static void deleteTransactionRemote(int id) {
    if (!_isAuthenticated) return;
    _transactions?.doc('$id').delete().catchError(_onError);
  }

  static void uploadMerchant(Merchant m) {
    if (!_isAuthenticated) return;
    _merchants?.doc('${m.id}').set({
      'id': m.id,
      'name': m.name,
      'phone': m.phone,
      'address': m.address,
      'notes': m.notes,
      'createdAt': m.createdAt.toIso8601String(),
      'updatedAt': m.updatedAt.toIso8601String(),
    }).catchError(_onError);
  }

  static void deleteMerchantRemote(int id) {
    if (!_isAuthenticated) return;
    _merchants?.doc('$id').delete().catchError(_onError);
    _invoices?.where('merchantId', isEqualTo: id).get().then((snap) {
      final batch = _db.batch();
      for (final d in snap.docs) batch.delete(d.reference);
      batch.commit();
    }).catchError(_onError);
  }

  static void uploadInvoice(Invoice inv) {
    if (!_isAuthenticated) return;
    _invoices?.doc('${inv.id}').set({
      'id': inv.id,
      'merchantId': inv.merchantId,
      'invoiceNumber': inv.invoiceNumber,
      'totalAmount': inv.totalAmount,
      'paidAmount': inv.paidAmount,
      'notes': inv.notes,
      'itemsJson': inv.itemsJson,
      'date': inv.date.toIso8601String(),
      'createdAt': inv.createdAt.toIso8601String(),
      'updatedAt': inv.updatedAt.toIso8601String(),
    }).catchError(_onError);
  }

  static void deleteInvoiceRemote(int id) {
    if (!_isAuthenticated) return;
    _invoices?.doc('$id').delete().catchError(_onError);
  }

  static void uploadShortage(MerchantShortage s) {
    if (!_isAuthenticated) return;
    _shortages?.doc('${s.id}').set({
      'id': s.id,
      'merchantId': s.merchantId,
      'productName': s.productName,
      'quantity': s.quantity,
      'note': s.note,
      'isResolved': s.isResolved,
      'createdAt': s.createdAt.toIso8601String(),
      'updatedAt': s.updatedAt.toIso8601String(),
    }).catchError(_onError);
  }

  static void deleteShortageRemote(int id) {
    if (!_isAuthenticated) return;
    _shortages?.doc('$id').delete().catchError(_onError);
  }

  // ─── Check if Firestore has data for this user ─────────────────────────────

  static Future<bool> hasRemoteData() async {
    if (!_isAuthenticated) return false;
    try {
      final snap = await _customers?.limit(1).get();
      return snap?.docs.isNotEmpty ?? false;
    } catch (_) {
      return false;
    }
  }

  // ─── Upload all local data to Firestore (first-time sync) ──────────────────

  static Future<void> uploadAll() async {
    if (!_isAuthenticated) return;
    try {
      final customers = await DatabaseService.getAllCustomers();
      for (final c in customers) uploadCustomer(c);

      final transactions = await DatabaseService.getAllTransactions();
      for (final t in transactions) uploadTransaction(t);

      final merchants = await DatabaseService.getAllMerchants();
      for (final m in merchants) uploadMerchant(m);

      final invoices = await DatabaseService.getAllInvoices();
      for (final inv in invoices) uploadInvoice(inv);

      final shortages = await DatabaseService.getAllShortages();
      for (final s in shortages) uploadShortage(s);
    } catch (e) {
      debugPrint('SyncService.uploadAll error: $e');
    }
  }

  // ─── Download all Firestore data into Isar (new device login) ─────────────

  static Future<void> downloadAll() async {
    if (!_isAuthenticated) return;
    try {
      await _downloadCustomers();
      await _downloadTransactions();
      await _downloadMerchants();
      await _downloadInvoices();
      await _downloadShortages();
    } catch (e) {
      debugPrint('SyncService.downloadAll error: $e');
      Get.snackbar(
        'sync_error'.tr,
        'sync_error_msg'.tr,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  static Future<void> _downloadCustomers() async {
    final snap = await _customers?.get();
    if (snap == null) return;
    for (final doc in snap.docs) {
      final d = doc.data();
      final c = Customer(
        name: d['name'] ?? '',
        phoneNumber: d['phoneNumber'] ?? '',
        profilePicturePath: d['profilePicturePath'] as String?,
      );
      c.id = (d['id'] as num).toInt();
      c.createdAt = DateTime.parse(d['createdAt'] as String);
      c.updatedAt = DateTime.parse(d['updatedAt'] as String);
      await DatabaseService.addCustomer(c);
    }
  }

  static Future<void> _downloadTransactions() async {
    final snap = await _transactions?.get();
    if (snap == null) return;
    for (final doc in snap.docs) {
      final d = doc.data();
      final t = TransactionModel(
        amount: (d['amount'] as num).toDouble(),
        type: d['type'] == 'give' ? TransactionType.give : TransactionType.got,
        description: d['description'] ?? '',
        customerId: (d['customerId'] as num).toInt(),
      );
      t.id = (d['id'] as num).toInt();
      t.createdAt = DateTime.parse(d['createdAt'] as String);
      await DatabaseService.addTransaction(t);
    }
  }

  static Future<void> _downloadMerchants() async {
    final snap = await _merchants?.get();
    if (snap == null) return;
    for (final doc in snap.docs) {
      final d = doc.data();
      final m = Merchant(
        name: d['name'] ?? '',
        phone: d['phone'] ?? '',
        address: d['address'] ?? '',
        notes: d['notes'] as String?,
      );
      m.id = (d['id'] as num).toInt();
      m.createdAt = DateTime.parse(d['createdAt'] as String);
      m.updatedAt = DateTime.parse(d['updatedAt'] as String);
      await DatabaseService.addMerchant(m);
    }
  }

  static Future<void> _downloadInvoices() async {
    final snap = await _invoices?.get();
    if (snap == null) return;
    for (final doc in snap.docs) {
      final d = doc.data();
      final inv = Invoice(
        merchantId: (d['merchantId'] as num).toInt(),
        invoiceNumber: d['invoiceNumber'] ?? '',
        totalAmount: (d['totalAmount'] as num).toDouble(),
        paidAmount: (d['paidAmount'] as num? ?? 0).toDouble(),
        notes: d['notes'] as String?,
        itemsJson: d['itemsJson'] as String?,
      );
      inv.id = (d['id'] as num).toInt();
      inv.date = DateTime.parse(d['date'] as String);
      inv.createdAt = DateTime.parse(d['createdAt'] as String);
      inv.updatedAt = DateTime.parse(d['updatedAt'] as String);
      await DatabaseService.addInvoice(inv);
    }
  }

  static Future<void> _downloadShortages() async {
    final snap = await _shortages?.get();
    if (snap == null) return;
    for (final doc in snap.docs) {
      final d = doc.data();
      final s = MerchantShortage(
        merchantId:
            d['merchantId'] != null ? (d['merchantId'] as num).toInt() : null,
        productName: d['productName'] ?? '',
        quantity:
            d['quantity'] != null ? (d['quantity'] as num).toDouble() : null,
        note: d['note'] as String?,
        isResolved: d['isResolved'] as bool? ?? false,
      );
      s.id = (d['id'] as num).toInt();
      s.createdAt = DateTime.parse(d['createdAt'] as String);
      s.updatedAt = DateTime.parse(d['updatedAt'] as String);
      await DatabaseService.addMerchantShortage(s);
    }
  }

  static dynamic _onError(dynamic e) {
    debugPrint('SyncService error: $e');
  }
}
