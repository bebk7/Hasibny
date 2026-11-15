import 'package:get/get.dart';
import 'package:isar_community/isar.dart';

part 'transaction.g.dart';

enum TransactionType { give, got }

@Collection()
class TransactionModel {
  Id id = Isar.autoIncrement;

  String? firestoreId;
  bool isSynced = false;

  late double amount;
  @Enumerated(EnumType.name)
  late TransactionType type;
  late String description;

  @Index()
  String currencyCode = 'YER';

  @Index()
  late DateTime createdAt;

  @Index()
  late int customerId;

  TransactionModel({
    required this.amount,
    required this.type,
    required this.description,
    required this.customerId,
    this.currencyCode = 'YER',
  }) {
    createdAt = DateTime.now();
  }

  // Helper method to get transaction type as string
  String get typeString => type == TransactionType.give ? 'Give' : 'Got';

  // Helper method to get formatted amount with sign
  String get formattedAmount {
    final prefix = type == TransactionType.give ? '-' : '+';
    return '$prefix${amount.toStringAsFixed(2)}';
  }

  // Helper method to get color based on type
  String get typeColor {
    switch (type) {
      case TransactionType.give:
        return 'red';
      case TransactionType.got:
        return 'teal';
    }
  }

  String get formattedTime {
    final hour24 = createdAt.hour;
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final isPm = hour24 >= 12;
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final hourStr = hour12.toString().padLeft(2, '0');
    final isAr = Get.locale?.languageCode == 'ar';
    final period = isAr ? (isPm ? 'م' : 'ص') : (isPm ? 'PM' : 'AM');
    return '$hourStr:$minute $period';
  }

  String get formattedDateTime {
    final y = createdAt.year;
    final m = createdAt.month.toString().padLeft(2, '0');
    final d = createdAt.day.toString().padLeft(2, '0');
    return '$y/$m/$d  $formattedTime';
  }

  // Helper method to get formatted date & time of entry
  String get formattedDate {
    final now = DateTime.now();
    final isToday = now.year == createdAt.year &&
        now.month == createdAt.month &&
        now.day == createdAt.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = yesterday.year == createdAt.year &&
        yesterday.month == createdAt.month &&
        yesterday.day == createdAt.day;
    final isAr = Get.locale?.languageCode == 'ar';

    if (isToday) {
      return '${isAr ? 'اليوم' : 'Today'}  $formattedTime';
    } else if (isYesterday) {
      return '${isAr ? 'أمس' : 'Yesterday'}  $formattedTime';
    } else {
      return formattedDateTime;
    }
  }
}
