import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';

/// Custom Theme Types
enum CustomThemeType { light, dark, system, professional }

/// Theme Controller using GetX
class ThemeController extends GetxController {
  // Observable theme mode
  final Rx<CustomThemeType> _themeType = CustomThemeType.system.obs;

  // Getter
  CustomThemeType get themeType => _themeType.value;
  ThemeMode get themeMode {
    switch (_themeType.value) {
      case CustomThemeType.light:
        return ThemeMode.light;
      case CustomThemeType.dark:
        return ThemeMode.dark;
      case CustomThemeType.professional:
        return ThemeMode.dark; // Professional uses dark base
      case CustomThemeType.system:
        return ThemeMode.system;
    }
  }

  bool get isDarkMode =>
      _themeType.value == CustomThemeType.dark ||
      _themeType.value == CustomThemeType.professional;
  bool get isProfessional => _themeType.value == CustomThemeType.professional;

  // Professional theme colors
  Color get primaryColor {
    switch (_themeType.value) {
      case CustomThemeType.professional:
        return const Color(0xFF1E3A8A); // Deep blue
      case CustomThemeType.dark:
        return Colors.blue;
      case CustomThemeType.light:
        return Colors.blue;
      case CustomThemeType.system:
        return Colors.blue;
    }
  }

  Color get accentColor {
    switch (_themeType.value) {
      case CustomThemeType.professional:
        return const Color(0xFFF59E0B); // Amber
      case CustomThemeType.dark:
        return Colors.blue[300]!;
      case CustomThemeType.light:
        return Colors.blue[600]!;
      case CustomThemeType.system:
        return Colors.blue;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  /// تحميل الثيم من التخزين
  void _loadTheme() {
    try {
      final savedTheme = StorageService.instance.getString('theme_mode');

      if (savedTheme != null && savedTheme.isNotEmpty) {
        switch (savedTheme) {
          case 'light':
            _themeType.value = CustomThemeType.light;
            break;
          case 'dark':
            _themeType.value = CustomThemeType.dark;
            break;
          case 'professional':
            _themeType.value = CustomThemeType.professional;
            break;
          default:
            _themeType.value = CustomThemeType.system;
        }
      } else {
        _themeType.value = CustomThemeType.system;
      }
    } catch (e) {
      // في حالة وجود خطأ، استخدم الثيم الافتراضي
      _themeType.value = CustomThemeType.system;
    }
  }

  /// تغيير الثيم
  Future<void> setThemeType(CustomThemeType type) async {
    _themeType.value = type;

    String modeString;
    switch (type) {
      case CustomThemeType.light:
        modeString = 'light';
        break;
      case CustomThemeType.dark:
        modeString = 'dark';
        break;
      case CustomThemeType.professional:
        modeString = 'professional';
        break;
      case CustomThemeType.system:
        modeString = 'system';
        break;
    }

    await StorageService.instance.setString('theme_mode', modeString);
    Get.changeThemeMode(themeMode);
  }

  /// تبديل الثيم
  Future<void> toggleTheme() async {
    if (_themeType.value == CustomThemeType.light) {
      await setThemeType(CustomThemeType.dark);
    } else {
      await setThemeType(CustomThemeType.light);
    }
  }
}
