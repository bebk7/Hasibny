import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../models/merchant.dart';
import '../models/invoice.dart';
import '../models/merchant_shortage.dart';

class DatabaseService {
  static late Isar _isar;
  static late Isar _isarMerchants;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [CustomerSchema, TransactionModelSchema],
      directory: dir.path,
      inspector: true,
    );
    _isarMerchants = await Isar.open(
      [MerchantSchema, InvoiceSchema, MerchantShortageSchema],
      directory: dir.path,
      name: 'merchants_db',
      inspector: true,
    );
    _initialized = true;
  }

  static bool get isInitialized => _initialized;
  static Isar get instance => _isar;

  static Future<void> close() async {
    if (_initialized) {
      await _isar.close();
      await _isarMerchants.close();
      _initialized = false;
    }
  }

  // ─── Customer operations ───────────────────────────────────────────────────

  static Future<List<Customer>> getAllCustomers() async {
    return await _isar.customers.where().sortByUpdatedAtDesc().findAll();
  }

  static Future<List<Customer>> getCustomersByCurrency(String currencyCode) async {
    return await _isar.customers
        .filter()
        .currencyCodeEqualTo(currencyCode)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  static Future<Customer?> getCustomerById(int id) async {
    return await _isar.customers.get(id);
  }

  static Future<List<Customer>> searchCustomers(String query) async {
    if (query.isEmpty) return getAllCustomers();

    return await _isar.customers
        .filter()
        .nameContains(query, caseSensitive: false)
        .or()
        .phoneNumberContains(query, caseSensitive: false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  static Future<int> addCustomer(Customer customer) async {
    return await _isar.writeTxn(() async {
      return await _isar.customers.put(customer);
    });
  }

  static Future<void> updateCustomer(Customer customer) async {
    customer.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.customers.put(customer);
    });
  }

  static Future<void> deleteCustomer(int id) async {
    await _isar.writeTxn(() async {
      // Delete associated transactions first
      final transactions =
          await _isar.transactionModels.where().customerIdEqualTo(id).findAll();
      await _isar.transactionModels
          .deleteAll(transactions.map((t) => t.id).toList());

      // Then delete the customer
      await _isar.customers.delete(id);
    });

    // Also delete any customer invoices
    await _isarMerchants.writeTxn(() async {
      final invoices = await _isarMerchants.invoices
          .filter()
          .customerIdEqualTo(id)
          .findAll();
      await _isarMerchants.invoices
          .deleteAll(invoices.map((i) => i.id).toList());
    });
  }

  // ─── Transaction operations ────────────────────────────────────────────────

  static Future<List<TransactionModel>> getTransactionsForCustomer(
      int customerId) async {
    return await _isar.transactionModels
        .where()
        .customerIdEqualTo(customerId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  static Future<List<TransactionModel>> getAllTransactions() async {
    return await _isar.transactionModels
        .where()
        .sortByCreatedAtDesc()
        .findAll();
  }

  static Future<List<TransactionModel>> getTransactionsByCurrency(
      String currencyCode) async {
    return await _isar.transactionModels
        .filter()
        .currencyCodeEqualTo(currencyCode)
        .sortByCreatedAtDesc()
        .findAll();
  }

  static Future<List<TransactionModel>> getRecentTransactions(int limit) async {
    return await _isar.transactionModels
        .where()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }

  static Future<int> addTransaction(TransactionModel transaction) async {
    return await _isar.writeTxn(() async {
      return await _isar.transactionModels.put(transaction);
    });
  }

  static Future<void> updateTransaction(TransactionModel transaction) async {
    await _isar.writeTxn(() async {
      await _isar.transactionModels.put(transaction);
    });
  }

  static Future<void> deleteTransaction(int id) async {
    await _isar.writeTxn(() async {
      await _isar.transactionModels.delete(id);
    });
  }

  // ─── Multi-Currency Analytics operations ───────────────────────────────────

  static Future<double> getTotalToGiveByCurrency(String currencyCode) async {
    final transactions = await _isar.transactionModels
        .filter()
        .currencyCodeEqualTo(currencyCode)
        .and()
        .typeEqualTo(TransactionType.give)
        .findAll();

    return transactions.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  static Future<double> getTotalToGetByCurrency(String currencyCode) async {
    final transactions = await _isar.transactionModels
        .filter()
        .currencyCodeEqualTo(currencyCode)
        .and()
        .typeEqualTo(TransactionType.got)
        .findAll();

    return transactions.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  static Future<Map<String, Map<String, double>>> getTotalsByCurrency() async {
    final all = await getAllTransactions();
    final Map<String, Map<String, double>> result = {
      'YER': {'toGive': 0.0, 'toGet': 0.0, 'net': 0.0},
      'SAR': {'toGive': 0.0, 'toGet': 0.0, 'net': 0.0},
      'USD': {'toGive': 0.0, 'toGet': 0.0, 'net': 0.0},
    };

    for (final t in all) {
      final code = t.currencyCode.isNotEmpty ? t.currencyCode : 'YER';
      if (!result.containsKey(code)) {
        result[code] = {'toGive': 0.0, 'toGet': 0.0, 'net': 0.0};
      }
      if (t.type == TransactionType.give) {
        result[code]!['toGive'] = (result[code]!['toGive'] ?? 0.0) + t.amount;
      } else {
        result[code]!['toGet'] = (result[code]!['toGet'] ?? 0.0) + t.amount;
      }
    }

    for (final entry in result.entries) {
      final toGive = entry.value['toGive'] ?? 0.0;
      final toGet = entry.value['toGet'] ?? 0.0;
      entry.value['net'] = toGet - toGive;
    }

    return result;
  }

  static Future<double> getCustomerBalance(int customerId) async {
    final transactions = await getTransactionsForCustomer(customerId);

    double balance = 0.0;
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.give) {
        balance -= transaction.amount;
      } else {
        balance += transaction.amount;
      }
    }

    return balance;
  }

  static Future<Map<int, double>> getAllCustomerBalances() async {
    final allTransactions = await getAllTransactions();
    final customers = await getAllCustomers();
    final Map<int, double> balances = {};

    for (final customer in customers) {
      balances[customer.id] = 0.0;
    }

    for (final t in allTransactions) {
      final current = balances[t.customerId] ?? 0.0;
      balances[t.customerId] = t.type == TransactionType.give
          ? current - t.amount
          : current + t.amount;
    }

    return balances;
  }

  static Future<void> clearAllData() async {
    await _isar.writeTxn(() async {
      await _isar.transactionModels.clear();
      await _isar.customers.clear();
    });
    await _isarMerchants.writeTxn(() async {
      await _isarMerchants.merchants.clear();
      await _isarMerchants.invoices.clear();
      await _isarMerchants.merchantShortages.clear();
    });
  }

  // ─── Merchant operations ─────────────────────────────────────────────────

  static Future<List<Merchant>> getAllMerchants() async {
    return await _isarMerchants.merchants
        .where()
        .sortByUpdatedAtDesc()
        .findAll();
  }

  static Future<Merchant?> getMerchantById(int id) async {
    return await _isarMerchants.merchants.get(id);
  }

  static Future<List<Merchant>> searchMerchants(String query) async {
    if (query.isEmpty) return getAllMerchants();
    return await _isarMerchants.merchants
        .filter()
        .nameContains(query, caseSensitive: false)
        .or()
        .phoneContains(query, caseSensitive: false)
        .or()
        .addressContains(query, caseSensitive: false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  static Future<int> addMerchant(Merchant merchant) async {
    return await _isarMerchants.writeTxn(() async {
      return await _isarMerchants.merchants.put(merchant);
    });
  }

  static Future<void> updateMerchant(Merchant merchant) async {
    merchant.updatedAt = DateTime.now();
    await _isarMerchants.writeTxn(() async {
      await _isarMerchants.merchants.put(merchant);
    });
  }

  static Future<void> deleteMerchant(int id) async {
    await _isarMerchants.writeTxn(() async {
      final invoices =
          await _isarMerchants.invoices.where().merchantIdEqualTo(id).findAll();
      await _isarMerchants.invoices
          .deleteAll(invoices.map((i) => i.id).toList());
      await _isarMerchants.merchants.delete(id);
    });
  }

  // ─── Invoice operations ──────────────────────────────────────────────────

  static Future<List<Invoice>> getInvoicesForMerchant(int merchantId) async {
    return await _isarMerchants.invoices
        .filter()
        .merchantIdEqualTo(merchantId)
        .sortByDateDesc()
        .findAll();
  }

  static Future<List<Invoice>> getInvoicesForCustomer(int customerId) async {
    return await _isarMerchants.invoices
        .filter()
        .customerIdEqualTo(customerId)
        .sortByDateDesc()
        .findAll();
  }

  static Future<List<Invoice>> getAllInvoices() async {
    return await _isarMerchants.invoices.where().sortByDateDesc().findAll();
  }

  static Future<Invoice?> getInvoiceById(int id) async {
    return await _isarMerchants.invoices.get(id);
  }

  static Future<int> addInvoice(Invoice invoice) async {
    return await _isarMerchants.writeTxn(() async {
      return await _isarMerchants.invoices.put(invoice);
    });
  }

  static Future<void> updateInvoice(Invoice invoice) async {
    invoice.updatedAt = DateTime.now();
    await _isarMerchants.writeTxn(() async {
      await _isarMerchants.invoices.put(invoice);
    });
  }

  static Future<void> deleteInvoice(int id) async {
    await _isarMerchants.writeTxn(() async {
      await _isarMerchants.invoices.delete(id);
    });
  }

  static Future<double> getMerchantTotalOwed(int merchantId) async {
    final invoices = await getInvoicesForMerchant(merchantId);
    return invoices.fold<double>(0.0, (sum, inv) => sum + inv.remainingAmount);
  }

  static Future<List<Map<String, dynamic>>> searchProductAcrossInvoices(
      String query) async {
    if (query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();
    final allInvoices = await _isarMerchants.invoices.where().findAll();
    final allMerchants = await _isarMerchants.merchants.where().findAll();
    final merchantMap = {for (final m in allMerchants) m.id: m};

    final List<Map<String, dynamic>> results = [];
    for (final inv in allInvoices) {
      for (final item in inv.items) {
        if (item.name.toLowerCase().contains(q)) {
          results.add({
            'itemName': item.name,
            'unitPrice': item.unitPrice,
            'quantity': item.quantity,
            'invoiceNumber': inv.invoiceNumber,
            'invoiceDate': inv.date,
            'merchantName': merchantMap[inv.merchantId]?.name ?? '-',
            'merchantId': inv.merchantId,
            'currencyCode': inv.currencyCode,
          });
        }
      }
    }
    results.sort((a, b) =>
        (b['invoiceDate'] as DateTime).compareTo(a['invoiceDate'] as DateTime));
    return results;
  }

  static Future<Map<int, double>> getAllMerchantTotals() async {
    final merchants = await getAllMerchants();
    final Map<int, double> totals = {};
    for (final m in merchants) {
      totals[m.id] = await getMerchantTotalOwed(m.id);
    }
    return totals;
  }

  // ─── Merchant Shortages operations ───────────────────────────────────────

  static Future<List<MerchantShortage>> getAllShortages() async {
    return await _isarMerchants.merchantShortages
        .where()
        .sortByUpdatedAtDesc()
        .findAll();
  }

  static Future<List<MerchantShortage>> getShortagesForMerchant(
      int merchantId) async {
    return await _isarMerchants.merchantShortages
        .filter()
        .merchantIdEqualTo(merchantId)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  static Future<int> addMerchantShortage(MerchantShortage shortage) async {
    return await _isarMerchants.writeTxn(() async {
      return await _isarMerchants.merchantShortages.put(shortage);
    });
  }

  static Future<void> updateMerchantShortage(MerchantShortage shortage) async {
    shortage.updatedAt = DateTime.now();
    await _isarMerchants.writeTxn(() async {
      await _isarMerchants.merchantShortages.put(shortage);
    });
  }

  static Future<void> deleteMerchantShortage(int id) async {
    await _isarMerchants.writeTxn(() async {
      await _isarMerchants.merchantShortages.delete(id);
    });
  }

  // ─── Bulk & Restore operations ──────────────────────────────────────────

  static Future<void> restoreAllData({
    required List<Customer> customers,
    required List<TransactionModel> transactions,
    required List<Merchant> merchants,
    required List<Invoice> invoices,
    required List<MerchantShortage> shortages,
  }) async {
    if (!isInitialized) {
      try {
        await initialize();
      } catch (_) {
        return;
      }
    }
    await _isar.writeTxn(() async {
      await _isar.transactionModels.clear();
      await _isar.customers.clear();
      await _isar.customers.putAll(customers);
      await _isar.transactionModels.putAll(transactions);
    });

    await _isarMerchants.writeTxn(() async {
      await _isarMerchants.merchantShortages.clear();
      await _isarMerchants.invoices.clear();
      await _isarMerchants.merchants.clear();
      await _isarMerchants.merchants.putAll(merchants);
      await _isarMerchants.invoices.putAll(invoices);
      await _isarMerchants.merchantShortages.putAll(shortages);
    });
  }
}
