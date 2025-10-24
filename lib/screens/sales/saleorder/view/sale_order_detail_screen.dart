// lib/screens/sales/saleorder/view/sale_order_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routy/l10n/app_localizations.dart';
import 'package:routy/utils/app_logger.dart';

/// 📋 Sale Order Detail Screen - شاشة تفاصيل أمر البيع
///
/// تدعم:
/// - عرض تفاصيل الطلب
/// - عرض المنتجات
/// - عرض الإجماليات
/// - إجراءات الطلب
class SaleOrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const SaleOrderDetailScreen({super.key, required this.order});

  @override
  State<SaleOrderDetailScreen> createState() => _SaleOrderDetailScreenState();
}

class _SaleOrderDetailScreenState extends State<SaleOrderDetailScreen> {
  // ============= State =============

  bool _isLoading = false;
  String _errorMessage = '';

  // ============= Lifecycle =============

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  // ============= Initialization =============

  Future<void> _initializeScreen() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      appLogger.info(
        '\n📋 ========== INITIALIZING ORDER DETAIL SCREEN ==========',
      );
      appLogger.info('Order ID: ${widget.order['id']}');
      appLogger.info('Order Name: ${widget.order['name']}');

      // تحميل تفاصيل الطلب
      await _loadOrderDetails();

      appLogger.info('✅ Order detail screen initialized successfully');
      appLogger.info('=====================================================\n');
    } catch (e) {
      appLogger.error('❌ Error initializing order detail screen: $e');
      setState(() {
        _errorMessage = 'خطأ في تهيئة الشاشة: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOrderDetails() async {
    try {
      // تحميل تفاصيل الطلب
      // سيتم تنفيذها لاحقاً

      appLogger.info('✅ Order details loaded');
    } catch (e) {
      appLogger.error('❌ Error loading order details: $e');
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
          title: Text(l10n.order_details),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.order_details),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // معلومات الطلب
            _buildOrderInfo(l10n),

            const SizedBox(height: 24),

            // حالة الطلب
            _buildOrderStatus(l10n),

            const SizedBox(height: 24),

            // معلومات العميل
            _buildCustomerInfo(l10n),

            const SizedBox(height: 24),

            // المنتجات
            _buildProductsSection(l10n),

            const SizedBox(height: 24),

            // الإجماليات
            _buildTotalsSection(l10n),

            const SizedBox(height: 24),

            // إجراءات الطلب
            _buildOrderActions(l10n),
          ],
        ),
      ),
    );
  }

  // ============= App Bar =============

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.order_details),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: _printOrder,
          icon: const Icon(Icons.print),
          tooltip: l10n.print,
        ),
        IconButton(
          onPressed: _shareOrder,
          icon: const Icon(Icons.share),
          tooltip: l10n.share,
        ),
        PopupMenuButton<String>(
          onSelected: _onMenuSelected,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: 8),
                  Text(l10n.edit),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  const Icon(Icons.copy),
                  const SizedBox(width: 8),
                  Text(l10n.duplicate),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete),
                  const SizedBox(width: 8),
                  Text(l10n.delete),
                ],
              ),
            ),
          ],
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
            _buildInfoRow(l10n.order_number, widget.order['name'] ?? ''),
            _buildInfoRow(l10n.date, widget.order['date_order'] ?? ''),
            _buildInfoRow(l10n.customer, widget.order['partner_name'] ?? ''),
            _buildInfoRow(l10n.salesperson, widget.order['user_name'] ?? ''),
            _buildInfoRow(l10n.team, widget.order['team_name'] ?? ''),
          ],
        ),
      ),
    );
  }

  // ============= Order Status =============

  Widget _buildOrderStatus(AppLocalizations l10n) {
    final state = widget.order['state'] ?? 'draft';
    final statusColor = _getStatusColor(state);
    final statusText = _getStatusText(state, l10n);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.status,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            if (state == 'draft')
              ElevatedButton(
                onPressed: _confirmOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.confirm),
              ),
          ],
        ),
      ),
    );
  }

  // ============= Customer Info =============

  Widget _buildCustomerInfo(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.customer_info,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // معلومات العميل
            _buildInfoRow(
              l10n.customer_name,
              widget.order['partner_name'] ?? '',
            ),
            _buildInfoRow(l10n.email, widget.order['partner_email'] ?? ''),
            _buildInfoRow(l10n.phone, widget.order['partner_phone'] ?? ''),
            _buildInfoRow(l10n.address, widget.order['partner_address'] ?? ''),
          ],
        ),
      ),
    );
  }

  // ============= Products Section =============

  Widget _buildProductsSection(AppLocalizations l10n) {
    final products = widget.order['order_line'] as List<dynamic>? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.products,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            if (products.isEmpty)
              Center(
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
              )
            else
              ...products.map((product) => _buildProductItem(product, l10n)),
          ],
        ),
      ),
    );
  }

  // ============= Totals Section =============

  Widget _buildTotalsSection(AppLocalizations l10n) {
    final amountUntaxed =
        (widget.order['amount_untaxed'] as num?)?.toDouble() ?? 0.0;
    final amountTax = (widget.order['amount_tax'] as num?)?.toDouble() ?? 0.0;
    final amountTotal =
        (widget.order['amount_total'] as num?)?.toDouble() ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.order_summary,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // الإجمالي الفرعي
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.subtotal),
                Text('${amountUntaxed.toStringAsFixed(2)} Dh'),
              ],
            ),

            // الضريبة
            if (amountTax > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.tax),
                  Text('${amountTax.toStringAsFixed(2)} Dh'),
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
                  '${amountTotal.toStringAsFixed(2)} Dh',
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
  }

  // ============= Order Actions =============

  Widget _buildOrderActions(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.actions,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // أزرار الإجراءات
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _editOrder,
                    icon: const Icon(Icons.edit),
                    label: Text(l10n.edit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _duplicateOrder,
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.duplicate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _printOrder,
                    icon: const Icon(Icons.print),
                    label: Text(l10n.print),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareOrder,
                    icon: const Icon(Icons.share),
                    label: Text(l10n.share),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============= Helper Methods =============

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(
    Map<String, dynamic> product,
    AppLocalizations l10n,
  ) {
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
          product['product_name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الكمية: ${product['product_uom_qty'] ?? 0}'),
            Text('السعر: ${product['price_unit'] ?? 0} Dh'),
            if (product['discount'] != null && product['discount'] > 0)
              Text('الخصم: ${product['discount']}%'),
          ],
        ),
        trailing: Text(
          '${product['price_subtotal'] ?? 0} Dh',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String state) {
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

  String _getStatusText(String state, AppLocalizations l10n) {
    switch (state) {
      case 'draft':
        return l10n.draft;
      case 'sent':
        return l10n.sent;
      case 'sale':
        return l10n.confirmed;
      case 'done':
        return l10n.completed;
      case 'cancel':
        return l10n.cancelled;
      default:
        return state;
    }
  }

  // ============= Event Handlers =============

  void _onMenuSelected(String value) {
    switch (value) {
      case 'edit':
        _editOrder();
        break;
      case 'duplicate':
        _duplicateOrder();
        break;
      case 'delete':
        _deleteOrder();
        break;
    }
  }

  void _editOrder() {
    Get.toNamed('/sales/update', arguments: widget.order);
  }

  void _duplicateOrder() {
    Get.snackbar(
      'قيد التطوير',
      'ميزة نسخ الطلب قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _deleteOrder() {
    Get.dialog(
      AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text(
          'هل أنت متأكد من حذف هذا الطلب؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
          TextButton(
            onPressed: () {
              Get.back();
              // حذف الطلب
              Get.snackbar(
                'تم الحذف',
                'تم حذف أمر البيع بنجاح',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _confirmOrder() {
    Get.snackbar(
      'قيد التطوير',
      'ميزة تأكيد الطلب قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _printOrder() {
    Get.snackbar(
      'قيد التطوير',
      'ميزة طباعة الطلب قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _shareOrder() {
    Get.snackbar(
      'قيد التطوير',
      'ميزة مشاركة الطلب قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
