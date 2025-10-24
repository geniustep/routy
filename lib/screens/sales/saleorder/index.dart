// lib/screens/sales/saleorder/index.dart

/// 📦 Sales Order Module - وحدة أوامر البيع
///
/// يحتوي على:
/// - إنشاء أوامر البيع
/// - تعديل الأوامر
/// - عرض التفاصيل
/// - إدارة المسودات
/// - خدمات المبيعات

export 'create/create_new_order_screen.dart';
export 'create/controllers/order_controller.dart';
export 'create/controllers/partner_controller.dart';
export 'create/controllers/draft_controller.dart';
export 'create/services/order_creation_service.dart';
export 'create/services/order_validation_service.dart';
export 'create/services/price_management_service.dart';
export 'create/widgets/order_form_section.dart';
export 'create/widgets/product_selection_dialog.dart';
export 'create/widgets/product_line_card.dart';
// export 'create/widgets/product_line_editor.dart'; // TODO: Create this file
export 'create/widgets/sales_quantity_selector.dart';
export 'create/widgets/empty_products_view.dart';
export 'create/widgets/draft_indicator.dart';

export 'update/update_order_screen.dart';
export 'update/services/order_update_service.dart';
export 'update/services/order_line_change_tracker.dart';
// export 'update/services/order_persistence_tracker.dart'; // TODO: Create this file

export 'view/sale_order_detail_screen.dart';
// export 'view/widgets/order_actions_widget.dart'; // TODO: Create this file
// export 'view/widgets/order_summary_widget.dart'; // TODO: Create this file

export 'drafts/draft_sales_screen.dart';
export 'drafts/services/draft_sale_service.dart';
