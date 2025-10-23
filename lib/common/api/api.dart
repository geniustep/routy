// ════════════════════════════════════════════════════════════
// api.dart - الصفحة الكاملة المحسّنة والمحدثة
// ════════════════════════════════════════════════════════════

import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:routy/common/api/api_response.dart';
import 'package:routy/common/api/endpoints.dart';
import 'package:routy/common/api/dio_factory.dart';
import 'package:routy/common/models/version_info_response.dart';
import 'package:routy/common/models/databases_response.dart';
import 'package:routy/common/models/user_model.dart';
import 'package:routy/services/storage_service.dart';
import 'package:routy/utils/pref_utils.dart';
import 'package:routy/utils/app_logger.dart';
import 'package:uuid/uuid.dart';

// ════════════════════════════════════════════════════════════
// Enums
// ════════════════════════════════════════════════════════════

enum ApiEnvironment { uat, dev, prod }

extension APIEnvi on ApiEnvironment {
  String get endpoint {
    String url = "https://app.propanel.ma/";
    switch (this) {
      case ApiEnvironment.uat:
        return url;
      case ApiEnvironment.dev:
        return url;
      case ApiEnvironment.prod:
        return url;
    }
  }
}

enum HttpMethod { delete, get, patch, post, put }

extension HttpMethods on HttpMethod {
  String get value {
    switch (this) {
      case HttpMethod.delete:
        return 'DELETE';
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.patch:
        return 'PATCH';
      case HttpMethod.post:
        return 'POST';
      case HttpMethod.put:
        return 'PUT';
    }
  }
}

// ════════════════════════════════════════════════════════════
// Api Class
// ════════════════════════════════════════════════════════════

class Api {
  Api._();
  static final _dio = DioFactory.dio;
  static final _storageService = StorageService.instance;
  // ════════════════════════════════════════════════════════════
  // Private Variables
  // ════════════════════════════════════════════════════════════

  // ════════════════════════════════════════════════════════════
  // Loading Handler
  // ════════════════════════════════════════════════════════════

  static void _handleLoading(bool? showGlobalLoading, bool isStart) {
    if (showGlobalLoading == true) {
      if (isStart) {
        appLogger.info('🔄 Loading started');
      } else {
        appLogger.info('✅ Loading completed');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Error Handling
  // ════════════════════════════════════════════════════════════

  static final catchError = _catchError;

  static void _catchError(e, stackTrace, OnError onError) async {
    appLogger.error('API Error', error: e, stackTrace: stackTrace);

    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown) {
        onError('Server unreachable', {});
      } else if (e.type == DioExceptionType.badResponse) {
        final response = e.response;
        if (response != null) {
          var data = response.data;

          // HTML response check
          if (data is String && data.contains('<!doctype html>')) {
            await handleSessionExpired();
            onError(
              'Session expired or URL not found. Please login again.',
              {},
            );
            return;
          }

          // JSON response
          if (data != null && data is Map<String, dynamic>) {
            // Session expired check
            if (data.containsKey("error") && data["error"]["code"] == 100) {
              await handleSessionExpired();
              return;
            }

            onError('Failed to get response: ${e.message}', data);
            return;
          }
        }
        onError('Failed to get response: ${e.message}', {});
      } else {
        onError('Request cancelled: ${e.message}', {});
      }
    } else {
      onError(e?.toString() ?? 'Unknown error occurred', {});
    }
  }

  // ════════════════════════════════════════════════════════════
  // General Request
  // ════════════════════════════════════════════════════════════

  static Future<void> request({
    required HttpMethod method,
    required String path,
    required Map params,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    Future.delayed(const Duration(microseconds: 1), () {
      if (path != ApiEndpoints.getVersionInfo &&
          path != ApiEndpoints.getDatabases) {
        _handleLoading(showGlobalLoading, true);
      }
    });

    try {
      Response? response;
      switch (method) {
        case HttpMethod.post:
          response = await _dio!.post(path, data: params);
          break;
        case HttpMethod.delete:
          response = await _dio!.delete(path, data: params);
          break;
        case HttpMethod.get:
          response = await _dio!.get(path);
          break;
        case HttpMethod.patch:
          response = await _dio!.patch(path, data: params);
          break;
        case HttpMethod.put:
          response = await _dio!.put(path, data: params);
          break;
      }

      _handleLoading(showGlobalLoading, false);

      // التحقق من نوع الاستجابة
      if (response.data is String &&
          response.data.contains('<!doctype html>')) {
        appLogger.warning('⚠️ Session expired (HTML response)');
        await handleSessionExpired();
        return;
      }

      if (response.data is! Map) {
        appLogger.error('Invalid response type: ${response.data.runtimeType}');
        onError('Invalid response format', {});
        return;
      }

      if (response.data["success"] == 0) {
        final errorMessage = response.data["error"][0] ?? 'Server error';
        appLogger.error('Server error: $errorMessage');
        onError(errorMessage, {});
      } else {
        if (response.data.containsKey("error") &&
            response.data["error"] is Map<String, dynamic> &&
            response.data["error"]["code"] == 100) {
          appLogger.warning('Session expired');
          await handleSessionExpired();
        } else if (response.data.containsKey("result")) {
          onResponse(response.data["result"]);
        } else {
          appLogger.error('Bad response format');
          onError('Bad response format', response.data);
        }
      }

      if (path == ApiEndpoints.authenticate) {
        _updateCookies(response.headers);
      }
    } on DioException catch (e) {
      _handleLoading(showGlobalLoading, false);

      String errorMessage = 'Network error';

      if (e.type == DioExceptionType.connectionError) {
        if (e.error is SocketException) {
          final socketException = e.error as SocketException;
          if (socketException.osError?.errorCode == 7 ||
              e.message?.contains('Failed host lookup') == true) {
            errorMessage = 'No internet connection';
          } else {
            errorMessage = 'Connection failed';
          }
        } else {
          errorMessage = 'Connection failed';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      } else if (e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Send timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Receive timeout';
      } else if (e.type == DioExceptionType.badResponse) {
        final response = e.response;
        if (response != null) {
          var data = response.data;

          if (data is String && data.contains('<!doctype html>')) {
            errorMessage = 'Session expired';
            await handleSessionExpired();
            onError(errorMessage, {});
            return;
          }

          if (data != null && data is Map<String, dynamic>) {
            if (data.containsKey("error")) {
              if (data["error"]["code"] == 100) {
                await handleSessionExpired();
                onError('Session expired', {});
                return;
              }
            } else {
              errorMessage = 'Bad response';
            }
          } else {
            errorMessage = 'Bad response';
          }
        } else {
          errorMessage = 'Bad response';
        }
      } else if (e.type == DioExceptionType.cancel) {
        errorMessage = 'Request cancelled';
      } else if (e.type == DioExceptionType.unknown) {
        if (e.error is SocketException) {
          errorMessage = 'No internet connection';
        } else {
          errorMessage = 'Unknown error';
        }
      } else {
        errorMessage = 'Unknown error';
      }

      appLogger.error('API Error: $errorMessage');
      onError(errorMessage, {});
    } catch (e) {
      _handleLoading(showGlobalLoading, false);
      appLogger.error('Unexpected error: $e');
      onError('Unexpected error: $e', {});
    }
  }

  static void _updateCookies(Headers headers) async {
    appLogger.info("Updating cookies...");
    final cookies = headers['set-cookie'];
    if (cookies != null && cookies.isNotEmpty) {
      final combinedCookies = cookies.join('; ');
      DioFactory.initialiseHeaders(combinedCookies);
      await PrefUtils.setToken(combinedCookies);
      appLogger.info("Cookies updated successfully: $combinedCookies");
    } else {
      appLogger.warning("No cookies found in the response headers.");
    }
  }

  // ════════════════════════════════════════════════════════════
  // Session Management
  // ════════════════════════════════════════════════════════════

  static getSessionInfo({
    required OnResponse onResponse,
    required OnError onError,
  }) {
    request(
      method: HttpMethod.post,
      path: ApiEndpoints.getSessionInfo,
      params: createPayload({}),
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        onError(error, {});
      },
    );
  }

  /// تسجيل الخروج

  static destroy({required OnResponse onResponse, required OnError onError}) {
    request(
      method: HttpMethod.post,
      path: ApiEndpoints.destroy,
      params: createPayload({}),
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        onError(error, {});
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // Authentication
  // ════════════════════════════════════════════════════════════

  static authenticate({
    required String username,
    required String password,
    required String database,
    required OnResponse<UserModel> onResponse,
    required OnError onError,
  }) {
    var params = {
      "db": database,
      "login": username,
      "password": password,
      "context": {},
    };

    request(
      method: HttpMethod.post,
      path: ApiEndpoints.authenticate,
      params: createPayload(params),
      onResponse: (response) {
        onResponse(UserModel.fromJson(response));
      },
      onError: (error, data) {
        onError(error, {});
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // Call KW - الدالة الأساسية
  // ════════════════════════════════════════════════════════════

  static callKW({
    required String model,
    required String method,
    required List args,
    Map<String, dynamic>? context,
    Map? kwargs,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    var params = {
      "model": model,
      "method": method,
      "args": args,
      "kwargs": kwargs ?? {},
    };

    request(
      method: HttpMethod.post,
      path: ApiEndpoints.callKw,
      params: createPayload(params),
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        onError(error, {});
      },
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Search Read
  // ════════════════════════════════════════════════════════════

  static Future<void> searchRead({
    required String model,
    List<String>? fields,
    required List domain,
    dynamic limit,
    dynamic offset,
    String? order,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    var params = {
      "model": model,
      "method": "search_read",
      "args": [],
      "kwargs": {
        "domain": domain,
        if (fields != null) "fields": fields,
        if (limit != null) "limit": limit,
        if (offset != null) "offset": offset,
        if (order != null) "order": order,
        "context": context ?? {},
      },
    };
    debugPrint(params.toString());

    request(
      method: HttpMethod.post,
      path: ApiEndpoints.callKw,
      params: createPayload(params),
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Search Count
  // ════════════════════════════════════════════════════════════

  static searchCount({
    required String model,
    required List domain,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    callKW(
      model: model,
      method: "search_count",
      args: [],
      kwargs: {"domain": domain, if (context != null) "context": context},
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Read
  // ════════════════════════════════════════════════════════════

  static read({
    required String model,
    required List<int> ids,
    List<String>? fields,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    callKW(
      model: model,
      method: "read",
      args: [ids],
      kwargs: {
        if (fields != null) "fields": fields,
        if (context != null) "context": context,
      },
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Create
  // ════════════════════════════════════════════════════════════

  static create({
    required String model,
    required Map<String, dynamic> values,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    callKW(
      model: model,
      method: "create",
      args: [values],
      kwargs: {if (context != null) "context": context},
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Write
  // ════════════════════════════════════════════════════════════

  static write({
    required String model,
    required List<int> ids,
    required Map<String, dynamic> values,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    callKW(
      model: model,
      method: "write",
      args: [ids, values],
      kwargs: {if (context != null) "context": context},
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Unlink
  // ════════════════════════════════════════════════════════════

  static unlink({
    required String model,
    required List<int> ids,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    callKW(
      model: model,
      method: "unlink",
      args: [ids],
      kwargs: {if (context != null) "context": context},
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Get Version Info
  // ════════════════════════════════════════════════════════════

  static getVersionInfo({
    required OnResponse<VersionInfoResponse> onResponse,
    required OnError onError,
  }) {
    // محاولة من Cache أولاً
    final cached = _storageService.getCache('version_info');
    if (cached != null) {
      appLogger.info('📦 Cache hit: version_info');
      onResponse(
        VersionInfoResponse.fromJson(Map<String, dynamic>.from(cached as Map)),
      );
      return; // إيقاف التنفيذ - لا داعي للطلب من السيرفر
    }

    // جلب من السيرفر إذا لم يكن في الكاش
    request(
      method: HttpMethod.post,
      path: ApiEndpoints.getVersionInfo,
      params: createPayload({}),
      onResponse: (response) async {
        if (response != null) {
          // حفظ في Cache
          await _storageService.setCache('version_info', response);
          ApiResponse.success(response);
          onResponse(VersionInfoResponse.fromJson(response));
        }
      },
      onError: (error, data) {
        ApiResponse.error('فشل الحصول على معلومات الإصدار');
        onError(error, {});
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // Get Databases
  // ════════════════════════════════════════════════════════════

  static getDatabases({
    required int serverVersionNumber,
    required OnResponse<DatabasesResponse> onResponse,
    required OnError onError,
  }) async {
    var params = {};
    var endPoint = "";

    if (serverVersionNumber == 9) {
      params["method"] = "list";
      params["service"] = "db";
      params["args"] = [];
      endPoint = ApiEndpoints.getDatabases;
    } else if (serverVersionNumber >= 10) {
      endPoint = ApiEndpoints.getDatabases;
      params["context"] = {};
    } else {
      endPoint = ApiEndpoints.getDatabases;
      params["context"] = {};
    }

    request(
      method: HttpMethod.post,
      path: endPoint,
      params: createPayload(params),
      onResponse: (response) {
        // Convert the list response to DatabasesResponse
        if (response is List) {
          final databasesResponse = DatabasesResponse.fromList(
            response,
            serverVersion: serverVersionNumber.toString(),
          );
          onResponse(databasesResponse);
        } else {
          appLogger.error(
            'Unexpected response type for databases: ${response.runtimeType}',
          );
          onError('Invalid response format', {});
        }
      },
      onError: (error, data) {
        onError(error, {});
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // Helper Methods
  // ════════════════════════════════════════════════════════════

  static Map createPayload(Map params) {
    return {
      "id": const Uuid().v1(),
      "jsonrpc": "2.0",
      "method": "call",
      "params": params,
    };
  }

  static Map<String, dynamic> getContext(dynamic addition) {
    Map<String, dynamic> map = {
      "lang": "en_US",
      "tz": "Europe/Brussels",
      "uid": const Uuid().v1(),
    };
    if (addition != null && addition.isNotEmpty) {
      addition.forEach((key, value) {
        map[key] = value;
      });
    }
    return map;
  }

  // ════════════════════════════════════════════════════════════
  // Session Expired Handler
  // ════════════════════════════════════════════════════════════

  static Future<void> handleSessionExpired() async {
    appLogger.warning('⚠️ Session expired - clearing user data');

    try {
      // مسح جميع البيانات
      await PrefUtils.clearAll();
      await StorageService.instance.clearUserData();
      await _storageService.remove('uid');
      await _storageService.remove('database');
      await _storageService.remove('username');

      // إعادة التوجيه للـ login
      Get.offAllNamed('/login');

      // عرض رسالة للمستخدم
      Get.snackbar(
        'انتهت الجلسة',
        'يرجى تسجيل الدخول مرة أخرى',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      appLogger.info('✅ Redirected to login');
    } catch (e) {
      appLogger.error('Error handling session expiry', error: e);
    }
  }
}

// ════════════════════════════════════════════════════════════
// Type Definitions
// ════════════════════════════════════════════════════════════

typedef OnError = void Function(String error, Map<String, dynamic> data);
typedef OnResponse<T> = void Function(T response);
