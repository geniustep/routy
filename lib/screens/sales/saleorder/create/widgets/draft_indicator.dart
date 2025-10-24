// lib/screens/sales/saleorder/create/widgets/draft_indicator.dart

import 'package:flutter/material.dart';

/// 📝 Draft Indicator - مؤشر المسودة
///
/// يعرض:
/// - حالة المسودة
/// - وقت آخر حفظ
/// - أزرار الإجراءات
/// - تحذيرات التغييرات
class DraftIndicator extends StatelessWidget {
  final String lastSaved;
  final VoidCallback? onDelete;
  final bool hasUnsavedChanges;

  const DraftIndicator({
    super.key,
    required this.lastSaved,
    this.onDelete,
    this.hasUnsavedChanges = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasUnsavedChanges
            ? Colors.orange.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: hasUnsavedChanges ? Colors.orange : Colors.blue,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          // أيقونة المسودة
          Icon(
            hasUnsavedChanges ? Icons.edit : Icons.save,
            color: hasUnsavedChanges ? Colors.orange : Colors.blue,
            size: 20,
          ),

          const SizedBox(width: 8),

          // معلومات المسودة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasUnsavedChanges
                      ? 'المسودة تحتوي على تغييرات'
                      : 'تم حفظ المسودة',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: hasUnsavedChanges ? Colors.orange : Colors.blue,
                  ),
                ),
                Text(
                  lastSaved,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),

          // أزرار الإجراءات
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              iconSize: 20,
              color: Colors.red,
              tooltip: 'حذف المسودة',
            ),
        ],
      ),
    );
  }
}
