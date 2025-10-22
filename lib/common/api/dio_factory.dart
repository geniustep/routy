import 'dart:developer' show log;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:routy/utils/app_logger.dart';

class DioFactory {
  static final _singleton = DioFactory._instance();

  static Dio? get dio => _singleton._dio;
  static var _deviceName = 'Generic Device';
  static var _authorization = '';

  /// الحصول على معلومات الجهاز
  static Future<bool> computeDeviceInfo() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (Platform.isAndroid) {
        _deviceName = 'Android Device';
      } else {
        _deviceName = 'iOS Device';
      }
    } else if (Platform.isFuchsia) {
      _deviceName = 'Generic Fuchsia Device';
    } else if (Platform.isLinux) {
      _deviceName = 'Generic Linux Device';
    } else if (Platform.isMacOS) {
      _deviceName = 'Generic Macintosh Device';
    } else if (Platform.isWindows) {
      _deviceName = 'Generic Windows Device';
    } else {
      _deviceName = 'Web Browser';
    }

    return true;
  }

  /// تهيئة الترويسة Authorization
  static void initialiseHeaders(String token) {
    _authorization = token;
    _singleton._dio!.options.headers[HttpHeaders.cookieHeader] = _authorization;
  }

  /// تعيين توكن FCM
  static void initFCMToken(String token) {
    var newToken = token;
    _singleton._dio!.options.headers["device_id"] = newToken;
  }

  /// إعدادات CORS للخادم الحقيقي
  static void setupCORS() {
    _singleton._dio!.options.headers.addAll({
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers':
          'Content-Type, Authorization, X-Requested-With',
      'Access-Control-Allow-Credentials': 'true',
    });

    // إعدادات إضافية للخادم
    _singleton._dio!.options.extra['withCredentials'] = true;
    _singleton._dio!.options.followRedirects = true;
    _singleton._dio!.options.maxRedirects = 5;
    _singleton._dio!.options.receiveDataWhenStatusError = true;
    _singleton._dio!.options.persistentConnection = true;
  }

  Dio? _dio;

  /// المُنشئ الخاص بـ DioFactory
  DioFactory._instance() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://app.propanel.ma/', // يمكن تغييرها حسب البيئة
        headers: {
          HttpHeaders.userAgentHeader: _deviceName,
          HttpHeaders.authorizationHeader: _authorization,
          'Connection': 'Keep-Alive',
          'Keep-Alive': 'timeout=120, max=1000',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 60),
        contentType: Headers.jsonContentType,
        validateStatus: (status) {
          return status != null && status < 500;
        },
        // إعدادات CORS للخادم الحقيقي
        extra: {'withCredentials': true},
        // إعدادات إضافية للخادم
        followRedirects: true,
        maxRedirects: 5,
        // إعدادات إضافية للخادم الحقيقي
        receiveDataWhenStatusError: true,
        persistentConnection: true,
      ),
    );

    if (!kReleaseMode) {
      _dio!.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (Object object) {
            log(object.toString(), name: 'dio');
          },
        ),
      );
    }

    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // إعدادات CORS للخادم الحقيقي
          options.headers['Access-Control-Allow-Origin'] = '*';
          options.headers['Access-Control-Allow-Methods'] =
              'GET, POST, PUT, DELETE, OPTIONS';
          options.headers['Access-Control-Allow-Headers'] =
              'Content-Type, Authorization, X-Requested-With';
          options.headers['Access-Control-Allow-Credentials'] = 'true';

          // معالجة OPTIONS requests (CORS preflight)
          if (options.method == 'OPTIONS') {
            appLogger.info('CORS preflight request detected');
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                headers: Headers.fromMap({
                  'Access-Control-Allow-Origin': ['*'],
                  'Access-Control-Allow-Methods': [
                    'GET, POST, PUT, DELETE, OPTIONS',
                  ],
                  'Access-Control-Allow-Headers': [
                    'Content-Type, Authorization, X-Requested-With',
                  ],
                  'Access-Control-Allow-Credentials': ['true'],
                }),
              ),
            );
          }

          // معالجة الطلب قبل الإرسال
          appLogger.info(
            'Request [${options.method}] => PATH: ${options.path}',
          );
          return handler.next(options); // متابعة الطلب
        },
        onResponse: (response, handler) {
          // إضافة CORS headers للاستجابة
          response.headers.add('Access-Control-Allow-Origin', '*');
          response.headers.add(
            'Access-Control-Allow-Methods',
            'GET, POST, PUT, DELETE, OPTIONS',
          );
          response.headers.add(
            'Access-Control-Allow-Headers',
            'Content-Type, Authorization, X-Requested-With',
          );
          response.headers.add('Access-Control-Allow-Credentials', 'true');

          // معالجة الاستجابة
          appLogger.info(
            'Response [${response.statusCode}] => DATA: ${response.data}',
          );
          return handler.next(response); // متابعة الاستجابة
        },
        onError: (DioException e, handler) async {
          // إضافة CORS headers للخطأ
          if (e.response != null) {
            e.response!.headers.add('Access-Control-Allow-Origin', '*');
            e.response!.headers.add(
              'Access-Control-Allow-Methods',
              'GET, POST, PUT, DELETE, OPTIONS',
            );
            e.response!.headers.add(
              'Access-Control-Allow-Headers',
              'Content-Type, Authorization, X-Requested-With',
            );
            e.response!.headers.add('Access-Control-Allow-Credentials', 'true');
          }

          // التحقق من حالة الخطأ 401
          if (e.response?.statusCode == 401) {
            appLogger.warning('Session expired. Showing dialog...');
            showSessionDialog(); // استدعاء الدالة لعرض نافذة انتهاء الجلسة
            return handler.next(e); // متابعة الخطأ
          }

          appLogger.error('Error [${e.type}] => MESSAGE: ${e.message}');
          return handler.next(e); // متابعة الخطأ
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Session Dialog
// ════════════════════════════════════════════════════════════

void showSessionDialog() {
  // يمكن تنفيذ منطق عرض نافذة انتهاء الجلسة هنا
  appLogger.warning('Session expired dialog should be shown');
}
