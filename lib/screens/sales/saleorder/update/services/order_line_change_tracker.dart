// lib/screens/sales/saleorder/update/services/order_line_change_tracker.dart

import 'package:collection/collection.dart';
import 'package:routy/models/sales/sale_order_line_model.dart';
import 'package:routy/screens/sales/saleorder/create/widgets/product_line.dart';
import 'package:routy/utils/app_logger.dart';

/// 📊 Order Line Change Tracker - متتبع تغييرات أسطر الطلب
///
/// يدير:
/// - تتبع التغييرات في أسطر الطلب
/// - مقارنة البيانات
/// - حساب الفروقات
/// - إدارة الحالة
class OrderLineChangeTracker {
  // ============= State =============

  final List<SaleOrderLineModel> _originalLines = [];
  final List<ProductLine> _currentLines = [];
  final Map<int, LineChange> _changes = {};

  // ============= Initialization =============

  /// تهيئة المتتبع مع الأسطر الأصلية
  void initialize(List<SaleOrderLineModel> originalLines) {
    _originalLines.clear();
    _originalLines.addAll(originalLines);
    _changes.clear();

    appLogger.info('📊 OrderLineChangeTracker initialized');
    appLogger.info('   Original lines: ${_originalLines.length}');
  }

  /// تحديث الأسطر الحالية
  void updateCurrentLines(List<ProductLine> currentLines) {
    _currentLines.clear();
    _currentLines.addAll(currentLines);
    _calculateChanges();

    appLogger.info('📊 Current lines updated');
    appLogger.info('   Current lines: ${_currentLines.length}');
    appLogger.info('   Changes detected: ${_changes.length}');
  }

  // ============= Change Calculation =============

  /// حساب التغييرات
  void _calculateChanges() {
    _changes.clear();

    // تتبع الأسطر المحدثة
    for (var currentLine in _currentLines) {
      final originalLine = _findOriginalLine(currentLine.productId);

      if (originalLine != null) {
        final change = _compareLines(originalLine, currentLine);
        if (change.hasChanges) {
          _changes[currentLine.productId] = change;
        }
      }
    }

    // تتبع الأسطر المحذوفة
    for (var originalLine in _originalLines) {
      final stillExists = _currentLines.any(
        (current) => current.productId == originalLine.productId,
      );

      if (!stillExists) {
        _changes[originalLine.productId!] = LineChange(
          type: ChangeType.deleted,
          originalLine: originalLine,
          currentLine: null,
        );
      }
    }

    // تتبع الأسطر المضافة
    for (var currentLine in _currentLines) {
      final wasOriginal = _originalLines.any(
        (original) => original.productId == currentLine.productId,
      );

      if (!wasOriginal) {
        _changes[currentLine.productId] = LineChange(
          type: ChangeType.added,
          originalLine: null,
          currentLine: currentLine,
        );
      }
    }
  }

  /// البحث عن السطر الأصلي
  SaleOrderLineModel? _findOriginalLine(int productId) {
    return _originalLines.firstWhereOrNull(
      (line) => line.productId == productId,
    );
  }

  /// مقارنة السطرين
  LineChange _compareLines(SaleOrderLineModel original, ProductLine current) {
    final changes = <String, dynamic>{};

    // مقارنة الكمية
    final originalQuantity = original.productUomQty ?? 0.0;
    final currentQuantity = current.quantity.toDouble();
    if (originalQuantity != currentQuantity) {
      changes['quantity'] = {
        'original': originalQuantity,
        'current': currentQuantity,
        'difference': currentQuantity - originalQuantity,
      };
    }

    // مقارنة السعر
    final originalPrice = original.priceUnit ?? 0.0;
    final currentPrice = current.priceUnit;
    if (originalPrice != currentPrice) {
      changes['price'] = {
        'original': originalPrice,
        'current': currentPrice,
        'difference': currentPrice - originalPrice,
      };
    }

    // مقارنة الخصم
    final originalDiscount = original.discount ?? 0.0;
    final currentDiscount = current.discountPercentage;
    if (originalDiscount != currentDiscount) {
      changes['discount'] = {
        'original': originalDiscount,
        'current': currentDiscount,
        'difference': currentDiscount - originalDiscount,
      };
    }

    // مقارنة الإجمالي
    final originalTotal = original.priceSubtotal ?? 0.0;
    final currentTotal = current.getTotalPrice();
    if (originalTotal != currentTotal) {
      changes['total'] = {
        'original': originalTotal,
        'current': currentTotal,
        'difference': currentTotal - originalTotal,
      };
    }

    return LineChange(
      type: changes.isEmpty ? ChangeType.unchanged : ChangeType.modified,
      originalLine: original,
      currentLine: current,
      changes: changes,
    );
  }

  // ============= Getters =============

  /// الحصول على جميع التغييرات
  Map<int, LineChange> get allChanges => Map.from(_changes);

  /// الحصول على التغييرات المحدثة
  Map<int, LineChange> get modifiedChanges {
    return _changes.entries
        .where((entry) => entry.value.type == ChangeType.modified)
        .fold<Map<int, LineChange>>({}, (map, entry) {
          map[entry.key] = entry.value;
          return map;
        });
  }

  /// الحصول على التغييرات المضافة
  Map<int, LineChange> get addedChanges {
    return _changes.entries
        .where((entry) => entry.value.type == ChangeType.added)
        .fold<Map<int, LineChange>>({}, (map, entry) {
          map[entry.key] = entry.value;
          return map;
        });
  }

  /// الحصول على التغييرات المحذوفة
  Map<int, LineChange> get deletedChanges {
    return _changes.entries
        .where((entry) => entry.value.type == ChangeType.deleted)
        .fold<Map<int, LineChange>>({}, (map, entry) {
          map[entry.key] = entry.value;
          return map;
        });
  }

  /// التحقق من وجود تغييرات
  bool get hasChanges => _changes.isNotEmpty;

  /// التحقق من وجود تغييرات محددة
  bool get hasModifiedChanges => modifiedChanges.isNotEmpty;

  /// التحقق من وجود تغييرات مضافة
  bool get hasAddedChanges => addedChanges.isNotEmpty;

  /// التحقق من وجود تغييرات محذوفة
  bool get hasDeletedChanges => deletedChanges.isNotEmpty;

  /// عدد التغييرات
  int get changesCount => _changes.length;

  /// عدد التغييرات المحدثة
  int get modifiedCount => modifiedChanges.length;

  /// عدد التغييرات المضافة
  int get addedCount => addedChanges.length;

  /// عدد التغييرات المحذوفة
  int get deletedCount => deletedChanges.length;

  // ============= Statistics =============

  /// الحصول على إحصائيات التغييرات
  Map<String, dynamic> getChangeStatistics() {
    final totalOriginalValue = _originalLines.fold(
      0.0,
      (sum, line) => sum + (line.priceSubtotal ?? 0.0),
    );

    final totalCurrentValue = _currentLines.fold(
      0.0,
      (sum, line) => sum + line.getTotalPrice(),
    );

    final totalSavings = _currentLines.fold(
      0.0,
      (sum, line) => sum + line.getSavings(),
    );

    return {
      'totalChanges': changesCount,
      'modifiedChanges': modifiedCount,
      'addedChanges': addedCount,
      'deletedChanges': deletedCount,
      'originalValue': totalOriginalValue,
      'currentValue': totalCurrentValue,
      'valueDifference': totalCurrentValue - totalOriginalValue,
      'totalSavings': totalSavings,
      'savingsPercentage': totalOriginalValue > 0
          ? (totalSavings / totalOriginalValue * 100)
          : 0.0,
    };
  }

  // ============= Validation =============

  /// التحقق من صحة التغييرات
  bool validateChanges() {
    for (var change in _changes.values) {
      if (change.type == ChangeType.modified) {
        // التحقق من صحة التغييرات المحدثة
        if (change.changes != null) {
          for (var field in change.changes!.keys) {
            final fieldChange = change.changes![field] as Map<String, dynamic>;
            final difference = fieldChange['difference'] as num;

            // التحقق من الكمية
            if (field == 'quantity' && difference < 0) {
              appLogger.warning('⚠️ Negative quantity change detected');
              return false;
            }

            // التحقق من السعر
            if (field == 'price' && difference < 0) {
              appLogger.warning('⚠️ Negative price change detected');
              return false;
            }

            // التحقق من الخصم
            if (field == 'discount' && (difference < 0 || difference > 100)) {
              appLogger.warning('⚠️ Invalid discount change detected');
              return false;
            }
          }
        }
      }
    }

    return true;
  }

  // ============= Reset =============

  /// إعادة تعيين المتتبع
  void reset() {
    _originalLines.clear();
    _currentLines.clear();
    _changes.clear();

    appLogger.info('📊 OrderLineChangeTracker reset');
  }

  /// إعادة تعيين التغييرات
  void resetChanges() {
    _changes.clear();
    appLogger.info('📊 Changes reset');
  }
}

// ============= Enums and Classes =============

/// نوع التغيير
enum ChangeType { unchanged, modified, added, deleted }

/// تغيير السطر
class LineChange {
  final ChangeType type;
  final SaleOrderLineModel? originalLine;
  final ProductLine? currentLine;
  final Map<String, dynamic>? changes;

  LineChange({
    required this.type,
    this.originalLine,
    this.currentLine,
    this.changes,
  });

  bool get hasChanges => type != ChangeType.unchanged;
  bool get isModified => type == ChangeType.modified;
  bool get isAdded => type == ChangeType.added;
  bool get isDeleted => type == ChangeType.deleted;
  bool get isUnchanged => type == ChangeType.unchanged;

  /// الحصول على ملخص التغيير
  String get summary {
    switch (type) {
      case ChangeType.unchanged:
        return 'لم يتغير';
      case ChangeType.modified:
        return 'تم التعديل';
      case ChangeType.added:
        return 'تم الإضافة';
      case ChangeType.deleted:
        return 'تم الحذف';
    }
  }

  /// الحصول على تفاصيل التغيير
  String get details {
    if (changes == null || changes!.isEmpty) {
      return summary;
    }

    final details = <String>[];

    if (changes!.containsKey('quantity')) {
      final qtyChange = changes!['quantity'] as Map<String, dynamic>;
      final difference = qtyChange['difference'] as num;
      details.add(
        'الكمية: ${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)}',
      );
    }

    if (changes!.containsKey('price')) {
      final priceChange = changes!['price'] as Map<String, dynamic>;
      final difference = priceChange['difference'] as num;
      details.add(
        'السعر: ${difference > 0 ? '+' : ''}${difference.toStringAsFixed(2)}',
      );
    }

    if (changes!.containsKey('discount')) {
      final discountChange = changes!['discount'] as Map<String, dynamic>;
      final difference = discountChange['difference'] as num;
      details.add(
        'الخصم: ${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)}%',
      );
    }

    return details.join(', ');
  }
}
