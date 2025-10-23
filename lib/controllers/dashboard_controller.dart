import 'package:get/get.dart';
import 'package:routy/screens/dashboard/dashboard_models.dart';
import 'package:routy/utils/app_logger.dart';
import 'package:flutter/material.dart';

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

      // محاكاة تأخير API
      await Future.delayed(const Duration(seconds: 1));

      // بيانات تجريبية - يجب استبدالها ببيانات حقيقية من API
      stats.value = _generateMockStats();
      recentActivities.value = _generateMockActivities();

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

  // ==================== Mock Data Generators ====================

  DashboardStatsEnhanced _generateMockStats() {
    final now = DateTime.now();
    return DashboardStatsEnhanced(
      todaySales: 45000,
      weekSales: 280000,
      monthSales: 850000,
      todayOrders: 12,
      weekOrders: 78,
      monthOrders: 245,
      activeCustomers: 156,
      totalCustomers: 320,
      target: 1000000,
      salesTrend: List.generate(7, (index) {
        final date = now.subtract(Duration(days: 6 - index));
        final baseValue = 100000 + (index * 20000);
        final randomVariation = (index % 2 == 0 ? 1.2 : 0.8);
        return ChartDataPoint(
          date: date,
          value: baseValue * randomVariation,
          label: _getDayLabel(date.weekday),
        );
      }),
    );
  }

  String _getDayLabel(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(weekday - 1) % 7];
  }

  List<ActivityModelEnhanced> _generateMockActivities() {
    final now = DateTime.now();
    return [
      ActivityModelEnhanced(
        id: '1',
        title: 'New Sale Created',
        subtitle: 'Sale #SO001 - 12,500 Dhs',
        timestamp: now.subtract(const Duration(hours: 2)),
        type: ActivityType.sale,
        color: Colors.green,
        icon: Icons.shopping_cart,
      ),
      ActivityModelEnhanced(
        id: '2',
        title: 'New Customer Added',
        subtitle: 'Ahmed Alami - Rabat',
        timestamp: now.subtract(const Duration(hours: 4)),
        type: ActivityType.customer,
        color: Colors.blue,
        icon: Icons.person_add,
      ),
      ActivityModelEnhanced(
        id: '3',
        title: 'Product Updated',
        subtitle: 'iPhone 15 Pro - Stock: 25',
        timestamp: now.subtract(const Duration(hours: 6)),
        type: ActivityType.product,
        color: Colors.orange,
        icon: Icons.inventory,
      ),
      ActivityModelEnhanced(
        id: '4',
        title: 'Delivery Completed',
        subtitle: 'Delivery #DEL123 to Casablanca',
        timestamp: now.subtract(const Duration(hours: 8)),
        type: ActivityType.delivery,
        color: Colors.purple,
        icon: Icons.local_shipping,
      ),
      ActivityModelEnhanced(
        id: '5',
        title: 'Payment Received',
        subtitle: 'Payment of 8,500 Dhs',
        timestamp: now.subtract(const Duration(days: 1)),
        type: ActivityType.payment,
        color: Colors.teal,
        icon: Icons.payment,
      ),
    ];
  }

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
          route: '/products',
        ),
        const QuickActionData(
          title: 'Sales',
          icon: Icons.shopping_cart,
          color: Colors.green,
          route: '/sales',
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
