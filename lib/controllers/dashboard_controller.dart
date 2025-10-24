import 'package:get/get.dart';
import 'package:routy/screens/dashboard/dashboard_models.dart';
import 'package:routy/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:routy/app/app_router.dart';

/// 📊 Dashboard Controller - إدارة لوحة التحكم
class DashboardController extends GetxController {
  // ==================== Singleton ====================
  static DashboardController get instance => Get.find<DashboardController>();

  // ==================== Observable State ====================

  /// حالة التحميل
  final isLoading = false.obs;

  /// حالة التحديث
  final isRefreshing = false.obs;

  /// إحصائيات Dashboard
  final stats = DashboardStatsEnhanced().obs;

  /// الأنشطة الأخيرة
  final recentActivities = <ActivityModelEnhanced>[].obs;

  /// رسالة الخطأ
  final Rx<String?> errorMessage = Rx<String?>(null);

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    try {
      appLogger.info('🚀 Initializing DashboardController...');
      await loadDashboardData();
      appLogger.info('✅ DashboardController initialized');
    } catch (e) {
      appLogger.error('Failed to initialize DashboardController', error: e);
    }
  }

  // ==================== Data Loading ====================

  /// تحميل بيانات Dashboard
  Future<void> loadDashboardData({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      errorMessage.value = null;

      // TODO: استبدال هذا ببيانات حقيقية من API
      // يجب تنفيذ استدعاء API حقيقي هنا
      // مثال: final response = await Api.searchRead(...)

      // تهيئة البيانات الفارغة
      stats.value = DashboardStatsEnhanced();
      recentActivities.value = [];

      appLogger.info('✅ Dashboard data loaded successfully');
    } catch (e) {
      errorMessage.value = 'Failed to load dashboard data';
      appLogger.error('Error loading dashboard data', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث البيانات (Pull to Refresh)
  Future<void> refreshDashboard() async {
    try {
      isRefreshing.value = true;
      await loadDashboardData(showLoading: false);
      appLogger.info('✅ Dashboard refreshed');
    } finally {
      isRefreshing.value = false;
    }
  }

  // ==================== Real Data Loading ====================

  // TODO: تنفيذ استدعاءات API حقيقية هنا
  // يجب إضافة دوال لتحميل البيانات الحقيقية من السيرفر

  // ==================== Getters ====================

  /// KPI Cards Data
  List<KpiCardData> get kpiCards => [
    KpiCardData(
      title: 'Today Sales',
      value: '${(stats.value.todaySales / 1000).toStringAsFixed(1)}K Dhs',
      subtitle: '${stats.value.todayOrders} orders',
      icon: Icons.today,
      color: Colors.blue,
      progress: stats.value.todaySales / (stats.value.target / 30),
      trend: '+12%',
      isPositiveTrend: true,
    ),
    KpiCardData(
      title: 'Week Sales',
      value: '${(stats.value.weekSales / 1000).toStringAsFixed(1)}K Dhs',
      subtitle: '${stats.value.weekOrders} orders',
      icon: Icons.date_range,
      color: Colors.green,
      progress: stats.value.weekSales / (stats.value.target / 4),
      trend: '+8%',
      isPositiveTrend: true,
    ),
    KpiCardData(
      title: 'Month Sales',
      value: '${(stats.value.monthSales / 1000).toStringAsFixed(1)}K Dhs',
      subtitle:
          '${(stats.value.progressPercentage * 100).toStringAsFixed(1)}% of target',
      icon: Icons.calendar_month,
      color: Colors.orange,
      progress: stats.value.progressPercentage,
      trend: '+15%',
      isPositiveTrend: true,
    ),
  ];

  /// Quick Actions Data
  List<QuickActionData> get quickActions => [
    const QuickActionData(
      title: 'Products',
      icon: Icons.inventory_2,
      color: Colors.red,
      route: AppRouter.productsGrid,
    ),
    const QuickActionData(
      title: 'Sales',
      icon: Icons.shopping_cart,
      color: Colors.green,
      route: '/sales',
    ),
    const QuickActionData(
      title: 'Create Order',
      icon: Icons.add_shopping_cart,
      color: Colors.green,
      route: '/sales/create/new',
    ),
    const QuickActionData(
      title: 'Draft Orders',
      icon: Icons.drafts,
      color: Colors.orange,
      route: '/sales/drafts',
    ),
    const QuickActionData(
      title: 'Customers',
      icon: Icons.people,
      color: Colors.blue,
      route: '/partners/customers',
    ),
    const QuickActionData(
      title: 'Suppliers',
      icon: Icons.store,
      color: Colors.orange,
      route: '/partners/suppliers',
    ),
    const QuickActionData(
      title: 'Partners',
      icon: Icons.business_center,
      color: Colors.indigo,
      route: '/partners',
    ),
    const QuickActionData(
      title: 'Map',
      icon: Icons.map,
      color: Colors.teal,
      route: '/partners/map',
    ),
    const QuickActionData(
      title: 'Reports',
      icon: Icons.analytics,
      color: Colors.deepPurple,
      route: '/reports',
    ),
    const QuickActionData(
      title: 'Settings',
      icon: Icons.settings,
      color: Colors.blueGrey,
      route: '/settings',
    ),
  ];

  @override
  void onClose() {
    appLogger.info('🔴 Closing DashboardController');
    super.onClose();
  }
}
