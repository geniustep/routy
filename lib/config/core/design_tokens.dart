import 'package:flutter/material.dart';
import 'app_config.dart';

/// رموز التصميم الأساسية
class DesignTokens {
  // الألوان الأساسية
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF212121);
  static const Color accentColor = Color(0xFFFF9800);

  // الألوان الداكنة
  static const Color darkPrimaryColor = Color(0xFF1976D2);
  static const Color darkSecondaryColor = Color(0xFF03DAC6);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkTextColor = Color(0xFFFFFFFF);
  static const Color darkAccentColor = Color(0xFFFF9800);

  // الخطوط
  static const String primaryFontFamily = 'Cairo';
  static const String secondaryFontFamily = 'Roboto';
  static const double baseFontSize = 16.0;

  // المسافات
  static const double baseSpacing = 16.0;
  static const double borderRadius = 8.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 6.0;

  // الأحجام
  static const double buttonHeight = 48.0;
  static const double cardHeight = 200.0;
  static const double iconSize = 24.0;
  static const double avatarSize = 40.0;

  /// الحصول على اللون المناسب حسب النوع
  static Color getColor(ColorType type, {bool isDark = false}) {
    if (isDark) {
      switch (type) {
        case ColorType.primary:
          return darkPrimaryColor;
        case ColorType.secondary:
          return darkSecondaryColor;
        case ColorType.background:
          return darkBackgroundColor;
        case ColorType.surface:
          return darkSurfaceColor;
        case ColorType.text:
          return darkTextColor;
        case ColorType.accent:
          return darkAccentColor;
      }
    } else {
      switch (type) {
        case ColorType.primary:
          return primaryColor;
        case ColorType.secondary:
          return secondaryColor;
        case ColorType.background:
          return backgroundColor;
        case ColorType.surface:
          return surfaceColor;
        case ColorType.text:
          return textColor;
        case ColorType.accent:
          return accentColor;
      }
    }
  }

  /// الحصول على المسافة المناسبة
  static double getSpacing(SpacingType type) {
    switch (type) {
      case SpacingType.xs:
        return 4.0;
      case SpacingType.sm:
        return 8.0;
      case SpacingType.md:
        return 16.0;
      case SpacingType.lg:
        return 24.0;
      case SpacingType.xl:
        return 32.0;
      case SpacingType.xxl:
        return 48.0;
    }
  }

  /// الحصول على حجم الخط المناسب
  static double getFontSize(FontType type) {
    switch (type) {
      case FontType.display:
        return 32.0;
      case FontType.headline:
        return 24.0;
      case FontType.title:
        return 20.0;
      case FontType.body:
        return 16.0;
      case FontType.caption:
        return 12.0;
    }
  }

  /// الحصول على عائلة الخط المناسبة
  static String getFontFamily({bool isArabic = false}) {
    return isArabic ? primaryFontFamily : secondaryFontFamily;
  }

  /// الحصول على نصف القطر المناسب
  static double getBorderRadius({bool isCard = false}) {
    return isCard ? cardRadius : borderRadius;
  }

  /// الحصول على حجم الأيقونة المناسب
  static double getIconSize({bool isLarge = false}) {
    return isLarge ? iconSize * 1.5 : iconSize;
  }

  /// الحصول على حجم الصورة الشخصية المناسب
  static double getAvatarSize({bool isLarge = false}) {
    return isLarge ? avatarSize * 1.5 : avatarSize;
  }

  /// الحصول على ارتفاع الزر المناسب
  static double getButtonHeight({bool isLarge = false}) {
    return isLarge ? buttonHeight * 1.2 : buttonHeight;
  }

  /// الحصول على ارتفاع البطاقة المناسب
  static double getCardHeight({bool isLarge = false}) {
    return isLarge ? cardHeight * 1.2 : cardHeight;
  }

  /// الحصول على الظل المناسب
  static List<BoxShadow> getShadow({bool isElevated = false}) {
    if (isElevated) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4.0,
          offset: const Offset(0, 2),
        ),
      ];
    }
  }

  /// الحصول على التدرج المناسب
  static LinearGradient getGradient({bool isDark = false}) {
    if (isDark) {
      return const LinearGradient(
        colors: [darkPrimaryColor, darkSecondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  /// الحصول على التدرج الدائري المناسب
  static RadialGradient getRadialGradient({bool isDark = false}) {
    if (isDark) {
      return const RadialGradient(
        colors: [darkPrimaryColor, darkSecondaryColor],
        center: Alignment.center,
        radius: 1.0,
      );
    } else {
      return const RadialGradient(
        colors: [primaryColor, secondaryColor],
        center: Alignment.center,
        radius: 1.0,
      );
    }
  }

  /// الحصول على BorderRadius المناسب
  static BorderRadius getBorderRadiusWidget({bool isCard = false}) {
    return BorderRadius.circular(isCard ? cardRadius : borderRadius);
  }

  /// الحصول على الحدود المناسبة
  static Border getBorder({bool isFocused = false}) {
    return Border.all(
      color: isFocused ? primaryColor : Colors.grey.shade300,
      width: isFocused ? 2.0 : 1.0,
    );
  }

  /// الحصول على النمط المناسب
  static TextStyle getTextStyle(FontType type, {bool isDark = false}) {
    return TextStyle(
      fontSize: getFontSize(type),
      fontFamily: getFontFamily(),
      color: getColor(ColorType.text, isDark: isDark),
      fontWeight: _getFontWeight(type),
    );
  }

  /// الحصول على وزن الخط المناسب
  static FontWeight _getFontWeight(FontType type) {
    switch (type) {
      case FontType.display:
        return FontWeight.bold;
      case FontType.headline:
        return FontWeight.w600;
      case FontType.title:
        return FontWeight.w500;
      case FontType.body:
        return FontWeight.normal;
      case FontType.caption:
        return FontWeight.normal;
    }
  }
}
