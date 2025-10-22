import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../services/translation_service.dart';

/// Translation Controller using GetX
class TranslationController extends GetxController {
  // Observable locale
  final Rx<Locale> _locale = const Locale('fr', 'FR').obs;

  // Getter
  Locale get locale => _locale.value;
  String get currentLanguage => _locale.value.languageCode;

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  /// تحميل اللغة من التخزين
  void _loadLanguage() {
    final savedLang = StorageService.instance.getString('app_language') ?? 'fr';
    changeLanguage(savedLang);
  }

  /// تغيير اللغة
  Future<void> changeLanguage(String languageCode) async {
    Locale newLocale;

    switch (languageCode) {
      case 'ar':
        newLocale = const Locale('ar', 'MA');
        break;
      case 'en':
        newLocale = const Locale('en', 'US');
        break;
      case 'es':
        newLocale = const Locale('es', 'ES');
        break;
      default:
        newLocale = const Locale('fr', 'FR');
    }

    _locale.value = newLocale;
    await TranslationService.instance.changeLanguage(languageCode);
    await StorageService.instance.setString('app_language', languageCode);

    // Update GetX locale
    Get.updateLocale(newLocale);
  }

  /// جلب الترجمة
  String translate(String key) {
    return TranslationService.instance.translate(key);
  }

  /// جلب الترجمة بمعاملات
  String translateWithParams(String key, Map<String, String> params) {
    String translation = translate(key);
    params.forEach((param, value) {
      translation = translation.replaceAll('{$param}', value);
    });
    return translation;
  }
}
