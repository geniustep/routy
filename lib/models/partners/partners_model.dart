import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';
import 'partner_type.dart';

part 'partners_model.g.dart';

/// 👥 Partner Model المحسّن (يدمج القديم + الجديد)
///
/// يمثل res.partner في Odoo
/// يدعم:
/// - ✅ جميع حقول Odoo
/// - ✅ BaseModel (Sync, Timestamps)
/// - ✅ Getters ذكية
/// - ✅ json_serializable
@JsonSerializable(explicitToJson: true)
class PartnerModel extends BaseModel {
  // ==================== Basic Info ====================
  // 🔄 جميع الحقول dynamic للتعامل مع false/null/String من Odoo

  @JsonKey(name: 'name')
  final dynamic name;

  @JsonKey(name: 'display_name')
  final dynamic displayName;

  @JsonKey(name: 'ref')
  final dynamic ref;

  @JsonKey(name: 'active')
  final dynamic active;

  @JsonKey(name: 'barcode')
  final dynamic barcode;

  // ==================== Company Info ====================

  @JsonKey(name: 'is_company')
  final dynamic isCompany;

  @JsonKey(name: 'company_type')
  final dynamic companyType;

  @JsonKey(name: 'company_registry')
  final dynamic companyRegistry;

  @JsonKey(name: 'title')
  final dynamic title; // [id, name] or false

  @JsonKey(name: 'function')
  final dynamic function;

  // ==================== Contact Info ====================

  @JsonKey(name: 'email')
  final dynamic email;

  @JsonKey(name: 'phone')
  final dynamic phone;

  @JsonKey(name: 'mobile')
  final dynamic mobile;

  @JsonKey(name: 'website')
  final dynamic website;

  // ==================== Address Info ====================

  @JsonKey(name: 'type')
  final dynamic addressType;

  @JsonKey(name: 'street')
  final dynamic street;

  @JsonKey(name: 'street2')
  final dynamic street2;

  @JsonKey(name: 'city')
  final dynamic city;

  @JsonKey(name: 'zip')
  final dynamic zip;

  @JsonKey(name: 'country_id')
  final dynamic countryId; // [id, name] or false

  @JsonKey(name: 'partner_latitude')
  final dynamic partnerLatitude;

  @JsonKey(name: 'partner_longitude')
  final dynamic partnerLongitude;

  // ==================== Tax & Legal ====================

  @JsonKey(name: 'vat')
  final dynamic vat;

  // ==================== Customer/Supplier ====================

  @JsonKey(name: 'customer_rank')
  final dynamic customerRank;

  @JsonKey(name: 'supplier_rank')
  final dynamic supplierRank;

  // ==================== Relations ====================

  @JsonKey(name: 'child_ids')
  final dynamic childIds;

  @JsonKey(name: 'user_id')
  final dynamic userId; // [id, name] or false

  // ==================== Images ====================

  @JsonKey(name: 'image_512')
  final dynamic image512;

  @JsonKey(name: 'image_1920')
  final dynamic image1920;

  // ==================== Additional Fields ====================

  @JsonKey(includeFromJson: false, includeToJson: false)
  final PartnerType type;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final PartnerStatus status;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final PartnerLevel level;

  @JsonKey(name: 'credit_limit')
  final dynamic creditLimit;

  @JsonKey(name: 'credit')
  final dynamic balance;

  @JsonKey(name: 'total_due')
  final dynamic totalDue;

  @JsonKey(name: 'total_sales')
  final dynamic totalSales;

  @JsonKey(name: 'notes')
  final dynamic notes;

  @JsonKey(name: 'metadata')
  final dynamic metadata;

  const PartnerModel({
    // Base fields
    super.id,
    super.odooId,
    super.createdAt,
    super.updatedAt,
    super.synced,
    super.syncStatus,

    // Basic
    required this.name,
    this.displayName,
    this.ref,
    this.active,
    this.barcode,

    // Company
    this.isCompany,
    this.companyType,
    this.companyRegistry,
    this.title,
    this.function,

    // Contact
    this.email,
    this.phone,
    this.mobile,
    this.website,

    // Address
    this.addressType,
    this.street,
    this.street2,
    this.city,
    this.zip,
    this.countryId,
    this.partnerLatitude,
    this.partnerLongitude,

    // Tax
    this.vat,

    // Ranks
    this.customerRank,
    this.supplierRank,

    // Relations
    this.childIds,
    this.userId,

    // Images
    this.image512,
    this.image1920,

    // Additional
    this.type = PartnerType.customer,
    this.status = PartnerStatus.active,
    this.level = PartnerLevel.normal,
    this.creditLimit,
    this.balance,
    this.totalDue,
    this.totalSales,
    this.notes,
    this.metadata,
  });

  // ==================== Getters ====================

  /// الاسم المختصر
  String get shortName {
    final nameStr = (name is String)
        ? name as String
        : (name?.toString() ?? '');
    final parts = nameStr.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1][0]}.';
    }
    return nameStr;
  }

  /// الأحرف الأولى (للـ Avatar)
  String get initials {
    final nameStr = (name is String)
        ? name as String
        : (name?.toString() ?? '');
    final parts = nameStr.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// رقم الاتصال الأساسي
  String? get primaryPhone {
    final mobileStr = (mobile is String && mobile != false)
        ? mobile as String
        : null;
    final phoneStr = (phone is String && phone != false)
        ? phone as String
        : null;
    return mobileStr ?? phoneStr;
  }

  /// العنوان الكامل
  String? get fullAddress {
    final streetStr = (street is String && street != false)
        ? street as String
        : null;
    final street2Str = (street2 is String && street2 != false)
        ? street2 as String
        : null;
    final cityStr = (city is String && city != false) ? city as String : null;
    final zipStr = (zip is String && zip != false) ? zip as String : null;

    final parts = [
      streetStr,
      street2Str,
      cityStr,
      _extractName(countryId),
      zipStr,
    ].where((s) => s != null && s.isNotEmpty);

    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  /// اسم الدولة
  String? get countryName => _extractName(countryId);

  /// اسم User المسؤول
  String? get userName => _extractName(userId);

  /// اسم Title
  String? get titleName => _extractName(title);

  /// هل يمكن التعامل معه؟
  bool get canTransact {
    final isActive = (active is bool) ? active as bool : true;
    return isActive && status.canTransact;
  }

  /// هل لديه ديون؟
  bool get hasDebt {
    final due = (totalDue is num) ? (totalDue as num).toDouble() : 0.0;
    return due > 0;
  }

  /// هل تجاوز حد الائتمان؟
  bool get exceededCreditLimit {
    final limit = (creditLimit is num) ? (creditLimit as num).toDouble() : 0.0;
    if (limit <= 0) return false;
    final bal = (balance is num) ? (balance as num).toDouble() : 0.0;
    return bal > limit;
  }

  /// نسبة استخدام الائتمان
  double get creditUsagePercentage {
    final limit = (creditLimit is num) ? (creditLimit as num).toDouble() : 0.0;
    if (limit <= 0) return 0;
    final bal = (balance is num) ? (balance as num).toDouble() : 0.0;
    return ((bal / limit) * 100).clamp(0, 100);
  }

  /// هل VIP؟
  bool get isVip => level == PartnerLevel.vip;

  /// هل عميل؟
  bool get isCustomer {
    final rank = (customerRank is int) ? customerRank as int : 0;
    return rank > 0 || type.isCustomer;
  }

  /// هل مورد؟
  bool get isSupplier {
    final rank = (supplierRank is int) ? supplierRank as int : 0;
    return rank > 0 || type.isSupplier;
  }

  /// هل لديه موقع GPS؟
  bool get hasLocation {
    final lat = (partnerLatitude is num)
        ? (partnerLatitude as num).toDouble()
        : 0.0;
    final lng = (partnerLongitude is num)
        ? (partnerLongitude as num).toDouble()
        : 0.0;
    return lat != 0 && lng != 0;
  }

  /// الصورة المناسبة
  String? get image {
    final img1920 = (image1920 is String) ? image1920 as String : null;
    final img512 = (image512 is String) ? image512 as String : null;
    return img1920 ?? img512;
  }

  // ==================== Factory Constructors ====================

  /// من JSON (json_serializable)
  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    // ✅ لا حاجة للتنظيف، جميع الحقول dynamic

    // تحديد Type من Ranks
    PartnerType determinedType = PartnerType.customer;
    final customerRank = (json['customer_rank'] is int)
        ? json['customer_rank'] as int
        : 0;
    final supplierRank = (json['supplier_rank'] is int)
        ? json['supplier_rank'] as int
        : 0;

    if (customerRank > 0 && supplierRank > 0) {
      determinedType = PartnerType.both;
    } else if (supplierRank > 0) {
      determinedType = PartnerType.supplier;
    }

    // تحديد Status من active
    final status = json['active'] == false
        ? PartnerStatus.inactive
        : PartnerStatus.active;

    final model = _$PartnerModelFromJson(json);

    return PartnerModel(
      // Base - ✅ مصححة
      id: _parseId(model.id),
      odooId: _parseId(json['id']) ?? _parseId(model.id),
      createdAt: DateTimeX.fromIso(json['create_date'] as String?),
      updatedAt: DateTimeX.fromIso(json['write_date'] as String?),
      synced: json['synced'] as bool? ?? true,
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == json['sync_status'],
        orElse: () => SyncStatus.synced,
      ),

      // من model
      name: model.name,
      displayName: model.displayName,
      ref: model.ref,
      active: model.active,
      barcode: model.barcode,
      isCompany: model.isCompany,
      companyType: model.companyType,
      companyRegistry: model.companyRegistry,
      title: model.title,
      function: model.function,
      email: model.email,
      phone: model.phone,
      mobile: model.mobile,
      website: model.website,
      addressType: model.addressType,
      street: model.street,
      street2: model.street2,
      city: model.city,
      zip: model.zip,
      countryId: model.countryId,
      partnerLatitude: model.partnerLatitude,
      partnerLongitude: model.partnerLongitude,
      vat: model.vat,
      customerRank: model.customerRank,
      supplierRank: model.supplierRank,
      childIds: model.childIds,
      userId: model.userId,
      image512: model.image512,
      image1920: model.image1920,

      // Additional
      type: determinedType,
      status: status,
      level: PartnerLevel.fromString(json['level'] as String?),
      creditLimit: model.creditLimit,
      balance: model.balance,
      totalDue: model.totalDue,
      totalSales: model.totalSales,
      notes: model.notes,
      metadata: model.metadata,
    );
  }

  /// إلى JSON (json_serializable)
  @override
  Map<String, dynamic> toJson() {
    final json = _$PartnerModelToJson(this);

    // إضافة Base fields
    json['id'] = id;
    json['odoo_id'] = odooId;
    json['create_date'] = createdAt?.toIso();
    json['write_date'] = updatedAt?.toIso();
    json['synced'] = synced;
    json['sync_status'] = syncStatus.name;

    // إضافة Enums
    json['type_enum'] = type.name;
    json['status_enum'] = status.name;
    json['level'] = level.name;

    return json;
  }

  /// إلى Odoo Format
  Map<String, dynamic> toOdoo() {
    return {
      if (odooId != null) 'id': odooId,
      'name': name,
      'ref': ref,
      'active': active ?? true,
      'barcode': barcode,
      'is_company': isCompany,
      'company_type': companyType,
      'company_registry': companyRegistry,
      'function': function,
      'email': email,
      'phone': phone,
      'mobile': mobile,
      'website': website,
      'type': addressType,
      'street': street,
      'street2': street2,
      'city': city,
      'zip': zip,
      'vat': vat,
      'partner_latitude': partnerLatitude,
      'partner_longitude': partnerLongitude,
      'customer_rank': customerRank,
      'supplier_rank': supplierRank,
      if (notes != null) 'comment': notes,
      if (image1920 != null) 'image_1920': image1920,
    };
  }

  /// نسخ مع تعديلات
  @override
  PartnerModel copyWith({
    int? id,
    int? odooId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
    SyncStatus? syncStatus,
    String? name,
    String? displayName,
    String? ref,
    bool? active,
    String? barcode,
    bool? isCompany,
    String? companyType,
    String? companyRegistry,
    dynamic title,
    String? function,
    String? email,
    String? phone,
    String? mobile,
    String? website,
    String? addressType,
    String? street,
    String? street2,
    String? city,
    String? zip,
    dynamic countryId,
    double? partnerLatitude,
    double? partnerLongitude,
    String? vat,
    int? customerRank,
    int? supplierRank,
    List<int>? childIds,
    dynamic userId,
    String? image512,
    String? image1920,
    PartnerType? type,
    PartnerStatus? status,
    PartnerLevel? level,
    double? creditLimit,
    double? balance,
    double? totalDue,
    double? totalSales,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return PartnerModel(
      id: id ?? this.id,
      odooId: odooId ?? this.odooId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      syncStatus: syncStatus ?? this.syncStatus,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      ref: ref ?? this.ref,
      active: active ?? this.active,
      barcode: barcode ?? this.barcode,
      isCompany: isCompany ?? this.isCompany,
      companyType: companyType ?? this.companyType,
      companyRegistry: companyRegistry ?? this.companyRegistry,
      title: title ?? this.title,
      function: function ?? this.function,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      mobile: mobile ?? this.mobile,
      website: website ?? this.website,
      addressType: addressType ?? this.addressType,
      street: street ?? this.street,
      street2: street2 ?? this.street2,
      city: city ?? this.city,
      zip: zip ?? this.zip,
      countryId: countryId ?? this.countryId,
      partnerLatitude: partnerLatitude ?? this.partnerLatitude,
      partnerLongitude: partnerLongitude ?? this.partnerLongitude,
      vat: vat ?? this.vat,
      customerRank: customerRank ?? this.customerRank,
      supplierRank: supplierRank ?? this.supplierRank,
      childIds: childIds ?? this.childIds,
      userId: userId ?? this.userId,
      image512: image512 ?? this.image512,
      image1920: image1920 ?? this.image1920,
      type: type ?? this.type,
      status: status ?? this.status,
      level: level ?? this.level,
      creditLimit: creditLimit ?? this.creditLimit,
      balance: balance ?? this.balance,
      totalDue: totalDue ?? this.totalDue,
      totalSales: totalSales ?? this.totalSales,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  /// وضع علامة كمزامن
  PartnerModel markAsSynced(int odooId) {
    return copyWith(
      odooId: odooId,
      synced: true,
      syncStatus: SyncStatus.synced,
      updatedAt: DateTime.now(),
    );
  }

  /// وضع علامة كفاشل
  PartnerModel markAsFailed() {
    return copyWith(syncStatus: SyncStatus.failed);
  }

  // ==================== Helper Methods ====================

  /// تحويل ID بأمان
  static int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// استخراج الاسم من [id, name]
  static String? _extractName(dynamic value) {
    if (value == null || value == false) return null;
    if (value is String) return value;
    if (value is List && value.length >= 2) {
      return value[1] as String?;
    }
    return null;
  }

  @override
  String toString() {
    return 'PartnerModel(id: $id, odooId: $odooId, name: $name, type: $type)';
  }
}
