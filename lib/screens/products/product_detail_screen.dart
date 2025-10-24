import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/products/product_model.dart';
import '../../utils/app_logger.dart';

/// 📦 Product Detail Screen - شاشة تفاصيل المنتج
///
/// المزايا:
/// ✅ عرض تفاصيل المنتج الكاملة
/// ✅ صور المنتج مع إمكانية التكبير
/// ✅ معلومات الأسعار والمخزون
/// ✅ إحصائيات المبيعات
/// ✅ معلومات الموردين
/// ✅ إجراءات سريعة للمديرين
class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat = NumberFormat.currency(
      symbol: 'MAD ',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(colorScheme, context),
              _buildProductHeader(colorScheme, currencyFormat),
              _buildPriceSection(colorScheme, currencyFormat),
              _buildStockSection(colorScheme),
              if (_isAdmin) _buildQuickActions(colorScheme),
              _buildDetailsSection(colorScheme),
              _buildSalesInfo(colorScheme),
              if (_hasSellers) _buildSupplierInfo(colorScheme, currencyFormat),
              _buildAdditionalInfo(colorScheme),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(colorScheme, currencyFormat),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(product.name ?? 'تفاصيل المنتج'),
      actions: [
        IconButton(
          icon: Icon(
            product.isFavorite == true ? Icons.favorite : Icons.favorite_border,
            color: product.isFavorite == true ? Colors.red : null,
          ),
          onPressed: () {
            appLogger.info('Favorite button pressed');
          },
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            appLogger.info('Edit button pressed');
          },
        ),
      ],
    );
  }

  bool get _isAdmin {
    // TODO: التحقق من صلاحيات المستخدم
    return true; // مؤقتاً
  }

  bool get _hasSellers {
    try {
      return product.sellerIds != null &&
          product.sellerIds is List &&
          (product.sellerIds as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ✅ دالة لتحويل الصورة من String إلى Uint8List
  Uint8List? _getImageBytes() {
    try {
      if (product.image1920 == null || product.image1920 == false) {
        return null;
      }

      // إذا كانت String (base64)
      if (product.image1920 is String) {
        final imageString = product.image1920 as String;
        if (imageString.isEmpty) {
          return null;
        }

        try {
          return base64Decode(imageString);
        } catch (e) {
          appLogger.error('Error decoding base64 image: $e');
          return null;
        }
      }

      // إذا كانت Uint8List بالفعل
      if (product.image1920 is Uint8List) {
        return product.image1920 as Uint8List;
      }

      return null;
    } catch (e, stackTrace) {
      appLogger.error(
        'Error getting image bytes',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Widget _buildProductImage(ColorScheme colorScheme, BuildContext context) {
    try {
      appLogger.info('Building product image');

      final imageBytes = _getImageBytes();
      bool isChampsValid(dynamic champs) {
        return champs != null && champs != false && champs != "";
      }

      return InkWell(
        onTap: () async {
          await showDialog(
            context: context,
            builder: (_) {
              final String imageToShow = kReleaseMode
                  ? (isChampsValid(product.image1920)
                        ? product.image1920
                        : "assets/images/other/empty_product.png")
                  : "assets/images/other/empty_product.png";

              return _buildImageDialog(imageToShow);
            },
          );
        },
        child: Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: imageBytes != null
              ? Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    appLogger.error(
                      'Error loading image',
                      error: error,
                      stackTrace: stackTrace,
                    );
                    return _buildErrorIcon(colorScheme);
                  },
                )
              : _buildErrorIcon(colorScheme),
        ),
      );
    } catch (e, stackTrace) {
      appLogger.error(
        'Error in _buildProductImage',
        error: e,
        stackTrace: stackTrace,
      );
      return Container(
        width: double.infinity,
        height: 300,
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        child: _buildErrorIcon(colorScheme),
      );
    }
  }

  Widget _buildImageDialog(String imageToShow) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
        child: Image.asset(imageToShow, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildErrorIcon(ColorScheme colorScheme) {
    return Icon(
      Icons.inventory_2_outlined,
      size: 100,
      color: colorScheme.outline,
    );
  }

  Widget _buildProductHeader(
    ColorScheme colorScheme,
    NumberFormat currencyFormat,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name ?? 'منتج غير معروف',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_hasValidCode)
                Flexible(
                  child: Text(
                    'الكود: ${product.defaultCode}',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: product.active == true
                      ? colorScheme.primaryContainer
                      : colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.active == true ? 'نشط' : 'غير نشط',
                  style: TextStyle(
                    color: product.active == true
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (_hasValidBarcode) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.qr_code, size: 16, color: colorScheme.primary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'الباركود: ${product.barcode}',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          _buildCategoryChip(colorScheme),
        ],
      ),
    );
  }

  bool get _hasValidCode {
    return product.defaultCode != null &&
        product.defaultCode != false &&
        product.defaultCode.toString() != "false" &&
        product.defaultCode.toString().isNotEmpty;
  }

  bool get _hasValidBarcode {
    return product.barcode != null &&
        product.barcode != false &&
        product.barcode.toString() != "false" &&
        product.barcode.toString().isNotEmpty;
  }

  Widget _buildCategoryChip(ColorScheme colorScheme) {
    String categoryName = 'غير مصنف';

    try {
      if (product.categId != null) {
        if (product.categId is List && (product.categId as List).length > 1) {
          categoryName = (product.categId as List)[1]?.toString() ?? 'غير مصنف';
        } else if (product.categId is Map) {
          categoryName =
              product.categId['display_name']?.toString() ?? 'غير مصنف';
        }
      }
    } catch (e) {
      categoryName = 'غير مصنف';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.category,
            size: 14,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              categoryName,
              style: TextStyle(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(
    ColorScheme colorScheme,
    NumberFormat currencyFormat,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPriceCard(
              colorScheme: colorScheme,
              title: 'سعر البيع',
              price: _parseDouble(product.listPrice),
              icon: Icons.sell,
              color: colorScheme.primary,
              currencyFormat: currencyFormat,
            ),
          ),
          const SizedBox(width: 12),
          if (_isAdmin)
            Expanded(
              child: _buildPriceCard(
                colorScheme: colorScheme,
                title: 'سعر التكلفة',
                price: _parseDouble(product.standardPrice),
                icon: Icons.shopping_cart,
                color: colorScheme.tertiary,
                currencyFormat: currencyFormat,
              ),
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

  Widget _buildPriceCard({
    required ColorScheme colorScheme,
    required String title,
    required double price,
    required IconData icon,
    required Color color,
    required NumberFormat currencyFormat,
  }) {
    final salePrice = _parseDouble(product.listPrice);
    final costPrice = _parseDouble(product.standardPrice);
    final profit = salePrice - costPrice;
    final margin = salePrice > 0 ? ((profit / salePrice) * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(price),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (title == 'سعر البيع' && margin > 0 && _isAdmin) ...[
            const SizedBox(height: 4),
            Text(
              'الهامش: ${margin.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStockSection(ColorScheme colorScheme) {
    final qtyAvailable = _parseDouble(product.qtyAvailable);
    final virtualAvailable = _parseDouble(product.virtualAvailable);
    final isInStock = qtyAvailable > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'معلومات المخزون',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStockCard(
                  colorScheme: colorScheme,
                  title: 'في اليد',
                  quantity: qtyAvailable,
                  icon: Icons.warehouse,
                  color: isInStock ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStockCard(
                  colorScheme: colorScheme,
                  title: 'المتوقع',
                  quantity: virtualAvailable,
                  icon: Icons.trending_up,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          if (product.uomName != null &&
              product.uomName != false &&
              product.uomName.toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'الوحدة: ${product.uomName}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStockCard({
    required ColorScheme colorScheme,
    required String title,
    required double quantity,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            quantity.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              colorScheme: colorScheme,
              icon: Icons.point_of_sale,
              label: 'بيع',
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              colorScheme: colorScheme,
              icon: Icons.add_shopping_cart,
              label: 'شراء',
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              colorScheme: colorScheme,
              icon: Icons.inventory_2,
              label: 'تعديل المخزون',
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: colorScheme.onPrimaryContainer, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل المنتج',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            colorScheme: colorScheme,
            label: 'نوع المنتج',
            value: _getProductType(),
            icon: Icons.category,
          ),
          if (product.categId != null)
            _buildDetailRow(
              colorScheme: colorScheme,
              label: 'الفئة',
              value: _getCategoryName(),
              icon: Icons.folder,
            ),
          if (product.saleOk != null)
            _buildDetailRow(
              colorScheme: colorScheme,
              label: 'يمكن بيعه',
              value: product.saleOk == true ? 'نعم' : 'لا',
              icon: Icons.sell,
            ),
          if (product.purchaseOk != null)
            _buildDetailRow(
              colorScheme: colorScheme,
              label: 'يمكن شراؤه',
              value: product.purchaseOk == true ? 'نعم' : 'لا',
              icon: Icons.shopping_cart,
            ),
          if (product.invoicePolicy != null && product.invoicePolicy != false)
            _buildDetailRow(
              colorScheme: colorScheme,
              label: 'سياسة الفواتير',
              value: _getInvoicePolicy(),
              icon: Icons.receipt,
            ),
          if (product.tracking != null &&
              product.tracking != false &&
              product.tracking.toString() != 'none')
            _buildDetailRow(
              colorScheme: colorScheme,
              label: 'التتبع',
              value: product.tracking.toString(),
              icon: Icons.track_changes,
            ),
          if (_parseDouble(product.weight) > 0)
            _buildDetailRow(
              colorScheme: colorScheme,
              label: 'الوزن',
              value:
                  '${_parseDouble(product.weight)} ${product.weightUomName ?? "كغ"}',
              icon: Icons.fitness_center,
            ),
          if (_parseDouble(product.volume) > 0)
            _buildDetailRow(
              colorScheme: colorScheme,
              label: 'الحجم',
              value:
                  '${_parseDouble(product.volume)} ${product.volumeUomName ?? "م³"}',
              icon: Icons.square_foot,
            ),
        ],
      ),
    );
  }

  String _getProductType() {
    try {
      switch (product.type?.toString()) {
        case 'consu':
          return 'مستهلك';
        case 'service':
          return 'خدمة';
        case 'product':
          return 'منتج قابل للتخزين';
        default:
          return product.type?.toString() ?? 'غير معروف';
      }
    } catch (e) {
      return 'غير معروف';
    }
  }

  String _getCategoryName() {
    try {
      if (product.categId != null) {
        if (product.categId is List && (product.categId as List).length > 1) {
          String fullName =
              (product.categId as List)[1]?.toString() ?? 'غير مصنف';
          List<String> parts = fullName.split('/');
          return parts.last.trim();
        } else if (product.categId is Map) {
          return product.categId['display_name']?.toString() ?? 'غير مصنف';
        }
      }
    } catch (e) {
      return 'غير مصنف';
    }
    return 'غير مصنف';
  }

  String _getInvoicePolicy() {
    try {
      switch (product.invoicePolicy?.toString()) {
        case 'delivery':
          return 'الكميات المسلمة';
        case 'order':
          return 'الكميات المطلوبة';
        default:
          return product.invoicePolicy?.toString() ?? 'غير معروف';
      }
    } catch (e) {
      return 'غير معروف';
    }
  }

  Widget _buildDetailRow({
    required ColorScheme colorScheme,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesInfo(ColorScheme colorScheme) {
    final salesCount = _parseDouble(product.salesCount);
    final purchasedQty = _parseDouble(product.purchasedProductQty);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isAdmin ? 'إحصائيات المبيعات والشراء' : 'إحصائيات المبيعات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  colorScheme: colorScheme,
                  title: 'إجمالي المبيعات',
                  value: salesCount.toStringAsFixed(0),
                  icon: Icons.shopping_bag,
                  color: Colors.green,
                ),
              ),
              if (_isAdmin) const SizedBox(width: 12),
              if (_isAdmin)
                Expanded(
                  child: _buildStatCard(
                    colorScheme: colorScheme,
                    title: 'الكمية المشتراة',
                    value: purchasedQty.toStringAsFixed(0),
                    icon: Icons.shopping_cart,
                    color: Colors.blue,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required ColorScheme colorScheme,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierInfo(
    ColorScheme colorScheme,
    NumberFormat currencyFormat,
  ) {
    if (!_hasSellers) return const SizedBox.shrink();

    final sellers = product.sellerIds as List;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.store, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'الموردون',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sellers.map(
            (seller) => _buildSupplierCard(
              colorScheme: colorScheme,
              seller: seller,
              currencyFormat: currencyFormat,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard({
    required ColorScheme colorScheme,
    required dynamic seller,
    required NumberFormat currencyFormat,
  }) {
    String supplierName = 'مورد غير معروف';
    double price = 0.0;
    double minQty = 1.0;
    int delay = 0;

    try {
      if (seller is Map) {
        supplierName =
            seller['partner_id']?['display_name']?.toString() ??
            'مورد غير معروف';
        price = _parseDouble(seller['price']);
        minQty = _parseDouble(seller['min_qty']);
        delay = (seller['delay'] ?? 0) is int
            ? seller['delay']
            : int.tryParse(seller['delay'].toString()) ?? 0;
      }
    } catch (e) {
      // Keep default values
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                radius: 20,
                child: Icon(
                  Icons.business,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplierName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      currencyFormat.format(price),
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSupplierDetail(
                colorScheme: colorScheme,
                icon: Icons.shopping_basket,
                label: 'الحد الأدنى: ${minQty.toStringAsFixed(0)}',
              ),
              const SizedBox(width: 16),
              _buildSupplierDetail(
                colorScheme: colorScheme,
                icon: Icons.access_time,
                label: 'وقت التوريد: $delay يوم',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierDetail({
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colorScheme.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات إضافية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (_hasResponsible)
            _buildInfoRow(
              colorScheme: colorScheme,
              icon: Icons.person,
              label: 'المسؤول',
              value: _getResponsibleName(),
            ),
          if (product.writeDate != null && product.writeDate != false)
            _buildInfoRow(
              colorScheme: colorScheme,
              icon: Icons.calendar_today,
              label: 'آخر تحديث',
              value: _formatDate(product.writeDate.toString()),
            ),
          if (product.productVariantCount != null)
            _buildInfoRow(
              colorScheme: colorScheme,
              icon: Icons.description,
              label: 'متغيرات المنتج',
              value: product.productVariantCount.toString(),
            ),
          if (product.saleDelay != null && product.saleDelay != false)
            _buildInfoRow(
              colorScheme: colorScheme,
              icon: Icons.local_shipping,
              label: 'وقت تسليم العميل',
              value: '${product.saleDelay} يوم',
            ),
        ],
      ),
    );
  }

  bool get _hasResponsible {
    try {
      return product.responsibleId != null &&
          product.responsibleId != false &&
          (product.responsibleId is List
              ? (product.responsibleId as List).length > 1
              : true);
    } catch (e) {
      return false;
    }
  }

  String _getResponsibleName() {
    try {
      if (product.responsibleId is List &&
          (product.responsibleId as List).length > 1) {
        return (product.responsibleId as List)[1]?.toString() ?? 'غير معين';
      } else if (product.responsibleId is Map) {
        return product.responsibleId['display_name']?.toString() ?? 'غير معين';
      }
    } catch (e) {
      return 'غير معين';
    }
    return 'غير معين';
  }

  Widget _buildInfoRow({
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildBottomBar(ColorScheme colorScheme, NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سعر البيع',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    currencyFormat.format(_parseDouble(product.listPrice)),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('إضافة للسلة'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
