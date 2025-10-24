// lib/models/products/product_list/pricelist_model.dart

import 'package:json_annotation/json_annotation.dart';
import '../../base/base_model.dart';

part 'pricelist_model.g.dart';

/// 💰 Price List Model - نموذج قائمة الأسعار
///
/// يمثل product.pricelist في Odoo
/// يدعم:
/// - ✅ جميع حقول Odoo
/// - ✅ BaseModel (Sync, Timestamps)
/// - ✅ Getters ذكية
/// - ✅ json_serializable
@JsonSerializable(explicitToJson: true)
class PricelistModel extends BaseModel {
  // ==================== Basic Info ====================

  @JsonKey(name: 'name')
  final dynamic name; // اسم قائمة الأسعار

  @JsonKey(name: 'display_name')
  final dynamic displayName;

  @JsonKey(name: 'active')
  final dynamic active; // هل القائمة نشطة؟

  @JsonKey(name: 'currency_id')
  final dynamic currencyId; // العملة [id, name]

  // ==================== Pricing Rules ====================

  @JsonKey(name: 'item_ids')
  final dynamic itemIds; // قائمة قواعد الأسعار

  @JsonKey(name: 'items')
  final List<PricelistItemModel>? items; // قواعد الأسعار

  // ==================== Additional Fields ====================

  @JsonKey(name: 'company_id')
  final dynamic companyId; // الشركة [id, name]

  @JsonKey(name: 'country_group_ids')
  final dynamic countryGroupIds;

  @JsonKey(name: 'selectable')
  final dynamic selectable; // هل يمكن اختيارها؟

  @JsonKey(name: 'discount_policy')
  final dynamic discountPolicy; // سياسة الخصم

  @JsonKey(name: 'website_id')
  final dynamic websiteId;

  @JsonKey(name: 'code')
  final dynamic code; // كود القائمة

  @JsonKey(name: 'sequence')
  final dynamic sequence; // ترتيب القائمة

  const PricelistModel({
    super.id,
    super.odooId,
    super.createdAt,
    super.updatedAt,
    super.synced,
    super.syncStatus,
    this.name,
    this.displayName,
    this.active,
    this.currencyId,
    this.itemIds,
    this.items,
    this.companyId,
    this.countryGroupIds,
    this.selectable,
    this.discountPolicy,
    this.websiteId,
    this.code,
    this.sequence,
  });

  // ==================== Getters ====================

  /// اسم قائمة الأسعار
  String get pricelistName {
    if (name == null || name == false) return '';
    return name is String ? name as String : name.toString();
  }

  /// هل القائمة نشطة؟
  bool get isActive {
    if (active == null || active == false) return true;
    return active == true;
  }

  /// العملة
  String? get currencyName {
    if (currencyId == null || currencyId == false) return null;
    if (currencyId is List && (currencyId as List).length >= 2) {
      return (currencyId as List)[1].toString();
    }
    return null;
  }

  /// ID العملة
  int? get currencyIdInt {
    if (currencyId == null || currencyId == false) return null;
    if (currencyId is List && (currencyId as List).isNotEmpty) {
      return (currencyId as List)[0] is int ? (currencyId as List)[0] : null;
    }
    if (currencyId is int) return currencyId;
    return null;
  }

  /// عدد قواعد الأسعار
  int get rulesCount => items?.length ?? 0;

  /// هل تحتوي على قواعد؟
  bool get hasRules => rulesCount > 0;

  /// كود القائمة
  String? get pricelistCode {
    if (code == null || code == false) return null;
    if (code is String && (code as String).isNotEmpty) {
      return code as String;
    }
    return null;
  }

  /// ترتيب القائمة
  int get pricelistSequence {
    if (sequence == null || sequence == false) return 0;
    if (sequence is int) return sequence;
    return 0;
  }

  /// سياسة الخصم
  String get discountPolicyLabel {
    if (discountPolicy == null || discountPolicy == false)
      return 'with_discount';
    return discountPolicy.toString();
  }

  /// هل تظهر الخصومات؟
  bool get showDiscounts => discountPolicyLabel == 'with_discount';

  // ==================== Serialization ====================

  factory PricelistModel.fromJson(Map<String, dynamic> json) {
    final model = _$PricelistModelFromJson(json);
    return PricelistModel(
      id: model.id,
      odooId: model.odooId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      synced: model.synced,
      syncStatus: model.syncStatus,
      name: model.name,
      displayName: model.displayName,
      active: model.active,
      currencyId: model.currencyId,
      itemIds: model.itemIds,
      items: model.items,
      companyId: model.companyId,
      countryGroupIds: model.countryGroupIds,
      selectable: model.selectable,
      discountPolicy: model.discountPolicy,
      websiteId: model.websiteId,
      code: model.code,
      sequence: model.sequence,
    );
  }

  @override
  Map<String, dynamic> toJson() => _$PricelistModelToJson(this);

  @override
  PricelistModel copyWith({
    int? id,
    int? odooId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
    SyncStatus? syncStatus,
    dynamic name,
    dynamic active,
    dynamic currencyId,
    List<PricelistItemModel>? items,
  }) {
    return PricelistModel(
      id: id ?? this.id,
      odooId: odooId ?? this.odooId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      syncStatus: syncStatus ?? this.syncStatus,
      name: name ?? this.name,
      displayName: displayName,
      active: active ?? this.active,
      currencyId: currencyId ?? this.currencyId,
      itemIds: itemIds,
      items: items ?? this.items,
      companyId: companyId,
      countryGroupIds: countryGroupIds,
      selectable: selectable,
      discountPolicy: discountPolicy,
      websiteId: websiteId,
      code: code,
      sequence: sequence,
    );
  }
}

/// 💰 Price List Item Model - نموذج عنصر قائمة الأسعار
///
/// يمثل product.pricelist.item في Odoo
@JsonSerializable(explicitToJson: true)
class PricelistItemModel extends BaseModel {
  // ==================== Basic Info ====================

  @JsonKey(name: 'name')
  final dynamic name; // اسم القاعدة

  @JsonKey(name: 'pricelist_id')
  final dynamic pricelistId; // قائمة الأسعار [id, name]

  @JsonKey(name: 'product_id')
  final dynamic productId; // المنتج [id, name]

  @JsonKey(name: 'product_tmpl_id')
  final dynamic productTmplId; // قالب المنتج [id, name]

  // ==================== Pricing ====================

  @JsonKey(name: 'price')
  final dynamic price; // السعر

  @JsonKey(name: 'fixed_price')
  final dynamic fixedPrice; // السعر الثابت

  @JsonKey(name: 'discount')
  final dynamic discount; // الخصم (%)

  @JsonKey(name: 'price_discount')
  final dynamic priceDiscount; // خصم السعر

  // ==================== Conditions ====================

  @JsonKey(name: 'min_quantity')
  final dynamic minQuantity; // الحد الأدنى للكمية

  @JsonKey(name: 'max_quantity')
  final dynamic maxQuantity; // الحد الأقصى للكمية

  @JsonKey(name: 'date_start')
  final dynamic dateStart; // تاريخ البداية

  @JsonKey(name: 'date_end')
  final dynamic dateEnd; // تاريخ النهاية

  // ==================== Additional Fields ====================

  @JsonKey(name: 'applied_on')
  final dynamic appliedOn; // تطبيق على (product, product_template, category)

  @JsonKey(name: 'categ_id')
  final dynamic categId; // الفئة [id, name]

  @JsonKey(name: 'product_name')
  final dynamic productName; // اسم المنتج

  @JsonKey(name: 'product_tmpl_name')
  final dynamic productTmplName; // اسم قالب المنتج

  @JsonKey(name: 'base')
  final dynamic base; // الأساس (list_price, standard_price, pricelist)

  @JsonKey(name: 'base_pricelist_id')
  final dynamic basePricelistId; // قائمة الأسعار الأساسية

  @JsonKey(name: 'compute_price')
  final dynamic computePrice; // طريقة حساب السعر

  @JsonKey(name: 'sequence')
  final dynamic sequence; // ترتيب القاعدة

  @JsonKey(name: 'active')
  final dynamic active; // هل القاعدة نشطة؟

  const PricelistItemModel({
    super.id,
    super.odooId,
    super.createdAt,
    super.updatedAt,
    super.synced,
    super.syncStatus,
    this.name,
    this.pricelistId,
    this.productId,
    this.productTmplId,
    this.price,
    this.fixedPrice,
    this.discount,
    this.priceDiscount,
    this.minQuantity,
    this.maxQuantity,
    this.dateStart,
    this.dateEnd,
    this.appliedOn,
    this.categId,
    this.productName,
    this.productTmplName,
    this.base,
    this.basePricelistId,
    this.computePrice,
    this.sequence,
    this.active,
  });

  // ==================== Getters ====================

  /// اسم القاعدة
  String get ruleName {
    if (name == null || name == false) return '';
    return name is String ? name as String : name.toString();
  }

  /// ID المنتج
  int? get productIdInt {
    if (productId == null || productId == false) return null;
    if (productId is List && (productId as List).isNotEmpty) {
      return (productId as List)[0] is int ? (productId as List)[0] : null;
    }
    if (productId is int) return productId;
    return null;
  }

  /// اسم المنتج
  String? get productNameText {
    if (productName == null || productName == false) return null;
    if (productName is String && (productName as String).isNotEmpty) {
      return productName as String;
    }
    return null;
  }

  /// السعر كرقم
  double get priceValue {
    if (price == null || price == false) return 0.0;
    if (price is num) return (price as num).toDouble();
    return 0.0;
  }

  /// السعر الثابت كرقم
  double get fixedPriceValue {
    if (fixedPrice == null || fixedPrice == false) return 0.0;
    if (fixedPrice is num) return (fixedPrice as num).toDouble();
    return 0.0;
  }

  /// الخصم كرقم
  double get discountValue {
    if (discount == null || discount == false) return 0.0;
    if (discount is num) return (discount as num).toDouble();
    return 0.0;
  }

  /// الحد الأدنى للكمية كرقم
  double get minQuantityValue {
    if (minQuantity == null || minQuantity == false) return 0.0;
    if (minQuantity is num) return (minQuantity as num).toDouble();
    return 0.0;
  }

  /// الحد الأقصى للكمية كرقم
  double get maxQuantityValue {
    if (maxQuantity == null || maxQuantity == false) return 0.0;
    if (maxQuantity is num) return (maxQuantity as num).toDouble();
    return 0.0;
  }

  /// هل القاعدة نشطة؟
  bool get isActive {
    if (active == null || active == false) return true;
    return active == true;
  }

  /// طريقة التطبيق
  String get appliedOnLabel {
    if (appliedOn == null || appliedOn == false) return 'product';
    return appliedOn.toString();
  }

  /// هل تطبق على منتج محدد؟
  bool get isAppliedOnProduct => appliedOnLabel == 'product';

  /// هل تطبق على قالب منتج؟
  bool get isAppliedOnTemplate => appliedOnLabel == 'product_template';

  /// هل تطبق على فئة؟
  bool get isAppliedOnCategory => appliedOnLabel == 'category';

  /// طريقة حساب السعر
  String get computePriceLabel {
    if (computePrice == null || computePrice == false) return 'fixed';
    return computePrice.toString();
  }

  /// هل يستخدم سعر ثابت؟
  bool get isFixedPrice => computePriceLabel == 'fixed';

  /// هل يستخدم خصم؟
  bool get isDiscount => computePriceLabel == 'percentage';

  /// هل يستخدم قائمة أسعار أخرى؟
  bool get isPricelist => computePriceLabel == 'formula';

  // ==================== Serialization ====================

  factory PricelistItemModel.fromJson(Map<String, dynamic> json) {
    final model = _$PricelistItemModelFromJson(json);
    return PricelistItemModel(
      id: model.id,
      odooId: model.odooId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      synced: model.synced,
      syncStatus: model.syncStatus,
      name: model.name,
      pricelistId: model.pricelistId,
      productId: model.productId,
      productTmplId: model.productTmplId,
      price: model.price,
      fixedPrice: model.fixedPrice,
      discount: model.discount,
      priceDiscount: model.priceDiscount,
      minQuantity: model.minQuantity,
      maxQuantity: model.maxQuantity,
      dateStart: model.dateStart,
      dateEnd: model.dateEnd,
      appliedOn: model.appliedOn,
      categId: model.categId,
      productName: model.productName,
      productTmplName: model.productTmplName,
      base: model.base,
      basePricelistId: model.basePricelistId,
      computePrice: model.computePrice,
      sequence: model.sequence,
      active: model.active,
    );
  }

  @override
  Map<String, dynamic> toJson() => _$PricelistItemModelToJson(this);

  @override
  PricelistItemModel copyWith({
    int? id,
    int? odooId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
    SyncStatus? syncStatus,
    dynamic name,
    dynamic productId,
    dynamic price,
    dynamic fixedPrice,
    dynamic discount,
    dynamic minQuantity,
  }) {
    return PricelistItemModel(
      id: id ?? this.id,
      odooId: odooId ?? this.odooId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      syncStatus: syncStatus ?? this.syncStatus,
      name: name ?? this.name,
      pricelistId: pricelistId,
      productId: productId ?? this.productId,
      productTmplId: productTmplId,
      price: price ?? this.price,
      fixedPrice: fixedPrice ?? this.fixedPrice,
      discount: discount ?? this.discount,
      priceDiscount: priceDiscount,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity,
      dateStart: dateStart,
      dateEnd: dateEnd,
      appliedOn: appliedOn,
      categId: categId,
      productName: productName,
      productTmplName: productTmplName,
      base: base,
      basePricelistId: basePricelistId,
      computePrice: computePrice,
      sequence: sequence,
      active: active,
    );
  }
}
