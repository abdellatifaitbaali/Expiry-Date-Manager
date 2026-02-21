import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/item.dart';
import '../services/notification_service.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';

class ItemProvider with ChangeNotifier {
  static const String _boxName = 'items';
  final _uuid = const Uuid();
  final NotificationService _notificationService = NotificationService();
  final AdService _adService = AdService();

  List<Item> _items = [];
  int _bonusSlots = 0;

  List<Item> get items {
    final sorted = List<Item>.from(_items);
    sorted.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return sorted;
  }

  List<Item> get expiringToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return items.where((item) {
      final expiry = DateTime(
        item.expiryDate.year,
        item.expiryDate.month,
        item.expiryDate.day,
      );
      return expiry.difference(today).inDays <= 0;
    }).toList();
  }

  List<Item> get expiringSoon {
    return items.where((item) {
      final days = _daysUntil(item.expiryDate);
      return days > 0 && days <= 3;
    }).toList();
  }

  int get totalItems => _items.length;
  int get maxSlots => AppConstants.maxFreeSlots + _bonusSlots;
  bool get canAddItem => _items.length < maxSlots;

  int _daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(today).inDays;
  }

  Future<void> loadItems() async {
    final box = await Hive.openBox<Item>(_boxName);
    _items = box.values.toList();

    // Load bonus slots
    final settingsBox = await Hive.openBox('settings');
    _bonusSlots = settingsBox.get('bonusSlots', defaultValue: 0);

    notifyListeners();
  }

  Future<bool> addItem({
    required String name,
    required String category,
    required DateTime expiryDate,
    String? barcode,
    int quantity = 1,
    String? notes,
  }) async {
    if (!canAddItem) return false;

    final item = Item(
      id: _uuid.v4(),
      name: name,
      category: category,
      expiryDate: expiryDate,
      barcode: barcode,
      quantity: quantity,
      notes: notes,
    );

    final box = await Hive.openBox<Item>(_boxName);
    await box.put(item.id, item);
    _items.add(item);

    // Schedule notifications
    await _notificationService.scheduleExpiryNotifications(item);

    // Track for interstitial ad
    _adService.onItemAdded();

    notifyListeners();
    return true;
  }

  Future<void> updateItem(Item item) async {
    final box = await Hive.openBox<Item>(_boxName);
    await box.put(item.id, item);

    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
    }

    // Reschedule notifications
    await _notificationService.scheduleExpiryNotifications(item);

    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    final box = await Hive.openBox<Item>(_boxName);
    await box.delete(id);
    _items.removeWhere((item) => item.id == id);

    // Cancel notifications
    await _notificationService.cancelNotifications(id);

    notifyListeners();
  }

  Future<void> markAsUsed(String id) async {
    await deleteItem(id);
  }

  Future<void> deleteAllItems() async {
    final box = await Hive.openBox<Item>(_boxName);
    await box.clear();
    _items.clear();

    await _notificationService.cancelAllNotifications();

    notifyListeners();
  }

  Future<bool> unlockBonusSlots() async {
    final rewarded = await _adService.showRewardedAd();
    if (rewarded) {
      _bonusSlots += AppConstants.rewardedSlotBonus;
      final settingsBox = await Hive.openBox('settings');
      await settingsBox.put('bonusSlots', _bonusSlots);
      notifyListeners();
    }
    return rewarded;
  }
}
