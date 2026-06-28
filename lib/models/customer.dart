// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types
import 'package:isar/isar.dart';

part 'customer.g.dart';

@Collection()
class Customer {
  Id id = Isar.autoIncrement;
  
  late String name;
  late String phoneNumber;
  String? profilePicturePath;
  
  @Index()
  late DateTime createdAt;
  
  @Index()
  late DateTime updatedAt;
  
  @Index()
  String? firestoreId;
  
  bool isSynced = false;
  
  Customer({
    required this.name,
    required this.phoneNumber,
    this.profilePicturePath,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }
  
  // Computed property for total balance (calculated from transactions)
  double get totalBalance => 0.0; // This will be calculated in controller
  
  // Helper method to check if customer owes money (negative balance)
  bool get owesMoney => totalBalance < 0;
  
  // Helper method to get formatted balance
  String get formattedBalance {
    final amount = totalBalance.abs();
    final prefix = totalBalance >= 0 ? '+' : '-';
    return '$prefix${amount.toStringAsFixed(2)}';
  }
}
