// lib/screens/sales/saleorder/create/services/order_creation_service.dart

import 'dart:async';
import 'package:routy/common/api/api.dart';
import 'package:routy/utils/app_logger.dart';

/// 🛒 Order Creation Service - خدمة إنشاء أوامر البيع
///
/// يدير:
/// - إنشاء أوامر البيع في Odoo
/// - التحقق من صحة البيانات
/// - معالجة الأخطاء
/// - إرسال البيانات للخادم
class OrderCreationService {
  // ============= Singleton =============

  static final OrderCreationService _instance =
      OrderCreationService._internal();
  factory OrderCreationService() => _instance;
  OrderCreationService._internal();

  // ============= Order Creation =============

  /// إنشاء أمر بيع جديد
  Future<Map<String, dynamic>> createOrder({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> productLines,
  }) async {
    appLogger.info('\n🛒 ========== CREATING ORDER ==========');
    appLogger.info('Order data: $orderData');
    appLogger.info('Product lines: ${productLines.length}');

    try {
      // التحقق من صحة البيانات
      final validationResult = _validateOrderData(orderData, productLines);
      if (!validationResult['isValid']) {
        throw Exception(validationResult['message']);
      }

      // بناء بيانات الطلب الكاملة
      final completeOrderData = _createCompleteOrder(orderData, productLines);

      appLogger.info('✅ Order data prepared successfully');
      appLogger.info('   Partner ID: ${completeOrderData['partner_id']}');
      appLogger.info('   Price List ID: ${completeOrderData['pricelist_id']}');
      appLogger.info(
        '   Order Lines: ${(completeOrderData['order_line'] as List).length}',
      );

      // إرسال البيانات للخادم
      final result = await _sendOrderToServer(completeOrderData);

      appLogger.info('✅ Order created successfully');
      appLogger.info('   Order ID: ${result['id']}');
      appLogger.info('   Order Name: ${result['name']}');
      appLogger.info('=====================================\n');

      return result;
    } catch (e) {
      appLogger.error('❌ Error creating order: $e');
      appLogger.error('   Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // ============= Data Preparation =============

  /// بناء بيانات الطلب الكاملة
  Map<String, dynamic> _createCompleteOrder(
    Map<String, dynamic> orderData,
    List<Map<String, dynamic>> productLines,
  ) {
    final completeOrderData = Map<String, dynamic>.from(orderData);

    // إضافة أسطر الطلب
    completeOrderData['order_line'] = _buildOrderLinesData(productLines);

    // إضافة حقول إضافية مطلوبة
    completeOrderData['state'] = 'draft';
    completeOrderData['date_order'] = DateTime.now().toIso8601String();

    return completeOrderData;
  }

  /// بناء بيانات أسطر الطلب
  List<dynamic> _buildOrderLinesData(List<Map<String, dynamic>> productLines) {
    final orderLines = <dynamic>[];

    for (var line in productLines) {
      final orderLine = [
        0, // 0 = create
        0, // virtual_id
        {
          'product_id': line['product_id'],
          'product_uom_qty': line['product_uom_qty'],
          'price_unit': line['price_unit'],
          'discount': line['discount'],
        },
      ];

      orderLines.add(orderLine);

      appLogger.info('📦 Order line prepared:');
      appLogger.info('   Product ID: ${line['product_id']}');
      appLogger.info('   Quantity: ${line['product_uom_qty']}');
      appLogger.info('   Price: ${line['price_unit']}');
      appLogger.info('   Discount: ${line['discount']}%');
    }

    return orderLines;
  }

  // ============= Validation =============

  /// التحقق من صحة بيانات الطلب
  Map<String, dynamic> _validateOrderData(
    Map<String, dynamic> orderData,
    List<Map<String, dynamic>> productLines,
  ) {
    appLogger.info('\n🔍 ========== VALIDATING ORDER DATA ==========');

    // التحقق من وجود العميل
    if (orderData['partner_id'] == null) {
      return {'isValid': false, 'message': 'يجب اختيار العميل'};
    }

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

      if (line['discount'] == null ||
          line['discount'] < 0 ||
          line['discount'] > 100) {
        return {
          'isValid': false,
          'message': 'منتج رقم ${i + 1}: يجب تحديد خصم صحيح (0-100%)',
        };
      }
    }

    appLogger.info('✅ Order data validation passed');
    appLogger.info('==========================================\n');

    return {'isValid': true, 'message': 'البيانات صحيحة'};
  }

  // ============= Server Communication =============

  /// إرسال الطلب للخادم
  Future<Map<String, dynamic>> _sendOrderToServer(
    Map<String, dynamic> orderData,
  ) async {
    appLogger.info('\n🌐 ========== SENDING ORDER TO SERVER ==========');
    appLogger.info('Sending order data to Odoo...');

    final completer = Completer<Map<String, dynamic>>();

    Api.create(
      model: 'sale.order',
      values: orderData,
      onResponse: (response) {
        appLogger.info('✅ Order sent successfully');
        appLogger.info('   Response: $response');
        completer.complete(response);
      },
      onError: (error, data) {
        appLogger.error('❌ Failed to send order to server: $error');
        completer.completeError(Exception(error));
      },
    );

    return completer.future;
  }

  // ============= Helper Methods =============

  /// حساب إجمالي الطلب
  double calculateOrderTotal(List<Map<String, dynamic>> productLines) {
    double total = 0.0;

    for (var line in productLines) {
      final quantity = (line['product_uom_qty'] as num).toDouble();
      final price = (line['price_unit'] as num).toDouble();
      final discount = (line['discount'] as num).toDouble();

      final lineTotal = quantity * price * (1 - discount / 100);
      total += lineTotal;
    }

    return total;
  }

  /// حساب عدد المنتجات
  int calculateProductsCount(List<Map<String, dynamic>> productLines) {
    return productLines.length;
  }

  /// حساب إجمالي الكمية
  double calculateTotalQuantity(List<Map<String, dynamic>> productLines) {
    return productLines.fold(0.0, (sum, line) {
      return sum + (line['product_uom_qty'] as num).toDouble();
    });
  }
}
