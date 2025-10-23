import 'dart:async';
import 'package:get/get.dart';
import 'package:routy/app/app_router.dart';
import 'package:routy/common/api/api.dart';
import 'package:routy/common/api/dio_factory.dart';
// import 'package:routy/common/api/api_response.dart'; // Not used in this file
import 'package:routy/common/services/api_service.dart';
import 'package:routy/services/storage_service.dart';
import 'package:routy/controllers/user_controller.dart';
import 'package:routy/controllers/partner_controller.dart';
import 'package:routy/utils/app_logger.dart';

/// 🚀 Splash Controller - إدارة تحميل التطبيق
///
/// المسؤوليات:
/// - ✅ تحميل معلومات الإصدار
/// - ✅ تحميل قواعد البيانات
/// - ✅ تحميل الإعدادات
/// - ✅ تحميل الشركاء
/// - ✅ التنقل للشاشة المناسبة
class SplashController extends GetxController {
  // ==================== Dependencies ====================

  final _storageService = StorageService.instance;

  // ==================== Observable State ====================

  /// التقدم العام (0-100)
  final progress = 0.0.obs;

  /// الحالة الحالية
  final currentStatus = 'splash_initializing'.obs;

  /// النموذج الحالي
  final currentModel = ''.obs;

  /// تقدم النموذج (0-100)
  final modelProgress = 0.0.obs;

  /// هل يحمل؟
  final isLoading = true.obs;

  /// هل جاهز؟
  final isReady = false.obs;

  /// رسالة الخطأ
  final Rx<String?> errorMessage = Rx<String?>(null);

  /// عدد المحاولات
  final retryCount = 0.obs;

  // ==================== Constants ====================

  static const int maxRetries = 3;
  static const List<Duration> retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ];

  /// أوزان التقدم لكل مرحلة
  static const Map<String, double> progressWeights = {
    'version_info': 20.0,
    'databases': 20.0,
    'settings': 20.0,
    'partners': 30.0,
    'finalizing': 10.0,
  };

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      appLogger.info('🚀 Starting app initialization...');

      await _runInitializationSequence();

      appLogger.info('✅ App initialization completed');
    } catch (e, stackTrace) {
      appLogger.error(
        '❌ App initialization failed',
        error: e,
        stackTrace: stackTrace,
      );
      await _handleError(e);
    }
  }

  // ==================== Initialization Sequence ====================

  /// تسلسل التهيئة الكامل
  Future<void> _runInitializationSequence() async {
    try {
      // 1. معلومات الإصدار (20%)
      await _loadStep(stepKey: 'version_info', loader: _loadVersionInfo);

      // 3. الإعدادات (60%)
      await _loadStep(stepKey: 'settings', loader: _loadSettings);

      // 4. الشركاء (90%)
      await _loadStep(stepKey: 'partners', loader: _loadPartners);

      // 5. الانتهاء (100%)
      await _loadStep(stepKey: 'finalizing', loader: _finalize);

      // الانتقال
      await _navigateToNextScreen();
    } catch (e) {
      rethrow;
    }
  }

  /// تحميل خطوة واحدة
  Future<void> _loadStep({
    required String stepKey,
    required Future<void> Function() loader,
  }) async {
    try {
      // تحديث الحالة
      _updateStatus('splash_loading_$stepKey');
      _updateModel(stepKey, 0);

      appLogger.info('📦 Loading: $stepKey');

      // تحميل
      await loader();

      // تحديث التقدم
      _updateModel(stepKey, 100);
      _incrementProgress(progressWeights[stepKey] ?? 10);

      appLogger.info('✅ Loaded: $stepKey');
    } catch (e) {
      appLogger.error('❌ Failed to load: $stepKey', error: e);
      rethrow;
    }
  }

  // ==================== Loading Steps ====================

  /// 1. تحميل معلومات الإصدار
  Future<void> _loadVersionInfo() async {
    try {
      // فحص الكاش أولاً
      final cached = _storageService.getCache('version_info');
      if (cached != null) {
        appLogger.info('📦 Cache hit: version_info');
        // تحويل آمن للبيانات
        final version = (cached as Map)['server_version']?.toString() ?? '';
        appLogger.info('🔢 Server Version (from cache): $version');
        return;
      }

      final completer = Completer<void>();

      Api.getVersionInfo(
        onResponse: (response) async {
          if (response.serverVersion != null) {
            final version = response.serverVersion ?? '';
            appLogger.info('🔢 Server Version: $version');

            final result = response.toJson();
            await _storageService.setCache('version_info', result);

            completer.complete();
          }
        },
        onError: (error, data) {
          completer.completeError(Exception(error));
        },
      );

      await completer.future;
    } catch (e) {
      appLogger.error('❌ Error loading version info', error: e);
      rethrow;
    }
  }

  /// 3. تحميل الإعدادات
  Future<void> _loadSettings() async {
    try {
      // تحميل الجلسة في ApiService
      await ApiService.instance.loadSession();

      // تحميل الـ cookies في Dio
      final token = _storageService.getString('user_token');
      if (token != null && token.isNotEmpty) {
        DioFactory.initialiseHeaders(token);
        appLogger.info('✅ Cookies loaded in Dio');
      }

      // تحميل حالة تسجيل الدخول
      final isLoggedIn = _storageService.getIsLoggedIn();
      final user = _storageService.getUser();

      if (isLoggedIn && user != null) {
        appLogger.info('👤 User logged in: ${user['name']}');

        // تهيئة UserController
      } else {
        appLogger.info('🔓 No user logged in');
      }
    } catch (e) {
      appLogger.error('❌ Error loading settings', error: e);
      // لا نرمي خطأ هنا - الإعدادات اختيارية
    }
  }

  /// 4. تحميل الشركاء (الجديد! 🎉)
  Future<void> _loadPartners() async {
    try {
      // التحقق من تسجيل الدخول
      final isLoggedIn = ApiService.instance.isAuthenticated;
      if (!isLoggedIn) {
        appLogger.info('⏭️ Skipping partners - user not logged in');
        return;
      }

      // تهيئة PartnerController - سيقوم onInit بتحميل البيانات تلقائياً
      if (!Get.isRegistered<PartnerController>()) {
        Get.put(PartnerController());
        appLogger.info('✅ PartnerController initialized');
      } else {
        appLogger.info('✅ PartnerController already registered');
      }
    } catch (e) {
      appLogger.error('❌ Error initializing PartnerController', error: e);
      // لا نرمي خطأ - الشركاء ليسوا ضروريين للـ splash
      appLogger.warning('⚠️ Continuing without partners');
    }
  }

  /// 5. الانتهاء
  Future<void> _finalize() async {
    try {
      // انتظار قصير للأنيميشن
      await Future.delayed(const Duration(milliseconds: 300));

      // وضع علامة الجاهزية
      isReady.value = true;
      isLoading.value = false;

      appLogger.info('🎉 App is ready!');
    } catch (e) {
      appLogger.error('❌ Error finalizing', error: e);
      rethrow;
    }
  }

  // ==================== Navigation ====================

  /// الانتقال للشاشة التالية
  Future<void> _navigateToNextScreen() async {
    try {
      // انتظار قصير لإكمال الأنيميشن
      await Future.delayed(const Duration(milliseconds: 500));

      final userController = Get.find<UserController>();

      // تحديد الشاشة المناسبة
      String route;
      if (userController.isLoggedIn && userController.user != null) {
        route = AppRouter.dashboardV2;
        appLogger.navigation(route, from: AppRouter.splash);
      } else {
        route = AppRouter.login;
        appLogger.navigation(route, from: AppRouter.splash);
      }

      // الانتقال
      Get.offAllNamed(route);
    } catch (e) {
      appLogger.error('❌ Navigation error', error: e);
      // في حالة الخطأ، نذهب للـ login
      Get.offAllNamed(AppRouter.login);
    }
  }

  // ==================== Progress Updates ====================

  /// تحديث الحالة
  void _updateStatus(String status) {
    currentStatus.value = status;
  }

  /// تحديث النموذج الحالي
  void _updateModel(String model, double progress) {
    currentModel.value = model;
    modelProgress.value = progress.clamp(0, 100);
  }

  /// زيادة التقدم
  void _incrementProgress(double amount) {
    progress.value = (progress.value + amount).clamp(0, 100);
  }

  // ==================== Error Handling ====================

  /// معالجة الخطأ
  Future<void> _handleError(dynamic error) async {
    errorMessage.value = _getErrorMessage(error);

    // محاولة إعادة التحميل
    if (retryCount.value < maxRetries) {
      await _retry();
    } else {
      // فشلت جميع المحاولات
      appLogger.error('❌ Max retries reached');
      _showErrorState();
    }
  }

  /// إعادة المحاولة
  Future<void> _retry() async {
    try {
      retryCount.value++;
      appLogger.info('🔄 Retry attempt ${retryCount.value}/$maxRetries');

      // انتظار قبل إعادة المحاولة
      final delay = retryDelays[retryCount.value - 1];
      await Future.delayed(delay);

      // إعادة تعيين التقدم
      progress.value = 0;
      modelProgress.value = 0;
      errorMessage.value = null;

      // إعادة المحاولة
      await _runInitializationSequence();
    } catch (e) {
      await _handleError(e);
    }
  }

  /// عرض حالة الخطأ
  void _showErrorState() {
    isLoading.value = false;
    currentStatus.value = 'splash_error';
  }

  /// الحصول على رسالة الخطأ
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'splash_error_network'.tr;
    } else if (error.toString().contains('TimeoutException')) {
      return 'splash_error_timeout'.tr;
    } else if (error.toString().contains('FormatException')) {
      return 'splash_error_data'.tr;
    } else {
      return 'splash_error_unknown'.tr;
    }
  }

  // ==================== Public Methods ====================

  /// إعادة المحاولة يدوياً
  Future<void> retryManually() async {
    retryCount.value = 0;
    errorMessage.value = null;
    isLoading.value = true;
    progress.value = 0;

    await _initialize();
  }

  /// تخطي والذهاب للـ Login
  void skipToLogin() {
    appLogger.warning('⏭️ User skipped to login');
    Get.offAllNamed(AppRouter.login);
  }

  // ==================== Cleanup ====================

  @override
  void onClose() {
    appLogger.info('🔴 Closing SplashController');
    super.onClose();
  }
}
