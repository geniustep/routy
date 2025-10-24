// lib/screens/sales/saleorder/update/services/order_update_service.dart

import 'dart:async';
import 'package:collection/collection.dart';
import 'package:routy/common/api/api.dart';
import 'package:routy/models/sales/sale_order_line_model.dart';
import 'package:routy/utils/app_logger.dart';

/// 🔄 Order Update Service - خدمة تحديث أوامر البيع
///
/// يدير:
/// - تحديث أوامر البيع
/// - تحديث أسطر الطلب
/// - حذف أسطر الطلب
/// - إضافة أسطر جديدة
/// - معالجة التغييرات
class OrderUpdateService {
  // ============= Singleton =============

  static final OrderUpdateService _instance = OrderUpdateService._internal();
  factory OrderUpdateService() => _instance;
  OrderUpdateService._internal();

  // ============= Order Update =============

  /// تحديث أمر البيع
  Future<Map<String, dynamic>> updateOrder({
    required int orderId,
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> productLines,
  }) async {
    try {
      appLogger.info('\n🔄 ========== UPDATING ORDER ==========');
      appLogger.info('Order ID: $orderId');
      appLogger.info('Order data: $orderData');
      appLogger.info('Product lines: ${productLines.length}');

      // التحقق من صحة البيانات
      final validationResult = _validateUpdateData(orderData, productLines);
      if (!validationResult['isValid']) {
        throw Exception(validationResult['message']);
      }

      // تحديث بيانات الطلب
      final orderResult = await _updateOrderData(orderId, orderData);

      // تحديث أسطر الطلب
      final linesResult = await _updateOrderLines(orderId, productLines);

      appLogger.info('✅ Order updated successfully');
      appLogger.info('   Order ID: $orderId');
      appLogger.info('   Updated lines: ${linesResult['updatedLines']}');
      appLogger.info('   Added lines: ${linesResult['addedLines']}');
      appLogger.info('   Deleted lines: ${linesResult['deletedLines']}');
      appLogger.info('=====================================\n');

      return {'order': orderResult, 'lines': linesResult, 'success': true};
    } catch (e) {
      appLogger.error('❌ Error updating order: $e');
      appLogger.error('   Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // ============= Order Data Update =============

  /// تحديث بيانات الطلب الأساسية
  Future<Map<String, dynamic>> _updateOrderData(
    int orderId,
    Map<String, dynamic> orderData,
  ) async {
    try {
      appLogger.info('\n📝 ========== UPDATING ORDER DATA ==========');
      appLogger.info('Order ID: $orderId');
      appLogger.info('Data to update: $orderData');

      final completer = Completer<Map<String, dynamic>>();

      Api.write(
        model: 'sale.order',
        ids: [orderId],
        values: orderData,
        onResponse: (response) {
          completer.complete(response);
        },
        onError: (error, data) {
          completer.completeError(Exception(error));
        },
      );

      final result = await completer.future;

      appLogger.info('✅ Order data updated successfully');
      appLogger.info('   Response: $result');
      return result;
    } catch (e) {
      appLogger.error('❌ Error updating order data: $e');
      rethrow;
    }
  }

  // ============= Order Lines Update =============

  /// تحديث أسطر الطلب
  Future<Map<String, dynamic>> _updateOrderLines(
    int orderId,
    List<Map<String, dynamic>> productLines,
  ) async {
    try {
      appLogger.info('\n📦 ========== UPDATING ORDER LINES ==========');
      appLogger.info('Order ID: $orderId');
      appLogger.info('Product lines: ${productLines.length}');

      // جلب الأسطر الحالية
      final currentLines = await _getCurrentOrderLines(orderId);

      // تحديد التغييرات
      final changes = _calculateLineChanges(currentLines, productLines);

      // تطبيق التغييرات
      final results = await _applyLineChanges(orderId, changes);

      appLogger.info('✅ Order lines updated successfully');
      appLogger.info('   Updated: ${results['updated']}');
      appLogger.info('   Added: ${results['added']}');
      appLogger.info('   Deleted: ${results['deleted']}');
      appLogger.info('==========================================\n');

      return results;
    } catch (e) {
      appLogger.error('❌ Error updating order lines: $e');
      rethrow;
    }
  }

  // ============= Line Changes Calculation =============

  /// حساب التغييرات في أسطر الطلب
  Map<String, dynamic> _calculateLineChanges(
    List<SaleOrderLineModel> currentLines,
    List<Map<String, dynamic>> newLines,
  ) {
    final changes = <String, dynamic>{
      'toUpdate': <Map<String, dynamic>>[],
      'toAdd': <Map<String, dynamic>>[],
      'toDelete': <int>[],
    };

    // تحديد الأسطر المحدثة
    for (var newLine in newLines) {
      final lineId = newLine['id'] as int?;

      if (lineId != null && lineId > 0) {
        // سطر موجود - تحديث
        final currentLine = currentLines.firstWhereOrNull(
          (l) => l.id == lineId,
        );
        if (currentLine != null) {
          final hasChanges = _hasLineChanged(currentLine, newLine);
          if (hasChanges) {
            changes['toUpdate'].add(newLine);
          }
        }
      } else {
        // سطر جديد - إضافة
        changes['toAdd'].add(newLine);
      }
    }

    // تحديد الأسطر المحذوفة
    for (var currentLine in currentLines) {
      final stillExists = newLines.any(
        (newLine) => newLine['id'] == currentLine.id,
      );

      if (!stillExists) {
        changes['toDelete'].add(currentLine.id!);
      }
    }

    appLogger.info('📊 Line changes calculated:');
    appLogger.info('   To update: ${(changes['toUpdate'] as List).length}');
    appLogger.info('   To add: ${(changes['toAdd'] as List).length}');
    appLogger.info('   To delete: ${(changes['toDelete'] as List).length}');

    return changes;
  }

  /// التحقق من تغيير السطر
  bool _hasLineChanged(
    SaleOrderLineModel currentLine,
    Map<String, dynamic> newLine,
  ) {
    final currentQuantity = currentLine.productUomQty ?? 0.0;
    final newQuantity = (newLine['product_uom_qty'] as num?)?.toDouble() ?? 0.0;

    final currentPrice = currentLine.priceUnit ?? 0.0;
    final newPrice = (newLine['price_unit'] as num?)?.toDouble() ?? 0.0;

    final currentDiscount = currentLine.discount ?? 0.0;
    final newDiscount = (newLine['discount'] as num?)?.toDouble() ?? 0.0;

    return currentQuantity != newQuantity ||
        currentPrice != newPrice ||
        currentDiscount != newDiscount;
  }

  // ============= Apply Changes =============

  /// تطبيق التغييرات على أسطر الطلب
  Future<Map<String, dynamic>> _applyLineChanges(
    int orderId,
    Map<String, dynamic> changes,
  ) async {
    final results = <String, dynamic>{'updated': 0, 'added': 0, 'deleted': 0};

    try {
      // تحديث الأسطر الموجودة
      final toUpdate = changes['toUpdate'] as List<Map<String, dynamic>>;
      for (var lineData in toUpdate) {
        await _updateOrderLine(lineData);
        results['updated']++;
      }

      // إضافة أسطر جديدة
      final toAdd = changes['toAdd'] as List<Map<String, dynamic>>;
      for (var lineData in toAdd) {
        await _addOrderLine(orderId, lineData);
        results['added']++;
      }

      // حذف الأسطر
      final toDelete = changes['toDelete'] as List<int>;
      for (var lineId in toDelete) {
        await _deleteOrderLine(lineId);
        results['deleted']++;
      }

      return results;
    } catch (e) {
      appLogger.error('❌ Error applying line changes: $e');
      rethrow;
    }
  }

  /// تحديث سطر طلب
  Future<void> _updateOrderLine(Map<String, dynamic> lineData) async {
    try {
      final lineId = lineData['id'] as int;
      final updateData = Map<String, dynamic>.from(lineData);
      updateData.remove('id');

      final completer = Completer<void>();

      Api.write(
        model: 'sale.order.line',
        ids: [lineId],
        values: updateData,
        onResponse: (response) {
          completer.complete();
        },
        onError: (error, data) {
          completer.completeError(Exception(error));
        },
      );

      await completer.future;

      appLogger.info('✅ Order line updated: $lineId');
    } catch (e) {
      appLogger.error('❌ Error updating order line: $e');
      rethrow;
    }
  }

  /// إضافة سطر طلب جديد
  Future<void> _addOrderLine(int orderId, Map<String, dynamic> lineData) async {
    try {
      final createData = Map<String, dynamic>.from(lineData);
      createData['order_id'] = orderId;

      final completer = Completer<void>();

      Api.create(
        model: 'sale.order.line',
        values: createData,
        onResponse: (response) {
          completer.complete();
        },
        onError: (error, data) {
          completer.completeError(Exception(error));
        },
      );

      await completer.future;

      appLogger.info('✅ Order line added to order: $orderId');
    } catch (e) {
      appLogger.error('❌ Error adding order line: $e');
      rethrow;
    }
  }

  /// حذف سطر طلب
  Future<void> _deleteOrderLine(int lineId) async {
    try {
      final completer = Completer<void>();

      Api.unlink(
        model: 'sale.order.line',
        ids: [lineId],
        onResponse: (response) {
          completer.complete();
        },
        onError: (error, data) {
          completer.completeError(Exception(error));
        },
      );

      await completer.future;

      appLogger.info('✅ Order line deleted: $lineId');
    } catch (e) {
      appLogger.error('❌ Error deleting order line: $e');
      rethrow;
    }
  }

  // ============= Helper Methods =============

  /// جلب الأسطر الحالية للطلب
  Future<List<SaleOrderLineModel>> _getCurrentOrderLines(int orderId) async {
    try {
      final completer = Completer<List<SaleOrderLineModel>>();

      Api.searchRead(
        model: 'sale.order.line',
        domain: [
          ['order_id', '=', orderId],
        ],
        fields: [
          'id',
          'order_id',
          'product_id',
          'product_uom_qty',
          'price_unit',
          'discount',
          'name',
        ],
        onResponse: (response) {
          final lines = (response as List<dynamic>)
              .map(
                (json) =>
                    SaleOrderLineModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
          completer.complete(lines);
        },
        onError: (message, data) {
          appLogger.error('❌ Error fetching current order lines: $message');
          completer.complete(<SaleOrderLineModel>[]);
        },
      );

      return completer.future;
    } catch (e) {
      appLogger.error('❌ Error fetching current order lines: $e');
      return <SaleOrderLineModel>[];
    }
  }

  /// التحقق من صحة بيانات التحديث
  Map<String, dynamic> _validateUpdateData(
    Map<String, dynamic> orderData,
    List<Map<String, dynamic>> productLines,
  ) {
    // التحقق من وجود المنتجات
    if (productLines.isEmpty) {
      return {'isValid': false, 'message': 'يجب إضافة منتج واحد على الأقل'};
    }

    // التحقق من صحة كل منتج
    for (var i = 0; i < productLines.length; i++) {
      final line = productLines[i];

      if (line['product_id'] == null) {
        return {
          'isValid': false,
          'message': 'منتج رقم ${i + 1}: يجب تحديد المنتج',
        };
      }

      if (line['product_uom_qty'] == null || line['product_uom_qty'] <= 0) {
        return {
          'isValid': false,
          'message': 'منتج رقم ${i + 1}: يجب تحديد كمية صحيحة',
        };
      }

      if (line['price_unit'] == null || line['price_unit'] < 0) {
        return {
          'isValid': false,
          'message': 'منتج رقم ${i + 1}: يجب تحديد سعر صحيح',
        };
      }
    }

    return {'isValid': true, 'message': 'البيانات صحيحة'};
  }

  // ============= Bulk Operations =============

  /// تحديث جميع أسطر الطلب دفعة واحدة
  Future<void> updateAllOrderLines(
    int orderId,
    List<Map<String, dynamic>> productLines,
  ) async {
    try {
      appLogger.info('\n🔄 ========== BULK UPDATING ORDER LINES ==========');
      appLogger.info('Order ID: $orderId');
      appLogger.info('Product lines: ${productLines.length}');

      // حذف جميع الأسطر الحالية
      final currentLines = await _getCurrentOrderLines(orderId);
      for (var line in currentLines) {
        await _deleteOrderLine(line.id!);
      }

      // إضافة الأسطر الجديدة
      for (var lineData in productLines) {
        await _addOrderLine(orderId, lineData);
      }

      appLogger.info('✅ All order lines updated successfully');
      appLogger.info('   Deleted: ${currentLines.length}');
      appLogger.info('   Added: ${productLines.length}');
      appLogger.info('===============================================\n');
    } catch (e) {
      appLogger.error('❌ Error bulk updating order lines: $e');
      rethrow;
    }
  }
}
