import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routy/controllers/index.dart';
import 'package:routy/app/app_router.dart';
import 'package:routy/utils/pref_utils.dart';
import 'package:routy/config/responsive/responsive_design.dart';
import 'package:routy/config/responsive/responsive_components.dart';
import 'package:routy/config/responsive/responsive_fonts.dart';
import 'package:routy/services/translation_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final themeController = Get.find<ThemeController>();

    // تحقق من حالة تسجيل الدخول
    if (!userController.isLoggedIn || userController.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRouter.login);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // عرض نافذة تأكيد
          final shouldExit = await _showExitDialog(context);
          if (shouldExit == true && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Obx(() {
        return Scaffold(
          backgroundColor: themeController.isDarkMode
              ? Colors.grey[900]
              : themeController.isProfessional
              ? const Color(0xFF0F172A)
              : Colors.grey[50],
          appBar: AppBar(
            title: Text(
              TranslationService.instance.translate('dashboard'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    themeController.isDarkMode || themeController.isProfessional
                    ? Colors.white
                    : Colors.white,
              ),
            ),
            backgroundColor: themeController.isProfessional
                ? themeController.primaryColor
                : themeController.isDarkMode
                ? Colors.grey[800]
                : Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () => Get.toNamed(AppRouter.settings),
                icon: const Icon(Icons.settings),
              ),
              IconButton(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16), // ✅ استخدام padding ثابت
            child: Column(
              children: [
                // Welcome Section
                _buildWelcomeSection(),
                const SizedBox(height: 16),

                // Today Reports Section
                _buildTodayReportsSection(),
                const SizedBox(height: 16),

                // Quick Actions Grid
                _buildQuickActionsGrid(),
                const SizedBox(height: 16),

                // Recent Activity Section
                _buildRecentActivitySection(),
                const SizedBox(height: 16),

                // Banner Section
                _buildBannerSection(),
                const SizedBox(height: 16), // ✅ مساحة إضافية في النهاية
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeSection() {
    final userController = Get.find<UserController>();
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      // استخدام PrefUtils كـ fallback
      final userName = userController.userName.isNotEmpty
          ? userController.userName
          : PrefUtils.user.value?.name ?? 'User';

      return Builder(
        builder: (context) => ResponsiveComponents.createResponsiveCard(
          context: context,
          child: Container(
            width: double.infinity,
            padding: ResponsiveDesign.getPadding(context),
            decoration: BoxDecoration(
              gradient: themeController.isProfessional
                  ? LinearGradient(
                      colors: [
                        themeController.primaryColor,
                        themeController.primaryColor.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : themeController.isDarkMode
                  ? const LinearGradient(
                      colors: [Colors.grey, Colors.grey],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Colors.blue, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: themeController.isProfessional
                      ? themeController.primaryColor.withValues(alpha: 0.3)
                      : Colors.blue.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.waving_hand,
                      color: themeController.isProfessional
                          ? themeController.accentColor
                          : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      TranslationService.instance.translate('welcome_back'),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  userName.toUpperCase(),
                  style: ResponsiveFonts.getHeadingStyle(
                    context,
                  ).copyWith(color: Colors.white, letterSpacing: 1.2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  themeController.isProfessional
                      ? TranslationService.instance.translate(
                          'ready_to_achieve',
                        )
                      : TranslationService.instance.translate(
                          'whats_happening_today',
                        ),
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTodayReportsSection() {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      return Card(
        elevation: themeController.isProfessional ? 8 : 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: themeController.isDarkMode
            ? Colors.grey[800]
            : themeController.isProfessional
            ? const Color(0xFF1E1B4B)
            : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: themeController.isProfessional
                            ? themeController.accentColor
                            : themeController.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        TranslationService.instance.translate('today_reports'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              themeController.isDarkMode ||
                                  themeController.isProfessional
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: null,
                    child: Text(
                      TranslationService.instance.translate('view_all'),
                      style: TextStyle(
                        color: themeController.isProfessional
                            ? themeController.accentColor
                            : themeController.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildReportCard(
                      title: TranslationService.instance.translate('target'),
                      value: '1M Dhs',
                      icon: Icons.track_changes,
                      color: Colors.blue,
                      progress: 0.7,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildReportCard(
                      title: TranslationService.instance.translate('sales'),
                      value: '700K Dhs',
                      icon: Icons.shopping_bag,
                      color: Colors.green,
                      progress: 0.7,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildReportCard(
                      title: TranslationService.instance.translate('progress'),
                      value: '70%',
                      icon: Icons.trending_up,
                      color: Colors.orange,
                      progress: 0.7,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildReportCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    final themeController = Get.find<ThemeController>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeController.isProfessional
            ? color.withValues(alpha: 0.15)
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeController.isProfessional
              ? color.withValues(alpha: 0.4)
              : color.withValues(alpha: 0.3),
          width: themeController.isProfessional ? 2 : 1,
        ),
        boxShadow: themeController.isProfessional
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color:
                    themeController.isDarkMode || themeController.isProfessional
                    ? Colors.white70
                    : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 3,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final themeController = Get.find<ThemeController>();

    final actions = [
      _QuickAction(
        title: TranslationService.instance.translate('products'),
        icon: Icons.inventory_2,
        color: Colors.red,
        route: '/products',
      ),
      _QuickAction(
        title: TranslationService.instance.translate('sales'),
        icon: Icons.shopping_cart,
        color: Colors.green,
        route: '/sales',
      ),
      _QuickAction(
        title: TranslationService.instance.translate('customers'),
        icon: Icons.people,
        color: Colors.blue,
        route: '/customers',
      ),
      _QuickAction(
        title: TranslationService.instance.translate('reports'),
        icon: Icons.analytics,
        color: Colors.orange,
        route: '/reports',
      ),
      _QuickAction(
        title: TranslationService.instance.translate('expenses'),
        icon: Icons.money_off,
        color: Colors.purple,
        route: '/expenses',
      ),
      _QuickAction(
        title: TranslationService.instance.translate('pos'),
        icon: Icons.point_of_sale,
        color: Colors.pink,
        route: '/pos',
      ),
      _QuickAction(
        title: TranslationService.instance.translate('purchase'),
        icon: Icons.local_mall,
        color: Colors.blueGrey,
        route: '/purchase',
      ),
      _QuickAction(
        title: TranslationService.instance.translate('warehouse'),
        icon: Icons.warehouse,
        color: Colors.teal,
        route: '/warehouse',
      ),
    ];

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: themeController.isProfessional
                    ? themeController.accentColor
                    : themeController.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                TranslationService.instance.translate('quick_actions'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      themeController.isDarkMode ||
                          themeController.isProfessional
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              // تحديد عدد الأعمدة بناءً على عرض الشاشة
              final screenWidth = MediaQuery.of(context).size.width;
              int crossAxisCount;

              if (screenWidth < 600) {
                crossAxisCount = 2; // للهواتف - عمودان
              } else if (screenWidth < 900) {
                crossAxisCount = 3; // للتابلت - 3 أعمدة
              } else if (screenWidth < 1200) {
                crossAxisCount = 4; // للكمبيوتر الصغير - 4 أعمدة
              } else {
                crossAxisCount = 6; // للكمبيوتر الكبير - 6 أعمدة
              }

              return GridView.count(
                shrinkWrap: true, // ✅ إضافة هذا
                physics: const NeverScrollableScrollPhysics(), // ✅ إضافة هذا
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.0,
                mainAxisSpacing: 12, // ✅ استخدام قيم ثابتة
                crossAxisSpacing: 12, // ✅ استخدام قيم ثابتة
                children: actions
                    .map((action) => _buildQuickActionCard(action))
                    .toList(),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildQuickActionCard(_QuickAction action) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      return GestureDetector(
        onTap: () {
          Get.toNamed(action.route);
        },
        child: Container(
          padding: const EdgeInsets.all(12), // ✅ تقليل من 16 إلى 12
          decoration: BoxDecoration(
            color: themeController.isProfessional
                ? action.color.withValues(alpha: 0.15)
                : action.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12), // ✅ تقليل من 16 إلى 12
            border: Border.all(
              color: themeController.isProfessional
                  ? action.color.withValues(alpha: 0.4)
                  : action.color.withValues(alpha: 0.3),
              width: themeController.isProfessional
                  ? 1
                  : 1, // ✅ تقليل من 2 إلى 1
            ),
            boxShadow: themeController.isProfessional
                ? [
                    BoxShadow(
                      color: action.color.withValues(alpha: 0.2),
                      blurRadius: 4, // ✅ تقليل من 6 إلى 4
                      offset: const Offset(0, 1), // ✅ تقليل من 2 إلى 1
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8), // ✅ تقليل من 12 إلى 8
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8), // ✅ تقليل من 12 إلى 8
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 24,
                ), // ✅ تقليل من 28 إلى 24
              ),
              const SizedBox(height: 8), // ✅ تقليل من 12 إلى 8
              Flexible(
                child: Text(
                  action.title,
                  style: TextStyle(
                    fontSize: 10, // ✅ تقليل من 12 إلى 10
                    fontWeight: FontWeight.w600,
                    color:
                        themeController.isDarkMode ||
                            themeController.isProfessional
                        ? Colors.white
                        : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRecentActivitySection() {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      return Card(
        elevation: themeController.isProfessional ? 8 : 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: themeController.isDarkMode
            ? Colors.grey[800]
            : themeController.isProfessional
            ? const Color(0xFF1E1B4B)
            : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: themeController.isProfessional
                            ? themeController.accentColor
                            : themeController.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        TranslationService.instance.translate(
                          'recent_activity',
                        ),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              themeController.isDarkMode ||
                                  themeController.isProfessional
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: null,
                    child: Text(
                      TranslationService.instance.translate('view_all'),
                      style: TextStyle(
                        color: themeController.isProfessional
                            ? themeController.accentColor
                            : themeController.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildActivityItem(
                icon: Icons.shopping_cart,
                title: TranslationService.instance.translate(
                  'new_sale_created',
                ),
                subtitle: 'Sale #SO001 - 2,500 Dhs',
                time: '2h ago',
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildActivityItem(
                icon: Icons.person_add,
                title: TranslationService.instance.translate(
                  'new_customer_added',
                ),
                subtitle: 'Ahmed Alami - Rabat',
                time: '4h ago',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildActivityItem(
                icon: Icons.inventory,
                title: TranslationService.instance.translate('product_updated'),
                subtitle: 'iPhone 15 Pro - Stock: 25',
                time: '6h ago',
                color: Colors.orange,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeController.isProfessional
                  ? color.withValues(alpha: 0.2)
                  : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: themeController.isProfessional
                  ? Border.all(color: color.withValues(alpha: 0.3), width: 1)
                  : null,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        themeController.isDarkMode ||
                            themeController.isProfessional
                        ? Colors.white
                        : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        themeController.isDarkMode ||
                            themeController.isProfessional
                        ? Colors.white70
                        : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 10,
              color:
                  themeController.isDarkMode || themeController.isProfessional
                  ? Colors.white60
                  : Colors.grey[500],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    });
  }

  Widget _buildBannerSection() {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      return Card(
        elevation: themeController.isProfessional ? 8 : 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: themeController.isProfessional
                ? LinearGradient(
                    colors: [
                      themeController.primaryColor.withValues(alpha: 0.1),
                      themeController.accentColor.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Colors.blue.withValues(alpha: 0.1),
                      Colors.purple.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(20),
            border: themeController.isProfessional
                ? Border.all(
                    color: themeController.primaryColor.withValues(alpha: 0.3),
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.trending_up,
                color: themeController.isProfessional
                    ? themeController.accentColor
                    : Colors.orange,
                size: 36,
              ),
              const SizedBox(height: 16),
              Text(
                themeController.isProfessional
                    ? TranslationService.instance.translate('business_insights')
                    : TranslationService.instance.translate(
                        'performance_overview',
                      ),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      themeController.isDarkMode ||
                          themeController.isProfessional
                      ? Colors.white
                      : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                themeController.isProfessional
                    ? TranslationService.instance.translate(
                        'track_business_growth',
                      )
                    : TranslationService.instance.translate(
                        'monitor_sales_performance',
                      ),
                style: TextStyle(
                  fontSize: 14,
                  color:
                      themeController.isDarkMode ||
                          themeController.isProfessional
                      ? Colors.white70
                      : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(AppRouter.settings);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeController.isProfessional
                      ? themeController.primaryColor
                      : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  TranslationService.instance.translate('view_analytics'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<bool?> _showExitDialog(BuildContext context) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text(TranslationService.instance.translate('confirm_exit')),
        content: Text(
          TranslationService.instance.translate('exit_confirmation'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(TranslationService.instance.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(TranslationService.instance.translate('exit')),
          ),
        ],
      ),
    );
  }

  void _handleLogout() async {
    final userController = Get.find<UserController>();

    // عرض dialog للتأكيد
    final shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        title: Text(TranslationService.instance.translate('confirm_logout')),
        content: Text(
          TranslationService.instance.translate('logout_confirmation'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(TranslationService.instance.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(TranslationService.instance.translate('logout')),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // مسح بيانات المستخدم من PrefUtils + UserController
      await PrefUtils.clearAll();
      final success = await userController.logout();

      if (success) {
        // التنقل إلى صفحة تسجيل الدخول
        Get.offAllNamed(AppRouter.login);
      } else {
        // عرض رسالة خطأ إذا فشل المسح
        Get.snackbar(
          TranslationService.instance.translate('error'),
          TranslationService.instance.translate('logout_error'),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}

class _QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  _QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}
