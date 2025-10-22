import 'package:flutter/material.dart';
import 'package:routy/config/core/app_config.dart';

/// نظام التصميم المتجاوب
class ResponsiveDesign {
  /// تحديد نوع الجهاز بناءً على السياق
  static DeviceType getDeviceType(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;

    if (size.width < 600) {
      return DeviceType.phone;
    } else if (size.width < 900) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// تحديد حجم الشاشة بناءً على السياق
  static ScreenSize getScreenSize(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;

    if (size.width < 600) {
      return ScreenSize.small;
    } else if (size.width < 900) {
      return ScreenSize.medium;
    } else if (size.width < 1200) {
      return ScreenSize.large;
    } else {
      return ScreenSize.xlarge;
    }
  }

  /// تحديد اتجاه الشاشة بناءً على السياق
  static NewOrientation getOrientation(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.orientation == Orientation.portrait
        ? NewOrientation.portrait
        : NewOrientation.landscape;
  }

  /// تحديد نوع التخطيط المناسب
  static LayoutType getLayoutType(BuildContext context) {
    final deviceType = getDeviceType(context);
    final screenSize = getScreenSize(context);
    final orientation = getOrientation(context);

    switch (deviceType) {
      case DeviceType.phone:
        return LayoutType.singleColumn;
      case DeviceType.tablet:
        if (orientation == NewOrientation.landscape) {
          return LayoutType.twoColumn;
        } else {
          return LayoutType.singleColumn;
        }
      case DeviceType.desktop:
        if (screenSize == ScreenSize.xlarge) {
          return LayoutType.threeColumn;
        } else {
          return LayoutType.twoColumn;
        }
      case DeviceType.watch:
        return LayoutType.singleColumn;
    }
  }

  /// تحديد حجم الخط المناسب
  static double getFontSize(BuildContext context, FontType type) {
    final deviceType = getDeviceType(context);
    final screenSize = getScreenSize(context);
    final fontScale = MediaQuery.of(context).textScaler.scale(1.0);

    // الأحجام الأساسية
    double baseSize;
    switch (type) {
      case FontType.display:
        baseSize = 32.0;
        break;
      case FontType.headline:
        baseSize = 24.0;
        break;
      case FontType.title:
        baseSize = 20.0;
        break;
      case FontType.body:
        baseSize = 16.0;
        break;
      case FontType.caption:
        baseSize = 12.0;
        break;
    }

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

    return baseSize * fontScale;
  }

  /// تحديد المسافات المناسبة
  static EdgeInsets getPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    final screenSize = getScreenSize(context);

    double basePadding;
    switch (deviceType) {
      case DeviceType.phone:
        basePadding = 16.0;
        break;
      case DeviceType.tablet:
        basePadding = 24.0;
        break;
      case DeviceType.desktop:
        basePadding = 32.0;
        break;
      case DeviceType.watch:
        basePadding = 8.0;
        break;
    }

    // تعديل المسافة حسب حجم الشاشة
    switch (screenSize) {
      case ScreenSize.small:
        basePadding *= 0.8;
        break;
      case ScreenSize.medium:
        basePadding *= 1.0;
        break;
      case ScreenSize.large:
        basePadding *= 1.2;
        break;
      case ScreenSize.xlarge:
        basePadding *= 1.4;
        break;
    }

    return EdgeInsets.all(basePadding);
  }

  /// تحديد المسافات الأفقية
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    final padding = getPadding(context);
    return EdgeInsets.symmetric(horizontal: padding.left);
  }

  /// تحديد المسافات العمودية
  static EdgeInsets getVerticalPadding(BuildContext context) {
    final padding = getPadding(context);
    return EdgeInsets.symmetric(vertical: padding.top);
  }

  /// تحديد المسافات المخصصة
  static EdgeInsets getCustomPadding(
    BuildContext context, {
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    final basePadding = getPadding(context);
    return EdgeInsets.only(
      left: left ?? basePadding.left,
      right: right ?? basePadding.right,
      top: top ?? basePadding.top,
      bottom: bottom ?? basePadding.bottom,
    );
  }

  /// تحديد المسافات بين العناصر
  static double getSpacing(BuildContext context, SpacingType type) {
    final deviceType = getDeviceType(context);
    final screenSize = getScreenSize(context);

    double baseSpacing;
    switch (type) {
      case SpacingType.xs:
        baseSpacing = 4.0;
        break;
      case SpacingType.sm:
        baseSpacing = 8.0;
        break;
      case SpacingType.md:
        baseSpacing = 16.0;
        break;
      case SpacingType.lg:
        baseSpacing = 24.0;
        break;
      case SpacingType.xl:
        baseSpacing = 32.0;
        break;
      case SpacingType.xxl:
        baseSpacing = 48.0;
        break;
    }

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

    return baseSpacing;
  }

  /// تحديد عدد الأعمدة في الشبكة
  static int getGridColumns(BuildContext context) {
    final deviceType = getDeviceType(context);
    final screenSize = getScreenSize(context);

    switch (deviceType) {
      case DeviceType.phone:
        return 2; // ✅ تغيير من 1 إلى 2 للهواتف
      case DeviceType.tablet:
        return screenSize == ScreenSize.medium ? 3 : 4; // ✅ زيادة عدد الأعمدة
      case DeviceType.desktop:
        return screenSize == ScreenSize.large ? 4 : 6; // ✅ زيادة عدد الأعمدة
      case DeviceType.watch:
        return 1;
    }
  }

  /// تحديد عرض العنصر
  static double getItemWidth(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final deviceType = getDeviceType(context);

    double width = mediaQuery.size.width;

    switch (deviceType) {
      case DeviceType.phone:
        return width;
      case DeviceType.tablet:
        return width / 2;
      case DeviceType.desktop:
        return width / 3;
      case DeviceType.watch:
        return width;
    }
  }

  /// تحديد ارتفاع العنصر
  static double getItemHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    final screenSize = getScreenSize(context);

    double baseHeight;
    switch (deviceType) {
      case DeviceType.phone:
        baseHeight = 200.0;
        break;
      case DeviceType.tablet:
        baseHeight = 250.0;
        break;
      case DeviceType.desktop:
        baseHeight = 300.0;
        break;
      case DeviceType.watch:
        baseHeight = 150.0;
        break;
    }

    // تعديل الارتفاع حسب حجم الشاشة
    switch (screenSize) {
      case ScreenSize.small:
        baseHeight *= 0.8;
        break;
      case ScreenSize.medium:
        baseHeight *= 1.0;
        break;
      case ScreenSize.large:
        baseHeight *= 1.2;
        break;
      case ScreenSize.xlarge:
        baseHeight *= 1.4;
        break;
    }

    return baseHeight;
  }
}
