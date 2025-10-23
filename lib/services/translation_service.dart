import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routy/utils/app_logger.dart';
import 'storage_service.dart';

/// الثوابت الأساسية للترجمة
class _TranslationConstants {
  static const List<String> supportedLanguages = ['fr', 'ar', 'en', 'es'];
}

/// خدمة الترجمة المتقدمة مع البناء التلقائي
class TranslationService {
  static TranslationService? _instance;
  static TranslationService get instance =>
      _instance ??= TranslationService._();

  TranslationService._();

  Map<String, Map<String, String>> _translations = {};
  String _currentLanguage = 'fr';
  bool _isInitialized = false;

  /// تهيئة خدمة الترجمة
  Future<void> initialize() async {
    if (_isInitialized) return;

    // جلب اللغة المحفوظة
    _currentLanguage = StorageService.instance.getLanguage();

    // تحميل الترجمات
    await _loadTranslations();

    _isInitialized = true;
  }

  /// تحميل جميع الترجمات
  Future<void> _loadTranslations() async {
    for (String language in _TranslationConstants.supportedLanguages) {
      try {
        final translations = await _loadLanguageFile(language);
        _translations[language] = translations;
      } catch (e) {
        if (kDebugMode) {
          appLogger.info('Error loading translations for $language: $e');
        }
        // استخدام الترجمات الافتراضية في حالة الخطأ
        _translations[language] = _getDefaultTranslations(language);
      }
    }
  }

  /// تحميل ملف ترجمة لغة معينة
  Future<Map<String, String>> _loadLanguageFile(String language) async {
    try {
      Map<String, String> allTranslations = {};

      // تحميل ملف الترجمة الموحد
      final file = 'assets/translations/app_$language.arb';

      try {
        final String content = await rootBundle.loadString(file);
        final Map<String, dynamic> jsonMap = json.decode(content);

        // تحويل الترجمات
        jsonMap.forEach((key, value) {
          if (key.startsWith('@')) return; // تجاهل المفاتيح الوصفية
          if (value is String) {
            allTranslations[key] = value;
          }
        });
      } catch (e) {
        if (kDebugMode) appLogger.info('Error loading $file: $e');
      }

      return allTranslations;
    } catch (e) {
      if (kDebugMode) {
        appLogger.info('Error loading translations for $language: $e');
      }
      return _getDefaultTranslations(language);
    }
  }

  /// الترجمات الافتراضية لكل لغة
  Map<String, String> _getDefaultTranslations(String language) {
    switch (language) {
      case 'fr':
        return {
          'appTitle': 'Routy',
          'welcome': 'Bienvenue dans Routy',
          'sales': 'Ventes',
          'delivery': 'Livraison',
          'invoices': 'Factures',
          'customers': 'Clients',
          'products': 'Produits',
          'settings': 'Paramètres',
          'language': 'Langue',
          'logout': 'Déconnexion',
          // ترجمات تسجيل الدخول
          'loginTitle': 'Routy',
          'loginSubtitle': 'Gestion des Ventes et Livraisons',
          'usernameLabel': 'Nom d\'utilisateur',
          'passwordLabel': 'Mot de passe',
          'databaseLabel': 'Base de données',
          'loginButton': 'Se connecter',
          'usernameRequired': 'Veuillez saisir votre nom d\'utilisateur',
          'passwordRequired': 'Veuillez saisir votre mot de passe',
          'passwordMinLength':
              'Le mot de passe doit contenir au moins 3 caractères',
          'databaseRequired': 'Veuillez saisir le nom de la base de données',
          'loginError': 'Erreur de connexion',
          'version': 'Version 1.0.0',
          'copyright': '© 2024 Routy. Tous droits réservés.',
        };
      case 'ar':
        return {
          'appTitle': 'روتي',
          'welcome': 'مرحباً بك في روتي',
          'sales': 'المبيعات',
          'delivery': 'التسليم',
          'invoices': 'الفواتير',
          'customers': 'العملاء',
          'products': 'المنتجات',
          'settings': 'الإعدادات',
          'language': 'اللغة',
          'logout': 'تسجيل الخروج',
          // ترجمات تسجيل الدخول
          'loginTitle': 'روتي',
          'loginSubtitle': 'إدارة المبيعات والتسليم',
          'usernameLabel': 'اسم المستخدم',
          'passwordLabel': 'كلمة المرور',
          'databaseLabel': 'قاعدة البيانات',
          'loginButton': 'تسجيل الدخول',
          'usernameRequired': 'يرجى إدخال اسم المستخدم',
          'passwordRequired': 'يرجى إدخال كلمة المرور',
          'passwordMinLength': 'يجب أن تتكون كلمة المرور من 3 أحرف على الأقل',
          'databaseRequired': 'يرجى إدخال اسم قاعدة البيانات',
          'loginError': 'خطأ في الاتصال',
          'version': 'الإصدار 1.0.0',
          'copyright': '© 2024 روتي. جميع الحقوق محفوظة.',
        };
      case 'en':
        return {
          'appTitle': 'Routy',
          'welcome': 'Welcome to Routy',
          'sales': 'Sales',
          'delivery': 'Delivery',
          'invoices': 'Invoices',
          'customers': 'Customers',
          'products': 'Products',
          'settings': 'Settings',
          'language': 'Language',
          'logout': 'Logout',
          // ترجمات تسجيل الدخول
          'loginTitle': 'Routy',
          'loginSubtitle': 'Sales and Delivery Management',
          'usernameLabel': 'Username',
          'passwordLabel': 'Password',
          'databaseLabel': 'Database',
          'loginButton': 'Login',
          'usernameRequired': 'Please enter your username',
          'passwordRequired': 'Please enter your password',
          'passwordMinLength': 'Password must be at least 3 characters long',
          'databaseRequired': 'Please enter the database name',
          'loginError': 'Connection error',
          'version': 'Version 1.0.0',
          'copyright': '© 2024 Routy. All rights reserved.',
        };
      case 'es':
        return {
          'appTitle': 'Routy',
          'welcome': 'Bienvenido a Routy',
          'sales': 'Ventas',
          'delivery': 'Entrega',
          'invoices': 'Facturas',
          'customers': 'Clientes',
          'products': 'Productos',
          'settings': 'Configuración',
          'language': 'Idioma',
          'logout': 'Cerrar sesión',
          // ترجمات تسجيل الدخول
          'loginTitle': 'Routy',
          'loginSubtitle': 'Gestión de Ventas y Entregas',
          'usernameLabel': 'Nombre de usuario',
          'passwordLabel': 'Contraseña',
          'databaseLabel': 'Base de datos',
          'loginButton': 'Iniciar sesión',
          'usernameRequired': 'Por favor, ingrese su nombre de usuario',
          'passwordRequired': 'Por favor, ingrese su contraseña',
          'passwordMinLength': 'La contraseña debe tener al menos 3 caracteres',
          'databaseRequired':
              'Por favor, ingrese el nombre de la base de datos',
          'loginError': 'Error de conexión',
          'version': 'Versión 1.0.0',
          'copyright': '© 2024 Routy. Todos los derechos reservados.',
        };
      default:
        return _getDefaultTranslations('fr');
    }
  }

  /// الحصول على الترجمة
  String translate(String key, {Map<String, String>? params}) {
    if (!_isInitialized) {
      if (kDebugMode) appLogger.info('TranslationService not initialized');
      return key;
    }

    final languageTranslations = _translations[_currentLanguage];
    if (languageTranslations == null) {
      if (kDebugMode) {
        appLogger.info('No translations found for language: $_currentLanguage');
      }
      return key;
    }

    String translation = languageTranslations[key] ?? key;

    // استبدال المعاملات
    if (params != null) {
      params.forEach((paramKey, value) {
        translation = translation.replaceAll('{$paramKey}', value);
      });
    }

    return translation;
  }

  /// تغيير اللغة
  Future<void> setLanguage(String language) async {
    if (!_TranslationConstants.supportedLanguages.contains(language)) {
      if (kDebugMode) appLogger.info('Unsupported language: $language');
      return;
    }

    _currentLanguage = language;
    await StorageService.instance.saveLanguage(language);

    // إعادة تحميل الترجمات
    await _loadTranslations();
  }

  /// الحصول على اللغة الحالية
  String get currentLanguage => _currentLanguage;
  String getCurrentLanguage() => _currentLanguage;

  /// تغيير اللغة
  Future<void> changeLanguage(String languageCode) async {
    if (!_TranslationConstants.supportedLanguages.contains(languageCode)) {
      return;
    }

    _currentLanguage = languageCode;
    await StorageService.instance.saveLanguage(languageCode);

    // إعادة تحميل الترجمات للغة الجديدة إذا لم تكن محملة
    if (!_translations.containsKey(languageCode)) {
      try {
        final translations = await _loadLanguageFile(languageCode);
        _translations[languageCode] = translations;
      } catch (e) {
        if (kDebugMode) {
          appLogger.info('Error loading translations for $languageCode: $e');
        }
        _translations[languageCode] = _getDefaultTranslations(languageCode);
      }
    }
  }

  /// الحصول على قائمة اللغات المدعومة
  List<String> get supportedLanguages =>
      _TranslationConstants.supportedLanguages;

  /// التحقق من وجود ترجمة
  bool hasTranslation(String key) {
    final languageTranslations = _translations[_currentLanguage];
    return languageTranslations?.containsKey(key) ?? false;
  }

  /// إضافة ترجمة جديدة ديناميكياً
  Future<void> addTranslation(
    String key,
    String value, {
    String? language,
  }) async {
    final targetLanguage = language ?? _currentLanguage;

    if (!_translations.containsKey(targetLanguage)) {
      _translations[targetLanguage] = {};
    }

    _translations[targetLanguage]![key] = value;

    // حفظ في التخزين المحلي
    await _saveTranslationsToStorage(targetLanguage);
  }

  /// حفظ الترجمات في التخزين المحلي
  Future<void> _saveTranslationsToStorage(String language) async {
    final translations = _translations[language];
    if (translations != null) {
      await StorageService.instance.saveSetting(
        'translations_$language',
        translations,
      );
    }
  }

  /// تصدير الترجمات
  Map<String, Map<String, String>> exportTranslations() {
    return Map.from(_translations);
  }

  /// استيراد الترجمات
  Future<void> importTranslations(
    Map<String, Map<String, String>> translations,
  ) async {
    _translations = Map.from(translations);

    // حفظ في التخزين المحلي
    for (String language in translations.keys) {
      await _saveTranslationsToStorage(language);
    }
  }

  /// إعادة تعيين الترجمات
  Future<void> resetTranslations() async {
    _translations.clear();
    await _loadTranslations();
  }

  /// الحصول على إحصائيات الترجمة
  Map<String, int> getTranslationStats() {
    Map<String, int> stats = {};

    for (String language in _translations.keys) {
      stats[language] = _translations[language]?.length ?? 0;
    }

    return stats;
  }

  /// البحث في الترجمات
  List<String> searchTranslations(String query) {
    List<String> results = [];

    for (String language in _translations.keys) {
      final translations = _translations[language];
      if (translations != null) {
        translations.forEach((key, value) {
          if (key.toLowerCase().contains(query.toLowerCase()) ||
              value.toLowerCase().contains(query.toLowerCase())) {
            results.add('$language: $key = $value');
          }
        });
      }
    }

    return results;
  }
}

/// مساعدات الترجمة السريعة
class T {
  static TranslationService get _service => TranslationService.instance;

  /// ترجمة سريعة
  static String _(String key, {Map<String, String>? params}) {
    return _service.translate(key, params: params);
  }

  /// ترجمة مع معاملات
  static String withParams(String key, Map<String, String> params) {
    return _service.translate(key, params: params);
  }

  /// التحقق من وجود ترجمة
  static bool has(String key) {
    return _service.hasTranslation(key);
  }
}

/// مساعدات الترجمة للواجهات
class TranslationHelper {
  /// الحصول على اتجاه النص
  static TextDirection getTextDirection(String language) {
    switch (language) {
      case 'ar':
        return TextDirection.rtl;
      default:
        return TextDirection.ltr;
    }
  }

  /// الحصول على اتجاه النص للغة الحالية
  static TextDirection getCurrentTextDirection() {
    return getTextDirection(TranslationService.instance.currentLanguage);
  }

  /// التحقق من اللغة العربية
  static bool isArabic() {
    return TranslationService.instance.currentLanguage == 'ar';
  }

  /// التحقق من اللغة الفرنسية
  static bool isFrench() {
    return TranslationService.instance.currentLanguage == 'fr';
  }

  /// التحقق من اللغة الإنجليزية
  static bool isEnglish() {
    return TranslationService.instance.currentLanguage == 'en';
  }

  /// التحقق من اللغة الإسبانية
  static bool isSpanish() {
    return TranslationService.instance.currentLanguage == 'es';
  }
}

/// مساعدات الترجمة للواجهات
class LocalizedWidget extends StatelessWidget {
  final String textKey;
  final Map<String, String>? params;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const LocalizedWidget(
    this.textKey, {
    super.key,
    this.params,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      T._(textKey, params: params),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
