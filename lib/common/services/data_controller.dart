import 'dart:async';
import '../api/api.dart';
import '../../utils/app_logger.dart';

/// 🎯 DataController - عمليات جلب البيانات العامة
///
/// يوفر أساليب موحدة لجلب البيانات من API
/// مع دعم النماذج العامة والتحويلات التلقائية
class DataController {
  // ==================== Generic Data Fetching ====================

  /// جلب السجلات مع التحكم العام
  ///
  /// [model] - اسم النموذج (مثل "product.product")
  /// [fields] - الحقول المطلوبة (اختياري)
  /// [domain] - نطاق البحث (اختياري)
  /// [limit] - عدد السجلات في الصفحة
  /// [offset] - الإزاحة
  /// [fromJson] - دالة تحويل JSON إلى نموذج
  /// [onResponse] - دالة معالجة الاستجابة
  /// [showGlobalLoading] - إظهار مؤشر التحميل العام
  static Future<void> getRecordsController<T>({
    required String model,
    List<String>? fields,
    List<dynamic> domain = const [],
    int limit = 50,
    int offset = 0,
    T Function(Map<String, dynamic>)? fromJson,
    OnResponse? onResponse,
    bool? showGlobalLoading,
  }) async {
    try {
      appLogger.info('🔍 Fetching records for model: $model');

      // الحصول على الحقول الصحيحة
      List<String> dynamicFields = await getValidFields(model);
      List<String> validFields = [...?fields, ...dynamicFields];

      // جلب السجلات
      final fetchedRecords = await searchRead<T>(
        model: model,
        domain: domain,
        fields: validFields,
        fromJson: fromJson,
        limit: limit,
        offset: offset,
        showGlobalLoading: showGlobalLoading,
      );

      // معالجة الاستجابة
      if (onResponse != null) {
        onResponse(fetchedRecords);
      }

      appLogger.info('✅ Successfully fetched ${fetchedRecords.length} records');
    } catch (e, stackTrace) {
      appLogger.error(
        '❌ Error fetching records',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// جلب السجلات مع البحث والقراءة
  ///
  /// [model] - اسم النموذج
  /// [domain] - نطاق البحث
  /// [fields] - الحقول المطلوبة
  /// [fromJson] - دالة تحويل JSON
  /// [limit] - عدد السجلات في الصفحة
  /// [offset] - الإزاحة
  /// [showGlobalLoading] - إظهار مؤشر التحميل
  static Future<List<T>> searchRead<T>({
    required String model,
    required List<dynamic> domain,
    required List<String> fields,
    T Function(Map<String, dynamic>)? fromJson,
    int limit = 50,
    int offset = 0,
    bool? showGlobalLoading,
  }) async {
    int currentOffset = offset;
    bool hasMore = true;
    List<T> allRecords = [];

    appLogger.info('📊 Starting searchRead for $model with limit: $limit');

    while (hasMore) {
      final Completer<Map<int, List<T>>> completer = Completer();

      try {
        Api.callKW(
          method: 'search_read',
          model: model,
          args: [domain, fields],
          kwargs: {"limit": limit, "offset": currentOffset},
          onResponse: (response) {
            if (response is List) {
              List<T> fetchedRecords = [];

              for (var element in response) {
                if (element is Map<String, dynamic>) {
                  if (fromJson != null) {
                    try {
                      fetchedRecords.add(fromJson(element));
                    } catch (e) {
                      appLogger.warning('Failed to convert record: $e');
                    }
                  } else {
                    // إذا لم تكن هناك دالة تحويل، استخدم العنصر كما هو
                    fetchedRecords.add(element as T);
                  }
                }
              }

              completer.complete({fetchedRecords.length: fetchedRecords});
            } else {
              completer.completeError('Invalid response format');
            }
          },
          onError: (error, data) {
            appLogger.error('API Error in searchRead', error: error);
            completer.completeError(error);
          },
          showGlobalLoading: showGlobalLoading,
        );

        final response = await completer.future;

        if (response.isNotEmpty) {
          int size = response.keys.first;
          List<T> fetchedRecords = response[size]!;

          allRecords.addAll(fetchedRecords);
          currentOffset += limit;

          // التحقق من وجود المزيد من السجلات
          hasMore = fetchedRecords.length == limit;

          appLogger.info(
            '📄 Fetched ${fetchedRecords.length} records, total: ${allRecords.length}',
          );
        } else {
          hasMore = false;
        }
      } catch (e, stackTrace) {
        appLogger.error(
          'Error in searchRead iteration',
          error: e,
          stackTrace: stackTrace,
        );
        hasMore = false;
      }
    }

    appLogger.info(
      '✅ searchRead completed. Total records: ${allRecords.length}',
    );
    return allRecords;
  }

  /// الحصول على الحقول الصحيحة للنموذج
  ///
  /// [model] - اسم النموذج
  /// Returns: قائمة بالحقول المطلوبة
  static Future<List<String>> getValidFields(String model) async {
    final Completer<List<String>> completer = Completer();

    try {
      appLogger.info('🔍 Getting valid fields for model: $model');

      Api.callKW(
        method: 'fields_get',
        model: model,
        args: [],
        kwargs: {
          "attributes": ["string", "type", "required"],
        },
        onResponse: (response) {
          if (response is Map<String, dynamic>) {
            List<String> requiredFields = response.entries
                .where((entry) => entry.value['required'] == true)
                .map((entry) => entry.key)
                .toList();

            appLogger.info('📋 Found ${requiredFields.length} required fields');
            completer.complete(requiredFields);
          } else {
            completer.completeError('Invalid fields response format');
          }
        },
        onError: (error, data) {
          appLogger.error('Error getting fields', error: error);
          completer.completeError(error);
        },
      );

      return completer.future;
    } catch (e, stackTrace) {
      appLogger.error(
        'Error in getValidFields',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  // ==================== Specialized Data Fetching ====================

  /// جلب سجلات مع تحويل تلقائي
  ///
  /// [model] - اسم النموذج
  /// [domain] - نطاق البحث
  /// [fields] - الحقول المطلوبة
  /// [limit] - عدد السجلات
  /// [fromJson] - دالة التحويل
  static Future<List<T>> fetchRecords<T>({
    required String model,
    List<dynamic> domain = const [],
    List<String>? fields,
    int limit = 50,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // الحصول على الحقول الصحيحة
      List<String> validFields = fields ?? await getValidFields(model);

      return await searchRead<T>(
        model: model,
        domain: domain,
        fields: validFields,
        fromJson: fromJson,
        limit: limit,
      );
    } catch (e, stackTrace) {
      appLogger.error(
        'Error in fetchRecords',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// جلب سجل واحد بالمعرف
  ///
  /// [model] - اسم النموذج
  /// [id] - معرف السجل
  /// [fields] - الحقول المطلوبة
  /// [fromJson] - دالة التحويل
  static Future<T?> fetchRecord<T>({
    required String model,
    required int id,
    List<String>? fields,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final records = await fetchRecords<T>(
        model: model,
        domain: [
          ['id', '=', id],
        ],
        fields: fields,
        fromJson: fromJson,
        limit: 1,
      );

      return records.isNotEmpty ? records.first : null;
    } catch (e, stackTrace) {
      appLogger.error('Error in fetchRecord', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// جلب عدد السجلات
  ///
  /// [model] - اسم النموذج
  /// [domain] - نطاق البحث
  static Future<int> getRecordsCount({
    required String model,
    List<dynamic> domain = const [],
  }) async {
    try {
      final Completer<int> completer = Completer();

      Api.callKW(
        method: 'search_count',
        model: model,
        args: [domain],
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
        'Error in getRecordsCount',
        error: e,
        stackTrace: stackTrace,
      );
      return 0;
    }
  }

  // ==================== Utility Methods ====================

  /// جلب جميع السجلات (بدون حدود)
  ///
  /// [model] - اسم النموذج
  /// [domain] - نطاق البحث
  /// [fields] - الحقول المطلوبة
  /// [fromJson] - دالة التحويل
  static Future<List<T>> fetchAllRecords<T>({
    required String model,
    List<dynamic> domain = const [],
    List<String>? fields,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // الحصول على العدد الإجمالي
      final totalCount = await getRecordsCount(model: model, domain: domain);

      if (totalCount == 0) {
        return [];
      }

      appLogger.info('📊 Fetching all $totalCount records for $model');

      // جلب جميع السجلات
      return await searchRead<T>(
        model: model,
        domain: domain,
        fields: fields ?? await getValidFields(model),
        fromJson: fromJson,
        limit: totalCount,
      );
    } catch (e, stackTrace) {
      appLogger.error(
        'Error in fetchAllRecords',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// جلب السجلات مع التصفح
  ///
  /// [model] - اسم النموذج
  /// [domain] - نطاق البحث
  /// [fields] - الحقول المطلوبة
  /// [page] - رقم الصفحة (يبدأ من 1)
  /// [pageSize] - حجم الصفحة
  /// [fromJson] - دالة التحويل
  static Future<Map<String, dynamic>> fetchRecordsPaginated<T>({
    required String model,
    List<dynamic> domain = const [],
    List<String>? fields,
    int page = 1,
    int pageSize = 20,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final offset = (page - 1) * pageSize;

      final records = await searchRead<T>(
        model: model,
        domain: domain,
        fields: fields ?? await getValidFields(model),
        fromJson: fromJson,
        limit: pageSize,
        offset: offset,
      );

      final totalCount = await getRecordsCount(model: model, domain: domain);
      final totalPages = (totalCount / pageSize).ceil();

      return {
        'records': records,
        'totalCount': totalCount,
        'currentPage': page,
        'pageSize': pageSize,
        'totalPages': totalPages,
        'hasNext': page < totalPages,
        'hasPrevious': page > 1,
      };
    } catch (e, stackTrace) {
      appLogger.error(
        'Error in fetchRecordsPaginated',
        error: e,
        stackTrace: stackTrace,
      );
      return {
        'records': <T>[],
        'totalCount': 0,
        'currentPage': page,
        'pageSize': pageSize,
        'totalPages': 0,
        'hasNext': false,
        'hasPrevious': false,
      };
    }
  }
}
