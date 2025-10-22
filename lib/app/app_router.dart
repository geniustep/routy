import 'package:get/get.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/sales/sales_list_screen.dart';
import '../screens/sales/sales_create_screen.dart';
import '../screens/delivery/delivery_list_screen.dart';
import '../screens/delivery/delivery_create_screen.dart';
import '../screens/customers/customers_list_screen.dart';
import '../screens/customers/customers_create_screen.dart';
import '../screens/products/products_list_screen.dart';
import '../screens/products/products_create_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';

/// Application Router using GetX
class AppRouter {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String salesList = '/sales';
  static const String salesCreate = '/sales/create';
  static const String deliveryList = '/delivery';
  static const String deliveryCreate = '/delivery/create';
  static const String customersList = '/customers';
  static const String customersCreate = '/customers/create';
  static const String productsList = '/products';
  static const String productsCreate = '/products/create';
  static const String reports = '/reports';
  static const String settings = '/settings';

  /// Get all GetX pages
  static List<GetPage> get pages => [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: dashboard, page: () => const DashboardScreen()),
    GetPage(name: salesList, page: () => const SalesListScreen()),
    GetPage(name: salesCreate, page: () => const SalesCreateScreen()),
    GetPage(name: deliveryList, page: () => const DeliveryListScreen()),
    GetPage(name: deliveryCreate, page: () => const DeliveryCreateScreen()),
    GetPage(name: customersList, page: () => const CustomersListScreen()),
    GetPage(name: customersCreate, page: () => const CustomersCreateScreen()),
    GetPage(name: productsList, page: () => const ProductsListScreen()),
    GetPage(name: productsCreate, page: () => const ProductsCreateScreen()),
    GetPage(name: reports, page: () => const ReportsScreen()),
    GetPage(name: settings, page: () => const SettingsScreen()),
  ];

  /// Navigate to route
  static Future<dynamic>? navigateTo(String route) {
    return Get.toNamed(route);
  }

  /// Navigate and replace current route
  static Future<dynamic>? navigateAndReplace(String route) {
    return Get.offNamed(route);
  }

  /// Navigate and clear stack
  static Future<dynamic>? navigateAndClearStack(String route) {
    return Get.offAllNamed(route);
  }
}
