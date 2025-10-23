import 'package:get/get.dart';
import 'package:routy/screens/splash/splash_controller.dart';
import 'package:routy/controllers/user_controller.dart';
import 'package:routy/controllers/partner_controller.dart';

/// 🔗 Splash Binding
///
/// يهيئ جميع Dependencies المطلوبة لـ Splash Screen
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // SplashController - مباشر
    Get.put(SplashController(), permanent: false);

    // UserController - إذا لم يكن موجوداً
    if (!Get.isRegistered<UserController>()) {
      Get.put(UserController(), permanent: true);
    }

    // PartnerController - Lazy Load
    // سيتم تحميله فقط عند الحاجة
    Get.lazyPut(() => PartnerController(), fenix: true);
  }
}
