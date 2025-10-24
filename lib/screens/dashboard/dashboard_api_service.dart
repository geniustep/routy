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
      // TODO: تنفيذ استدعاء API حقيقي هنا
      // يجب استبدال هذا ببيانات حقيقية من السيرفر

      return BaseResponse.error(
        error: 'API not implemented yet',
        statusCode: 501,
      );
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
      // TODO: تنفيذ استدعاء API حقيقي هنا
      // يجب استبدال هذا ببيانات حقيقية من السيرفر

      return BaseResponse.error(
        error: 'API not implemented yet',
        statusCode: 501,
      );
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
      // TODO: تنفيذ استدعاء API حقيقي هنا
      // يجب استبدال هذا ببيانات حقيقية من السيرفر

      return BaseResponse.error(
        error: 'API not implemented yet',
        statusCode: 501,
      );
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
      // TODO: تنفيذ استدعاء API حقيقي هنا
      // يجب استبدال هذا ببيانات حقيقية من السيرفر

      return BaseResponse.error(
        error: 'API not implemented yet',
        statusCode: 501,
      );
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
