import 'package:flutter/material.dart';
import 'package:routy/config/core/design_tokens.dart';
import 'package:routy/config/device/device_adaptation.dart';
import 'package:routy/config/core/app_config.dart';

/// نظام الألوان المتجاوب
class ResponsiveColors {
  /// الحصول على اللون المناسب
  static Color getColor(BuildContext context, ColorType type) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    final deviceType = DeviceAdaptation.detectDeviceType(context);
    final screenSize = DeviceAdaptation.detectScreenSize(context);

    // اللون الأساسي
    Color baseColor = DesignTokens.getColor(type, isDark: isDark);

    // تعديل اللون حسب نوع الجهاز
    switch (deviceType) {
      case DeviceType.phone:
        // تقليل التشبع قليلاً للهواتف
        baseColor = _adjustSaturation(baseColor, 0.9);
        break;
      case DeviceType.tablet:
        // اللون العادي للتابلت
        break;
      case DeviceType.desktop:
        // زيادة التشبع قليلاً لسطح المكتب
        baseColor = _adjustSaturation(baseColor, 1.1);
        break;
      case DeviceType.watch:
        // تقليل التشبع للساعات
        baseColor = _adjustSaturation(baseColor, 0.8);
        break;
    }

    // تعديل اللون حسب حجم الشاشة
    switch (screenSize) {
      case ScreenSize.small:
        // تقليل التشبع للشاشات الصغيرة
        baseColor = _adjustSaturation(baseColor, 0.9);
        break;
      case ScreenSize.medium:
        // اللون العادي للشاشات المتوسطة
        break;
      case ScreenSize.large:
        // زيادة التشبع للشاشات الكبيرة
        baseColor = _adjustSaturation(baseColor, 1.1);
        break;
      case ScreenSize.xlarge:
        // زيادة التشبع للشاشات الكبيرة جداً
        baseColor = _adjustSaturation(baseColor, 1.2);
        break;
    }

    return baseColor;
  }

  /// تعديل تشبع اللون
  static Color _adjustSaturation(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final adjustedHsl = hsl.withSaturation(
      (hsl.saturation * factor).clamp(0.0, 1.0),
    );
    return adjustedHsl.toColor();
  }

  /// الحصول على اللون الأساسي
  static Color getPrimaryColor(BuildContext context) {
    return getColor(context, ColorType.primary);
  }

  /// الحصول على اللون الثانوي
  static Color getSecondaryColor(BuildContext context) {
    return getColor(context, ColorType.secondary);
  }

  /// الحصول على لون الخلفية
  static Color getBackgroundColor(BuildContext context) {
    return getColor(context, ColorType.background);
  }

  /// الحصول على لون السطح
  static Color getSurfaceColor(BuildContext context) {
    return getColor(context, ColorType.surface);
  }

  /// الحصول على لون النص
  static Color getTextColor(BuildContext context) {
    return getColor(context, ColorType.text);
  }

  /// الحصول على لون التمييز
  static Color getAccentColor(BuildContext context) {
    return getColor(context, ColorType.accent);
  }

  /// الحصول على لون النص الأساسي
  static Color getPrimaryTextColor(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    return isDark ? Colors.white : Colors.black87;
  }

  /// الحصول على لون النص الثانوي
  static Color getSecondaryTextColor(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    return isDark ? Colors.white70 : Colors.black54;
  }

  /// الحصول على لون النص المعطل
  static Color getDisabledTextColor(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    return isDark ? Colors.white38 : Colors.black38;
  }

  /// الحصول على لون الحدود
  static Color getBorderColor(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    return isDark ? Colors.white24 : Colors.black12;
  }

  /// الحصول على لون الحدود المحدد
  static Color getFocusedBorderColor(BuildContext context) {
    return getPrimaryColor(context);
  }

  /// الحصول على لون الحدود الخطأ
  static Color getErrorBorderColor(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    return isDark ? Colors.red[300]! : Colors.red[700]!;
  }

  /// الحصول على لون الحدود النجاح
  static Color getSuccessBorderColor(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    return isDark ? Colors.green[300]! : Colors.green[700]!;
  }

  /// الحصول على لون الحدود التحذير
  static Color getWarningBorderColor(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    return isDark ? Colors.orange[300]! : Colors.orange[700]!;
  }

  /// الحصول على لون الحدود المعلومات
  static Color getInfoBorderColor(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    return isDark ? Colors.blue[300]! : Colors.blue[700]!;
  }

  /// الحصول على لون الظل
  static Color getShadowColor(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    return isDark ? Colors.black54 : Colors.black12;
  }

  /// الحصول على لون الظل المرفوع
  static Color getElevatedShadowColor(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    return isDark ? Colors.black87 : Colors.black26;
  }

  /// الحصول على لون التدرج
  static LinearGradient getGradient(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    final primaryColor = getPrimaryColor(context);
    final secondaryColor = getSecondaryColor(context);

    // تعديل التدرج حسب الوضع الداكن
    final begin = isDark ? Alignment.topRight : Alignment.topLeft;
    final end = isDark ? Alignment.bottomLeft : Alignment.bottomRight;

    return LinearGradient(
      colors: [primaryColor, secondaryColor],
      begin: begin,
      end: end,
    );
  }

  /// الحصول على التدرج الدائري
  static RadialGradient getRadialGradient(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    final primaryColor = getPrimaryColor(context);
    final secondaryColor = getSecondaryColor(context);

    // تعديل التدرج الدائري حسب الوضع الداكن
    final center = isDark ? Alignment.topRight : Alignment.center;
    final radius = isDark ? 1.2 : 1.0;

    return RadialGradient(
      colors: [primaryColor, secondaryColor],
      center: center,
      radius: radius,
    );
  }

  /// الحصول على لون البطاقة
  static Color getCardColor(BuildContext context) {
    return getSurfaceColor(context);
  }

  /// الحصول على لون البطاقة المرفوعة
  static Color getElevatedCardColor(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    return isDark ? Colors.grey[800]! : Colors.white;
  }

  /// الحصول على لون الزر الأساسي
  static Color getPrimaryButtonColor(BuildContext context) {
    return getPrimaryColor(context);
  }

  /// الحصول على لون الزر الثانوي
  static Color getSecondaryButtonColor(BuildContext context) {
    return getSecondaryColor(context);
  }

  /// الحصول على لون الزر المعطل
  static Color getDisabledButtonColor(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    return isDark ? Colors.grey[600]! : Colors.grey[300]!;
  }

  /// الحصول على لون النص في الزر الأساسي
  static Color getPrimaryButtonTextColor(BuildContext context) {
    return Colors.white;
  }

  /// الحصول على لون النص في الزر الثانوي
  static Color getSecondaryButtonTextColor(BuildContext context) {
    return getPrimaryColor(context);
  }

  /// الحصول على لون النص في الزر المعطل
  static Color getDisabledButtonTextColor(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    return isDark ? Colors.white38 : Colors.black38;
  }

  /// الحصول على لون التنبيه
  static Color getAlertColor(BuildContext context, AlertType type) {
    final isDark = DeviceAdaptation.detectDarkMode(context);

    switch (type) {
      case AlertType.success:
        return isDark ? Colors.green[300]! : Colors.green[700]!;
      case AlertType.error:
        return isDark ? Colors.red[300]! : Colors.red[700]!;
      case AlertType.warning:
        return isDark ? Colors.orange[300]! : Colors.orange[700]!;
      case AlertType.info:
        return isDark ? Colors.blue[300]! : Colors.blue[700]!;
    }
  }

  /// الحصول على لون خلفية التنبيه
  static Color getAlertBackgroundColor(BuildContext context, AlertType type) {
    final isDark = DeviceAdaptation.detectDarkMode(context);

    switch (type) {
      case AlertType.success:
        return isDark ? Colors.green[900]! : Colors.green[50]!;
      case AlertType.error:
        return isDark ? Colors.red[900]! : Colors.red[50]!;
      case AlertType.warning:
        return isDark ? Colors.orange[900]! : Colors.orange[50]!;
      case AlertType.info:
        return isDark ? Colors.blue[900]! : Colors.blue[50]!;
    }
  }

  /// الحصول على لون الرابط
  static Color getLinkColor(BuildContext context) {
    return getPrimaryColor(context);
  }

  /// الحصول على لون الرابط المحدد
  static Color getFocusedLinkColor(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    return isDark ? Colors.blue[300]! : Colors.blue[600]!;
  }

  /// الحصول على لون الرابط المعطل
  static Color getDisabledLinkColor(BuildContext context) {
    final isDark = DeviceAdaptation.detectDarkMode(context);
    return isDark ? Colors.white38 : Colors.black38;
  }
}

/// أنواع التنبيهات
enum AlertType { success, error, warning, info }
