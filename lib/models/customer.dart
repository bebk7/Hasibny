import 'package:isar_community/isar.dart';
import '../utils/phone_number_helper.dart';

part 'customer.g.dart';

@Collection()
class Customer {
  Id id = Isar.autoIncrement;

  String? firestoreId;
  bool isSynced = false;

  late String name;
  late String phoneNumber;
  String? profilePicturePath;

  @Index()
  String currencyCode = 'YER';

  /// WhatsApp delivery settings
  bool autoSendInvoiceWhatsApp = false;
  String? whatsappNumber;

  @Index()
  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;

  Customer({
    required this.name,
    required this.phoneNumber,
    this.profilePicturePath,
    this.currencyCode = 'YER',
    this.autoSendInvoiceWhatsApp = false,
    this.whatsappNumber,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Returns the effective WhatsApp phone number (dedicated WhatsApp number if provided, otherwise primary phone).
  String get effectiveWhatsAppNumber {
    if (whatsappNumber != null && whatsappNumber!.trim().isNotEmpty) {
      return whatsappNumber!.trim();
    }
    return phoneNumber.trim();
  }

  /// Returns normalized E.164 WhatsApp number (+XXXXXXXXXXX).
  String get normalizedWhatsAppNumber =>
      PhoneNumberHelper.normalizeToE164(effectiveWhatsAppNumber);

  /// Checks whether this customer has a valid WhatsApp phone number format.
  bool get hasValidWhatsApp =>
      PhoneNumberHelper.isValidE164(effectiveWhatsAppNumber);

  /// Computed property for total balance (calculated from transactions)
  double get totalBalance => 0.0; // This will be calculated in controller

  // Helper method to check if customer owes money (negative balance)
  bool get owesMoney => totalBalance < 0;

  // Helper method to get formatted balance
  String get formattedBalance {
    final amount = totalBalance.abs();
    final prefix = totalBalance >= 0 ? '+' : '-';
    return '$prefix${amount.toStringAsFixed(2)}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
