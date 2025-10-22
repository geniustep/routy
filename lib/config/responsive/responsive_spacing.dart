import 'package:flutter/material.dart';
import 'package:routy/config/core/app_config.dart';
import 'package:routy/config/core/design_tokens.dart';
import 'package:routy/config/device/device_adaptation.dart';

/// نظام المسافات المتجاوب
class ResponsiveSpacing {
  /// الحصول على المسافة المناسبة
  static double getSpacing(BuildContext context, SpacingType type) {
    final deviceType = DeviceAdaptation.detectDeviceType(context);
    final screenSize = DeviceAdaptation.detectScreenSize(context);
    final orientation = DeviceAdaptation.detectOrientation(context);
    final designMode = DeviceAdaptation.detectDesignMode(context);

    // المسافة الأساسية
    double baseSpacing = DesignTokens.getSpacing(type);

    // تعديل المسافة حسب نوع الجهاز
    switch (deviceType) {
      case DeviceType.phone:
        baseSpacing *= 0.8;
        break;
      case DeviceType.tablet:
        baseSpacing *= 1.0;
        break;
      case DeviceType.desktop:
        baseSpacing *= 1.2;
        break;
      case DeviceType.watch:
        baseSpacing *= 0.6;
        break;
    }

    // تعديل المسافة حسب حجم الشاشة
    switch (screenSize) {
      case ScreenSize.small:
        baseSpacing *= 0.8;
        break;
      case ScreenSize.medium:
        baseSpacing *= 1.0;
        break;
      case ScreenSize.large:
        baseSpacing *= 1.2;
        break;
      case ScreenSize.xlarge:
        baseSpacing *= 1.4;
        break;
    }

    // تعديل المسافة حسب اتجاه الشاشة
    if (orientation == NewOrientation.landscape) {
      baseSpacing *= 1.1;
    }

    // تعديل المسافة حسب نمط التصميم
    switch (designMode) {
      case DesignMode.compact:
        baseSpacing *= 0.8;
        break;
      case DesignMode.normal:
        baseSpacing *= 1.0;
        break;
      case DesignMode.spacious:
        baseSpacing *= 1.2;
        break;
    }

    return baseSpacing;
  }

  /// الحصول على المسافة الأفقية
  static double getHorizontalSpacing(BuildContext context, SpacingType type) {
    return getSpacing(context, type);
  }

  /// الحصول على المسافة العمودية
  static double getVerticalSpacing(BuildContext context, SpacingType type) {
    return getSpacing(context, type);
  }

  /// الحصول على المسافة المخصصة
  static double getCustomSpacing(
    BuildContext context, {
    required SpacingType type,
    double? multiplier,
    double? minValue,
    double? maxValue,
  }) {
    double spacing = getSpacing(context, type);

    if (multiplier != null) {
      spacing *= multiplier;
    }

    if (minValue != null && spacing < minValue) {
      spacing = minValue;
    }

    if (maxValue != null && spacing > maxValue) {
      spacing = maxValue;
    }

    return spacing;
  }

  /// الحصول على المسافة للبطاقات
  static double getCardSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.md);
  }

  /// الحصول على المسافة للقوائم
  static double getListSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.sm);
  }

  /// الحصول على المسافة للأزرار
  static double getButtonSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.sm);
  }

  /// الحصول على المسافة للحقول
  static double getFieldSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.md);
  }

  /// الحصول على المسافة للتنقل
  static double getNavigationSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.lg);
  }

  /// الحصول على المسافة للتبويبات
  static double getTabSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.md);
  }

  /// الحصول على المسافة للتنبيهات
  static double getAlertSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.md);
  }

  /// الحصول على المسافة للشبكات
  static double getGridSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.md);
  }

  /// الحصول على المسافة للصفوف
  static double getRowSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.sm);
  }

  /// الحصول على المسافة للأعمدة
  static double getColumnSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.md);
  }

  /// الحصول على المسافة للحدود
  static double getBorderSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.xs);
  }

  /// الحصول على المسافة للظلال
  static double getShadowSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.xs);
  }

  /// الحصول على المسافة للعناصر المترابطة
  static double getRelatedSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.sm);
  }

  /// الحصول على المسافة للعناصر غير المترابطة
  static double getUnrelatedSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.lg);
  }

  /// الحصول على المسافة للعناصر المجمعة
  static double getGroupSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.xl);
  }

  /// الحصول على المسافة للعناصر المنفصلة
  static double getSeparatedSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.xxl);
  }

  /// الحصول على المسافة للعناصر المتراصة
  static double getStackedSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.xs);
  }

  /// الحصول على المسافة للعناصر المتراصة مع فصل
  static double getStackedWithSeparatorSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.sm);
  }

  /// الحصول على المسافة للعناصر المتراصة مع فصل كبير
  static double getStackedWithLargeSeparatorSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.lg);
  }

  /// الحصول على المسافة للعناصر المتراصة مع فصل كبير جداً
  static double getStackedWithXLargeSeparatorSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.xl);
  }

  /// الحصول على المسافة للعناصر المتراصة مع فصل كبير جداً جداً
  static double getStackedWithXXLargeSeparatorSpacing(BuildContext context) {
    return getSpacing(context, SpacingType.xxl);
  }
}
