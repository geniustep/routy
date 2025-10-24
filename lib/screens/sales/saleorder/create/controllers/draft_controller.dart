// lib/screens/sales/saleorder/create/controllers/draft_controller.dart

import 'package:get/get.dart';
import 'package:routy/screens/sales/saleorder/drafts/services/draft_sale_service.dart';
import 'package:routy/utils/app_logger.dart';

/// 📝 Draft Controller - تحكم في المسودات
///
/// يدير:
/// - حفظ المسودات تلقائياً
/// - استعادة المسودات
/// - إدارة حالة الحفظ
/// - تتبع التغييرات
class DraftController extends GetxController {
  // ============= State =============

  final RxString currentDraftId = ''.obs;
  final Rx<DateTime?> lastSavedAt = Rx<DateTime?>(null);
  final RxString lastSavedText = ''.obs;
  final RxBool isAutoSaving = false.obs;
  final RxBool hasUnsavedChanges = false.obs;

  // ============= Services =============
  final DraftSaleService _draftService = DraftSaleService.instance();

  // ============= Lifecycle =============

  @override
  void onInit() {
    super.onInit();
    appLogger.info('✅ DraftController initialized');
  }

  @override
  void onClose() {
    appLogger.info('🗑️ DraftController disposed');
    super.onClose();
  }

  // ============= Draft Management =============

  /// التحقق من وجود مسودة وتحميلها
  Future<bool> checkAndLoadDraft({
    required String customerName,
    required int? partnerId,
    required int? priceListId,
  }) async {
    try {
      appLogger.info('\n🔍 ========== CHECKING FOR DRAFT ==========');
      appLogger.info('Customer: $customerName');
      appLogger.info('Partner ID: $partnerId');
      appLogger.info('Price List ID: $priceListId');

      final drafts = await _draftService.getAllDrafts();

      // البحث عن مسودة مطابقة
      final matchingDraft = drafts.firstWhereOrNull((draft) {
        final draftCustomer = draft['customer']?.toString() ?? '';
        final draftPartnerId = draft['partnerId'];
        final draftPriceListId = draft['priceListId'];

        return draftCustomer.toLowerCase() == customerName.toLowerCase() &&
            draftPartnerId == partnerId &&
            draftPriceListId == priceListId;
      });

      if (matchingDraft != null) {
        appLogger.info('✅ Found matching draft: ${matchingDraft['id']}');
        appLogger.info('   Last modified: ${matchingDraft['lastModified']}');

        currentDraftId.value = matchingDraft['id']?.toString() ?? '';

        if (matchingDraft['lastModified'] != null) {
          lastSavedAt.value = DateTime.parse(matchingDraft['lastModified']);
          lastSavedText.value =
              'آخر حفظ: ${_formatLastSaved(lastSavedAt.value!)}';
        }

        return true;
      } else {
        appLogger.info('ℹ️ No matching draft found');
        return false;
      }
    } catch (e) {
      appLogger.error('❌ Error checking for draft: $e');
      return false;
    }
  }

  /// حفظ المسودة تلقائياً
  Future<void> autoSaveDraft({
    required String customerName,
    required int? partnerId,
    required int? priceListId,
    List<Map<String, dynamic>>? products,
  }) async {
    if (isAutoSaving.value) {
      appLogger.info('⏳ Auto-save already in progress, skipping...');
      return;
    }

    try {
      isAutoSaving.value = true;

      appLogger.info('\n💾 ========== AUTO-SAVING DRAFT ==========');
      appLogger.info('Customer: $customerName');
      appLogger.info('Partner ID: $partnerId');
      appLogger.info('Price List ID: $priceListId');
      appLogger.info('Products: ${products?.length ?? 0}');

      final draftData = {
        'customer': customerName,
        'partnerId': partnerId,
        'priceListId': priceListId,
        'products': products ?? [],
        'lastModified': DateTime.now().toIso8601String(),
      };

      String draftId;
      if (currentDraftId.value.isNotEmpty) {
        // تحديث مسودة موجودة
        draftId = currentDraftId.value;
        await _draftService.updateDraft(draftId, draftData);
        appLogger.info('✅ Draft updated: $draftId');
      } else {
        // إنشاء مسودة جديدة
        draftId = await _draftService.createDraft(draftData);
        currentDraftId.value = draftId;
        appLogger.info('✅ New draft created: $draftId');
      }

      lastSavedAt.value = DateTime.now();
      lastSavedText.value = 'آخر حفظ: ${_formatLastSaved(lastSavedAt.value!)}';
      hasUnsavedChanges.value = false;

      appLogger.info('✅ Auto-save completed successfully');
      appLogger.info('=========================================\n');
    } catch (e) {
      appLogger.error('❌ Error auto-saving draft: $e');
      appLogger.error('   Stack trace: ${StackTrace.current}');
    } finally {
      isAutoSaving.value = false;
    }
  }

  /// حذف المسودة الحالية
  Future<void> deleteCurrentDraft() async {
    if (currentDraftId.value.isEmpty) {
      appLogger.info('ℹ️ No draft to delete');
      return;
    }

    try {
      appLogger.info('\n🗑️ ========== DELETING DRAFT ==========');
      appLogger.info('Draft ID: ${currentDraftId.value}');

      await _draftService.deleteDraft(currentDraftId.value);

      currentDraftId.value = '';
      lastSavedAt.value = null;
      lastSavedText.value = '';
      hasUnsavedChanges.value = false;

      appLogger.info('✅ Draft deleted successfully');
      appLogger.info('=====================================\n');
    } catch (e) {
      appLogger.error('❌ Error deleting draft: $e');
    }
  }

  /// تحميل مسودة محددة
  Future<Map<String, dynamic>?> loadDraft(String draftId) async {
    try {
      appLogger.info('\n📥 ========== LOADING DRAFT ==========');
      appLogger.info('Draft ID: $draftId');

      final draft = await _draftService.getDraft(draftId);

      if (draft != null) {
        currentDraftId.value = draftId;

        if (draft['lastModified'] != null) {
          lastSavedAt.value = DateTime.parse(draft['lastModified']);
          lastSavedText.value =
              'آخر حفظ: ${_formatLastSaved(lastSavedAt.value!)}';
        }

        appLogger.info('✅ Draft loaded successfully');
        appLogger.info('   Customer: ${draft['customer']}');
        appLogger.info(
          '   Products: ${(draft['products'] as List?)?.length ?? 0}',
        );
        appLogger.info('   Last modified: ${draft['lastModified']}');

        return draft;
      } else {
        appLogger.warning('⚠️ Draft not found: $draftId');
        return null;
      }
    } catch (e) {
      appLogger.error('❌ Error loading draft: $e');
      return null;
    }
  }

  // ============= Helper Methods =============

  /// تنسيق وقت آخر حفظ
  String _formatLastSaved(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  // ============= Getters =============

  bool get hasDraft => currentDraftId.value.isNotEmpty;
  bool get isDraftSaved => lastSavedAt.value != null;
  String get draftId => currentDraftId.value;
  DateTime? get lastSaved => lastSavedAt.value;
  String get lastSavedFormatted => lastSavedText.value;

  // ============= Clear Data =============

  void clearDraft() {
    currentDraftId.value = '';
    lastSavedAt.value = null;
    lastSavedText.value = '';
    hasUnsavedChanges.value = false;

    appLogger.info('🗑️ Draft data cleared');
  }

  void markAsChanged() {
    hasUnsavedChanges.value = true;
  }

  void markAsSaved() {
    hasUnsavedChanges.value = false;
  }
}
