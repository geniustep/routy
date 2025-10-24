// lib/screens/sales/saleorder/drafts/services/draft_sale_service.dart

import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:routy/utils/app_logger.dart';

/// 📝 Draft Sale Service - خدمة مسودات المبيعات
///
/// يدير:
/// - حفظ المسودات محلياً
/// - استعادة المسودات
/// - حذف المسودات
/// - إدارة التخزين المحلي
class DraftSaleService {
  // ============= Singleton =============

  static final DraftSaleService _instance = DraftSaleService._internal();
  factory DraftSaleService.instance() => _instance;
  DraftSaleService._internal();

  // ============= Constants =============

  static const String _draftsKey = 'draft_sales';
  static const String _draftCountKey = 'draft_count';

  // ============= Draft Management =============

  /// إنشاء مسودة جديدة
  Future<String> createDraft(Map<String, dynamic> draftData) async {
    try {
      appLogger.info('\n📝 ========== CREATING DRAFT ==========');
      appLogger.info('Draft data: $draftData');

      final drafts = await getAllDrafts();

      // إنشاء ID فريد
      final draftId = DateTime.now().millisecondsSinceEpoch.toString();

      // إضافة البيانات
      final newDraft = {
        'id': draftId,
        'createdAt': DateTime.now().toIso8601String(),
        'lastModified': DateTime.now().toIso8601String(),
        ...draftData,
      };

      drafts.add(newDraft);

      // حفظ البيانات
      await _saveDrafts(drafts);

      appLogger.info('✅ Draft created successfully');
      appLogger.info('   Draft ID: $draftId');
      appLogger.info('   Customer: ${draftData['customer']}');
      appLogger.info(
        '   Products: ${(draftData['products'] as List?)?.length ?? 0}',
      );
      appLogger.info('=====================================\n');

      return draftId;
    } catch (e) {
      appLogger.error('❌ Error creating draft: $e');
      rethrow;
    }
  }

  /// تحديث مسودة موجودة
  Future<void> updateDraft(
    String draftId,
    Map<String, dynamic> draftData,
  ) async {
    try {
      appLogger.info('\n📝 ========== UPDATING DRAFT ==========');
      appLogger.info('Draft ID: $draftId');
      appLogger.info('Updated data: $draftData');

      final drafts = await getAllDrafts();

      // البحث عن المسودة
      final draftIndex = drafts.indexWhere((draft) => draft['id'] == draftId);

      if (draftIndex == -1) {
        throw Exception('Draft not found: $draftId');
      }

      // تحديث البيانات
      drafts[draftIndex] = {
        ...drafts[draftIndex],
        'lastModified': DateTime.now().toIso8601String(),
        ...draftData,
      };

      // حفظ البيانات
      await _saveDrafts(drafts);

      appLogger.info('✅ Draft updated successfully');
      appLogger.info('   Draft ID: $draftId');
      appLogger.info('   Last modified: ${drafts[draftIndex]['lastModified']}');
      appLogger.info('=====================================\n');
    } catch (e) {
      appLogger.error('❌ Error updating draft: $e');
      rethrow;
    }
  }

  /// حذف مسودة
  Future<void> deleteDraft(String draftId) async {
    try {
      appLogger.info('\n🗑️ ========== DELETING DRAFT ==========');
      appLogger.info('Draft ID: $draftId');

      final drafts = await getAllDrafts();

      // إزالة المسودة
      drafts.removeWhere((draft) => draft['id'] == draftId);

      // حفظ البيانات
      await _saveDrafts(drafts);

      appLogger.info('✅ Draft deleted successfully');
      appLogger.info('   Remaining drafts: ${drafts.length}');
      appLogger.info('=====================================\n');
    } catch (e) {
      appLogger.error('❌ Error deleting draft: $e');
      rethrow;
    }
  }

  /// الحصول على مسودة محددة
  Future<Map<String, dynamic>?> getDraft(String draftId) async {
    try {
      appLogger.info('\n📥 ========== GETTING DRAFT ==========');
      appLogger.info('Draft ID: $draftId');

      final drafts = await getAllDrafts();
      final draft = drafts.firstWhereOrNull((draft) => draft['id'] == draftId);

      if (draft != null) {
        appLogger.info('✅ Draft found');
        appLogger.info('   Customer: ${draft['customer']}');
        appLogger.info(
          '   Products: ${(draft['products'] as List?)?.length ?? 0}',
        );
        appLogger.info('   Last modified: ${draft['lastModified']}');
      } else {
        appLogger.info('ℹ️ Draft not found');
      }

      appLogger.info('=====================================\n');

      return draft;
    } catch (e) {
      appLogger.error('❌ Error getting draft: $e');
      return null;
    }
  }

  /// الحصول على جميع المسودات
  Future<List<Map<String, dynamic>>> getAllDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = prefs.getString(_draftsKey);

      if (draftsJson == null || draftsJson.isEmpty) {
        return [];
      }

      final List<dynamic> draftsList = jsonDecode(draftsJson);
      return draftsList.cast<Map<String, dynamic>>();
    } catch (e) {
      appLogger.error('❌ Error getting all drafts: $e');
      return [];
    }
  }

  // ============= Storage Management =============

  /// حفظ المسودات في التخزين المحلي
  Future<void> _saveDrafts(List<Map<String, dynamic>> drafts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = jsonEncode(drafts);
      await prefs.setString(_draftsKey, draftsJson);

      // تحديث عداد المسودات
      await prefs.setInt(_draftCountKey, drafts.length);

      appLogger.info('💾 Drafts saved to local storage');
      appLogger.info('   Total drafts: ${drafts.length}');
    } catch (e) {
      appLogger.error('❌ Error saving drafts: $e');
      rethrow;
    }
  }

  /// مسح جميع المسودات
  Future<void> clearAllDrafts() async {
    try {
      appLogger.info('\n🗑️ ========== CLEARING ALL DRAFTS ==========');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftsKey);
      await prefs.remove(_draftCountKey);

      appLogger.info('✅ All drafts cleared');
      appLogger.info('=====================================\n');
    } catch (e) {
      appLogger.error('❌ Error clearing all drafts: $e');
      rethrow;
    }
  }

  // ============= Statistics =============

  /// الحصول على عدد المسودات
  Future<int> getDraftCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_draftCountKey) ?? 0;
    } catch (e) {
      appLogger.error('❌ Error getting draft count: $e');
      return 0;
    }
  }

  /// الحصول على إحصائيات المسودات
  Future<Map<String, dynamic>> getDraftStatistics() async {
    try {
      final drafts = await getAllDrafts();

      int totalDrafts = drafts.length;
      int totalProducts = 0;
      double totalValue = 0.0;

      for (var draft in drafts) {
        final products = draft['products'] as List? ?? [];
        totalProducts += products.length;

        // حساب القيمة الإجمالية
        for (var product in products) {
          final quantity = (product['quantity'] as num?)?.toDouble() ?? 0.0;
          final price = (product['price'] as num?)?.toDouble() ?? 0.0;
          totalValue += quantity * price;
        }
      }

      return {
        'totalDrafts': totalDrafts,
        'totalProducts': totalProducts,
        'totalValue': totalValue,
        'averageProductsPerDraft': totalDrafts > 0
            ? totalProducts / totalDrafts
            : 0.0,
        'averageValuePerDraft': totalDrafts > 0
            ? totalValue / totalDrafts
            : 0.0,
      };
    } catch (e) {
      appLogger.error('❌ Error getting draft statistics: $e');
      return {
        'totalDrafts': 0,
        'totalProducts': 0,
        'totalValue': 0.0,
        'averageProductsPerDraft': 0.0,
        'averageValuePerDraft': 0.0,
      };
    }
  }

  // ============= Search and Filter =============

  /// البحث في المسودات
  Future<List<Map<String, dynamic>>> searchDrafts(String query) async {
    try {
      final drafts = await getAllDrafts();

      if (query.isEmpty) return drafts;

      final queryLower = query.toLowerCase();

      return drafts.where((draft) {
        final customer = (draft['customer'] as String?)?.toLowerCase() ?? '';
        final products = draft['products'] as List? ?? [];

        // البحث في اسم العميل
        if (customer.contains(queryLower)) return true;

        // البحث في أسماء المنتجات
        for (var product in products) {
          final productName =
              (product['productName'] as String?)?.toLowerCase() ?? '';
          if (productName.contains(queryLower)) return true;
        }

        return false;
      }).toList();
    } catch (e) {
      appLogger.error('❌ Error searching drafts: $e');
      return [];
    }
  }

  /// فلترة المسودات حسب العميل
  Future<List<Map<String, dynamic>>> getDraftsByCustomer(
    String customerName,
  ) async {
    try {
      final drafts = await getAllDrafts();

      return drafts.where((draft) {
        final customer = (draft['customer'] as String?) ?? '';
        return customer.toLowerCase() == customerName.toLowerCase();
      }).toList();
    } catch (e) {
      appLogger.error('❌ Error filtering drafts by customer: $e');
      return [];
    }
  }
}
