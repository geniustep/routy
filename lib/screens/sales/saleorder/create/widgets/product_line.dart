// lib/screens/sales/saleorder/create/widgets/product_line.dart

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:routy/models/products/product_model.dart';
import 'package:routy/utils/app_logger.dart';

/// 🛒 Product Line - سطر منتج في أمر البيع
///
/// يدير:
/// - بيانات المنتج
/// - الكمية والسعر
/// - الخصم
/// - الحسابات
class ProductLine {
  // ============= Properties =============

  final Key key;
  final int productId;
  final String productName;
  final List<ProductModel> availableProducts;

  // Controllers
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();

  // State
  ProductModel? productModel;
  int quantity = 1;
  double listPrice = 0.0;
  double priceUnit = 0.0;
  double discountPercentage = 0.0;

  // Form Key
  GlobalKey<FormBuilderState>? formKey;

  // ============= Constructor =============

  ProductLine({
    required this.key,
    required this.productId,
    required this.productName,
    required this.availableProducts,
    int defaultQuantity = 1,
    double defaultPrice = 0.0,
    double defaultDiscount = 0.0,
  }) {
    quantity = defaultQuantity;
    priceUnit = defaultPrice;
    discountPercentage = defaultDiscount;

    // Initialize controllers
    quantityController.text = quantity.toString();
    priceController.text = priceUnit.toStringAsFixed(2);
    discountController.text = discountPercentage.toStringAsFixed(1);

    appLogger.info('🛒 ProductLine created: $productName');
  }

  // ============= Product Management =============

  void setProduct(ProductModel product) {
    productModel = product;
    listPrice = product.listPrice ?? 0.0;

    // إذا لم يكن هناك سعر محدد، استخدم سعر القائمة
    if (priceUnit == 0.0) {
      priceUnit = listPrice;
      priceController.text = priceUnit.toStringAsFixed(2);
    }

    appLogger.info('✅ Product set: ${product.name}');
    appLogger.info('   List price: $listPrice');
    appLogger.info('   Unit price: $priceUnit');
  }

  // ============= Quantity Management =============

  void updateQuantity(double newQuantity) {
    quantity = newQuantity.toInt();
    quantityController.text = quantity.toString();

    appLogger.info('📊 Quantity updated: $quantity');
  }

  // ============= Price Management =============

  void updatePrice(double newPrice) {
    priceUnit = newPrice;
    priceController.text = priceUnit.toStringAsFixed(2);

    // إعادة حساب الخصم
    if (listPrice > 0) {
      discountPercentage = ((listPrice - priceUnit) / listPrice * 100).clamp(
        0.0,
        100.0,
      );
      discountController.text = discountPercentage.toStringAsFixed(1);
    }

    appLogger.info('💰 Price updated: $priceUnit');
    appLogger.info('   Discount: ${discountPercentage.toStringAsFixed(1)}%');
  }

  void updateDiscount(double newDiscount) {
    discountPercentage = newDiscount.clamp(0.0, 100.0);
    discountController.text = discountPercentage.toStringAsFixed(1);

    // إعادة حساب السعر
    if (listPrice > 0) {
      priceUnit = listPrice * (1 - discountPercentage / 100);
      priceController.text = priceUnit.toStringAsFixed(2);
    }

    appLogger.info(
      '🎯 Discount updated: ${discountPercentage.toStringAsFixed(1)}%',
    );
    appLogger.info('   New price: $priceUnit');
  }

  // ============= Price Application =============

  void applyPriceAndDiscount({
    required double price,
    required double discount,
  }) {
    priceUnit = price;
    discountPercentage = discount;

    priceController.text = priceUnit.toStringAsFixed(2);
    discountController.text = discountPercentage.toStringAsFixed(1);

    appLogger.info('✅ Price and discount applied:');
    appLogger.info('   Price: $priceUnit');
    appLogger.info('   Discount: ${discountPercentage.toStringAsFixed(1)}%');
  }

  // ============= Calculations =============

  double getTotalPrice() {
    return priceUnit * quantity;
  }

  double getSavings() {
    if (listPrice <= 0) return 0.0;
    return (listPrice - priceUnit) * quantity;
  }

  double getOriginalTotal() {
    return listPrice * quantity;
  }

  // ============= Validation =============

  bool isValid() {
    return productModel != null &&
        quantity > 0 &&
        priceUnit >= 0 &&
        discountPercentage >= 0 &&
        discountPercentage <= 100;
  }

  // ============= Form Management =============

  void setFormKey(GlobalKey<FormBuilderState> key) {
    formKey = key;
  }

  bool validateForm() {
    if (formKey?.currentState == null) return true;
    return formKey!.currentState!.validate();
  }

  void saveForm() {
    if (formKey?.currentState == null) return;
    formKey!.currentState!.save();
  }

  // ============= Data Export =============

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'listPrice': listPrice,
      'priceUnit': priceUnit,
      'discountPercentage': discountPercentage,
      'totalPrice': getTotalPrice(),
      'savings': getSavings(),
    };
  }

  // ============= Disposal =============

  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    discountController.dispose();

    appLogger.info('🗑️ ProductLine disposed: $productName');
  }

  // ============= Debug Info =============

  @override
  String toString() {
    return 'ProductLine{'
        'productId: $productId, '
        'productName: $productName, '
        'quantity: $quantity, '
        'listPrice: $listPrice, '
        'priceUnit: $priceUnit, '
        'discountPercentage: ${discountPercentage.toStringAsFixed(1)}%, '
        'totalPrice: ${getTotalPrice().toStringAsFixed(2)}'
        '}';
  }
}
