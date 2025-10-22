import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Trans;
import '../../services/index.dart';
import '../../common/services/api_service.dart';
import '../../controllers/index.dart';
import '../../app/app_router.dart';
import '../../utils/app_logger.dart';
import '../../services/translation_service.dart';
import '../../controllers/partner_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedLanguage = 'fr';
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _autoSync = true;
  double _fontSize = 16.0;

  final List<Map<String, dynamic>> _languages = [
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇲🇦'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSettings();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    // تحميل الإعدادات المحفوظة
    final currentLanguage = TranslationService.instance.getCurrentLanguage();
    setState(() {
      _selectedLanguage = currentLanguage;
    });
  }

  void _saveLanguage(String language) async {
    setState(() {
      _selectedLanguage = language;
    });
    await TranslationService.instance.setLanguage(language);
    HapticFeedback.lightImpact();
  }

  void _saveThemeType(CustomThemeType type) {
    final themeController = Get.find<ThemeController>();
    themeController.setThemeType(type);
    HapticFeedback.lightImpact();
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          TranslationService.instance.translate('language'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((lang) {
            return ListTile(
              leading: Text(lang['flag'], style: const TextStyle(fontSize: 24)),
              title: Text(
                lang['name'],
                style: const TextStyle(color: Colors.white),
              ),
              trailing: _selectedLanguage == lang['code']
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                _saveLanguage(lang['code']);
                Get.back();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    final themeController = Get.find<ThemeController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          TranslationService.instance.translate('theme'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              TranslationService.instance.translate('light_theme'),
              CustomThemeType.light,
              Icons.light_mode,
              themeController,
            ),
            _buildThemeOption(
              TranslationService.instance.translate('dark_theme'),
              CustomThemeType.dark,
              Icons.dark_mode,
              themeController,
            ),
            _buildThemeOption(
              TranslationService.instance.translate('professional_theme'),
              CustomThemeType.professional,
              Icons.business,
              themeController,
            ),
            _buildThemeOption(
              TranslationService.instance.translate('system_theme'),
              CustomThemeType.system,
              Icons.settings,
              themeController,
            ),
            const SizedBox(height: 16),
            _buildThemePreviewCard(themeController),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    String title,
    CustomThemeType type,
    IconData icon,
    ThemeController themeController,
  ) {
    final isSelected = themeController.themeType == type;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.blue.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.blue : Colors.white),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check, color: Colors.blue)
            : null,
        onTap: () {
          _saveThemeType(type);
          Get.back();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      return Scaffold(
        backgroundColor: themeController.isDarkMode
            ? Colors.grey[900]
            : Colors.grey[50],
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(themeController),
                  _buildSettingsContent(themeController),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAppBar(ThemeController themeController) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: themeController.isDarkMode
                  ? [const Color(0xFF1a1a1a), const Color(0xFF2d2d2d)]
                  : [Colors.blue[600]!, Colors.blue[400]!],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.settings,
                  size: 40,
                  color: themeController.isDarkMode
                      ? Colors.white
                      : Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  'Paramètres',
                  style: TextStyle(
                    color: themeController.isDarkMode
                        ? Colors.white
                        : Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(ThemeController themeController) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildLanguageSection(themeController),
          const SizedBox(height: 20),
          _buildThemeSection(),
          const SizedBox(height: 20),
          _buildNotificationSection(themeController),
          const SizedBox(height: 20),
          _buildLocationSection(themeController),
          const SizedBox(height: 20),
          _buildSyncSection(themeController),
          const SizedBox(height: 20),
          _buildDisplaySection(themeController),
          const SizedBox(height: 20),
          _buildAboutSection(themeController),
        ]),
      ),
    );
  }

  Widget _buildLanguageSection(ThemeController themeController) {
    return _buildSectionCard(
      title: 'Langue',
      icon: Icons.language,
      themeController: themeController,
      children: [
        _buildSettingTile(
          title: 'Langue de l\'application',
          subtitle: _languages.firstWhere(
            (lang) => lang['code'] == _selectedLanguage,
          )['name'],
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showLanguageDialog,
          themeController: themeController,
        ),
      ],
    );
  }

  Widget _buildThemeSection() {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      return _buildSectionCard(
        title: 'Apparence',
        icon: Icons.palette,
        themeController: themeController,
        children: [
          _buildSettingTile(
            title: 'Thème',
            subtitle: _getThemeName(themeController.themeType),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showThemeDialog,
            themeController: themeController,
          ),
          _buildThemePreview(themeController),
          const SizedBox(height: 16),
          _buildThemePreviewCard(themeController),
        ],
      );
    });
  }

  Widget _buildThemePreview(ThemeController themeController) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Changer le thème',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildThemePreviewItem(
                'Clair',
                CustomThemeType.light,
                themeController,
              ),
              const SizedBox(width: 12),
              _buildThemePreviewItem(
                'Sombre',
                CustomThemeType.dark,
                themeController,
              ),
              const SizedBox(width: 12),
              _buildThemePreviewItem(
                'Auto',
                CustomThemeType.system,
                themeController,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildThemePreviewItem(
                'Professionnel',
                CustomThemeType.professional,
                themeController,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemePreviewItem(
    String label,
    CustomThemeType type,
    ThemeController themeController,
  ) {
    final isSelected = themeController.themeType == type;
    return GestureDetector(
      onTap: () {
        _saveThemeType(type);
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? themeController.primaryColor.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? themeController.primaryColor
                : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type == CustomThemeType.light
                  ? Icons.light_mode
                  : type == CustomThemeType.dark
                  ? Icons.dark_mode
                  : type == CustomThemeType.professional
                  ? Icons.business
                  : Icons.settings,
              color: isSelected ? themeController.primaryColor : Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? themeController.primaryColor : Colors.grey,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePreviewCard(ThemeController themeController) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeController.isProfessional
              ? const Color(0xFF1E1B4B) // Deep professional background
              : themeController.isDarkMode
              ? Colors.grey[800]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeController.isProfessional
                ? themeController.primaryColor
                : themeController.isDarkMode
                ? Colors.grey[600]!
                : Colors.grey[300]!,
            width: themeController.isProfessional ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: themeController.isProfessional
                      ? themeController.accentColor
                      : themeController.isDarkMode
                      ? Colors.blue[300]
                      : Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dashboard',
                  style: TextStyle(
                    color: themeController.isProfessional
                        ? Colors.white
                        : themeController.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: themeController.isDarkMode
                        ? Colors.blue[700]
                        : Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    themeController.isProfessional
                        ? 'Professionnel'
                        : themeController.isDarkMode
                        ? 'Sombre'
                        : 'Clair',
                    style: TextStyle(
                      color: themeController.isDarkMode
                          ? Colors.white
                          : Colors.blue[800],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeController.isDarkMode
                    ? Colors.grey[700]
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: themeController.isDarkMode
                      ? Colors.grey[600]!
                      : Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue',
                    style: TextStyle(
                      color: themeController.isDarkMode
                          ? Colors.white70
                          : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'UTILISATEUR',
                    style: TextStyle(
                      color: themeController.isDarkMode
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: themeController.isDarkMode
                              ? Colors.blue[300]
                              : Colors.blue[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '70%',
                        style: TextStyle(
                          color: themeController.isDarkMode
                              ? Colors.blue[300]
                              : Colors.blue[600],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aperçu en temps réel du thème sélectionné',
              style: TextStyle(
                color: themeController.isDarkMode
                    ? Colors.white60
                    : Colors.grey[500],
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNotificationSection(ThemeController themeController) {
    return _buildSectionCard(
      title: 'Notifications',
      icon: Icons.notifications,
      themeController: themeController,
      children: [
        _buildSwitchTile(
          title: 'Notifications push',
          subtitle: 'Recevoir des notifications importantes',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
            HapticFeedback.lightImpact();
          },
          themeController: themeController,
        ),
      ],
    );
  }

  Widget _buildLocationSection(ThemeController themeController) {
    return _buildSectionCard(
      title: 'Localisation',
      icon: Icons.location_on,
      themeController: themeController,
      children: [
        _buildSwitchTile(
          title: 'Géolocalisation',
          subtitle: 'Autoriser l\'accès à la position',
          value: _locationEnabled,
          onChanged: (value) {
            setState(() {
              _locationEnabled = value;
            });
            HapticFeedback.lightImpact();
          },
          themeController: themeController,
        ),
      ],
    );
  }

  Widget _buildSyncSection(ThemeController themeController) {
    return _buildSectionCard(
      title: 'Synchronisation',
      icon: Icons.sync,
      themeController: themeController,
      children: [
        _buildSwitchTile(
          title: 'Synchronisation automatique',
          subtitle: 'Synchroniser les données automatiquement',
          value: _autoSync,
          onChanged: (value) {
            setState(() {
              _autoSync = value;
            });
            HapticFeedback.lightImpact();
          },
          themeController: themeController,
        ),
        _buildSettingTile(
          title: 'Synchroniser maintenant',
          subtitle: 'Forcer la synchronisation des données',
          trailing: const Icon(Icons.sync, color: Colors.blue),
          onTap: () async {
            HapticFeedback.lightImpact();

            // عرض رسالة التحميل
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Synchronisation en cours...'),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 2),
              ),
            );

            try {
              // الحصول على PartnerController أو إنشاؤه
              final partnerController = Get.find<PartnerController>();

              // تحميل العملاء من التخزين المحلي أولاً
              await partnerController.loadPartnersFromStorage();

              // جلب العملاء الجدد من الخادم
              await partnerController.fetchPartners(
                page: 1,
                pageSize: 100,
                showLoading: false,
              );

              // عرض رسالة النجاح
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Synchronisation terminée! ${partnerController.partners.length} clients chargés',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }

              appLogger.info(
                '✅ Manual sync completed successfully - ${partnerController.partners.length} partners loaded',
              );
            } catch (e) {
              // عرض رسالة الخطأ
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur de synchronisation: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }

              appLogger.error('❌ Manual sync failed', error: e);
            }
          },
          themeController: themeController,
        ),
      ],
    );
  }

  Widget _buildDisplaySection(ThemeController themeController) {
    return _buildSectionCard(
      title: 'Affichage',
      icon: Icons.text_fields,
      themeController: themeController,
      children: [
        _buildSettingTile(
          title: 'Taille de police',
          subtitle: '${_fontSize.toInt()}px',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showFontSizeDialog();
          },
          themeController: themeController,
        ),
      ],
    );
  }

  Widget _buildAboutSection(ThemeController themeController) {
    return _buildSectionCard(
      title: 'À propos',
      icon: Icons.info,
      themeController: themeController,
      children: [
        _buildSettingTile(
          title: 'Version',
          subtitle: '1.0.0',
          trailing: null,
          onTap: null,
          themeController: themeController,
        ),
        _buildSettingTile(
          title: 'Conditions d\'utilisation',
          subtitle: 'Lire les conditions',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            HapticFeedback.lightImpact();
          },
          themeController: themeController,
        ),
        _buildSettingTile(
          title: 'Politique de confidentialité',
          subtitle: 'Lire la politique',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            HapticFeedback.lightImpact();
          },
          themeController: themeController,
        ),
        _buildSettingTile(
          title: 'Déconnexion',
          subtitle: 'Se déconnecter et effacer les données',
          trailing: const Icon(Icons.logout, color: Colors.red),
          onTap: () {
            _showLogoutDialog();
          },
          themeController: themeController,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required ThemeController themeController,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: themeController.isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeController.isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: themeController.isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: themeController.isDarkMode
                      ? Colors.white.withValues(alpha: 0.8)
                      : Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: themeController.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback? onTap,
    required ThemeController themeController,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: themeController.isDarkMode ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: themeController.isDarkMode
              ? Colors.white.withValues(alpha: 0.7)
              : Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeController themeController,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: themeController.isDarkMode ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: themeController.isDarkMode
              ? Colors.white.withValues(alpha: 0.7)
              : Colors.grey[600],
          fontSize: 14,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.blue,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  String _getThemeName(CustomThemeType type) {
    switch (type) {
      case CustomThemeType.light:
        return 'Clair';
      case CustomThemeType.dark:
        return 'Sombre';
      case CustomThemeType.professional:
        return 'Professionnel';
      case CustomThemeType.system:
        return 'Système';
    }
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Taille de police',
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_fontSize.toInt()}px',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Slider(
                  value: _fontSize,
                  min: 12,
                  max: 24,
                  divisions: 12,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      _fontSize = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        this.setState(() {
                          _fontSize = _fontSize;
                        });
                        Get.back();
                        HapticFeedback.lightImpact();
                      },
                      child: const Text(
                        'Appliquer',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ? Toutes les données locales seront effacées.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _handleLogout();
            },
            child: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final userController = Get.find<UserController>();

    // عرض dialog للتأكيد
    final shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        // 1. إنهاء الجلسة من الخادم
        await ApiService.instance.logout();

        // 2. مسح جميع البيانات المحلية باستخدام UserController
        final success = await userController.logout();

        // 3. الانتقال لصفحة تسجيل الدخول
        if (success) {
          appLogger.navigation(AppRouter.login, from: AppRouter.settings);
          Get.offAllNamed(AppRouter.login);
        } else {
          Get.snackbar(
            'خطأ',
            'حدث خطأ أثناء تسجيل الخروج',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e, stackTrace) {
        appLogger.error('Logout error', error: e, stackTrace: stackTrace);

        // في حالة فشل API، نمسح البيانات المحلية فقط
        final success = await userController.logout();

        if (success) {
          appLogger.navigation(AppRouter.login, from: AppRouter.settings);
          Get.offAllNamed(AppRouter.login);
        } else {
          Get.snackbar(
            'خطأ',
            'حدث خطأ أثناء تسجيل الخروج',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    }
  }
}
