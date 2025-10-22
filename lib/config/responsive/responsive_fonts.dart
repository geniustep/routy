import 'package:flutter/material.dart';
import 'package:routy/config/core/design_tokens.dart';
import 'package:routy/config/device/device_adaptation.dart';
import 'package:routy/config/core/app_config.dart';

/// نظام الخطوط المتجاوب
class ResponsiveFonts {
  /// الحصول على حجم الخط المناسب
  static double getFontSize(BuildContext context, FontType type) {
    final deviceType = DeviceAdaptation.detectDeviceType(context);
    final screenSize = DeviceAdaptation.detectScreenSize(context);
    final orientation = DeviceAdaptation.detectOrientation(context);
    final fontScale = DeviceAdaptation.detectFontScale(context);

    // الحجم الأساسي
    double baseSize = DesignTokens.getFontSize(type);

    // تعديل الحجم حسب نوع الجهاز
    switch (deviceType) {
      case DeviceType.phone:
        baseSize *= 0.9;
        break;
      case DeviceType.tablet:
        baseSize *= 1.0;
        break;
      case DeviceType.desktop:
        baseSize *= 1.1;
        break;
      case DeviceType.watch:
        baseSize *= 0.8;
        break;
    }

    // تعديل الحجم حسب حجم الشاشة
    switch (screenSize) {
      case ScreenSize.small:
        baseSize *= 0.9;
        break;
      case ScreenSize.medium:
        baseSize *= 1.0;
        break;
      case ScreenSize.large:
        baseSize *= 1.1;
        break;
      case ScreenSize.xlarge:
        baseSize *= 1.2;
        break;
    }

    // تعديل الحجم حسب اتجاه الشاشة
    if (orientation == NewOrientation.landscape) {
      baseSize *= 1.05;
    }

    // تطبيق مقياس الخط
    return baseSize * fontScale;
  }

  /// الحصول على عائلة الخط المناسبة
  static String getFontFamily(BuildContext context) {
    final language = DeviceAdaptation.detectLanguage(context);

    // تحديد الخط بناءً على اللغة
    if (language == 'ar') {
      return 'Cairo';
    } else {
      return 'Roboto';
    }
  }

  /// الحصول على وزن الخط المناسب
  static FontWeight getFontWeight(BuildContext context, FontType type) {
    final deviceType = DeviceAdaptation.detectDeviceType(context);

    FontWeight baseWeight;
    switch (type) {
      case FontType.display:
        baseWeight = FontWeight.bold;
        break;
      case FontType.headline:
        baseWeight = FontWeight.w600;
        break;
      case FontType.title:
        baseWeight = FontWeight.w500;
        break;
      case FontType.body:
        baseWeight = FontWeight.normal;
        break;
      case FontType.caption:
        baseWeight = FontWeight.normal;
        break;
    }

    // تعديل الوزن حسب نوع الجهاز
    switch (deviceType) {
      case DeviceType.phone:
        // تقليل الوزن قليلاً للهواتف
        if (baseWeight == FontWeight.bold) {
          baseWeight = FontWeight.w700;
        }
        break;
      case DeviceType.tablet:
        // الوزن العادي
        break;
      case DeviceType.desktop:
        // زيادة الوزن قليلاً لسطح المكتب
        if (baseWeight == FontWeight.normal) {
          baseWeight = FontWeight.w500;
        }
        break;
      case DeviceType.watch:
        // تقليل الوزن للساعات
        if (baseWeight == FontWeight.bold) {
          baseWeight = FontWeight.w600;
        }
        break;
    }

    return baseWeight;
  }

  /// الحصول على نمط النص المناسب
  static TextStyle getTextStyle(BuildContext context, FontType type) {
    final fontSize = getFontSize(context, type);
    final fontFamily = getFontFamily(context);
    final fontWeight = getFontWeight(context, type);
    final isDark = DeviceAdaptation.detectDarkMode(context);

    return TextStyle(
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      color: DesignTokens.getColor(ColorType.text, isDark: isDark),
    );
  }

  /// الحصول على نمط النص مع خيارات مخصصة
  static TextStyle getCustomTextStyle(
    BuildContext context, {
    required FontType type,
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    String? fontFamily,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
  }) {
    final baseStyle = getTextStyle(context, type);
    final isDark = DeviceAdaptation.detectDarkMode(context);

    return baseStyle.copyWith(
      color: color ?? DesignTokens.getColor(ColorType.text, isDark: isDark),
      fontWeight: fontWeight ?? getFontWeight(context, type),
      fontSize: fontSize ?? getFontSize(context, type),
      fontFamily: fontFamily ?? getFontFamily(context),
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
    );
  }

  /// الحصول على نمط النص للعناوين
  static TextStyle getHeadingStyle(
    BuildContext context, {
    int level = 1,
    Color? color,
    FontWeight? fontWeight,
  }) {
    FontType type;
    switch (level) {
      case 1:
        type = FontType.display;
        break;
      case 2:
        type = FontType.headline;
        break;
      case 3:
        type = FontType.title;
        break;
      default:
        type = FontType.title;
        break;
    }

    return getCustomTextStyle(
      context,
      type: type,
      color: color,
      fontWeight: fontWeight,
    );
  }

  /// الحصول على نمط النص للجسم
  static TextStyle getBodyStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return getCustomTextStyle(
      context,
      type: FontType.body,
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }

  /// الحصول على نمط النص للتسميات
  static TextStyle getCaptionStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return getCustomTextStyle(
      context,
      type: FontType.caption,
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }

  /// الحصول على نمط النص للأزرار
  static TextStyle getButtonStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    final deviceType = DeviceAdaptation.detectDeviceType(context);

    double buttonFontSize = getFontSize(context, FontType.body);

    // تعديل حجم خط الزر حسب نوع الجهاز
    switch (deviceType) {
      case DeviceType.phone:
        buttonFontSize *= 0.9;
        break;
      case DeviceType.tablet:
        buttonFontSize *= 1.0;
        break;
      case DeviceType.desktop:
        buttonFontSize *= 1.1;
        break;
      case DeviceType.watch:
        buttonFontSize *= 0.8;
        break;
    }

    return getCustomTextStyle(
      context,
      type: FontType.body,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w500,
      fontSize: fontSize ?? buttonFontSize,
    );
  }

  /// الحصول على نمط النص للحقول
  static TextStyle getFieldStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return getCustomTextStyle(
      context,
      type: FontType.body,
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }

  /// الحصول على نمط النص للبطاقات
  static TextStyle getCardStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return getCustomTextStyle(
      context,
      type: FontType.body,
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }

  /// الحصول على نمط النص للقوائم
  static TextStyle getListStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return getCustomTextStyle(
      context,
      type: FontType.body,
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }

  /// الحصول على نمط النص للتنقل
  static TextStyle getNavigationStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return getCustomTextStyle(
      context,
      type: FontType.caption,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w500,
      fontSize: fontSize,
    );
  }

  /// الحصول على نمط النص للتبويبات
  static TextStyle getTabStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return getCustomTextStyle(
      context,
      type: FontType.caption,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w500,
      fontSize: fontSize,
    );
  }

  /// الحصول على نمط النص للتنبيهات
  static TextStyle getAlertStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return getCustomTextStyle(
      context,
      type: FontType.body,
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }

  /// الحصول على نمط النص للأخطاء
  static TextStyle getErrorStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    final isDark = DeviceAdaptation.detectDarkMode(context);

    return getCustomTextStyle(
      context,
      type: FontType.caption,
      color: color ?? (isDark ? Colors.red[300] : Colors.red[700]),
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }

  /// الحصول على نمط النص للنجاح
  static TextStyle getSuccessStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    final isDark = DeviceAdaptation.detectDarkMode(context);

    return getCustomTextStyle(
      context,
      type: FontType.caption,
      color: color ?? (isDark ? Colors.green[300] : Colors.green[700]),
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }

  /// الحصول على نمط النص للتحذير
  static TextStyle getWarningStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    final isDark = DeviceAdaptation.detectDarkMode(context);

    return getCustomTextStyle(
      context,
      type: FontType.caption,
      color: color ?? (isDark ? Colors.orange[300] : Colors.orange[700]),
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }

  /// الحصول على نمط النص للمعلومات
  static TextStyle getInfoStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    final isDark = DeviceAdaptation.detectDarkMode(context);

    return getCustomTextStyle(
      context,
      type: FontType.caption,
      color: color ?? (isDark ? Colors.blue[300] : Colors.blue[700]),
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }
}
