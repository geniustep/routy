import 'package:get/get.dart';
import 'dart:async';
import '../models/sales/sale_order_model.dart';
import '../common/api/api.dart';
import 'package:routy/utils/app_logger.dart';

/// Controller للمبيعات
class SalesController extends GetxController {
  // البيانات
  final RxList<SaleOrderModel> orders = <SaleOrderModel>[].obs;
  final Rx<SaleOrderModel?> selectedOrder = Rx<SaleOrderModel?>(null);

  // الحالة
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString error = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalOrders = 0.obs;
  final RxBool hasMorePages = true.obs;
  final int ordersPerPage = 20;

  // الحقول المتاحة (يتم تحديثها ديناميكياً)
  late List<String> _availableFields;

  @override
  void onInit() {
    super.onInit();
    _availableFields = _getOrderFields();
  }

  /// جلب أوامر البيع مع معالجة الحقول المفقودة
  Future<List<SaleOrderModel>> fetchOrders({
    String? search,
    String? status,
    int? page,
    String? sortField,
    String? sortOrder,
  }) async {
    try {
      appLogger.info('📦 Fetching sales orders...');

      // بناء domain للفلترة
      List<dynamic> domain = [];

      // فلتر البحث
      if (search != null && search.isNotEmpty) {
        domain.add('|');
        domain.add(['name', 'ilike', search]);
        domain.add(['partner_id.name', 'ilike', search]);
      }

      // فلتر الحالة
      if (status != null && status.isNotEmpty && status != 'all') {
        domain.add(['state', '=', status]);
      }

      final int offset = ((page ?? 1) - 1) * ordersPerPage;
      final String orderStr = sortField != null && sortOrder != null
          ? '$sortField $sortOrder'
          : 'date_order DESC';

      return await _fetchWithFieldRetry(
        domain: domain,
        offset: offset,
        orderStr: orderStr,
      );
    } catch (e, stackTrace) {
      appLogger.error(
        '❌ Exception in fetchOrders',
        error: e,
        stackTrace: stackTrace,
      );
      error.value = e.toString();
      rethrow;
    }
  }

  /// جلب البيانات مع إعادة المحاولة عند فشل الحقول
  Future<List<SaleOrderModel>> _fetchWithFieldRetry({
    required List<dynamic> domain,
    required int offset,
    required String orderStr,
  }) async {
    final completer = Completer<List<SaleOrderModel>>();

    try {
      await Api.searchRead(
        model: 'sale.order',
        domain: domain,
        fields: _availableFields,
        limit: ordersPerPage,
        offset: offset,
        order: orderStr,
        onResponse: (response) {
          appLogger.info('✅ Sales orders fetched successfully');

          final ordersList = (response as List<dynamic>)
              .map(
                (json) => SaleOrderModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

          // تحديث البيانات
          if (offset == 0) {
            orders.value = ordersList;
          } else {
            orders.addAll(ordersList);
          }

          hasMorePages.value = ordersList.length >= ordersPerPage;
          currentPage.value = (offset ~/ ordersPerPage) + 1;

          if (!completer.isCompleted) {
            completer.complete(ordersList);
          }
        },
        onError: (message, data) {
          // ✅ محاولة استخراج اسم الحقل المفقود
          if (message.contains("Invalid field")) {
            final invalidFieldMatch = RegExp(
              r"Invalid field '(\w+)'",
            ).firstMatch(message);
            if (invalidFieldMatch != null) {
              final invalidField = invalidFieldMatch.group(1);
              appLogger.warning('⚠️ Field removed: $invalidField. Retrying...');

              // حذف الحقل المفقود
              _availableFields.removeWhere((f) => f == invalidField);

              // إعادة المحاولة
              _fetchWithFieldRetry(
                domain: domain,
                offset: offset,
                orderStr: orderStr,
              ).then(
                (result) {
                  if (!completer.isCompleted) {
                    completer.complete(result);
                  }
                },
                onError: (e) {
                  if (!completer.isCompleted) {
                    completer.completeError(e);
                  }
                },
              );
              return;
            }
          }

          appLogger.error('❌ Error fetching sales orders', error: message);
          error.value = message;
          if (!completer.isCompleted) {
            completer.completeError(Exception(message));
          }
        },
      );
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }

    return completer.future;
  }

  /// الحصول على حقول أمر البيع
  List<String> _getOrderFields() {
    return [
      'name',
      'date_order',
      'partner_id',
      'user_id',
      'amount_total',
      'amount_untaxed',
      'amount_tax',
      'state',
      'invoice_status',
      'delivery_status',
      'payment_term_id',
      'validity_date',
      'confirmation_date',
      'expected_date',
      'commitment_date',
      'note',
      'client_order_ref',
      'currency_id',
      'company_id',
      'team_id',
      'tag_ids',
      'order_line',
      'write_date',
      'create_date',
    ];
  }

  /// تصفية الأوامر محلياً
  List<SaleOrderModel> filterOrders({String? search, String? status}) {
    var filtered = orders.toList();

    if (search != null && search.isNotEmpty) {
      filtered = filtered.where((order) {
        final searchLower = search.toLowerCase();
        return (order.orderName.toLowerCase().contains(searchLower)) ||
            (order.partnerName?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    if (status != null && status.isNotEmpty && status != 'all') {
      filtered = filtered.where((order) => order.state == status).toList();
    }

    return filtered;
  }

  /// تحديد أمر
  void selectOrder(SaleOrderModel order) {
    selectedOrder.value = order;
  }

  /// مسح البيانات
  void clearOrders() {
    orders.clear();
    selectedOrder.value = null;
    currentPage.value = 1;
    hasMorePages.value = true;
    error.value = '';
    _availableFields = _getOrderFields();
  }

  @override
  void onClose() {
    clearOrders();
    super.onClose();
  }
}
