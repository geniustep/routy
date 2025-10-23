// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_order_line_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleOrderLineModel _$SaleOrderLineModelFromJson(Map<String, dynamic> json) =>
    SaleOrderLineModel(
      id: (json['id'] as num?)?.toInt(),
      odooId: (json['odooId'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      synced: json['synced'] as bool? ?? false,
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
          SyncStatus.pending,
      sequence: json['sequence'],
      name: json['name'],
      displayType: json['display_type'],
      state: json['state'],
      productId: json['product_id'],
      productTemplateId: json['product_template_id'],
      productType: json['product_type'],
      productUpdatable: json['product_updatable'],
      productUomCategoryId: json['product_uom_category_id'],
      productUomQty: json['product_uom_qty'],
      productUom: json['product_uom'],
      productPackaging: json['product_packaging'],
      qtyDelivered: json['qty_delivered'],
      qtyDeliveredManual: json['qty_delivered_manual'],
      qtyDeliveredMethod: json['qty_delivered_method'],
      qtyToDeliver: json['qty_to_deliver'],
      qtyInvoiced: json['qty_invoiced'],
      qtyToInvoice: json['qty_to_invoice'],
      virtualAvailableAtDate: json['virtual_available_at_date'],
      qtyAvailableToday: json['qty_available_today'],
      freeQtyToday: json['free_qty_today'],
      isMto: json['is_mto'],
      displayQtyWidget: json['display_qty_widget'],
      warehouseId: json['warehouse_id'],
      routeId: json['route_id'],
      priceUnit: json['price_unit'],
      discount: json['discount'],
      priceSubtotal: json['price_subtotal'],
      priceTax: json['price_tax'],
      priceTotal: json['price_total'],
      taxId: json['tax_id'],
      currencyId: json['currency_id'],
      scheduledDate: json['scheduled_date'],
      customerLead: json['customer_lead'],
      invoiceStatus: json['invoice_status'],
      companyId: json['company_id'],
      analyticTagIds: json['analytic_tag_ids'],
    );

Map<String, dynamic> _$SaleOrderLineModelToJson(SaleOrderLineModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'odooId': instance.odooId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'synced': instance.synced,
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'sequence': instance.sequence,
      'name': instance.name,
      'display_type': instance.displayType,
      'state': instance.state,
      'product_id': instance.productId,
      'product_template_id': instance.productTemplateId,
      'product_type': instance.productType,
      'product_updatable': instance.productUpdatable,
      'product_uom_category_id': instance.productUomCategoryId,
      'product_uom_qty': instance.productUomQty,
      'product_uom': instance.productUom,
      'product_packaging': instance.productPackaging,
      'qty_delivered': instance.qtyDelivered,
      'qty_delivered_manual': instance.qtyDeliveredManual,
      'qty_delivered_method': instance.qtyDeliveredMethod,
      'qty_to_deliver': instance.qtyToDeliver,
      'qty_invoiced': instance.qtyInvoiced,
      'qty_to_invoice': instance.qtyToInvoice,
      'virtual_available_at_date': instance.virtualAvailableAtDate,
      'qty_available_today': instance.qtyAvailableToday,
      'free_qty_today': instance.freeQtyToday,
      'is_mto': instance.isMto,
      'display_qty_widget': instance.displayQtyWidget,
      'warehouse_id': instance.warehouseId,
      'route_id': instance.routeId,
      'price_unit': instance.priceUnit,
      'discount': instance.discount,
      'price_subtotal': instance.priceSubtotal,
      'price_tax': instance.priceTax,
      'price_total': instance.priceTotal,
      'tax_id': instance.taxId,
      'currency_id': instance.currencyId,
      'scheduled_date': instance.scheduledDate,
      'customer_lead': instance.customerLead,
      'invoice_status': instance.invoiceStatus,
      'company_id': instance.companyId,
      'analytic_tag_ids': instance.analyticTagIds,
    };

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.syncing: 'syncing',
  SyncStatus.synced: 'synced',
  SyncStatus.failed: 'failed',
  SyncStatus.conflict: 'conflict',
};
