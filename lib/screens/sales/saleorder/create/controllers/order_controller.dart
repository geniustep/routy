// lib/screens/sales/saleorder/create/controllers/order_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routy/models/products/product_model.dart';
import 'package:routy/models/products/product_list/pricelist_model.dart';
import 'package:routy/screens/sales/saleorder/create/widgets/product_line.dart';
import 'package:routy/screens/sales/saleorder/create/services/price_management_service.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:routy/utils/app_logger.dart';

/// 🛒 Order Controller - تحكم في أوامر البيع
///
/// يدير:
/// - المنتجات في الطلب
/// - الأسعار والخصومات
/// - قوائم الأسعار
/// - الحسابات والإجماليات
class OrderController extends GetxController {
  // ============= State =============

  final RxList<ProductLine> productLines = <ProductLine>[].obs;
  final RxSet<int> selectedProductIds = <int>{}.obs;
  final RxInt editingLineIndex = (-1).obs;
  final RxDouble orderTotal = 0.0.obs;
  final Map<int, GlobalKey<FormBuilderState>> lineFormKeys = {};

  List<ProductModel> availableProducts = [];
  dynamic selectedPriceListId;
  List<PricelistModel> priceLists = [];

  // ============= Performance Optimization =============
  bool _isBatchUpdating = false;
  Timer? _updateTimer;
  Timer? _totalCalculationTimer;

  // ============= Services =============
  final PriceManagementService _priceService = PriceManagementService();

  // ============= Lifecycle =============

  @override
  void onInit() {
    super.onInit();
    appLogger.info('✅ OrderController initialized');
  }

  @override
  void onClose() {
    // إلغاء الـ timers
    _updateTimer?.cancel();
    _totalCalculationTimer?.cancel();

    for (var line in productLines) {
      line.dispose();
    }
    appLogger.info('🗑️ OrderController disposed');
    super.onClose();
  }

  // ============= Initialization =============

  void initialize({
    required List<ProductModel> products,
    required List<PricelistModel> allPriceLists,
    dynamic priceListId,
  }) {
    availableProducts = products;
    priceLists = allPriceLists;
    selectedPriceListId = priceListId;

    appLogger.info('📦 OrderController initialized with:');
    appLogger.info('   Products: ${products.length}');
    appLogger.info('   Price Lists: ${allPriceLists.length}');
    appLogger.info('   Selected Price List: $priceListId');
  }

  // ============= Performance Optimization Methods =============

  /// جدولة التحديث مع debounce لتقليل التحديثات
  void _scheduleUpdate() {
    if (_isBatchUpdating) return;

    _updateTimer?.cancel();
    _updateTimer = Timer(const Duration(milliseconds: 100), () {
      _isBatchUpdating = true;
      _calculateTotal();
      update(['product_lines']);
      _isBatchUpdating = false;
    });
  }

  /// تحديث الكمية مع batch update
  void updateQuantity(int index, double quantity) {
    if (index >= 0 && index < productLines.length) {
      productLines[index].updateQuantity(quantity);
      _scheduleUpdate();
    }
  }

  /// تحديث السعر مع batch update
  void updatePrice(int index, double price) {
    if (index >= 0 && index < productLines.length) {
      productLines[index].updatePrice(price);
      _scheduleUpdate();
    }
  }

  /// تحديث الخصم مع batch update
  void updateDiscount(int index, double discount) {
    if (index >= 0 && index < productLines.length) {
      productLines[index].updateDiscount(discount);
      _scheduleUpdate();
    }
  }

  // ============= Product Management =============

  Future<void> addProduct(ProductModel product) async {
    appLogger.info('\n➕ Adding product: ${product.name} (ID: ${product.id})');

    if (selectedProductIds.contains(product.id)) {
      appLogger.warning('⚠️ Product already exists');
      return;
    }

    final line = ProductLine(
      key: UniqueKey(),
      productId: product.id ?? 0,
      productName: product.name ?? '',
      availableProducts: availableProducts,
    );

    line.setProduct(product);

    productLines.add(line);
    selectedProductIds.add(product.id ?? 0);

    final formKey = GlobalKey<FormBuilderState>();
    lineFormKeys[productLines.length - 1] = formKey;
    line.setFormKey(formKey);

    // استخدام await إذا كانت هناك قوائم أسعار
    if (priceLists.isNotEmpty && selectedPriceListId != null) {
      await updateLinePrice(line);
    } else {
      // إذا لم تكن هناك قوائم أسعار، نحدث الإجمالي مباشرة
      _calculateTotal();
    }

    // تحديث UI
    update(['product_lines']);

    appLogger.info('✅ Product added successfully');
    appLogger.info('   Total products: ${productLines.length}');
    appLogger.info(
      '   Total amount: ${orderTotal.value.toStringAsFixed(2)} Dh',
    );
  }

  Future<void> _applyPriceListToLine(ProductLine line) async {
    if (selectedPriceListId == null ||
        line.productModel == null ||
        priceLists.isEmpty) {
      return;
    }

    try {
      appLogger.info('💰 Applying pricelist to: ${line.productName}');

      // البحث عن قائمة الأسعار
      final priceList = priceLists.firstWhereOrNull(
        (p) => p.id == selectedPriceListId,
      );

      if (priceList == null ||
          priceList.items == null ||
          priceList.items!.isEmpty) {
        return;
      }

      // استخدام الخدمة الجديدة للبحث عن القاعدة المناسبة
      final matchingRule = _priceService.findMatchingRule(
        line: line,
        rules: priceList.items!,
      );

      if (matchingRule != null) {
        // استخدام الخدمة الجديدة لحساب السعر
        final result = _priceService.calculatePrice(
          line: line,
          rule: matchingRule,
        );

        if (result.hasAppliedRule) {
          // تطبيق السعر النهائي
          line.applyPriceAndDiscount(
            price: result.finalPrice,
            discount: result.discount,
          );

          appLogger.info('   ✅ Price applied: ${line.priceUnit} Dh');
        }
      }
    } catch (e) {
      appLogger.error('   ❌ Error applying pricelist: $e');
      appLogger.error('   Stack trace: ${StackTrace.current}');
    }
  }

  // ============= Price List Updates =============

  /// تحديث أسعار جميع المنتجات بقائمة أسعار جديدة
  Future<void> updateAllProductsPrices(int priceListId) async {
    // التحقق من وجود قوائم أسعار قبل التحديث
    if (priceLists.isEmpty) {
      appLogger.warning('⚠️ No price lists available - skipping price updates');
      return;
    }

    if (productLines.isEmpty) {
      appLogger.warning('⚠️ No products to update');
      return;
    }

    appLogger.info('\n🔄 ========== UPDATING ALL PRICES ==========');
    appLogger.info('New Pricelist ID: $priceListId');
    appLogger.info('Products count: ${productLines.length}');
    appLogger.info('Available price lists: ${priceLists.length}');

    selectedPriceListId = priceListId;

    // عرض dialog التحديث
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحديث الأسعار...'),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    int completed = 0;
    int updated = 0;

    for (var line in productLines) {
      if (line.productModel != null) {
        final oldPrice = line.priceUnit;
        final oldDiscount = line.discountPercentage;

        await _applyPriceListToLine(line);

        if (line.priceUnit != oldPrice ||
            line.discountPercentage != oldDiscount) {
          updated++;

          appLogger.info('   ✅ ${line.productName}:');
          appLogger.info(
            '      Old: ${oldPrice.toStringAsFixed(2)} Dh (-${oldDiscount.toStringAsFixed(1)}%)',
          );
          appLogger.info(
            '      New: ${line.priceUnit.toStringAsFixed(2)} Dh (-${line.discountPercentage.toStringAsFixed(1)}%)',
          );
        }
      }
      completed++;
    }

    // إغلاق Dialog
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    // تحديث UI مرة واحدة فقط بعد الانتهاء من كل المنتجات
    update(['product_lines']);
    _calculateTotal();

    // عرض رسالة النجاح فقط إذا تم تحديث شيء
    if (updated > 0) {
      Get.snackbar(
        'تم التحديث',
        'تم تحديث $updated من $completed منتج',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    }

    appLogger.info('\n✅ ========== PRICES UPDATE COMPLETE ==========');
    appLogger.info('Updated: $updated / $completed products');
    appLogger.info('New Total: ${orderTotal.value.toStringAsFixed(2)} Dh');
    appLogger.info('=========================================\n');
  }

  /// تحديث السعر لمنتج واحد
  Future<void> updateLinePrice(ProductLine line) async {
    await _applyPriceListToLine(line);
    // تحديث الإجمالي يدوياً
    _calculateTotal();
  }

  // ============= Line Editing =============

  void editLine(int index) {
    appLogger.info('\n✏️ Editing line $index');

    if (editingLineIndex.value != -1) {
      saveLineEditing();
    }

    editingLineIndex.value = index;
  }

  void saveLineEditing() {
    if (editingLineIndex.value == -1) return;

    final line = productLines[editingLineIndex.value];

    appLogger.info('\n💾 Saving line edits');
    appLogger.info('   Product: ${line.productName}');
    appLogger.info('   Quantity: ${line.quantity}');
    appLogger.info('   Price: ${line.priceUnit} Dh');
    appLogger.info('   Discount: ${line.discountPercentage}%');

    editingLineIndex.value = -1;

    // تحديث UI
    update(['product_lines']);

    // تحديث الإجمالي يدوياً
    _calculateTotal();
  }

  void cancelEditing() {
    appLogger.info('\n❌ Canceling line edits');

    editingLineIndex.value = -1;

    // تحديث UI
    update(['product_lines']);
  }

  // ============= Line Management =============

  void deleteLine(int index) {
    appLogger.info('\n🗑️ Deleting line $index');

    if (index < 0 || index >= productLines.length) {
      appLogger.error('❌ Invalid index: $index');
      return;
    }

    final line = productLines[index];
    selectedProductIds.remove(line.productId);
    line.dispose();

    productLines.removeAt(index);
    lineFormKeys.remove(index);

    final keysToUpdate = <int, GlobalKey<FormBuilderState>>{};
    for (var i = index; i < productLines.length; i++) {
      if (lineFormKeys.containsKey(i + 1)) {
        keysToUpdate[i] = lineFormKeys[i + 1]!;
      }
    }
    lineFormKeys.removeWhere((key, value) => key > index);
    keysToUpdate.forEach((key, value) {
      lineFormKeys[key] = value;
    });

    // تحديث UI
    update(['product_lines']);

    // تحديث الإجمالي يدوياً
    _calculateTotal();

    appLogger.info('✅ Line deleted');
    appLogger.info('   Remaining products: ${productLines.length}');
    appLogger.info('   Total: ${orderTotal.value.toStringAsFixed(2)} Dh');
  }

  // ============= Calculations =============

  void _calculateTotal() {
    if (_isBatchUpdating) return;

    final total = productLines.fold<double>(
      0.0,
      (sum, line) => sum + line.getTotalPrice(),
    );

    orderTotal.value = total;
  }

  double getOrderTotal() {
    return orderTotal.value;
  }

  double getOrderSubtotal() {
    return productLines.fold(0.0, (sum, line) {
      return sum + (line.listPrice * line.quantity);
    });
  }

  double getOrderDiscount() {
    return getOrderSubtotal() - getOrderTotal();
  }

  double getOrderSavings() {
    return productLines.fold(0.0, (sum, line) => sum + line.getSavings());
  }

  // ============= Validation =============

  bool validateAllLines() {
    appLogger.info('\n🔍 Validating all product lines...');

    if (productLines.isEmpty) {
      appLogger.error('❌ No products to validate');
      return false;
    }

    for (var i = 0; i < productLines.length; i++) {
      final line = productLines[i];

      if (line.productModel == null) {
        appLogger.error('❌ Line $i: Product model is null');
        return false;
      }

      if (line.quantity <= 0) {
        appLogger.error('❌ Line $i: Invalid quantity (${line.quantity})');
        return false;
      }

      if (line.priceUnit < 0) {
        appLogger.error('❌ Line $i: Invalid price (${line.priceUnit})');
        return false;
      }

      appLogger.info('✅ Line $i valid: ${line.productName} x${line.quantity}');
    }

    appLogger.info('✅ All lines validated successfully');

    return true;
  }

  // ============= Data Retrieval =============

  List<Map<String, dynamic>> getProductLinesData() {
    appLogger.info('\n💾 ========== SAVING DRAFT DATA ==========');

    return productLines.map((line) {
      appLogger.info('Product: ${line.productName}');
      appLogger.info('  listPrice: ${line.listPrice}');
      appLogger.info('  priceUnit: ${line.priceUnit}');
      appLogger.info('  discountPercentage: ${line.discountPercentage}%');
      appLogger.info('  quantity: ${line.quantity}');
      appLogger.info('  total: ${line.getTotalPrice()} Dh');

      return {
        'productId': line.productModel?.id ?? line.productId,
        'productName': line.productModel?.name ?? line.productName,
        'quantity': line.quantity.toDouble(),
        'price': line.priceUnit,
        'discount': line.discountPercentage,
        'listPrice': line.listPrice,
      };
    }).toList();
  }

  // ============= Server Data (for Odoo API) =============

  List<Map<String, dynamic>> getServerProductLinesData() {
    return productLines.map((line) {
      return {
        'product_id': line.productModel?.id ?? line.productId,
        'product_uom_qty': line.quantity.toDouble(),
        'price_unit': line.listPrice,
        'discount': line.discountPercentage,
      };
    }).toList();
  }

  List<Map<String, dynamic>> getDisplayProductLinesData() {
    return productLines.map((line) {
      return {
        'productId': line.productModel?.id ?? line.productId,
        'productName': line.productModel?.name ?? line.productName,
        'quantity': line.quantity.toDouble(),
        'displayPrice': line.priceUnit,
        'originalPrice': line.listPrice,
        'discount': line.discountPercentage,
        'total': line.getTotalPrice(),
      };
    }).toList();
  }

  Future<void> loadFromDraft(List<dynamic> productsData) async {
    appLogger.info('\n📥 ========== LOADING DRAFT ==========');
    appLogger.info('Products count: ${productsData.length}');

    clearAll();

    for (var i = 0; i < productsData.length; i++) {
      final productData = productsData[i];

      try {
        final productId = productData['productId'];
        final quantity = (productData['quantity'] ?? 1.0).toDouble();
        final price = (productData['price'] ?? 0.0).toDouble();
        final discount = (productData['discount'] ?? 0.0).toDouble();

        appLogger.info('\n🔍 ========== LOADING PRODUCT $i ==========');
        appLogger.info('Product ID: $productId');
        appLogger.info('Quantity: $quantity');
        appLogger.info('Price from draft: $price');
        appLogger.info('Discount from draft: $discount%');

        final product = availableProducts.firstWhere((p) => p.id == productId);

        appLogger.info('Product found: ${product.name}');
        appLogger.info('Product list_price: ${product.listPrice}');

        final line = ProductLine(
          key: UniqueKey(),
          productId: product.id ?? 0,
          productName: product.name ?? '',
          availableProducts: availableProducts,
          defaultQuantity: quantity.toInt(),
          defaultPrice: price,
          defaultDiscount: discount,
        );

        line.setProduct(product);

        appLogger.info('After setProduct:');
        appLogger.info('  listPrice: ${line.listPrice}');
        appLogger.info('  priceUnit: ${line.priceUnit}');
        appLogger.info('  discountPercentage: ${line.discountPercentage}%');

        line.priceUnit = price;
        line.discountPercentage = discount;
        line.quantity = quantity.toInt();
        line.quantityController.text = quantity.toInt().toString();

        appLogger.info('After applyPriceAndDiscount:');
        appLogger.info('  listPrice: ${line.listPrice}');
        appLogger.info('  priceUnit: ${line.priceUnit}');
        appLogger.info('  discountPercentage: ${line.discountPercentage}%');

        if (discount > 0) {
          line.listPrice = price / (1 - discount / 100);
        } else {
          line.listPrice = price;
        }

        line.priceController.text = line.priceUnit.toStringAsFixed(2);
        line.discountController.text = line.discountPercentage.toStringAsFixed(
          1,
        );

        appLogger.info('After recalculating listPrice:');
        appLogger.info('  listPrice: ${line.listPrice}');
        appLogger.info('  priceUnit: ${line.priceUnit}');
        appLogger.info('  discountPercentage: ${line.discountPercentage}%');
        appLogger.info('  Total: ${line.getTotalPrice()} Dh');
        appLogger.info('==========================================\n');

        final formKey = GlobalKey<FormBuilderState>();
        lineFormKeys[i] = formKey;
        line.setFormKey(formKey);

        productLines.add(line);
        selectedProductIds.add(product.id ?? 0);

        appLogger.info('   ✅ Loaded: ${line.productName} x${line.quantity}');
      } catch (e) {
        appLogger.error('   ❌ Error loading product $i: $e');
      }
    }

    _calculateTotal();

    appLogger.info('✅ Draft loaded: ${productLines.length} products');
    appLogger.info('   Total: ${orderTotal.value.toStringAsFixed(2)} Dh');
  }

  void clearAll() {
    appLogger.info('\n🗑️ Clearing all order data...');

    for (var line in productLines) {
      line.dispose();
    }

    productLines.clear();
    selectedProductIds.clear();
    lineFormKeys.clear();
    editingLineIndex.value = -1;
    orderTotal.value = 0.0;

    appLogger.info('✅ All data cleared');
  }

  // ============= Getters =============

  bool get hasProducts => productLines.isNotEmpty;
  int get productsCount => productLines.length;
  bool get isEditing => editingLineIndex.value != -1;

  ProductLine? get editingLine {
    if (editingLineIndex.value == -1) return null;
    if (editingLineIndex.value >= productLines.length) return null;
    return productLines[editingLineIndex.value];
  }

  GlobalKey<FormBuilderState>? get editingFormKey {
    if (editingLineIndex.value == -1) return null;
    return lineFormKeys[editingLineIndex.value];
  }
}
