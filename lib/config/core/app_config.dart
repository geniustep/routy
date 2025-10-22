import 'package:flutter/material.dart';

/// أنواع الأجهزة المدعومة
enum DeviceType {
  phone, // هاتف
  tablet, // تابلت
  desktop, // سطح مكتب
  watch, // ساعة ذكية
}

/// أحجام الشاشات
enum ScreenSize {
  small, // < 600px
  medium, // 600-900px
  large, // 900-1200px
  xlarge, // > 1200px
}

/// اتجاهات الشاشة
enum NewOrientation {
  portrait, // عمودي
  landscape, // أفقي
}

/// أنماط التصميم
enum DesignMode {
  compact, // مدمج
  normal, // عادي
  spacious, // واسع
}

/// أنواع الخطوط
enum FontType {
  display, // للعناوين الكبيرة
  headline, // للعناوين
  title, // للعناوين الفرعية
  body, // للنصوص العادية
  caption, // للنصوص الصغيرة
}

/// أنواع المسافات
enum SpacingType {
  xs, // 4px
  sm, // 8px
  md, // 16px
  lg, // 24px
  xl, // 32px
  xxl, // 48px
}

/// أنواع الألوان
enum ColorType {
  primary, // اللون الأساسي
  secondary, // اللون الثانوي
  background, // لون الخلفية
  surface, // لون السطح
  text, // لون النص
  accent, // لون التمييز
}

/// أنواع التخطيط
enum LayoutType {
  singleColumn, // عمود واحد
  twoColumn, // عمودين
  threeColumn, // ثلاثة أعمدة
  grid, // شبكة
  list, // قائمة
}

/// إعدادات التطبيق الرئيسية
class AppConfig {
  static DeviceType _deviceType = DeviceType.phone;
  static ScreenSize _screenSize = ScreenSize.small;
  static NewOrientation _orientation = NewOrientation.portrait;
  static DesignMode _designMode = DesignMode.normal;
  static String _fontFamily = 'Cairo';
  static double _fontScale = 1.0;
  static bool _isDarkMode = false;
  static String _language = 'fr';

  // Getters
  static DeviceType get deviceType => _deviceType;
  static ScreenSize get screenSize => _screenSize;
  static NewOrientation get orientation => _orientation;
  static DesignMode get designMode => _designMode;
  static String get fontFamily => _fontFamily;
  static double get fontScale => _fontScale;
  static bool get isDarkMode => _isDarkMode;
  static String get language => _language;

  // Setters
  static void setDeviceType(DeviceType type) => _deviceType = type;
  static void setScreenSize(ScreenSize size) => _screenSize = size;
  static void setOrientation(NewOrientation orientation) =>
      _orientation = orientation;
  static void setDesignMode(DesignMode mode) => _designMode = mode;
  static void setFontFamily(String family) => _fontFamily = family;
  static void setFontScale(double scale) => _fontScale = scale;
  static void setDarkMode(bool isDark) => _isDarkMode = isDark;
  static void setLanguage(String lang) => _language = lang;

  /// تحديث الإعدادات بناءً على السياق
  static void updateFromContext(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final flutterOrientation = mediaQuery.orientation;

    // تحديث نوع الجهاز
    if (size.width < 600) {
      _deviceType = DeviceType.phone;
    } else if (size.width < 900) {
      _deviceType = DeviceType.tablet;
    } else {
      _deviceType = DeviceType.desktop;
    }

    // تحديث حجم الشاشة
    if (size.width < 600) {
      _screenSize = ScreenSize.small;
    } else if (size.width < 900) {
      _screenSize = ScreenSize.medium;
    } else if (size.width < 1200) {
      _screenSize = ScreenSize.large;
    } else {
      _screenSize = ScreenSize.xlarge;
    }

    // تحديث اتجاه الشاشة
    if (flutterOrientation.toString() == 'Orientation.portrait') {
      _orientation = NewOrientation.portrait;
    } else {
      _orientation = NewOrientation.landscape;
    }
  }

  /// إعادة تعيين الإعدادات
  static void reset() {
    _deviceType = DeviceType.phone;
    _screenSize = ScreenSize.small;
    _orientation = NewOrientation.portrait;
    _designMode = DesignMode.normal;
    _fontFamily = 'Cairo';
    _fontScale = 1.0;
    _isDarkMode = false;
    _language = 'fr';
  }
}
