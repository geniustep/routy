import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// 💾 StorageService المحسّن - نظام تخزين ثلاثي الطبقات
///
/// الطبقات الثلاث:
/// 1️⃣ SharedPreferences: إعدادات بسيطة (<100 قيمة)
/// 2️⃣ Hive: Cache سريع وQueue (<1000 سجل)
/// 3️⃣ SQLite: بيانات كاملة (>1000 سجل) - في DatabaseService
///
/// المزايا:
/// ✅ Cache مع TTL
/// ✅ Offline Queue
/// ✅ Session Management
/// ✅ Error Handling
/// ✅ Encryption Ready
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  StorageService._();

  // ==================== Storage Layers ====================
  late SharedPreferences _prefs;
  late Box _cacheBox;
  late Box _queueBox;
  late Box _sessionBox;
  late Box _settingsBox;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // ==================== Storage Keys ====================
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserData = 'userData';
  static const String keyLanguage = 'language';
  static const String keyThemeMode = 'themeMode';
  static const String keyFirstTime = 'firstTime';
  static const String keyNotificationsEnabled = 'notificationsEnabled';
  static const String keyLocationEnabled = 'locationEnabled';
  static const String keyAutoSync = 'autoSync';
  static const String keyFontSize = 'fontSize';
  static const String keyLastSync = 'lastSync';

  // ==================== Initialization ====================

  /// تهيئة خدمة التخزين
  Future<void> initialize() async {
    if (_isInitialized) {
      appLogger.warning('⚠️ StorageService already initialized');
      return;
    }

    try {
      appLogger.info('🔧 Initializing StorageService...');

      // Layer 1: SharedPreferences
      await _initializeSharedPreferences();

      // Layer 2: Hive
      await _initializeHive();

      _isInitialized = true;
      appLogger.info('✅ StorageService initialized successfully');
    } catch (e, stackTrace) {
      appLogger.error(
        'StorageService initialization failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// تهيئة SharedPreferences
  Future<void> _initializeSharedPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      appLogger.storage('Initialize', key: 'SharedPreferences');
    } catch (e) {
      appLogger.error('SharedPreferences init failed', error: e);
      rethrow;
    }
  }

  /// تهيئة Hive
  Future<void> _initializeHive() async {
    try {
      await Hive.initFlutter();

      // فتح جميع الـ Boxes
      _cacheBox = await Hive.openBox('cache');
      _queueBox = await Hive.openBox('offline_queue');
      _sessionBox = await Hive.openBox('session');
      _settingsBox = await Hive.openBox('settings');

      appLogger.storage('Initialize', key: 'Hive Boxes');
    } catch (e) {
      appLogger.error('Hive init failed', error: e);
      rethrow;
    }
  }

  // ==================== Layer 1: SharedPreferences ====================

  /// حفظ String
  Future<bool> setString(String key, String value) async {
    try {
      appLogger.storage('Set', key: key, value: value);
      return await _prefs.setString(key, value);
    } catch (e) {
      appLogger.error('Error setting string', error: e);
      return false;
    }
  }

  /// جلب String
  String? getString(String key, {String? defaultValue}) {
    try {
      return _prefs.getString(key) ?? defaultValue;
    } catch (e) {
      appLogger.warning('Error getting string for key $key: $e');
      return defaultValue;
    }
  }

  /// حفظ Bool
  Future<bool> setBool(String key, bool value) async {
    try {
      appLogger.storage('Set', key: key, value: value);
      return await _prefs.setBool(key, value);
    } catch (e) {
      appLogger.error('Error setting bool', error: e);
      return false;
    }
  }

  /// جلب Bool
  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _prefs.getBool(key) ?? defaultValue;
    } catch (e) {
      appLogger.warning('Error getting bool for key $key: $e');
      return defaultValue;
    }
  }

  /// حفظ Int
  Future<bool> setInt(String key, int value) async {
    try {
      appLogger.storage('Set', key: key, value: value);
      return await _prefs.setInt(key, value);
    } catch (e) {
      appLogger.error('Error setting int', error: e);
      return false;
    }
  }

  /// جلب Int
  int getInt(String key, {int defaultValue = 0}) {
    try {
      return _prefs.getInt(key) ?? defaultValue;
    } catch (e) {
      appLogger.warning('Error getting int for key $key: $e');
      return defaultValue;
    }
  }

  /// حفظ Double
  Future<bool> setDouble(String key, double value) async {
    try {
      appLogger.storage('Set', key: key, value: value);
      return await _prefs.setDouble(key, value);
    } catch (e) {
      appLogger.error('Error setting double', error: e);
      return false;
    }
  }

  /// جلب Double
  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return _prefs.getDouble(key) ?? defaultValue;
    } catch (e) {
      appLogger.warning('Error getting double for key $key: $e');
      return defaultValue;
    }
  }

  /// حفظ StringList
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      appLogger.storage('Set', key: key);
      return await _prefs.setStringList(key, value);
    } catch (e) {
      appLogger.error('Error setting string list', error: e);
      return false;
    }
  }

  /// جلب StringList
  List<String>? getStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      appLogger.warning('Error getting string list for key $key: $e');
      return null;
    }
  }

  /// حذف مفتاح
  Future<bool> remove(String key) async {
    try {
      appLogger.storage('Remove', key: key);
      return await _prefs.remove(key);
    } catch (e) {
      appLogger.error('Error removing key', error: e);
      return false;
    }
  }

  /// مسح جميع البيانات
  Future<bool> clearAll() async {
    try {
      appLogger.warning('🗑️ Clearing all SharedPreferences');
      return await _prefs.clear();
    } catch (e) {
      appLogger.error('Error clearing prefs', error: e);
      return false;
    }
  }

  // ==================== Layer 2: Hive Cache ====================

  /// حفظ في Cache مع TTL
  Future<void> setCache(String key, dynamic value, [int? ttlSeconds]) async {
    try {
      final data = {
        'value': value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'ttl': ttlSeconds,
      };
      await _cacheBox.put(key, data);
      appLogger.storage('Cache Set', key: key);
    } catch (e) {
      appLogger.error('Error setting cache', error: e);
    }
  }

  /// جلب من Cache مع التحقق من الانتهاء
  dynamic getCache(String key) {
    try {
      final data = _cacheBox.get(key);
      if (data == null) return null;

      // التحقق من TTL
      if (data['ttl'] != null) {
        final timestamp = data['timestamp'] as int;
        final ttl = data['ttl'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;

        if (now - timestamp > ttl * 1000) {
          _cacheBox.delete(key);
          appLogger.storage('Cache Expired', key: key);
          return null;
        }
      }

      appLogger.storage('Cache Hit', key: key);
      return data['value'];
    } catch (e) {
      appLogger.warning('Error getting cache for key $key: $e');
      return null;
    }
  }

  /// حذف من Cache
  Future<void> deleteCache(String key) async {
    try {
      await _cacheBox.delete(key);
      appLogger.storage('Cache Delete', key: key);
    } catch (e) {
      appLogger.error('Error deleting cache', error: e);
    }
  }

  /// مسح جميع الـ Cache
  Future<void> clearCache() async {
    try {
      await _cacheBox.clear();
      appLogger.warning('🗑️ Cache cleared');
    } catch (e) {
      appLogger.error('Error clearing cache', error: e);
    }
  }

  /// عدد عناصر الـ Cache
  int getCacheCount() => _cacheBox.length;

  // ==================== Layer 2: Offline Queue ====================

  /// إضافة للـ Queue
  Future<void> addToQueue(Map<String, dynamic> operation) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final queueItem = {
        'id': id,
        ...operation,
        'createdAt': DateTime.now().toIso8601String(),
        'retries': 0,
        'priority': operation['priority'] ?? 1,
      };
      await _queueBox.put(id, queueItem);
      appLogger.storage('Queue Add', key: id);
    } catch (e) {
      appLogger.error('Error adding to queue', error: e);
    }
  }

  /// جلب جميع عناصر الـ Queue
  Future<List<Map<String, dynamic>>> getQueueItems() async {
    try {
      final items = <Map<String, dynamic>>[];
      for (var key in _queueBox.keys) {
        final item = _queueBox.get(key);
        if (item != null) {
          items.add(Map<String, dynamic>.from(item));
        }
      }

      // ترتيب حسب الأولوية
      items.sort(
        (a, b) => (b['priority'] as int).compareTo(a['priority'] as int),
      );

      return items;
    } catch (e) {
      appLogger.error('Error getting queue items', error: e);
      return [];
    }
  }

  /// حذف من الـ Queue
  Future<void> removeFromQueue(String id) async {
    try {
      await _queueBox.delete(id);
      appLogger.storage('Queue Remove', key: id);
    } catch (e) {
      appLogger.error('Error removing from queue', error: e);
    }
  }

  /// مسح جميع الـ Queue
  Future<void> clearQueue() async {
    try {
      await _queueBox.clear();
      appLogger.warning('🗑️ Queue cleared');
    } catch (e) {
      appLogger.error('Error clearing queue', error: e);
    }
  }

  /// عدد عناصر الـ Queue
  int getQueueCount() => _queueBox.length;

  // ==================== Layer 2: Session ====================

  /// حفظ Session
  Future<void> saveSession(Map<String, dynamic> session) async {
    try {
      await _sessionBox.put('current_session', {
        ...session,
        'lastActivity': DateTime.now().toIso8601String(),
      });
      appLogger.storage('Session Save', key: 'current_session');
    } catch (e) {
      appLogger.error('Error saving session', error: e);
    }
  }

  /// جلب Session
  Map<String, dynamic>? getSession() {
    try {
      final session = _sessionBox.get('current_session');
      if (session == null) return null;

      // التحقق من انتهاء الصلاحية (30 دقيقة)
      final lastActivity = DateTime.parse(session['lastActivity']);
      final now = DateTime.now();

      if (now.difference(lastActivity).inMinutes > 30) {
        clearSession();
        appLogger.warning('⚠️ Session expired');
        return null;
      }

      return Map<String, dynamic>.from(session);
    } catch (e) {
      appLogger.error('Error getting session', error: e);
      return null;
    }
  }

  /// تحديث نشاط Session
  Future<void> updateSessionActivity() async {
    try {
      final session = getSession();
      if (session != null) {
        await saveSession(session);
      }
    } catch (e) {
      appLogger.error('Error updating session', error: e);
    }
  }

  /// مسح Session
  Future<void> clearSession() async {
    try {
      await _sessionBox.clear();
      appLogger.warning('🗑️ Session cleared');
    } catch (e) {
      appLogger.error('Error clearing session', error: e);
    }
  }

  // ==================== Layer 2: Settings ====================

  /// حفظ إعداد
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      await _settingsBox.put(key, value);
      appLogger.storage('Setting Save', key: key);
    } catch (e) {
      appLogger.error('Error saving setting', error: e);
    }
  }

  /// جلب إعداد
  dynamic getSetting(String key, {dynamic defaultValue}) {
    try {
      return _settingsBox.get(key, defaultValue: defaultValue);
    } catch (e) {
      appLogger.warning('Error getting setting for key $key: $e');
      return defaultValue;
    }
  }

  /// حذف إعداد
  Future<void> deleteSetting(String key) async {
    try {
      await _settingsBox.delete(key);
      appLogger.storage('Setting Delete', key: key);
    } catch (e) {
      appLogger.error('Error deleting setting', error: e);
    }
  }

  /// مسح جميع الإعدادات
  Future<void> clearSettings() async {
    try {
      await _settingsBox.clear();
      appLogger.warning('🗑️ Settings cleared');
    } catch (e) {
      appLogger.error('Error clearing settings', error: e);
    }
  }

  // ==================== User Management ====================

  /// حفظ بيانات المستخدم
  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      final userJson = jsonEncode(userData);
      await setString(keyUserData, userJson);
      appLogger.storage('Save', key: 'user');
    } catch (e) {
      appLogger.error('Error saving user', error: e);
    }
  }

  /// جلب بيانات المستخدم
  Map<String, dynamic>? getUser() {
    try {
      final userJson = getString(keyUserData);
      if (userJson == null || userJson.isEmpty) return null;
      return jsonDecode(userJson);
    } catch (e) {
      appLogger.error('Error getting user', error: e);
      return null;
    }
  }

  /// حفظ حالة تسجيل الدخول
  Future<void> saveIsLoggedIn(bool isLoggedIn) async {
    await setBool(keyIsLoggedIn, isLoggedIn);
  }

  /// الحصول على حالة تسجيل الدخول
  bool getIsLoggedIn() {
    return getBool(keyIsLoggedIn);
  }

  /// مسح بيانات المستخدم
  Future<void> clearUserData() async {
    try {
      await remove(keyUserData);
      await remove(keyIsLoggedIn);
      await clearSession();
      await clearCache();
      appLogger.warning('🗑️ User data cleared');
    } catch (e) {
      appLogger.error('Error clearing user data', error: e);
    }
  }

  // ==================== Settings Shortcuts ====================

  /// حفظ اللغة
  Future<void> saveLanguage(String language) async {
    await setString(keyLanguage, language);
    await saveSetting(keyLanguage, language);
  }

  /// جلب اللغة
  String getLanguage() {
    return getString(keyLanguage, defaultValue: 'fr') ?? 'fr';
  }

  /// حفظ التيم
  Future<void> saveThemeMode(String themeMode) async {
    await setString(keyThemeMode, themeMode);
    await saveSetting(keyThemeMode, themeMode);
  }

  /// جلب التيم
  String getThemeMode() {
    return getString(keyThemeMode, defaultValue: 'system') ?? 'system';
  }

  /// حفظ حالة المرة الأولى
  Future<void> saveFirstTime(bool isFirstTime) async {
    await setBool(keyFirstTime, isFirstTime);
  }

  /// هل هذه المرة الأولى؟
  bool isFirstTime() {
    return getBool(keyFirstTime, defaultValue: true);
  }

  /// حفظ إعدادات الإشعارات
  Future<void> saveNotificationsEnabled(bool enabled) async {
    await setBool(keyNotificationsEnabled, enabled);
    await saveSetting(keyNotificationsEnabled, enabled);
  }

  /// هل الإشعارات مفعلة؟
  bool areNotificationsEnabled() {
    return getBool(keyNotificationsEnabled, defaultValue: true);
  }

  /// حفظ إعدادات الموقع
  Future<void> saveLocationEnabled(bool enabled) async {
    await setBool(keyLocationEnabled, enabled);
    await saveSetting(keyLocationEnabled, enabled);
  }

  /// هل الموقع مفعل؟
  bool isLocationEnabled() {
    return getBool(keyLocationEnabled, defaultValue: false);
  }

  /// حفظ المزامنة التلقائية
  Future<void> saveAutoSync(bool enabled) async {
    await setBool(keyAutoSync, enabled);
    await saveSetting(keyAutoSync, enabled);
  }

  /// هل المزامنة التلقائية مفعلة؟
  bool isAutoSyncEnabled() {
    return getBool(keyAutoSync, defaultValue: true);
  }

  /// حفظ حجم الخط
  Future<void> saveFontSize(double fontSize) async {
    await setDouble(keyFontSize, fontSize);
    await saveSetting(keyFontSize, fontSize);
  }

  /// جلب حجم الخط
  double getFontSize() {
    return getDouble(keyFontSize, defaultValue: 16.0);
  }

  /// حفظ آخر مزامنة
  Future<void> saveLastSync(DateTime dateTime) async {
    await setString(keyLastSync, dateTime.toIso8601String());
  }

  /// جلب آخر مزامنة
  DateTime? getLastSync() {
    final lastSyncStr = getString(keyLastSync);
    if (lastSyncStr == null) return null;
    try {
      return DateTime.parse(lastSyncStr);
    } catch (e) {
      return null;
    }
  }

  // ==================== Statistics ====================

  /// إحصائيات التخزين
  Map<String, dynamic> getStorageStats() {
    return {
      'prefs_keys': _prefs.getKeys().length,
      'cache_items': _cacheBox.length,
      'queue_items': _queueBox.length,
      'session_items': _sessionBox.length,
      'settings_items': _settingsBox.length,
      'total_items':
          _prefs.getKeys().length +
          _cacheBox.length +
          _queueBox.length +
          _sessionBox.length +
          _settingsBox.length,
    };
  }

  /// طباعة الإحصائيات
  void printStats() {
    final stats = getStorageStats();
    appLogger.info('📊 Storage Statistics:');
    appLogger.info('  SharedPreferences: ${stats['prefs_keys']} keys');
    appLogger.info('  Cache: ${stats['cache_items']} items');
    appLogger.info('  Queue: ${stats['queue_items']} items');
    appLogger.info('  Session: ${stats['session_items']} items');
    appLogger.info('  Settings: ${stats['settings_items']} items');
    appLogger.info('  Total: ${stats['total_items']} items');
  }

  // ==================== Cleanup ====================

  /// تنظيف الـ Cache المنتهي
  Future<int> cleanupExpiredCache() async {
    try {
      int removed = 0;
      final keys = _cacheBox.keys.toList();

      for (final key in keys) {
        final data = _cacheBox.get(key);
        if (data != null && data['ttl'] != null) {
          final timestamp = data['timestamp'] as int;
          final ttl = data['ttl'] as int;
          final now = DateTime.now().millisecondsSinceEpoch;

          if (now - timestamp > ttl * 1000) {
            await _cacheBox.delete(key);
            removed++;
          }
        }
      }

      if (removed > 0) {
        appLogger.info('🗑️ Cleaned up $removed expired cache items');
      }
      return removed;
    } catch (e) {
      appLogger.error('Error cleaning cache', error: e);
      return 0;
    }
  }

  /// تنظيف Queue القديمة (أكثر من 7 أيام)
  Future<int> cleanupOldQueue() async {
    try {
      int removed = 0;
      final items = await getQueueItems();
      final cutoff = DateTime.now().subtract(Duration(days: 7));

      for (final item in items) {
        try {
          final createdAt = DateTime.parse(item['createdAt']);
          if (createdAt.isBefore(cutoff)) {
            await removeFromQueue(item['id']);
            removed++;
          }
        } catch (e) {
          // Skip invalid items
        }
      }

      if (removed > 0) {
        appLogger.info('🗑️ Cleaned up $removed old queue items');
      }
      return removed;
    } catch (e) {
      appLogger.error('Error cleaning queue', error: e);
      return 0;
    }
  }

  /// تنظيف شامل
  Future<void> performMaintenance() async {
    appLogger.info('🔧 Performing storage maintenance...');

    final cacheRemoved = await cleanupExpiredCache();
    final queueRemoved = await cleanupOldQueue();

    appLogger.info(
      '✅ Maintenance complete: '
      'Removed $cacheRemoved cache items and $queueRemoved queue items',
    );

    printStats();
  }

  // ==================== Complete Data Clearing ====================

  /// مسح جميع البيانات المخزنة (Cache + Storage)
  /// ⚠️ هذه العملية لا يمكن التراجع عنها!
  Future<bool> clearAllData() async {
    try {
      appLogger.warning('🗑️ Starting complete data clearing...');

      // 1. مسح SharedPreferences
      await clearAll();

      // 2. مسح جميع Hive boxes
      await clearCache();
      await clearQueue();
      await clearSession();
      await clearSettings();

      appLogger.info('✅ All local data cleared successfully');
      return true;
    } catch (e, stackTrace) {
      appLogger.error(
        'Error clearing all data',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// الحصول على حجم البيانات المخزنة (تقريبي)
  Map<String, int> getDataSize() {
    return {
      'prefs': _prefs.getKeys().length,
      'cache': _cacheBox.length,
      'queue': _queueBox.length,
      'session': _sessionBox.length,
      'settings': _settingsBox.length,
      'total':
          _prefs.getKeys().length +
          _cacheBox.length +
          _queueBox.length +
          _sessionBox.length +
          _settingsBox.length,
    };
  }

  // ==================== Disposal ====================

  /// إغلاق جميع الاتصالات
  Future<void> dispose() async {
    try {
      await _cacheBox.close();
      await _queueBox.close();
      await _sessionBox.close();
      await _settingsBox.close();
      appLogger.info('✅ StorageService disposed');
    } catch (e) {
      appLogger.error('Error disposing StorageService', error: e);
    }
  }
}
