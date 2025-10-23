import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:routy/app/index.dart';
import 'package:routy/common/api/api.dart';
import 'package:routy/common/services/api_service.dart';
import 'package:routy/config/core/app_config.dart';
import 'package:routy/config/core/design_tokens.dart';
import 'package:routy/services/storage_service.dart';
import 'package:routy/services/translation_service.dart';
import 'package:routy/utils/app_logger.dart';
import 'package:routy/controllers/theme_controller.dart';
import 'package:routy/controllers/translation_controller.dart';
import 'package:routy/controllers/user_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _databaseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  List<String> _availableDatabases = [];

  // Animation Controllers
  late AnimationController _mainAnimationController;
  late AnimationController _logoAnimationController;
  late AnimationController _particlesAnimationController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _particlesAnimation;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'done';
    _passwordController.text = ',,07Genius';
    _databaseController.text = 'done2026';
    _setupAnimations();
    _loadVersionInfo(); // سيستدعي _loadAvailableDatabases تلقائياً
  }

  void _setupAnimations() {
    // Main animation
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainAnimationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    // Logo animation
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _logoRotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Particles animation
    _particlesAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _particlesAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particlesAnimationController);

    // Start animations
    _mainAnimationController.forward();
    _logoAnimationController.forward();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _logoAnimationController.dispose();
    _particlesAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _databaseController.dispose();
    super.dispose();
  }

  Future<void> _loadVersionInfo() async {
    try {
      await Api.getVersionInfo(
        onResponse: (response) async {
          if (response.serverVersion != null && mounted) {
            if (kDebugMode) {
              appLogger.info('Version Info: ${response.serverVersion}');
            }
            await _loadAvailableDatabases(
              serverVersionNumber: response.serverVersionInfo?[0],
            );
          }
        },
        onError: (error, data) {
          if (kDebugMode) {
            appLogger.info('Error loading version info: $error');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        appLogger.info('Error loading version info: $e');
      }
    }
  }

  Future<void> _loadAvailableDatabases({int? serverVersionNumber}) async {
    try {
      // فحص إذا كانت البيانات محفوظة مسبقاً
      final savedDatabases = StorageService.instance.getString(
        'available_databases',
      );
      if (savedDatabases != null && savedDatabases.isNotEmpty) {
        try {
          final databases = List<String>.from(jsonDecode(savedDatabases));
          if (mounted) {
            setState(() {
              _availableDatabases = databases;
            });
          }
          appLogger.info(
            '📦 Using cached databases: ${databases.length} items → ${databases.join(", ")}',
          );
          return;
        } catch (e) {
          appLogger.warning('Error parsing cached databases: $e');
        }
      }

      // جلب من الخادم إذا لم تكن في الكاش

      await Api.getDatabases(
        serverVersionNumber: serverVersionNumber ?? 18,
        onResponse: (response) async {
          if (response.serverVersion != null && mounted) {
            if (kDebugMode) {
              appLogger.info('Version Info: ${response.serverVersion}');
            }
            if (mounted) {
              setState(() {
                _availableDatabases = response.data ?? [];
              });
            }
            appLogger.info(
              '🌐 Fetched databases: ${response.data?.length ?? 0} items → ${response.data?.join(", ") ?? ""}',
            );
            await StorageService.instance.setString(
              'available_databases',
              jsonEncode(response.data!),
            );
          }
        },
        onError: (error, data) {
          if (kDebugMode) {
            appLogger.info('Error loading version info: $error');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        appLogger.info('Error loading databases: $e');
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      appLogger.apiRequest(
        'POST',
        'authenticate',
        data: {
          'username': _emailController.text.trim(),
          'database': _databaseController.text.trim(),
        },
      );

      await ApiService.instance.login(
        username: _emailController.text.trim(),
        password: _passwordController.text,
        database: _databaseController.text.trim(),
        onResponse: (response) async {
          if (kDebugMode) {
            appLogger.info('Login response: ${response.db}');
          }
          appLogger.info('✅ Login successful');
          appLogger.userAction(
            'Login',
            details: {
              'username': _emailController.text.trim(),
              'database': _databaseController.text.trim(),
            },
          );
          appLogger.debug(
            '📥 Login response: success=${response.db}, data=${response.name}',
          );

          // تحديث UserController
          final userController = Get.find<UserController>();
          await userController.setUser(response);
          appLogger.info('✅ UserController updated');

          if (mounted) {
            HapticFeedback.lightImpact();
            appLogger.navigation(AppRouter.dashboard, from: AppRouter.login);
            Get.offAllNamed(AppRouter.dashboard);
          }
        },
        onError: (error, data) {
          if (kDebugMode) {
            appLogger.info('Error logging in: $error');
          }
        },
      );
    } catch (e) {
      appLogger.warning('⚠️ Login failed');
      _showError(TranslationService.instance.translate('loginError'));
      _showError('Erreur: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    HapticFeedback.heavyImpact();
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TranslationService.instance.translate('language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('ar', 'العربية', '🇲🇦'),
            _buildLanguageOption('fr', 'Français', '🇫🇷'),
            _buildLanguageOption('en', 'English', '🇺🇸'),
            _buildLanguageOption('es', 'Español', '🇪🇸'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String flag) {
    final translationController = Get.find<TranslationController>();
    final isSelected = translationController.currentLanguage == code;

    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        translationController.changeLanguage(code);
        Navigator.of(context).pop();
        setState(() {}); // تحديث الواجهة
      },
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TranslationService.instance.translate('theme')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              'light',
              TranslationService.instance.translate('light_theme'),
              Icons.light_mode,
            ),
            _buildThemeOption(
              'dark',
              TranslationService.instance.translate('dark_theme'),
              Icons.dark_mode,
            ),
            _buildThemeOption(
              'professional',
              TranslationService.instance.translate('professional_theme'),
              Icons.business,
            ),
            _buildThemeOption(
              'system',
              TranslationService.instance.translate('system_theme'),
              Icons.settings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme, String name, IconData icon) {
    final themeController = Get.find<ThemeController>();
    final isSelected = themeController.themeType.name == theme;

    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        switch (theme) {
          case 'light':
            themeController.setThemeType(CustomThemeType.light);
            break;
          case 'dark':
            themeController.setThemeType(CustomThemeType.dark);
            break;
          case 'professional':
            themeController.setThemeType(CustomThemeType.professional);
            break;
          case 'system':
            themeController.setThemeType(CustomThemeType.system);
            break;
        }
        Navigator.of(context).pop();
        setState(() {}); // تحديث الواجهة
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(isDark),

          // Floating Particles
          _buildFloatingParticles(isDark),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 60.0 : 24.0,
                  vertical: 20.0,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 540 : double.infinity,
                      ),
                      child: Column(
                        children: [
                          _buildLoginCard(isDark),
                          const SizedBox(height: 20),
                          _buildControlButtons(isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر الترجمة
          Container(
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _showLanguageDialog,
              icon: Icon(
                Icons.language,
                color: isDark ? Colors.white : Colors.black87,
                size: 22,
              ),
              tooltip: TranslationService.instance.translate('language'),
            ),
          ),
          const SizedBox(width: 12),
          // زر التيم
          Container(
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _showThemeDialog,
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.white : Colors.black87,
                size: 22,
              ),
              tooltip: TranslationService.instance.translate('theme'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _particlesAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      DesignTokens.darkBackgroundColor,
                      DesignTokens.darkSurfaceColor,
                      DesignTokens.darkBackgroundColor,
                    ]
                  : [
                      DesignTokens.backgroundColor,
                      Colors.white,
                      DesignTokens.backgroundColor,
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles(bool isDark) {
    return AnimatedBuilder(
      animation: _particlesAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(12, (index) {
            final offset = (index * 0.083 + _particlesAnimation.value) % 1.0;
            final horizontalOffset = (index * 41) % 100;

            return Positioned(
              top: MediaQuery.of(context).size.height * offset,
              left:
                  MediaQuery.of(context).size.width * (horizontalOffset / 100),
              child: Opacity(
                opacity: isDark ? 0.08 : 0.12,
                child: Container(
                  width: 6 + (index % 3) * 3,
                  height: 6 + (index % 3) * 3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        isDark
                            ? DesignTokens.darkPrimaryColor
                            : DesignTokens.primaryColor,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildLoginCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius * 2),
        border: Border.all(
          color: isDark
              ? DesignTokens.darkPrimaryColor.withValues(alpha: 0.2)
              : DesignTokens.primaryColor.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : DesignTokens.primaryColor.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -5,
          ),
          if (!isDark)
            BoxShadow(
              color: DesignTokens.secondaryColor.withValues(alpha: 0.05),
              blurRadius: 60,
              offset: const Offset(0, 30),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius * 2),
        child: Stack(
          children: [
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            DesignTokens.darkPrimaryColor.withValues(
                              alpha: 0.03,
                            ),
                            Colors.transparent,
                          ]
                        : [
                            DesignTokens.primaryColor.withValues(alpha: 0.02),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(48.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAnimatedLogo(isDark),
                    const SizedBox(height: 48),
                    _buildWelcomeText(isDark),
                    const SizedBox(height: 56),
                    _buildEmailField(isDark),
                    const SizedBox(height: 28),
                    _buildPasswordField(isDark),
                    const SizedBox(height: 28),
                    _buildDatabaseField(isDark),
                    const SizedBox(height: 40),
                    _buildErrorMessage(isDark),
                    _buildLoginButton(isDark),
                    const SizedBox(height: 32),
                    _buildFooter(isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo(bool isDark) {
    return ScaleTransition(
      scale: _logoScaleAnimation,
      child: RotationTransition(
        turns: _logoRotationAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Shimmer effect
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _particlesAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(
                            -1.0 + (_particlesAnimation.value * 2),
                            0,
                          ),
                          end: Alignment(
                            1.0 + (_particlesAnimation.value * 2),
                            0,
                          ),
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Logo - فقط الصورة بدون نص
              Center(
                child: Image.asset(
                  'assets/logo/logo_routy.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.route_rounded,
                      size: 70,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),

      child: Text(
        TranslationService.instance.translate('loginSubtitle'),
        style: TextStyle(
          fontSize: DesignTokens.getFontSize(FontType.body),
          color: isDark
              ? DesignTokens.darkPrimaryColor
              : DesignTokens.primaryColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEmailField(bool isDark) {
    return _buildModernTextField(
      controller: _emailController,
      label: TranslationService.instance.translate('usernameLabel'),
      icon: Icons.person_outline_rounded,
      keyboardType: TextInputType.emailAddress,
      isDark: isDark,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return TranslationService.instance.translate('usernameRequired');
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return _buildModernTextField(
      controller: _passwordController,
      label: TranslationService.instance.translate('passwordLabel'),
      icon: Icons.lock_outline_rounded,
      obscureText: _obscurePassword,
      isDark: isDark,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded,
          color: isDark
              ? DesignTokens.darkPrimaryColor.withValues(alpha: 0.7)
              : DesignTokens.primaryColor.withValues(alpha: 0.7),
          size: 26,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
          HapticFeedback.selectionClick();
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return TranslationService.instance.translate('passwordRequired');
        }
        if (value.length < 3) {
          return TranslationService.instance.translate('passwordMinLength');
        }
        return null;
      },
    );
  }

  Widget _buildDatabaseField(bool isDark) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.borderRadius * 2),
        color: isDark
            ? DesignTokens.darkBackgroundColor.withValues(alpha: 0.3)
            : DesignTokens.backgroundColor.withValues(alpha: 0.5),
        border: Border.all(
          color: isDark
              ? DesignTokens.darkPrimaryColor.withValues(alpha: 0.3)
              : DesignTokens.primaryColor.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isDark
                        ? DesignTokens.darkPrimaryColor
                        : DesignTokens.primaryColor)
                    .withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _availableDatabases.contains(_databaseController.text)
            ? _databaseController.text.trim()
            : (_availableDatabases.isNotEmpty
                  ? _availableDatabases.first
                  : null),
        decoration: InputDecoration(
          labelText: TranslationService.instance.translate('databaseLabel'),
          labelStyle: TextStyle(
            color: isDark
                ? DesignTokens.darkPrimaryColor.withValues(alpha: 0.7)
                : DesignTokens.primaryColor.withValues(alpha: 0.7),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: TextStyle(
            color: isDark
                ? DesignTokens.darkPrimaryColor
                : DesignTokens.primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(right: 12, left: 12),
            child: Icon(
              Icons.storage_rounded,
              color: isDark
                  ? DesignTokens.darkPrimaryColor.withValues(alpha: 0.8)
                  : DesignTokens.primaryColor.withValues(alpha: 0.8),
              size: 26,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
        dropdownColor: isDark ? DesignTokens.darkSurfaceColor : Colors.white,
        style: TextStyle(
          inherit: false,
          color: isDark ? DesignTokens.darkTextColor : DesignTokens.textColor,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          textBaseline: TextBaseline.alphabetic,
        ),
        items: _availableDatabases.map((String database) {
          return DropdownMenuItem<String>(
            value: database,
            child: Text(
              database,
              style: TextStyle(
                color: isDark
                    ? DesignTokens.darkTextColor
                    : DesignTokens.textColor,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _databaseController.text = newValue;
            });
          }
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return TranslationService.instance.translate('databaseRequired');
          }
          return null;
        },
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 64, // خانات كبيرة
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.borderRadius * 2),
        color: isDark
            ? DesignTokens.darkBackgroundColor.withValues(alpha: 0.3)
            : DesignTokens.backgroundColor.withValues(alpha: 0.5),
        border: Border.all(
          color: isDark
              ? DesignTokens.darkPrimaryColor.withValues(alpha: 0.3)
              : DesignTokens.primaryColor.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isDark
                        ? DesignTokens.darkPrimaryColor
                        : DesignTokens.primaryColor)
                    .withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          inherit: false,
          color: isDark ? DesignTokens.darkTextColor : DesignTokens.textColor,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          textBaseline: TextBaseline.alphabetic,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark
                ? DesignTokens.darkPrimaryColor.withValues(alpha: 0.7)
                : DesignTokens.primaryColor.withValues(alpha: 0.7),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: TextStyle(
            color: isDark
                ? DesignTokens.darkPrimaryColor
                : DesignTokens.primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(right: 12, left: 12),
            child: Icon(
              icon,
              color: isDark
                  ? DesignTokens.darkPrimaryColor.withValues(alpha: 0.8)
                  : DesignTokens.primaryColor.withValues(alpha: 0.8),
              size: 26,
            ),
          ),
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffixIcon,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          filled: false,
        ),
      ),
    );
  }

  Widget _buildErrorMessage(bool isDark) {
    if (_errorMessage == null) return const SizedBox.shrink();

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 28),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade400.withValues(alpha: 0.15),
                    Colors.red.shade500.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  DesignTokens.borderRadius * 1.5,
                ),
                border: Border.all(
                  color: Colors.red.shade400.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: DesignTokens.buttonHeight * 1.3, // زر كبير
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.buttonRadius * 2),
        gradient: _isLoading
            ? null
            : LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  isDark
                      ? DesignTokens.darkPrimaryColor
                      : DesignTokens.primaryColor,
                  isDark
                      ? DesignTokens.darkSecondaryColor
                      : DesignTokens.secondaryColor,
                ],
              ),
        boxShadow: _isLoading
            ? null
            : [
                BoxShadow(
                  color:
                      (isDark
                              ? DesignTokens.darkPrimaryColor
                              : DesignTokens.primaryColor)
                          .withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLoading
              ? (isDark
                    ? Colors.grey.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.3))
              : Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.buttonRadius * 2),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? DesignTokens.darkTextColor : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    TranslationService.instance.translate('loading'),
                    style: TextStyle(
                      inherit: false,
                      color: isDark ? DesignTokens.darkTextColor : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                ],
              )
            : Text(
                TranslationService.instance.translate('loginButton'),
                style: const TextStyle(
                  inherit: false,
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (isDark
                        ? DesignTokens.darkPrimaryColor
                        : DesignTokens.primaryColor)
                    .withValues(alpha: 0.1),
                (isDark
                        ? DesignTokens.darkSecondaryColor
                        : DesignTokens.secondaryColor)
                    .withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            TranslationService.instance.translate('version'),
            style: TextStyle(
              color: isDark
                  ? DesignTokens.darkPrimaryColor
                  : DesignTokens.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          TranslationService.instance.translate('copyright'),
          style: TextStyle(
            color: isDark
                ? DesignTokens.darkTextColor.withValues(alpha: 0.5)
                : DesignTokens.textColor.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
