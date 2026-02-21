import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 0)
class Item extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category; // 'food', 'medicine', 'cosmetics', 'other'

  @HiveField(3)
  DateTime expiryDate;

  @HiveField(4)
  String? barcode;

  @HiveField(5)
  int quantity;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  bool notified3Day;

  @HiveField(9)
  bool notified1Day;

  @HiveField(10)
  bool notifiedExpired;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.expiryDate,
    this.barcode,
    this.quantity = 1,
    this.notes,
    DateTime? createdAt,
    this.notified3Day = false,
    this.notified1Day = false,
    this.notifiedExpired = false,
  }) : createdAt = createdAt ?? DateTime.now();
}
