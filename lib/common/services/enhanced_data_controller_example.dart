import 'enhanced_data_controller.dart';
import '../../models/partners/partners_model.dart';
import '../../utils/app_logger.dart';

/// 📝 مثال على استخدام Enhanced DataController
///
/// يوضح كيفية استخدام المزايا المتقدمة
class EnhancedDataControllerExample {
  /// مثال: جلب الشركاء مع الصلاحيات
  static Future<void> fetchPartnersWithPermissions() async {
    await EnhancedDataController.getRecordsWithPermissions<PartnerModel>(
      model: 'res.partner',
      safeFields: [
        "id",
        "name",
        "active",
        "is_company",
        "email",
        "phone",
        "mobile",
        "street",
        "city",
        "zip",
        "country_id",
        "website",
        "display_name",
      ],
      adminFields: [
        "user_id",
        "create_uid",
        "write_uid",
        "company_id",
        "purchase_order_count",
        "sale_order_count",
        "total_invoiced",
        "credit",
        "customer_rank",
        "supplier_rank",
      ],
      userId: 1, // معرف المستخدم الحالي
      isAdmin: false, // صلاحيات المستخدم
      limit: 20,
      fromJson: (json) => PartnerModel.fromJson(json),
      onResponse: (partners) {
        appLogger.info('✅ Partners loaded: ${partners.length} items');
        for (var partner in partners) {
          appLogger.info('👤 ${partner.name} - ${partner.email}');
        }
      },
      cacheKey: 'partners_page_1',
      cacheTTL: 300, // 5 دقائق
    );
  }

  /// مثال: جلب شريك واحد مع الصلاحيات
  static Future<void> fetchSinglePartner() async {
    final partner =
        await EnhancedDataController.fetchRecordWithPermissions<PartnerModel>(
          model: 'res.partner',
          id: 123,
          userId: 1,
          isAdmin: false,
          fromJson: (json) => PartnerModel.fromJson(json),
        );

    if (partner != null) {
      appLogger.info('👤 Partner: ${partner.name}');
    } else {
      appLogger.warning('❌ Partner not found');
    }
  }

  /// مثال: جلب عدد الشركاء مع الصلاحيات
  static Future<void> getPartnersCount() async {
    final count = await EnhancedDataController.getRecordsCountWithPermissions(
      model: 'res.partner',
      userId: 1,
      isAdmin: false,
    );

    appLogger.info('📊 Total partners: $count');
  }

  /// مثال: جلب الشركاء مع البحث والفلترة
  static Future<void> fetchPartnersWithSearch() async {
    await EnhancedDataController.getRecordsWithPermissions<PartnerModel>(
      model: 'res.partner',
      domain: [
        ['name', 'ilike', 'أحمد'], // البحث في الأسماء
        ['is_company', '=', false], // العملاء الأفراد فقط
        ['active', '=', true], // النشطين فقط
      ],
      userId: 1,
      isAdmin: false,
      limit: 10,
      fromJson: (json) => PartnerModel.fromJson(json),
      onResponse: (partners) {
        appLogger.info('🔍 Search results: ${partners.length} partners');
      },
    );
  }

  /// مثال: جلب الشركاء مع Fallback Strategy
  static Future<void> fetchPartnersWithFallback() async {
    await EnhancedDataController.getRecordsWithPermissions<PartnerModel>(
      model: 'res.partner',
      safeFields: ["id", "name", "active", "email", "phone"],
      adminFields: [
        "user_id",
        "create_uid",
        "purchase_order_count",
        "sale_order_count",
      ],
      userId: 1,
      isAdmin: true, // محاولة مع الحقول الكاملة
      limit: 20,
      fromJson: (json) => PartnerModel.fromJson(json),
      onResponse: (partners) {
        appLogger.info(
          '✅ Partners loaded with fallback: ${partners.length} items',
        );
      },
      enableFallback: true, // تفعيل Fallback Strategy
    );
  }

  /// مثال: جلب الشركاء مع التخزين المؤقت
  static Future<void> fetchPartnersWithCache() async {
    await EnhancedDataController.getRecordsWithPermissions<PartnerModel>(
      model: 'res.partner',
      userId: 1,
      isAdmin: false,
      limit: 50,
      fromJson: (json) => PartnerModel.fromJson(json),
      onResponse: (partners) {
        appLogger.info('💾 Cached partners: ${partners.length} items');
      },
      cacheKey: 'partners_all',
      cacheTTL: 600, // 10 دقائق
    );
  }
}
