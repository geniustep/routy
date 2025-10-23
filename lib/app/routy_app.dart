import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:routy/screens/dashboard/dashboard_screen.dart';
import '../themes/index.dart';
import '../services/index.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../controllers/index.dart';
import '../l10n/app_localizations.dart';
import 'app_router.dart';

class RoutyApp extends StatelessWidget {
  const RoutyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize GetX controllers
    Get.put(UserController());
    Get.put(ThemeController());
    Get.put(TranslationController());
    Get.put(SyncManager());

    return GetMaterialApp(
      title: 'Routy',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: Get.find<ThemeController>().themeMode,
      home: const SplashScreen(),
      getPages: AppRouter.pages,
      debugShowCheckedModeBanner: false,
      locale: Get.find<TranslationController>().locale,
      fallbackLocale: const Locale('fr', 'FR'),

      // ✅ إضافة دعم AppLocalizations
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''),
        Locale('en', ''),
        Locale('fr', ''),
        Locale('es', ''),
      ],
    );
  }
}

/// Auth Wrapper to check login status
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      // التحقق من حالة تسجيل الدخول
      final isLoggedInFlag = StorageService.instance.getIsLoggedIn();

      // التحقق من وجود بيانات المستخدم الفعلية
      final userData = StorageService.instance.getUser();
      final hasUserData = userData != null && userData.isNotEmpty;

      // المستخدم مسجل دخول فقط إذا كان كلا الشرطين صحيحين
      final isLoggedIn = isLoggedInFlag && hasUserData;

      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    return _isLoggedIn ? const DashboardScreen() : const LoginScreen();
  }
}
