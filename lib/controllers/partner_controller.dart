// lib/src/presentation/screens/sales/saleorder/create/controllers/partner_controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:routy/models/partners/partners_model.dart';
import 'package:routy/models/products/product_list/pricelist_model.dart';
import 'package:routy/utils/pref_utils.dart';
import 'package:routy/controllers/partner_controller.dart' as main_partner;
import 'package:routy/common/api/api.dart';

class PartnerController extends GetxController {
  // ============= State =============

  final Rxn<PartnerModel> selectedPartner = Rxn<PartnerModel>();
  final Rxn<PricelistModel> selectedPriceList = Rxn<PricelistModel>();
  final RxnInt selectedPaymentTermId = RxnInt();
  final RxList<PricelistModel> partnerPriceLists = <PricelistModel>[].obs;
  final RxList<PartnerModel> partners = <PartnerModel>[].obs;
  final RxList<PricelistModel> allPriceLists = <PricelistModel>[].obs;
  final RxList<dynamic> paymentTerms = <dynamic>[].obs;
  final Rxn<DateTime> deliveryDate = Rxn<DateTime>();
  final RxBool showDeliveryDate = false.obs;

  // Admin flag
  bool get isAdmin => PrefUtils.user.value?.isAdmin ?? false;

  // ============= Lifecycle =============

  @override
  void onInit() {
    super.onInit();
    // تهيئة إضافية إذا لزم الأمر
    if (kDebugMode) {
      debugPrint('PartnerController initialized');
    }

    // تحميل الشركاء عند التهيئة
    fetchPartners();
  }

  // ============= Initialization =============

  void initialize({PartnerModel? preSelectedPartner}) {
    // استخدام main PartnerController للحصول على البيانات
    final mainPartnerController = Get.find<main_partner.PartnerController>();

    partners.value = preSelectedPartner != null
        ? [preSelectedPartner]
        : mainPartnerController.partners.toList();

    allPriceLists.value = []; // سيتم تحميلها لاحقاً
    paymentTerms.value = []; // سيتم تحميلها لاحقاً

    if (preSelectedPartner != null) {
      selectPartner(preSelectedPartner.id ?? 0);
    }
  }

  // ============= Partner Management =============

  void selectPartner(int partnerId) {
    try {
      // ✅ التحقق من وجود الشركاء
      if (partners.isEmpty) {
        final mainPartnerController =
            Get.find<main_partner.PartnerController>();
        partners.value = mainPartnerController.partners.toList();
      }

      // ✅ التحقق من وجود قوائم الأسعار
      if (allPriceLists.isEmpty) {
        // سيتم تحميلها لاحقاً
        allPriceLists.value = [];
      }

      final partner = partners.firstWhere((p) => p.id == partnerId);
      selectedPartner.value = partner;

      // تحميل قوائم الأسعار الخاصة بالشريك
      _loadPartnerPriceLists(partner);

      if (kDebugMode) {
        print('✅ Partner selected: ${partner.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error selecting partner: $e');
        print('   Available partners: ${partners.length}');
        print('   Partner IDs: ${partners.map((p) => p.id).toList()}');
      }
    }
  }

  void _loadPartnerPriceLists(PartnerModel partner) {
    try {
      if (kDebugMode) {
        print('\n💰 Loading price lists for partner: ${partner.name}');
        print('   Is Admin: $isAdmin');
      }

      // ✅ التحقق من وجود قوائم أسعار متاحة
      if (allPriceLists.isEmpty) {
        if (kDebugMode) {
          print('   ⚠️ No price lists available - hiding section');
        }
        partnerPriceLists.clear(); // إفراغ القائمة
        selectedPriceList.value = null; // إلغاء التحديد
        update(); // ✅ تحديث GetBuilder
        return; // إنهاء الدالة مبكراً
      }

      // ✅ فحص إذا كانت الشركة تستخدم قوائم الأسعار
      if (!_shouldUsePriceLists(partner)) {
        if (kDebugMode) {
          print('   ⚠️ Company does not use price lists - skipping');
        }
        partnerPriceLists.clear();
        selectedPriceList.value = null;
        update(); // ✅ تحديث GetBuilder
        return;
      }

      // إذا كان المستخدم Admin، يحصل على جميع القوائم
      if (isAdmin) {
        partnerPriceLists.value = allPriceLists.toList();

        if (kDebugMode) {
          print(
            '   ✅ Admin: All price lists available (${partnerPriceLists.length})',
          );
        }

        _selectDefaultPriceList(partner);
        update(); // ✅ تحديث GetBuilder
        return;
      }

      // للمستخدمين العاديين: تحديد قائمة الأسعار من بيانات الشريك
      // استخدام حقل بديل أو إعداد افتراضي

      // محاولة الحصول على معرف قائمة الأسعار من بيانات الشريك
      // يمكن إضافة منطق مخصص هنا

      // للآن، لا يوجد قائمة أسعار محددة
      // سيتم إضافة منطق مخصص هنا لاحقاً

      if (kDebugMode) {
        print('   ⚠️ No price list logic implemented yet');
      }
      partnerPriceLists.clear();
      selectedPriceList.value = null;
      update(); // ✅ تحديث GetBuilder
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading partner price lists: $e');
      }
      // ✅ في حالة الخطأ، إخفاء القسم
      partnerPriceLists.clear();
      selectedPriceList.value = null;
    }
  }

  void _selectDefaultPriceList(PartnerModel partner) {
    if (partnerPriceLists.isEmpty) return;

    // محاولة العثور على قائمة الأسعار الخاصة بالشريك
    // يمكن إضافة منطق مخصص هنا للحصول على معرف قائمة الأسعار

    // تحديد قائمة الأسعار
    // سيتم إضافة منطق مخصص هنا لاحقاً

    // إذا لم يتم العثور على قائمة محددة، اختر الأولى
    selectPriceList(partnerPriceLists.first.id);
  }

  // ============= Price List Management =============

  void selectPriceList(dynamic priceListId) {
    if (priceListId == null) {
      selectedPriceList.value = null;
      if (kDebugMode) {
        print('   Price list cleared');
      }
      return;
    }

    try {
      final priceList = allPriceLists.firstWhere((p) => p.id == priceListId);
      selectedPriceList.value = priceList;

      if (kDebugMode) {
        print('\n💰 Price list selected:');
        print('   Name: ${priceList.name}');
        print('   ID: $priceListId');
        print('   Items: ${priceList.items?.length ?? 0}');

        // طباعة بعض الأمثلة على القواعد
        if (priceList.items != null && priceList.items!.isNotEmpty) {
          print('   Sample rules:');
          for (
            var i = 0;
            i < (priceList.items!.length > 3 ? 3 : priceList.items!.length);
            i++
          ) {
            final item = priceList.items![i];
            print(
              '     Rule ${i + 1}: Product ${item.productTmplId}, '
              'Min Qty: ${item.minQuantity}, '
              'Fixed Price: ${item.price}, '
              'Discount: ${item.priceDiscount}%',
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error selecting price list: $e');
      }
    }
  }

  // ============= Payment Terms Management =============

  void selectPaymentTerm(dynamic paymentTermId) {
    selectedPaymentTermId.value = paymentTermId;
    if (kDebugMode) {
      print('💳 Payment term selected: $paymentTermId');
    }
  }

  // ============= Delivery Date Management =============

  void toggleDeliveryDate(bool show) {
    showDeliveryDate.value = show;
    if (!show) {
      deliveryDate.value = null;
    }
    if (kDebugMode) {
      print('📅 Delivery date ${show ? "enabled" : "disabled"}');
    }
  }

  void setDeliveryDate(DateTime? date) {
    deliveryDate.value = date;
    if (kDebugMode) {
      print('📅 Delivery date set: ${date?.toIso8601String() ?? "null"}');
    }
  }

  // ============= Validation =============

  bool validateFormData() {
    if (kDebugMode) {
      print('\n🔍 Validating form data...');
    }

    if (selectedPartner.value == null) {
      if (kDebugMode) {
        print('❌ No partner selected');
      }
      return false;
    }

    if (kDebugMode) {
      debugPrint('✅ Form data validated');
      debugPrint('   Partner: ${selectedPartner.value!.name}');
      debugPrint('   Price List: ${selectedPriceList.value?.name ?? "None"}');
      debugPrint('   Payment Term: ${selectedPaymentTermId.value ?? "None"}');
      debugPrint(
        '   Delivery Date: ${deliveryDate.value?.toIso8601String() ?? "None"}',
      );
    }

    return true;
  }

  // ============= Data Retrieval =============

  Map<String, dynamic> getFormData() {
    final data = <String, dynamic>{
      'partner_id': selectedPartner.value?.id,
      'pricelist_id': selectedPriceList.value?.id,
      'payment_term_id': selectedPaymentTermId.value,
    };

    if (showDeliveryDate.value && deliveryDate.value != null) {
      data['commitment_date'] = deliveryDate.value;
    }

    if (kDebugMode) {
      debugPrint('\n📋 Form data:');
      data.forEach((key, value) {
        debugPrint('   $key: $value');
      });
    }

    return data;
  }

  void loadFromDraft({
    dynamic partnerId,
    dynamic priceListId,
    dynamic paymentTermId,
  }) {
    if (kDebugMode) {
      print('\n📥 Loading partner data from draft...');
      print('   Partner ID: $partnerId');
      print('   Price List ID: $priceListId');
      print('   Payment Term ID: $paymentTermId');
    }

    if (partnerId != null) {
      selectPartner(partnerId);
    }

    if (priceListId != null) {
      selectPriceList(priceListId);
    }

    if (paymentTermId != null) {
      selectPaymentTerm(paymentTermId);
    }

    if (kDebugMode) {
      print('✅ Partner data loaded from draft');
    }
  }

  // ============= Reset =============

  void reset() {
    if (kDebugMode) {
      print('\n🔄 Resetting PartnerController...');
    }

    selectedPartner.value = null;
    selectedPriceList.value = null;
    selectedPaymentTermId.value = null;
    partnerPriceLists.clear();
    deliveryDate.value = null;
    showDeliveryDate.value = false;

    if (kDebugMode) {
      print('✅ PartnerController reset');
    }
  }

  // ============= Getters =============

  bool get hasPartner => selectedPartner.value != null;
  dynamic get partnerId => selectedPartner.value?.id;
  String? get partnerName => selectedPartner.value?.name;
  dynamic get priceListId => selectedPriceList.value?.id;
  dynamic get paymentTermId => selectedPaymentTermId.value;

  // ✅ إضافة getter جديد للتحقق من وجود قوائم أسعار
  bool get hasPriceLists => partnerPriceLists.isNotEmpty;

  // ============= Price List Configuration =============

  /// التحقق من إذا كانت الشركة تستخدم قوائم الأسعار
  bool _shouldUsePriceLists(PartnerModel partner) {
    // ✅ يمكن إضافة منطق للتحقق من إعدادات الشركة
    // مثلاً: التحقق من حقل في بيانات الشركة أو إعدادات النظام

    // للآن، نستخدم إعداد افتراضي
    if (kDebugMode) {
      print('   ⚠️ Using default price list logic');
    }

    // ✅ يمكن إضافة المزيد من الشروط هنا
    // مثلاً: التحقق من إعدادات الشركة
    return true;
  }

  /// التحقق من إذا كان يجب إرسال pricelist_id للخادم
  bool get shouldSendPriceListId {
    return selectedPriceList.value != null && hasPriceLists;
  }

  // إضافة الطرق المفقودة
  Future<void> loadFromLocal() async {
    // TODO: تحميل البيانات من التخزين المحلي
  }

  Future<void> fetchPartners() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // جلب الشركاء من API مع معالجة الأخطاء
      await Api.searchRead(
        model: 'res.partner',
        fields: [
          'id',
          'name',
          'display_name',
          'email',
          'phone',
          'mobile',
          'street',
          'city',
          'zip',
          'country_id',
          'state_id',
          'is_company',
          'customer_rank',
          'supplier_rank',
          'active',
          'image_1920',
          'category_id',
          'parent_id',
          'child_ids',
          'property_account_position_id',
          'property_payment_term_id',
          'property_product_pricelist',
          'property_supplier_payment_term_id',
          'property_account_payable_id',
          'property_account_receivable_id',
          'comment',
          'website',
          'function',
          'title',
          'lang',
          'tz',
          'user_id',
          'create_date',
          'write_date',
        ],
        domain: [
          ['active', '=', true],
        ],
        limit: 1000,
        order: 'name ASC',
        onResponse: (data) {
          if (data != null) {
            final List<dynamic> partnersData = data;
            partners.value = partnersData
                .map((json) => PartnerModel.fromJson(json))
                .toList();

            // تطبيق الفلاتر
            _applyFilters();

            if (kDebugMode) {
              print('✅ Partners loaded: ${partners.length}');
            }
          }
        },
        onError: (message, data) {
          // معالجة الأخطاء مثل SalesController
          if (message.contains('Invalid field')) {
            // إزالة الحقول غير الموجودة وإعادة المحاولة
            _retryWithReducedFields();
          } else {
            _errorMessage.value = 'Error loading partners: $message';
            if (kDebugMode) {
              print('❌ Error loading partners: $message');
            }
          }
        },
      );
    } catch (e) {
      _errorMessage.value = 'Error loading partners: $e';
      if (kDebugMode) {
        print('❌ Error loading partners: $e');
      }
    } finally {
      _isLoading.value = false;
    }
  }

  // إعادة المحاولة مع حقول أقل
  Future<void> _retryWithReducedFields() async {
    try {
      if (kDebugMode) {
        print('🔄 Retrying with reduced fields...');
      }

      await Api.searchRead(
        model: 'res.partner',
        fields: [
          'id',
          'name',
          'display_name',
          'email',
          'phone',
          'mobile',
          'street',
          'city',
          'zip',
          'country_id',
          'state_id',
          'is_company',
          'customer_rank',
          'supplier_rank',
          'active',
          'image_1920',
          'category_id',
          'parent_id',
          'child_ids',
          'comment',
          'website',
          'function',
          'title',
          'lang',
          'tz',
          'user_id',
          'create_date',
          'write_date',
        ],
        domain: [
          ['active', '=', true],
        ],
        limit: 1000,
        order: 'name ASC',
        onResponse: (data) {
          if (data != null) {
            final List<dynamic> partnersData = data;
            partners.value = partnersData
                .map((json) => PartnerModel.fromJson(json))
                .toList();

            // تطبيق الفلاتر
            _applyFilters();

            if (kDebugMode) {
              print(
                '✅ Partners loaded with reduced fields: ${partners.length}',
              );
            }
          }
        },
        onError: (message, data) {
          _errorMessage.value = 'Error loading partners: $message';
          if (kDebugMode) {
            print('❌ Error loading partners with reduced fields: $message');
          }
        },
      );
    } catch (e) {
      _errorMessage.value = 'Error loading partners: $e';
      if (kDebugMode) {
        print('❌ Error loading partners with reduced fields: $e');
      }
    }
  }

  int get totalCount => partners.length;
  int get customersCount => partners.where((p) => p.isCustomer).length;
  int get suppliersCount => partners.where((p) => p.isSupplier).length;
  List<PartnerModel> get vipPartners => partners
      .where((p) => p.customerRank != null && p.customerRank! > 0)
      .toList();
  List<PartnerModel> get activePartners =>
      partners.where((p) => p.active == true).toList();

  // إضافة خصائص الفلترة
  final RxString _currentTypeFilter = 'all'.obs;
  String get currentTypeFilter => _currentTypeFilter.value;

  final RxList<PartnerModel> _filteredPartners = <PartnerModel>[].obs;
  List<PartnerModel> get filteredPartners => _filteredPartners;

  final RxString _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  // إضافة طرق الفلترة والبحث
  void filterByType(String type) {
    _currentTypeFilter.value = type;
    _applyFilters();
  }

  void searchPartners(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = partners.toList();

    // فلتر النوع
    if (_currentTypeFilter.value != 'all') {
      if (_currentTypeFilter.value == 'customer') {
        filtered = filtered.where((p) => p.isCustomer).toList();
      } else if (_currentTypeFilter.value == 'supplier') {
        filtered = filtered.where((p) => p.isSupplier).toList();
      }
    }

    // فلتر البحث
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered
          .where(
            (p) =>
                p.displayName.toLowerCase().contains(query) ||
                (p.email?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    _filteredPartners.value = filtered;
  }
}
