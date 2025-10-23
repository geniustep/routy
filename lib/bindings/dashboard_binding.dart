import 'package:get/get.dart';
import 'package:routy/controllers/dashboard_controller.dart';

/// 📊 Dashboard Binding
/// 
/// Initializes all dependencies needed for Dashboard Screen
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize DashboardController
    Get.lazyPut<DashboardController>(
      () => DashboardController(),
      fenix: true,
    );
  }
}
