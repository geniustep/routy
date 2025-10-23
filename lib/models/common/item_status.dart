import 'package:flutter/material.dart';

/// نموذج حالة العنصر
class ItemStatus {
  final String id;
  final String labelKey; // مفتاح الترجمة
  final Color color;
  final IconData? icon;

  const ItemStatus({
    required this.id,
    required this.labelKey,
    required this.color,
    this.icon,
  });

  /// الحالات الشائعة
  static const ItemStatus draft = ItemStatus(
    id: 'draft',
    labelKey: 'draft',
    color: Colors.orange,
    icon: Icons.edit_note,
  );

  static const ItemStatus pending = ItemStatus(
    id: 'pending',
    labelKey: 'pending',
    color: Colors.amber,
    icon: Icons.schedule,
  );

  static const ItemStatus confirmed = ItemStatus(
    id: 'confirmed',
    labelKey: 'confirmed',
    color: Colors.blue,
    icon: Icons.check_circle_outline,
  );

  static const ItemStatus inProgress = ItemStatus(
    id: 'in_progress',
    labelKey: 'in_progress',
    color: Colors.purple,
    icon: Icons.sync,
  );

  static const ItemStatus completed = ItemStatus(
    id: 'completed',
    labelKey: 'completed',
    color: Colors.green,
    icon: Icons.check_circle,
  );

  static const ItemStatus delivered = ItemStatus(
    id: 'delivered',
    labelKey: 'delivered',
    color: Colors.teal,
    icon: Icons.local_shipping,
  );

  static const ItemStatus cancelled = ItemStatus(
    id: 'cancelled',
    labelKey: 'cancelled',
    color: Colors.red,
    icon: Icons.cancel,
  );

  static const ItemStatus paid = ItemStatus(
    id: 'paid',
    labelKey: 'paid',
    color: Colors.green,
    icon: Icons.payment,
  );

  static const ItemStatus unpaid = ItemStatus(
    id: 'unpaid',
    labelKey: 'unpaid',
    color: Colors.orange,
    icon: Icons.money_off,
  );

  /// الحصول على حالة حسب الـ ID
  static ItemStatus? fromId(String id) {
    switch (id) {
      case 'draft':
        return draft;
      case 'pending':
        return pending;
      case 'confirmed':
        return confirmed;
      case 'in_progress':
        return inProgress;
      case 'completed':
        return completed;
      case 'delivered':
        return delivered;
      case 'cancelled':
        return cancelled;
      case 'paid':
        return paid;
      case 'unpaid':
        return unpaid;
      default:
        return null;
    }
  }
}
