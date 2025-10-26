// lib/screens/sales/saleorder/create/controllers/partner_controller.dart

import 'package:get/get.dart';
import 'package:routy/models/partners/partners_model.dart';
import 'package:routy/models/products/product_list/pricelist_model.dart';
import 'package:routy/models/common/payment_term_model.dart';
import 'package:routy/utils/app_logger.dart';
import 'package:routy/controllers/partner_controller.dart';
import 'package:routy/common/api/api.dart';

/// 👤 Sales Partner Controller - تحكم في العملاء والشركاء للمبيعات
///
/// يدير:
/// - اختيار العميل
/// - قوائم الأسعار
/// - شروط الدفع
/// - تواريخ التسليم
class SalesPartnerController extends GetxController {
  // ============= State =============

  final RxList<PartnerModel> partners = <PartnerModel>[].obs;
  final Rx<PartnerModel?> selectedPartner = Rx<PartnerModel?>(null);
  final RxList<PricelistModel> allPriceLists = <PricelistModel>[].obs;
  final RxList<PricelistModel> partnerPriceLists = <PricelistModel>[].obs;
  final Rx<PricelistModel?> selectedPriceList = Rx<PricelistModel?>(null);
  final RxList<PaymentTermModel> paymentTerms = <PaymentTermModel>[].obs;
  final Rx<PaymentTermModel?> selectedPaymentTerm = Rx<PaymentTermModel?>(null);

  // Delivery Date
  final RxBool showDeliveryDate = false.obs;
  final Rx<DateTime?> deliveryDate = Rx<DateTime?>(null);

  // ============= Lifecycle =============

  @override
  void onInit() {
    super.onInit();
    appLogger.info('✅ PartnerController initialized');
  }

  @override
  void onClose() {
    appLogger.info('🗑️ PartnerController disposed');
    super.onClose();
  }

  // ============= Initialization =============

  void initialize({PartnerModel? preSelectedPartner}) {
    appLogger.info('📦 PartnerController initializing...');

    if (preSelectedPartner != null) {
      selectPartner(preSelectedPartner.id!);
      appLogger.info('   Pre-selected partner: ${preSelectedPartner.name}');
    }

    // تحميل العملاء
    loadPartners();

    appLogger.info('✅ PartnerController initialized');
  }

  /// تحميل قائمة العملاء من السيرفر
  Future<void> loadPartners() async {
    try {
      appLogger.info('📋 Loading partners from server...');

      // استخدام PartnerController الموجود للحصول على العملاء
      final partnerController = Get.find<PartnerController>();

      // نسخ العملاء من PartnerController
      partners.value = partnerController.partners.toList();

      appLogger.info('✅ Partners loaded: ${partners.length} partners');
    } catch (e) {
      appLogger.error('❌ Error loading partners: $e');
      partners.value = [];
    }
  }

  // ============= Partner Management =============

  void selectPartner(int partnerId) {
    try {
      final partner = partners.firstWhere((p) => p.id == partnerId);
      selectedPartner.value = partner;

      // تحديث قوائم الأسعار الخاصة بالشريك
      _updatePartnerPriceLists(partner);

      appLogger.info('✅ Partner selected: ${partner.name}');
      appLogger.info('   Partner ID: ${partner.id}');
      appLogger.info('   Available price lists: ${partnerPriceLists.length}');
    } catch (e) {
      appLogger.error('❌ Partner not found with ID: $partnerId');
      appLogger.error(
        '   Available partners: ${partners.map((p) => p.id).toList()}',
      );
    }
  }

  void _updatePartnerPriceLists(PartnerModel partner) {
    try {
      appLogger.info('📋 Loading price lists for partner: ${partner.name}');

      // جلب قوائم الأسعار الخاصة بالشريك من API
      _loadPartnerPriceListsFromAPI(partner);
    } catch (e) {
      appLogger.error('❌ Error loading partner price lists: $e');
      // في حالة الخطأ، استخدام قوائم الأسعار العامة
      partnerPriceLists.value = allPriceLists.toList();
    }
  }

  /// جلب قوائم الأسعار الخاصة بالشريك من API
  Future<void> _loadPartnerPriceListsFromAPI(PartnerModel partner) async {
    try {
      // جلب قوائم الأسعار الخاصة بالشريك
      await Api.searchRead(
        model: 'product.pricelist',
        fields: [
          'id',
          'name',
          'display_name',
          'active',
          'currency_id',
          'country_group_ids',
          'item_ids',
        ],
        domain: [
          ['active', '=', true],
          '|',
          ['partner_ids', '=', partner.id],
          ['partner_ids', '=', false], // قوائم الأسعار العامة
        ],
        limit: 100,
        order: 'name ASC',
        onResponse: (data) {
          if (data != null) {
            final List<dynamic> priceListsData = data;
            partnerPriceLists.value = priceListsData
                .map((json) => PricelistModel.fromJson(json))
                .toList();

            // تحديد قائمة الأسعار الافتراضية للشريك
            _setDefaultPriceList(partner);

            appLogger.info(
              '✅ Partner price lists loaded: ${partnerPriceLists.length}',
            );
          }
        },
        onError: (message, data) {
          appLogger.error('❌ Error loading partner price lists: $message');
          // في حالة الخطأ، استخدام قوائم الأسعار العامة
          partnerPriceLists.value = allPriceLists.toList();
        },
      );
    } catch (e) {
      appLogger.error('❌ Error loading partner price lists: $e');
      // في حالة الخطأ، استخدام قوائم الأسعار العامة
      partnerPriceLists.value = allPriceLists.toList();
    }
  }

  /// تحديد قائمة الأسعار الافتراضية للشريك
  void _setDefaultPriceList(PartnerModel partner) {
    try {
      // استخدام أول قائمة أسعار متاحة للشريك
      if (partnerPriceLists.isNotEmpty) {
        selectedPriceList.value = partnerPriceLists.first;
        appLogger.info(
          '✅ Default price list set: ${partnerPriceLists.first.name}',
        );
        appLogger.info('   Available price lists: ${partnerPriceLists.length}');
      } else {
        appLogger.warning(
          '⚠️ No price lists available for partner: ${partner.name}',
        );
      }
    } catch (e) {
      appLogger.error('❌ Error setting default price list: $e');
    }
  }

  // ============= Price List Management =============

  void selectPriceList(int? priceListId) {
    if (priceListId == null) {
      selectedPriceList.value = null;
      appLogger.info('📋 Price list cleared');
      return;
    }

    try {
      final priceList = allPriceLists.firstWhere((p) => p.id == priceListId);
      selectedPriceList.value = priceList;

      appLogger.info('✅ Price list selected: ${priceList.name}');
      appLogger.info('   Price list ID: ${priceList.id}');
    } catch (e) {
      appLogger.error('❌ Price list not found with ID: $priceListId');
      appLogger.error(
        '   Available price lists: ${allPriceLists.map((p) => p.id).toList()}',
      );
    }
  }

  // ============= Payment Terms Management =============

  void selectPaymentTerm(int? paymentTermId) {
    if (paymentTermId == null) {
      selectedPaymentTerm.value = null;
      appLogger.info('💳 Payment term cleared');
      return;
    }

    try {
      final paymentTerm = paymentTerms.firstWhere((p) => p.id == paymentTermId);
      selectedPaymentTerm.value = paymentTerm;

      appLogger.info('✅ Payment term selected: ${paymentTerm.name}');
      appLogger.info('   Payment term ID: ${paymentTerm.id}');
    } catch (e) {
      appLogger.error('❌ Payment term not found with ID: $paymentTermId');
      appLogger.error(
        '   Available payment terms: ${paymentTerms.map((p) => p.id).toList()}',
      );
    }
  }

  // ============= Delivery Date Management =============

  void toggleDeliveryDate(bool show) {
    showDeliveryDate.value = show;

    if (!show) {
      deliveryDate.value = null;
    }

    appLogger.info('📅 Delivery date toggled: $show');
  }

  void setDeliveryDate(DateTime? date) {
    deliveryDate.value = date;
    appLogger.info('📅 Delivery date set: $date');
  }

  // ============= Data Retrieval =============

  Map<String, dynamic> getFormData() {
    final data = <String, dynamic>{
      'partner_id': selectedPartner.value?.id,
      'pricelist_id': selectedPriceList.value?.id,
      'payment_term_id': selectedPaymentTerm.value?.id,
    };

    if (showDeliveryDate.value && deliveryDate.value != null) {
      data['commitment_date'] = deliveryDate.value!.toIso8601String();
    }

    appLogger.info('📋 Form data prepared:');
    appLogger.info('   Partner ID: ${data['partner_id']}');
    appLogger.info('   Price List ID: ${data['pricelist_id']}');
    appLogger.info('   Payment Term ID: ${data['payment_term_id']}');
    appLogger.info('   Delivery Date: ${data['commitment_date']}');

    return data;
  }

  // ============= Validation =============

  bool get hasPartner => selectedPartner.value != null;
  bool get hasPriceLists => partnerPriceLists.isNotEmpty;
  bool get hasPaymentTerms => paymentTerms.isNotEmpty;

  bool get shouldSendPriceListId {
    // إرسال priceListId فقط إذا كان هناك شريك وقائمة أسعار
    return hasPartner && selectedPriceList.value != null;
  }

  // ============= Getters =============

  int? get partnerId => selectedPartner.value?.id;
  String? get partnerName => selectedPartner.value?.name;
  int? get priceListId => selectedPriceList.value?.id;
  String? get priceListName => selectedPriceList.value?.name;
  int? get paymentTermId => selectedPaymentTerm.value?.id;
  String? get paymentTermName => selectedPaymentTerm.value?.name;

  // ============= Clear Data =============

  void clearSelection() {
    selectedPartner.value = null;
    selectedPriceList.value = null;
    selectedPaymentTerm.value = null;
    showDeliveryDate.value = false;
    deliveryDate.value = null;
    partnerPriceLists.clear();

    appLogger.info('🗑️ Partner selection cleared');
  }

  void clearPriceList() {
    selectedPriceList.value = null;
    appLogger.info('🗑️ Price list cleared');
  }

  void clearPaymentTerm() {
    selectedPaymentTerm.value = null;
    appLogger.info('🗑️ Payment term cleared');
  }
}
