import 'package:flutter/material.dart';

/// نموذج إجراء على عنصر في اللائحة
class ListItemAction<T> {
  final String id;
  final String labelKey; // مفتاح الترجمة
  final IconData icon;
  final Color? color;
  final Function(T item) onTap;
  final bool Function(T item)? isVisible; // شرط الظهور
  final bool Function(T item)? isEnabled; // شرط التفعيل

  ListItemAction({
    required this.id,
    required this.labelKey,
    required this.icon,
    required this.onTap,
    this.color,
    this.isVisible,
    this.isEnabled,
  });

  /// التحقق من إمكانية الظهور
  bool canShow(T item) {
    return isVisible?.call(item) ?? true;
  }

  /// التحقق من إمكانية التفعيل
  bool canEnable(T item) {
    return isEnabled?.call(item) ?? true;
  }
}

/// نموذج إجراء سريع (Swipe Action)
class SwipeAction<T> {
  final String id;
  final String labelKey;
  final IconData icon;
  final Color backgroundColor;
  final Function(T item) onTap;
  final bool Function(T item)? isVisible;

  SwipeAction({
    required this.id,
    required this.labelKey,
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
    this.isVisible,
  });

  bool canShow(T item) {
    return isVisible?.call(item) ?? true;
  }
}
