import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:routy/common/api/api.dart';

import 'package:routy/common/api/api_response.dart';

import 'package:routy/services/storage_service.dart';
import 'package:routy/utils/app_logger.dart';

/// 🌐 API Service - إدارة الاتصال مع Odoo
///
/// يدعم:
/// - ✅ Odoo 18 (JSON-RPC)
/// - ✅ Authentication
/// - ✅ CRUD Operations
/// - ✅ Session Management
/// - ✅ Error Handling
class ApiService {
  // ==================== Singleton ====================
  static final ApiService _instance = ApiService._internal();
  static ApiService get instance => _instance;

  factory ApiService() => _instance;

  // ==================== Dependencies ====================
  final _storageService = StorageService.instance;

  // ==================== State ====================
  String? _sessionId;
  String? _database;
  int? _uid;
  String? _username;

  // ==================== Constructor ====================
  ApiService._internal() {
    debugPrint('ApiService constructor');
  }

  // ==================== Authentication ====================

  /// تسجيل الدخول
  Future<void> login({
    required String username,
    required String password,
    required String database,
    required Function(dynamic) onResponse,
    required Function(String, Map) onError,
  }) async {
    Api.authenticate(
      username: username,
      password: password,
      database: database,
      onResponse: (userModel) {
        // تحديث حالة ApiService
        _uid = userModel.uid;
        _database = database;
        _username = username;

        // حفظ البيانات
        _storageService.setString('uid', userModel.uid.toString());
        _storageService.setString('database', database);
        _storageService.setString('username', username);

        appLogger.info('✅ ApiService state updated: uid=$_uid, db=$_database');

        // استدعاء callback
        onResponse(userModel);
      },
      onError: onError,
    );
  }

  /// تحميل الجلسة المحفوظة
  Future<void> loadSession() async {
    try {
      final uidStr = _storageService.getString('uid');
      final database = _storageService.getString('database');
      final username = _storageService.getString('username');

      if (uidStr != null && database != null) {
        _uid = int.tryParse(uidStr);
        _database = database;
        _username = username;
        appLogger.info('✅ Session loaded: uid=$_uid, db=$_database');
      }
    } catch (e) {
      appLogger.error('Error loading session', error: e);
    }
  }

  /// تسجيل الخروج
  Future<ApiResponse<void>> logout() async {
    try {
      Api.destroy(
        onResponse: (response) async {
          if (response.success) {
            if (kDebugMode) {
              appLogger.info('Session destroyed: ${response.data}');
            }
            // مسح البيانات المحلية
            _sessionId = null;
            _database = null;
            _uid = null;
            _username = null;
            await _storageService.remove('session_id');
            await _storageService.remove('uid');
            await _storageService.remove('database');
            await _storageService.remove('username');
            appLogger.info('✅ Session destroyed');
          }
        },
        onError: (error, data) {
          if (kDebugMode) {
            appLogger.info('Error destroying session: $error');
          }
        },
      );
      return ApiResponse.success(null);
    } catch (e) {
      appLogger.error('Error destroying session', error: e);
      return ApiResponse.error('خطأ في تسجيل الخروج: $e');
    }
  }

  // ==================== Getters ====================

  bool get isAuthenticated => _uid != null && _database != null;
  String? get sessionId => _sessionId;
  String? get database => _database;
  int? get uid => _uid;
  String? get username => _username;
}
