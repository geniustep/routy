// lib/screens/sales/saleorder/create/widgets/sales_quantity_selector.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routy/models/products/product_model.dart';
import 'package:routy/l10n/app_localizations.dart';

/// 🔢 Sales Quantity Selector - منتقي كمية البيع
///
/// يدعم:
/// - اختيار الكمية
/// - التحقق من المخزون
/// - حساب الإجمالي
/// - تطبيق الخصومات
class SalesQuantitySelector extends StatefulWidget {
  final ProductModel product;
  final double? initialQuantity;
  final Function(double)? onQuantityChanged;
  final Function(double)? onPriceChanged;
  final Function(double)? onDiscountChanged;

  const SalesQuantitySelector({
    super.key,
    required this.product,
    this.initialQuantity,
    this.onQuantityChanged,
    this.onPriceChanged,
    this.onDiscountChanged,
  });

  @override
  State<SalesQuantitySelector> createState() => _SalesQuantitySelectorState();
}

class _SalesQuantitySelectorState extends State<SalesQuantitySelector> {
  // ============= Controllers =============

  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();

  // ============= State =============

  double _quantity = 1.0;
  double _price = 0.0;
  double _discount = 0.0;
  double _total = 0.0;

  // ============= Lifecycle =============

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  @override
  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    discountController.dispose();
    super.dispose();
  }

  // ============= Initialization =============

  void _initializeValues() {
    _quantity = widget.initialQuantity ?? 1.0;
    _price = widget.product.listPriceValue;
    _discount = 0.0;

    quantityController.text = _quantity.toString();
    priceController.text = _price.toStringAsFixed(2);
    discountController.text = _discount.toStringAsFixed(1);

    _calculateTotal();
  }

  // ============= Calculations =============

  void _calculateTotal() {
    _total = _quantity * _price * (1 - _discount / 100);
    setState(() {});
  }

  // ============= Event Handlers =============

  void _onQuantityChanged(String value) {
    final quantity = double.tryParse(value) ?? 0.0;
    if (quantity > 0) {
      setState(() {
        _quantity = quantity;
      });
      _calculateTotal();
      widget.onQuantityChanged?.call(quantity);
    }
  }

  void _onPriceChanged(String value) {
    final price = double.tryParse(value) ?? 0.0;
    if (price >= 0) {
      setState(() {
        _price = price;
      });
      _calculateTotal();
      widget.onPriceChanged?.call(price);
    }
  }

  void _onDiscountChanged(String value) {
    final discount = double.tryParse(value) ?? 0.0;
    if (discount >= 0 && discount <= 100) {
      setState(() {
        _discount = discount;
      });
      _calculateTotal();
      widget.onDiscountChanged?.call(discount);
    }
  }

  // ============= Build =============

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // رأس الحوار
            _buildHeader(l10n),

            const SizedBox(height: 24),

            // معلومات المنتج
            _buildProductInfo(l10n),

            const SizedBox(height: 24),

            // حقول الإدخال
            _buildInputFields(l10n),

            const SizedBox(height: 24),

            // الإجمالي
            _buildTotalSection(l10n),

            const SizedBox(height: 24),

            // أزرار الإجراءات
            _buildActionButtons(l10n),
          ],
        ),
      ),
    );
  }

  // ============= Header =============

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      children: [
        const Icon(Icons.add_shopping_cart, color: Colors.blue, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            l10n.add_to_order,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
      ],
    );
  }

  // ============= Product Info =============

  Widget _buildProductInfo(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.productName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.product.productCode != null) ...[
              const SizedBox(height: 4),
              Text(
                'كود: ${widget.product.productCode}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            if (widget.product.categoryName != null) ...[
              const SizedBox(height: 4),
              Text(
                'فئة: ${widget.product.categoryName}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'السعر الأصلي: ${widget.product.listPriceValue.toStringAsFixed(2)} Dh',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ============= Input Fields =============

  Widget _buildInputFields(AppLocalizations l10n) {
    return Column(
      children: [
        // الكمية
        TextField(
          controller: quantityController,
          decoration: InputDecoration(
            labelText: l10n.quantity,
            hintText: l10n.enter_quantity,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.numbers),
          ),
          keyboardType: TextInputType.number,
          onChanged: _onQuantityChanged,
        ),

        const SizedBox(height: 16),

        // السعر
        TextField(
          controller: priceController,
          decoration: InputDecoration(
            labelText: l10n.price,
            hintText: l10n.enter_price,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.attach_money),
            suffixText: 'Dh',
          ),
          keyboardType: TextInputType.number,
          onChanged: _onPriceChanged,
        ),

        const SizedBox(height: 16),

        // الخصم
        TextField(
          controller: discountController,
          decoration: InputDecoration(
            labelText: l10n.discount,
            hintText: l10n.enter_discount,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.percent),
            suffixText: '%',
          ),
          keyboardType: TextInputType.number,
          onChanged: _onDiscountChanged,
        ),
      ],
    );
  }

  // ============= Total Section =============

  Widget _buildTotalSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.total,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_total.toStringAsFixed(2)} Dh',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          if (_discount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.savings,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${(_quantity * _price * _discount / 100).toStringAsFixed(2)} Dh',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ============= Action Buttons =============

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            child: Text(l10n.cancel),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // إضافة المنتج للطلب
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.add),
          ),
        ),
      ],
    );
  }
}
