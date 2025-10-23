import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:routy/utils/app_logger.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:logger/logger.dart';
import 'services/index.dart';
import 'app/index.dart';
import 'common/api/dio_factory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Logger
  appLogger.initialize(
    level: kDebugMode ? Level.debug : Level.warning,
    enabled: true,
  );

  appLogger.info('🚀 Routy App Starting...');

  // إعدادات خاصة للويب
  if (kIsWeb) {
    appLogger.info('🌐 Running on Web platform');
  }

  // تهيئة الخدمات حسب الطبقات الثلاث

  // Layer 1 & 2: StorageService (SharedPreferences + Hive)
  await StorageService.instance.initialize();
  appLogger.info('✅ StorageService initialized (Layers 1 & 2)');

  // Layer 3: DatabaseService (SQLite) - فقط للمنصات غير الويب
  if (!kIsWeb) {
    appLogger.info('✅ DatabaseService initialized (Layer 3)');
  } else {
    appLogger.warning('⚠️ SQLite not supported on Web - using Hive only');
  }

  // Translation Service
  await TranslationService.instance.initialize();
  appLogger.info('✅ TranslationService initialized');

  // إعدادات CORS للخادم الحقيقي
  DioFactory.setupCORS();
  appLogger.info('✅ CORS settings configured for real server');

  // إخفاء Navigation Bar فقط
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top], // إظهار Status Bar فقط
  );

  // ✅ منع الشاشة من الخمول
  await WakelockPlus.enable();

  runApp(const RoutyApp());
}
