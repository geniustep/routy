# 📦 نظام القوالب الهجين - Generic Widget System

نظام قوالب عامة قابلة لإعادة الاستخدام مع دعم كامل لنظام الترجمة.

---

## 🎯 المكونات الأساسية

### 1️⃣ **الموديلات المشتركة** (`lib/models/common/`)
```dart
import 'package:routy/models/common/index.dart';

// نظام الفلترة
FilterOption(id: '1', labelKey: 'confirmed', value: 'confirmed', type: FilterType.status)

// نظام الترتيب
SortOption(id: '1', labelKey: 'newest_first', field: 'date', order: SortOrder.descending)

// الحالات الموحدة
ItemStatus.confirmed  // أزرق
ItemStatus.completed  // أخضر
ItemStatus.cancelled  // أحمر
```

### 2️⃣ **ويدجتات الحالات** (`lib/widgets/common/states/`)
```dart
// حالة فارغة
EmptyStateWidget(
  titleKey: 'no_sales_orders',
  messageKey: 'create_first_sale_order',
  icon: Icons.receipt_long,
  actionLabelKey: 'add',
  onActionPressed: () => _createNewOrder(),
)

// حالة تحميل
LoadingStateWidget(messageKey: 'loading')

// حالة خطأ
ErrorStateWidget(
  errorMessage: 'خطأ في الاتصال',
  actionLabelKey: 'retry',
  onActionPressed: () => _retry(),
)
```

### 3️⃣ **القوالب الرئيسية** (`lib/widgets/common/lists/`)

#### `GenericListScreen<T>` - لائحة عامة
```dart
GenericListScreen<SaleOrderModel>(
  titleKey: 'المبيعات',  // ← مباشرة، ليس مفتاح ترجمة
  
  fetchData: ({searchQuery, filters, sortOption, page}) async {
    return await salesController.fetchOrders(
      search: searchQuery,
      page: page,
    );
  },
  
  itemBuilder: (context, order, index) {
    return GenericListCard(
      title: order.orderName,
      subtitle: order.partnerName,
      trailing: Text('\$${order.totalAmount}'),
      status: ItemStatus.fromId(order.state),
    );
  },
  
  onItemTap: (order) => Get.to(() => OrderDetailsScreen(order)),
  
  enableSearch: true,
  enableRefresh: true,
  enablePagination: true,
)
```

#### `GenericListCard` - كارد عام
```dart
GenericListCard(
  // المحتوى الأساسي
  title: 'SO-2024-001',
  subtitle: 'محمد أحمد',
  secondaryText: 'تسليم خلال 3 أيام',
  
  // الحالة
  status: ItemStatus.confirmed,
  // أو
  trailing: Text('\$1,234.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  
  // معلومات إضافية
  infoChips: [
    InfoChip(label: '5 عناصر', icon: Icons.list),
    InfoChip(label: 'علي حسن', icon: Icons.person),
  ],
  
  // الإجراءات
  actions: [
    ActionButton(
      label: 'تعديل',
      icon: Icons.edit,
      onPressed: () => _edit(),
    ),
    ActionButton(
      label: 'حذف',
      icon: Icons.delete,
      color: Colors.red,
      onPressed: () => _delete(),
    ),
  ],
  
  onTap: () => _viewDetails(),
)
```

---

## 🔧 نظام الترجمة

### استخدام `TranslationHelper`
```dart
import 'package:routy/utils/translation_helper.dart';
import 'package:routy/l10n/app_localizations.dart';

final l10n = AppLocalizations.of(context)!;

// الترجمات المدعومة تلقائياً
String text = TranslationHelper.getCommonTranslation(l10n, 'loading');
String text = TranslationHelper.getCommonTranslation(l10n, 'error_occurred');
String text = TranslationHelper.getCommonTranslation(l10n, 'draft');
String text = TranslationHelper.getCommonTranslation(l10n, 'confirmed');
String text = TranslationHelper.getCommonTranslation(l10n, 'save');
```

### المفاتيح المدعومة
```dart
// النصوص العامة
'loading', 'error_occurred', 'error_loading_data', 'no_data_found', 
'no_items_found', 'try_different_search', 'retry', 'search'

// الحالات
'draft', 'pending', 'confirmed', 'in_progress', 'completed', 
'delivered', 'cancelled', 'paid', 'unpaid'

// الإجراءات
'add', 'edit', 'delete', 'save', 'cancel', 'confirm'
```

---

## ✨ مثال كامل: لائحة المبيعات

```dart
import 'package:flutter/material.dart';
import 'package:routy/widgets/common/index.dart';
import 'package:routy/models/common/index.dart';
import 'package:routy/models/sales/sale_order_model.dart';

class SalesOrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GenericListScreen<SaleOrderModel>(
      titleKey: 'أوامر البيع',
      searchHintKey: 'البحث في المبيعات...',
      
      // جلب البيانات
      fetchData: ({searchQuery, filters, sortOption, page}) async {
        return await Get.find<SalesController>().fetchOrders(
          search: searchQuery,
          status: filters?.firstWhere((f) => f.type == FilterType.status).value,
          page: page,
        );
      },
      
      // بناء العنصر
      itemBuilder: (context, order, index) {
        return GenericListCard(
          title: order.orderName ?? 'SO-${order.odooId}',
          subtitle: order.partnerName ?? 'عميل',
          
          status: ItemStatus.fromId(order.stateLabel ?? 'draft'),
          
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '\$${order.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (order.dateOrder != null)
                Text(
                  order.dateOrderFormatted,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
          
          infoChips: [
            if (order.linesCount != null && order.linesCount! > 0)
              InfoChip(
                label: '${order.linesCount} عناصر',
                icon: Icons.list,
              ),
            if (order.salesPersonName != null)
              InfoChip(
                label: order.salesPersonName!,
                icon: Icons.person,
              ),
          ],
          
          actions: [
            ActionButton(
              label: 'عرض',
              icon: Icons.visibility,
              isIcon: true,
              onPressed: () => _viewOrder(order),
            ),
            if (order.isDraft)
              ActionButton(
                label: 'تعديل',
                icon: Icons.edit,
                isIcon: true,
                onPressed: () => _editOrder(order),
              ),
          ],
        );
      },
      
      onItemTap: (order) => Get.to(() => SaleOrderDetailsScreen(order: order)),
      
      // الإعدادات
      enableSearch: true,
      enableRefresh: true,
      enablePagination: true,
      itemsPerPage: 20,
      
      // FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewOrder(),
        icon: Icon(Icons.add),
        label: Text('طلب جديد'),
      ),
      
      // حالة فارغة مخصصة
      customEmptyState: EmptyStateWidget(
        titleKey: 'no_sales_orders',
        messageKey: 'create_first_sale_order',
        icon: Icons.receipt_long,
        actionLabelKey: 'add',
        onActionPressed: () => _createNewOrder(),
      ),
    );
  }
  
  void _viewOrder(SaleOrderModel order) {
    Get.to(() => SaleOrderDetailsScreen(order: order));
  }
  
  void _editOrder(SaleOrderModel order) {
    Get.to(() => SaleOrderEditScreen(order: order));
  }
  
  void _createNewOrder() {
    Get.to(() => SaleOrderCreateScreen());
  }
}
```

---

## 📊 الميزات المدمجة تلقائياً

✅ بحث فوري مع Debouncing (500ms)  
✅ فلترة متقدمة (جاهزة، تحتاج Bottom Sheet)  
✅ ترتيب ديناميكي (جاهز، تحتاج Bottom Sheet)  
✅ Pagination تلقائي (scroll detection 80%)  
✅ Pull-to-Refresh  
✅ إدارة الحالات (فارغ، تحميل، خطأ)  
✅ دعم 4 لغات (عربي، إنجليزي، فرنسي، إسباني)  
✅ Material Design 3  
✅ RTL Support  

---

## 🚀 المبدأ

**80% كود مشترك + 20% تخصيص = 100% مرونة**

- استخدم `GenericListScreen` لأي لائحة
- استخدم `GenericListCard` لأي كارد
- خصص حسب الحاجة فقط

---

## 📝 TODO (للتحسينات المستقبلية)

- [ ] تطبيق Filter Bottom Sheet
- [ ] تطبيق Sort Bottom Sheet
- [ ] تطبيق Swipe Actions
- [ ] إضافة Shimmer Loading
- [ ] إضافة Multi-Select Mode
- [ ] إضافة Hero Animations
- [ ] Unit Tests

---

**آخر تحديث:** 23 أكتوبر 2025

