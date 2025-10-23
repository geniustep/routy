import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/sales/sale_order_model.dart';
import '../../l10n/app_localizations.dart';

/// شاشة تفاصيل أمر البيع
class SaleOrderDetailsScreen extends StatelessWidget {
  final SaleOrderModel order;

  const SaleOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          order.orderName.isNotEmpty ? order.orderName : l10n.sale_order,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editOrder(),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareOrder(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الحالة
            _buildStatusCard(theme, l10n),
            const SizedBox(height: 16),

            // معلومات العميل
            _buildCustomerCard(theme, l10n),
            const SizedBox(height: 16),

            // معلومات الطلب
            _buildOrderInfoCard(theme, l10n),
            const SizedBox(height: 16),

            // المبالغ المالية
            _buildFinancialCard(theme, l10n),
            const SizedBox(height: 16),

            // الملاحظات
            if (order.note != null && order.note!.isNotEmpty)
              _buildNotesCard(theme, l10n),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(theme, l10n),
    );
  }

  /// بطاقة الحالة
  Widget _buildStatusCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (order.clientOrderRef != null)
                      Text(
                        'Ref: ${order.clientOrderRef}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                _buildStatusBadge(theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// شارة الحالة
  Widget _buildStatusBadge(ThemeData theme) {
    final statusInfo = _getStatusInfo(order.state ?? 'draft');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusInfo['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusInfo['color'].withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo['icon'], size: 18, color: statusInfo['color']),
          const SizedBox(width: 4),
          Text(
            statusInfo['label'],
            style: TextStyle(
              color: statusInfo['color'],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// معلومات الحالة
  Map<String, dynamic> _getStatusInfo(String state) {
    switch (state) {
      case 'draft':
        return {
          'label': 'مسودة',
          'icon': Icons.edit_note,
          'color': Colors.orange,
        };
      case 'sent':
        return {'label': 'مرسل', 'icon': Icons.send, 'color': Colors.blue};
      case 'sale':
        return {
          'label': 'مؤكد',
          'icon': Icons.check_circle,
          'color': Colors.green,
        };
      case 'done':
        return {'label': 'مكتمل', 'icon': Icons.done_all, 'color': Colors.teal};
      case 'cancel':
        return {'label': 'ملغى', 'icon': Icons.cancel, 'color': Colors.red};
      default:
        return {'label': state, 'icon': Icons.help, 'color': Colors.grey};
    }
  }

  /// بطاقة معلومات العميل
  Widget _buildCustomerCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.customer,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, order.partnerName ?? '-'),
            if (order.salesPersonName != null)
              _buildInfoRow(Icons.support_agent, order.salesPersonName!),
            if (order.teamName != null)
              _buildInfoRow(Icons.groups, order.teamName!),
          ],
        ),
      ),
    );
  }

  /// بطاقة معلومات الطلب
  Widget _buildOrderInfoCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.order_info,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (order.dateOrderFormatted != null)
              _buildInfoRow(Icons.calendar_today, order.dateOrderFormatted!),
            if (order.confirmationDateFormatted != null)
              _buildInfoRow(
                Icons.check_circle_outline,
                order.confirmationDateFormatted!,
              ),
            if (order.expectedDateFormatted != null)
              _buildInfoRow(Icons.schedule, order.expectedDateFormatted!),
            if (order.linesCount > 0)
              _buildInfoRow(Icons.list, '${order.linesCount} عناصر'),
          ],
        ),
      ),
    );
  }

  /// بطاقة المعلومات المالية
  Widget _buildFinancialCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.financial,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildAmountRow(
              'المبلغ قبل الضريبة:',
              order.untaxedAmountFormatted,
              theme,
            ),
            _buildAmountRow('الضريبة:', order.taxAmountFormatted, theme),
            const Divider(),
            _buildAmountRow(
              l10n.total_amount,
              order.totalAmountFormatted,
              theme,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقة الملاحظات
  Widget _buildNotesCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notes,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(order.note!, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  /// صف معلومات
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  /// صف المبلغ
  Widget _buildAmountRow(
    String label,
    String amount,
    ThemeData theme, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : null,
            ),
          ),
          Text(
            amount,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.green : null,
              fontSize: isTotal ? 20 : null,
            ),
          ),
        ],
      ),
    );
  }

  /// شريط الإجراءات السفلي
  Widget _buildBottomBar(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (order.isDraft)
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _confirmOrder(),
                icon: const Icon(Icons.check),
                label: Text(l10n.confirm),
              ),
            ),
          if (order.isDraft) const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _printOrder(),
              icon: const Icon(Icons.print),
              label: Text(l10n.print),
            ),
          ),
        ],
      ),
    );
  }

  /// تعديل الأمر
  void _editOrder() {
    Get.snackbar(
      'قيد التطوير',
      'صفحة تعديل أمر البيع قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// مشاركة الأمر
  void _shareOrder() {
    Get.snackbar(
      'قيد التطوير',
      'مشاركة أمر البيع قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// تأكيد الأمر
  void _confirmOrder() {
    Get.snackbar(
      'قيد التطوير',
      'تأكيد أمر البيع قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// طباعة الأمر
  void _printOrder() {
    Get.snackbar(
      'قيد التطوير',
      'طباعة أمر البيع قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
