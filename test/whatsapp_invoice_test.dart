import 'package:flutter_test/flutter_test.dart';
import 'package:account_book/models/customer.dart';
import 'package:account_book/models/invoice.dart';
import 'package:account_book/services/whatsapp_service.dart';

void main() {
  group('WhatsApp Invoice Integration Tests', () {
    test('Customer model handles WhatsApp settings correctly', () {
      final customer = Customer(
        name: 'أحمد محمد',
        phoneNumber: '771234567',
        autoSendInvoiceWhatsApp: true,
        whatsappNumber: '+967771234567',
      );

      expect(customer.autoSendInvoiceWhatsApp, true);
      expect(customer.effectiveWhatsAppNumber, '+967771234567');
      expect(customer.normalizedWhatsAppNumber, '+967771234567');
      expect(customer.hasValidWhatsApp, true);
    });

    test('Customer falls back to primary phoneNumber if whatsappNumber is null', () {
      final customer = Customer(
        name: 'محمد علي',
        phoneNumber: '779876543',
        autoSendInvoiceWhatsApp: false,
      );

      expect(customer.autoSendInvoiceWhatsApp, false);
      expect(customer.effectiveWhatsAppNumber, '779876543');
      expect(customer.normalizedWhatsAppNumber, '+967779876543');
      expect(customer.hasValidWhatsApp, true);
    });

    test('Invoice model tracks WhatsApp status and currency correctly', () {
      final invoice = Invoice(
        customerId: 1,
        invoiceNumber: 'INV-1001',
        currencyCode: 'SAR',
        totalAmount: 500.0,
        paidAmount: 200.0,
      );
      invoice.items = [
        InvoiceItem(name: 'Item 1', quantity: 2, unitPrice: 250.0),
      ];

      expect(invoice.customerId, 1);
      expect(invoice.currencyCode, 'SAR');
      expect(invoice.totalAmount, 500.0);
      expect(invoice.remainingAmount, 300.0);
      expect(invoice.isFullyPaid, false);
      expect(invoice.whatsappStatus, 'none');
      expect(invoice.whatsappSendingEnabled, false);

      invoice.whatsappStatus = 'sent';
      invoice.whatsappMessageId = 'wamid.123456789';
      invoice.whatsappSentAt = DateTime(2026, 8, 23, 18, 30);

      expect(invoice.whatsappStatus, 'sent');
      expect(invoice.whatsappMessageId, 'wamid.123456789');
      expect(invoice.whatsappSentAt, isNotNull);
    });

    test('WhatsAppService shouldAutoSend checks all required gates', () {
      final eligibleCustomer = Customer(
        name: 'صالح علي',
        phoneNumber: '771234567',
        autoSendInvoiceWhatsApp: true,
      );

      // Without SettingsController registered, defaults to true
      final canSend = WhatsAppService.shouldAutoSend(customer: eligibleCustomer);
      expect(canSend, true);

      final disabledCustomer = Customer(
        name: 'خالد عمر',
        phoneNumber: '771234567',
        autoSendInvoiceWhatsApp: false,
      );
      expect(WhatsAppService.shouldAutoSend(customer: disabledCustomer), false);

      final invalidPhoneCustomer = Customer(
        name: 'عميل بدون رقم',
        phoneNumber: 'invalid_num',
        autoSendInvoiceWhatsApp: true,
      );
      expect(WhatsAppService.shouldAutoSend(customer: invalidPhoneCustomer), false);
    });
  });
}
