import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'sale_order_line_model.g.dart';

/// 📝 Sale Order Line Model - سطر أمر المبيعات
///
/// يمثل sale.order.line في Odoo
/// يدعم:
/// - ✅ جميع حقول Odoo
/// - ✅ BaseModel (Sync, Timestamps)
/// - ✅ Getters ذكية
/// - ✅ json_serializable
@JsonSerializable(explicitToJson: true)
class SaleOrderLineModel extends BaseModel {
  // ==================== Basic Info ====================

  @JsonKey(name: 'sequence')
  final dynamic sequence; // الترتيب

  @JsonKey(name: 'name')
  final dynamic name; // وصف المنتج

  @JsonKey(name: 'display_type')
  final dynamic displayType; // line_section, line_note, null

  @JsonKey(name: 'state')
  final dynamic state; // draft, sale, done, cancel

  // ==================== Product Info ====================

  @JsonKey(name: 'product_id')
  final dynamic productId; // [id, name] or false

  @JsonKey(name: 'product_template_id')
  final dynamic productTemplateId; // [id, name]

  @JsonKey(name: 'product_type')
  final dynamic productType; // consu, service, product

  @JsonKey(name: 'product_updatable')
  final dynamic productUpdatable;

  @JsonKey(name: 'product_uom_category_id')
  final dynamic productUomCategoryId;

  // ==================== Quantity ====================

  @JsonKey(name: 'product_uom_qty')
  final dynamic productUomQty; // الكمية المطلوبة

  @JsonKey(name: 'product_uom')
  final dynamic productUom; // وحدة القياس [id, name]

  @JsonKey(name: 'product_packaging')
  final dynamic productPackaging;

  @JsonKey(name: 'qty_delivered')
  final dynamic qtyDelivered; // الكمية المسلمة

  @JsonKey(name: 'qty_delivered_manual')
  final dynamic qtyDeliveredManual;

  @JsonKey(name: 'qty_delivered_method')
  final dynamic qtyDeliveredMethod; // stock_move, manual, analytic

  @JsonKey(name: 'qty_to_deliver')
  final dynamic qtyToDeliver; // الكمية المتبقية للتسليم

  @JsonKey(name: 'qty_invoiced')
  final dynamic qtyInvoiced; // الكمية المفوترة

  @JsonKey(name: 'qty_to_invoice')
  final dynamic qtyToInvoice; // الكمية المتبقية للفوترة

  // ==================== Stock Info ====================

  @JsonKey(name: 'virtual_available_at_date')
  final dynamic virtualAvailableAtDate;

  @JsonKey(name: 'qty_available_today')
  final dynamic qtyAvailableToday;

  @JsonKey(name: 'free_qty_today')
  final dynamic freeQtyToday;

  @JsonKey(name: 'is_mto')
  final dynamic isMto; // Make to Order

  @JsonKey(name: 'display_qty_widget')
  final dynamic displayQtyWidget;

  @JsonKey(name: 'warehouse_id')
  final dynamic warehouseId;

  @JsonKey(name: 'route_id')
  final dynamic routeId;

  // ==================== Price Info ====================

  @JsonKey(name: 'price_unit')
  final dynamic priceUnit; // سعر الوحدة

  @JsonKey(name: 'discount')
  final dynamic discount; // نسبة الخصم %

  @JsonKey(name: 'price_subtotal')
  final dynamic priceSubtotal; // المجموع الجزئي بدون ضريبة

  @JsonKey(name: 'price_tax')
  final dynamic priceTax; // قيمة الضريبة

  @JsonKey(name: 'price_total')
  final dynamic priceTotal; // المجموع الإجمالي مع الضريبة

  @JsonKey(name: 'tax_id')
  final dynamic taxId; // قائمة IDs الضرائب

  @JsonKey(name: 'currency_id')
  final dynamic currencyId; // [id, name]

  // ==================== Dates ====================

  @JsonKey(name: 'scheduled_date')
  final dynamic scheduledDate; // تاريخ التسليم المجدول

  @JsonKey(name: 'customer_lead')
  final dynamic customerLead; // مدة التسليم بالأيام

  // ==================== Status ====================

  @JsonKey(name: 'invoice_status')
  final dynamic invoiceStatus; // to invoice, invoiced, no

  // ==================== Company & Analytics ====================

  @JsonKey(name: 'company_id')
  final dynamic companyId; // [id, name]

  @JsonKey(name: 'analytic_tag_ids')
  final dynamic analyticTagIds;

  const SaleOrderLineModel({
    super.id,
    super.odooId,
    super.createdAt,
    super.updatedAt,
    super.synced,
    super.syncStatus,
    this.sequence,
    this.name,
    this.displayType,
    this.state,
    this.productId,
    this.productTemplateId,
    this.productType,
    this.productUpdatable,
    this.productUomCategoryId,
    this.productUomQty,
    this.productUom,
    this.productPackaging,
    this.qtyDelivered,
    this.qtyDeliveredManual,
    this.qtyDeliveredMethod,
    this.qtyToDeliver,
    this.qtyInvoiced,
    this.qtyToInvoice,
    this.virtualAvailableAtDate,
    this.qtyAvailableToday,
    this.freeQtyToday,
    this.isMto,
    this.displayQtyWidget,
    this.warehouseId,
    this.routeId,
    this.priceUnit,
    this.discount,
    this.priceSubtotal,
    this.priceTax,
    this.priceTotal,
    this.taxId,
    this.currencyId,
    this.scheduledDate,
    this.customerLead,
    this.invoiceStatus,
    this.companyId,
    this.analyticTagIds,
  });

  // ==================== Getters ====================

  /// اسم المنتج
  String get productName {
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

  /// اسم المنتج من productId
  String? get productIdName {
    if (productId == null || productId == false) return null;
    if (productId is List && (productId as List).length >= 2) {
      return (productId as List)[1].toString();
    }
    return null;
  }

  /// الكمية المطلوبة كرقم
  double get quantity {
    if (productUomQty == null || productUomQty == false) return 0.0;
    if (productUomQty is num) return (productUomQty as num).toDouble();
    return 0.0;
  }

  /// سعر الوحدة كرقم
  double get unitPrice {
    if (priceUnit == null || priceUnit == false) return 0.0;
    if (priceUnit is num) return (priceUnit as num).toDouble();
    return 0.0;
  }

  /// نسبة الخصم كرقم
  double get discountPercent {
    if (discount == null || discount == false) return 0.0;
    if (discount is num) return (discount as num).toDouble();
    return 0.0;
  }

  /// المجموع الجزئي كرقم
  double get subtotal {
    if (priceSubtotal == null || priceSubtotal == false) return 0.0;
    if (priceSubtotal is num) return (priceSubtotal as num).toDouble();
    return 0.0;
  }

  /// قيمة الضريبة كرقم
  double get taxValue {
    if (priceTax == null || priceTax == false) return 0.0;
    if (priceTax is num) return (priceTax as num).toDouble();
    return 0.0;
  }

  /// المجموع الإجمالي كرقم
  double get total {
    if (priceTotal == null || priceTotal == false) return 0.0;
    if (priceTotal is num) return (priceTotal as num).toDouble();
    return 0.0;
  }

  /// الكمية المسلمة كرقم
  double get deliveredQty {
    if (qtyDelivered == null || qtyDelivered == false) return 0.0;
    if (qtyDelivered is num) return (qtyDelivered as num).toDouble();
    return 0.0;
  }

  /// الكمية المفوترة كرقم
  double get invoicedQty {
    if (qtyInvoiced == null || qtyInvoiced == false) return 0.0;
    if (qtyInvoiced is num) return (qtyInvoiced as num).toDouble();
    return 0.0;
  }

  /// الكمية المتبقية للتسليم
  double get remainingToDeliver {
    if (qtyToDeliver == null || qtyToDeliver == false) return 0.0;
    if (qtyToDeliver is num) return (qtyToDeliver as num).toDouble();
    return 0.0;
  }

  /// الكمية المتبقية للفوترة
  double get remainingToInvoice {
    if (qtyToInvoice == null || qtyToInvoice == false) return 0.0;
    if (qtyToInvoice is num) return (qtyToInvoice as num).toDouble();
    return 0.0;
  }

  /// هل هو قسم (Section)؟
  bool get isSection => displayType == 'line_section';

  /// هل هو ملاحظة (Note)؟
  bool get isNote => displayType == 'line_note';

  /// هل هو سطر عادي (منتج)؟
  bool get isProduct => displayType == null || displayType == false;

  /// الحالة كنص
  String get lineState {
    if (state == null || state == false) return 'draft';
    return state.toString();
  }

  /// وحدة القياس
  String? get uomName {
    if (productUom == null || productUom == false) return null;
    if (productUom is List && (productUom as List).length >= 2) {
      return (productUom as List)[1].toString();
    }
    return null;
  }

  /// نوع المنتج
  String get productTypeLabel {
    if (productType == null || productType == false) return 'consu';
    return productType.toString();
  }

  /// هل المنتج قابل للتخزين؟
  bool get isStorableProduct => productTypeLabel == 'product';

  /// هل المنتج خدمة؟
  bool get isService => productTypeLabel == 'service';

  /// هل المنتج قابل للاستهلاك؟
  bool get isConsumable => productTypeLabel == 'consu';

  /// حالة الفوترة
  String get invoiceStatusLabel {
    if (invoiceStatus == null || invoiceStatus == false) return 'no';
    return invoiceStatus.toString();
  }

  /// هل تم إصدار فاتورة؟
  bool get isInvoiced => invoiceStatusLabel == 'invoiced';

  /// هل يحتاج فاتورة؟
  bool get needsInvoice => invoiceStatusLabel == 'to invoice';

  /// قيمة الخصم
  double get discountAmount {
    return subtotal * (discountPercent / 100);
  }

  /// السعر بعد الخصم
  double get priceAfterDiscount {
    return unitPrice * (1 - discountPercent / 100);
  }

  /// نسبة التسليم (%)
  double get deliveryProgress {
    if (quantity == 0) return 0;
    return (deliveredQty / quantity) * 100;
  }

  /// نسبة الفوترة (%)
  double get invoiceProgress {
    if (quantity == 0) return 0;
    return (invoicedQty / quantity) * 100;
  }

  // ==================== Serialization ====================

  factory SaleOrderLineModel.fromJson(Map<String, dynamic> json) {
    final model = _$SaleOrderLineModelFromJson(json);
    return SaleOrderLineModel(
      id: model.id,
      odooId: model.odooId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      synced: model.synced,
      syncStatus: model.syncStatus,
      sequence: model.sequence,
      name: model.name,
      displayType: model.displayType,
      state: model.state,
      productId: model.productId,
      productTemplateId: model.productTemplateId,
      productType: model.productType,
      productUpdatable: model.productUpdatable,
      productUomCategoryId: model.productUomCategoryId,
      productUomQty: model.productUomQty,
      productUom: model.productUom,
      productPackaging: model.productPackaging,
      qtyDelivered: model.qtyDelivered,
      qtyDeliveredManual: model.qtyDeliveredManual,
      qtyDeliveredMethod: model.qtyDeliveredMethod,
      qtyToDeliver: model.qtyToDeliver,
      qtyInvoiced: model.qtyInvoiced,
      qtyToInvoice: model.qtyToInvoice,
      virtualAvailableAtDate: model.virtualAvailableAtDate,
      qtyAvailableToday: model.qtyAvailableToday,
      freeQtyToday: model.freeQtyToday,
      isMto: model.isMto,
      displayQtyWidget: model.displayQtyWidget,
      warehouseId: model.warehouseId,
      routeId: model.routeId,
      priceUnit: model.priceUnit,
      discount: model.discount,
      priceSubtotal: model.priceSubtotal,
      priceTax: model.priceTax,
      priceTotal: model.priceTotal,
      taxId: model.taxId,
      currencyId: model.currencyId,
      scheduledDate: model.scheduledDate,
      customerLead: model.customerLead,
      invoiceStatus: model.invoiceStatus,
      companyId: model.companyId,
      analyticTagIds: model.analyticTagIds,
    );
  }

  @override
  Map<String, dynamic> toJson() => _$SaleOrderLineModelToJson(this);

  @override
  SaleOrderLineModel copyWith({
    int? id,
    int? odooId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
    SyncStatus? syncStatus,
    dynamic sequence,
    dynamic name,
    dynamic productId,
    dynamic productUomQty,
    dynamic priceUnit,
    dynamic discount,
  }) {
    return SaleOrderLineModel(
      id: id ?? this.id,
      odooId: odooId ?? this.odooId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      syncStatus: syncStatus ?? this.syncStatus,
      sequence: sequence ?? this.sequence,
      name: name ?? this.name,
      displayType: displayType,
      state: state,
      productId: productId ?? this.productId,
      productTemplateId: productTemplateId,
      productType: productType,
      productUpdatable: productUpdatable,
      productUomCategoryId: productUomCategoryId,
      productUomQty: productUomQty ?? this.productUomQty,
      productUom: productUom,
      productPackaging: productPackaging,
      qtyDelivered: qtyDelivered,
      qtyDeliveredManual: qtyDeliveredManual,
      qtyDeliveredMethod: qtyDeliveredMethod,
      qtyToDeliver: qtyToDeliver,
      qtyInvoiced: qtyInvoiced,
      qtyToInvoice: qtyToInvoice,
      virtualAvailableAtDate: virtualAvailableAtDate,
      qtyAvailableToday: qtyAvailableToday,
      freeQtyToday: freeQtyToday,
      isMto: isMto,
      displayQtyWidget: displayQtyWidget,
      warehouseId: warehouseId,
      routeId: routeId,
      priceUnit: priceUnit ?? this.priceUnit,
      discount: discount ?? this.discount,
      priceSubtotal: priceSubtotal,
      priceTax: priceTax,
      priceTotal: priceTotal,
      taxId: taxId,
      currencyId: currencyId,
      scheduledDate: scheduledDate,
      customerLead: customerLead,
      invoiceStatus: invoiceStatus,
      companyId: companyId,
      analyticTagIds: analyticTagIds,
    );
  }
}
