import 'package:get/get.dart';

/// 👥 تصنيف الشركاء (Partner Type)
///
/// يحدد نوع الشريك:
/// - العملاء (Customers)
/// - الموردين (Suppliers)
/// - كلاهما
enum PartnerType {
  /// عميل فقط
  customer,

  /// مورد فقط
  supplier,

  /// عميل ومورد
  both;

  /// التسمية المترجمة
  String get label => 'partner_type_$name'.tr;

  /// أيقونة
  String get icon {
    switch (this) {
      case PartnerType.customer:
        return '👤';
      case PartnerType.supplier:
        return '🏭';
      case PartnerType.both:
        return '👥';
    }
  }

  /// هل عميل؟
  bool get isCustomer =>
      this == PartnerType.customer || this == PartnerType.both;

  /// هل مورد؟
  bool get isSupplier =>
      this == PartnerType.supplier || this == PartnerType.both;

  /// تحويل من String
  static PartnerType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'customer':
        return PartnerType.customer;
      case 'supplier':
        return PartnerType.supplier;
      case 'both':
        return PartnerType.both;
      default:
        return PartnerType.customer;
    }
  }

  /// تحويل لـ String
  @override
  String toString() => name;
}

/// حالة الشريك
enum PartnerStatus {
  /// نشط
  active,

  /// غير نشط
  inactive,

  /// محظور
  blocked,

  /// محذوف
  deleted;

  /// التسمية المترجمة
  String get label => 'partner_status_$name'.tr;

  /// اللون
  String get colorHex {
    switch (this) {
      case PartnerStatus.active:
        return '#4CAF50'; // Green
      case PartnerStatus.inactive:
        return '#FFC107'; // Amber
      case PartnerStatus.blocked:
        return '#F44336'; // Red
      case PartnerStatus.deleted:
        return '#9E9E9E'; // Grey
    }
  }

  /// هل نشط؟
  bool get isActive => this == PartnerStatus.active;

  /// هل يمكن التعامل معه؟
  bool get canTransact => this == PartnerStatus.active;

  /// تحويل من String
  static PartnerStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'active':
        return PartnerStatus.active;
      case 'inactive':
        return PartnerStatus.inactive;
      case 'blocked':
        return PartnerStatus.blocked;
      case 'deleted':
        return PartnerStatus.deleted;
      default:
        return PartnerStatus.active;
    }
  }

  /// تحويل من bool (Odoo active field)
  static PartnerStatus fromBool(bool? active) {
    return (active ?? true) ? PartnerStatus.active : PartnerStatus.inactive;
  }
}

/// مستوى الشريك (VIP, Normal, etc.)
enum PartnerLevel {
  /// VIP
  vip,

  /// عادي
  normal,

  /// جديد
  newbie;

  /// التسمية المترجمة
  String get label => 'partner_level_$name'.tr;

  /// الأيقونة
  String get icon {
    switch (this) {
      case PartnerLevel.vip:
        return '⭐';
      case PartnerLevel.normal:
        return '👤';
      case PartnerLevel.newbie:
        return '🆕';
    }
  }

  /// تحويل من String
  static PartnerLevel fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'vip':
        return PartnerLevel.vip;
      case 'normal':
        return PartnerLevel.normal;
      case 'newbie':
        return PartnerLevel.newbie;
      default:
        return PartnerLevel.normal;
    }
  }
}
