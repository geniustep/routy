// lib/screens/sales/saleorder/create/services/price_management_service.dart

import 'package:routy/models/products/product_list/pricelist_model.dart';
import 'package:routy/screens/sales/saleorder/create/widgets/product_line.dart';
import 'package:routy/utils/app_logger.dart';

/// 💰 Price Management Service - خدمة إدارة الأسعار
///
/// يدير:
/// - تطبيق قوائم الأسعار
/// - حساب الخصومات
/// - البحث عن القواعد المناسبة
/// - تطبيق الأسعار النهائية
class PriceManagementService {
  // ============= Singleton =============

  static final PriceManagementService _instance =
      PriceManagementService._internal();
  factory PriceManagementService() => _instance;
  PriceManagementService._internal();

  // ============= Price Calculation =============

  /// البحث عن القاعدة المناسبة للمنتج
  PricelistItemModel? findMatchingRule({
    required ProductLine line,
    required List<PricelistItemModel> rules,
  }) {
    if (line.productModel == null) {
      appLogger.warning('⚠️ Product model is null, cannot find matching rule');
      return null;
    }

    appLogger.info('\n🔍 ========== FINDING MATCHING RULE ==========');
    appLogger.info('Product: ${line.productName} (ID: ${line.productId})');
    appLogger.info('Available rules: ${rules.length}');

    // البحث عن قاعدة مطابقة للمنتج
    for (var rule in rules) {
      appLogger.info('\n📋 Checking rule: ${rule.id}');
      appLogger.info('   Product ID: ${rule.productId}');
      appLogger.info('   Product Name: ${rule.productName}');
      appLogger.info('   Fixed Price: ${rule.fixedPrice}');
      appLogger.info('   Min Quantity: ${rule.minQuantity}');
      appLogger.info('   Price: ${rule.price}');
      appLogger.info('   Discount: ${rule.discount}%');

      // التحقق من تطابق المنتج
      if (rule.productId == line.productId) {
        appLogger.info('   ✅ Product ID matches!');

        // التحقق من الحد الأدنى للكمية
        if (rule.minQuantity != null && line.quantity < rule.minQuantity!) {
          appLogger.info(
            '   ⚠️ Quantity ${line.quantity} < min ${rule.minQuantity}',
          );
          continue;
        }

        appLogger.info('   ✅ Rule found and applicable!');
        appLogger.info('==========================================\n');
        return rule;
      } else {
        appLogger.info('   ❌ Product ID does not match');
      }
    }

    appLogger.info('❌ No matching rule found');
    appLogger.info('==========================================\n');
    return null;
  }

  /// حساب السعر النهائي بناءً على القاعدة
  PriceCalculationResult calculatePrice({
    required ProductLine line,
    required PricelistItemModel rule,
  }) {
    appLogger.info('\n💰 ========== CALCULATING PRICE ==========');
    appLogger.info('Product: ${line.productName}');
    appLogger.info('Rule: ${rule.id}');
    appLogger.info('Original list price: ${line.listPrice}');
    appLogger.info('Rule fixed price: ${rule.fixedPrice}');
    appLogger.info('Rule price: ${rule.price}');
    appLogger.info('Rule discount: ${rule.discount}%');

    double finalPrice = line.listPrice;
    double discount = 0.0;
    bool hasAppliedRule = false;

    // تطبيق السعر الثابت إذا كان متوفراً
    if (rule.fixedPrice != null && rule.fixedPrice! > 0) {
      finalPrice = rule.fixedPrice!;
      discount = ((line.listPrice - finalPrice) / line.listPrice * 100).clamp(
        0.0,
        100.0,
      );
      hasAppliedRule = true;

      appLogger.info('✅ Applied fixed price: $finalPrice');
      appLogger.info('   Calculated discount: ${discount.toStringAsFixed(1)}%');
    }
    // تطبيق السعر المخصص إذا كان متوفراً
    else if (rule.price != null && rule.price! > 0) {
      finalPrice = rule.price!;
      discount = ((line.listPrice - finalPrice) / line.listPrice * 100).clamp(
        0.0,
        100.0,
      );
      hasAppliedRule = true;

      appLogger.info('✅ Applied custom price: $finalPrice');
      appLogger.info('   Calculated discount: ${discount.toStringAsFixed(1)}%');
    }
    // تطبيق الخصم إذا كان متوفراً
    else if (rule.discount != null && rule.discount! > 0) {
      discount = rule.discount!.clamp(0.0, 100.0);
      finalPrice = line.listPrice * (1 - discount / 100);
      hasAppliedRule = true;

      appLogger.info('✅ Applied discount: ${discount.toStringAsFixed(1)}%');
      appLogger.info('   Calculated price: $finalPrice');
    }

    if (hasAppliedRule) {
      appLogger.info('✅ Price calculation completed:');
      appLogger.info('   Final price: $finalPrice');
      appLogger.info('   Discount: ${discount.toStringAsFixed(1)}%');
      appLogger.info(
        '   Savings per unit: ${(line.listPrice - finalPrice).toStringAsFixed(2)}',
      );
      appLogger.info(
        '   Total savings: ${((line.listPrice - finalPrice) * line.quantity).toStringAsFixed(2)}',
      );
    } else {
      appLogger.info('ℹ️ No price rule applied, keeping original price');
    }

    appLogger.info('==========================================\n');

    return PriceCalculationResult(
      finalPrice: finalPrice,
      discount: discount,
      hasAppliedRule: hasAppliedRule,
      appliedRule: rule,
    );
  }

  // ============= Bulk Price Updates =============

  /// تطبيق قائمة أسعار على جميع المنتجات
  Future<List<PriceUpdateResult>> applyPriceListToAllProducts({
    required List<ProductLine> productLines,
    required List<PricelistItemModel> rules,
  }) async {
    appLogger.info(
      '\n🔄 ========== APPLYING PRICE LIST TO ALL PRODUCTS ==========',
    );
    appLogger.info('Products count: ${productLines.length}');
    appLogger.info('Rules count: ${rules.length}');

    final results = <PriceUpdateResult>[];

    for (var line in productLines) {
      if (line.productModel == null) {
        appLogger.warning('⚠️ Skipping line with null product model');
        continue;
      }

      final rule = findMatchingRule(line: line, rules: rules);

      if (rule != null) {
        final calculation = calculatePrice(line: line, rule: rule);

        if (calculation.hasAppliedRule) {
          results.add(
            PriceUpdateResult(
              productLine: line,
              oldPrice: line.priceUnit,
              newPrice: calculation.finalPrice,
              oldDiscount: line.discountPercentage,
              newDiscount: calculation.discount,
              appliedRule: rule,
            ),
          );
        }
      }
    }

    appLogger.info('✅ Price list application completed');
    appLogger.info('   Updated products: ${results.length}');
    appLogger.info(
      '========================================================\n',
    );

    return results;
  }

  // ============= Validation =============

  /// التحقق من صحة قائمة الأسعار
  bool validatePriceList(List<PricelistItemModel> rules) {
    if (rules.isEmpty) {
      appLogger.warning('⚠️ Price list is empty');
      return false;
    }

    for (var rule in rules) {
      if (rule.productId == null) {
        appLogger.warning('⚠️ Rule ${rule.id} has null product ID');
        return false;
      }
    }

    appLogger.info('✅ Price list validation passed');
    return true;
  }
}

// ============= Result Classes =============

/// نتيجة حساب السعر
class PriceCalculationResult {
  final double finalPrice;
  final double discount;
  final bool hasAppliedRule;
  final PricelistItemModel? appliedRule;

  PriceCalculationResult({
    required this.finalPrice,
    required this.discount,
    required this.hasAppliedRule,
    this.appliedRule,
  });
}

/// نتيجة تحديث السعر
class PriceUpdateResult {
  final ProductLine productLine;
  final double oldPrice;
  final double newPrice;
  final double oldDiscount;
  final double newDiscount;
  final PricelistItemModel appliedRule;

  PriceUpdateResult({
    required this.productLine,
    required this.oldPrice,
    required this.newPrice,
    required this.oldDiscount,
    required this.newDiscount,
    required this.appliedRule,
  });

  bool get hasPriceChanged => oldPrice != newPrice;
  bool get hasDiscountChanged => oldDiscount != newDiscount;
  double get priceDifference => newPrice - oldPrice;
  double get discountDifference => newDiscount - oldDiscount;
}
