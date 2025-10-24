import 'package:get/get.dart';
import '../controllers/sales_controller.dart';
import '../controllers/partner_controller.dart';

/// Binding لصفحات المبيعات
class SalesBinding extends Bindings {
  @override
  void dependencies() {
    // تسجيل SalesController كـ permanent للحفاظ عليه
    if (!Get.isRegistered<SalesController>()) {
      Get.put<SalesController>(SalesController(), permanent: true);
    }

    // تسجيل PartnerController كـ permanent للحفاظ عليه
    if (!Get.isRegistered<PartnerController>()) {
      Get.put<PartnerController>(PartnerController(), permanent: true);
    }
  }
}
