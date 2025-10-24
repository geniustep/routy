// lib/screens/sales/saleorder/create/create_new_order_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:routy/screens/sales/saleorder/create/controllers/order_controller.dart';
import 'package:routy/screens/sales/saleorder/create/controllers/partner_controller.dart';
import 'package:routy/screens/sales/saleorder/create/controllers/draft_controller.dart';
import 'package:routy/screens/sales/saleorder/create/services/order_creation_service.dart';
import 'package:routy/screens/sales/saleorder/create/services/order_validation_service.dart';
import 'package:routy/screens/sales/saleorder/create/widgets/order_form_section.dart';
import 'package:routy/screens/sales/saleorder/create/widgets/product_line_card.dart';
import 'package:routy/screens/sales/saleorder/create/widgets/empty_products_view.dart';
import 'package:routy/screens/sales/saleorder/create/widgets/draft_indicator.dart';
import 'package:routy/l10n/app_localizations.dart';
import 'package:routy/utils/app_localizations_extension.dart';
import 'package:routy/utils/app_logger.dart';

/// 🛒 Create New Order Screen - شاشة إنشاء أمر بيع جديد
///
/// تدعم:
/// - إنشاء أوامر البيع
/// - إدارة المنتجات
/// - تطبيق قوائم الأسعار
/// - حفظ المسودات
/// - التحقق من الصحة
class CreateNewOrderScreen extends StatefulWidget {
  const CreateNewOrderScreen({super.key});

  @override
  State<CreateNewOrderScreen> createState() => _CreateNewOrderScreenState();
}

class _CreateNewOrderScreenState extends State<CreateNewOrderScreen> {
  // ============= Controllers =============

  final OrderController orderController = Get.put(OrderController());
  final SalesPartnerController partnerController = Get.put(
    SalesPartnerController(),
  );
  final DraftController draftController = Get.put(DraftController());

  // ============= Services =============

  final OrderCreationService _orderService = OrderCreationService();
  final OrderValidationService _validationService = OrderValidationService();

  // ============= Form =============

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  // ============= State =============

  bool _isLoading = false;
  bool _isSaving = false;
  String _errorMessage = '';

  // ============= Lifecycle =============

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    // تنظيف Controllers
    Get.delete<OrderController>();
    Get.delete<SalesPartnerController>();
    Get.delete<DraftController>();
    super.dispose();
  }

  // ============= Initialization =============

  Future<void> _initializeScreen() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      appLogger.info(
        '\n🛒 ========== INITIALIZING CREATE ORDER SCREEN ==========',
      );

      // تهيئة Controllers
      await _initializeControllers();

      // التحقق من المسودات
      await _checkForDrafts();

      appLogger.info('✅ Create order screen initialized successfully');
      appLogger.info('=====================================================\n');
    } catch (e) {
      appLogger.error('❌ Error initializing create order screen: $e');
      setState(() {
        _errorMessage = 'خطأ في تهيئة الشاشة: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeControllers() async {
    // تهيئة OrderController
    orderController.initialize(
      products: [], // سيتم تحميلها لاحقاً
      allPriceLists: [], // سيتم تحميلها لاحقاً
      priceListId: null,
    );

    // تهيئة SalesPartnerController
    partnerController.initialize();

    appLogger.info('✅ Controllers initialized');
  }

  Future<void> _checkForDrafts() async {
    try {
      final customerName = partnerController.partnerName ?? '';
      final partnerId = partnerController.partnerId;
      final priceListId = partnerController.priceListId;

      if (customerName.isNotEmpty) {
        final hasDraft = await draftController.checkAndLoadDraft(
          customerName: customerName,
          partnerId: partnerId,
          priceListId: priceListId,
        );

        if (hasDraft) {
          appLogger.info('📝 Draft found and loaded');
        }
      }
    } catch (e) {
      appLogger.error('❌ Error checking for drafts: $e');
    }
  }

  // ============= Build =============

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.createOrder),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.createOrder),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = '';
                  });
                  _initializeScreen();
                },
                child: Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(l10n),
      body: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            // مؤشر المسودة
            if (draftController.hasDraft)
              DraftIndicator(
                lastSaved: draftController.lastSavedFormatted,
                onDelete: _deleteDraft,
              ),

            // المحتوى الرئيسي
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // قسم بيانات الطلب
                    OrderFormSection(
                      partnerController: partnerController,
                      onPartnerChanged: _onPartnerChanged,
                      onPriceListChanged: _onPriceListChanged,
                      onPaymentTermChanged: _onPaymentTermChanged,
                    ),

                    const SizedBox(height: 24),

                    // قسم المنتجات
                    _buildProductsSection(l10n),

                    const SizedBox(height: 24),

                    // قسم الإجمالي
                    _buildTotalSection(l10n),
                  ],
                ),
              ),
            ),

            // أزرار الإجراءات
            _buildActionButtons(l10n),
          ],
        ),
      ),
    );
  }

  // ============= App Bar =============

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.new_sale),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      actions: [
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: _isSaving ? null : _saveDraft,
          tooltip: context.saveDraft,
        ),
      ],
    );
  }

  // ============= Products Section =============

  Widget _buildProductsSection(AppLocalizations l10n) {
    return Obx(() {
      if (orderController.productLines.isEmpty) {
        return EmptyProductsView(
          onAddProduct: _addProduct,
          onScanBarcode: _scanBarcode,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان القسم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المنتجات',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addProduct,
                    tooltip: context.addProduct,
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _scanBarcode,
                    tooltip: context.scanBarcode,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // قائمة المنتجات
          ...orderController.productLines.asMap().entries.map((entry) {
            final index = entry.key;
            final line = entry.value;

            return ProductLineCard(
              line: line,
              index: index,
              isEditing: orderController.editingLineIndex.value == index,
              onEdit: () => orderController.editLine(index),
              onSave: () => orderController.saveLineEditing(),
              onCancel: () => orderController.cancelEditing(),
              onDelete: () => orderController.deleteLine(index),
              onQuantityChanged: (quantity) =>
                  orderController.updateQuantity(index, quantity),
              onPriceChanged: (price) =>
                  orderController.updatePrice(index, price),
              onDiscountChanged: (discount) =>
                  orderController.updateDiscount(index, discount),
            );
          }),
        ],
      );
    });
  }

  // ============= Total Section =============

  Widget _buildTotalSection(AppLocalizations l10n) {
    return Obx(() {
      final total = orderController.getOrderTotal();
      final subtotal = orderController.getOrderSubtotal();
      final discount = orderController.getOrderDiscount();
      final savings = orderController.getOrderSavings();

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.orderSummary,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // الإجمالي الفرعي
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.subtotal),
                  Text('${subtotal.toStringAsFixed(2)} Dh'),
                ],
              ),

              // الخصم
              if (discount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.discount),
                    Text('-${discount.toStringAsFixed(2)} Dh'),
                  ],
                ),
              ],

              // الادخار
              if (savings > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.savings),
                    Text('${savings.toStringAsFixed(2)} Dh'),
                  ],
                ),
              ],

              const Divider(),

              // الإجمالي النهائي
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.total,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${total.toStringAsFixed(2)} Dh',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  // ============= Action Buttons =============

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : _cancelOrder,
              child: Text('إلغاء'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _createOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(context.createOrder),
            ),
          ),
        ],
      ),
    );
  }

  // ============= Event Handlers =============

  void _onPartnerChanged() {
    // تحديث قوائم الأسعار عند تغيير العميل
    _updatePriceLists();

    // التحقق من المسودات
    _checkForDrafts();
  }

  void _onPriceListChanged() {
    // تطبيق قائمة الأسعار الجديدة
    if (partnerController.priceListId != null) {
      orderController.updateAllProductsPrices(partnerController.priceListId!);
    }
  }

  void _onPaymentTermChanged() {
    // تحديث شروط الدفع
    appLogger.info(
      '💳 Payment term changed: ${partnerController.paymentTermName}',
    );
  }

  Future<void> _updatePriceLists() async {
    // تحديث قوائم الأسعار الخاصة بالعميل
    // سيتم تنفيذها لاحقاً
  }

  Future<void> _addProduct() async {
    // فتح شاشة اختيار المنتجات
    // سيتم تنفيذها لاحقاً
    Get.snackbar(
      'قيد التطوير',
      'شاشة اختيار المنتجات قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _scanBarcode() async {
    // فتح شاشة مسح الباركود
    // سيتم تنفيذها لاحقاً
    Get.snackbar(
      'قيد التطوير',
      'شاشة مسح الباركود قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _saveDraft() async {
    try {
      setState(() {
        _isSaving = true;
      });

      final customerName = partnerController.partnerName ?? '';
      final partnerId = partnerController.partnerId;
      final priceListId = partnerController.priceListId;
      final products = orderController.getProductLinesData();

      await draftController.autoSaveDraft(
        customerName: customerName,
        partnerId: partnerId,
        priceListId: priceListId,
        products: products,
      );

      Get.snackbar(
        'تم الحفظ',
        'تم حفظ المسودة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      appLogger.error('❌ Error saving draft: $e');
      Get.snackbar(
        'خطأ في الحفظ',
        'فشل في حفظ المسودة: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _deleteDraft() async {
    try {
      await draftController.deleteCurrentDraft();

      Get.snackbar(
        'تم الحذف',
        'تم حذف المسودة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      appLogger.error('❌ Error deleting draft: $e');
      Get.snackbar(
        'خطأ في الحذف',
        'فشل في حذف المسودة: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _createOrder() async {
    try {
      setState(() {
        _isSaving = true;
      });

      // التحقق من صحة النموذج
      if (!_formKey.currentState!.validate()) {
        Get.snackbar(
          'خطأ في التحقق',
          'يرجى تصحيح الأخطاء في النموذج',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // التحقق من صحة البيانات
      final validationResult = _validationService.validateOrder(
        partner: partnerController.selectedPartner.value,
        productLines: orderController.productLines,
        priceList: partnerController.selectedPriceList.value,
        paymentTerm: partnerController.selectedPaymentTerm.value,
        orderData: partnerController.getFormData(),
      );

      if (!validationResult.isValid) {
        Get.snackbar(
          'خطأ في التحقق',
          validationResult.errors.join('\n'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // إنشاء الطلب
      final orderData = partnerController.getFormData();
      final productLines = orderController.getServerProductLinesData();

      await _orderService.createOrder(
        orderData: orderData,
        productLines: productLines,
      );

      // حذف المسودة بعد النجاح
      if (draftController.hasDraft) {
        await draftController.deleteCurrentDraft();
      }

      Get.snackbar(
        'تم الإنشاء',
        'تم إنشاء أمر البيع بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // العودة للشاشة السابقة
      Get.back();
    } catch (e) {
      appLogger.error('❌ Error creating order: $e');
      Get.snackbar(
        'خطأ في الإنشاء',
        'فشل في إنشاء أمر البيع: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _cancelOrder() {
    Get.back();
  }
}
