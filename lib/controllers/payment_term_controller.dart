// lib/controllers/payment_term_controller.dart

import 'package:get/get.dart';
import 'dart:async';
import '../models/common/payment_term_model.dart';
import '../common/api/api.dart';
import 'package:routy/utils/app_logger.dart';

/// 💳 Payment Term Controller - تحكم في شروط الدفع
///
/// يدير:
/// - جلب شروط الدفع
/// - إدارة شروط الدفع
/// - تطبيق الشروط
/// - حساب الخصومات
class PaymentTermController extends GetxController {
  // ============= State =============

  final RxList<PaymentTermModel> paymentTerms = <PaymentTermModel>[].obs;
  final RxList<PaymentTermModel> filteredPaymentTerms =
      <PaymentTermModel>[].obs;
  final Rx<PaymentTermModel?> selectedPaymentTerm = Rx<PaymentTermModel?>(null);

  // الحالة
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString error = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPaymentTerms = 0.obs;
  final RxBool hasMorePages = true.obs;
  final int paymentTermsPerPage = 20;

  // البحث والفلترة
  final RxString searchQuery = ''.obs;
  final RxBool showOnlyActive = true.obs;

  // الحقول المتاحة (يتم تحديثها ديناميكياً)
  late List<String> _availableFields;

  // ============= Lifecycle =============

  @override
  void onInit() {
    super.onInit();
    _availableFields = _getPaymentTermFields();

    // مراقبة تغييرات البحث
    ever(searchQuery, (_) => _applyFilters());
    ever(showOnlyActive, (_) => _applyFilters());

    appLogger.info('✅ PaymentTermController initialized');
  }

  @override
  void onClose() {
    appLogger.info('🗑️ PaymentTermController disposed');
    super.onClose();
  }

  // ============= Data Fetching =============

  /// جلب شروط الدفع مع معالجة الحقول المفقودة
  Future<List<PaymentTermModel>> fetchPaymentTerms({
    String? search,
    bool? activeOnly,
    int? page,
    String? sortField,
    String? sortOrder,
  }) async {
    try {
      appLogger.info('💳 Fetching payment terms...');

      // بناء domain للفلترة
      List<dynamic> domain = [];

      // فلتر البحث
      if (search != null && search.isNotEmpty) {
        domain.add('|');
        domain.add(['name', 'ilike', search]);
        domain.add(['note', 'ilike', search]);
      }

      // فلتر النشاط
      if (activeOnly == true) {
        domain.add(['active', '=', true]);
      }

      final int offset = ((page ?? 1) - 1) * paymentTermsPerPage;
      final String orderStr = sortField != null && sortOrder != null
          ? '$sortField $sortOrder'
          : 'name ASC';

      return await _fetchWithFieldRetry(
        domain: domain,
        offset: offset,
        orderStr: orderStr,
      );
    } catch (e, stackTrace) {
      appLogger.error(
        '❌ Exception in fetchPaymentTerms',
        error: e,
        stackTrace: stackTrace,
      );
      error.value = e.toString();
      rethrow;
    }
  }

  /// جلب البيانات مع إعادة المحاولة عند فشل الحقول
  Future<List<PaymentTermModel>> _fetchWithFieldRetry({
    required List<dynamic> domain,
    required int offset,
    required String orderStr,
  }) async {
    final completer = Completer<List<PaymentTermModel>>();

    try {
      await Api.searchRead(
        model: 'account.payment.term',
        domain: domain,
        fields: _availableFields,
        limit: paymentTermsPerPage,
        offset: offset,
        order: orderStr,
        onResponse: (response) {
          appLogger.info('✅ Payment terms fetched successfully');

          final paymentTermsList = (response as List<dynamic>)
              .map(
                (json) =>
                    PaymentTermModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

          // تحديث البيانات
          if (offset == 0) {
            paymentTerms.value = paymentTermsList;
          } else {
            paymentTerms.addAll(paymentTermsList);
          }

          hasMorePages.value = paymentTermsList.length >= paymentTermsPerPage;
          currentPage.value = (offset ~/ paymentTermsPerPage) + 1;

          if (!completer.isCompleted) {
            completer.complete(paymentTermsList);
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

          appLogger.error('❌ Error fetching payment terms', error: message);
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

  /// الحصول على حقول شروط الدفع
  List<String> _getPaymentTermFields() {
    return [
      'name',
      'display_name',
      'active',
      'sequence',
      'line_ids',
      'company_id',
      'note',
      'early_pay_discount_computation',
      'early_discount',
      'early_discount_computation',
      'early_discount_days',
      'write_date',
      'create_date',
    ];
  }

  // ============= Search and Filter =============

  /// البحث في شروط الدفع
  void searchPaymentTerms(String query) {
    searchQuery.value = query;
  }

  /// تبديل فلتر النشاط
  void toggleActiveFilter() {
    showOnlyActive.value = !showOnlyActive.value;
  }

  /// تطبيق الفلاتر
  void _applyFilters() {
    var filtered = paymentTerms.toList();

    // فلتر البحث
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((paymentTerm) {
        return paymentTerm.paymentTermName.toLowerCase().contains(query) ||
            (paymentTerm.noteText?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // فلتر النشاط
    if (showOnlyActive.value) {
      filtered = filtered.where((paymentTerm) => paymentTerm.isActive).toList();
    }

    filteredPaymentTerms.value = filtered;
  }

  // ============= Payment Term Selection =============

  /// تحديد شروط الدفع
  void selectPaymentTerm(PaymentTermModel paymentTerm) {
    selectedPaymentTerm.value = paymentTerm;
    appLogger.info('✅ Payment term selected: ${paymentTerm.paymentTermName}');
  }

  /// تحديد شروط الدفع بالـ ID
  void selectPaymentTermById(int paymentTermId) {
    final paymentTerm = paymentTerms.firstWhereOrNull(
      (p) => p.id == paymentTermId,
    );
    if (paymentTerm != null) {
      selectPaymentTerm(paymentTerm);
    } else {
      appLogger.warning('⚠️ Payment term not found with ID: $paymentTermId');
    }
  }

  /// إلغاء تحديد شروط الدفع
  void clearSelection() {
    selectedPaymentTerm.value = null;
    appLogger.info('🗑️ Payment term selection cleared');
  }

  // ============= Payment Term Management =============

  /// البحث عن شروط الدفع بالاسم
  Future<PaymentTermModel?> findPaymentTermByName(String name) async {
    try {
      appLogger.info('🔍 Searching for payment term with name: $name');

      final paymentTerms = await fetchPaymentTerms(
        search: name,
        activeOnly: true,
      );

      final paymentTerm = paymentTerms.firstWhereOrNull(
        (p) => p.paymentTermName.toLowerCase() == name.toLowerCase(),
      );

      if (paymentTerm != null) {
        appLogger.info('✅ Payment term found: ${paymentTerm.paymentTermName}');
        return paymentTerm;
      } else {
        appLogger.warning('⚠️ Payment term not found with name: $name');
        return null;
      }
    } catch (e) {
      appLogger.error('❌ Error finding payment term by name: $e');
      return null;
    }
  }

  // ============= Payment Term Lines =============

  /// جلب شروط الدفع لقائمة محددة
  Future<List<PaymentTermLineModel>> fetchPaymentTermLines(
    int paymentTermId,
  ) async {
    try {
      appLogger.info('📋 Fetching payment term lines for ID: $paymentTermId');

      final completer = Completer<List<PaymentTermLineModel>>();

      Api.searchRead(
        model: 'account.payment.term.line',
        domain: [
          ['payment_id', '=', paymentTermId],
        ],
        fields: [
          'name',
          'payment_id',
          'sequence',
          'value',
          'value_amount',
          'days',
          'option',
          'day_of_month',
          'discount',
          'discount_days',
        ],
        onResponse: (response) {
          appLogger.info('✅ Payment term lines fetched successfully');
          final lines = (response as List<dynamic>)
              .map(
                (json) =>
                    PaymentTermLineModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
          completer.complete(lines);
        },
        onError: (message, data) {
          appLogger.error('❌ Error fetching payment term lines: $message');
          completer.complete(<PaymentTermLineModel>[]);
        },
      );

      return completer.future;
    } catch (e) {
      appLogger.error('❌ Error fetching payment term lines: $e');
      return <PaymentTermLineModel>[];
    }
  }

  // ============= Data Management =============

  /// مسح البيانات
  void clearPaymentTerms() {
    paymentTerms.clear();
    filteredPaymentTerms.clear();
    selectedPaymentTerm.value = null;
    currentPage.value = 1;
    hasMorePages.value = true;
    error.value = '';
    _availableFields = _getPaymentTermFields();

    appLogger.info('🗑️ Payment terms data cleared');
  }

  /// إعادة تحميل البيانات
  Future<void> refreshPaymentTerms() async {
    clearPaymentTerms();
    await fetchPaymentTerms(
      search: searchQuery.value,
      activeOnly: showOnlyActive.value,
    );
  }

  // ============= Getters =============

  bool get hasPaymentTerms => paymentTerms.isNotEmpty;
  bool get hasFilteredPaymentTerms => filteredPaymentTerms.isNotEmpty;
  bool get hasSelectedPaymentTerm => selectedPaymentTerm.value != null;
  int get paymentTermsCount => paymentTerms.length;
  int get filteredPaymentTermsCount => filteredPaymentTerms.length;

  List<PaymentTermModel> get activePaymentTerms =>
      paymentTerms.where((p) => p.isActive).toList();

  // ============= Statistics =============

  /// الحصول على إحصائيات شروط الدفع
  Map<String, dynamic> getPaymentTermStatistics() {
    final total = paymentTerms.length;
    final active = paymentTerms.where((p) => p.isActive).length;
    final withLines = paymentTerms.where((p) => p.hasLines).length;
    final withEarlyDiscount = paymentTerms
        .where((p) => p.hasEarlyDiscount)
        .length;
    final totalLines = paymentTerms.fold(0, (sum, p) => sum + p.linesCount);

    return {
      'total': total,
      'active': active,
      'inactive': total - active,
      'withLines': withLines,
      'withoutLines': total - withLines,
      'withEarlyDiscount': withEarlyDiscount,
      'withoutEarlyDiscount': total - withEarlyDiscount,
      'totalLines': totalLines,
      'averageLinesPerTerm': total > 0 ? totalLines / total : 0.0,
    };
  }

  // ============= Early Discount Analysis =============

  /// الحصول على شروط الدفع مع خصم الدفع المبكر
  List<PaymentTermModel> getPaymentTermsWithEarlyDiscount() {
    return paymentTerms.where((p) => p.hasEarlyDiscount).toList();
  }

  /// الحصول على شروط الدفع بدون خصم الدفع المبكر
  List<PaymentTermModel> getPaymentTermsWithoutEarlyDiscount() {
    return paymentTerms.where((p) => !p.hasEarlyDiscount).toList();
  }

  /// تحليل خصم الدفع المبكر
  Map<String, dynamic> analyzeEarlyDiscounts() {
    final withEarlyDiscount = getPaymentTermsWithEarlyDiscount();
    final withoutEarlyDiscount = getPaymentTermsWithoutEarlyDiscount();

    double totalEarlyDiscount = 0.0;
    int totalEarlyDiscountDays = 0;

    for (var term in withEarlyDiscount) {
      totalEarlyDiscount += term.earlyDiscountValue;
      totalEarlyDiscountDays += term.earlyDiscountDaysValue;
    }

    return {
      'withEarlyDiscount': withEarlyDiscount.length,
      'withoutEarlyDiscount': withoutEarlyDiscount.length,
      'averageEarlyDiscount': withEarlyDiscount.isNotEmpty
          ? totalEarlyDiscount / withEarlyDiscount.length
          : 0.0,
      'averageEarlyDiscountDays': withEarlyDiscount.isNotEmpty
          ? totalEarlyDiscountDays / withEarlyDiscount.length
          : 0.0,
      'maxEarlyDiscount': withEarlyDiscount.isNotEmpty
          ? withEarlyDiscount
                .map((p) => p.earlyDiscountValue)
                .reduce((a, b) => a > b ? a : b)
          : 0.0,
      'minEarlyDiscount': withEarlyDiscount.isNotEmpty
          ? withEarlyDiscount
                .map((p) => p.earlyDiscountValue)
                .reduce((a, b) => a < b ? a : b)
          : 0.0,
    };
  }
}
