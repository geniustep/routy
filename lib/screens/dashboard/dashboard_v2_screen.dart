import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:routy/controllers/dashboard_controller.dart';
import 'package:routy/controllers/theme_controller.dart';
import 'package:routy/controllers/user_controller.dart';
import 'package:routy/services/translation_service.dart';
import 'package:routy/app/app_router.dart';
import 'package:routy/screens/dashboard/widgets/dashboard_widgets.dart';

/// 🎨 Enhanced Dashboard Screen V2
///
/// Features:
/// - ✅ Responsive Design (Mobile, Tablet, Desktop)
/// - ✅ Real-time Charts (fl_chart)
/// - ✅ Animated Statistics
/// - ✅ Glassmorphism UI
/// - ✅ Pull-to-Refresh
/// - ✅ Skeleton Loading
/// - ✅ RTL/LTR Support
/// - ✅ Dark Mode Optimized
class DashboardV2Screen extends StatelessWidget {
  const DashboardV2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashController = Get.put(DashboardController());
    final themeController = Get.find<ThemeController>();
    final userController = Get.find<UserController>();

    return Obx(() {
      if (!userController.isLoggedIn) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(AppRouter.login);
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: themeController.isDarkMode
              ? const Color(0xFF0D1117)
              : const Color(0xFFF5F7FA),
          appBar: _buildAppBar(themeController, userController),
          body: RefreshIndicator(
            onRefresh: dashController.refreshDashboard,
            color: themeController.primaryColor,
            child: dashController.isLoading.value
                ? _buildLoadingSkeleton(context, themeController.isDarkMode)
                : _buildContent(context, dashController, themeController),
          ),
        ),
      );
    });
  }

  /// App Bar
  PreferredSizeWidget _buildAppBar(ThemeController theme, UserController user) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.isDarkMode
          ? const Color(0xFF161B22)
          : theme.primaryColor,
      title: Row(
        children: [
          Icon(Icons.dashboard, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            TranslationService.instance.translate('dashboard'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Get.toNamed(AppRouter.settings),
          icon: const Icon(Icons.settings, color: Colors.white),
        ),
        IconButton(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout, color: Colors.white),
        ),
      ],
    );
  }

  /// Content
  Widget _buildContent(
    BuildContext context,
    DashboardController controller,
    ThemeController theme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        final isTablet =
            constraints.maxWidth > 600 && constraints.maxWidth <= 900;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              _buildWelcomeHeader(theme),
              SizedBox(height: isDesktop ? 32 : 24),

              // KPI Cards
              _buildKpiSection(context, controller, theme, isDesktop, isTablet),
              SizedBox(height: isDesktop ? 32 : 24),

              // Sales Chart
              _buildSalesChartSection(controller, theme),
              SizedBox(height: isDesktop ? 32 : 24),

              // Quick Actions & Recent Activity
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildQuickActionsSection(
                        context,
                        controller,
                        theme,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildRecentActivitySection(controller, theme),
                    ),
                  ],
                )
              else ...[
                _buildQuickActionsSection(context, controller, theme),
                SizedBox(height: isDesktop ? 32 : 24),
                _buildRecentActivitySection(controller, theme),
              ],

              SizedBox(height: isDesktop ? 32 : 100),
            ],
          ),
        );
      },
    );
  }

  /// Loading Skeleton
  Widget _buildLoadingSkeleton(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ShimmerLoadingCard(height: 120, width: double.infinity),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: ShimmerLoadingCard(height: 150)),
              const SizedBox(width: 16),
              Expanded(child: ShimmerLoadingCard(height: 150)),
              const SizedBox(width: 16),
              Expanded(child: ShimmerLoadingCard(height: 150)),
            ],
          ),
          const SizedBox(height: 24),
          ShimmerLoadingCard(height: 300, width: double.infinity),
          const SizedBox(height: 24),
          ShimmerLoadingCard(height: 200, width: double.infinity),
        ],
      ),
    );
  }

  /// Welcome Header
  Widget _buildWelcomeHeader(ThemeController theme) {
    final userController = Get.find<UserController>();

    return Obx(() {
      final userName = userController.userName.isNotEmpty
          ? userController.userName
          : 'User';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.isDarkMode
                ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                : [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.waving_hand, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    TranslationService.instance.translate('welcome_back'),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              userName.toUpperCase(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              TranslationService.instance.translate('ready_to_achieve'),
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      );
    });
  }

  /// KPI Section
  Widget _buildKpiSection(
    BuildContext context,
    DashboardController controller,
    ThemeController theme,
    bool isDesktop,
    bool isTablet,
  ) {
    return Obx(() {
      final cards = controller.kpiCards;

      if (isDesktop) {
        return Row(
          children: cards
              .map(
                (card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: EnhancedKpiCard(
                      data: card,
                      isDarkMode: theme.isDarkMode,
                    ),
                  ),
                ),
              )
              .toList(),
        );
      } else if (isTablet) {
        return Column(
          children: [
            Row(
              children: cards
                  .take(2)
                  .map(
                    (card) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: EnhancedKpiCard(
                          data: card,
                          isDarkMode: theme.isDarkMode,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            EnhancedKpiCard(data: cards[2], isDarkMode: theme.isDarkMode),
          ],
        );
      } else {
        return Column(
          children: cards
              .map(
                (card) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: EnhancedKpiCard(
                    data: card,
                    isDarkMode: theme.isDarkMode,
                  ),
                ),
              )
              .toList(),
        );
      }
    });
  }

  /// Sales Chart Section
  Widget _buildSalesChartSection(
    DashboardController controller,
    ThemeController theme,
  ) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.isDarkMode ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.isDarkMode
                ? const Color(0xFF30363D)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: theme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  TranslationService.instance.translate('sales_trend'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  'Last 7 Days',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.isDarkMode ? Colors.white60 : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(height: 250, child: _buildSalesChart(controller, theme)),
          ],
        ),
      );
    });
  }

  /// Sales Chart
  Widget _buildSalesChart(
    DashboardController controller,
    ThemeController theme,
  ) {
    final salesData = controller.stats.value.salesTrend;

    if (salesData.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(
            color: theme.isDarkMode ? Colors.white60 : Colors.grey[600],
          ),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < salesData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      salesData[value.toInt()].label,
                      style: TextStyle(
                        color: theme.isDarkMode
                            ? Colors.white60
                            : Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 50000,
              reservedSize: 50,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '${(value / 1000).toInt()}K',
                  style: TextStyle(
                    color: theme.isDarkMode ? Colors.white60 : Colors.grey[600],
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: theme.isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        minX: 0,
        maxX: salesData.length.toDouble() - 1,
        minY: 0,
        maxY:
            salesData.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: salesData
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                .toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.6)],
            ),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: theme.primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.primaryColor.withOpacity(0.3),
                  theme.primaryColor.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) =>
                theme.isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem(
                  '${(barSpot.y / 1000).toStringAsFixed(1)}K Dhs',
                  TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  /// Quick Actions Section
  Widget _buildQuickActionsSection(
    BuildContext context,
    DashboardController controller,
    ThemeController theme,
  ) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.isDarkMode ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.isDarkMode
                ? const Color(0xFF30363D)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: theme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  TranslationService.instance.translate('quick_actions'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int crossAxisCount;

                if (width < 400) {
                  crossAxisCount = 2;
                } else if (width < 600) {
                  crossAxisCount = 3;
                } else {
                  crossAxisCount = 4;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: controller.quickActions.length,
                  itemBuilder: (context, index) {
                    final action = controller.quickActions[index];
                    return EnhancedQuickActionCard(
                      data: action,
                      onTap: () => Get.toNamed(action.route),
                      isDarkMode: theme.isDarkMode,
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    });
  }

  /// Recent Activity Section
  Widget _buildRecentActivitySection(
    DashboardController controller,
    ThemeController theme,
  ) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.isDarkMode ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.isDarkMode
                ? const Color(0xFF30363D)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.history, color: theme.primaryColor, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      TranslationService.instance.translate('recent_activity'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    TranslationService.instance.translate('view_all'),
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...controller.recentActivities
                .take(5)
                .map(
                  (activity) => EnhancedActivityItem(
                    activity: activity,
                    isDarkMode: theme.isDarkMode,
                  ),
                ),
          ],
        ),
      );
    });
  }

  /// Handle Logout
  Future<void> _handleLogout() async {
    final userController = Get.find<UserController>();

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
            child: Text(
              TranslationService.instance.translate('logout'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final success = await userController.logout();
      if (success) {
        Get.offAllNamed(AppRouter.login);
      }
    }
  }
}
