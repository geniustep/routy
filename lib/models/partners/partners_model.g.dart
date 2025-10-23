// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partners_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerModel _$PartnerModelFromJson(Map<String, dynamic> json) => PartnerModel(
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
  ref: json['ref'],
  active: json['active'],
  barcode: json['barcode'],
  isCompany: json['is_company'],
  companyType: json['company_type'],
  companyRegistry: json['company_registry'],
  title: json['title'],
  function: json['function'],
  email: json['email'],
  phone: json['phone'],
  mobile: json['mobile'],
  website: json['website'],
  addressType: json['type'],
  street: json['street'],
  street2: json['street2'],
  city: json['city'],
  zip: json['zip'],
  countryId: json['country_id'],
  partnerLatitude: json['partner_latitude'],
  partnerLongitude: json['partner_longitude'],
  vat: json['vat'],
  customerRank: json['customer_rank'],
  supplierRank: json['supplier_rank'],
  childIds: json['child_ids'],
  userId: json['user_id'],
  image512: json['image_512'],
  image1920: json['image_1920'],
  creditLimit: json['credit_limit'],
  balance: json['credit'],
  totalDue: json['total_due'],
  totalSales: json['total_sales'],
  notes: json['notes'],
  metadata: json['metadata'],
);

Map<String, dynamic> _$PartnerModelToJson(PartnerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'odooId': instance.odooId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'synced': instance.synced,
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'name': instance.name,
      'display_name': instance.displayName,
      'ref': instance.ref,
      'active': instance.active,
      'barcode': instance.barcode,
      'is_company': instance.isCompany,
      'company_type': instance.companyType,
      'company_registry': instance.companyRegistry,
      'title': instance.title,
      'function': instance.function,
      'email': instance.email,
      'phone': instance.phone,
      'mobile': instance.mobile,
      'website': instance.website,
      'type': instance.addressType,
      'street': instance.street,
      'street2': instance.street2,
      'city': instance.city,
      'zip': instance.zip,
      'country_id': instance.countryId,
      'partner_latitude': instance.partnerLatitude,
      'partner_longitude': instance.partnerLongitude,
      'vat': instance.vat,
      'customer_rank': instance.customerRank,
      'supplier_rank': instance.supplierRank,
      'child_ids': instance.childIds,
      'user_id': instance.userId,
      'image_512': instance.image512,
      'image_1920': instance.image1920,
      'credit_limit': instance.creditLimit,
      'credit': instance.balance,
      'total_due': instance.totalDue,
      'total_sales': instance.totalSales,
      'notes': instance.notes,
      'metadata': instance.metadata,
    };

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.syncing: 'syncing',
  SyncStatus.synced: 'synced',
  SyncStatus.failed: 'failed',
  SyncStatus.conflict: 'conflict',
};
