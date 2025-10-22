import 'package:flutter/material.dart';
import 'package:routy/config/core/app_config.dart';
import 'package:routy/config/device/device_adaptation.dart';
import 'responsive_design.dart';

/// نظام التخطيط المتجاوب
class ResponsiveLayout {
  /// الحصول على نوع التخطيط المناسب
  static LayoutType getLayoutType(BuildContext context) {
    final deviceType = DeviceAdaptation.detectDeviceType(context);
    final screenSize = DeviceAdaptation.detectScreenSize(context);
    final orientation = DeviceAdaptation.detectOrientation(context);

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

  /// إنشاء تخطيط عمود واحد
  static Widget createSingleColumnLayout({
    required List<Widget> children,
    EdgeInsets? padding,
    double? spacing,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(children: _addSpacing(children, spacing ?? 16.0)),
    );
  }

  /// إنشاء تخطيط عمودين
  static Widget createTwoColumnLayout({
    required List<Widget> children,
    EdgeInsets? padding,
    double? spacing,
    double? crossAxisSpacing,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: crossAxisSpacing ?? 16.0,
        mainAxisSpacing: spacing ?? 16.0,
        children: children,
      ),
    );
  }

  /// إنشاء تخطيط ثلاثة أعمدة
  static Widget createThreeColumnLayout({
    required List<Widget> children,
    EdgeInsets? padding,
    double? spacing,
    double? crossAxisSpacing,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: crossAxisSpacing ?? 16.0,
        mainAxisSpacing: spacing ?? 16.0,
        children: children,
      ),
    );
  }

  /// إنشاء تخطيط شبكة
  static Widget createGridLayout({
    required List<Widget> children,
    required int crossAxisCount,
    EdgeInsets? padding,
    double? spacing,
    double? crossAxisSpacing,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing ?? 16.0,
        mainAxisSpacing: spacing ?? 16.0,
        children: children,
      ),
    );
  }

  /// إنشاء تخطيط قائمة
  static Widget createListLayout({
    required List<Widget> children,
    EdgeInsets? padding,
    double? spacing,
    bool? shrinkWrap,
    ScrollPhysics? physics,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: shrinkWrap ?? true, // ✅ تغيير الافتراضي إلى true
        physics:
            physics ??
            const NeverScrollableScrollPhysics(), // ✅ تغيير الافتراضي
        itemCount: children.length,
        separatorBuilder: (context, index) => SizedBox(height: spacing ?? 16.0),
        itemBuilder: (context, index) => children[index],
      ),
    );
  }

  /// إنشاء تخطيط متجاوب تلقائياً
  static Widget createAdaptiveLayout({
    required BuildContext context,
    required List<Widget> children,
    EdgeInsets? padding,
    double? spacing,
    double? crossAxisSpacing,
  }) {
    final layoutType = getLayoutType(context);

    switch (layoutType) {
      case LayoutType.singleColumn:
        return createSingleColumnLayout(
          children: children,
          padding: padding,
          spacing: spacing,
        );
      case LayoutType.twoColumn:
        return createTwoColumnLayout(
          children: children,
          padding: padding,
          spacing: spacing,
          crossAxisSpacing: crossAxisSpacing,
        );
      case LayoutType.threeColumn:
        return createThreeColumnLayout(
          children: children,
          padding: padding,
          spacing: spacing,
          crossAxisSpacing: crossAxisSpacing,
        );
      case LayoutType.grid:
        return createGridLayout(
          children: children,
          crossAxisCount: ResponsiveDesign.getGridColumns(context),
          padding: padding,
          spacing: spacing,
          crossAxisSpacing: crossAxisSpacing,
        );
      case LayoutType.list:
        return createListLayout(
          children: children,
          padding: padding,
          spacing: spacing,
        );
    }
  }

  /// إنشاء تخطيط متجاوب مع خيارات مخصصة
  static Widget createCustomAdaptiveLayout({
    required BuildContext context,
    required List<Widget> children,
    Widget? phoneLayout,
    Widget? tabletLayout,
    Widget? desktopLayout,
    Widget? watchLayout,
    EdgeInsets? padding,
    double? spacing,
  }) {
    final deviceType = DeviceAdaptation.detectDeviceType(context);

    Widget layout;
    switch (deviceType) {
      case DeviceType.phone:
        layout =
            phoneLayout ??
            createSingleColumnLayout(
              children: children,
              padding: padding,
              spacing: spacing,
            );
        break;
      case DeviceType.tablet:
        layout =
            tabletLayout ??
            createTwoColumnLayout(
              children: children,
              padding: padding,
              spacing: spacing,
            );
        break;
      case DeviceType.desktop:
        layout =
            desktopLayout ??
            createThreeColumnLayout(
              children: children,
              padding: padding,
              spacing: spacing,
            );
        break;
      case DeviceType.watch:
        layout =
            watchLayout ??
            createSingleColumnLayout(
              children: children,
              padding: padding,
              spacing: spacing,
            );
        break;
    }

    return layout;
  }

  /// إنشاء تخطيط متجاوب مع اتجاه الشاشة
  static Widget createOrientationAdaptiveLayout({
    required BuildContext context,
    required List<Widget> children,
    Widget? portraitLayout,
    Widget? landscapeLayout,
    EdgeInsets? padding,
    double? spacing,
  }) {
    final orientation = DeviceAdaptation.detectOrientation(context);

    if (orientation == NewOrientation.portrait) {
      return portraitLayout ??
          createSingleColumnLayout(
            children: children,
            padding: padding,
            spacing: spacing,
          );
    } else {
      return landscapeLayout ??
          createTwoColumnLayout(
            children: children,
            padding: padding,
            spacing: spacing,
          );
    }
  }

  /// إنشاء تخطيط متجاوب مع حجم الشاشة
  static Widget createScreenSizeAdaptiveLayout({
    required BuildContext context,
    required List<Widget> children,
    Widget? smallLayout,
    Widget? mediumLayout,
    Widget? largeLayout,
    Widget? xlargeLayout,
    EdgeInsets? padding,
    double? spacing,
  }) {
    final screenSize = DeviceAdaptation.detectScreenSize(context);

    switch (screenSize) {
      case ScreenSize.small:
        return smallLayout ??
            createSingleColumnLayout(
              children: children,
              padding: padding,
              spacing: spacing,
            );
      case ScreenSize.medium:
        return mediumLayout ??
            createTwoColumnLayout(
              children: children,
              padding: padding,
              spacing: spacing,
            );
      case ScreenSize.large:
        return largeLayout ??
            createThreeColumnLayout(
              children: children,
              padding: padding,
              spacing: spacing,
            );
      case ScreenSize.xlarge:
        return xlargeLayout ??
            createThreeColumnLayout(
              children: children,
              padding: padding,
              spacing: spacing,
            );
    }
  }

  /// إنشاء تخطيط متجاوب مع نمط التصميم
  static Widget createDesignModeAdaptiveLayout({
    required BuildContext context,
    required List<Widget> children,
    Widget? compactLayout,
    Widget? normalLayout,
    Widget? spaciousLayout,
    EdgeInsets? padding,
    double? spacing,
  }) {
    final designMode = DeviceAdaptation.detectDesignMode(context);

    switch (designMode) {
      case DesignMode.compact:
        return compactLayout ??
            createSingleColumnLayout(
              children: children,
              padding: padding,
              spacing: spacing,
            );
      case DesignMode.normal:
        return normalLayout ??
            createTwoColumnLayout(
              children: children,
              padding: padding,
              spacing: spacing,
            );
      case DesignMode.spacious:
        return spaciousLayout ??
            createThreeColumnLayout(
              children: children,
              padding: padding,
              spacing: spacing,
            );
    }
  }

  /// إضافة المسافات بين العناصر
  static List<Widget> _addSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) return children;

    List<Widget> spacedChildren = [children.first];

    for (int i = 1; i < children.length; i++) {
      spacedChildren.add(SizedBox(height: spacing));
      spacedChildren.add(children[i]);
    }

    return spacedChildren;
  }

  /// إنشاء تخطيط متجاوب مع خيارات متقدمة
  static Widget createAdvancedAdaptiveLayout({
    required BuildContext context,
    required List<Widget> children,
    Map<DeviceType, Widget>? deviceLayouts,
    Map<ScreenSize, Widget>? screenLayouts,
    Map<NewOrientation, Widget>? orientationLayouts,
    Map<DesignMode, Widget>? designModeLayouts,
    EdgeInsets? padding,
    double? spacing,
    double? crossAxisSpacing,
  }) {
    // تحديد التخطيط بناءً على الأولوية
    final deviceType = DeviceAdaptation.detectDeviceType(context);
    final screenSize = DeviceAdaptation.detectScreenSize(context);
    final orientation = DeviceAdaptation.detectOrientation(context);
    final designMode = DeviceAdaptation.detectDesignMode(context);

    // التحقق من التخطيطات المخصصة
    if (deviceLayouts != null && deviceLayouts.containsKey(deviceType)) {
      return deviceLayouts[deviceType]!;
    }

    if (screenLayouts != null && screenLayouts.containsKey(screenSize)) {
      return screenLayouts[screenSize]!;
    }

    if (orientationLayouts != null &&
        orientationLayouts.containsKey(orientation)) {
      return orientationLayouts[orientation]!;
    }

    if (designModeLayouts != null &&
        designModeLayouts.containsKey(designMode)) {
      return designModeLayouts[designMode]!;
    }

    // استخدام التخطيط الافتراضي
    return createAdaptiveLayout(
      context: context,
      children: children,
      padding: padding,
      spacing: spacing,
      crossAxisSpacing: crossAxisSpacing,
    );
  }
}
