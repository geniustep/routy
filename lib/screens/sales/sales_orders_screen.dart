import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sales_controller.dart';
import '../../models/sales/sale_order_model.dart';
import '../../models/common/index.dart';
import '../../widgets/common/index.dart';
import '../../l10n/app_localizations.dart';
import 'sale_order_details_screen.dart';

/// شاشة لائحة أوامر البيع
class SalesOrdersScreen extends StatelessWidget {
  const SalesOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final salesController = Get.find<SalesController>();

    return GenericListScreen<SaleOrderModel>(
      // العنوان
      titleKey: l10n.sales_orders,
      searchHintKey: l10n.search_sales_orders,

      // جلب البيانات
      fetchData: ({searchQuery, filters, sortOption, page}) async {
        // استخراج الفلتر النشط
        String? statusFilter;
        if (filters != null && filters.isNotEmpty) {
          final statusFilterOption = filters.firstWhereOrNull(
            (f) => f.type == FilterType.status,
          );
          if (statusFilterOption != null) {
            statusFilter = statusFilterOption.value as String?;
          }
        }

        // استخراج الترتيب
        String? sortField;
        String? sortOrder;
        if (sortOption != null) {
          sortField = sortOption.field;
          sortOrder = sortOption.order == SortOrder.ascending ? 'ASC' : 'DESC';
        }

        return await salesController.fetchOrders(
          search: searchQuery,
          status: statusFilter,
          page: page,
          sortField: sortField,
          sortOrder: sortOrder,
        );
      },

      // بناء عنصر اللائحة
      itemBuilder: (context, order, index) {
        return GenericListCard(
          // المحتوى الأساسي
          title: order.orderName.isEmpty
              ? 'SO-${order.odooId ?? index + 1}'
              : order.orderName,
          subtitle: order.partnerName ?? l10n.customer,
          secondaryText: order.clientOrderRefText != null
              ? 'Ref: ${order.clientOrderRefText}'
              : null,

          // Leading: أيقونة
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getStatusColor(order.stateLabel).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long,
              color: _getStatusColor(order.stateLabel),
            ),
          ),

          // الحالة
          status: _getOrderStatus(order.stateLabel),

          // السعر في الـ trailing
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                order.totalAmountFormatted,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              if (order.dateOrderFormatted != null)
                Text(
                  order.dateOrderFormatted!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),

          // معلومات إضافية
          infoChips: [
            if (order.linesCount > 0)
              InfoChip(
                label: '${order.linesCount} ${l10n.items}',
                icon: Icons.list,
                backgroundColor: Colors.blue.shade50,
                textColor: Colors.blue.shade700,
              ),
            if (order.salesPersonName != null)
              InfoChip(
                label: order.salesPersonName!,
                icon: Icons.person,
                backgroundColor: Colors.purple.shade50,
                textColor: Colors.purple.shade700,
              ),
            if (order.teamName != null)
              InfoChip(
                label: order.teamName!,
                icon: Icons.groups,
                backgroundColor: Colors.orange.shade50,
                textColor: Colors.orange.shade700,
              ),
          ],

          // أزرار الإجراءات
          actions: [
            ActionButton(
              label: l10n.view,
              icon: Icons.visibility,
              isIcon: true,
              onPressed: () => _viewOrderDetails(context, order),
            ),
            if (order.isDraft)
              ActionButton(
                label: l10n.edit,
                icon: Icons.edit,
                isIcon: true,
                color: Colors.blue,
                onPressed: () => _editOrder(order),
              ),
          ],

          // عند النقر
          onTap: () => _viewOrderDetails(context, order),
        );
      },

      // عند النقر على العنصر
      onItemTap: (order) => _viewOrderDetails(context, order),

      // مجموعات الفلاتر
      filterGroups: [
        FilterGroup(
          titleKey: l10n.status,
          allowMultiple: false,
          options: [
            FilterOption(
              id: 'all',
              labelKey: 'all',
              value: 'all',
              type: FilterType.status,
              isSelected: true,
            ),
            FilterOption(
              id: 'draft',
              labelKey: 'draft',
              value: 'draft',
              type: FilterType.status,
            ),
            FilterOption(
              id: 'sent',
              labelKey: 'sent',
              value: 'sent',
              type: FilterType.status,
            ),
            FilterOption(
              id: 'sale',
              labelKey: 'confirmed',
              value: 'sale',
              type: FilterType.status,
            ),
            FilterOption(
              id: 'done',
              labelKey: 'completed',
              value: 'done',
              type: FilterType.status,
            ),
            FilterOption(
              id: 'cancel',
              labelKey: 'cancelled',
              value: 'cancel',
              type: FilterType.status,
            ),
          ],
        ),
      ],

      // خيارات الترتيب
      sortOptions: [
        SortOption(
          id: 'date_new',
          labelKey: 'newest_first',
          field: 'date_order',
          order: SortOrder.descending,
          isSelected: true,
        ),
        SortOption(
          id: 'date_old',
          labelKey: 'oldest_first',
          field: 'date_order',
          order: SortOrder.ascending,
        ),
        SortOption(
          id: 'amount_high',
          labelKey: 'highest_amount',
          field: 'amount_total',
          order: SortOrder.descending,
        ),
        SortOption(
          id: 'amount_low',
          labelKey: 'lowest_amount',
          field: 'amount_total',
          order: SortOrder.ascending,
        ),
        SortOption(
          id: 'name',
          labelKey: 'alphabetical',
          field: 'name',
          order: SortOrder.ascending,
        ),
      ],

      // الإعدادات
      enableSearch: true,
      enableRefresh: true,
      enablePagination: true,
      itemsPerPage: 20,

      // FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewOrder(),
        icon: const Icon(Icons.add),
        label: Text(l10n.new_sale),
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

  /// الحصول على حالة الأمر
  ItemStatus _getOrderStatus(String state) {
    switch (state) {
      case 'draft':
        return ItemStatus.draft;
      case 'sent':
        return ItemStatus.pending;
      case 'sale':
        return ItemStatus.confirmed;
      case 'done':
        return ItemStatus.completed;
      case 'cancel':
        return ItemStatus.cancelled;
      default:
        return ItemStatus.draft;
    }
  }

  /// الحصول على لون الحالة
  Color _getStatusColor(String? state) {
    switch (state) {
      case 'draft':
        return Colors.orange;
      case 'sent':
        return Colors.amber;
      case 'sale':
        return Colors.blue;
      case 'done':
        return Colors.green;
      case 'cancel':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// عرض تفاصيل الأمر
  void _viewOrderDetails(BuildContext context, SaleOrderModel order) {
    Get.to(
      () => SaleOrderDetailsScreen(order: order),
      transition: Transition.rightToLeft,
    );
  }

  /// تعديل الأمر
  void _editOrder(SaleOrderModel order) {
    // TODO: تطبيق صفحة التعديل
    Get.snackbar(
      'قيد التطوير',
      'صفحة تعديل أمر البيع قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// إنشاء أمر جديد
  void _createNewOrder() {
    // TODO: تطبيق صفحة الإنشاء
    Get.snackbar(
      'قيد التطوير',
      'صفحة إنشاء أمر بيع جديد قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
