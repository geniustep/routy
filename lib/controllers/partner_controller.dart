import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:routy/common/api/api.dart';
import 'package:routy/common/api/api_response.dart';
import 'package:routy/common/services/api_service.dart';
import 'package:routy/models/partners/partner_type.dart';
import 'package:routy/models/partners/partners_model.dart';
import 'package:routy/services/storage_service.dart';
import 'package:routy/utils/app_logger.dart';

/// 👥 Partner Controller - إدارة الشركاء (العملاء والموردين)
///
/// المزايا:
/// - ✅ CRUD كامل
/// - ✅ البحث والفلترة
/// - ✅ Pagination
/// - ✅ Offline Support
/// - ✅ Auto Sync
/// - ✅ Statistics
class PartnerController extends GetxController {
  // ==================== Singleton ====================
  static PartnerController get instance => Get.find<PartnerController>();

  // ==================== Dependencies ====================
  final _apiService = ApiService.instance;
  final _storageService = StorageService.instance;

  // ==================== Cache Management ====================

  /// Cache Keys
  static const String _partnersCacheKey = 'partners_cache';

  // ==================== Observable State ====================

  /// قائمة الشركاء
  final partners = <PartnerModel>[].obs;

  /// الشركاء المفلترة (للعرض)
  final filteredPartners = <PartnerModel>[].obs;

  /// الشريك المحدد حالياً
  final Rx<PartnerModel?> selectedPartner = Rx<PartnerModel?>(null);

  /// حالة التحميل
  final isLoading = false.obs;

  /// حالة التحديث (Pull to Refresh)
  final isRefreshing = false.obs;

  /// حالة المزامنة
  final isSyncing = false.obs;

  /// رسالة الخطأ
  final Rx<String?> errorMessage = Rx<String?>(null);

  /// نص البحث
  final searchQuery = ''.obs;

  /// نوع الفلتر الحالي
  final Rx<PartnerType?> currentTypeFilter = Rx<PartnerType?>(null);

  /// حالة الفلتر الحالية
  final Rx<PartnerStatus?> currentStatusFilter = Rx<PartnerStatus?>(null);

  /// عدد العناصر لكل صفحة
  final pageSize = 20.obs;

  /// الصفحة الحالية
  final currentPage = 1.obs;

  /// هل يوجد المزيد من البيانات؟
  final hasMore = true.obs;

  /// إحصائيات
  final stats = <String, dynamic>{}.obs;

  // ==================== Getters ====================

  /// هل المستخدم مسجل الدخول؟
  bool get isAuthenticated => _apiService.isAuthenticated;

  /// العملاء فقط
  List<PartnerModel> get customers =>
      partners.where((p) => p.isCustomer).toList();

  /// الموردين فقط
  List<PartnerModel> get suppliers =>
      partners.where((p) => p.isSupplier).toList();

  /// VIP فقط
  List<PartnerModel> get vipPartners => partners.where((p) => p.isVip).toList();

  /// النشطين فقط
  List<PartnerModel> get activePartners =>
      partners.where((p) => p.canTransact).toList();

  /// الذين تجاوزوا حد الائتمان
  List<PartnerModel> get exceededCreditPartners =>
      partners.where((p) => p.exceededCreditLimit).toList();

  /// الشركاء غير المتزامنة
  List<PartnerModel> get unsyncedPartners =>
      partners.where((p) => !p.synced).toList();

  /// عدد الشركاء
  int get totalCount => partners.length;

  /// عدد العملاء
  int get customersCount => customers.length;

  /// عدد الموردين
  int get suppliersCount => suppliers.length;

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      appLogger.info('🚀 Initializing PartnerController...');

      // التحقق من تسجيل الدخول أولاً
      if (!_apiService.isAuthenticated) {
        appLogger.warning(
          'User not authenticated, skipping partner initialization',
        );
        return;
      }

      // تحميل من Database المحلي
      await loadFromLocal();

      // جلب من API إذا كان فارغاً (بذكاء)
      if (partners.isEmpty) {
        await loadPartnersSmart();
      }

      // تحديث الإحصائيات
      _updateStats();

      appLogger.info('✅ PartnerController initialized');
    } catch (e) {
      appLogger.error('Failed to initialize PartnerController', error: e);
    }
  }

  @override
  void onClose() {
    appLogger.info('🔴 Closing PartnerController');
    super.onClose();
  }

  // ==================== Cache Management ====================

  /// جلب الشركاء من Cache
  Future<List<PartnerModel>?> loadPartnersFromCache() async {
    try {
      final cachedData = _storageService.getSmartCache(
        _partnersCacheKey,
        CacheType.partners,
      );
      if (cachedData != null && cachedData is List) {
        appLogger.info(
          '📦 Partners loaded from cache: ${cachedData.length} partners',
        );
        return cachedData.map((json) => PartnerModel.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      appLogger.error('Error loading partners from cache: $e');
      return null;
    }
  }

  /// حفظ الشركاء في Cache
  Future<void> savePartnersToCache(List<PartnerModel> partners) async {
    try {
      final jsonData = partners.map((partner) => partner.toJson()).toList();
      await _storageService.setSmartCache(
        _partnersCacheKey,
        jsonData,
        CacheType.partners,
      );
      appLogger.info('💾 Partners saved to cache: ${partners.length} partners');
    } catch (e) {
      appLogger.error('Error saving partners to cache: $e');
    }
  }

  /// إبطال Cache الشركاء
  Future<void> invalidatePartnersCache() async {
    try {
      await _storageService.invalidateCacheByType(CacheType.partners);
      appLogger.info('🗑️ Partners cache invalidated');
    } catch (e) {
      appLogger.error('Error invalidating partners cache: $e');
    }
  }

  /// جلب الشركاء بذكاء (Cache أولاً، ثم API)
  Future<void> loadPartnersSmart({bool forceRefresh = false}) async {
    try {
      // إذا لم يكن هناك تحديث إجباري، جرب Cache أولاً
      if (!forceRefresh) {
        final cachedPartners = await loadPartnersFromCache();
        if (cachedPartners != null && cachedPartners.isNotEmpty) {
          partners.value = cachedPartners;
          filteredPartners.value = cachedPartners;
          appLogger.info('✅ Partners loaded from cache');
          return;
        }
      }

      // إذا لم يكن هناك Cache أو كان فارغاً، جلب من API
      await fetchPartners(showLoading: true, refresh: forceRefresh);
    } catch (e) {
      appLogger.error('Error in smart partners loading: $e');
    }
  }

  // ==================== Data Loading ====================

  /// جلب الشركاء من Odoo
  Future<void> fetchPartners({
    bool showLoading = true,
    bool refresh = false,
  }) async {
    try {
      // التحقق من تسجيل الدخول أولاً
      if (!_apiService.isAuthenticated) {
        errorMessage.value = 'غير مسجل الدخول';
        appLogger.error('User not authenticated');
        return;
      }

      if (showLoading) isLoading.value = true;
      if (refresh) {
        isRefreshing.value = true;
        currentPage.value = 1;
        hasMore.value = true;
      }

      errorMessage.value = null;

      // فحص الكاش أولاً (إذا لم يكن هناك تحديث إجباري)
      if (!refresh) {
        final cachedPartners = await loadPartnersFromCache();
        if (cachedPartners != null && cachedPartners.isNotEmpty) {
          appLogger.info('📦 Cache hit: partners');

          if (refresh) {
            partners.value = cachedPartners;
          } else {
            partners.addAll(cachedPartners);
          }

          _applyFilters();
          _updateStats();

          appLogger.info(
            '✅ Loaded ${cachedPartners.length} partners from cache',
          );
          return;
        }
      }

      appLogger.info('📡 Fetching partners from Odoo...');

      List<dynamic> domain = [
        '|',
        ['customer_rank', '>', 0],
        ['supplier_rank', '>', 0],
      ];

      List<String> fields = [
        'name',
        'display_name',
        'email',
        'phone',
        'mobile',
        'street',
        'street2',
        'city',
        'zip',
        'country_id',
        'vat',
        'active',
        'is_company',
        'customer_rank',
        'supplier_rank',
        'credit_limit',
        'credit',
        'partner_latitude',
        'partner_longitude',
        'ref',
        'barcode',
      ];
      if (!kDebugMode) {
        fields.addAll(['image_1920', 'image_512']);
      }
      final completer = Completer<ApiResponse<List<PartnerModel>>>();
      Api.searchRead(
        model: 'res.partner',
        domain: domain,
        fields: fields,
        limit: pageSize.value,
        offset: (currentPage.value - 1) * pageSize.value,
        order: 'name ASC',
        context: Api.getContext({
          'tz': 'Africa/Casablanca',
          'uid': _apiService.uid ?? 1,
          'db': _apiService.database ?? 'done2026',
        }),
        onResponse: (response) {
          try {
            if (response is List) {
              final partners = response
                  .map(
                    (json) => PartnerModel.fromJson(
                      Map<String, dynamic>.from(json as Map),
                    ),
                  )
                  .toList();
              completer.complete(ApiResponse.success(partners));
            } else {
              completer.completeError('Invalid response format');
            }
          } catch (e) {
            completer.completeError('Error parsing response: $e');
          }
        },
        onError: (error, data) => completer.completeError(error),
      );

      try {
        final result = await completer.future;

        if (result.success && result.data != null) {
          final newPartners = result.data!;

          if (refresh) {
            partners.value = newPartners;
          } else {
            partners.addAll(newPartners);
          }

          // حفظ في Database المحلي
          await _saveToLocal(newPartners);

          // حفظ في الكاش الذكي
          await savePartnersToCache(newPartners);

          // تحديث hasMore
          hasMore.value = newPartners.length >= pageSize.value;

          // تطبيق الفلاتر
          _applyFilters();

          // تحديث الإحصائيات
          _updateStats();

          appLogger.info('✅ Fetched ${newPartners.length} partners');
        } else {
          errorMessage.value = result.error ?? 'فشل تحميل الشركاء';
          appLogger.error('Failed to fetch partners: ${result.error}');
        }
      } catch (completerError) {
        errorMessage.value = 'فشل تحميل الشركاء: $completerError';
        appLogger.error('API call failed', error: completerError);
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'خطأ في تحميل الشركاء';
      appLogger.error(
        'Error fetching partners',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// تحميل الصفحة التالية
  Future<void> loadMore() async {
    if (!hasMore.value || isLoading.value) return;

    currentPage.value++;
    await fetchPartners(showLoading: false);
  }

  /// تحديث البيانات (Pull to Refresh)
  @override
  Future<void> refresh() async {
    await fetchPartners(refresh: true);
  }

  /// تحميل من Database المحلي
  Future<void> loadFromLocal() async {
    try {
      appLogger.info('📦 Loading partners from local database...');

      // final localPartners = await _databaseService.getPartners();
      // partners.value = localPartners;

      // مؤقتاً: جلب من Cache
      final cached = _storageService.getCache('partners_all');
      if (cached != null && cached is List) {
        partners.value = cached
            .map(
              (json) =>
                  PartnerModel.fromJson(Map<String, dynamic>.from(json as Map)),
            )
            .toList();

        _applyFilters();
        _updateStats();

        appLogger.info('✅ Loaded ${partners.length} partners from local');
      }
    } catch (e) {
      appLogger.error('Error loading from local', error: e);
    }
  }

  /// حفظ في Database المحلي
  Future<void> _saveToLocal(List<PartnerModel> newPartners) async {
    try {
      // await _databaseService.savePartners(newPartners);

      // مؤقتاً: حفظ في Cache
      final allPartnersJson = partners.map((p) => p.toJson()).toList();
      await _storageService.setCache('partners_all', allPartnersJson);

      appLogger.info('💾 Saved ${newPartners.length} partners to local');
    } catch (e) {
      appLogger.error('Error saving to local', error: e);
    }
  }

  // ==================== CRUD Operations ====================

  /// إنشاء شريك جديد
  Future<bool> createPartner(PartnerModel partner) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      appLogger.info('➕ Creating partner: ${partner.name}');

      await Api.create(
        model: 'res.partner',
        values: partner.toOdoo(),
        onResponse: (response) async {
          if (response.success) {
            final odooId = response.data!;
            final syncedPartner = partner.markAsSynced(odooId);
            partners.insert(0, syncedPartner);
            _applyFilters();
            _updateStats();

            await _saveToLocal([syncedPartner]);

            appLogger.info('✅ Partner created with ID: $odooId');

            Get.snackbar(
              'نجح',
              'تم إنشاء الشريك بنجاح',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        onError: (error, data) {
          errorMessage.value = error;
          appLogger.error('Error creating partner', error: error);
        },
      );

      return errorMessage.value == null;
    } catch (e) {
      errorMessage.value = 'خطأ في إنشاء الشريك';
      appLogger.error('Error creating partner', error: e);

      Get.snackbar(
        'خطأ',
        errorMessage.value!,
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث شريك
  Future<bool> updatePartner(PartnerModel partner) async {
    try {
      if (partner.odooId == null) {
        errorMessage.value = 'لا يوجد Odoo ID';
        return false;
      }

      isLoading.value = true;
      errorMessage.value = null;

      appLogger.info('✏️ Updating partner: ${partner.name}');

      await Api.write(
        model: 'res.partner',
        ids: [partner.odooId!],
        values: partner.toOdoo(),
        onResponse: (response) async {
          if (response.success) {
            final index = partners.indexWhere((p) => p.id == partner.id);
            if (index != -1) {
              partners[index] = partner.copyWith(updatedAt: DateTime.now());
            }

            _applyFilters();
            _updateStats();

            await _saveToLocal([partner]);

            appLogger.info('✅ Partner updated');

            Get.snackbar(
              'نجح',
              'تم تحديث الشريك بنجاح',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        onError: (error, data) {
          errorMessage.value = error;
          appLogger.error('Error updating partner', error: error);
        },
      );

      return errorMessage.value == null;
    } catch (e) {
      errorMessage.value = 'خطأ في تحديث الشريك';
      appLogger.error('Error updating partner', error: e);

      Get.snackbar(
        'خطأ',
        errorMessage.value!,
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// حذف شريك
  Future<bool> deletePartner(int id) async {
    try {
      final partner = partners.firstWhereOrNull((p) => p.id == id);
      if (partner == null) {
        errorMessage.value = 'الشريك غير موجود';
        return false;
      }

      if (partner.odooId == null) {
        errorMessage.value = 'لا يوجد Odoo ID';
        return false;
      }

      isLoading.value = true;
      errorMessage.value = null;

      appLogger.info('🗑️ Deleting partner: ${partner.name}');

      await Api.unlink(
        model: 'res.partner',
        ids: [partner.odooId!],
        onResponse: (response) {
          if (response.success) {
            partners.removeWhere((p) => p.id == id);
            partners.removeWhere((p) => p.id == id);
            _applyFilters();
            _updateStats();

            appLogger.info('✅ Partner deleted');

            Get.snackbar(
              'نجح',
              'تم حذف الشريك بنجاح',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        onError: (error, data) {
          errorMessage.value = error;
          appLogger.error('Error deleting partner', error: error);
        },
      );

      return errorMessage.value == null;
    } catch (e) {
      errorMessage.value = 'خطأ في حذف الشريك';
      appLogger.error('Error deleting partner', error: e);

      Get.snackbar(
        'خطأ',
        errorMessage.value!,
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Search & Filter ====================

  /// بحث في الشركاء
  void searchPartners(String query) {
    searchQuery.value = query.trim();
    _applyFilters();
  }

  /// فلترة حسب النوع
  void filterByType(PartnerType? type) {
    currentTypeFilter.value = type;
    _applyFilters();
  }

  /// فلترة حسب الحالة
  void filterByStatus(PartnerStatus? status) {
    currentStatusFilter.value = status;
    _applyFilters();
  }

  /// مسح الفلاتر
  void clearFilters() {
    searchQuery.value = '';
    currentTypeFilter.value = null;
    currentStatusFilter.value = null;
    _applyFilters();
  }

  /// تطبيق الفلاتر
  void _applyFilters() {
    var result = partners.toList();

    // فلتر البحث
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((p) {
        // اسم الشريك
        final nameStr = (p.name is String)
            ? (p.name as String).toLowerCase()
            : '';

        // البريد الإلكتروني
        final emailStr = (p.email is String && p.email != false)
            ? (p.email as String).toLowerCase()
            : '';

        // الهاتف
        final phoneStr = (p.phone is String && p.phone != false)
            ? p.phone as String
            : '';

        // الجوال
        final mobileStr = (p.mobile is String && p.mobile != false)
            ? p.mobile as String
            : '';

        return nameStr.contains(query) ||
            emailStr.contains(query) ||
            phoneStr.contains(query) ||
            mobileStr.contains(query);
      }).toList();
    }

    // فلتر النوع
    if (currentTypeFilter.value != null) {
      result = result.where((p) {
        switch (currentTypeFilter.value!) {
          case PartnerType.customer:
            return p.isCustomer;
          case PartnerType.supplier:
            return p.isSupplier;
          case PartnerType.both:
            return p.isCustomer && p.isSupplier;
        }
      }).toList();
    }

    // فلتر الحالة
    if (currentStatusFilter.value != null) {
      result = result
          .where((p) => p.status == currentStatusFilter.value)
          .toList();
    }

    filteredPartners.value = result;
  }

  // ==================== Selection ====================

  /// تحديد شريك
  void selectPartner(PartnerModel partner) {
    selectedPartner.value = partner;
  }

  /// مسح التحديد
  void clearSelection() {
    selectedPartner.value = null;
  }

  /// جلب شريك بالـ ID
  PartnerModel? getPartnerById(int id) {
    return partners.firstWhereOrNull((p) => p.id == id);
  }

  /// جلب شريك بالـ Odoo ID
  PartnerModel? getPartnerByOdooId(int odooId) {
    return partners.firstWhereOrNull((p) => p.odooId == odooId);
  }

  // ==================== Sync ====================

  /// مزامنة مع Odoo
  Future<void> syncWithOdoo() async {
    try {
      isSyncing.value = true;
      errorMessage.value = null;

      appLogger.info('🔄 Syncing partners with Odoo...');

      // مزامنة الشركاء غير المتزامنة
      final unsynced = unsyncedPartners;

      if (unsynced.isEmpty) {
        appLogger.info('✅ All partners already synced');
        Get.snackbar(
          'معلومة',
          'جميع الشركاء متزامنون بالفعل',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      int successCount = 0;
      int failCount = 0;

      for (final partner in unsynced) {
        if (partner.id == null) {
          // إنشاء جديد
          final success = await createPartner(partner);
          if (success) {
            successCount++;
          } else {
            failCount++;
          }
        } else {
          // تحديث موجود
          final success = await updatePartner(partner);
          if (success) {
            successCount++;
          } else {
            failCount++;
          }
        }
      }

      appLogger.info(
        '✅ Sync completed: $successCount success, $failCount failed',
      );

      Get.snackbar(
        'اكتمل',
        'تمت المزامنة: $successCount نجح، $failCount فشل',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'خطأ في المزامنة';
      appLogger.error('Error syncing', error: e);

      Get.snackbar(
        'خطأ',
        errorMessage.value!,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSyncing.value = false;
    }
  }

  // ==================== Statistics ====================

  /// تحديث الإحصائيات
  void _updateStats() {
    stats.value = {
      'total': totalCount,
      'customers': customersCount,
      'suppliers': suppliersCount,
      'vip': vipPartners.length,
      'active': activePartners.length,
      'exceeded_credit': exceededCreditPartners.length,
      'unsynced': unsyncedPartners.length,
    };
  }

  /// الحصول على إحصائية
  dynamic getStat(String key) => stats[key];

  // ==================== Utility Methods ====================

  /// مسح الخطأ
  void clearError() {
    errorMessage.value = null;
  }

  /// مسح البيانات
  Future<void> clearData() async {
    partners.clear();
    filteredPartners.clear();
    selectedPartner.value = null;
    searchQuery.value = '';
    currentTypeFilter.value = null;
    currentStatusFilter.value = null;
    currentPage.value = 1;
    hasMore.value = true;
    errorMessage.value = null;
    _updateStats();

    // مسح جميع كاشات الشركاء
    await _storageService.deleteCache('partners_all');
    for (int i = 1; i <= 10; i++) {
      // مسح أول 10 صفحات
      await _storageService.deleteCache('partners_page_$i');
    }
    appLogger.info('🗑️ Partner data and cache cleared');
  }

  /// مسح الكاش فقط
  Future<void> clearCache() async {
    await _storageService.deleteCache('partners_all');
    for (int i = 1; i <= 10; i++) {
      await _storageService.deleteCache('partners_page_$i');
    }
    appLogger.info('🗑️ Partner cache cleared');
  }

  /// التحقق من إمكانية جلب الشركاء
  bool canFetchPartners() {
    if (!isAuthenticated) {
      appLogger.warning('Cannot fetch partners: User not authenticated');
      return false;
    }
    return true;
  }

  /// جلب الشركاء من التخزين المحلي (للمستخدمين غير المسجلين)
  Future<void> loadPartnersFromStorage() async {
    try {
      appLogger.info('📦 Loading partners from storage...');

      // جلب من الكاش العام
      final cached = _storageService.getCache('partners_all');
      if (cached != null && cached is List) {
        partners.value = cached
            .map(
              (json) =>
                  PartnerModel.fromJson(Map<String, dynamic>.from(json as Map)),
            )
            .toList();

        _applyFilters();
        _updateStats();

        appLogger.info('✅ Loaded ${partners.length} partners from storage');
      } else {
        appLogger.info('📭 No partners found in storage');
      }
    } catch (e) {
      appLogger.error('Error loading partners from storage', error: e);
    }
  }
}
