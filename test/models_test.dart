import 'package:flutter_test/flutter_test.dart';
import 'package:account_book/models/app_currency.dart';
import 'package:account_book/utils/currency_formatter.dart';
import 'package:account_book/models/customer.dart';
import 'package:account_book/models/transaction.dart';
import 'package:account_book/models/merchant.dart';
import 'package:account_book/models/merchant_shortage.dart';
import 'package:account_book/models/invoice.dart';

void main() {
  group('AppCurrency & CurrencyFormatter Tests', () {
    test('AppCurrency lookup and properties', () {
      final yer = AppCurrency.fromCode('YER');
      expect(yer.code, 'YER');
      expect(yer.nameAr, 'الريال اليمني');
      expect(yer.flag, '🇾🇪');
      expect(yer.decimalDigits, 0);

      final sar = AppCurrency.fromCode('SAR');
      expect(sar.code, 'SAR');
      expect(sar.nameAr, 'الريال السعودي');
      expect(sar.flag, '🇸🇦');
      expect(sar.decimalDigits, 2);

      final usd = AppCurrency.fromCode('USD');
      expect(usd.code, 'USD');
      expect(usd.nameAr, 'الدولار الأمريكي');
      expect(usd.flag, '🇺🇸');
      expect(usd.decimalDigits, 2);

      // Default fallback
      final fallback = AppCurrency.fromCode('INVALID');
      expect(fallback.code, 'YER');
    });

    test('AppCurrency.formatAmount for YER, SAR, USD', () {
      expect(AppCurrency.formatAmount(1500, currencyCode: 'YER', isArabic: true), '1,500 ر.ي');
      expect(AppCurrency.formatAmount(2500.50, currencyCode: 'SAR', isArabic: true), '2,500.5 ر.س');
      expect(AppCurrency.formatAmount(100.0, currencyCode: 'USD', isArabic: true), '\$100');
      expect(AppCurrency.formatAmount(100.75, currencyCode: 'USD', isArabic: true), '\$100.75');
    });

    test('CurrencyFormatter.amountToWords with currency', () {
      final wordsYer = CurrencyFormatter.amountToWords(500, currencyCode: 'YER');
      expect(wordsYer.contains('الريال اليمني') || wordsYer.contains('Five Hundred'), isTrue);

      final wordsUsd = CurrencyFormatter.amountToWords(100, currencyCode: 'USD');
      expect(wordsUsd.contains('الدولار الأمريكي') || wordsUsd.contains('One Hundred'), isTrue);
    });
  });

  group('Models Unit Tests with Multi-Currency', () {
    test('Customer model creation & default/custom currency', () {
      final customerDefault = Customer(
        name: 'Ahmed Ali',
        phoneNumber: '+967774190100',
      );
      expect(customerDefault.name, 'Ahmed Ali');
      expect(customerDefault.currencyCode, 'YER');
      expect(customerDefault.isSynced, false);
      expect(customerDefault.createdAt, isNotNull);

      final customerSar = Customer(
        name: 'Khalid Mohammed',
        phoneNumber: '+966501234567',
        currencyCode: 'SAR',
      );
      expect(customerSar.currencyCode, 'SAR');
    });

    test('TransactionModel creation & currencyCode', () {
      final tGive = TransactionModel(
        amount: 250.0,
        type: TransactionType.give,
        description: 'Store goods',
        customerId: 1,
        currencyCode: 'USD',
      );

      expect(tGive.amount, 250.0);
      expect(tGive.type, TransactionType.give);
      expect(tGive.currencyCode, 'USD');
      expect(tGive.typeString, 'Give');
      expect(tGive.formattedAmount, '-250.00');

      final tGot = TransactionModel(
        amount: 500.0,
        type: TransactionType.got,
        description: 'Payment',
        customerId: 1,
        currencyCode: 'YER',
      );

      expect(tGot.typeString, 'Got');
      expect(tGot.currencyCode, 'YER');
      expect(tGot.formattedAmount, '+500.00');
    });

    test('Merchant model creation', () {
      final merchant = Merchant(
        name: 'Al-Baraka Trading',
        phone: '777123456',
        address: 'Sana\'a, Yemen',
        notes: 'Wholesale supplier',
      );

      expect(merchant.name, 'Al-Baraka Trading');
      expect(merchant.phone, '777123456');
      expect(merchant.address, 'Sana\'a, Yemen');
      expect(merchant.notes, 'Wholesale supplier');
      expect(merchant.createdAt, isNotNull);
    });

    test('MerchantShortage model creation & resolution', () {
      final shortage = MerchantShortage(
        merchantId: 1,
        productName: 'Sugar 50kg',
        quantity: 10,
        note: 'Urgent',
      );

      expect(shortage.productName, 'Sugar 50kg');
      expect(shortage.quantity, 10);
      expect(shortage.isResolved, false);

      shortage.isResolved = true;
      expect(shortage.isResolved, true);
    });

    test('Invoice and InvoiceItem calculations with currencyCode', () {
      final item1 = InvoiceItem(name: 'Item A', quantity: 2, unitPrice: 50.0);
      final item2 = InvoiceItem(name: 'Item B', quantity: 3, unitPrice: 100.0);

      expect(item1.total, 100.0);
      expect(item2.total, 300.0);

      final invoice = Invoice(
        merchantId: 1,
        invoiceNumber: 'INV-2026-001',
        totalAmount: 400.0,
        paidAmount: 150.0,
        currencyCode: 'SAR',
      );

      invoice.items = [item1, item2];

      expect(invoice.remainingAmount, 250.0);
      expect(invoice.isFullyPaid, false);
      expect(invoice.paymentPercentage, 0.375);
      expect(invoice.currencyCode, 'SAR');
      expect(invoice.items.length, 2);
      expect(invoice.items[0].name, 'Item A');
    });
  });
}
