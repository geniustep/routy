// lib/models/common/payment_term_model.dart

import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'payment_term_model.g.dart';

/// 💳 Payment Term Model - نموذج شروط الدفع
///
/// يمثل account.payment.term في Odoo
/// يدعم:
/// - ✅ جميع حقول Odoo
/// - ✅ BaseModel (Sync, Timestamps)
/// - ✅ Getters ذكية
/// - ✅ json_serializable
@JsonSerializable(explicitToJson: true)
class PaymentTermModel extends BaseModel {
  // ==================== Basic Info ====================

  @JsonKey(name: 'name')
  final dynamic name; // اسم شروط الدفع

  @JsonKey(name: 'display_name')
  final dynamic displayName;

  @JsonKey(name: 'active')
  final dynamic active; // هل الشروط نشطة؟

  @JsonKey(name: 'sequence')
  final dynamic sequence; // ترتيب الشروط

  // ==================== Payment Terms ====================

  @JsonKey(name: 'line_ids')
  final dynamic lineIds; // قائمة شروط الدفع

  @JsonKey(name: 'lines')
  final List<PaymentTermLineModel>? lines; // شروط الدفع

  // ==================== Additional Fields ====================

  @JsonKey(name: 'company_id')
  final dynamic companyId; // الشركة [id, name]

  @JsonKey(name: 'note')
  final dynamic note; // ملاحظات

  @JsonKey(name: 'early_pay_discount_computation')
  final dynamic earlyPayDiscountComputation; // حساب خصم الدفع المبكر

  @JsonKey(name: 'early_discount')
  final dynamic earlyDiscount; // خصم الدفع المبكر

  @JsonKey(name: 'early_discount_computation')
  final dynamic earlyDiscountComputation; // طريقة حساب خصم الدفع المبكر

  @JsonKey(name: 'early_discount_days')
  final dynamic earlyDiscountDays; // أيام خصم الدفع المبكر

  const PaymentTermModel({
    super.id,
    super.odooId,
    super.createdAt,
    super.updatedAt,
    super.synced,
    super.syncStatus,
    this.name,
    this.displayName,
    this.active,
    this.sequence,
    this.lineIds,
    this.lines,
    this.companyId,
    this.note,
    this.earlyPayDiscountComputation,
    this.earlyDiscount,
    this.earlyDiscountComputation,
    this.earlyDiscountDays,
  });

  // ==================== Getters ====================

  /// اسم شروط الدفع
  String get paymentTermName {
    if (name == null || name == false) return '';
    return name is String ? name as String : name.toString();
  }

  /// هل الشروط نشطة؟
  bool get isActive {
    if (active == null || active == false) return true;
    return active == true;
  }

  /// ترتيب الشروط
  int get paymentTermSequence {
    if (sequence == null || sequence == false) return 0;
    if (sequence is int) return sequence;
    return 0;
  }

  /// عدد شروط الدفع
  int get linesCount => lines?.length ?? 0;

  /// هل تحتوي على شروط؟
  bool get hasLines => linesCount > 0;

  /// الملاحظات
  String? get noteText {
    if (note == null || note == false) return null;
    if (note is String && (note as String).isNotEmpty) {
      return note as String;
    }
    return null;
  }

  /// خصم الدفع المبكر
  double get earlyDiscountValue {
    if (earlyDiscount == null || earlyDiscount == false) return 0.0;
    if (earlyDiscount is num) return (earlyDiscount as num).toDouble();
    return 0.0;
  }

  /// أيام خصم الدفع المبكر
  int get earlyDiscountDaysValue {
    if (earlyDiscountDays == null || earlyDiscountDays == false) return 0;
    if (earlyDiscountDays is int) return earlyDiscountDays;
    return 0;
  }

  /// طريقة حساب خصم الدفع المبكر
  String get earlyDiscountComputationLabel {
    if (earlyDiscountComputation == null || earlyDiscountComputation == false) {
      return 'fixed';
    }
    return earlyDiscountComputation.toString();
  }

  /// هل يستخدم خصم الدفع المبكر؟
  bool get hasEarlyDiscount => earlyDiscountValue > 0;

  // ==================== Serialization ====================

  factory PaymentTermModel.fromJson(Map<String, dynamic> json) {
    final model = _$PaymentTermModelFromJson(json);
    return PaymentTermModel(
      id: model.id,
      odooId: model.odooId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      synced: model.synced,
      syncStatus: model.syncStatus,
      name: model.name,
      displayName: model.displayName,
      active: model.active,
      sequence: model.sequence,
      lineIds: model.lineIds,
      lines: model.lines,
      companyId: model.companyId,
      note: model.note,
      earlyPayDiscountComputation: model.earlyPayDiscountComputation,
      earlyDiscount: model.earlyDiscount,
      earlyDiscountComputation: model.earlyDiscountComputation,
      earlyDiscountDays: model.earlyDiscountDays,
    );
  }

  @override
  Map<String, dynamic> toJson() => _$PaymentTermModelToJson(this);

  @override
  PaymentTermModel copyWith({
    int? id,
    int? odooId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
    SyncStatus? syncStatus,
    dynamic name,
    dynamic active,
    dynamic sequence,
    List<PaymentTermLineModel>? lines,
  }) {
    return PaymentTermModel(
      id: id ?? this.id,
      odooId: odooId ?? this.odooId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      syncStatus: syncStatus ?? this.syncStatus,
      name: name ?? this.name,
      displayName: displayName,
      active: active ?? this.active,
      sequence: sequence ?? this.sequence,
      lineIds: lineIds,
      lines: lines ?? this.lines,
      companyId: companyId,
      note: note,
      earlyPayDiscountComputation: earlyPayDiscountComputation,
      earlyDiscount: earlyDiscount,
      earlyDiscountComputation: earlyDiscountComputation,
      earlyDiscountDays: earlyDiscountDays,
    );
  }
}

/// 💳 Payment Term Line Model - نموذج سطر شروط الدفع
///
/// يمثل account.payment.term.line في Odoo
@JsonSerializable(explicitToJson: true)
class PaymentTermLineModel extends BaseModel {
  // ==================== Basic Info ====================

  @JsonKey(name: 'name')
  final dynamic name; // اسم السطر

  @JsonKey(name: 'payment_id')
  final dynamic paymentId; // شروط الدفع [id, name]

  @JsonKey(name: 'sequence')
  final dynamic sequence; // ترتيب السطر

  // ==================== Payment Terms ====================

  @JsonKey(name: 'value')
  final dynamic value; // القيمة (balance, percent)

  @JsonKey(name: 'value_amount')
  final dynamic valueAmount; // مبلغ القيمة

  @JsonKey(name: 'days')
  final dynamic days; // عدد الأيام

  @JsonKey(name: 'option')
  final dynamic option; // الخيار (day_after_invoice_date, day_of_month)

  @JsonKey(name: 'day_of_month')
  final dynamic dayOfMonth; // يوم الشهر

  @JsonKey(name: 'discount')
  final dynamic discount; // الخصم (%)

  @JsonKey(name: 'discount_days')
  final dynamic discountDays; // أيام الخصم

  const PaymentTermLineModel({
    super.id,
    super.odooId,
    super.createdAt,
    super.updatedAt,
    super.synced,
    super.syncStatus,
    this.name,
    this.paymentId,
    this.sequence,
    this.value,
    this.valueAmount,
    this.days,
    this.option,
    this.dayOfMonth,
    this.discount,
    this.discountDays,
  });

  // ==================== Getters ====================

  /// اسم السطر
  String get lineName {
    if (name == null || name == false) return '';
    return name is String ? name as String : name.toString();
  }

  /// ترتيب السطر
  int get lineSequence {
    if (sequence == null || sequence == false) return 0;
    if (sequence is int) return sequence;
    return 0;
  }

  /// نوع القيمة
  String get valueType {
    if (value == null || value == false) return 'balance';
    return value.toString();
  }

  /// مبلغ القيمة
  double get valueAmountValue {
    if (valueAmount == null || valueAmount == false) return 0.0;
    if (valueAmount is num) return (valueAmount as num).toDouble();
    return 0.0;
  }

  /// عدد الأيام
  int get daysValue {
    if (days == null || days == false) return 0;
    if (days is int) return days;
    return 0;
  }

  /// الخيار
  String get optionLabel {
    if (option == null || option == false) return 'day_after_invoice_date';
    return option.toString();
  }

  /// يوم الشهر
  int get dayOfMonthValue {
    if (dayOfMonth == null || dayOfMonth == false) return 0;
    if (dayOfMonth is int) return dayOfMonth;
    return 0;
  }

  /// الخصم
  double get discountValue {
    if (discount == null || discount == false) return 0.0;
    if (discount is num) return (discount as num).toDouble();
    return 0.0;
  }

  /// أيام الخصم
  int get discountDaysValue {
    if (discountDays == null || discountDays == false) return 0;
    if (discountDays is int) return discountDays;
    return 0;
  }

  /// هل يستخدم الرصيد الكامل؟
  bool get isBalance => valueType == 'balance';

  /// هل يستخدم نسبة مئوية؟
  bool get isPercent => valueType == 'percent';

  /// هل يستخدم خصم؟
  bool get hasDiscount => discountValue > 0;

  // ==================== Serialization ====================

  factory PaymentTermLineModel.fromJson(Map<String, dynamic> json) {
    final model = _$PaymentTermLineModelFromJson(json);
    return PaymentTermLineModel(
      id: model.id,
      odooId: model.odooId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      synced: model.synced,
      syncStatus: model.syncStatus,
      name: model.name,
      paymentId: model.paymentId,
      sequence: model.sequence,
      value: model.value,
      valueAmount: model.valueAmount,
      days: model.days,
      option: model.option,
      dayOfMonth: model.dayOfMonth,
      discount: model.discount,
      discountDays: model.discountDays,
    );
  }

  @override
  Map<String, dynamic> toJson() => _$PaymentTermLineModelToJson(this);

  @override
  PaymentTermLineModel copyWith({
    int? id,
    int? odooId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
    SyncStatus? syncStatus,
    dynamic name,
    dynamic sequence,
    dynamic value,
    dynamic days,
    dynamic discount,
  }) {
    return PaymentTermLineModel(
      id: id ?? this.id,
      odooId: odooId ?? this.odooId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      syncStatus: syncStatus ?? this.syncStatus,
      name: name ?? this.name,
      paymentId: paymentId,
      sequence: sequence ?? this.sequence,
      value: value ?? this.value,
      valueAmount: valueAmount,
      days: days ?? this.days,
      option: option,
      dayOfMonth: dayOfMonth,
      discount: discount ?? this.discount,
      discountDays: discountDays,
    );
  }
}
