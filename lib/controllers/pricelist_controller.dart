// lib/controllers/pricelist_controller.dart

import 'package:get/get.dart';
import 'dart:async';
import '../models/products/product_list/pricelist_model.dart';
import '../common/api/api.dart';
import 'package:routy/utils/app_logger.dart';

/// 💰 Price List Controller - تحكم في قوائم الأسعار
///
/// يدير:
/// - جلب قوائم الأسعار
/// - إدارة قواعد الأسعار
/// - تطبيق الأسعار
/// - حساب الخصومات
class PricelistController extends GetxController {
  // ============= State =============

  final RxList<PricelistModel> priceLists = <PricelistModel>[].obs;
  final RxList<PricelistModel> filteredPriceLists = <PricelistModel>[].obs;
  final Rx<PricelistModel?> selectedPriceList = Rx<PricelistModel?>(null);

  // الحالة
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString error = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPriceLists = 0.obs;
  final RxBool hasMorePages = true.obs;
  final int priceListsPerPage = 20;

  // البحث والفلترة
  final RxString searchQuery = ''.obs;
  final RxBool showOnlyActive = true.obs;
  final RxString selectedCurrency = ''.obs;

  // الحقول المتاحة (يتم تحديثها ديناميكياً)
  late List<String> _availableFields;

  // ============= Lifecycle =============

  @override
  void onInit() {
    super.onInit();
    _availableFields = _getPricelistFields();

    // مراقبة تغييرات البحث
    ever(searchQuery, (_) => _applyFilters());
    ever(showOnlyActive, (_) => _applyFilters());
    ever(selectedCurrency, (_) => _applyFilters());

    appLogger.info('✅ PricelistController initialized');
  }

  @override
  void onClose() {
    appLogger.info('🗑️ PricelistController disposed');
    super.onClose();
  }

  // ============= Data Fetching =============

  /// جلب قوائم الأسعار مع معالجة الحقول المفقودة
  Future<List<PricelistModel>> fetchPriceLists({
    String? search,
    bool? activeOnly,
    String? currency,
    int? page,
    String? sortField,
    String? sortOrder,
  }) async {
    try {
      appLogger.info('💰 Fetching price lists...');

      // بناء domain للفلترة
      List<dynamic> domain = [];

      // فلتر البحث
      if (search != null && search.isNotEmpty) {
        domain.add('|');
        domain.add(['name', 'ilike', search]);
        domain.add(['code', 'ilike', search]);
      }

      // فلتر النشاط
      if (activeOnly == true) {
        domain.add(['active', '=', true]);
      }

      // فلتر العملة
      if (currency != null && currency.isNotEmpty && currency != 'all') {
        domain.add(['currency_id', '=', int.tryParse(currency)]);
      }

      final int offset = ((page ?? 1) - 1) * priceListsPerPage;
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
        '❌ Exception in fetchPriceLists',
        error: e,
        stackTrace: stackTrace,
      );
      error.value = e.toString();
      rethrow;
    }
  }

  /// جلب البيانات مع إعادة المحاولة عند فشل الحقول
  Future<List<PricelistModel>> _fetchWithFieldRetry({
    required List<dynamic> domain,
    required int offset,
    required String orderStr,
  }) async {
    final completer = Completer<List<PricelistModel>>();

    try {
      await Api.searchRead(
        model: 'product.pricelist',
        domain: domain,
        fields: _availableFields,
        limit: priceListsPerPage,
        offset: offset,
        order: orderStr,
        onResponse: (response) {
          appLogger.info('✅ Price lists fetched successfully');

          final priceListsList = (response as List<dynamic>)
              .map(
                (json) => PricelistModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

          // تحديث البيانات
          if (offset == 0) {
            priceLists.value = priceListsList;
          } else {
            priceLists.addAll(priceListsList);
          }

          hasMorePages.value = priceListsList.length >= priceListsPerPage;
          currentPage.value = (offset ~/ priceListsPerPage) + 1;

          if (!completer.isCompleted) {
            completer.complete(priceListsList);
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

          appLogger.error('❌ Error fetching price lists', error: message);
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

  /// الحصول على حقول قائمة الأسعار
  List<String> _getPricelistFields() {
    return [
      'name',
      'display_name',
      'active',
      'currency_id',
      'item_ids',
      'company_id',
      'country_group_ids',
      'selectable',
      'discount_policy',
      'website_id',
      'code',
      'sequence',
      'write_date',
      'create_date',
    ];
  }

  // ============= Search and Filter =============

  /// البحث في قوائم الأسعار
  void searchPriceLists(String query) {
    searchQuery.value = query;
  }

  /// فلترة حسب العملة
  void filterByCurrency(String currency) {
    selectedCurrency.value = currency;
  }

  /// تبديل فلتر النشاط
  void toggleActiveFilter() {
    showOnlyActive.value = !showOnlyActive.value;
  }

  /// تطبيق الفلاتر
  void _applyFilters() {
    var filtered = priceLists.toList();

    // فلتر البحث
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((pricelist) {
        return pricelist.pricelistName.toLowerCase().contains(query) ||
            (pricelist.pricelistCode?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // فلتر النشاط
    if (showOnlyActive.value) {
      filtered = filtered.where((pricelist) => pricelist.isActive).toList();
    }

    // فلتر العملة
    if (selectedCurrency.value.isNotEmpty && selectedCurrency.value != 'all') {
      final currencyId = int.tryParse(selectedCurrency.value);
      if (currencyId != null) {
        filtered = filtered
            .where((pricelist) => pricelist.currencyIdInt == currencyId)
            .toList();
      }
    }

    filteredPriceLists.value = filtered;
  }

  // ============= Price List Selection =============

  /// تحديد قائمة أسعار
  void selectPriceList(PricelistModel priceList) {
    selectedPriceList.value = priceList;
    appLogger.info('✅ Price list selected: ${priceList.pricelistName}');
  }

  /// تحديد قائمة أسعار بالـ ID
  void selectPriceListById(int priceListId) {
    final priceList = priceLists.firstWhereOrNull((p) => p.id == priceListId);
    if (priceList != null) {
      selectPriceList(priceList);
    } else {
      appLogger.warning('⚠️ Price list not found with ID: $priceListId');
    }
  }

  /// إلغاء تحديد قائمة الأسعار
  void clearSelection() {
    selectedPriceList.value = null;
    appLogger.info('🗑️ Price list selection cleared');
  }

  // ============= Price List Management =============

  /// البحث عن قائمة أسعار بالاسم
  Future<PricelistModel?> findPriceListByName(String name) async {
    try {
      appLogger.info('🔍 Searching for price list with name: $name');

      final priceLists = await fetchPriceLists(search: name, activeOnly: true);

      final priceList = priceLists.firstWhereOrNull(
        (p) => p.pricelistName.toLowerCase() == name.toLowerCase(),
      );

      if (priceList != null) {
        appLogger.info('✅ Price list found: ${priceList.pricelistName}');
        return priceList;
      } else {
        appLogger.warning('⚠️ Price list not found with name: $name');
        return null;
      }
    } catch (e) {
      appLogger.error('❌ Error finding price list by name: $e');
      return null;
    }
  }

  /// البحث عن قائمة أسعار بالكود
  Future<PricelistModel?> findPriceListByCode(String code) async {
    try {
      appLogger.info('🔍 Searching for price list with code: $code');

      final priceLists = await fetchPriceLists(search: code, activeOnly: true);

      final priceList = priceLists.firstWhereOrNull(
        (p) => p.pricelistCode == code,
      );

      if (priceList != null) {
        appLogger.info('✅ Price list found: ${priceList.pricelistName}');
        return priceList;
      } else {
        appLogger.warning('⚠️ Price list not found with code: $code');
        return null;
      }
    } catch (e) {
      appLogger.error('❌ Error finding price list by code: $e');
      return null;
    }
  }

  // ============= Price List Rules =============

  /// جلب قواعد قائمة أسعار محددة
  Future<List<PricelistItemModel>> fetchPriceListRules(int priceListId) async {
    try {
      appLogger.info('📋 Fetching price list rules for ID: $priceListId');

      final completer = Completer<List<PricelistItemModel>>();

      Api.searchRead(
        model: 'product.pricelist.item',
        domain: [
          ['pricelist_id', '=', priceListId],
        ],
        fields: [
          'name',
          'pricelist_id',
          'product_id',
          'product_tmpl_id',
          'price',
          'fixed_price',
          'discount',
          'min_quantity',
          'max_quantity',
          'date_start',
          'date_end',
          'applied_on',
          'categ_id',
          'product_name',
          'product_tmpl_name',
          'base',
          'base_pricelist_id',
          'compute_price',
          'sequence',
          'active',
        ],
        onResponse: (response) {
          appLogger.info('✅ Price list rules fetched successfully');
          final rules = (response as List<dynamic>)
              .map(
                (json) =>
                    PricelistItemModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
          completer.complete(rules);
        },
        onError: (message, data) {
          appLogger.error('❌ Error fetching price list rules: $message');
          completer.complete(<PricelistItemModel>[]);
        },
      );

      return completer.future;
    } catch (e) {
      appLogger.error('❌ Error fetching price list rules: $e');
      return <PricelistItemModel>[];
    }
  }

  // ============= Data Management =============

  /// مسح البيانات
  void clearPriceLists() {
    priceLists.clear();
    filteredPriceLists.clear();
    selectedPriceList.value = null;
    currentPage.value = 1;
    hasMorePages.value = true;
    error.value = '';
    _availableFields = _getPricelistFields();

    appLogger.info('🗑️ Price lists data cleared');
  }

  /// إعادة تحميل البيانات
  Future<void> refreshPriceLists() async {
    clearPriceLists();
    await fetchPriceLists(
      search: searchQuery.value,
      activeOnly: showOnlyActive.value,
      currency: selectedCurrency.value,
    );
  }

  // ============= Getters =============

  bool get hasPriceLists => priceLists.isNotEmpty;
  bool get hasFilteredPriceLists => filteredPriceLists.isNotEmpty;
  bool get hasSelectedPriceList => selectedPriceList.value != null;
  int get priceListsCount => priceLists.length;
  int get filteredPriceListsCount => filteredPriceLists.length;

  List<PricelistModel> get activePriceLists =>
      priceLists.where((p) => p.isActive).toList();
  List<PricelistModel> get selectablePriceLists =>
      priceLists.where((p) => p.isActive).toList();

  // ============= Currencies =============

  List<String> get availableCurrencies {
    final currencies = <String>{};
    for (var priceList in priceLists) {
      if (priceList.currencyName != null) {
        currencies.add(priceList.currencyName!);
      }
    }
    return currencies.toList()..sort();
  }

  // ============= Statistics =============

  /// الحصول على إحصائيات قوائم الأسعار
  Map<String, dynamic> getPriceListStatistics() {
    final total = priceLists.length;
    final active = priceLists.where((p) => p.isActive).length;
    final withRules = priceLists.where((p) => p.hasRules).length;
    final totalRules = priceLists.fold(0, (sum, p) => sum + p.rulesCount);

    return {
      'total': total,
      'active': active,
      'inactive': total - active,
      'withRules': withRules,
      'withoutRules': total - withRules,
      'totalRules': totalRules,
      'averageRulesPerList': total > 0 ? totalRules / total : 0.0,
    };
  }
}
