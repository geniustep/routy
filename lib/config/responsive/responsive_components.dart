import 'package:flutter/material.dart';
import 'package:routy/config/core/app_config.dart';
import 'package:routy/config/device/device_adaptation.dart';
import 'responsive_design.dart';
import 'responsive_fonts.dart';
import 'responsive_spacing.dart';
import 'responsive_colors.dart';

/// نظام المكونات المتجاوبة
class ResponsiveComponents {
  /// إنشاء زر متجاوب
  static Widget createResponsiveButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    ButtonType type = ButtonType.primary,
    ButtonSize size = ButtonSize.medium,
    bool isFullWidth = false,
    bool isDisabled = false,
    IconData? icon,
    Widget? child,
  }) {
    final deviceType = DeviceAdaptation.detectDeviceType(context);
    final screenSize = DeviceAdaptation.detectScreenSize(context);

    // تحديد حجم الزر
    double buttonHeight;
    double buttonWidth;

    switch (size) {
      case ButtonSize.small:
        buttonHeight = 32.0;
        break;
      case ButtonSize.medium:
        buttonHeight = 48.0;
        break;
      case ButtonSize.large:
        buttonHeight = 56.0;
        break;
    }

    // تعديل الحجم حسب نوع الجهاز
    switch (deviceType) {
      case DeviceType.phone:
        buttonHeight *= 0.9;
        break;
      case DeviceType.tablet:
        buttonHeight *= 1.0;
        break;
      case DeviceType.desktop:
        buttonHeight *= 1.1;
        break;
      case DeviceType.watch:
        buttonHeight *= 0.8;
        break;
    }

    // تعديل الحجم حسب حجم الشاشة
    switch (screenSize) {
      case ScreenSize.small:
        buttonHeight *= 0.9;
        break;
      case ScreenSize.medium:
        buttonHeight *= 1.0;
        break;
      case ScreenSize.large:
        buttonHeight *= 1.1;
        break;
      case ScreenSize.xlarge:
        buttonHeight *= 1.2;
        break;
    }

    // تحديد عرض الزر
    if (isFullWidth) {
      buttonWidth = double.infinity;
    } else {
      buttonWidth = buttonHeight * 3;
    }

    // تحديد لون الزر
    Color buttonColor;
    Color textColor;

    switch (type) {
      case ButtonType.primary:
        buttonColor = ResponsiveColors.getPrimaryButtonColor(context);
        textColor = ResponsiveColors.getPrimaryButtonTextColor(context);
        break;
      case ButtonType.secondary:
        buttonColor = ResponsiveColors.getSecondaryButtonColor(context);
        textColor = ResponsiveColors.getSecondaryButtonTextColor(context);
        break;
      case ButtonType.outline:
        buttonColor = Colors.transparent;
        textColor = ResponsiveColors.getPrimaryColor(context);
        break;
      case ButtonType.text:
        buttonColor = Colors.transparent;
        textColor = ResponsiveColors.getPrimaryColor(context);
        break;
    }

    // تحديد النص
    Widget buttonChild =
        child ?? Text(text, style: ResponsiveFonts.getButtonStyle(context));

    // إضافة الأيقونة إذا كانت موجودة
    if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20.0),
          SizedBox(width: ResponsiveSpacing.getButtonSpacing(context)),
          buttonChild,
        ],
      );
    }

    // إنشاء الزر
    Widget button;

    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            minimumSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: buttonChild,
        );
        break;
      case ButtonType.outline:
        button = OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor,
            minimumSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            side: BorderSide(color: textColor),
          ),
          child: buttonChild,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor,
            minimumSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: buttonChild,
        );
        break;
    }

    return button;
  }

  /// إنشاء بطاقة متجاوبة
  static Widget createResponsiveCard({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool isElevated = true,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    final deviceType = DeviceAdaptation.detectDeviceType(context);

    // تحديد المسافات
    EdgeInsets cardPadding = padding ?? ResponsiveDesign.getPadding(context);
    EdgeInsets cardMargin = margin ?? EdgeInsets.zero;

    // تعديل المسافات حسب نوع الجهاز
    switch (deviceType) {
      case DeviceType.phone:
        cardPadding = EdgeInsets.all(cardPadding.left * 0.8);
        break;
      case DeviceType.tablet:
        // المسافات العادية
        break;
      case DeviceType.desktop:
        cardPadding = EdgeInsets.all(cardPadding.left * 1.2);
        break;
      case DeviceType.watch:
        cardPadding = EdgeInsets.all(cardPadding.left * 0.6);
        break;
    }

    // إنشاء البطاقة
    Widget card = Container(
      padding: cardPadding,
      margin: cardMargin,
      decoration: BoxDecoration(
        color: ResponsiveColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: isElevated
            ? [
                BoxShadow(
                  color: ResponsiveColors.getShadowColor(context),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );

    // إضافة التفاعل إذا كان مطلوباً
    if (isClickable && onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: card,
      );
    }

    return card;
  }

  /// إنشاء حقل نص متجاوب
  static Widget createResponsiveTextField({
    required BuildContext context,
    required String label,
    String? hint,
    String? initialValue,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    bool isEnabled = true,
    int? maxLines,
    int? maxLength,
  }) {
    final deviceType = DeviceAdaptation.detectDeviceType(context);
    final screenSize = DeviceAdaptation.detectScreenSize(context);

    // تحديد ارتفاع الحقل
    double fieldHeight = 48.0;

    // تعديل الارتفاع حسب نوع الجهاز
    switch (deviceType) {
      case DeviceType.phone:
        fieldHeight *= 0.9;
        break;
      case DeviceType.tablet:
        fieldHeight *= 1.0;
        break;
      case DeviceType.desktop:
        fieldHeight *= 1.1;
        break;
      case DeviceType.watch:
        fieldHeight *= 0.8;
        break;
    }

    // تعديل الارتفاع حسب حجم الشاشة
    switch (screenSize) {
      case ScreenSize.small:
        fieldHeight *= 0.9;
        break;
      case ScreenSize.medium:
        fieldHeight *= 1.0;
        break;
      case ScreenSize.large:
        fieldHeight *= 1.1;
        break;
      case ScreenSize.xlarge:
        fieldHeight *= 1.2;
        break;
    }

    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: isEnabled,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      style: ResponsiveFonts.getFieldStyle(context),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: ResponsiveColors.getBorderColor(context),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: ResponsiveColors.getBorderColor(context),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: ResponsiveColors.getFocusedBorderColor(context),
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: ResponsiveColors.getErrorBorderColor(context),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: ResponsiveColors.getErrorBorderColor(context),
            width: 2.0,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: fieldHeight / 2 - 12.0,
        ),
      ),
    );
  }

  /// إنشاء قائمة متجاوبة
  static Widget createResponsiveList({
    required BuildContext context,
    required List<Widget> children,
    bool isScrollable = true,
    EdgeInsets? padding,
    double? spacing,
  }) {
    final deviceType = DeviceAdaptation.detectDeviceType(context);

    // تحديد المسافات
    EdgeInsets listPadding = padding ?? ResponsiveDesign.getPadding(context);
    double listSpacing = spacing ?? ResponsiveSpacing.getListSpacing(context);

    // تعديل المسافات حسب نوع الجهاز
    switch (deviceType) {
      case DeviceType.phone:
        listPadding = EdgeInsets.all(listPadding.left * 0.8);
        listSpacing *= 0.8;
        break;
      case DeviceType.tablet:
        // المسافات العادية
        break;
      case DeviceType.desktop:
        listPadding = EdgeInsets.all(listPadding.left * 1.2);
        listSpacing *= 1.2;
        break;
      case DeviceType.watch:
        listPadding = EdgeInsets.all(listPadding.left * 0.6);
        listSpacing *= 0.6;
        break;
    }

    // إنشاء القائمة
    if (isScrollable) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: listPadding,
        itemCount: children.length,
        separatorBuilder: (context, index) => SizedBox(height: listSpacing),
        itemBuilder: (context, index) => children[index],
      );
    } else {
      return Padding(
        padding: listPadding,
        child: Column(children: _addSpacing(children, listSpacing)),
      );
    }
  }

  /// إنشاء شبكة متجاوبة
  static Widget createResponsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    int? crossAxisCount,
    double? childAspectRatio,
    EdgeInsets? padding,
    double? spacing,
    double? crossAxisSpacing,
  }) {
    final deviceType = DeviceAdaptation.detectDeviceType(context);
    final screenSize = DeviceAdaptation.detectScreenSize(context);

    // تحديد عدد الأعمدة
    int gridCrossAxisCount =
        crossAxisCount ?? ResponsiveDesign.getGridColumns(context);

    // تعديل عدد الأعمدة حسب حجم الشاشة
    switch (screenSize) {
      case ScreenSize.small:
        gridCrossAxisCount = (gridCrossAxisCount * 0.8).round().clamp(1, 4);
        break;
      case ScreenSize.medium:
        // العدد العادي
        break;
      case ScreenSize.large:
        gridCrossAxisCount = (gridCrossAxisCount * 1.2).round().clamp(1, 6);
        break;
      case ScreenSize.xlarge:
        gridCrossAxisCount = (gridCrossAxisCount * 1.5).round().clamp(1, 8);
        break;
    }

    // تحديد المسافات
    EdgeInsets gridPadding = padding ?? ResponsiveDesign.getPadding(context);
    double gridSpacing = spacing ?? ResponsiveSpacing.getGridSpacing(context);
    double gridCrossAxisSpacing =
        crossAxisSpacing ?? ResponsiveSpacing.getGridSpacing(context);

    // تعديل المسافات حسب نوع الجهاز
    switch (deviceType) {
      case DeviceType.phone:
        gridPadding = EdgeInsets.all(gridPadding.left * 0.8);
        gridSpacing *= 0.8;
        gridCrossAxisSpacing *= 0.8;
        break;
      case DeviceType.tablet:
        // المسافات العادية
        break;
      case DeviceType.desktop:
        gridPadding = EdgeInsets.all(gridPadding.left * 1.2);
        gridSpacing *= 1.2;
        gridCrossAxisSpacing *= 1.2;
        break;
      case DeviceType.watch:
        gridPadding = EdgeInsets.all(gridPadding.left * 0.6);
        gridSpacing *= 0.6;
        gridCrossAxisSpacing *= 0.6;
        break;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: gridCrossAxisCount,
      childAspectRatio: childAspectRatio ?? 1.0,
      padding: gridPadding,
      mainAxisSpacing: gridSpacing,
      crossAxisSpacing: gridCrossAxisSpacing,
      children: children,
    );
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
}

/// أنواع الأزرار
enum ButtonType { primary, secondary, outline, text }

/// أحجام الأزرار
enum ButtonSize { small, medium, large }
