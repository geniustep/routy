// lib/screens/sales/saleorder/update/update_order_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routy/screens/sales/saleorder/create/controllers/order_controller.dart';
import 'package:routy/screens/sales/saleorder/create/controllers/partner_controller.dart';
import 'package:routy/screens/sales/saleorder/create/controllers/draft_controller.dart';
import 'package:routy/screens/sales/saleorder/update/services/order_update_service.dart';
import 'package:routy/screens/sales/saleorder/update/services/order_line_change_tracker.dart';
import 'package:routy/l10n/app_localizations.dart';
import 'package:routy/utils/app_logger.dart';

/// 🔄 Update Order Screen - شاشة تحديث أمر البيع
///
/// تدعم:
/// - تحديث أوامر البيع
/// - تعديل المنتجات
/// - تتبع التغييرات
/// - حفظ التحديثات
class UpdateOrderScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const UpdateOrderScreen({super.key, required this.order});

  @override
  State<UpdateOrderScreen> createState() => _UpdateOrderScreenState();
}

class _UpdateOrderScreenState extends State<UpdateOrderScreen> {
  // ============= Controllers =============

  final OrderController orderController = Get.put(OrderController());
  final SalesPartnerController partnerController = Get.put(
    SalesPartnerController(),
  );
  final DraftController draftController = Get.put(DraftController());

  // ============= Services =============

  final OrderUpdateService _updateService = OrderUpdateService();
  final OrderLineChangeTracker _changeTracker = OrderLineChangeTracker();

  // ============= State =============

  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasChanges = false;
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
        '\n🔄 ========== INITIALIZING UPDATE ORDER SCREEN ==========',
      );
      appLogger.info('Order ID: ${widget.order['id']}');
      appLogger.info('Order Name: ${widget.order['name']}');

      // تهيئة Controllers
      await _initializeControllers();

      // تحميل بيانات الطلب
      await _loadOrderData();

      // تهيئة متتبع التغييرات
      _changeTracker.initialize([]);

      appLogger.info('✅ Update order screen initialized successfully');
      appLogger.info('=====================================================\n');
    } catch (e) {
      appLogger.error('❌ Error initializing update order screen: $e');
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

  Future<void> _loadOrderData() async {
    try {
      // تحميل بيانات الطلب
      final orderData = widget.order;

      // تحميل بيانات العميل
      if (orderData['partner_id'] != null) {
        // سيتم تحميل بيانات العميل لاحقاً
      }

      // تحميل أسطر الطلب
      if (orderData['order_line'] != null) {
        // سيتم تحميل أسطر الطلب لاحقاً
      }

      appLogger.info('✅ Order data loaded');
    } catch (e) {
      appLogger.error('❌ Error loading order data: $e');
      throw e;
    }
  }

  // ============= Build =============

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.update_order),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.update_order),
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
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(l10n),
      body: Column(
        children: [
          // مؤشر التغييرات
          if (_hasChanges)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.unsaved_changes,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

          // المحتوى الرئيسي
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // معلومات الطلب
                  _buildOrderInfo(l10n),

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
    );
  }

  // ============= App Bar =============

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.update_order),
      backgroundColor: Colors.orange,
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
      ],
    );
  }

  // ============= Order Info =============

  Widget _buildOrderInfo(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.order_info,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // معلومات الطلب
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.order_number,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        widget.order['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.customer,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        widget.order['partner_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============= Products Section =============

  Widget _buildProductsSection(AppLocalizations l10n) {
    return Obx(() {
      if (orderController.productLines.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.no_products,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان القسم
          Text(
            l10n.products,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // قائمة المنتجات
          ...orderController.productLines.asMap().entries.map((entry) {
            final index = entry.key;
            final line = entry.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory, color: Colors.blue),
                ),
                title: Text(
                  line.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'الكمية: ${line.quantity} | السعر: ${line.priceUnit.toStringAsFixed(2)} Dh',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => orderController.editLine(index),
                      icon: const Icon(Icons.edit),
                      tooltip: l10n.edit,
                    ),
                    IconButton(
                      onPressed: () => orderController.deleteLine(index),
                      icon: const Icon(Icons.delete),
                      tooltip: l10n.delete,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
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

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.order_summary,
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
                  Text(l10n.subtotal),
                  Text('${subtotal.toStringAsFixed(2)} Dh'),
                ],
              ),

              // الخصم
              if (discount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.discount),
                    Text('-${discount.toStringAsFixed(2)} Dh'),
                  ],
                ),
              ],

              const Divider(),

              // الإجمالي النهائي
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.total,
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
              onPressed: _isSaving ? null : _cancelUpdate,
              child: Text(l10n.cancel),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.save_changes),
            ),
          ),
        ],
      ),
    );
  }

  // ============= Event Handlers =============

  void _cancelUpdate() {
    if (_hasChanges) {
      Get.dialog(
        AlertDialog(
          title: Text('تأكيد الإلغاء'),
          content: Text('لديك تغييرات غير محفوظة. هل تريد تجاهل التغييرات؟'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('متابعة التحرير'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: Text('تجاهل التغييرات'),
            ),
          ],
        ),
      );
    } else {
      Get.back();
    }
  }

  Future<void> _saveChanges() async {
    try {
      setState(() {
        _isSaving = true;
      });

      // التحقق من وجود تغييرات
      if (!_hasChanges) {
        Get.snackbar(
          'لا توجد تغييرات',
          'لم يتم إجراء أي تغييرات على الطلب',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // تحديث الطلب
      final orderId = widget.order['id'] as int;
      final orderData = partnerController.getFormData();
      final productLines = orderController.getServerProductLinesData();

      await _updateService.updateOrder(
        orderId: orderId,
        orderData: orderData,
        productLines: productLines,
      );

      Get.snackbar(
        'تم التحديث',
        'تم تحديث أمر البيع بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // العودة للشاشة السابقة
      Get.back();
    } catch (e) {
      appLogger.error('❌ Error saving changes: $e');
      Get.snackbar(
        'خطأ في التحديث',
        'فشل في تحديث أمر البيع: $e',
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
}
