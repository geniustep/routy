// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricelist_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PricelistModel _$PricelistModelFromJson(Map<String, dynamic> json) =>
    PricelistModel(
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
      active: json['active'],
      currencyId: json['currency_id'],
      itemIds: json['item_ids'],
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => PricelistItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      companyId: json['company_id'],
      countryGroupIds: json['country_group_ids'],
      selectable: json['selectable'],
      discountPolicy: json['discount_policy'],
      websiteId: json['website_id'],
      code: json['code'],
      sequence: json['sequence'],
    );

Map<String, dynamic> _$PricelistModelToJson(PricelistModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'odooId': instance.odooId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'synced': instance.synced,
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'name': instance.name,
      'display_name': instance.displayName,
      'active': instance.active,
      'currency_id': instance.currencyId,
      'item_ids': instance.itemIds,
      'items': instance.items?.map((e) => e.toJson()).toList(),
      'company_id': instance.companyId,
      'country_group_ids': instance.countryGroupIds,
      'selectable': instance.selectable,
      'discount_policy': instance.discountPolicy,
      'website_id': instance.websiteId,
      'code': instance.code,
      'sequence': instance.sequence,
    };

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.syncing: 'syncing',
  SyncStatus.synced: 'synced',
  SyncStatus.failed: 'failed',
  SyncStatus.conflict: 'conflict',
};

PricelistItemModel _$PricelistItemModelFromJson(Map<String, dynamic> json) =>
    PricelistItemModel(
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
      pricelistId: json['pricelist_id'],
      productId: json['product_id'],
      productTmplId: json['product_tmpl_id'],
      price: json['price'],
      fixedPrice: json['fixed_price'],
      discount: json['discount'],
      priceDiscount: json['price_discount'],
      minQuantity: json['min_quantity'],
      maxQuantity: json['max_quantity'],
      dateStart: json['date_start'],
      dateEnd: json['date_end'],
      appliedOn: json['applied_on'],
      categId: json['categ_id'],
      productName: json['product_name'],
      productTmplName: json['product_tmpl_name'],
      base: json['base'],
      basePricelistId: json['base_pricelist_id'],
      computePrice: json['compute_price'],
      sequence: json['sequence'],
      active: json['active'],
    );

Map<String, dynamic> _$PricelistItemModelToJson(PricelistItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'odooId': instance.odooId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'synced': instance.synced,
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'name': instance.name,
      'pricelist_id': instance.pricelistId,
      'product_id': instance.productId,
      'product_tmpl_id': instance.productTmplId,
      'price': instance.price,
      'fixed_price': instance.fixedPrice,
      'discount': instance.discount,
      'price_discount': instance.priceDiscount,
      'min_quantity': instance.minQuantity,
      'max_quantity': instance.maxQuantity,
      'date_start': instance.dateStart,
      'date_end': instance.dateEnd,
      'applied_on': instance.appliedOn,
      'categ_id': instance.categId,
      'product_name': instance.productName,
      'product_tmpl_name': instance.productTmplName,
      'base': instance.base,
      'base_pricelist_id': instance.basePricelistId,
      'compute_price': instance.computePrice,
      'sequence': instance.sequence,
      'active': instance.active,
    };
