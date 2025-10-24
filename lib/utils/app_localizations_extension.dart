// lib/utils/app_localizations_extension.dart

import 'package:flutter/material.dart';
import 'package:routy/utils/localization_helper.dart';

/// 🔤 App Localizations Extension - امتداد الترجمة
///
/// يوفر:
/// - معالجة مفاتيح الترجمة المفقودة
/// - قيم افتراضية للنصوص
extension AppLocalizationsExtension on BuildContext {
  /// الحصول على نص مع قيمة افتراضية
  String getText(String key, String fallback) {
    return LocalizationHelper.getText(this, key, fallback);
  }

  // ============= Sales Module Methods =============

  String get saveDraft => getText(LocalizationHelper.saveDraft, 'حفظ المسودة');
  String get addProduct => getText(LocalizationHelper.addProduct, 'إضافة منتج');
  String get scanBarcode =>
      getText(LocalizationHelper.scanBarcode, 'مسح الباركود');
  String get orderSummary =>
      getText(LocalizationHelper.orderSummary, 'ملخص الطلب');
  String get subtotal => getText(LocalizationHelper.subtotal, 'المجموع الفرعي');
  String get discount => getText(LocalizationHelper.discount, 'الخصم');
  String get savings => getText(LocalizationHelper.savings, 'التوفير');
  String get total => getText(LocalizationHelper.total, 'المجموع');
  String get createOrder =>
      getText(LocalizationHelper.createOrder, 'إنشاء الطلب');
  String get orderDetails =>
      getText(LocalizationHelper.orderDetails, 'تفاصيل الطلب');
  String get selectCustomer =>
      getText(LocalizationHelper.selectCustomer, 'اختر العميل');
  String get pleaseSelectCustomer =>
      getText(LocalizationHelper.pleaseSelectCustomer, 'يرجى اختيار العميل');
  String get priceList =>
      getText(LocalizationHelper.priceList, 'قائمة الأسعار');
  String get selectPriceList =>
      getText(LocalizationHelper.selectPriceList, 'اختر قائمة الأسعار');
  String get pleaseSelectPriceList => getText(
    LocalizationHelper.pleaseSelectPriceList,
    'يرجى اختيار قائمة الأسعار',
  );
  String get paymentTerms =>
      getText(LocalizationHelper.paymentTerms, 'شروط الدفع');
  String get selectPaymentTerms =>
      getText(LocalizationHelper.selectPaymentTerms, 'اختر شروط الدفع');
  String get pleaseSelectPaymentTerms => getText(
    LocalizationHelper.pleaseSelectPaymentTerms,
    'يرجى اختيار شروط الدفع',
  );
  String get setDeliveryDate =>
      getText(LocalizationHelper.setDeliveryDate, 'تحديد تاريخ التسليم');
  String get deliveryDate =>
      getText(LocalizationHelper.deliveryDate, 'تاريخ التسليم');
  String get selectDeliveryDate =>
      getText(LocalizationHelper.selectDeliveryDate, 'اختر تاريخ التسليم');
  String get pleaseSelectDeliveryDate => getText(
    LocalizationHelper.pleaseSelectDeliveryDate,
    'يرجى اختيار تاريخ التسليم',
  );
  String get quantity => getText(LocalizationHelper.quantity, 'الكمية');
  String get price => getText(LocalizationHelper.price, 'السعر');
  String get pleaseEnterQuantity =>
      getText(LocalizationHelper.pleaseEnterQuantity, 'يرجى إدخال الكمية');
  String get pleaseEnterValidQuantity => getText(
    LocalizationHelper.pleaseEnterValidQuantity,
    'يرجى إدخال كمية صحيحة',
  );
  String get pleaseEnterPrice =>
      getText(LocalizationHelper.pleaseEnterPrice, 'يرجى إدخال السعر');
  String get pleaseEnterValidPrice =>
      getText(LocalizationHelper.pleaseEnterValidPrice, 'يرجى إدخال سعر صحيح');
  String get pleaseEnterDiscount =>
      getText(LocalizationHelper.pleaseEnterDiscount, 'يرجى إدخال الخصم');
  String get pleaseEnterValidDiscount => getText(
    LocalizationHelper.pleaseEnterValidDiscount,
    'يرجى إدخال خصم صحيح',
  );
  String get noProductsAdded =>
      getText(LocalizationHelper.noProductsAdded, 'لم يتم إضافة منتجات');
  String get addProductsToOrder =>
      getText(LocalizationHelper.addProductsToOrder, 'إضافة منتجات للطلب');
  String get tips => getText(LocalizationHelper.tips, 'نصائح');
  String get addProductsTips =>
      getText(LocalizationHelper.addProductsTips, 'نصائح لإضافة المنتجات');
  String get draftHasChanges =>
      getText(LocalizationHelper.draftHasChanges, 'المسودة تحتوي على تغييرات');
  String get draftSaved =>
      getText(LocalizationHelper.draftSaved, 'تم حفظ المسودة');
  String get deleteDraft =>
      getText(LocalizationHelper.deleteDraft, 'حذف المسودة');
  String get selectProduct =>
      getText(LocalizationHelper.selectProduct, 'اختر المنتج');
  String get searchProducts =>
      getText(LocalizationHelper.searchProducts, 'البحث في المنتجات');
  String get category => getText(LocalizationHelper.category, 'الفئة');
  String get allCategories =>
      getText(LocalizationHelper.allCategories, 'جميع الفئات');
  String get type => getText(LocalizationHelper.type, 'النوع');
  String get allTypes => getText(LocalizationHelper.allTypes, 'جميع الأنواع');
  String get noProductsFound =>
      getText(LocalizationHelper.noProductsFound, 'لم يتم العثور على منتجات');
  String get select => getText(LocalizationHelper.select, 'اختر');
  String get addToOrder =>
      getText(LocalizationHelper.addToOrder, 'إضافة للطلب');
  String get enterQuantity =>
      getText(LocalizationHelper.enterQuantity, 'أدخل الكمية');
  String get enterPrice => getText(LocalizationHelper.enterPrice, 'أدخل السعر');
  String get enterDiscount =>
      getText(LocalizationHelper.enterDiscount, 'أدخل الخصم');
  String get updateOrder =>
      getText(LocalizationHelper.updateOrder, 'تحديث الطلب');
  String get unsavedChanges =>
      getText(LocalizationHelper.unsavedChanges, 'تغييرات غير محفوظة');
  String get orderNumber =>
      getText(LocalizationHelper.orderNumber, 'رقم الطلب');
  String get noProducts =>
      getText(LocalizationHelper.noProducts, 'لا توجد منتجات');
  String get saveChanges =>
      getText(LocalizationHelper.saveChanges, 'حفظ التغييرات');
  String get customerInfo =>
      getText(LocalizationHelper.customerInfo, 'معلومات العميل');
  String get customerName =>
      getText(LocalizationHelper.customerName, 'اسم العميل');
  String get tax => getText(LocalizationHelper.tax, 'الضريبة');
  String get actions => getText(LocalizationHelper.actions, 'الإجراءات');
  String get duplicate => getText(LocalizationHelper.duplicate, 'نسخ');
  String get share => getText(LocalizationHelper.share, 'مشاركة');
  String get sent => getText(LocalizationHelper.sent, 'مرسل');
  String get draftSales =>
      getText(LocalizationHelper.draftSales, 'مسودات المبيعات');
  String get clearAll => getText(LocalizationHelper.clearAll, 'مسح الكل');
  String get searchDrafts =>
      getText(LocalizationHelper.searchDrafts, 'البحث في المسودات');
  String get noDraftsFound =>
      getText(LocalizationHelper.noDraftsFound, 'لم يتم العثور على مسودات');
  String get noDrafts => getText(LocalizationHelper.noDrafts, 'لا توجد مسودات');
  String get createNewOrder =>
      getText(LocalizationHelper.createNewOrder, 'إنشاء طلب جديد');
  String get continueEditing =>
      getText(LocalizationHelper.continueEditing, 'متابعة التحرير');
}
