import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/products/product_model.dart';
import '../../controllers/product_controller.dart';
import 'product_detail_screen.dart';
import '../../utils/app_logger.dart';

/// 📦 Products Screen - شاشة قائمة المنتجات
///
/// المزايا:
/// ✅ عرض المنتجات في Grid أو List
/// ✅ البحث والفلترة
/// ✅ عرض تفاصيل المنتج
/// ✅ إجراءات سريعة
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late ProductController _productController;
  bool _isGridView = true;
  int _gridColumns = 2;

  @override
  void initState() {
    super.initState();
    // التحقق من وجود ProductController
    try {
      if (Get.isRegistered<ProductController>()) {
        _productController = Get.find<ProductController>();
      } else {
        _productController = Get.put(ProductController());
      }
      // تحميل المنتجات بذكاء
      _productController.loadProductsSmart();
    } catch (e) {
      appLogger.error('❌ Error initializing ProductsScreen: $e');
      // تهيئة بديلة
      _productController = Get.put(ProductController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('المنتجات'),
      actions: [
        IconButton(
          icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
        ),
        if (_isGridView)
          PopupMenuButton<int>(
            icon: const Icon(Icons.view_column),
            onSelected: (int columns) {
              setState(() {
                _gridColumns = columns;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 1, child: Text('عمود واحد')),
              const PopupMenuItem(value: 2, child: Text('عمودين')),
              const PopupMenuItem(value: 3, child: Text('ثلاثة أعمدة')),
            ],
          ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            _showSearchDialog();
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (_productController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_productController.products.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () async {
          await _productController.loadProductsSmart(forceRefresh: true);
        },
        child: _isGridView ? _buildGridView() : _buildListView(),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 100,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد منتجات',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على منتجات',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridColumns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _productController.products.length,
      itemBuilder: (context, index) {
        final product = _productController.products[index];
        return _buildProductCard(product, index);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _productController.products.length,
      itemBuilder: (context, index) {
        final product = _productController.products[index];
        return _buildProductRow(product, index);
      },
    );
  }

  Widget _buildProductCard(ProductModel product, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.to(() => ProductDetailScreen(product: product));
        },
        onLongPress: () {
          _showProductActions(product);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(product, colorScheme),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? 'منتج غير معروف',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.defaultCode != null)
                      Text(
                        'الكود: ${product.defaultCode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_parseDouble(product.listPrice).toStringAsFixed(0)} MAD',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: product.active == true
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.active == true ? 'نشط' : 'غير نشط',
                            style: TextStyle(
                              fontSize: 10,
                              color: product.active == true
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductRow(ProductModel product, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.to(() => ProductDetailScreen(product: product));
        },
        onLongPress: () {
          _showProductActions(product);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildProductImage(product, colorScheme, size: 60),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? 'منتج غير معروف',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.defaultCode != null)
                      Text(
                        'الكود: ${product.defaultCode}',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_parseDouble(product.listPrice).toStringAsFixed(0)} MAD',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: product.active == true
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product.active == true ? 'نشط' : 'غير نشط',
                            style: TextStyle(
                              fontSize: 12,
                              color: product.active == true
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(
    ProductModel product,
    ColorScheme colorScheme, {
    double size = 100,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _getProductImage(product, colorScheme, size),
    );
  }

  Widget _getProductImage(
    ProductModel product,
    ColorScheme colorScheme,
    double size,
  ) {
    try {
      if (product.image1920 != null && product.image1920 != false) {
        if (product.image1920 is String) {
          final imageString = product.image1920 as String;
          if (imageString.isNotEmpty) {
            try {
              final imageBytes = base64Decode(imageString);
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  errorBuilder: (context, error, stackTrace) {
                    appLogger.error(
                      'Error loading product image',
                      error: error,
                      stackTrace: stackTrace,
                    );
                    return _buildImagePlaceholder(colorScheme, size);
                  },
                ),
              );
            } catch (e) {
              appLogger.error('Error decoding base64 image: $e');
              return _buildImagePlaceholder(colorScheme, size);
            }
          }
        }
      }
    } catch (e) {
      appLogger.error('Error getting product image: $e');
    }

    return _buildImagePlaceholder(colorScheme, size);
  }

  Widget _buildImagePlaceholder(ColorScheme colorScheme, double size) {
    return Icon(
      Icons.inventory_2_outlined,
      size: size * 0.5,
      color: colorScheme.outline,
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // TODO: إضافة منتج جديد
        appLogger.info('Add new product pressed');
      },
      child: const Icon(Icons.add),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('البحث في المنتجات'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'ابحث عن منتج...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            // TODO: تنفيذ البحث
            appLogger.info('Search query: $value');
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: تنفيذ البحث
            },
            child: const Text('بحث'),
          ),
        ],
      ),
    );
  }

  void _showProductActions(ProductModel product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('عرض التفاصيل'),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => ProductDetailScreen(product: product));
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('تعديل'),
              onTap: () {
                Navigator.pop(context);
                // TODO: تعديل المنتج
                appLogger.info('Edit product: ${product.name}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('نسخ'),
              onTap: () {
                Navigator.pop(context);
                // TODO: نسخ المنتج
                appLogger.info('Copy product: ${product.name}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(product);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المنتج "${product.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: حذف المنتج
              appLogger.info('Delete product: ${product.name}');
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null || value == false) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
