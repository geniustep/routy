import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:uuid/uuid.dart';
import '../api/dio_factory.dart';
import '../api/endpoints.dart';
import '../models/base_response.dart';
import '../../services/storage_service.dart';
import '../../utils/app_logger.dart';
import '../../controllers/user_controller.dart';
import '../models/user_model.dart';

/// 🚀 ApiService المحسّن النهائي - يعتمد على DioFactory
///
/// يجمع أفضل ما في:
/// ✅ ApiService: Async/Await, Cache, Queue, Type Safety
/// ✅ api.dart: Session Management, Cookie Handling, Error Detection
/// ✅ DioFactory: CORS, Interceptors, Device Info
///
/// المزايا الكاملة:
/// ✅ Future-based (بدلاً من Callbacks)
/// ✅ Cache ذكي مع TTL
/// ✅ Offline Queue تلقائي
/// ✅ Retry Logic (3 محاولات)
/// ✅ Session Management كامل
/// ✅ Cookie Handling
/// ✅ HTML Response Detection
/// ✅ Socket Error Detection
/// ✅ Observable State (GetX)
/// ✅ Type-Safe مع Generics
/// ✅ Error Handling شامل
/// ✅ يعتمد على DioFactory
class ApiService extends getx.GetxController {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();

  ApiService._();

  // ==================== Observable States ====================
  final _isLoading = false.obs;
  final _lastError = getx.Rx<String?>(null);
  final _retryCount = 0.obs;

  bool get isLoading => _isLoading.value;
  String? get lastError => _lastError.value;
  int get retryCount => _retryCount.value;

  // ==================== Configuration ====================
  static const int maxRetryCount = 3;
  static const Duration timeoutDuration = Duration(seconds: 30);
  static const int defaultLimit = 20;

  // Session cookies
  String? _sessionId;
  Map<String, String> _cookies = {};

  // ==================== Private Methods ====================

  void _setLoading(bool loading) => _isLoading.value = loading;
  void _setError(String? error) => _lastError.value = error;
  void clearError() => _lastError.value = null;
  void _resetRetryCount() => _retryCount.value = 0;
  void _incrementRetryCount() => _retryCount.value++;

  /// إنشاء Payload لطلبات Odoo
  Map<String, dynamic> _createPayload(Map<String, dynamic> params) {
    return {
      "id": const Uuid().v1(),
      "jsonrpc": "2.0",
      "method": "call",
      "params": params,
    };
  }

  /// الحصول على Context لطلبات Odoo
  Map<String, dynamic> _getContext([Map<String, dynamic>? addition]) {
    final user = StorageService.instance.getUser();
    final context = {
      "lang": StorageService.instance.getLanguage(),
      "tz": "Africa/Casablanca",
      "uid": user?['uid'],
      "db":
          user?['db'] ??
          StorageService.instance.getString('selected_database') ??
          'done2026',
    };

    if (addition != null && addition.isNotEmpty) {
      context.addAll(addition);
    }

    return context;
  }

  /// تحديث Cookies من Response
  void _updateCookies(Headers headers) {
    try {
      final cookies = headers['set-cookie'];
      if (cookies != null) {
        for (final cookie in cookies) {
          final parts = cookie.split(';')[0].split('=');
          if (parts.length >= 2) {
            final key = parts[0].trim();
            final value = parts[1].trim();
            _cookies[key] = value;

            if (key == 'session_id') {
              _sessionId = value;
              appLogger.info('🍪 Session ID updated: $value');
            }
          }
        }
      }
    } catch (e) {
      appLogger.warning('Failed to update cookies: $e');
    }
  }

  /// معالجة انتهاء Session
  Future<void> _handleSessionExpired() async {
    appLogger.warning('⚠️ Session expired - clearing user data');

    _sessionId = null;
    _cookies.clear();

    await StorageService.instance.clearUserData();
    await StorageService.instance.clearSession();

    // التنقل لصفحة تسجيل الدخول
    getx.Get.offAllNamed('/auth/login');
  }

  /// كشف HTML Response
  bool _isHtmlResponse(dynamic data) {
    if (data is String) {
      return data.contains('<!doctype html>') ||
          data.contains('<html') ||
          data.contains('<!DOCTYPE html>');
    }
    return false;
  }

  /// معالجة DioException المحسّنة
  String _handleDioException(DioException e) {
    // 1. Connection Errors
    if (e.type == DioExceptionType.connectionError) {
      if (e.error is SocketException) {
        final socketException = e.error as SocketException;

        // No internet (Error code 7)
        if (socketException.osError?.errorCode == 7) {
          return 'لا يوجد اتصال بالإنترنت';
        }

        // Failed host lookup
        if (e.message?.contains('Failed host lookup') == true) {
          return 'فشل الاتصال بالخادم';
        }

        return 'فشل الاتصال';
      }
      return 'فشل الاتصال بالخادم';
    }

    // 2. Timeout Errors
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'انتهت مهلة الاتصال';
    }
    if (e.type == DioExceptionType.sendTimeout) {
      return 'انتهت مهلة إرسال البيانات';
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return 'انتهت مهلة استقبال البيانات';
    }

    // 3. Bad Response
    if (e.type == DioExceptionType.badResponse) {
      final response = e.response;
      if (response != null) {
        final data = response.data;

        // HTML Response = Session Expired
        if (_isHtmlResponse(data)) {
          _handleSessionExpired();
          return 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى';
        }

        // JSON Error
        if (data is Map<String, dynamic>) {
          // Session expired (code 100)
          if (data.containsKey('error') &&
              data['error'] is Map &&
              data['error']['code'] == 100) {
            _handleSessionExpired();
            return 'انتهت صلاحية الجلسة';
          }

          // Other errors
          if (data.containsKey('error')) {
            final error = data['error'];
            if (error is Map) {
              return error['message'] ??
                  error['data']?['message'] ??
                  'خطأ من الخادم';
            }
          }
        }

        return 'رد خاطئ من الخادم (${response.statusCode})';
      }
      return 'رد خاطئ من الخادم';
    }

    // 4. Cancel
    if (e.type == DioExceptionType.cancel) {
      return 'تم إلغاء الطلب';
    }

    // 5. Unknown
    if (e.type == DioExceptionType.unknown) {
      if (e.error is SocketException) {
        return 'لا يوجد اتصال بالإنترنت';
      }
      return 'خطأ غير معروف';
    }

    return 'خطأ غير معروف: ${e.message}';
  }

  /// طلب عام مع معالجة شاملة - يعتمد على DioFactory
  Future<BaseResponse<T>> _request<T>({
    required String endpoint,
    required Map<String, dynamic> params,
    T Function(dynamic)? fromJson,
    bool showLoading = true,
    bool retryOnError = true,
    Duration? timeout,
    bool useCache = false,
    String? cacheKey,
    int? cacheTTL,
  }) async {
    if (showLoading) _setLoading(true);

    try {
      // 1. التحقق من Cache
      if (useCache && cacheKey != null) {
        final cached = await _getCachedResponse<T>(cacheKey, fromJson);
        if (cached != null) {
          if (showLoading) _setLoading(false);
          appLogger.info('📦 Cache hit: $cacheKey');
          return cached;
        }
      }

      // 2. إنشاء الطلب
      final payload = _createPayload(params);

      // 3. إضافة Cookies للـ Headers
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (_cookies.isNotEmpty) {
        headers['Cookie'] = _cookies.entries
            .map((e) => '${e.key}=${e.value}')
            .join('; ');
      }

      appLogger.apiRequest('POST', endpoint);

      // 4. إرسال الطلب ✅ استخدام DioFactory.dio
      if (DioFactory.dio == null) {
        throw Exception('DioFactory not initialized');
      }

      final response = await DioFactory.dio!.post(
        endpoint,
        data: payload,
        options: Options(
          headers: headers,
          sendTimeout: timeout ?? timeoutDuration,
          receiveTimeout: timeout ?? timeoutDuration,
        ),
      );

      _resetRetryCount();
      _setError(null);

      if (showLoading) _setLoading(false);

      // 5. تحديث Cookies
      _updateCookies(response.headers);

      // 6. معالجة الرد
      final result = _handleResponse<T>(response, fromJson);

      // 7. حفظ في Cache
      if (result.success && useCache && cacheKey != null) {
        await _cacheResponse(cacheKey, result, cacheTTL);
      }

      appLogger.apiResponse(endpoint, statusCode: response.statusCode);
      return result;
    } on DioException catch (e) {
      if (showLoading) _setLoading(false);

      final errorMessage = _handleDioException(e);
      _setError(errorMessage);

      appLogger.error('API Error', error: e, stackTrace: e.stackTrace);

      // Retry Logic
      if (retryOnError && _retryCount.value < maxRetryCount) {
        _incrementRetryCount();
        await Future.delayed(Duration(seconds: _retryCount.value * 2));

        appLogger.warning('Retry attempt ${_retryCount.value}/$maxRetryCount');

        return _request<T>(
          endpoint: endpoint,
          params: params,
          fromJson: fromJson,
          showLoading: showLoading,
          retryOnError: retryOnError,
          timeout: timeout,
          useCache: useCache,
          cacheKey: cacheKey,
          cacheTTL: cacheTTL,
        );
      }

      // حفظ في Offline Queue عند فشل نهائي
      if (_shouldQueueRequest(endpoint)) {
        await _addToOfflineQueue(endpoint, params);
      }

      return BaseResponse.error(
        error: errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      if (showLoading) _setLoading(false);
      _setError(e.toString());

      appLogger.error('Unexpected error', error: e, stackTrace: stackTrace);

      return BaseResponse.error(error: e.toString());
    }
  }

  /// معالجة رد Odoo
  BaseResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    if (response.statusCode != 200) {
      return BaseResponse.error(
        error: 'HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final responseData = response.data;

    if (responseData == null) {
      return BaseResponse.error(error: 'Empty response');
    }

    // تحقق من HTML Response
    if (_isHtmlResponse(responseData)) {
      _handleSessionExpired();
      return BaseResponse.error(error: 'انتهت صلاحية الجلسة', statusCode: 401);
    }

    // تحقق من success = 0
    if (responseData is Map && responseData['success'] == 0) {
      String errorMessage = 'Server error';
      if (responseData['error'] is List && responseData['error'].isNotEmpty) {
        errorMessage = responseData['error'][0].toString();
      }
      return BaseResponse.error(error: errorMessage);
    }

    // تحقق من وجود error في الرد
    if (responseData is Map && responseData.containsKey('error')) {
      final error = responseData['error'];

      // Session expired (code 100)
      if (error is Map && error['code'] == 100) {
        _handleSessionExpired();
        return BaseResponse.error(
          error: 'انتهت صلاحية الجلسة',
          statusCode: 401,
        );
      }

      String errorMessage = 'Unknown error';
      if (error is Map<String, dynamic>) {
        errorMessage =
            error['message'] ??
            error['data']?['message'] ??
            error['data']?['name'] ??
            'Unknown error';
      } else if (error is String) {
        errorMessage = error;
      }

      return BaseResponse.error(
        error: errorMessage,
        statusCode: response.statusCode,
      );
    }

    // استخراج result
    if (responseData is Map && responseData.containsKey('result')) {
      final result = responseData['result'];

      if (fromJson != null) {
        try {
          final data = fromJson(result);
          return BaseResponse.success(data: data);
        } catch (e) {
          appLogger.error('Error parsing response', error: e);
          return BaseResponse.error(error: 'Failed to parse response: $e');
        }
      }

      return BaseResponse.success(data: result as T);
    }

    return BaseResponse.error(error: 'Invalid response format');
  }

  /// التحقق من Cache
  Future<BaseResponse<T>?> _getCachedResponse<T>(
    String key,
    T Function(dynamic)? fromJson,
  ) async {
    try {
      final cached = StorageService.instance.getCache(key);
      if (cached != null && fromJson != null) {
        final data = fromJson(cached);
        return BaseResponse.success(data: data);
      }
    } catch (e) {
      appLogger.warning('Cache error: $e');
    }
    return null;
  }

  /// حفظ في Cache
  Future<void> _cacheResponse<T>(
    String key,
    BaseResponse<T> response,
    int? ttl,
  ) async {
    try {
      if (response.success && response.data != null) {
        await StorageService.instance.setCache(key, response.data, ttl);
      }
    } catch (e) {
      appLogger.warning('Failed to cache: $e');
    }
  }

  /// هل يجب إضافة الطلب للـ Queue؟
  bool _shouldQueueRequest(String endpoint) {
    return !endpoint.contains('read') &&
        !endpoint.contains('search') &&
        !endpoint.contains('get');
  }

  /// إضافة للـ Offline Queue
  Future<void> _addToOfflineQueue(
    String endpoint,
    Map<String, dynamic> params,
  ) async {
    try {
      await StorageService.instance.addToQueue({
        'endpoint': endpoint,
        'params': params,
        'timestamp': DateTime.now().toIso8601String(),
        'retries': 0,
      });
      appLogger.info('✅ Added to offline queue');
    } catch (e) {
      appLogger.error('Failed to queue request', error: e);
    }
  }

  // ==================== Authentication ====================

  /// تسجيل الدخول
  Future<BaseResponse<Map<String, dynamic>>> authenticate({
    required String username,
    required String password,
    required String database,
  }) async {
    final params = {"db": database, "login": username, "password": password};

    final response = await _request<Map<String, dynamic>>(
      endpoint: ApiEndpoints.authenticate,
      params: params,
      fromJson: (data) => Map<String, dynamic>.from(data),
      retryOnError: false,
    );

    if (response.success) {
      // حفظ بيانات المستخدم
      await StorageService.instance.saveUser(response.data!);
      await StorageService.instance.saveIsLoggedIn(true);

      // حفظ Session
      await StorageService.instance.saveSession({
        'user': response.data,
        'session_id': _sessionId,
        'cookies': _cookies,
      });

      // تحديث UserController
      try {
        final userController = getx.Get.find<UserController>();
        final userModel = UserModel.fromJson(response.data!);
        await userController.setUser(userModel);
      } catch (e) {
        appLogger.warning(
          'UserController not found, user data saved to storage only',
        );
      }
    }

    return response;
  }

  /// تسجيل الخروج
  Future<BaseResponse<void>> logout() async {
    final result = await _request<void>(
      endpoint: ApiEndpoints.destroy,
      params: {},
    );

    if (result.success) {
      await _handleSessionExpired();
    }

    return result;
  }

  /// معلومات الجلسة
  Future<BaseResponse<Map<String, dynamic>>> getSessionInfo() async {
    return _request<Map<String, dynamic>>(
      endpoint: ApiEndpoints.getSessionInfo,
      params: {},
      fromJson: (data) => Map<String, dynamic>.from(data),
      useCache: true,
      cacheKey: 'session_info',
      cacheTTL: 300,
    );
  }

  // ==================== CRUD Operations ====================

  /// 📖 READ
  Future<BaseResponse<List<T>>> read<T>({
    required String model,
    required List<int> ids,
    List<String>? fields,
    Map<String, dynamic>? context,
    T Function(Map<String, dynamic>)? fromJson,
    bool showLoading = true,
    bool useCache = false,
  }) async {
    final params = {
      "model": model,
      "method": "read",
      "args": [ids],
      "kwargs": {
        if (fields != null) "fields": fields,
        "context": _getContext(context),
      },
    };

    return _request<List<T>>(
      endpoint: ApiEndpoints.callKw,
      params: params,
      fromJson: (data) {
        if (data is! List) return <T>[];
        if (fromJson == null) return data.cast<T>();
        return data
            .map((item) => fromJson(Map<String, dynamic>.from(item)))
            .toList();
      },
      showLoading: showLoading,
      useCache: useCache,
      cacheKey: useCache ? 'read_${model}_${ids.join('_')}' : null,
    );
  }

  /// 🔍 SEARCH
  Future<BaseResponse<List<int>>> search({
    required String model,
    List<dynamic>? domain,
    int? limit,
    int? offset,
    String? order,
    Map<String, dynamic>? context,
    bool showLoading = true,
  }) async {
    final params = {
      "model": model,
      "method": "search",
      "args": [domain ?? []],
      "kwargs": {
        if (limit != null) "limit": limit,
        if (offset != null) "offset": offset,
        if (order != null) "order": order,
        "context": _getContext(context),
      },
    };

    return _request<List<int>>(
      endpoint: ApiEndpoints.callKw,
      params: params,
      fromJson: (data) => (data as List).map((e) => e as int).toList(),
      showLoading: showLoading,
    );
  }

  /// 🔍📖 SEARCH_READ
  Future<BaseResponse<List<T>>> searchRead<T>({
    required String model,
    List<dynamic>? domain,
    List<String>? fields,
    int? limit,
    int? offset,
    String? order,
    Map<String, dynamic>? context,
    T Function(Map<String, dynamic>)? fromJson,
    bool showLoading = true,
    bool useCache = false,
    String? cacheKey,
  }) async {
    final params = {
      "model": model,
      "method": "search_read",
      "args": [],
      "kwargs": {
        "domain": domain ?? [],
        if (fields != null) "fields": fields,
        if (limit != null) "limit": limit,
        if (offset != null) "offset": offset,
        if (order != null) "order": order,
        "context": _getContext(context),
      },
    };

    return _request<List<T>>(
      endpoint: ApiEndpoints.callKw,
      params: params,
      fromJson: (data) {
        if (data is! List) return <T>[];
        if (fromJson == null) return data.cast<T>();
        return data
            .map((item) => fromJson(Map<String, dynamic>.from(item)))
            .toList();
      },
      showLoading: showLoading,
      useCache: useCache,
      cacheKey: cacheKey ?? (useCache ? 'search_read_$model' : null),
      cacheTTL: 300,
    );
  }

  /// 🔢 SEARCH_COUNT
  Future<BaseResponse<int>> searchCount({
    required String model,
    List<dynamic>? domain,
    Map<String, dynamic>? context,
    bool showLoading = false,
  }) async {
    final params = {
      "model": model,
      "method": "search_count",
      "args": [domain ?? []],
      "kwargs": {"context": _getContext(context)},
    };

    return _request<int>(
      endpoint: ApiEndpoints.callKw,
      params: params,
      fromJson: (data) => data as int,
      showLoading: showLoading,
    );
  }

  /// ➕ CREATE
  Future<BaseResponse<int>> create({
    required String model,
    required Map<String, dynamic> values,
    Map<String, dynamic>? context,
    bool showLoading = true,
  }) async {
    final params = {
      "model": model,
      "method": "create",
      "args": [values],
      "kwargs": {"context": _getContext(context)},
    };

    return _request<int>(
      endpoint: ApiEndpoints.callKw,
      params: params,
      fromJson: (data) => data as int,
      showLoading: showLoading,
    );
  }

  /// ➕➕ CREATE_BATCH
  Future<BaseResponse<List<int>>> createBatch({
    required String model,
    required List<Map<String, dynamic>> valuesList,
    Map<String, dynamic>? context,
    bool showLoading = true,
  }) async {
    final results = <int>[];

    for (final values in valuesList) {
      final response = await create(
        model: model,
        values: values,
        context: context,
        showLoading: false,
      );

      if (response.success && response.data != null) {
        results.add(response.data!);
      } else {
        return BaseResponse.error(error: response.error ?? 'Unknown error');
      }
    }

    if (showLoading) _setLoading(false);
    return BaseResponse.success(data: results);
  }

  /// ✏️ UPDATE (WRITE)
  Future<BaseResponse<bool>> updateRecord({
    required String model,
    required List<int> ids,
    required Map<String, dynamic> values,
    Map<String, dynamic>? context,
    bool showLoading = true,
  }) async {
    final params = {
      "model": model,
      "method": "write",
      "args": [ids, values],
      "kwargs": {"context": _getContext(context)},
    };

    return _request<bool>(
      endpoint: ApiEndpoints.callKw,
      params: params,
      fromJson: (data) => data as bool,
      showLoading: showLoading,
    );
  }

  /// ❌ DELETE (UNLINK)
  Future<BaseResponse<bool>> delete({
    required String model,
    required List<int> ids,
    Map<String, dynamic>? context,
    bool showLoading = true,
  }) async {
    final params = {
      "model": model,
      "method": "unlink",
      "args": [ids],
      "kwargs": {"context": _getContext(context)},
    };

    return _request<bool>(
      endpoint: ApiEndpoints.callKw,
      params: params,
      fromJson: (data) => data as bool,
      showLoading: showLoading,
    );
  }

  // ==================== Advanced Operations ====================

  /// 🔄 CALL_KW
  Future<BaseResponse<T>> callKW<T>({
    required String model,
    required String method,
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? context,
    T Function(dynamic)? fromJson,
    bool showLoading = true,
  }) async {
    final params = {
      "model": model,
      "method": method,
      "args": args ?? [],
      "kwargs": {...(kwargs ?? {}), "context": _getContext(context)},
    };

    return _request<T>(
      endpoint: ApiEndpoints.callKw,
      params: params,
      fromJson: fromJson,
      showLoading: showLoading,
    );
  }

  /// 🔧 NAME_GET
  Future<BaseResponse<List<Map<String, dynamic>>>> nameGet({
    required String model,
    required List<int> ids,
    Map<String, dynamic>? context,
  }) async {
    return callKW<List<Map<String, dynamic>>>(
      model: model,
      method: 'name_get',
      args: [ids],
      context: context,
      fromJson: (data) => (data as List)
          .map((item) => {'id': item[0] as int, 'name': item[1] as String})
          .toList(),
      showLoading: false,
    );
  }

  /// 🔍 NAME_SEARCH
  Future<BaseResponse<List<Map<String, dynamic>>>> nameSearch({
    required String model,
    String? name,
    List<dynamic>? domain,
    int? limit,
    Map<String, dynamic>? context,
  }) async {
    return callKW<List<Map<String, dynamic>>>(
      model: model,
      method: 'name_search',
      args: [name ?? ''],
      kwargs: {
        if (domain != null) 'args': domain,
        if (limit != null) 'limit': limit,
      },
      context: context,
      fromJson: (data) => (data as List)
          .map((item) => {'id': item[0] as int, 'name': item[1] as String})
          .toList(),
      showLoading: false,
    );
  }

  /// 📋 FIELDS_GET
  Future<BaseResponse<Map<String, dynamic>>> fieldsGet({
    required String model,
    List<String>? fields,
    Map<String, dynamic>? context,
  }) async {
    return callKW<Map<String, dynamic>>(
      model: model,
      method: 'fields_get',
      args: fields != null ? [fields] : [],
      context: context,
      fromJson: (data) => Map<String, dynamic>.from(data),
      showLoading: false,
    );
  }

  // ==================== Utility Methods ====================

  /// معلومات الإصدار
  Future<BaseResponse<Map<String, dynamic>>> getVersionInfo() async {
    return _request<Map<String, dynamic>>(
      endpoint: ApiEndpoints.getVersionInfo,
      params: {},
      fromJson: (data) => Map<String, dynamic>.from(data),
      useCache: true,
      cacheKey: 'version_info',
      cacheTTL: 3600,
    );
  }

  /// قائمة قواعد البيانات
  Future<BaseResponse<List<String>>> getDatabases() async {
    return _request<List<String>>(
      endpoint: ApiEndpoints.getDatabases,
      params: {},
      fromJson: (data) => (data as List).map((e) => e.toString()).toList(),
      showLoading: false,
    );
  }

  // ==================== Offline Queue Management ====================

  /// معالجة طلبات Offline
  Future<void> processOfflineQueue() async {
    try {
      final queue = await StorageService.instance.getQueueItems();

      if (queue.isEmpty) {
        appLogger.info('✅ Offline queue is empty');
        return;
      }

      appLogger.info('📤 Processing ${queue.length} queued requests');

      for (final item in queue) {
        try {
          final endpoint = item['endpoint'] as String;
          final params = item['params'] as Map<String, dynamic>;

          final response = await _request(
            endpoint: endpoint,
            params: params,
            showLoading: false,
            retryOnError: false,
          );

          if (response.success) {
            await StorageService.instance.removeFromQueue(item['id']);
            appLogger.info('✅ Synced queued request');
          }
        } catch (e) {
          appLogger.error('Failed to process queue item', error: e);
        }
      }
    } catch (e) {
      appLogger.error('Error processing offline queue', error: e);
    }
  }

  /// مسح الـ Cache
  Future<void> clearCache() async {
    await StorageService.instance.clearCache();
    appLogger.info('🗑️ Cache cleared');
  }

  /// مسح Session
  Future<void> clearSession() async {
    _sessionId = null;
    _cookies.clear();
    await StorageService.instance.clearSession();
    appLogger.info('🗑️ Session cleared');
  }

  /// استعادة Session من التخزين
  Future<void> restoreSession() async {
    try {
      final session = StorageService.instance.getSession();
      if (session != null) {
        _sessionId = session['session_id'];
        if (session['cookies'] != null) {
          _cookies = Map<String, String>.from(session['cookies']);
        }
        appLogger.info('✅ Session restored');
      }
    } catch (e) {
      appLogger.error('Failed to restore session', error: e);
    }
  }

  @override
  void onInit() {
    super.onInit();
    // استعادة Session عند تهيئة Controller
    restoreSession();
  }
}
