import 'package:json_annotation/json_annotation.dart';

part 'partners_model.g.dart';

@JsonSerializable()
class PartnerModel {
  @JsonKey(name: 'id')
  dynamic id;
  @JsonKey(name: 'name')
  dynamic name;
  @JsonKey(name: 'active')
  dynamic active;
  @JsonKey(name: 'is_company')
  bool? isCompany;
  @JsonKey(name: 'company_type')
  dynamic companyType;
  @JsonKey(name: 'type')
  dynamic type;
  @JsonKey(name: 'street')
  dynamic street;
  @JsonKey(name: 'street2')
  dynamic street2;
  @JsonKey(name: 'city')
  dynamic city;
  @JsonKey(name: 'zip')
  dynamic zip;
  @JsonKey(name: 'country_id')
  dynamic countryId;
  @JsonKey(name: 'partner_latitude')
  dynamic partnerLatitude;
  @JsonKey(name: 'partner_longitude')
  dynamic partnerLongitude;
  @JsonKey(name: 'email')
  dynamic email;
  @JsonKey(name: 'phone')
  dynamic phone;
  @JsonKey(name: 'mobile')
  dynamic mobile;
  @JsonKey(name: 'website')
  dynamic website;
  @JsonKey(name: 'title')
  dynamic title;
  @JsonKey(name: 'function')
  dynamic function;
  @JsonKey(name: 'vat')
  dynamic vat;
  @JsonKey(name: 'company_registry')
  dynamic companyRegistry;
  @JsonKey(name: 'customer_rank')
  dynamic customerRank;
  @JsonKey(name: 'supplier_rank')
  dynamic supplierRank;
  @JsonKey(name: 'child_ids')
  dynamic childIds;
  @JsonKey(name: 'user_id')
  dynamic userId;
  @JsonKey(name: 'ref')
  dynamic ref;
  @JsonKey(name: 'barcode')
  dynamic barcode;
  @JsonKey(name: 'image_512')
  dynamic image_512;
  @JsonKey(name: 'image_1920')
  dynamic image1920;
  @JsonKey(name: 'display_name')
  dynamic displayName;

  PartnerModel({
    this.id,
    this.name,
    this.active,
    this.isCompany,
    this.companyType,
    this.type,
    this.street,
    this.street2,
    this.city,
    this.zip,
    this.countryId,
    this.partnerLatitude,
    this.partnerLongitude,
    this.email,
    this.phone,
    this.mobile,
    this.website,
    this.title,
    this.function,
    this.vat,
    this.companyRegistry,
    this.customerRank,
    this.supplierRank,
    this.childIds,
    this.userId,
    this.ref,
    this.barcode,
    this.image_512,
    this.image1920,
    this.displayName,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) =>
      _$PartnerModelFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerModelToJson(this);
}
