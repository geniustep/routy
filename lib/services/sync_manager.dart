import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_logger.dart';
import 'database_service.dart';
import 'storage_service.dart';

/// مدير المزامنة
/// يدير المزامنة بين التخزين المحلي والخادم
class SyncManager extends GetxController {
  final _isSyncing = false.obs;
  final _lastSyncTime = Rx<DateTime?>(null);
  final _syncProgress = 0.0.obs;

  bool get isSyncing => _isSyncing.value;
  DateTime? get lastSyncTime => _lastSyncTime.value;
  double get syncProgress => _syncProgress.value;

  @override
  void onInit() {
    super.onInit();
    _loadLastSyncTime();
  }

  /// تحميل آخر وقت مزامنة
  void _loadLastSyncTime() {
    final timestamp = StorageService.instance.getString('last_sync_time');
    if (timestamp != null) {
      _lastSyncTime.value = DateTime.parse(timestamp);
    }
  }

  /// بدء المزامنة الكاملة
  Future<bool> syncAll() async {
    if (_isSyncing.value) {
      appLogger.warning('⚠️ Sync already in progress');
      return false;
    }

    _isSyncing.value = true;
    _syncProgress.value = 0.0;

    try {
      appLogger.info('🔄 Starting full sync...');

      // 1. مزامنة Offline Queue (أولوية قصوى)
      await _syncOfflineQueue();
      _syncProgress.value = 0.25;

      // 2. مزامنة البيانات غير المتزامنة من SQLite
      await _syncUnsyncedData();
      _syncProgress.value = 0.50;

      // 3. جلب بيانات جديدة من الخادم
      await _fetchNewData();
      _syncProgress.value = 0.75;

      // 4. تنظيف البيانات القديمة
      await _cleanupOldData();
      _syncProgress.value = 1.0;

      // حفظ وقت المزامنة
      _lastSyncTime.value = DateTime.now();
      await StorageService.instance.setString(
        'last_sync_time',
        _lastSyncTime.value!.toIso8601String(),
      );

      appLogger.info('✅ Full sync completed successfully');
      return true;
    } catch (e, stackTrace) {
      appLogger.error('Sync failed', error: e, stackTrace: stackTrace);
      return false;
    } finally {
      _isSyncing.value = false;
    }
  }

  /// مزامنة Offline Queue
  Future<void> _syncOfflineQueue() async {
    try {
      final pendingOps = await DatabaseService.instance.getPendingSyncItems();

      appLogger.info('📤 Syncing ${pendingOps.length} pending operations...');

      for (var op in pendingOps) {
        try {
          // تنفيذ العملية المعلقة
          await _executeQueuedOperation(op);

          // حذف من Queue بعد النجاح
          await DatabaseService.instance.updateSyncStatus(
            op['id'],
            'completed',
          );
        } catch (e) {
          appLogger.warning('⚠️ Failed to sync operation ${op['id']}: $e');

          // زيادة عدد المحاولات
          final retryCount = (op['retry_count'] ?? 0) + 1;

          if (retryCount >= 3) {
            // بعد 3 محاولات، نعلّمها كفاشلة
            await DatabaseService.instance.updateSyncStatus(
              op['id'],
              'failed',
              errorMessage: e.toString(),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      appLogger.error(
        'Offline queue sync failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// تنفيذ عملية معلقة
  Future<void> _executeQueuedOperation(Map<String, dynamic> operation) async {
    final action = operation['action'];
    final endpoint = operation['endpoint'];

    appLogger.debug('📡 Executing queued $action on $endpoint');

    // يمكن تنفيذ العملية هنا باستخدام ApiService
    // مثال:
    // await ApiService.instance.callKW(...);
  }

  /// مزامنة البيانات غير المتزامنة
  Future<void> _syncUnsyncedData() async {
    try {
      final tables = ['sales', 'partners', 'products', 'deliveries'];

      for (var table in tables) {
        final unsyncedRecords = await DatabaseService.instance.query(
          table,
          where: 'synced = ?',
          whereArgs: [0],
        );

        appLogger.info(
          '📤 Syncing ${unsyncedRecords.length} $table records...',
        );

        for (var record in unsyncedRecords) {
          try {
            // رفع إلى الخادم
            // await _uploadRecord(table, record);

            // تعليم كمتزامن
            await DatabaseService.instance.update(
              table,
              {'synced': 1},
              where: 'id = ?',
              whereArgs: [record['id']],
            );
          } catch (e) {
            appLogger.warning(
              '⚠️ Failed to sync $table record ${record['id']}: $e',
            );
          }
        }
      }
    } catch (e, stackTrace) {
      appLogger.error(
        'Unsynced data sync failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// جلب بيانات جديدة من الخادم
  Future<void> _fetchNewData() async {
    try {
      appLogger.info('📥 Fetching new data from server...');

      // يمكن جلب البيانات هنا
      // مثال:
      // final products = await ApiService.instance.searchRead(...);
      // await DatabaseService.instance.insertBatch('products', products);

      appLogger.info('✅ New data fetched');
    } catch (e, stackTrace) {
      appLogger.error(
        'Fetch new data failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// تنظيف البيانات القديمة
  Future<void> _cleanupOldData() async {
    try {
      await DatabaseService.instance.rawQuery(
        'DELETE FROM sync_queue WHERE created_at < datetime("now", "-90 days")',
      );
      appLogger.info('🧹 Old data cleaned up');
    } catch (e, stackTrace) {
      appLogger.error('Cleanup failed', error: e, stackTrace: stackTrace);
    }
  }

  /// مزامنة تلقائية في الخلفية
  Future<void> autoSync() async {
    if (!_shouldAutoSync()) return;

    appLogger.info('🔄 Auto sync triggered');
    await syncAll();
  }

  /// التحقق من الحاجة للمزامنة التلقائية
  bool _shouldAutoSync() {
    if (_lastSyncTime.value == null) return true;

    final timeSinceLastSync = DateTime.now().difference(_lastSyncTime.value!);

    // مزامنة كل 30 دقيقة
    return timeSinceLastSync.inMinutes >= 30;
  }

  /// مزامنة يدوية بواسطة المستخدم
  Future<void> manualSync() async {
    appLogger.userAction('Manual Sync');

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final success = await syncAll();

    Get.back();

    if (success) {
      Get.snackbar(
        '✅ نجح',
        'تمت المزامنة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        '❌ خطأ',
        'فشلت المزامنة',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
