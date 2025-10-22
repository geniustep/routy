import 'dart:async';
import 'dart:convert';
import '../api/api.dart';
import '../../utils/app_logger.dart';
import '../../services/storage_service.dart';

/// 🎯 Enhanced DataController - دمج المزايا المتقدمة
///
/// يجمع بين:
/// ✅ DataController: المرونة والسهولة
/// ✅ PartnerModule: الأمان والصلاحيات المتقدمة
///
/// المزايا الجديدة:
/// ✅ إدارة الصلاحيات الذكية
/// ✅ Fallback Strategy متقدمة
/// ✅ معالجة أخطاء متخصصة
/// ✅ تكامل مع التخزين المحلي
class EnhancedDataController {
  // ==================== Permission Management ====================

  /// الحصول على الحقول حسب الصلاحيات
  static List<String> _getFieldsForUser({
    required String model,
    List<String>? safeFields,
    List<String>? adminFields,
    bool isAdmin = false,
  }) {
    // حقول آمنة افتراضية
    final defaultSafeFields = [
      "id",
      "name",
      "active",
      "create_date",
      "write_date",
    ];

    // حقول إدارية افتراضية
    final defaultAdminFields = [
      "user_id",
      "create_uid",
      "write_uid",
      "company_id",
    ];

    final safe = safeFields ?? defaultSafeFields;
    final admin = adminFields ?? defaultAdminFields;

    return isAdmin ? [...safe, ...admin] : safe;
  }

  /// تحديد النطاق حسب الصلاحيات
  static List<dynamic> _getDomainForUser({
    required String model,
    int? userId,
    bool isAdmin = false,
    List<dynamic>? customDomain,
  }) {
    if (customDomain != null) return customDomain;

    if (isAdmin) {
      // للمديرين: جلب جميع السجلات
      return [
        ['name', '!=', false],
      ];
    } else {
      // للمستخدمين العاديين: السجلات المرتبطة بهم فقط
      return [
        if (userId != null) ['user_id', '=', userId],
        ['name', '!=', false],
      ];
    }
  }

  // ==================== Enhanced Data Fetching ====================

  /// جلب السجلات مع إدارة الصلاحيات المتقدمة
  static Future<void> getRecordsWithPermissions<T>({
    required String model,
    List<String>? safeFields,
    List<String>? adminFields,
    List<dynamic>? domain,
    int? userId,
    bool isAdmin = false,
    int limit = 50,
    int offset = 0,
    T Function(Map<String, dynamic>)? fromJson,
    OnResponse? onResponse,
    bool? showGlobalLoading,
    bool enableFallback = true,
    String? cacheKey,
    int? cacheTTL,
  }) async {
    try {
      appLogger.info(
        '🔍 Fetching $model with permissions for ${isAdmin ? "Admin" : "Regular"} user',
      );

      // تحديد الحقول حسب الصلاحيات
      final fields = _getFieldsForUser(
        model: model,
        safeFields: safeFields,
        adminFields: adminFields,
        isAdmin: isAdmin,
      );

      // تحديد النطاق حسب الصلاحيات
      final searchDomain = _getDomainForUser(
        model: model,
        userId: userId,
        isAdmin: isAdmin,
        customDomain: domain,
      );

      appLogger.info('📋 Using ${fields.length} fields, domain: $searchDomain');

      // محاولة جلب البيانات
      await _fetchWithFallback<T>(
        model: model,
        fields: fields,
        safeFields:
            safeFields ?? _getFieldsForUser(model: model, isAdmin: false),
        domain: searchDomain,
        limit: limit,
        offset: offset,
        fromJson: fromJson,
        onResponse: onResponse,
        showGlobalLoading: showGlobalLoading,
        enableFallback: enableFallback,
        cacheKey: cacheKey,
        cacheTTL: cacheTTL,
      );
    } catch (e, stackTrace) {
      appLogger.error(
        '❌ Error in getRecordsWithPermissions',
        error: e,
        stackTrace: stackTrace,
      );
      _handleApiError(e);
    }
  }

  /// جلب البيانات مع Fallback Strategy
  static Future<void> _fetchWithFallback<T>({
    required String model,
    required List<String> fields,
    required List<String> safeFields,
    required List<dynamic> domain,
    required int limit,
    required int offset,
    T Function(Map<String, dynamic>)? fromJson,
    OnResponse? onResponse,
    bool? showGlobalLoading,
    bool enableFallback = true,
    String? cacheKey,
    int? cacheTTL,
  }) async {
    try {
      // محاولة أولى مع الحقول الكاملة
      await _fetchRecords<T>(
        model: model,
        fields: fields,
        domain: domain,
        limit: limit,
        offset: offset,
        fromJson: fromJson,
        onResponse: onResponse,
        showGlobalLoading: showGlobalLoading,
        cacheKey: cacheKey,
        cacheTTL: cacheTTL,
      );
    } catch (e) {
      appLogger.warning('⚠️ Primary fetch failed: $e');

      // Fallback: إعادة المحاولة مع الحقول الآمنة فقط
      if (enableFallback && fields.length > safeFields.length) {
        appLogger.info('🔄 Retrying with safe fields only...');

        try {
          await _fetchRecords<T>(
            model: model,
            fields: safeFields,
            domain: domain,
            limit: limit,
            offset: offset,
            fromJson: fromJson,
            onResponse: onResponse,
            showGlobalLoading: showGlobalLoading,
            cacheKey: cacheKey,
            cacheTTL: cacheTTL,
          );

          appLogger.info('✅ Fallback successful with safe fields');
        } catch (fallbackError) {
          appLogger.error('❌ Fallback also failed: $fallbackError');
          _handleApiError(fallbackError);
        }
      } else {
        _handleApiError(e);
      }
    }
  }

  /// جلب البيانات الفعلي
  static Future<void> _fetchRecords<T>({
    required String model,
    required List<String> fields,
    required List<dynamic> domain,
    required int limit,
    required int offset,
    T Function(Map<String, dynamic>)? fromJson,
    OnResponse? onResponse,
    bool? showGlobalLoading,
    String? cacheKey,
    int? cacheTTL,
  }) async {
    // التحقق من التخزين المؤقت
    if (cacheKey != null) {
      final cached = await _getCachedData<T>(cacheKey, fromJson);
      if (cached != null) {
        appLogger.info('📦 Cache hit: $cacheKey');
        onResponse?.call(cached);
        return;
      }
    }

    // جلب البيانات من API
    final completer = Completer<List<T>>();

    Api.callKW(
      method: 'search_read',
      model: model,
      args: [domain, fields],
      kwargs: {"limit": limit, "offset": offset},
      onResponse: (response) {
        if (response is List) {
          List<T> records = [];

          for (var element in response) {
            if (element is Map<String, dynamic>) {
              if (fromJson != null) {
                try {
                  records.add(fromJson(element));
                } catch (e) {
                  appLogger.warning('Failed to convert record: $e');
                }
              } else {
                records.add(element as T);
              }
            }
          }

          completer.complete(records);
        } else {
          completer.completeError('Invalid response format');
        }
      },
      onError: (error, data) {
        appLogger.error('API Error in _fetchRecords', error: error);
        completer.completeError(error);
      },
      showGlobalLoading: showGlobalLoading,
    );

    final records = await completer.future;

    // حفظ في التخزين المؤقت
    if (cacheKey != null && records.isNotEmpty) {
      await _cacheData(cacheKey, records, cacheTTL);
    }

    // استدعاء callback
    onResponse?.call(records);

    appLogger.info('✅ Successfully fetched ${records.length} records');
  }

  // ==================== Cache Management ====================

  /// الحصول على البيانات من التخزين المؤقت
  static Future<List<T>?> _getCachedData<T>(
    String key,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    try {
      final cached = StorageService.instance.getString(key);
      if (cached != null) {
        final List<dynamic> jsonList = jsonDecode(cached);
        if (fromJson != null) {
          return jsonList.map((json) => fromJson(json)).toList();
        } else {
          return jsonList.cast<T>();
        }
      }
    } catch (e) {
      appLogger.warning('Cache error: $e');
    }
    return null;
  }

  /// حفظ البيانات في التخزين المؤقت
  static Future<void> _cacheData<T>(String key, List<T> data, int? ttl) async {
    try {
      final jsonData = data.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else {
          // تحويل إلى JSON إذا كان نموذج
          return (item as dynamic).toJson();
        }
      }).toList();

      await StorageService.instance.setString(key, jsonEncode(jsonData));

      if (ttl != null) {
        await StorageService.instance.setString(
          '${key}_ttl',
          DateTime.now().add(Duration(seconds: ttl)).toIso8601String(),
        );
      }

      appLogger.info('💾 Data cached: $key');
    } catch (e) {
      appLogger.error('Failed to cache data', error: e);
    }
  }

  // ==================== Error Handling ====================

  /// معالجة أخطاء API المتقدمة
  static void _handleApiError(dynamic error) {
    String errorMessage = 'Unknown error';

    if (error is String) {
      errorMessage = error;

      // تحليل نوع الخطأ
      if (error.toLowerCase().contains('access') ||
          error.toLowerCase().contains('permission') ||
          error.toLowerCase().contains('droits')) {
        appLogger.error('🔒 Access permission error detected');
        errorMessage = 'خطأ في الصلاحيات - لا يمكن الوصول إلى البيانات';
      } else if (error.toLowerCase().contains('network') ||
          error.toLowerCase().contains('connection')) {
        appLogger.error('🌐 Network error detected');
        errorMessage = 'خطأ في الشبكة - تحقق من الاتصال';
      } else if (error.toLowerCase().contains('timeout')) {
        appLogger.error('⏰ Timeout error detected');
        errorMessage = 'انتهت مهلة الاتصال - حاول مرة أخرى';
      }
    }

    appLogger.error('❌ API Error: $errorMessage');
    // يمكن إضافة معالجة إضافية هنا (مثل إظهار SnackBar)
  }

  // ==================== Utility Methods ====================

  /// جلب سجل واحد مع الصلاحيات
  static Future<T?> fetchRecordWithPermissions<T>({
    required String model,
    required int id,
    List<String>? safeFields,
    List<String>? adminFields,
    int? userId,
    bool isAdmin = false,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final completer = Completer<T?>();

    await getRecordsWithPermissions<T>(
      model: model,
      safeFields: safeFields,
      adminFields: adminFields,
      domain: [
        ['id', '=', id],
      ],
      userId: userId,
      isAdmin: isAdmin,
      limit: 1,
      fromJson: fromJson,
      onResponse: (records) {
        completer.complete(records.isNotEmpty ? records.first : null);
      },
    );

    return completer.future;
  }

  /// جلب عدد السجلات مع الصلاحيات
  static Future<int> getRecordsCountWithPermissions({
    required String model,
    List<dynamic>? domain,
    int? userId,
    bool isAdmin = false,
  }) async {
    try {
      final searchDomain = _getDomainForUser(
        model: model,
        userId: userId,
        isAdmin: isAdmin,
        customDomain: domain,
      );

      final completer = Completer<int>();

      Api.callKW(
        method: 'search_count',
        model: model,
        args: [searchDomain],
        onResponse: (response) {
          if (response is int) {
            completer.complete(response);
          } else {
            completer.completeError('Invalid count response');
          }
        },
        onError: (error, data) {
          appLogger.error('Error getting count', error: error);
          completer.completeError(error);
        },
      );

      return completer.future;
    } catch (e, stackTrace) {
      appLogger.error(
        'Error in getRecordsCountWithPermissions',
        error: e,
        stackTrace: stackTrace,
      );
      return 0;
    }
  }
}
