// lib/models/products/product_model.dart

import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'product_model.g.dart';

/// 📦 Product Model - نموذج المنتج
///
/// يمثل product.product في Odoo
/// يدعم:
/// - ✅ جميع حقول Odoo
/// - ✅ BaseModel (Sync, Timestamps)
/// - ✅ Getters ذكية
/// - ✅ json_serializable
@JsonSerializable(explicitToJson: true)
class ProductModel extends BaseModel {
  // ==================== Basic Info ====================

  @JsonKey(name: 'name')
  final dynamic name; // اسم المنتج

  @JsonKey(name: 'display_name')
  final dynamic displayName;

  @JsonKey(name: 'default_code')
  final dynamic defaultCode; // كود المنتج

  @JsonKey(name: 'barcode')
  final dynamic barcode; // الباركود

  @JsonKey(name: 'active')
  final dynamic active; // هل المنتج نشط؟

  // ==================== Pricing ====================

  @JsonKey(name: 'list_price')
  final dynamic listPrice; // سعر القائمة

  @JsonKey(name: 'standard_price')
  final dynamic standardPrice; // السعر المعياري

  @JsonKey(name: 'sale_ok')
  final dynamic saleOk; // هل يمكن بيعه؟

  @JsonKey(name: 'purchase_ok')
  final dynamic purchaseOk; // هل يمكن شراؤه؟

  // ==================== Inventory ====================

  @JsonKey(name: 'type')
  final dynamic type; // نوع المنتج (product, service, consu)

  @JsonKey(name: 'categ_id')
  final dynamic categId; // فئة المنتج [id, name]

  @JsonKey(name: 'uom_id')
  final dynamic uomId; // وحدة القياس [id, name]

  @JsonKey(name: 'uom_po_id')
  final dynamic uomPoId; // وحدة القياس للشراء [id, name]

  // ==================== Additional Fields ====================

  @JsonKey(name: 'description')
  final dynamic description; // وصف المنتج

  @JsonKey(name: 'description_sale')
  final dynamic descriptionSale; // وصف البيع

  @JsonKey(name: 'description_purchase')
  final dynamic descriptionPurchase; // وصف الشراء

  @JsonKey(name: 'weight')
  final dynamic weight; // الوزن

  @JsonKey(name: 'volume')
  final dynamic volume; // الحجم

  @JsonKey(name: 'sale_delay')
  final dynamic saleDelay; // تأخير البيع

  @JsonKey(name: 'tracking')
  final dynamic tracking; // تتبع المخزون

  @JsonKey(name: 'route_ids')
  final dynamic routeIds; // مسارات المنتج

  @JsonKey(name: 'company_id')
  final dynamic companyId; // الشركة [id, name]

  @JsonKey(name: 'currency_id')
  final dynamic currencyId; // العملة [id, name]

  // ==================== Additional Fields ====================

  @JsonKey(name: 'image_1920')
  final dynamic image1920; // صورة المنتج

  @JsonKey(name: 'is_favorite')
  final dynamic isFavorite; // هل هو مفضل؟

  @JsonKey(name: 'seller_ids')
  final dynamic sellerIds; // معرفات الموردين

  @JsonKey(name: 'qty_available')
  final dynamic qtyAvailable; // الكمية المتاحة

  @JsonKey(name: 'virtual_available')
  final dynamic virtualAvailable; // الكمية المتوقعة

  @JsonKey(name: 'uom_name')
  final dynamic uomNameField; // اسم وحدة القياس

  @JsonKey(name: 'invoice_policy')
  final dynamic invoicePolicy; // سياسة الفواتير

  @JsonKey(name: 'weight_uom_name')
  final dynamic weightUomName; // اسم وحدة الوزن

  @JsonKey(name: 'volume_uom_name')
  final dynamic volumeUomName; // اسم وحدة الحجم

  @JsonKey(name: 'sales_count')
  final dynamic salesCount; // عدد المبيعات

  @JsonKey(name: 'purchased_product_qty')
  final dynamic purchasedProductQty; // كمية المنتج المشتراة

  @JsonKey(name: 'write_date')
  final dynamic writeDate; // تاريخ آخر تحديث

  @JsonKey(name: 'product_variant_count')
  final dynamic productVariantCount; // عدد متغيرات المنتج

  @JsonKey(name: 'responsible_id')
  final dynamic responsibleId; // المسؤول [id, name]

  const ProductModel({
    super.id,
    super.odooId,
    super.createdAt,
    super.updatedAt,
    super.synced,
    super.syncStatus,
    this.name,
    this.displayName,
    this.defaultCode,
    this.barcode,
    this.active,
    this.listPrice,
    this.standardPrice,
    this.saleOk,
    this.purchaseOk,
    this.type,
    this.categId,
    this.uomId,
    this.uomPoId,
    this.description,
    this.descriptionSale,
    this.descriptionPurchase,
    this.weight,
    this.volume,
    this.saleDelay,
    this.tracking,
    this.routeIds,
    this.companyId,
    this.currencyId,
    this.image1920,
    this.isFavorite,
    this.sellerIds,
    this.qtyAvailable,
    this.virtualAvailable,
    this.uomNameField,
    this.invoicePolicy,
    this.weightUomName,
    this.volumeUomName,
    this.salesCount,
    this.purchasedProductQty,
    this.writeDate,
    this.productVariantCount,
    this.responsibleId,
  });

  // ==================== Getters ====================

  /// اسم المنتج
  String get productName {
    if (name == null || name == false) return '';
    return name is String ? name as String : name.toString();
  }

  /// كود المنتج
  String? get productCode {
    if (defaultCode == null || defaultCode == false) return null;
    if (defaultCode is String && (defaultCode as String).isNotEmpty) {
      return defaultCode as String;
    }
    return null;
  }

  /// الباركود
  String? get productBarcode {
    if (barcode == null || barcode == false) return null;
    if (barcode is String && (barcode as String).isNotEmpty) {
      return barcode as String;
    }
    return null;
  }

  /// هل المنتج نشط؟
  bool get isActive {
    if (active == null || active == false) return true;
    return active == true;
  }

  /// سعر القائمة كرقم
  double get listPriceValue {
    if (listPrice == null || listPrice == false) return 0.0;
    if (listPrice is num) return (listPrice as num).toDouble();
    return 0.0;
  }

  /// السعر المعياري كرقم
  double get standardPriceValue {
    if (standardPrice == null || standardPrice == false) return 0.0;
    if (standardPrice is num) return (standardPrice as num).toDouble();
    return 0.0;
  }

  /// هل يمكن بيعه؟
  bool get canBeSold {
    if (saleOk == null || saleOk == false) return true;
    return saleOk == true;
  }

  /// هل يمكن شراؤه؟
  bool get canBePurchased {
    if (purchaseOk == null || purchaseOk == false) return true;
    return purchaseOk == true;
  }

  /// نوع المنتج
  String get productType {
    if (type == null || type == false) return 'product';
    return type.toString();
  }

  /// هل هو منتج مادي؟
  bool get isProduct => productType == 'product';

  /// هل هو خدمة؟
  bool get isService => productType == 'service';

  /// هل هو منتج استهلاكي؟
  bool get isConsumable => productType == 'consu';

  /// فئة المنتج
  String? get categoryName {
    if (categId == null || categId == false) return null;
    if (categId is List && (categId as List).length >= 2) {
      return (categId as List)[1].toString();
    }
    return null;
  }

  /// ID فئة المنتج
  int? get categoryId {
    if (categId == null || categId == false) return null;
    if (categId is List && (categId as List).isNotEmpty) {
      return (categId as List)[0] is int ? (categId as List)[0] : null;
    }
    if (categId is int) return categId;
    return null;
  }

  /// وحدة القياس
  String? get uomName {
    if (uomNameField != null && uomNameField != false) {
      return uomNameField.toString();
    }
    if (uomId == null || uomId == false) return null;
    if (uomId is List && (uomId as List).length >= 2) {
      return (uomId as List)[1].toString();
    }
    return null;
  }

  /// ID وحدة القياس
  int? get uomIdInt {
    if (uomId == null || uomId == false) return null;
    if (uomId is List && (uomId as List).isNotEmpty) {
      return (uomId as List)[0] is int ? (uomId as List)[0] : null;
    }
    if (uomId is int) return uomId;
    return null;
  }

  /// وصف المنتج
  String? get productDescription {
    if (description == null || description == false) return null;
    if (description is String && (description as String).isNotEmpty) {
      return description as String;
    }
    return null;
  }

  /// وصف البيع
  String? get saleDescription {
    if (descriptionSale == null || descriptionSale == false) return null;
    if (descriptionSale is String && (descriptionSale as String).isNotEmpty) {
      return descriptionSale as String;
    }
    return null;
  }

  /// الوزن كرقم
  double get weightValue {
    if (weight == null || weight == false) return 0.0;
    if (weight is num) return (weight as num).toDouble();
    return 0.0;
  }

  /// الحجم كرقم
  double get volumeValue {
    if (volume == null || volume == false) return 0.0;
    if (volume is num) return (volume as num).toDouble();
    return 0.0;
  }

  /// تأخير البيع كرقم
  double get saleDelayValue {
    if (saleDelay == null || saleDelay == false) return 0.0;
    if (saleDelay is num) return (saleDelay as num).toDouble();
    return 0.0;
  }

  /// تتبع المخزون
  String get trackingLabel {
    if (tracking == null || tracking == false) return 'none';
    return tracking.toString();
  }

  /// هل يتم تتبع المخزون؟
  bool get hasTracking => trackingLabel != 'none';

  /// هل يتم تتبع التسلسل؟
  bool get isSerial => trackingLabel == 'serial';

  /// هل يتم تتبع اللوت؟
  bool get isLot => trackingLabel == 'lot';

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

  // ==================== Serialization ====================

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final model = _$ProductModelFromJson(json);
    return ProductModel(
      id: model.id,
      odooId: model.odooId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      synced: model.synced,
      syncStatus: model.syncStatus,
      name: model.name,
      displayName: model.displayName,
      defaultCode: model.defaultCode,
      barcode: model.barcode,
      active: model.active,
      listPrice: model.listPrice,
      standardPrice: model.standardPrice,
      saleOk: model.saleOk,
      purchaseOk: model.purchaseOk,
      type: model.type,
      categId: model.categId,
      uomId: model.uomId,
      uomPoId: model.uomPoId,
      description: model.description,
      descriptionSale: model.descriptionSale,
      descriptionPurchase: model.descriptionPurchase,
      weight: model.weight,
      volume: model.volume,
      saleDelay: model.saleDelay,
      tracking: model.tracking,
      routeIds: model.routeIds,
      companyId: model.companyId,
      currencyId: model.currencyId,
    );
  }

  @override
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  @override
  ProductModel copyWith({
    int? id,
    int? odooId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
    SyncStatus? syncStatus,
    dynamic name,
    dynamic defaultCode,
    dynamic barcode,
    dynamic active,
    dynamic listPrice,
    dynamic standardPrice,
    dynamic saleOk,
    dynamic purchaseOk,
    dynamic type,
    dynamic categId,
    dynamic uomId,
  }) {
    return ProductModel(
      id: id ?? this.id,
      odooId: odooId ?? this.odooId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      syncStatus: syncStatus ?? this.syncStatus,
      name: name ?? this.name,
      displayName: displayName,
      defaultCode: defaultCode ?? this.defaultCode,
      barcode: barcode ?? this.barcode,
      active: active ?? this.active,
      listPrice: listPrice ?? this.listPrice,
      standardPrice: standardPrice ?? this.standardPrice,
      saleOk: saleOk ?? this.saleOk,
      purchaseOk: purchaseOk ?? this.purchaseOk,
      type: type ?? this.type,
      categId: categId ?? this.categId,
      uomId: uomId ?? this.uomId,
      uomPoId: uomPoId,
      description: description,
      descriptionSale: descriptionSale,
      descriptionPurchase: descriptionPurchase,
      weight: weight,
      volume: volume,
      saleDelay: saleDelay,
      tracking: tracking,
      routeIds: routeIds,
      companyId: companyId,
      currencyId: currencyId,
    );
  }
}
