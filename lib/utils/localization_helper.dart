// lib/utils/localization_helper.dart

import 'package:flutter/material.dart';

/// 🔤 Localization Helper - مساعد الترجمة
///
/// يوفر:
/// - معالجة مفاتيح الترجمة المفقودة
/// - قيم افتراضية للنصوص
class LocalizationHelper {
  /// الحصول على نص مع قيمة افتراضية
  static String getText(BuildContext context, String key, String fallback) {
    // استخدام القيمة الافتراضية مباشرة
    return fallback;
  }

  // ============= Sales Module Keys =============

  static const String saveDraft = 'save_draft';
  static const String addProduct = 'add_product';
  static const String scanBarcode = 'scan_barcode';
  static const String orderSummary = 'order_summary';
  static const String subtotal = 'subtotal';
  static const String discount = 'discount';
  static const String savings = 'savings';
  static const String total = 'total';
  static const String createOrder = 'create_order';
  static const String orderDetails = 'order_details';
  static const String selectCustomer = 'select_customer';
  static const String pleaseSelectCustomer = 'please_select_customer';
  static const String priceList = 'price_list';
  static const String selectPriceList = 'select_price_list';
  static const String pleaseSelectPriceList = 'please_select_price_list';
  static const String paymentTerms = 'payment_terms';
  static const String selectPaymentTerms = 'select_payment_terms';
  static const String pleaseSelectPaymentTerms = 'please_select_payment_terms';
  static const String setDeliveryDate = 'set_delivery_date';
  static const String deliveryDate = 'delivery_date';
  static const String selectDeliveryDate = 'select_delivery_date';
  static const String pleaseSelectDeliveryDate = 'please_select_delivery_date';
  static const String quantity = 'quantity';
  static const String price = 'price';
  static const String pleaseEnterQuantity = 'please_enter_quantity';
  static const String pleaseEnterValidQuantity = 'please_enter_valid_quantity';
  static const String pleaseEnterPrice = 'please_enter_price';
  static const String pleaseEnterValidPrice = 'please_enter_valid_price';
  static const String pleaseEnterDiscount = 'please_enter_discount';
  static const String pleaseEnterValidDiscount = 'please_enter_valid_discount';
  static const String noProductsAdded = 'no_products_added';
  static const String addProductsToOrder = 'add_products_to_order';
  static const String tips = 'tips';
  static const String addProductsTips = 'add_products_tips';
  static const String draftHasChanges = 'draft_has_changes';
  static const String draftSaved = 'draft_saved';
  static const String deleteDraft = 'delete_draft';
  static const String selectProduct = 'select_product';
  static const String searchProducts = 'search_products';
  static const String category = 'category';
  static const String allCategories = 'all_categories';
  static const String type = 'type';
  static const String allTypes = 'all_types';
  static const String noProductsFound = 'no_products_found';
  static const String select = 'select';
  static const String addToOrder = 'add_to_order';
  static const String enterQuantity = 'enter_quantity';
  static const String enterPrice = 'enter_price';
  static const String enterDiscount = 'enter_discount';
  static const String updateOrder = 'update_order';
  static const String unsavedChanges = 'unsaved_changes';
  static const String orderNumber = 'order_number';
  static const String noProducts = 'no_products';
  static const String saveChanges = 'save_changes';
  static const String customerInfo = 'customer_info';
  static const String customerName = 'customer_name';
  static const String tax = 'tax';
  static const String actions = 'actions';
  static const String duplicate = 'duplicate';
  static const String share = 'share';
  static const String sent = 'sent';
  static const String draftSales = 'draft_sales';
  static const String clearAll = 'clear_all';
  static const String searchDrafts = 'search_drafts';
  static const String noDraftsFound = 'no_drafts_found';
  static const String noDrafts = 'no_drafts';
  static const String createNewOrder = 'create_new_order';
  static const String continueEditing = 'continue_editing';
}
