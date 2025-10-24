// lib/screens/sales/saleorder/create/widgets/empty_products_view.dart

import 'package:flutter/material.dart';

/// 📦 Empty Products View - عرض المنتجات الفارغ
///
/// يعرض:
/// - رسالة عدم وجود منتجات
/// - أزرار إضافة المنتجات
/// - مسح الباركود
/// - إرشادات الاستخدام
class EmptyProductsView extends StatelessWidget {
  final VoidCallback? onAddProduct;
  final VoidCallback? onScanBarcode;

  const EmptyProductsView({super.key, this.onAddProduct, this.onScanBarcode});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة المنتجات
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 24),

            // العنوان
            Text(
              'لم يتم إضافة منتجات',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // الرسالة
            Text(
              'إضافة منتجات للطلب',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // أزرار الإجراءات
            Column(
              children: [
                // إضافة منتج
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAddProduct,
                    icon: const Icon(Icons.add),
                    label: Text('إضافة منتج'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // مسح الباركود
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onScanBarcode,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text('مسح الباركود'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // إرشادات الاستخدام
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'نصائح',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'نصائح لإضافة المنتجات',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
