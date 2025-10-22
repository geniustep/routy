import 'package:routy/common/index.dart';
import 'package:routy/screens/dashboard/dashboard_models.dart';
import 'package:routy/services/storage_service.dart';

class DashboardApiService {
  static final DashboardApiService _instance = DashboardApiService._internal();
  factory DashboardApiService() => _instance;
  DashboardApiService._internal();

  // Get dashboard summary
  Future<BaseResponse<DashboardSummary>> getDashboardSummary() async {
    try {
      // This would typically call a real API endpoint
      // For now, we'll return mock data
      final summary = DashboardSummary(
        totalSales: '24',
        totalDeliveries: '18',
        totalCustomers: '156',
        totalRevenue: '2,450€',
        todayTarget: '1,000,000 Dhs',
        todaySales: '700,000 Dhs',
        todayProgress: '70%',
        recentActivityCount: 4,
      );

      return BaseResponse.success(data: summary, statusCode: 200);
    } catch (e) {
      return BaseResponse.error(
        error: 'Failed to load dashboard summary: $e',
        statusCode: 500,
      );
    }
  }

  // Get today's reports
  Future<BaseResponse<TodayReport>> getTodayReports() async {
    try {
      // This would typically call a real API endpoint
      // For now, we'll return mock data
      final report = TodayReport(
        target: 1000000,
        sales: 700000,
        progress: 0.7,
        targetFormatted: '1,000,000 Dhs',
        salesFormatted: '700,000 Dhs',
        progressFormatted: '70%',
      );

      return BaseResponse.success(data: report, statusCode: 200);
    } catch (e) {
      return BaseResponse.error(
        error: 'Failed to load today reports: $e',
        statusCode: 500,
      );
    }
  }

  // Get recent activity
  Future<BaseResponse<List<RecentActivity>>> getRecentActivity() async {
    try {
      // This would typically call a real API endpoint
      // For now, we'll return mock data
      final activities = [
        RecentActivity(
          id: 1,
          type: 'sale',
          title: 'New Sale Created',
          description: 'Sale #SO001 - 2,500 Dhs',
          time: '2 hours ago',
          icon: 'shopping_cart',
          color: 'success',
        ),
        RecentActivity(
          id: 2,
          type: 'customer',
          title: 'New Customer Added',
          description: 'Ahmed Alami - Rabat',
          time: '4 hours ago',
          icon: 'person_add',
          color: 'info',
        ),
        RecentActivity(
          id: 3,
          type: 'product',
          title: 'Product Updated',
          description: 'iPhone 15 Pro - Stock: 25',
          time: '6 hours ago',
          icon: 'inventory',
          color: 'warning',
        ),
        RecentActivity(
          id: 4,
          type: 'delivery',
          title: 'Delivery Completed',
          description: 'Delivery #DL001 - Casablanca',
          time: '8 hours ago',
          icon: 'local_shipping',
          color: 'primary',
        ),
      ];

      return BaseResponse.success(data: activities, statusCode: 200);
    } catch (e) {
      return BaseResponse.error(
        error: 'Failed to load recent activity: $e',
        statusCode: 500,
      );
    }
  }

  // Get quick stats
  Future<BaseResponse<List<QuickStat>>> getQuickStats() async {
    try {
      // This would typically call a real API endpoint
      // For now, we'll return mock data
      final stats = [
        QuickStat(
          title: 'Total Sales',
          value: '24',
          icon: 'trending_up',
          color: 'success',
          change: '+12%',
          changeType: 'positive',
        ),
        QuickStat(
          title: 'Deliveries',
          value: '18',
          icon: 'local_shipping',
          color: 'primary',
          change: '+5%',
          changeType: 'positive',
        ),
        QuickStat(
          title: 'Customers',
          value: '156',
          icon: 'people',
          color: 'info',
          change: '+3%',
          changeType: 'positive',
        ),
        QuickStat(
          title: 'Revenue',
          value: '2,450€',
          icon: 'euro',
          color: 'success',
          change: '+8%',
          changeType: 'positive',
        ),
      ];

      return BaseResponse.success(data: stats, statusCode: 200);
    } catch (e) {
      return BaseResponse.error(
        error: 'Failed to load quick stats: $e',
        statusCode: 500,
      );
    }
  }

  // Get user info
  Future<BaseResponse<UserInfo>> getUserInfo() async {
    try {
      final user = StorageService.instance.getUser();
      final isLoggedIn = StorageService.instance.getIsLoggedIn();

      final userInfo = UserInfo(
        name: user?['name'] ?? 'User',
        username: user?['username'] ?? 'user',
        email: user?['email'] ?? '',
        isLoggedIn: isLoggedIn,
      );

      return BaseResponse.success(data: userInfo, statusCode: 200);
    } catch (e) {
      return BaseResponse.error(
        error: 'Failed to load user info: $e',
        statusCode: 500,
      );
    }
  }

  // Get complete dashboard data
  Future<BaseResponse<DashboardData>> getDashboardData() async {
    try {
      // Load all data in parallel
      final results = await Future.wait([
        getTodayReports(),
        getRecentActivity(),
        getQuickStats(),
        getUserInfo(),
      ]);

      final todayReportResult = results[0] as BaseResponse<TodayReport>;
      final recentActivityResult =
          results[1] as BaseResponse<List<RecentActivity>>;
      final quickStatsResult = results[2] as BaseResponse<List<QuickStat>>;
      final userInfoResult = results[3] as BaseResponse<UserInfo>;

      if (!todayReportResult.success ||
          !recentActivityResult.success ||
          !quickStatsResult.success ||
          !userInfoResult.success) {
        return BaseResponse.error(
          error: 'Failed to load dashboard data',
          statusCode: 500,
        );
      }

      final dashboardData = DashboardData(
        todayReport: todayReportResult.data,
        recentActivity: recentActivityResult.data ?? [],
        quickStats: quickStatsResult.data ?? [],
        userInfo: userInfoResult.data,
      );

      return BaseResponse.success(data: dashboardData, statusCode: 200);
    } catch (e) {
      return BaseResponse.error(
        error: 'Failed to load dashboard data: $e',
        statusCode: 500,
      );
    }
  }

  // Refresh dashboard data
  Future<BaseResponse<DashboardData>> refreshDashboard() async {
    return getDashboardData();
  }
}
