import 'package:isar/isar.dart';

part 'transaction.g.dart';

enum TransactionType { give, got }

@Collection()
class TransactionModel {
  Id id = Isar.autoIncrement;
  
  late double amount;
  @Enumerated(EnumType.name)
  late TransactionType type;
  late String description;
  
  @Index()
  late DateTime createdAt;

  @Index()
  late int customerId;

  TransactionModel({
    required this.amount,
    required this.type,
    required this.description,
    required this.customerId,
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
        return 'red'; // Soft Red/Orange for "Give"
      case TransactionType.got:
        return 'teal'; // Deep Blue/Teal for "Got"
    }
  }
  
  // Helper method to get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
