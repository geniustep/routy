import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'sale_order_model.g.dart';

/// 📋 Sale Order Model - أمر المبيعات
///
/// يمثل sale.order في Odoo
/// يدعم:
/// - ✅ جميع حقول Odoo
/// - ✅ BaseModel (Sync, Timestamps)
/// - ✅ Getters ذكية
/// - ✅ json_serializable
@JsonSerializable(explicitToJson: true)
class SaleOrderModel extends BaseModel {
  // ==================== Basic Info ====================

  @JsonKey(name: 'name')
  final dynamic name; // رقم الطلب (SO001, SO002, etc.)

  @JsonKey(name: 'display_name')
  final dynamic displayName;

  @JsonKey(name: 'state')
  final dynamic state; // draft, sent, sale, done, cancel

  @JsonKey(name: 'invoice_status')
  final dynamic invoiceStatus; // to invoice, invoiced, no

  // ==================== Partner Info ====================

  @JsonKey(name: 'partner_id')
  final dynamic partnerId; // [id, name] or false

  @JsonKey(name: 'partner_invoice_id')
  final dynamic partnerInvoiceId;

  @JsonKey(name: 'partner_shipping_id')
  final dynamic partnerShippingId;

  // ==================== Dates ====================

  @JsonKey(name: 'date_order')
  final dynamic dateOrder; // تاريخ الطلب

  @JsonKey(name: 'validity_date')
  final dynamic validityDate; // صلاحية العرض

  @JsonKey(name: 'commitment_date')
  final dynamic commitmentDate; // موعد التسليم

  @JsonKey(name: 'confirmation_date')
  final dynamic confirmationDate; // تاريخ التأكيد

  @JsonKey(name: 'expected_date')
  final dynamic expectedDate;

  @JsonKey(name: 'effective_date')
  final dynamic effectiveDate;

  // ==================== Financial Info ====================

  @JsonKey(name: 'amount_untaxed')
  final dynamic amountUntaxed; // المبلغ بدون ضريبة

  @JsonKey(name: 'amount_tax')
  final dynamic amountTax; // قيمة الضريبة

  @JsonKey(name: 'amount_total')
  final dynamic amountTotal; // المبلغ الإجمالي

  @JsonKey(name: 'margin')
  final dynamic margin; // هامش الربح

  @JsonKey(name: 'pricelist_id')
  final dynamic pricelistId; // [id, name]

  @JsonKey(name: 'currency_id')
  final dynamic currencyId; // [id, name]

  @JsonKey(name: 'payment_term_id')
  final dynamic paymentTermId; // شروط الدفع

  @JsonKey(name: 'fiscal_position_id')
  final dynamic fiscalPositionId;

  // ==================== Order Lines ====================

  @JsonKey(name: 'order_line')
  final dynamic orderLine; // قائمة IDs أو Objects

  // ==================== Additional Fields ====================

  @JsonKey(name: 'note')
  final dynamic note; // ملاحظات

  @JsonKey(name: 'reference')
  final dynamic reference;

  @JsonKey(name: 'client_order_ref')
  final dynamic clientOrderRef; // مرجع العميل

  @JsonKey(name: 'origin')
  final dynamic origin;

  // ==================== User & Team ====================

  @JsonKey(name: 'user_id')
  final dynamic userId; // مندوب المبيعات [id, name]

  @JsonKey(name: 'team_id')
  final dynamic teamId; // فريق المبيعات [id, name]

  @JsonKey(name: 'company_id')
  final dynamic companyId; // [id, name]

  // ==================== Delivery ====================

  @JsonKey(name: 'picking_ids')
  final dynamic pickingIds;

  @JsonKey(name: 'delivery_count')
  final dynamic deliveryCount;

  @JsonKey(name: 'warehouse_id')
  final dynamic warehouseId;

  @JsonKey(name: 'picking_policy')
  final dynamic pickingPolicy; // direct, one

  @JsonKey(name: 'incoterm')
  final dynamic incoterm;

  // ==================== Invoice ====================

  @JsonKey(name: 'invoice_count')
  final dynamic invoiceCount;

  @JsonKey(name: 'move_ids')
  final dynamic moveIds; // قائمة الفواتير

  // ==================== Template & Options ====================

  @JsonKey(name: 'sale_order_template_id')
  final dynamic saleOrderTemplateId;

  @JsonKey(name: 'sale_order_option_ids')
  final dynamic saleOrderOptionIds;

  // ==================== Signature ====================

  @JsonKey(name: 'require_signature')
  final dynamic requireSignature;

  @JsonKey(name: 'require_payment')
  final dynamic requirePayment;

  @JsonKey(name: 'signed_by')
  final dynamic signedBy;

  @JsonKey(name: 'signed_on')
  final dynamic signedOn;

  @JsonKey(name: 'signature')
  final dynamic signature;

  // ==================== Analytics ====================

  @JsonKey(name: 'analytic_account_id')
  final dynamic analyticAccountId;

  @JsonKey(name: 'campaign_id')
  final dynamic campaignId;

  @JsonKey(name: 'medium_id')
  final dynamic mediumId;

  @JsonKey(name: 'source_id')
  final dynamic sourceId;

  // ==================== Other ====================

  @JsonKey(name: 'expense_count')
  final dynamic expenseCount;

  @JsonKey(name: 'authorized_transaction_ids')
  final dynamic authorizedTransactionIds;

  @JsonKey(name: '__last_update')
  final dynamic lastUpdate;

  // ==================== Messages & Activities ====================

  @JsonKey(name: 'message_follower_ids')
  final dynamic messageFollowerIds;

  @JsonKey(name: 'activity_ids')
  final dynamic activityIds;

  @JsonKey(name: 'message_ids')
  final dynamic messageIds;

  @JsonKey(name: 'message_attachment_count')
  final dynamic messageAttachmentCount;

  const SaleOrderModel({
    super.id,
    super.odooId,
    super.createdAt,
    super.updatedAt,
    super.synced,
    super.syncStatus,
    this.name,
    this.displayName,
    this.state,
    this.invoiceStatus,
    this.partnerId,
    this.partnerInvoiceId,
    this.partnerShippingId,
    this.dateOrder,
    this.validityDate,
    this.commitmentDate,
    this.confirmationDate,
    this.expectedDate,
    this.effectiveDate,
    this.amountUntaxed,
    this.amountTax,
    this.amountTotal,
    this.margin,
    this.pricelistId,
    this.currencyId,
    this.paymentTermId,
    this.fiscalPositionId,
    this.orderLine,
    this.note,
    this.reference,
    this.clientOrderRef,
    this.origin,
    this.userId,
    this.teamId,
    this.companyId,
    this.pickingIds,
    this.deliveryCount,
    this.warehouseId,
    this.pickingPolicy,
    this.incoterm,
    this.invoiceCount,
    this.moveIds,
    this.saleOrderTemplateId,
    this.saleOrderOptionIds,
    this.requireSignature,
    this.requirePayment,
    this.signedBy,
    this.signedOn,
    this.signature,
    this.analyticAccountId,
    this.campaignId,
    this.mediumId,
    this.sourceId,
    this.expenseCount,
    this.authorizedTransactionIds,
    this.lastUpdate,
    this.messageFollowerIds,
    this.activityIds,
    this.messageIds,
    this.messageAttachmentCount,
  });

  // ==================== Getters ====================

  /// اسم الطلب
  String get orderName {
    if (name == null || name == false) return '';
    return name is String ? name as String : name.toString();
  }

  /// اسم العميل
  String? get partnerName {
    if (partnerId == null || partnerId == false) return null;
    if (partnerId is List && (partnerId as List).length >= 2) {
      return (partnerId as List)[1].toString();
    }
    return null;
  }

  /// ID العميل
  int? get partnerIdInt {
    if (partnerId == null || partnerId == false) return null;
    if (partnerId is List && (partnerId as List).isNotEmpty) {
      return (partnerId as List)[0] is int ? (partnerId as List)[0] : null;
    }
    if (partnerId is int) return partnerId;
    return null;
  }

  /// الحالة كنص
  String get stateLabel {
    if (state == null || state == false) return 'draft';
    return state.toString();
  }

  /// المبلغ الإجمالي كرقم
  double get totalAmount {
    if (amountTotal == null || amountTotal == false) return 0.0;
    if (amountTotal is num) return (amountTotal as num).toDouble();
    return 0.0;
  }

  /// المبلغ بدون ضريبة كرقم
  double get untaxedAmount {
    if (amountUntaxed == null || amountUntaxed == false) return 0.0;
    if (amountUntaxed is num) return (amountUntaxed as num).toDouble();
    return 0.0;
  }

  /// قيمة الضريبة كرقم
  double get taxAmount {
    if (amountTax == null || amountTax == false) return 0.0;
    if (amountTax is num) return (amountTax as num).toDouble();
    return 0.0;
  }

  /// هامش الربح كرقم
  double get profitMargin {
    if (margin == null || margin == false) return 0.0;
    if (margin is num) return (margin as num).toDouble();
    return 0.0;
  }

  /// هل الطلب مسودة؟
  bool get isDraft => stateLabel == 'draft';

  /// هل الطلب مرسل؟
  bool get isSent => stateLabel == 'sent';

  /// هل الطلب مؤكد؟
  bool get isConfirmed => stateLabel == 'sale';

  /// هل الطلب منجز؟
  bool get isDone => stateLabel == 'done';

  /// هل الطلب ملغي؟
  bool get isCancelled => stateLabel == 'cancel';

  /// حالة الفوترة
  String get invoiceStatusLabel {
    if (invoiceStatus == null || invoiceStatus == false) return 'no';
    return invoiceStatus.toString();
  }

  /// هل تم إصدار فاتورة؟
  bool get isInvoiced => invoiceStatusLabel == 'invoiced';

  /// هل يحتاج فاتورة؟
  bool get needsInvoice => invoiceStatusLabel == 'to invoice';

  /// عدد الفواتير
  int get invoicesCount {
    if (invoiceCount == null || invoiceCount == false) return 0;
    if (invoiceCount is int) return invoiceCount;
    return 0;
  }

  /// عدد عمليات التسليم
  int get deliveriesCount {
    if (deliveryCount == null || deliveryCount == false) return 0;
    if (deliveryCount is int) return deliveryCount;
    return 0;
  }

  /// اسم مندوب المبيعات
  String? get salesPersonName {
    if (userId == null || userId == false) return null;
    if (userId is List && (userId as List).length >= 2) {
      return (userId as List)[1].toString();
    }
    return null;
  }

  /// تاريخ الطلب كـ DateTime
  DateTime? get orderDate {
    if (dateOrder == null || dateOrder == false) return null;
    try {
      if (dateOrder is String) {
        return DateTime.parse(dateOrder as String);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// العملة
  String? get currencyName {
    if (currencyId == null || currencyId == false) return null;
    if (currencyId is List && (currencyId as List).length >= 2) {
      return (currencyId as List)[1].toString();
    }
    return null;
  }

  /// أسطر الطلب كـ List
  List<int> get orderLineIds {
    if (orderLine == null || orderLine == false) return [];
    if (orderLine is List) {
      return (orderLine as List)
          .where((item) => item is int)
          .map((item) => item as int)
          .toList();
    }
    return [];
  }

  /// عدد أسطر الطلب
  int get linesCount => orderLineIds.length;

  /// الملاحظات (آمنة من false)
  String? get noteText {
    if (note == null || note == false) return null;
    if (note is String && (note as String).isNotEmpty) {
      return note as String;
    }
    return null;
  }

  /// مرجع العميل (آمنة من false)
  String? get clientOrderRefText {
    if (clientOrderRef == null || clientOrderRef == false) return null;
    if (clientOrderRef is String && (clientOrderRef as String).isNotEmpty) {
      return clientOrderRef as String;
    }
    return null;
  }

  /// المرجع (آمنة من false)
  String? get referenceText {
    if (reference == null || reference == false) return null;
    if (reference is String && (reference as String).isNotEmpty) {
      return reference as String;
    }
    return null;
  }

  /// المبلغ الإجمالي منسق
  String get totalAmountFormatted {
    final currency = currencyName ?? '';
    return '$currency${totalAmount.toStringAsFixed(2)}';
  }

  /// المبلغ بدون ضريبة منسق
  String get untaxedAmountFormatted {
    final currency = currencyName ?? '';
    return '$currency${untaxedAmount.toStringAsFixed(2)}';
  }

  /// قيمة الضريبة منسقة
  String get taxAmountFormatted {
    final currency = currencyName ?? '';
    return '$currency${taxAmount.toStringAsFixed(2)}';
  }

  /// تاريخ الطلب منسق
  String? get dateOrderFormatted {
    final date = orderDate;
    if (date == null) return null;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// تاريخ التأكيد منسق
  String? get confirmationDateFormatted {
    if (confirmationDate == null || confirmationDate == false) return null;
    if (confirmationDate is String) {
      return confirmationDate as String;
    }
    return null;
  }

  /// تاريخ التسليم المتوقع منسق
  String? get expectedDateFormatted {
    if (expectedDate == null || expectedDate == false) return null;
    if (expectedDate is String) {
      return expectedDate as String;
    }
    return null;
  }

  /// اسم الفريق
  String? get teamName {
    if (teamId == null || teamId == false) return null;
    if (teamId is List && (teamId as List).length > 1) {
      return (teamId as List)[1] as String?;
    }
    return null;
  }

  // ==================== Serialization ====================

  factory SaleOrderModel.fromJson(Map<String, dynamic> json) {
    final model = _$SaleOrderModelFromJson(json);
    return SaleOrderModel(
      id: model.id,
      odooId: model.odooId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      synced: model.synced,
      syncStatus: model.syncStatus,
      name: model.name,
      displayName: model.displayName,
      state: model.state,
      invoiceStatus: model.invoiceStatus,
      partnerId: model.partnerId,
      partnerInvoiceId: model.partnerInvoiceId,
      partnerShippingId: model.partnerShippingId,
      dateOrder: model.dateOrder,
      validityDate: model.validityDate,
      commitmentDate: model.commitmentDate,
      confirmationDate: model.confirmationDate,
      expectedDate: model.expectedDate,
      effectiveDate: model.effectiveDate,
      amountUntaxed: model.amountUntaxed,
      amountTax: model.amountTax,
      amountTotal: model.amountTotal,
      margin: model.margin,
      pricelistId: model.pricelistId,
      currencyId: model.currencyId,
      paymentTermId: model.paymentTermId,
      fiscalPositionId: model.fiscalPositionId,
      orderLine: model.orderLine,
      note: model.note,
      reference: model.reference,
      clientOrderRef: model.clientOrderRef,
      origin: model.origin,
      userId: model.userId,
      teamId: model.teamId,
      companyId: model.companyId,
      pickingIds: model.pickingIds,
      deliveryCount: model.deliveryCount,
      warehouseId: model.warehouseId,
      pickingPolicy: model.pickingPolicy,
      incoterm: model.incoterm,
      invoiceCount: model.invoiceCount,
      moveIds: model.moveIds,
      saleOrderTemplateId: model.saleOrderTemplateId,
      saleOrderOptionIds: model.saleOrderOptionIds,
      requireSignature: model.requireSignature,
      requirePayment: model.requirePayment,
      signedBy: model.signedBy,
      signedOn: model.signedOn,
      signature: model.signature,
      analyticAccountId: model.analyticAccountId,
      campaignId: model.campaignId,
      mediumId: model.mediumId,
      sourceId: model.sourceId,
      expenseCount: model.expenseCount,
      authorizedTransactionIds: model.authorizedTransactionIds,
      lastUpdate: model.lastUpdate,
      messageFollowerIds: model.messageFollowerIds,
      activityIds: model.activityIds,
      messageIds: model.messageIds,
      messageAttachmentCount: model.messageAttachmentCount,
    );
  }

  @override
  Map<String, dynamic> toJson() => _$SaleOrderModelToJson(this);

  @override
  SaleOrderModel copyWith({
    int? id,
    int? odooId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
    SyncStatus? syncStatus,
    dynamic name,
    dynamic displayName,
    dynamic state,
    dynamic invoiceStatus,
    dynamic partnerId,
    dynamic amountTotal,
    dynamic dateOrder,
  }) {
    return SaleOrderModel(
      id: id ?? this.id,
      odooId: odooId ?? this.odooId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      syncStatus: syncStatus ?? this.syncStatus,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      state: state ?? this.state,
      invoiceStatus: invoiceStatus ?? this.invoiceStatus,
      partnerId: partnerId ?? this.partnerId,
      partnerInvoiceId: partnerInvoiceId,
      partnerShippingId: partnerShippingId,
      dateOrder: dateOrder ?? this.dateOrder,
      validityDate: validityDate,
      commitmentDate: commitmentDate,
      confirmationDate: confirmationDate,
      expectedDate: expectedDate,
      effectiveDate: effectiveDate,
      amountUntaxed: amountUntaxed,
      amountTax: amountTax,
      amountTotal: amountTotal ?? this.amountTotal,
      margin: margin,
      pricelistId: pricelistId,
      currencyId: currencyId,
      paymentTermId: paymentTermId,
      fiscalPositionId: fiscalPositionId,
      orderLine: orderLine,
      note: note,
      reference: reference,
      clientOrderRef: clientOrderRef,
      origin: origin,
      userId: userId,
      teamId: teamId,
      companyId: companyId,
      pickingIds: pickingIds,
      deliveryCount: deliveryCount,
      warehouseId: warehouseId,
      pickingPolicy: pickingPolicy,
      incoterm: incoterm,
      invoiceCount: invoiceCount,
      moveIds: moveIds,
      saleOrderTemplateId: saleOrderTemplateId,
      saleOrderOptionIds: saleOrderOptionIds,
      requireSignature: requireSignature,
      requirePayment: requirePayment,
      signedBy: signedBy,
      signedOn: signedOn,
      signature: signature,
      analyticAccountId: analyticAccountId,
      campaignId: campaignId,
      mediumId: mediumId,
      sourceId: sourceId,
      expenseCount: expenseCount,
      authorizedTransactionIds: authorizedTransactionIds,
      lastUpdate: lastUpdate,
      messageFollowerIds: messageFollowerIds,
      activityIds: activityIds,
      messageIds: messageIds,
      messageAttachmentCount: messageAttachmentCount,
    );
  }
}
