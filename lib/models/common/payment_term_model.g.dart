// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_term_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentTermModel _$PaymentTermModelFromJson(Map<String, dynamic> json) =>
    PaymentTermModel(
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
      sequence: json['sequence'],
      lineIds: json['line_ids'],
      lines: (json['lines'] as List<dynamic>?)
          ?.map((e) => PaymentTermLineModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      companyId: json['company_id'],
      note: json['note'],
      earlyPayDiscountComputation: json['early_pay_discount_computation'],
      earlyDiscount: json['early_discount'],
      earlyDiscountComputation: json['early_discount_computation'],
      earlyDiscountDays: json['early_discount_days'],
    );

Map<String, dynamic> _$PaymentTermModelToJson(PaymentTermModel instance) =>
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
      'sequence': instance.sequence,
      'line_ids': instance.lineIds,
      'lines': instance.lines?.map((e) => e.toJson()).toList(),
      'company_id': instance.companyId,
      'note': instance.note,
      'early_pay_discount_computation': instance.earlyPayDiscountComputation,
      'early_discount': instance.earlyDiscount,
      'early_discount_computation': instance.earlyDiscountComputation,
      'early_discount_days': instance.earlyDiscountDays,
    };

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.syncing: 'syncing',
  SyncStatus.synced: 'synced',
  SyncStatus.failed: 'failed',
  SyncStatus.conflict: 'conflict',
};

PaymentTermLineModel _$PaymentTermLineModelFromJson(
  Map<String, dynamic> json,
) => PaymentTermLineModel(
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
  paymentId: json['payment_id'],
  sequence: json['sequence'],
  value: json['value'],
  valueAmount: json['value_amount'],
  days: json['days'],
  option: json['option'],
  dayOfMonth: json['day_of_month'],
  discount: json['discount'],
  discountDays: json['discount_days'],
);

Map<String, dynamic> _$PaymentTermLineModelToJson(
  PaymentTermLineModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'odooId': instance.odooId,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'synced': instance.synced,
  'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
  'name': instance.name,
  'payment_id': instance.paymentId,
  'sequence': instance.sequence,
  'value': instance.value,
  'value_amount': instance.valueAmount,
  'days': instance.days,
  'option': instance.option,
  'day_of_month': instance.dayOfMonth,
  'discount': instance.discount,
  'discount_days': instance.discountDays,
};
