// lib/screens/sales/saleorder/drafts/draft_sales_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routy/screens/sales/saleorder/drafts/services/draft_sale_service.dart';
import 'package:routy/l10n/app_localizations.dart';
import 'package:routy/utils/app_logger.dart';

/// 📝 Draft Sales Screen - شاشة مسودات المبيعات
///
/// تدعم:
/// - عرض المسودات
/// - البحث في المسودات
/// - حذف المسودات
/// - استعادة المسودات
class DraftSalesScreen extends StatefulWidget {
  const DraftSalesScreen({super.key});

  @override
  State<DraftSalesScreen> createState() => _DraftSalesScreenState();
}

class _DraftSalesScreenState extends State<DraftSalesScreen> {
  // ============= Services =============

  final DraftSaleService _draftService = DraftSaleService.instance();

  // ============= State =============

  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  List<Map<String, dynamic>> _drafts = [];
  List<Map<String, dynamic>> _filteredDrafts = [];

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
        '\n📝 ========== INITIALIZING DRAFT SALES SCREEN ==========',
      );

      // تحميل المسودات
      await _loadDrafts();

      appLogger.info('✅ Draft sales screen initialized successfully');
      appLogger.info('   Total drafts: ${_drafts.length}');
      appLogger.info('=====================================================\n');
    } catch (e) {
      appLogger.error('❌ Error initializing draft sales screen: $e');
      setState(() {
        _errorMessage = 'خطأ في تهيئة الشاشة: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDrafts() async {
    try {
      final drafts = await _draftService.getAllDrafts();
      setState(() {
        _drafts = drafts;
        _filteredDrafts = drafts;
      });

      appLogger.info('✅ Drafts loaded: ${drafts.length}');
    } catch (e) {
      appLogger.error('❌ Error loading drafts: $e');
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
          title: Text(l10n.draft_sales),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.draft_sales),
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
          // شريط البحث
          _buildSearchBar(l10n),

          // قائمة المسودات
          Expanded(child: _buildDraftsList(l10n)),
        ],
      ),
    );
  }

  // ============= App Bar =============

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.draft_sales),
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: _clearAllDrafts,
          icon: const Icon(Icons.delete_sweep),
          tooltip: l10n.clear_all,
        ),
        IconButton(
          onPressed: _refreshDrafts,
          icon: const Icon(Icons.refresh),
          tooltip: l10n.refresh,
        ),
      ],
    );
  }

  // ============= Search Bar =============

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: l10n.search_drafts,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                    _filterDrafts();
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _filterDrafts();
        },
      ),
    );
  }

  // ============= Drafts List =============

  Widget _buildDraftsList(AppLocalizations l10n) {
    if (_filteredDrafts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.drafts_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? l10n.no_drafts_found : l10n.no_drafts,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createNewOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.create_new_order),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredDrafts.length,
      itemBuilder: (context, index) {
        final draft = _filteredDrafts[index];
        return _buildDraftItem(draft, l10n);
      },
    );
  }

  // ============= Draft Item =============

  Widget _buildDraftItem(Map<String, dynamic> draft, AppLocalizations l10n) {
    final customer = draft['customer'] ?? '';
    final products = draft['products'] as List<dynamic>? ?? [];
    final lastModified = draft['lastModified'] ?? '';
    final totalValue = _calculateDraftTotal(products);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.drafts, color: Colors.orange),
        ),
        title: Text(
          customer,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المنتجات: ${products.length}'),
            Text('الإجمالي: ${totalValue.toStringAsFixed(2)} Dh'),
            Text('آخر تعديل: ${_formatDate(lastModified)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _onDraftAction(value, draft),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'continue',
              child: Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: 8),
                  Text(l10n.continue_editing),
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
        onTap: () => _continueEditing(draft),
      ),
    );
  }

  // ============= Helper Methods =============

  void _filterDrafts() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredDrafts = _drafts;
      });
      return;
    }

    final query = _searchQuery.toLowerCase();
    final filtered = _drafts.where((draft) {
      final customer = (draft['customer'] as String?)?.toLowerCase() ?? '';
      final products = draft['products'] as List<dynamic>? ?? [];

      // البحث في اسم العميل
      if (customer.contains(query)) return true;

      // البحث في أسماء المنتجات
      for (var product in products) {
        final productName =
            (product['productName'] as String?)?.toLowerCase() ?? '';
        if (productName.contains(query)) return true;
      }

      return false;
    }).toList();

    setState(() {
      _filteredDrafts = filtered;
    });
  }

  double _calculateDraftTotal(List<dynamic> products) {
    double total = 0.0;

    for (var product in products) {
      final quantity = (product['quantity'] as num?)?.toDouble() ?? 0.0;
      final price = (product['price'] as num?)?.toDouble() ?? 0.0;
      total += quantity * price;
    }

    return total;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'الآن';
      } else if (difference.inMinutes < 60) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else if (difference.inHours < 24) {
        return 'منذ ${difference.inHours} ساعة';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  // ============= Event Handlers =============

  void _onDraftAction(String action, Map<String, dynamic> draft) {
    switch (action) {
      case 'continue':
        _continueEditing(draft);
        break;
      case 'delete':
        _deleteDraft(draft);
        break;
    }
  }

  void _continueEditing(Map<String, dynamic> draft) {
    // الانتقال لشاشة إنشاء طلب جديد مع تحميل المسودة
    Get.toNamed('/sales/create/new', arguments: draft);
  }

  void _deleteDraft(Map<String, dynamic> draft) {
    Get.dialog(
      AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text(
          'هل أنت متأكد من حذف هذه المسودة؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Get.back();
              await _performDeleteDraft(draft);
            },
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteDraft(Map<String, dynamic> draft) async {
    try {
      final draftId = draft['id'] as String;
      await _draftService.deleteDraft(draftId);

      setState(() {
        _drafts.removeWhere((d) => d['id'] == draftId);
        _filteredDrafts.removeWhere((d) => d['id'] == draftId);
      });

      Get.snackbar(
        'تم الحذف',
        'تم حذف المسودة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
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

  void _clearAllDrafts() {
    Get.dialog(
      AlertDialog(
        title: Text('تأكيد مسح الكل'),
        content: Text(
          'هل أنت متأكد من حذف جميع المسودات؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Get.back();
              await _performClearAllDrafts();
            },
            child: Text('مسح الكل'),
          ),
        ],
      ),
    );
  }

  Future<void> _performClearAllDrafts() async {
    try {
      await _draftService.clearAllDrafts();

      setState(() {
        _drafts.clear();
        _filteredDrafts.clear();
      });

      Get.snackbar(
        'تم المسح',
        'تم مسح جميع المسودات بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      appLogger.error('❌ Error clearing all drafts: $e');
      Get.snackbar(
        'خطأ في المسح',
        'فشل في مسح المسودات: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _refreshDrafts() {
    _initializeScreen();
  }

  void _createNewOrder() {
    Get.toNamed('/sales/create/new');
  }
}
