import 'package:flutter/material.dart';
import 'package:routy/config/core/app_config.dart';

/// نظام التكيف مع الجهاز
class DeviceAdaptation {
  /// تحديد نوع الجهاز بناءً على الخصائص
  static DeviceType detectDeviceType(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;

    // تحديد نوع الجهاز بناءً على العرض
    if (size.width < 600) {
      return DeviceType.phone;
    } else if (size.width < 900) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// تحديد حجم الشاشة بناءً على الخصائص
  static ScreenSize detectScreenSize(BuildContext context) {
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

  /// تحديد اتجاه الشاشة بناءً على الخصائص
  static NewOrientation detectOrientation(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.orientation == Orientation.portrait
        ? NewOrientation.portrait
        : NewOrientation.landscape;
  }

  /// تحديد نمط التصميم المناسب
  static DesignMode detectDesignMode(BuildContext context) {
    final deviceType = detectDeviceType(context);

    switch (deviceType) {
      case DeviceType.phone:
        return DesignMode.compact;
      case DeviceType.tablet:
        return DesignMode.normal;
      case DeviceType.desktop:
        return DesignMode.spacious;
      case DeviceType.watch:
        return DesignMode.compact;
    }
  }

  /// تحديد عائلة الخط المناسبة
  static String detectFontFamily(BuildContext context) {
    final language = AppConfig.language;

    // تحديد الخط بناءً على اللغة
    if (language == 'ar') {
      return 'Cairo';
    } else {
      return 'Roboto';
    }
  }

  /// تحديد مقياس الخط المناسب
  static double detectFontScale(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final deviceType = detectDeviceType(context);
    final screenSize = detectScreenSize(context);

    double baseScale = mediaQuery.textScaler.scale(1.0);

    // تعديل المقياس حسب نوع الجهاز
    switch (deviceType) {
      case DeviceType.phone:
        baseScale *= 0.9;
        break;
      case DeviceType.tablet:
        baseScale *= 1.0;
        break;
      case DeviceType.desktop:
        baseScale *= 1.1;
        break;
      case DeviceType.watch:
        baseScale *= 0.8;
        break;
    }

    // تعديل المقياس حسب حجم الشاشة
    switch (screenSize) {
      case ScreenSize.small:
        baseScale *= 0.9;
        break;
      case ScreenSize.medium:
        baseScale *= 1.0;
        break;
      case ScreenSize.large:
        baseScale *= 1.1;
        break;
      case ScreenSize.xlarge:
        baseScale *= 1.2;
        break;
    }

    return baseScale;
  }

  /// تحديد الوضع الليلي المناسب
  static bool detectDarkMode(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.platformBrightness == Brightness.dark;
  }

  /// تحديد اللغة المناسبة
  static String detectLanguage(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode;
  }

  /// تحديث جميع الإعدادات بناءً على السياق
  static void updateAllSettings(BuildContext context) {
    AppConfig.setDeviceType(detectDeviceType(context));
    AppConfig.setScreenSize(detectScreenSize(context));
    AppConfig.setDesignMode(detectDesignMode(context));
    AppConfig.setFontFamily(detectFontFamily(context));
    AppConfig.setFontScale(detectFontScale(context));
    AppConfig.setDarkMode(detectDarkMode(context));
    AppConfig.setLanguage(detectLanguage(context));
  }

  /// الحصول على معلومات الجهاز
  static Map<String, dynamic> getDeviceInfo(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final deviceType = detectDeviceType(context);
    final screenSize = detectScreenSize(context);
    final orientation = detectOrientation(context);

    return {
      'deviceType': deviceType.toString(),
      'screenSize': screenSize.toString(),
      'orientation': orientation.toString(),
      'width': mediaQuery.size.width,
      'height': mediaQuery.size.height,
      'pixelRatio': mediaQuery.devicePixelRatio,
      'textScaleFactor': mediaQuery.textScaler.scale(1.0),
      'platform': Theme.of(context).platform.toString(),
      'brightness': mediaQuery.platformBrightness.toString(),
    };
  }

  /// التحقق من نوع الجهاز
  static bool isPhone(BuildContext context) {
    return detectDeviceType(context) == DeviceType.phone;
  }

  static bool isTablet(BuildContext context) {
    return detectDeviceType(context) == DeviceType.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return detectDeviceType(context) == DeviceType.desktop;
  }

  static bool isWatch(BuildContext context) {
    return detectDeviceType(context) == DeviceType.watch;
  }

  /// التحقق من حجم الشاشة
  static bool isSmallScreen(BuildContext context) {
    return detectScreenSize(context) == ScreenSize.small;
  }

  static bool isMediumScreen(BuildContext context) {
    return detectScreenSize(context) == ScreenSize.medium;
  }

  static bool isLargeScreen(BuildContext context) {
    return detectScreenSize(context) == ScreenSize.large;
  }

  static bool isXLargeScreen(BuildContext context) {
    return detectScreenSize(context) == ScreenSize.xlarge;
  }

  /// التحقق من اتجاه الشاشة
  static bool isPortrait(BuildContext context) {
    return detectOrientation(context) == NewOrientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return detectOrientation(context) == NewOrientation.landscape;
  }

  /// التحقق من نمط التصميم
  static bool isCompactMode(BuildContext context) {
    return detectDesignMode(context) == DesignMode.compact;
  }

  static bool isNormalMode(BuildContext context) {
    return detectDesignMode(context) == DesignMode.normal;
  }

  static bool isSpaciousMode(BuildContext context) {
    return detectDesignMode(context) == DesignMode.spacious;
  }

  /// الحصول على التخطيط المناسب للجهاز
  static Widget getAdaptiveLayout(
    BuildContext context, {
    required Widget phoneLayout,
    Widget? tabletLayout,
    Widget? desktopLayout,
    Widget? watchLayout,
  }) {
    final deviceType = detectDeviceType(context);

    switch (deviceType) {
      case DeviceType.phone:
        return phoneLayout;
      case DeviceType.tablet:
        return tabletLayout ?? phoneLayout;
      case DeviceType.desktop:
        return desktopLayout ?? tabletLayout ?? phoneLayout;
      case DeviceType.watch:
        return watchLayout ?? phoneLayout;
    }
  }

  /// الحصول على التخطيط المناسب للشاشة
  static Widget getScreenAdaptiveLayout(
    BuildContext context, {
    required Widget smallLayout,
    Widget? mediumLayout,
    Widget? largeLayout,
    Widget? xlargeLayout,
  }) {
    final screenSize = detectScreenSize(context);

    switch (screenSize) {
      case ScreenSize.small:
        return smallLayout;
      case ScreenSize.medium:
        return mediumLayout ?? smallLayout;
      case ScreenSize.large:
        return largeLayout ?? mediumLayout ?? smallLayout;
      case ScreenSize.xlarge:
        return xlargeLayout ?? largeLayout ?? mediumLayout ?? smallLayout;
    }
  }

  /// الحصول على التخطيط المناسب للاتجاه
  static Widget getOrientationAdaptiveLayout(
    BuildContext context, {
    required Widget portraitLayout,
    required Widget landscapeLayout,
  }) {
    final orientation = detectOrientation(context);

    return orientation == NewOrientation.portrait
        ? portraitLayout
        : landscapeLayout;
  }
}
