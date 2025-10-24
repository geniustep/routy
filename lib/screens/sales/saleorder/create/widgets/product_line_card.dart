// lib/screens/sales/saleorder/create/widgets/product_line_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:routy/screens/sales/saleorder/create/widgets/product_line.dart';
import 'package:routy/l10n/app_localizations.dart';

/// 🛒 Product Line Card - بطاقة سطر المنتج
///
/// تدعم:
/// - عرض بيانات المنتج
/// - تعديل الكمية والسعر
/// - تطبيق الخصم
/// - حذف السطر
class ProductLineCard extends StatelessWidget {
  final ProductLine line;
  final int index;
  final bool isEditing;
  final VoidCallback? onEdit;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final Function(double)? onQuantityChanged;
  final Function(double)? onPriceChanged;
  final Function(double)? onDiscountChanged;

  const ProductLineCard({
    super.key,
    required this.line,
    required this.index,
    required this.isEditing,
    this.onEdit,
    this.onSave,
    this.onCancel,
    this.onDelete,
    this.onQuantityChanged,
    this.onPriceChanged,
    this.onDiscountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // رأس البطاقة
            _buildCardHeader(l10n),

            const SizedBox(height: 16),

            // محتوى البطاقة
            if (isEditing)
              _buildEditingContent(l10n)
            else
              _buildDisplayContent(l10n),

            const SizedBox(height: 16),

            // أزرار الإجراءات
            _buildActionButtons(l10n),
          ],
        ),
      ),
    );
  }

  // ============= Card Header =============

  Widget _buildCardHeader(AppLocalizations l10n) {
    return Row(
      children: [
        // أيقونة المنتج
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.inventory, color: Colors.blue),
        ),

        const SizedBox(width: 12),

        // معلومات المنتج
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.productName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (line.productModel?.productCode != null)
                Text(
                  'كود: ${line.productModel!.productCode}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),

        // رقم السطر
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${index + 1}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ============= Display Content =============

  Widget _buildDisplayContent(AppLocalizations l10n) {
    return Column(
      children: [
        // معلومات السعر
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('الكمية', style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '${line.quantity}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('السعر', style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '${line.priceUnit.toStringAsFixed(2)} Dh',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        if (line.discountPercentage > 0) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الخصم',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${line.discountPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],

        const Divider(),

        // الإجمالي
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المجموع',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${line.getTotalPrice().toStringAsFixed(2)} Dh',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============= Editing Content =============

  Widget _buildEditingContent(AppLocalizations l10n) {
    return Column(
      children: [
        // الكمية
        FormBuilderTextField(
          name: 'quantity_$index',
          decoration: InputDecoration(
            labelText: 'الكمية',
            border: const OutlineInputBorder(),
          ),
          initialValue: line.quantity.toString(),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value != null && value.isNotEmpty) {
              final quantity = double.tryParse(value);
              if (quantity != null && quantity > 0) {
                onQuantityChanged?.call(quantity);
              }
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال الكمية';
            }
            final quantity = double.tryParse(value);
            if (quantity == null || quantity <= 0) {
              return 'يرجى إدخال كمية صحيحة';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // السعر
        FormBuilderTextField(
          name: 'price_$index',
          decoration: InputDecoration(
            labelText: 'السعر',
            border: const OutlineInputBorder(),
            suffixText: 'Dh',
          ),
          initialValue: line.priceUnit.toStringAsFixed(2),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value != null && value.isNotEmpty) {
              final price = double.tryParse(value);
              if (price != null && price >= 0) {
                onPriceChanged?.call(price);
              }
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال السعر';
            }
            final price = double.tryParse(value);
            if (price == null || price < 0) {
              return 'يرجى إدخال سعر صحيح';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // الخصم
        FormBuilderTextField(
          name: 'discount_$index',
          decoration: InputDecoration(
            labelText: 'الخصم',
            border: const OutlineInputBorder(),
            suffixText: '%',
          ),
          initialValue: line.discountPercentage.toStringAsFixed(1),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value != null && value.isNotEmpty) {
              final discount = double.tryParse(value);
              if (discount != null && discount >= 0 && discount <= 100) {
                onDiscountChanged?.call(discount);
              }
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال الخصم';
            }
            final discount = double.tryParse(value);
            if (discount == null || discount < 0 || discount > 100) {
              return 'يرجى إدخال خصم صحيح';
            }
            return null;
          },
        ),
      ],
    );
  }

  // ============= Action Buttons =============

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isEditing) ...[
          // أزرار التعديل
          TextButton(onPressed: onCancel, child: Text('إلغاء')),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('حفظ'),
          ),
        ] else ...[
          // أزرار العرض
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            tooltip: 'تعديل',
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete),
            tooltip: 'حذف',
            color: Colors.red,
          ),
        ],
      ],
    );
  }
}
