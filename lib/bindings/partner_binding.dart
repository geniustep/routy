import 'package:get/get.dart';
import 'package:routy/controllers/partner_controller.dart';

/// 🔗 Partner Binding
///
/// يقوم بتسجيل PartnerController عند الحاجة
///
/// الاستخدام:
/// ```dart
/// GetPage(
///   name: '/partners',
///   page: () => PartnersListScreen(),
///   binding: PartnerBinding(),
/// )
/// ```
class PartnerBinding extends Bindings {
  @override
  void dependencies() {
    // التحقق من وجود Controller قبل إنشائه
    if (!Get.isRegistered<PartnerController>()) {
      Get.put<PartnerController>(
        PartnerController(),
        permanent: true, // يبقى في الذاكرة
      );
    }
  }
}

/// 🔗 Partner Binding (Put مباشر)
///
/// يقوم بتسجيل PartnerController مباشرة
class PartnerBindingPut extends Bindings {
  @override
  void dependencies() {
    // Put - يتم تحميله مباشرة
    Get.put<PartnerController>(
      PartnerController(),
      permanent: true, // دائم في الذاكرة
    );
  }
}
