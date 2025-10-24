// lib/controllers/product_controller.dart

import 'package:get/get.dart';
import 'dart:async';
import '../models/products/product_model.dart';
import '../common/api/api.dart';
import '../services/storage_service.dart';
import 'package:routy/utils/app_logger.dart';

/// 📦 Product Controller - تحكم في المنتجات
///
/// يدير:
/// - جلب المنتجات
/// - البحث والفلترة
/// - إدارة المخزون
/// - معلومات المنتجات
class ProductController extends GetxController {
  // ============= Dependencies =============
  late final StorageService _storageService;

  // ============= Cache Management =============

  /// Cache Keys
  static const String _productsCacheKey = 'products_cache';

  // ============= State =============

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);

  // الحالة
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString error = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalProducts = 0.obs;
  final RxBool hasMorePages = true.obs;
  final int productsPerPage = 50;

  // البحث والفلترة
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedType = ''.obs;
  final RxBool showOnlyActive = true.obs;

  // الحقول المتاحة (يتم تحديثها ديناميكياً)
  late List<String> _availableFields;

  // ============= Lifecycle =============

  @override
  void onInit() {
    super.onInit();
    try {
      _storageService = StorageService.instance;
      _availableFields = _getProductFields();

      // مراقبة تغييرات البحث
      ever(searchQuery, (_) => _applyFilters());
      ever(selectedCategory, (_) => _applyFilters());
      ever(selectedType, (_) => _applyFilters());
      ever(showOnlyActive, (_) => _applyFilters());

      appLogger.info('✅ ProductController initialized');
    } catch (e) {
      appLogger.error('❌ Error initializing ProductController: $e');
      // تهيئة بديلة
      _storageService = StorageService.instance;
      _availableFields = _getProductFields();
    }
  }

  @override
  void onClose() {
    appLogger.info('🗑️ ProductController disposed');
    super.onClose();
  }

  // ============= Cache Management =============

  /// جلب المنتجات من Cache
  Future<List<ProductModel>?> loadProductsFromCache() async {
    try {
      final cachedData = _storageService.getSmartCache(
        _productsCacheKey,
        CacheType.products,
      );
      if (cachedData != null && cachedData is List) {
        appLogger.info(
          '📦 Products loaded from cache: ${cachedData.length} products',
        );
        return cachedData.map((json) => ProductModel.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      appLogger.error('Error loading products from cache: $e');
      return null;
    }
  }

  /// حفظ المنتجات في Cache
  Future<void> saveProductsToCache(List<ProductModel> products) async {
    try {
      final jsonData = products.map((product) => product.toJson()).toList();
      await _storageService.setSmartCache(
        _productsCacheKey,
        jsonData,
        CacheType.products,
      );
      appLogger.info('💾 Products saved to cache: ${products.length} products');
    } catch (e) {
      appLogger.error('Error saving products to cache: $e');
    }
  }

  /// إبطال Cache المنتجات
  Future<void> invalidateProductsCache() async {
    try {
      await _storageService.invalidateCacheByType(CacheType.products);
      appLogger.info('🗑️ Products cache invalidated');
    } catch (e) {
      appLogger.error('Error invalidating products cache: $e');
    }
  }

  /// جلب المنتجات بذكاء (Cache أولاً، ثم API)
  Future<void> loadProductsSmart({bool forceRefresh = false}) async {
    try {
      // إذا لم يكن هناك تحديث إجباري، جرب Cache أولاً
      if (!forceRefresh) {
        final cachedProducts = await loadProductsFromCache();
        if (cachedProducts != null && cachedProducts.isNotEmpty) {
          products.value = cachedProducts;
          filteredProducts.value = cachedProducts;
          appLogger.info('✅ Products loaded from cache');
          return;
        }
      }

      // إذا لم يكن هناك Cache أو كان فارغاً، جلب من API
      await fetchProducts();
    } catch (e) {
      appLogger.error('Error in smart products loading: $e');
    }
  }

  // ============= Data Fetching =============

  /// جلب المنتجات مع معالجة الحقول المفقودة
  Future<List<ProductModel>> fetchProducts({
    String? search,
    String? category,
    String? type,
    bool? activeOnly,
    int? page,
    String? sortField,
    String? sortOrder,
  }) async {
    try {
      appLogger.info('📦 Fetching products...');

      // بناء domain للفلترة
      List<dynamic> domain = [];

      // فلتر البحث
      if (search != null && search.isNotEmpty) {
        domain.add('|');
        domain.add(['name', 'ilike', search]);
        domain.add(['default_code', 'ilike', search]);
        domain.add(['barcode', 'ilike', search]);
      }

      // فلتر الفئة
      if (category != null && category.isNotEmpty && category != 'all') {
        domain.add(['categ_id', '=', int.tryParse(category)]);
      }

      // فلتر النوع
      if (type != null && type.isNotEmpty && type != 'all') {
        domain.add(['type', '=', type]);
      }

      // فلتر النشاط
      if (activeOnly == true) {
        domain.add(['active', '=', true]);
      }

      final int offset = ((page ?? 1) - 1) * productsPerPage;
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
        '❌ Exception in fetchProducts',
        error: e,
        stackTrace: stackTrace,
      );
      error.value = e.toString();
      rethrow;
    }
  }

  /// جلب البيانات مع إعادة المحاولة عند فشل الحقول
  Future<List<ProductModel>> _fetchWithFieldRetry({
    required List<dynamic> domain,
    required int offset,
    required String orderStr,
  }) async {
    final completer = Completer<List<ProductModel>>();

    try {
      await Api.searchRead(
        model: 'product.product',
        domain: domain,
        fields: _availableFields,
        limit: productsPerPage,
        offset: offset,
        order: orderStr,
        onResponse: (response) {
          appLogger.info('✅ Products fetched successfully');

          final productsList = (response as List<dynamic>)
              .map(
                (json) => ProductModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

          // تحديث البيانات
          if (offset == 0) {
            products.value = productsList;
          } else {
            products.addAll(productsList);
          }

          hasMorePages.value = productsList.length >= productsPerPage;
          currentPage.value = (offset ~/ productsPerPage) + 1;

          if (!completer.isCompleted) {
            completer.complete(productsList);
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

          appLogger.error('❌ Error fetching products', error: message);
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

  /// الحصول على حقول المنتج
  List<String> _getProductFields() {
    return [
      'name',
      'default_code',
      'barcode',
      'active',
      'list_price',
      'standard_price',
      'sale_ok',
      'purchase_ok',
      'type',
      'categ_id',
      'uom_id',
      'uom_po_id',
      'description',
      'description_sale',
      'description_purchase',
      'weight',
      'volume',
      'sale_delay',
      'tracking',
      'route_ids',
      'company_id',
      'currency_id',
      'write_date',
      'create_date',
    ];
  }

  // ============= Search and Filter =============

  /// البحث في المنتجات
  void searchProducts(String query) {
    searchQuery.value = query;
  }

  /// فلترة حسب الفئة
  void filterByCategory(String category) {
    selectedCategory.value = category;
  }

  /// فلترة حسب النوع
  void filterByType(String type) {
    selectedType.value = type;
  }

  /// تبديل فلتر النشاط
  void toggleActiveFilter() {
    showOnlyActive.value = !showOnlyActive.value;
  }

  /// تطبيق الفلاتر
  void _applyFilters() {
    var filtered = products.toList();

    // فلتر البحث
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((product) {
        return product.productName.toLowerCase().contains(query) ||
            (product.productCode?.toLowerCase().contains(query) ?? false) ||
            (product.productBarcode?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // فلتر الفئة
    if (selectedCategory.value.isNotEmpty && selectedCategory.value != 'all') {
      final categoryId = int.tryParse(selectedCategory.value);
      if (categoryId != null) {
        filtered = filtered
            .where((product) => product.categoryId == categoryId)
            .toList();
      }
    }

    // فلتر النوع
    if (selectedType.value.isNotEmpty && selectedType.value != 'all') {
      filtered = filtered
          .where((product) => product.productType == selectedType.value)
          .toList();
    }

    // فلتر النشاط
    if (showOnlyActive.value) {
      filtered = filtered.where((product) => product.isActive).toList();
    }

    filteredProducts.value = filtered;
  }

  // ============= Product Selection =============

  /// تحديد منتج
  void selectProduct(ProductModel product) {
    selectedProduct.value = product;
    appLogger.info('✅ Product selected: ${product.productName}');
  }

  /// إلغاء تحديد المنتج
  void clearSelection() {
    selectedProduct.value = null;
    appLogger.info('🗑️ Product selection cleared');
  }

  // ============= Product Management =============

  /// البحث عن منتج بالباركود
  Future<ProductModel?> findProductByBarcode(String barcode) async {
    try {
      appLogger.info('🔍 Searching for product with barcode: $barcode');

      final products = await fetchProducts(search: barcode, activeOnly: true);

      final product = products.firstWhereOrNull(
        (p) => p.productBarcode == barcode,
      );

      if (product != null) {
        appLogger.info('✅ Product found: ${product.productName}');
        return product;
      } else {
        appLogger.warning('⚠️ Product not found with barcode: $barcode');
        return null;
      }
    } catch (e) {
      appLogger.error('❌ Error finding product by barcode: $e');
      return null;
    }
  }

  /// البحث عن منتج بالكود
  Future<ProductModel?> findProductByCode(String code) async {
    try {
      appLogger.info('🔍 Searching for product with code: $code');

      final products = await fetchProducts(search: code, activeOnly: true);

      final product = products.firstWhereOrNull((p) => p.productCode == code);

      if (product != null) {
        appLogger.info('✅ Product found: ${product.productName}');
        return product;
      } else {
        appLogger.warning('⚠️ Product not found with code: $code');
        return null;
      }
    } catch (e) {
      appLogger.error('❌ Error finding product by code: $e');
      return null;
    }
  }

  // ============= Data Management =============

  /// مسح البيانات
  void clearProducts() {
    products.clear();
    filteredProducts.clear();
    selectedProduct.value = null;
    currentPage.value = 1;
    hasMorePages.value = true;
    error.value = '';
    _availableFields = _getProductFields();

    appLogger.info('🗑️ Products data cleared');
  }

  /// إعادة تحميل البيانات
  Future<void> refreshProducts() async {
    clearProducts();
    await fetchProducts(
      search: searchQuery.value,
      category: selectedCategory.value,
      type: selectedType.value,
      activeOnly: showOnlyActive.value,
    );
  }

  // ============= Getters =============

  bool get hasProducts => products.isNotEmpty;
  bool get hasFilteredProducts => filteredProducts.isNotEmpty;
  bool get hasSelectedProduct => selectedProduct.value != null;
  int get productsCount => products.length;
  int get filteredProductsCount => filteredProducts.length;

  List<ProductModel> get activeProducts =>
      products.where((p) => p.isActive).toList();
  List<ProductModel> get saleableProducts =>
      products.where((p) => p.canBeSold).toList();
  List<ProductModel> get purchasableProducts =>
      products.where((p) => p.canBePurchased).toList();

  // ============= Categories =============

  List<String> get availableCategories {
    final categories = <String>{};
    for (var product in products) {
      if (product.categoryName != null) {
        categories.add(product.categoryName!);
      }
    }
    return categories.toList()..sort();
  }

  List<String> get availableTypes {
    final types = <String>{};
    for (var product in products) {
      types.add(product.productType);
    }
    return types.toList()..sort();
  }
}
