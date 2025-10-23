import 'package:flutter/material.dart';

/// ⚙️ Splash Screen Configuration
///
/// جميع الثوابت والإعدادات للـ Splash Screen
class SplashConfig {
  SplashConfig._();

  // ==================== Timing ====================

  /// مدة الأنيميشنز
  static const Duration logoAnimationDuration = Duration(seconds: 3);
  static const Duration progressAnimationDuration = Duration(milliseconds: 500);
  static const Duration particlesAnimationDuration = Duration(seconds: 20);

  /// مدة الانتظار
  static const Duration finalizingDelay = Duration(milliseconds: 300);
  static const Duration navigationDelay = Duration(milliseconds: 500);

  // ==================== Retry ====================

  /// إعدادات إعادة المحاولة
  static const int maxRetries = 3;
  static const List<Duration> retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ];

  // ==================== Progress ====================

  /// أوزان التقدم لكل مرحلة (المجموع = 100)
  static const Map<String, double> progressWeights = {
    'version_info': 20.0, // معلومات الإصدار
    'databases': 20.0, // قواعد البيانات
    'settings': 20.0, // الإعدادات
    'partners': 30.0, // الشركاء (الأهم!)
    'finalizing': 10.0, // الانتهاء
  };

  // ==================== Animation Values ====================

  /// قيم أنيميشن الشعار
  static const double logoScaleMin = 0.8;
  static const double logoScaleMax = 1.1;
  static const double logoRotationMin = -0.1;
  static const double logoRotationMax = 0.1;

  // ==================== UI Dimensions ====================

  /// أبعاد واجهة المستخدم
  static const double logoSize = 150.0;
  static const double progressBarHeight = 4.0;
  static const double progressBarRadius = 2.0;
  static const double contentPadding = 24.0;
  static const double statusTextSize = 16.0;
  static const double modelTextSize = 14.0;
  static const double progressTextSize = 12.0;

  // ==================== Colors ====================

  /// الألوان (يمكن تخصيصها من Theme)
  static const Color backgroundColor = Color(0xFF0A0E21);
  static const Color progressColor = Color(0xFF00BCD4);
  static const Color progressBackgroundColor = Color(0xFF1D1E33);
  static const Color textColor = Colors.white;
  static const Color textSecondaryColor = Colors.white70;

  // ==================== Particles ====================

  /// إعدادات الجزيئات
  static const int particlesCount = 50;
  static const double particleMinSize = 1.0;
  static const double particleMaxSize = 3.0;

  // ==================== Error Messages Keys ====================

  /// مفاتيح رسائل الأخطاء (للترجمة)
  static const String errorNetwork = 'splash_error_network';
  static const String errorTimeout = 'splash_error_timeout';
  static const String errorData = 'splash_error_data';
  static const String errorUnknown = 'splash_error_unknown';

  // ==================== Status Keys ====================

  /// مفاتيح الحالات (للترجمة)
  static const String statusInitializing = 'splash_initializing';
  static const String statusLoadingVersionInfo = 'splash_loading_version_info';
  static const String statusLoadingDatabases = 'splash_loading_databases';
  static const String statusLoadingSettings = 'splash_loading_settings';
  static const String statusLoadingPartners = 'splash_loading_partners';
  static const String statusFinalizing = 'splash_loading_finalizing';
  static const String statusError = 'splash_error';

  // ==================== Curves ====================

  /// منحنيات الأنيميشن
  static const Curve logoScaleCurve = Curves.elasticOut;
  static const Curve logoRotationCurve = Curves.easeInOut;
  static const Curve logoOpacityCurve = Curves.easeIn;
  static const Curve progressCurve = Curves.easeInOut;
}
