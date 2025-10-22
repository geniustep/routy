// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partners_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerModel _$PartnerModelFromJson(Map<String, dynamic> json) => PartnerModel(
  id: json['id'],
  name: json['name'],
  active: json['active'],
  isCompany: json['is_company'] as bool?,
  companyType: json['company_type'],
  type: json['type'],
  street: json['street'],
  street2: json['street2'],
  city: json['city'],
  zip: json['zip'],
  countryId: json['country_id'],
  partnerLatitude: json['partner_latitude'],
  partnerLongitude: json['partner_longitude'],
  email: json['email'],
  phone: json['phone'],
  mobile: json['mobile'],
  website: json['website'],
  title: json['title'],
  function: json['function'],
  vat: json['vat'],
  companyRegistry: json['company_registry'],
  customerRank: json['customer_rank'],
  supplierRank: json['supplier_rank'],
  childIds: json['child_ids'],
  userId: json['user_id'],
  ref: json['ref'],
  barcode: json['barcode'],
  image_512: json['image_512'],
  image1920: json['image_1920'],
  displayName: json['display_name'],
);

Map<String, dynamic> _$PartnerModelToJson(PartnerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'active': instance.active,
      'is_company': instance.isCompany,
      'company_type': instance.companyType,
      'type': instance.type,
      'street': instance.street,
      'street2': instance.street2,
      'city': instance.city,
      'zip': instance.zip,
      'country_id': instance.countryId,
      'partner_latitude': instance.partnerLatitude,
      'partner_longitude': instance.partnerLongitude,
      'email': instance.email,
      'phone': instance.phone,
      'mobile': instance.mobile,
      'website': instance.website,
      'title': instance.title,
      'function': instance.function,
      'vat': instance.vat,
      'company_registry': instance.companyRegistry,
      'customer_rank': instance.customerRank,
      'supplier_rank': instance.supplierRank,
      'child_ids': instance.childIds,
      'user_id': instance.userId,
      'ref': instance.ref,
      'barcode': instance.barcode,
      'image_512': instance.image_512,
      'image_1920': instance.image1920,
      'display_name': instance.displayName,
    };
