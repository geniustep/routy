import 'dart:convert';
import 'package:get/get.dart';
import '../common/models/user_model.dart';
import '../services/storage_service.dart';
import 'app_logger.dart';

/// PrefUtils - مساعدات للتخزين والوصول السريع
/// نمط مشابه للمشروع القديم مع تحسينات
class PrefUtils {
  PrefUtils._();

  // ==================== Observable Variables ====================

  static final user = Rx<UserModel?>(null);
  static final products = <dynamic>[].obs;
  static final customers = <dynamic>[].obs;
  static final sales = <dynamic>[].obs;
  static final deliveries = <dynamic>[].obs;

  // ==================== User Management ====================

  /// حفظ Token
  static Future<void> setToken(String token) async {
    try {
      await StorageService.instance.setString('user_token', token);
      appLogger.storage('Set Token', key: 'user_token');
    } catch (e, stackTrace) {
      appLogger.error('Error saving token', error: e, stackTrace: stackTrace);
    }
  }

  /// جلب Token
  static String? getToken() {
    try {
      return StorageService.instance.getString('user_token');
    } catch (e, stackTrace) {
      appLogger.error('Error loading token', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// حفظ User
  static Future<void> setUser(UserModel userModel) async {
    try {
      final userJson = jsonEncode(userModel.toJson());
      await StorageService.instance.setString('user_data', userJson);
      user.value = userModel;
      appLogger.storage('Set User', key: 'user_data');
    } catch (e, stackTrace) {
      appLogger.error('Error saving user', error: e, stackTrace: stackTrace);
    }
  }

  /// جلب User
  static Future<UserModel?> getUser() async {
    try {
      final userJson = StorageService.instance.getString('user_data');
      if (userJson == null || userJson.isEmpty) {
        user.value = null;
        return null;
      }

      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      user.value = UserModel.fromJson(userData);
      return user.value;
    } catch (e, stackTrace) {
      appLogger.error('Error loading user', error: e, stackTrace: stackTrace);
      user.value = null;
      return null;
    }
  }

  // ==================== Generic Model Storage ====================

  /// حفظ List من Models
  static Future<void> saveList<T>(
    String key,
    List<T> items,
    RxList<T> observable,
  ) async {
    try {
      observable.assignAll(items);

      final jsonString = jsonEncode(
        items.map((item) => (item as dynamic).toJson()).toList(),
      );

      await StorageService.instance.setString(key, jsonString);
      appLogger.storage('Save List', key: key, value: '${items.length} items');
    } catch (e, stackTrace) {
      appLogger.error('Error saving list', error: e, stackTrace: stackTrace);
    }
  }

  /// جلب List من Models
  static Future<List<T>> getList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final jsonString = StorageService.instance.getString(key);
      if (jsonString == null || jsonString.isEmpty) {
        return <T>[];
      }

      final decoded = jsonDecode(jsonString) as List<dynamic>;
      final items = decoded
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();

      appLogger.storage('Get List', key: key, value: '${items.length} items');
      return items;
    } catch (e, stackTrace) {
      appLogger.error('Error loading list', error: e, stackTrace: stackTrace);
      return <T>[];
    }
  }

  // ==================== Products ====================

  static Future<void> setProducts(List<dynamic> productList) async {
    await saveList('products', productList, products);
  }

  static Future<List<dynamic>> getProducts() async {
    return await getList('products', (json) => json);
  }

  // ==================== Customers ====================

  static Future<void> setCustomers(List<dynamic> customerList) async {
    await saveList('customers', customerList, customers);
  }

  static Future<List<dynamic>> getCustomers() async {
    return await getList('customers', (json) => json);
  }

  // ==================== Sales ====================

  static Future<void> setSales(List<dynamic> saleList) async {
    await saveList('sales', saleList, sales);
  }

  static Future<List<dynamic>> getSales() async {
    return await getList('sales', (json) => json);
  }

  // ==================== Deliveries ====================

  static Future<void> setDeliveries(List<dynamic> deliveryList) async {
    await saveList('deliveries', deliveryList, deliveries);
  }

  static Future<List<dynamic>> getDeliveries() async {
    return await getList('deliveries', (json) => json);
  }

  // ==================== Clear Data ====================

  /// مسح جميع البيانات
  static Future<void> clearAll() async {
    user.value = null;
    products.clear();
    customers.clear();
    sales.clear();
    deliveries.clear();

    appLogger.info('🧹 PrefUtils cleared');
  }
}
