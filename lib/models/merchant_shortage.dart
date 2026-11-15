import 'package:isar_community/isar.dart';

part 'merchant_shortage.g.dart';

@Collection()
class MerchantShortage {
  Id id = Isar.autoIncrement;

  String? firestoreId;
  bool isSynced = false;

  @Index()
  int? merchantId;

  @Index()
  late bool isResolved;

  late String productName;
  double? quantity;
  String? note;

  @Index()
  late DateTime createdAt;

  late DateTime updatedAt;

  MerchantShortage({
    this.merchantId,
    required this.productName,
    this.quantity,
    this.note,
    this.isResolved = false,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }
}
