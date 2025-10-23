import 'package:get/get.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dashboard/dashboard_v2_screen.dart';
import '../screens/sales/sales_list_screen.dart';
import '../screens/sales/sales_create_screen.dart';
import '../screens/delivery/delivery_list_screen.dart';
import '../screens/delivery/delivery_create_screen.dart';
import '../screens/customers/customers_list_screen.dart';
import '../screens/customers/customers_create_screen.dart';
import '../screens/partners/partners_screen.dart';
import '../screens/partners/partners_map_screen.dart';
import '../screens/partners/partner_details_screen.dart';
import '../models/partners/partner_type.dart';
import '../models/partners/partners_model.dart';
import '../screens/products/products_list_screen.dart';
import '../screens/products/products_create_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../bindings/partner_binding.dart';
import '../bindings/dashboard_binding.dart';

/// Application Router using GetX
class AppRouter {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String dashboardV2 = '/dashboard/v2';
  static const String salesList = '/sales';
  static const String salesCreate = '/sales/create';
  static const String deliveryList = '/delivery';
  static const String deliveryCreate = '/delivery/create';
  static const String customersList = '/customers';
  static const String customersCreate = '/customers/create';
  static const String partnersList = '/partners';
  static const String partnersCustomers = '/partners/customers';
  static const String partnersSuppliers = '/partners/suppliers';
  static const String partnersMap = '/partners/map';
  static const String partnerDetails = '/partners/details';
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
    GetPage(
      name: dashboardV2,
      page: () => const DashboardV2Screen(),
      binding: DashboardBinding(),
    ),
    GetPage(name: salesList, page: () => const SalesListScreen()),
    GetPage(name: salesCreate, page: () => const SalesCreateScreen()),
    GetPage(name: deliveryList, page: () => const DeliveryListScreen()),
    GetPage(name: deliveryCreate, page: () => const DeliveryCreateScreen()),
    GetPage(name: customersList, page: () => const CustomersListScreen()),
    GetPage(name: customersCreate, page: () => const CustomersCreateScreen()),
    GetPage(
      name: partnersList,
      page: () => const PartnersScreen(),
      binding: PartnerBinding(),
    ),
    GetPage(
      name: partnersCustomers,
      page: () => const PartnersScreen(initialFilter: PartnerType.customer),
      binding: PartnerBinding(),
    ),
    GetPage(
      name: partnersSuppliers,
      page: () => const PartnersScreen(initialFilter: PartnerType.supplier),
      binding: PartnerBinding(),
    ),
    GetPage(
      name: partnersMap,
      page: () => const PartnersMapScreen(),
      binding: PartnerBinding(),
    ),
    GetPage(
      name: partnerDetails,
      page: () {
        final partner = Get.arguments as PartnerModel;
        return PartnerDetailsScreen(partner: partner);
      },
      binding: PartnerBinding(),
    ),
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
