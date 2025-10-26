// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
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
  name: json['name'],
  displayName: json['display_name'],
  defaultCode: json['default_code'],
  barcode: json['barcode'],
  active: json['active'],
  listPrice: json['list_price'],
  standardPrice: json['standard_price'],
  saleOk: json['sale_ok'],
  purchaseOk: json['purchase_ok'],
  type: json['type'],
  categId: json['categ_id'],
  uomId: json['uom_id'],
  uomPoId: json['uom_po_id'],
  description: json['description'],
  descriptionSale: json['description_sale'],
  descriptionPurchase: json['description_purchase'],
  weight: json['weight'],
  volume: json['volume'],
  saleDelay: json['sale_delay'],
  tracking: json['tracking'],
  routeIds: json['route_ids'],
  companyId: json['company_id'],
  currencyId: json['currency_id'],
  image1920: json['image_1920'],
  isFavorite: json['is_favorite'],
  sellerIds: json['seller_ids'],
  qtyAvailable: json['qty_available'],
  virtualAvailable: json['virtual_available'],
  uomNameField: json['uom_name'],
  invoicePolicy: json['invoice_policy'],
  weightUomName: json['weight_uom_name'],
  volumeUomName: json['volume_uom_name'],
  salesCount: json['sales_count'],
  purchasedProductQty: json['purchased_product_qty'],
  writeDate: json['write_date'],
  productVariantCount: json['product_variant_count'],
  responsibleId: json['responsible_id'],
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'odooId': instance.odooId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'synced': instance.synced,
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'name': instance.name,
      'display_name': instance.displayName,
      'default_code': instance.defaultCode,
      'barcode': instance.barcode,
      'active': instance.active,
      'list_price': instance.listPrice,
      'standard_price': instance.standardPrice,
      'sale_ok': instance.saleOk,
      'purchase_ok': instance.purchaseOk,
      'type': instance.type,
      'categ_id': instance.categId,
      'uom_id': instance.uomId,
      'uom_po_id': instance.uomPoId,
      'description': instance.description,
      'description_sale': instance.descriptionSale,
      'description_purchase': instance.descriptionPurchase,
      'weight': instance.weight,
      'volume': instance.volume,
      'sale_delay': instance.saleDelay,
      'tracking': instance.tracking,
      'route_ids': instance.routeIds,
      'company_id': instance.companyId,
      'currency_id': instance.currencyId,
      'image_1920': instance.image1920,
      'is_favorite': instance.isFavorite,
      'seller_ids': instance.sellerIds,
      'qty_available': instance.qtyAvailable,
      'virtual_available': instance.virtualAvailable,
      'uom_name': instance.uomNameField,
      'invoice_policy': instance.invoicePolicy,
      'weight_uom_name': instance.weightUomName,
      'volume_uom_name': instance.volumeUomName,
      'sales_count': instance.salesCount,
      'purchased_product_qty': instance.purchasedProductQty,
      'write_date': instance.writeDate,
      'product_variant_count': instance.productVariantCount,
      'responsible_id': instance.responsibleId,
    };

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.syncing: 'syncing',
  SyncStatus.synced: 'synced',
  SyncStatus.failed: 'failed',
  SyncStatus.conflict: 'conflict',
};
