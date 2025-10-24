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
    };

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.syncing: 'syncing',
  SyncStatus.synced: 'synced',
  SyncStatus.failed: 'failed',
  SyncStatus.conflict: 'conflict',
};
