// lib/screens/sales/saleorder/create/services/order_validation_service.dart

import 'package:routy/screens/sales/saleorder/create/widgets/product_line.dart';
import 'package:routy/models/partners/partners_model.dart';
import 'package:routy/models/products/product_list/pricelist_model.dart';
import 'package:routy/models/common/payment_term_model.dart';
import 'package:routy/utils/app_logger.dart';

/// ✅ Order Validation Service - خدمة التحقق من صحة أوامر البيع
///
/// يدير:
/// - التحقق من صحة البيانات
/// - التحقق من المنتجات
/// - التحقق من العملاء
/// - التحقق من الأسعار
/// - التحقق من الخصومات
class OrderValidationService {
  // ============= Singleton =============

  static final OrderValidationService _instance =
      OrderValidationService._internal();
  factory OrderValidationService() => _instance;
  OrderValidationService._internal();

  // ============= Order Validation =============

  /// التحقق من صحة أمر البيع الكامل
  ValidationResult validateOrder({
    required PartnerModel? partner,
    required List<ProductLine> productLines,
    required PricelistModel? priceList,
    required PaymentTermModel? paymentTerm,
    required Map<String, dynamic> orderData,
  }) {
    appLogger.info('\n✅ ========== VALIDATING ORDER ==========');
    appLogger.info('Partner: ${partner?.name ?? 'None'}');
    appLogger.info('Product lines: ${productLines.length}');
    appLogger.info('Price list: ${priceList?.pricelistName ?? 'None'}');
    appLogger.info('Payment term: ${paymentTerm?.paymentTermName ?? 'None'}');

    final errors = <String>[];
    final warnings = <String>[];

    // التحقق من العميل
    final partnerValidation = _validatePartner(partner);
    if (!partnerValidation.isValid) {
      errors.addAll(partnerValidation.errors);
    }
    warnings.addAll(partnerValidation.warnings);

    // التحقق من المنتجات
    final productsValidation = _validateProductLines(productLines);
    if (!productsValidation.isValid) {
      errors.addAll(productsValidation.errors);
    }
    warnings.addAll(productsValidation.warnings);

    // التحقق من قائمة الأسعار
    final priceListValidation = _validatePriceList(priceList);
    if (!priceListValidation.isValid) {
      errors.addAll(priceListValidation.errors);
    }
    warnings.addAll(priceListValidation.warnings);

    // التحقق من شروط الدفع
    final paymentTermValidation = _validatePaymentTerm(paymentTerm);
    if (!paymentTermValidation.isValid) {
      errors.addAll(paymentTermValidation.errors);
    }
    warnings.addAll(paymentTermValidation.warnings);

    // التحقق من البيانات الإضافية
    final orderDataValidation = _validateOrderData(orderData);
    if (!orderDataValidation.isValid) {
      errors.addAll(orderDataValidation.errors);
    }
    warnings.addAll(orderDataValidation.warnings);

    final isValid = errors.isEmpty;

    appLogger.info('✅ Order validation completed');
    appLogger.info('   Valid: $isValid');
    appLogger.info('   Errors: ${errors.length}');
    appLogger.info('   Warnings: ${warnings.length}');
    appLogger.info('==========================================\n');

    return ValidationResult(
      isValid: isValid,
      errors: errors,
      warnings: warnings,
    );
  }

  // ============= Partner Validation =============

  /// التحقق من صحة العميل
  ValidationResult _validatePartner(PartnerModel? partner) {
    final errors = <String>[];
    final warnings = <String>[];

    if (partner == null) {
      errors.add('يجب اختيار العميل');
      return ValidationResult(
        isValid: false,
        errors: errors,
        warnings: warnings,
      );
    }

    // التحقق من اسم العميل
    if (partner.name == null || partner.name!.isEmpty) {
      errors.add('اسم العميل مطلوب');
    }

    // التحقق من نوع العميل
    if (partner.isCompany == false) {
      warnings.add('العميل ليس شركة');
    }

    // التحقق من البريد الإلكتروني
    if (partner.email == null || partner.email!.isEmpty) {
      warnings.add('البريد الإلكتروني للعميل غير محدد');
    }

    // التحقق من الهاتف
    if (partner.phone == null || partner.phone!.isEmpty) {
      warnings.add('رقم الهاتف للعميل غير محدد');
    }

    appLogger.info('✅ Partner validation completed');
    appLogger.info('   Errors: ${errors.length}');
    appLogger.info('   Warnings: ${warnings.length}');

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // ============= Product Lines Validation =============

  /// التحقق من صحة أسطر المنتجات
  ValidationResult _validateProductLines(List<ProductLine> productLines) {
    final errors = <String>[];
    final warnings = <String>[];

    if (productLines.isEmpty) {
      errors.add('يجب إضافة منتج واحد على الأقل');
      return ValidationResult(
        isValid: false,
        errors: errors,
        warnings: warnings,
      );
    }

    for (var i = 0; i < productLines.length; i++) {
      final line = productLines[i];
      final lineNumber = i + 1;

      // التحقق من المنتج
      if (line.productModel == null) {
        errors.add('منتج رقم $lineNumber: يجب تحديد المنتج');
        continue;
      }

      // التحقق من الكمية
      if (line.quantity <= 0) {
        errors.add('منتج رقم $lineNumber: يجب تحديد كمية صحيحة');
      }

      // التحقق من السعر
      if (line.priceUnit < 0) {
        errors.add('منتج رقم $lineNumber: يجب تحديد سعر صحيح');
      }

      // التحقق من الخصم
      if (line.discountPercentage < 0 || line.discountPercentage > 100) {
        errors.add('منتج رقم $lineNumber: يجب تحديد خصم صحيح (0-100%)');
      }

      // التحقق من السعر النهائي
      if (line.getTotalPrice() <= 0) {
        errors.add(
          'منتج رقم $lineNumber: السعر النهائي يجب أن يكون أكبر من صفر',
        );
      }

      // التحقق من الخصم المفرط
      if (line.discountPercentage > 50) {
        warnings.add(
          'منتج رقم $lineNumber: خصم مرتفع (${line.discountPercentage.toStringAsFixed(1)}%)',
        );
      }

      // التحقق من الكمية الكبيرة
      if (line.quantity > 1000) {
        warnings.add('منتج رقم $lineNumber: كمية كبيرة (${line.quantity})');
      }
    }

    appLogger.info('✅ Product lines validation completed');
    appLogger.info('   Total lines: ${productLines.length}');
    appLogger.info('   Errors: ${errors.length}');
    appLogger.info('   Warnings: ${warnings.length}');

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // ============= Price List Validation =============

  /// التحقق من صحة قائمة الأسعار
  ValidationResult _validatePriceList(PricelistModel? priceList) {
    final errors = <String>[];
    final warnings = <String>[];

    if (priceList == null) {
      warnings.add('لم يتم اختيار قائمة أسعار');
      return ValidationResult(
        isValid: true,
        errors: errors,
        warnings: warnings,
      );
    }

    // التحقق من نشاط قائمة الأسعار
    if (!priceList.isActive) {
      errors.add('قائمة الأسعار المختارة غير نشطة');
    }

    // التحقق من وجود قواعد
    if (!priceList.hasRules) {
      warnings.add('قائمة الأسعار المختارة لا تحتوي على قواعد');
    }

    // التحقق من العملة
    if (priceList.currencyName == null) {
      warnings.add('عملة قائمة الأسعار غير محددة');
    }

    appLogger.info('✅ Price list validation completed');
    appLogger.info('   Price list: ${priceList.pricelistName}');
    appLogger.info('   Active: ${priceList.isActive}');
    appLogger.info('   Rules: ${priceList.rulesCount}');
    appLogger.info('   Errors: ${errors.length}');
    appLogger.info('   Warnings: ${warnings.length}');

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // ============= Payment Term Validation =============

  /// التحقق من صحة شروط الدفع
  ValidationResult _validatePaymentTerm(PaymentTermModel? paymentTerm) {
    final errors = <String>[];
    final warnings = <String>[];

    if (paymentTerm == null) {
      warnings.add('لم يتم اختيار شروط الدفع');
      return ValidationResult(
        isValid: true,
        errors: errors,
        warnings: warnings,
      );
    }

    // التحقق من نشاط شروط الدفع
    if (!paymentTerm.isActive) {
      errors.add('شروط الدفع المختارة غير نشطة');
    }

    // التحقق من وجود شروط
    if (!paymentTerm.hasLines) {
      warnings.add('شروط الدفع المختارة لا تحتوي على شروط');
    }

    appLogger.info('✅ Payment term validation completed');
    appLogger.info('   Payment term: ${paymentTerm.paymentTermName}');
    appLogger.info('   Active: ${paymentTerm.isActive}');
    appLogger.info('   Lines: ${paymentTerm.linesCount}');
    appLogger.info('   Errors: ${errors.length}');
    appLogger.info('   Warnings: ${warnings.length}');

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // ============= Order Data Validation =============

  /// التحقق من صحة بيانات الطلب
  ValidationResult _validateOrderData(Map<String, dynamic> orderData) {
    final errors = <String>[];
    final warnings = <String>[];

    // التحقق من تاريخ الطلب
    if (orderData['date_order'] == null) {
      warnings.add('تاريخ الطلب غير محدد');
    }

    // التحقق من تاريخ التسليم
    if (orderData['commitment_date'] != null) {
      final commitmentDate = DateTime.tryParse(orderData['commitment_date']);
      if (commitmentDate != null) {
        final now = DateTime.now();
        if (commitmentDate.isBefore(now)) {
          warnings.add('تاريخ التسليم في الماضي');
        }
      }
    }

    // التحقق من الملاحظات
    if (orderData['note'] != null &&
        orderData['note'].toString().length > 1000) {
      warnings.add('الملاحظات طويلة جداً (أكثر من 1000 حرف)');
    }

    appLogger.info('✅ Order data validation completed');
    appLogger.info('   Errors: ${errors.length}');
    appLogger.info('   Warnings: ${warnings.length}');

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // ============= Quick Validation =============

  /// التحقق السريع من صحة البيانات الأساسية
  bool quickValidate({
    required PartnerModel? partner,
    required List<ProductLine> productLines,
  }) {
    if (partner == null) return false;
    if (productLines.isEmpty) return false;

    for (var line in productLines) {
      if (line.productModel == null) return false;
      if (line.quantity <= 0) return false;
      if (line.priceUnit < 0) return false;
    }

    return true;
  }

  // ============= Business Rules Validation =============

  /// التحقق من قواعد العمل
  ValidationResult validateBusinessRules({
    required List<ProductLine> productLines,
    required PartnerModel? partner,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // التحقق من الحد الأدنى للطلب
    final totalAmount = productLines.fold(
      0.0,
      (sum, line) => sum + line.getTotalPrice(),
    );
    if (totalAmount < 100) {
      warnings.add('إجمالي الطلب أقل من 100 درهم');
    }

    // التحقق من عدد المنتجات
    if (productLines.length > 50) {
      warnings.add('عدد المنتجات كبير جداً (${productLines.length})');
    }

    // التحقق من الخصم الإجمالي
    final totalDiscount = productLines.fold(
      0.0,
      (sum, line) => sum + line.getSavings(),
    );
    final discountPercentage = totalAmount > 0
        ? (totalDiscount / totalAmount * 100)
        : 0;

    if (discountPercentage > 30) {
      warnings.add(
        'الخصم الإجمالي مرتفع (${discountPercentage.toStringAsFixed(1)}%)',
      );
    }

    appLogger.info('✅ Business rules validation completed');
    appLogger.info('   Total amount: ${totalAmount.toStringAsFixed(2)}');
    appLogger.info('   Total discount: ${totalDiscount.toStringAsFixed(2)}');
    appLogger.info(
      '   Discount percentage: ${discountPercentage.toStringAsFixed(1)}%',
    );
    appLogger.info('   Errors: ${errors.length}');
    appLogger.info('   Warnings: ${warnings.length}');

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

// ============= Result Classes =============

/// نتيجة التحقق من الصحة
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasIssues => hasErrors || hasWarnings;

  String get summary {
    if (isValid && !hasWarnings) {
      return 'البيانات صحيحة';
    } else if (isValid && hasWarnings) {
      return 'البيانات صحيحة مع ${warnings.length} تحذير';
    } else {
      return '${errors.length} خطأ و ${warnings.length} تحذير';
    }
  }
}
