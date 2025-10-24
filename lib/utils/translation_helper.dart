import '../l10n/app_localizations.dart';

/// مساعد الترجمة للنظام الهجين
class TranslationHelper {
  /// الحصول على ترجمة النصوص العامة
  static String getCommonTranslation(AppLocalizations l10n, String key) {
    switch (key) {
      // Common
      case 'loading':
        return l10n.loading;
      case 'error_occurred':
        return l10n.error_occurred;
      case 'error_loading_data':
        return l10n.error_loading_data;
      case 'no_data_found':
        return l10n.no_data_found;
      case 'no_items_found':
        return l10n.no_items_found;
      case 'try_different_search':
        return l10n.try_different_search;
      case 'retry':
        return l10n.retry;
      case 'search':
        return l10n.search;
      case 'filter':
        return l10n.filter;
      case 'apply':
        return l10n.apply;
      case 'sort_by':
        return l10n.sort_by;

      // Status
      case 'draft':
        return l10n.draft;
      case 'pending':
        return l10n.pending;
      case 'confirmed':
        return l10n.confirmed;
      case 'in_progress':
        return l10n.in_progress;
      case 'completed':
        return l10n.completed;
      case 'delivered':
        return l10n.delivered;
      case 'cancelled':
        return l10n.cancelled;
      case 'paid':
        return l10n.paid;
      case 'unpaid':
        return l10n.unpaid;

      // Actions
      case 'add':
        return l10n.add;
      case 'edit':
        return l10n.edit;
      case 'delete':
        return l10n.delete;
      case 'save':
        return l10n.save;
      case 'cancel':
        return l10n.cancel;
      case 'confirm':
        return l10n.confirm;

      // Sales
      case 'sales_orders':
        return l10n.sales_orders;
      case 'search_sales_orders':
        return l10n.search_sales_orders;
      case 'new_sale':
        return l10n.new_sale;
      case 'sale_order':
        return l10n.sale_order;
      case 'order_info':
        return l10n.order_info;
      case 'total_amount':
        return l10n.total_amount;
      case 'notes':
        return l10n.notes;
      case 'print':
        return l10n.print;
      case 'items':
        return l10n.items;
      case 'view':
        return l10n.view;

      default:
        return key;
    }
  }
}
