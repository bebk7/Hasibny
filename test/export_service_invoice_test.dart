import 'package:flutter_test/flutter_test.dart';
import 'package:account_book/services/export_service.dart';
import 'package:account_book/models/invoice.dart';
import 'package:account_book/models/customer.dart';
import 'package:account_book/controllers/settings_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'language': 'ar',
      'currency': 'YER',
    });
    Get.testMode = true;
    if (!Get.isRegistered<SettingsController>()) {
      Get.put(SettingsController());
    }
  });

  test('Generate invoice PDF in YER, SAR, USD and verify bytes', () async {
    for (final curr in ['YER', 'SAR', 'USD']) {
      final invoice = Invoice(
        invoiceNumber: 'INV-$curr-1001',
        totalAmount: 15000.0,
        paidAmount: 5000.0,
        currencyCode: curr,
        notes: 'شكراً لتعاملكم معنا',
      );
      invoice.items = [
        InvoiceItem(name: 'سكر أبيض 50 كجم', quantity: 2, unitPrice: 5000.0),
        InvoiceItem(name: 'زيت طبخ 20 لتر', quantity: 1, unitPrice: 5000.0),
      ];

      final customer = Customer(
        name: 'محمد عبدالله',
        phoneNumber: '777123456',
        currencyCode: curr,
      );

      final bytes = await ExportService.generateInvoicePdfBytes(
        invoice: invoice,
        customer: customer,
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(2000));
    }
  });
}
