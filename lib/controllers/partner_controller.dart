import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import '../models/partners/partners_model.dart';
import '../common/services/enhanced_data_controller.dart';
import '../services/storage_service.dart';
import '../utils/app_logger.dart';

/// 🎯 PartnerController - إدارة الشركاء مع المزايا المتقدمة
///
/// يجمع بين:
/// ✅ GetX للتفاعلية
/// ✅ Enhanced DataController للأمان
/// ✅ StorageService للتخزين المحلي
class PartnerController extends GetxController {
  // ==================== Observable Variables ====================
  final _partners = <PartnerModel>[].obs;
  final _isLoading = false.obs;
  final _searchQuery = ''.obs;
  final _selectedFilter = 'all'.obs;
  final _currentPage = 1.obs;
  final _totalPages = 0.obs;
  final _totalCount = 0.obs;

  // ==================== Getters ====================
  List<PartnerModel> get partners => _partners;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  String get selectedFilter => _selectedFilter.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalCount => _totalCount.value;

  // ==================== User Permissions ====================
  bool get isAdmin => _getUserPermissions();
  int? get currentUserId => _getCurrentUserId();

  bool _getUserPermissions() {
    try {
      final user = StorageService.instance.getUser();
      return user?['is_admin'] ?? false;
    } catch (e) {
      appLogger.warning('Error getting user permissions: $e');
      return false;
    }
  }

  int? _getCurrentUserId() {
    try {
      final user = StorageService.instance.getUser();
      return user?['uid'];
    } catch (e) {
      appLogger.warning('Error getting user ID: $e');
      return null;
    }
  }

  // ==================== Partner Management ====================

  /// جلب الشركاء مع الصلاحيات المتقدمة
  Future<void> fetchPartners({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? filter,
    bool showLoading = true,
  }) async {
    if (showLoading) _isLoading.value = true;

    try {
      appLogger.info('🔍 Fetching partners - Page: $page, Size: $pageSize');

      // تحديد الفلاتر
      List<dynamic> domain = [];

      if (filter == 'individual') {
        domain.add(['is_company', '=', false]);
      } else if (filter == 'company') {
        domain.add(['is_company', '=', true]);
      }

      if (search != null && search.isNotEmpty) {
        domain.add(['name', 'ilike', search]);
      }

      // حقول آمنة لجميع المستخدمين
      final safeFields = [
        "id",
        "name",
        "active",
        "is_company",
        "email",
        "phone",
        "mobile",
        "street",
        "city",
        "zip",
        "country_id",
        "website",
        "display_name",
      ];

      // حقول إضافية للمديرين
      final adminFields = [
        "user_id",
        "create_uid",
        "write_uid",
        "company_id",
        "purchase_order_count",
        "sale_order_count",
        "total_invoiced",
        "credit",
        "customer_rank",
        "supplier_rank",
      ];

      // إضافة الحقل image_1920 في وضع الإنتاج فقط
      if (!kDebugMode) {
        adminFields.add('image_1920');
      }

      // جلب البيانات باستخدام Enhanced DataController
      await EnhancedDataController.getRecordsWithPermissions<PartnerModel>(
        model: 'res.partner',
        safeFields: safeFields,
        adminFields: adminFields,
        domain: domain,
        userId: currentUserId,
        isAdmin: isAdmin,
        limit: pageSize,
        offset: (page - 1) * pageSize,
        fromJson: (json) => PartnerModel.fromJson(json),
        onResponse: (partners) {
          _partners.value = partners;
          _currentPage.value = page;
          _savePartnersToStorage(partners);
          appLogger.info('✅ Partners loaded: ${partners.length} items');
        },
        showGlobalLoading: showLoading,
        cacheKey: 'partners_${page}_${search ?? ''}_${filter ?? ''}',
        cacheTTL: 300, // 5 دقائق
      );

      // جلب العدد الإجمالي
      await _updateTotalCount(domain);
    } catch (e, stackTrace) {
      appLogger.error(
        '❌ Error fetching partners',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  /// تحديث العدد الإجمالي
  Future<void> _updateTotalCount(List<dynamic> domain) async {
    try {
      final count = await EnhancedDataController.getRecordsCountWithPermissions(
        model: 'res.partner',
        domain: domain,
        userId: currentUserId,
        isAdmin: isAdmin,
      );

      _totalCount.value = count;
      _totalPages.value = (count / 20).ceil(); // 20 سجل في الصفحة

      appLogger.info('📊 Total partners: $count, Pages: ${_totalPages.value}');
    } catch (e) {
      appLogger.error('Error updating total count', error: e);
    }
  }

  /// البحث في الشركاء
  Future<void> searchPartners(String query) async {
    _searchQuery.value = query;
    await fetchPartners(search: query, page: 1, showLoading: true);
  }

  /// فلترة الشركاء
  Future<void> filterPartners(String filter) async {
    _selectedFilter.value = filter;
    await fetchPartners(filter: filter, page: 1, showLoading: true);
  }

  /// جلب الصفحة التالية
  Future<void> loadNextPage() async {
    if (currentPage < totalPages) {
      await fetchPartners(
        page: currentPage + 1,
        search: searchQuery,
        filter: selectedFilter,
        showLoading: false,
      );
    }
  }

  /// جلب الصفحة السابقة
  Future<void> loadPreviousPage() async {
    if (currentPage > 1) {
      await fetchPartners(
        page: currentPage - 1,
        search: searchQuery,
        filter: selectedFilter,
        showLoading: false,
      );
    }
  }

  // ==================== Storage Management ====================

  /// حفظ الشركاء في التخزين المحلي
  Future<void> _savePartnersToStorage(List<PartnerModel> partners) async {
    try {
      final partnersJson = partners.map((p) => p.toJson()).toList();
      await StorageService.instance.setString(
        'cached_partners',
        jsonEncode(partnersJson),
      );

      await StorageService.instance.setString(
        'partners_last_update',
        DateTime.now().toIso8601String(),
      );

      appLogger.info('💾 Partners saved to storage: ${partners.length} items');
    } catch (e) {
      appLogger.error('Error saving partners to storage', error: e);
    }
  }

  /// تحميل الشركاء من التخزين المحلي
  Future<void> loadPartnersFromStorage() async {
    try {
      final partnersJson = StorageService.instance.getString('cached_partners');
      if (partnersJson != null) {
        final List<dynamic> jsonList = jsonDecode(partnersJson);
        final partners = jsonList
            .map((json) => PartnerModel.fromJson(json))
            .toList();
        _partners.value = partners;
        appLogger.info(
          '📦 Partners loaded from storage: ${partners.length} items',
        );
      }
    } catch (e) {
      appLogger.error('Error loading partners from storage', error: e);
    }
  }

  /// التحقق من آخر تحديث
  bool shouldRefreshData() {
    final lastUpdate = StorageService.instance.getString(
      'partners_last_update',
    );
    if (lastUpdate == null) return true;

    final lastUpdateTime = DateTime.parse(lastUpdate);
    final now = DateTime.now();
    final difference = now.difference(lastUpdateTime);

    // تحديث كل 30 دقيقة
    return difference.inMinutes > 30;
  }

  // ==================== Partner Operations ====================

  /// جلب شريك واحد
  Future<PartnerModel?> fetchPartner(int id) async {
    try {
      final partner =
          await EnhancedDataController.fetchRecordWithPermissions<PartnerModel>(
            model: 'res.partner',
            id: id,
            userId: currentUserId,
            isAdmin: isAdmin,
            fromJson: (json) => PartnerModel.fromJson(json),
          );

      return partner;
    } catch (e) {
      appLogger.error('Error fetching partner', error: e);
      return null;
    }
  }

  /// إنشاء شريك جديد
  Future<bool> createPartner(Map<String, dynamic> partnerData) async {
    try {
      _isLoading.value = true;

      // استخدام API مباشرة لإنشاء شريك
      final completer = Completer<bool>();

      // هنا يمكن إضافة منطق إنشاء الشريك
      // باستخدام Api.create أو DataController

      completer.complete(true);
      return completer.future;
    } catch (e) {
      appLogger.error('Error creating partner', error: e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// تحديث شريك موجود
  Future<bool> updatePartner(int id, Map<String, dynamic> updateData) async {
    try {
      _isLoading.value = true;

      // منطق تحديث الشريك
      // يمكن استخدام Api.update أو DataController

      // إعادة تحميل البيانات بعد التحديث
      await fetchPartners(page: currentPage);

      return true;
    } catch (e) {
      appLogger.error('Error updating partner', error: e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// حذف شريك
  Future<bool> deletePartner(int id) async {
    try {
      _isLoading.value = true;

      // منطق حذف الشريك
      // يمكن استخدام Api.delete أو DataController

      // إعادة تحميل البيانات بعد الحذف
      await fetchPartners(page: currentPage);

      return true;
    } catch (e) {
      appLogger.error('Error deleting partner', error: e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    appLogger.info('🎮 PartnerController initialized');

    // تحميل البيانات من التخزين المحلي
    loadPartnersFromStorage();

    // جلب البيانات الجديدة إذا لزم الأمر
    if (shouldRefreshData()) {
      fetchPartners();
    }
  }

  @override
  void onClose() {
    appLogger.info('🎮 PartnerController disposed');
    super.onClose();
  }
}
