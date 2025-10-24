// lib/screens/sales/saleorder/create/widgets/product_selection_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routy/controllers/product_controller.dart';
import 'package:routy/models/products/product_model.dart';
import 'package:routy/l10n/app_localizations.dart';

/// 🔍 Product Selection Dialog - حوار اختيار المنتجات
///
/// يدعم:
/// - البحث في المنتجات
/// - الفلترة حسب الفئة
/// - اختيار المنتجات
/// - عرض تفاصيل المنتج
class ProductSelectionDialog extends StatefulWidget {
  final Function(ProductModel)? onProductSelected;

  const ProductSelectionDialog({super.key, this.onProductSelected});

  @override
  State<ProductSelectionDialog> createState() => _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<ProductSelectionDialog> {
  // ============= Controllers =============

  final ProductController productController = Get.find<ProductController>();
  final TextEditingController searchController = TextEditingController();

  // ============= State =============

  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedType = '';

  // ============= Lifecycle =============

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============= Methods =============

  Future<void> _loadProducts() async {
    try {
      await productController.fetchProducts(
        search: _searchQuery,
        category: _selectedCategory,
        type: _selectedType,
        activeOnly: true,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ في التحميل',
        'فشل في تحميل المنتجات: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadProducts();
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadProducts();
  }

  void _onTypeChanged(String type) {
    setState(() {
      _selectedType = type;
    });
    _loadProducts();
  }

  void _onProductSelected(ProductModel product) {
    widget.onProductSelected?.call(product);
    Get.back();
  }

  // ============= Build =============

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // رأس الحوار
            _buildHeader(l10n),

            // شريط البحث والفلاتر
            _buildSearchAndFilters(l10n),

            // قائمة المنتجات
            Expanded(child: _buildProductsList(l10n)),

            // أزرار الإجراءات
            _buildActionButtons(l10n),
          ],
        ),
      ),
    );
  }

  // ============= Header =============

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'اختر المنتج',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ============= Search and Filters =============

  Widget _buildSearchAndFilters(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // شريط البحث
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'البحث في المنتجات',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: _onSearchChanged,
          ),

          const SizedBox(height: 16),

          // الفلاتر
          Row(
            children: [
              // فلتر الفئة
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory.isEmpty ? null : _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'الفئة',
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: '',
                      child: Text('جميع الفئات'),
                    ),
                    ...productController.availableCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    _onCategoryChanged(value ?? '');
                  },
                ),
              ),

              const SizedBox(width: 16),

              // فلتر النوع
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedType.isEmpty ? null : _selectedType,
                  decoration: InputDecoration(
                    labelText: 'النوع',
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: '',
                      child: Text('جميع الأنواع'),
                    ),
                    ...productController.availableTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    _onTypeChanged(value ?? '');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============= Products List =============

  Widget _buildProductsList(AppLocalizations l10n) {
    return Obx(() {
      if (productController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (productController.filteredProducts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'لم يتم العثور على منتجات',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: productController.filteredProducts.length,
        itemBuilder: (context, index) {
          final product = productController.filteredProducts[index];
          return _buildProductItem(product, l10n);
        },
      );
    });
  }

  // ============= Product Item =============

  Widget _buildProductItem(ProductModel product, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.inventory, color: Colors.blue),
        ),
        title: Text(
          product.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.productCode != null)
              Text('كود: ${product.productCode}'),
            if (product.categoryName != null)
              Text('فئة: ${product.categoryName}'),
            Text('السعر: ${product.listPriceValue.toStringAsFixed(2)} Dh'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _onProductSelected(product),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text('اختر'),
        ),
        onTap: () => _onProductSelected(product),
      ),
    );
  }

  // ============= Action Buttons =============

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              child: Text('إلغاء'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // فتح شاشة مسح الباركود
                Get.snackbar(
                  'قيد التطوير',
                  'شاشة مسح الباركود قيد التطوير',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('مسح الباركود'),
            ),
          ),
        ],
      ),
    );
  }
}
