import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';
import 'package:routy/controllers/partner_controller.dart';
import 'package:routy/models/partners/partners_model.dart';
import 'package:routy/models/products/product_list/pricelist_model.dart';
import 'package:routy/models/products/product_model.dart';
import 'package:routy/models/sales/sale_order_model.dart';
import 'package:routy/screens/sales/saleorder/create/controllers/draft_controller.dart';
import 'package:routy/screens/sales/saleorder/create/controllers/order_controller.dart';
import 'package:routy/screens/sales/saleorder/create/services/order_creation_service.dart';
import 'package:routy/screens/sales/saleorder/create/services/order_validation_service.dart';
import 'package:routy/screens/sales/saleorder/create/widgets/product_line_card.dart';
import 'package:routy/screens/sales/saleorder/create/widgets/empty_products_view.dart';
import 'package:routy/utils/pref_utils.dart';

class CreateNewOrder extends StatefulWidget {
  final PartnerModel? partner;
  final Map<String, dynamic>? draft;

  const CreateNewOrder({super.key, this.partner, this.draft});

  @override
  State<CreateNewOrder> createState() => _CreateNewOrderState();
}

class _CreateNewOrderState extends State<CreateNewOrder> {
  // ============= Controllers =============
  final OrderController orderController = Get.put(OrderController());
  final DraftController draftController = Get.put(DraftController());
  final PartnerController partnerController = Get.put(PartnerController());

  // ============= Services =============
  final OrderCreationService orderService = OrderCreationService();
  final OrderValidationService validationService = OrderValidationService();

  // ============= Form =============
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  // ============= State (بدون Rx) =============
  bool _isLoading = false;
  bool _isSaving = false;
  bool isSending = false;
  String? _lastSavedText;

  // ============= Scroll Controller =============
  final ScrollController _scrollController = ScrollController();

  // ============= Worker للاستماع فقط لـ lastSavedAt =============
  Worker? _lastSavedWorker;

  @override
  void initState() {
    super.initState();

    // ✅ Worker محدد فقط لـ lastSavedAt
    _lastSavedWorker = ever(draftController.lastSavedAt, (_) {
      if (mounted) {
        setState(() {
          _lastSavedText = draftController.lastSavedText;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();

      if (widget.draft != null) {
        _loadDraftData(widget.draft!);
      } else if (widget.partner != null) {
        _checkAndLoadDraft();
      }

      _loadServerData();
    });
  }

  void _initializeControllers() {
    final products = <ProductModel>[]; // سيتم تحميلها لاحقاً
    final priceLists = <PricelistModel>[]; // سيتم تحميلها لاحقاً

    orderController.initialize(products: products, allPriceLists: priceLists);
    partnerController.initialize(preSelectedPartner: widget.partner);

    if (partnerController.hasPriceLists &&
        partnerController.priceListId != null) {
      orderController.selectedPriceListId = partnerController.priceListId;
    }

    ever(
      partnerController.selectedPriceList,
      (priceList) {
        if (priceList != null && partnerController.hasPriceLists) {
          orderController.selectedPriceListId = priceList.id;
        }
      },
      condition: () => partnerController.hasPriceLists,
    );
  }

  Future<void> _loadDraftData(Map<String, dynamic> draft) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (draft['partnerId'] != null) {
        partnerController.selectPartner(draft['partnerId']);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (draft['priceListId'] != null) {
        partnerController.selectPriceList(draft['priceListId']);
        orderController.selectedPriceListId = draft['priceListId'];
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (draft['paymentTermId'] != null) {
        partnerController.selectPaymentTerm(draft['paymentTermId']);
      }

      final products = draft['products'] as List? ?? [];

      for (var productData in products) {
        try {
          final product = PrefUtils.products.toList().firstWhere(
            (p) => p.id == productData['productId'],
          );

          await orderController.addProduct(product);

          final line = orderController.productLines.last;

          final quantity = productData['quantity'];
          final price = productData['price'];
          final discount = productData['discount'];

          line.quantity = quantity is int
              ? quantity.toInt()
              : (quantity ?? 1.0).toInt();
          line.quantityController.text = line.quantity.toString();

          line.priceUnit = price is int
              ? price.toDouble()
              : (price ?? 0.0).toDouble();
          line.discountPercentage = discount is int
              ? discount.toDouble()
              : (discount ?? 0.0).toDouble();

          if (line.discountPercentage > 0) {
            line.listPrice =
                line.priceUnit / (1 - line.discountPercentage / 100);
          } else {
            line.listPrice = line.priceUnit;
          }

          line.priceController.text = line.priceUnit.toStringAsFixed(2);
          line.discountController.text = line.discountPercentage
              .toStringAsFixed(1);
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error loading product: $e');
          }
        }
      }

      setState(() {});

      draftController.currentDraftId.value = draft['id'];
      if (draft['lastModified'] != null) {
        draftController.lastSavedAt.value = DateTime.parse(
          draft['lastModified'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading draft: $e');
      }
    }
  }

  @override
  void dispose() {
    _lastSavedWorker?.dispose();
    _scrollController.dispose();
    Get.delete<OrderController>();
    Get.delete<DraftController>();
    Get.delete<PartnerController>();
    super.dispose();
  }

  Future<void> _loadServerData() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading server data: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkAndLoadDraft() async {
    if (!partnerController.hasPartner) return;
    await draftController.checkAndLoadDraft(
      customerName: partnerController.partnerName ?? '',
      partnerId: partnerController.partnerId,
      priceListId: partnerController.priceListId,
    );
  }

  Future<void> _createOrder() async {
    print('isSending: $isSending started');
    if (!_formKey.currentState!.saveAndValidate()) {
      Get.snackbar(
        'خطأ',
        'يرجى ملء جميع الحقول المطلوبة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    final formData = partnerController.getFormData();
    final productLines = orderController.productLines;

    if (!partnerController.shouldSendPriceListId) {
      formData.remove('pricelist_id');
    }

    final validationResult = validationService.validateOrder(
      partner: partnerController.selectedPartner.value,
      productLines: productLines,
      priceList: partnerController.selectedPriceList.value,
      paymentTerm: null, // TODO: إضافة PaymentTermModel
      orderData: formData,
    );

    if (!validationResult.isValid) {
      Get.snackbar(
        'خطأ في التحقق',
        validationResult.errors.join('\n'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // TODO: تنفيذ إنشاء الطلب من API
      await Future.delayed(const Duration(seconds: 2)); // محاكاة API call

      // محاكاة نجاح إنشاء الطلب
      final orderId = DateTime.now().millisecondsSinceEpoch;

      if (draftController.hasDraft) {
        unawaited(draftController.deleteCurrentDraft());
      }

      // TODO: تنفيذ قراءة الطلب من API
      final newOrder = SaleOrderModel(
        id: orderId,
        name: 'SO$orderId',
        partnerId: formData['partner_id'],
        state: 'draft',
        amountTotal: orderController.getOrderTotal(),
        dateOrder: DateTime.now().toIso8601String(),
      );

      // ✅ إضافة الطلب الجديد
      PrefUtils.sales.add(newOrder);
      PrefUtils.sales.refresh();

      // ✅ الانتقال فوراً بدون تأخير
      _navigateToOrderDetail(newOrder);
    } catch (e) {
      // ✅ معالجة الأخطاء
      Get.snackbar(
        'خطأ في إنشاء الطلب',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _navigateToOrderDetail(SaleOrderModel order) {
    isSending = true;
    print('isSending: $isSending finished');

    // TODO: تنفيذ الانتقال إلى تفاصيل الطلب
    Get.snackbar(
      'نجح',
      'تم إنشاء الطلب بنجاح',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      icon: const Icon(Icons.check, color: Colors.white),
    );

    // العودة إلى الشاشة السابقة
    Get.back();
  }

  Future<void> _scanBarcode() async {
    try {
      // TODO: تنفيذ مسح الباركود
      Get.snackbar(
        'تنبيه',
        'ماسح الباركود غير متاح حالياً',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
      return;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scanning barcode: $e');
      }
    }
  }

  Future<void> _autoSaveDraft() async {
    if (!partnerController.hasPartner) return;

    try {
      await draftController.autoSaveDraft(
        customerName: partnerController.partnerName!,
        partnerId: partnerController.partnerId!,
        priceListId: partnerController.priceListId,
      );

      // TODO: تنفيذ إشعار تغيير عدد المسودات
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in auto-save: $e');
      }
    }
  }

  Future<void> _openProductSelection() async {
    if (!partnerController.hasPartner) {
      Get.snackbar(
        'تنبيه',
        'يرجى اختيار العميل أولاً',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // TODO: تنفيذ showProductSelectionDialog
    Get.snackbar(
      'تنبيه',
      'اختيار المنتجات غير متاح حالياً',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withOpacity(0.8),
      colorText: Colors.white,
      icon: const Icon(Icons.warning, color: Colors.white),
    );
    return;
  }

  Future<void> _cancelOrder() async {
    if (orderController.hasProducts) {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('تأكيد الإلغاء'),
            ],
          ),
          content: const Text(
            'هل أنت متأكد من إلغاء الإنشاء؟\nسيتم فقدان جميع البيانات المدخلة.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('تأكيد الإلغاء'),
            ),
          ],
        ),
      );

      if (result != true) return;
    }

    if (draftController.hasDraft) {
      await draftController.deleteCurrentDraft();
    }

    Get.back();
  }

  // ============= UI =============
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('طلب بيع جديد'),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: _cancelOrder,
          tooltip: 'إلغاء الإنشاء',
        ),
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: _scanBarcode,
          tooltip: 'مسح الباركود',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // ✅ عرض آخر حفظ بدون Obx
        if (_lastSavedText != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16),
                const SizedBox(width: 8),
                Text(_lastSavedText!, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),

        _buildFixedOrderForm(),

        Expanded(child: _buildScrollableContent()),

        _buildFixedSaveButton(),

        // ✅ مؤشر التقدم المحسن
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return _ProgressIndicator(
      hasPartner: partnerController.hasPartner,
      hasProducts: orderController.hasProducts,
    );
  }

  Widget _buildFixedOrderForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'تفاصيل الطلب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

            // زر اختيار العميل
            _buildPartnerSelector(),

            const SizedBox(height: 16),

            // عرض تفاصيل العميل المختار
            Obx(() => _buildPartnerDetails()),

            const SizedBox(height: 16),

            Text(
              'عدد المنتجات: ${orderController.productsCount}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => Text(
                partnerController.partnerName ?? "اختر العميل",
                style: TextStyle(
                  fontSize: 16,
                  color: partnerController.partnerName != null
                      ? Colors.black
                      : Colors.grey[600],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_drop_down),
            onPressed: _selectPartner,
            tooltip: 'اختيار العميل',
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerDetails() {
    final selectedPartner = partnerController.selectedPartner.value;
    final selectedPriceList = partnerController.selectedPriceList.value;

    if (selectedPartner == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'العميل: ${selectedPartner.displayName ?? selectedPartner.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (selectedPriceList != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.list_alt, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'قائمة الأسعار: ${selectedPriceList.name}',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// فتح شاشة اختيار العميل
  void _selectPartner() async {
    try {
      // فتح شاشة اختيار العميل
      final selectedPartner = await Get.toNamed(
        '/partners',
        arguments: {
          'selectMode': true,
          'title': 'اختيار العميل',
          'showCustomersOnly': true,
        },
      );

      if (selectedPartner != null && selectedPartner is PartnerModel) {
        // اختيار العميل
        partnerController.selectPartner(selectedPartner.id!);

        // إظهار رسالة نجاح
        Get.snackbar(
          'تم اختيار العميل',
          'تم اختيار العميل: ${selectedPartner.displayName ?? selectedPartner.name}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      // إظهار رسالة خطأ
      Get.snackbar(
        'خطأ في اختيار العميل',
        'حدث خطأ أثناء اختيار العميل: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Widget _buildProductsList() {
    return GetBuilder<OrderController>(
      id: 'product_lines',
      builder: (controller) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.productLines.length,
          itemBuilder: (context, index) {
            final line = controller.productLines[index];
            final isEditing = controller.editingLineIndex.value == index;

            if (isEditing) {
              return ProductLineCard(
                index: index,
                line: line,
                isEditing: true,
                onEdit: () => controller.editLine(index),
                onDelete: () {
                  controller.deleteLine(index);
                  setState(() {});
                  _autoSaveDraft();
                },
              );
            }

            return ProductLineCard(
              index: index,
              line: line,
              isEditing: false,
              onEdit: () => controller.editLine(index),
              onDelete: () {
                controller.deleteLine(index);
                setState(() {});
                _autoSaveDraft();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFixedSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ الإجمالي - تصميم مدمج وأصغر
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'الإجمالي:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${orderController.getOrderTotal().toStringAsFixed(2)} Dh',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ✅ زر الحفظ - أصغر وأنيق
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _createOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isSaving ? Colors.grey : Colors.blue,
          foregroundColor: Colors.white,
          elevation: _isSaving ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isSaving
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'جاري الحفظ...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.save_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'حفظ الطلب',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _ProductsHeaderDelegate(
            onAddProduct: _openProductSelection,
            productsCount: orderController.productsCount,
            hasProducts: orderController.hasProducts,
          ),
        ),

        SliverToBoxAdapter(
          child: GetBuilder<OrderController>(
            id: 'product_lines',
            builder: (controller) {
              return controller.hasProducts
                  ? _buildProductsList()
                  : EmptyProductsView(onAddProduct: _openProductSelection);
            },
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

class _ProductsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onAddProduct;
  final int productsCount;
  final bool hasProducts;

  _ProductsHeaderDelegate({
    required this.onAddProduct,
    required this.productsCount,
    required this.hasProducts,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'المنتجات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              if (hasProducts)
                Text(
                  '$productsCount منتج',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: onAddProduct,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة منتج'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 70;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

// ============= Enhanced UI Components =============

/// مؤشر التقدم المحسن
class _ProgressIndicator extends StatelessWidget {
  final bool hasPartner;
  final bool hasProducts;

  const _ProgressIndicator({
    required this.hasPartner,
    required this.hasProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ مؤشر التقدم
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: hasPartner ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'اختيار العميل',
                style: TextStyle(
                  color: hasPartner ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.check_circle,
                color: hasProducts ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'إضافة المنتجات',
                style: TextStyle(
                  color: hasProducts ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ✅ شريط التقدم
          LinearProgressIndicator(
            value: _calculateProgress(),
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ],
      ),
    );
  }

  double _calculateProgress() {
    double progress = 0.0;
    if (hasPartner) progress += 0.5;
    if (hasProducts) progress += 0.5;
    return progress;
  }
}
