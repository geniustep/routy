// Dashboard Models for Routy App

import 'package:flutter/material.dart';

class DashboardSummary {
  final String totalSales;
  final String totalDeliveries;
  final String totalCustomers;
  final String totalRevenue;
  final String todayTarget;
  final String todaySales;
  final String todayProgress;
  final int recentActivityCount;

  DashboardSummary({
    required this.totalSales,
    required this.totalDeliveries,
    required this.totalCustomers,
    required this.totalRevenue,
    required this.todayTarget,
    required this.todaySales,
    required this.todayProgress,
    required this.recentActivityCount,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalSales: json['totalSales'] ?? '0',
      totalDeliveries: json['totalDeliveries'] ?? '0',
      totalCustomers: json['totalCustomers'] ?? '0',
      totalRevenue: json['totalRevenue'] ?? '0',
      todayTarget: json['todayTarget'] ?? '0 Dhs',
      todaySales: json['todaySales'] ?? '0 Dhs',
      todayProgress: json['todayProgress'] ?? '0%',
      recentActivityCount: json['recentActivityCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSales': totalSales,
      'totalDeliveries': totalDeliveries,
      'totalCustomers': totalCustomers,
      'totalRevenue': totalRevenue,
      'todayTarget': todayTarget,
      'todaySales': todaySales,
      'todayProgress': todayProgress,
      'recentActivityCount': recentActivityCount,
    };
  }
}

class TodayReport {
  final double target;
  final double sales;
  final double progress;
  final String targetFormatted;
  final String salesFormatted;
  final String progressFormatted;

  TodayReport({
    required this.target,
    required this.sales,
    required this.progress,
    required this.targetFormatted,
    required this.salesFormatted,
    required this.progressFormatted,
  });

  factory TodayReport.fromJson(Map<String, dynamic> json) {
    return TodayReport(
      target: (json['target'] ?? 0).toDouble(),
      sales: (json['sales'] ?? 0).toDouble(),
      progress: (json['progress'] ?? 0).toDouble(),
      targetFormatted: json['targetFormatted'] ?? '0 Dhs',
      salesFormatted: json['salesFormatted'] ?? '0 Dhs',
      progressFormatted: json['progressFormatted'] ?? '0%',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'target': target,
      'sales': sales,
      'progress': progress,
      'targetFormatted': targetFormatted,
      'salesFormatted': salesFormatted,
      'progressFormatted': progressFormatted,
    };
  }
}

class RecentActivity {
  final int id;
  final String type;
  final String title;
  final String description;
  final String time;
  final String icon;
  final String color;

  RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.color,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      time: json['time'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? 'primary',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'time': time,
      'icon': icon,
      'color': color,
    };
  }
}

class QuickStat {
  final String title;
  final String value;
  final String icon;
  final String color;
  final String change;
  final String changeType;

  QuickStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.change,
    required this.changeType,
  });

  factory QuickStat.fromJson(Map<String, dynamic> json) {
    return QuickStat(
      title: json['title'] ?? '',
      value: json['value'] ?? '0',
      icon: json['icon'] ?? '',
      color: json['color'] ?? 'primary',
      change: json['change'] ?? '0%',
      changeType: json['changeType'] ?? 'neutral',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'value': value,
      'icon': icon,
      'color': color,
      'change': change,
      'changeType': changeType,
    };
  }
}

class UserInfo {
  final String name;
  final String username;
  final String email;
  final bool isLoggedIn;

  UserInfo({
    required this.name,
    required this.username,
    required this.email,
    required this.isLoggedIn,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name'] ?? 'User',
      username: json['username'] ?? 'user',
      email: json['email'] ?? '',
      isLoggedIn: json['isLoggedIn'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'isLoggedIn': isLoggedIn,
    };
  }
}

// Dashboard API Response Models
class DashboardApiResponse {
  final bool success;
  final String? error;
  final DashboardData? data;

  DashboardApiResponse({required this.success, this.error, this.data});

  factory DashboardApiResponse.fromJson(Map<String, dynamic> json) {
    return DashboardApiResponse(
      success: json['success'] ?? false,
      error: json['error'],
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'error': error, 'data': data?.toJson()};
  }
}

class DashboardData {
  final TodayReport? todayReport;
  final List<RecentActivity> recentActivity;
  final List<QuickStat> quickStats;
  final UserInfo? userInfo;

  DashboardData({
    this.todayReport,
    required this.recentActivity,
    required this.quickStats,
    this.userInfo,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      todayReport: json['todayReport'] != null
          ? TodayReport.fromJson(json['todayReport'])
          : null,
      recentActivity:
          (json['recentActivity'] as List<dynamic>?)
              ?.map((item) => RecentActivity.fromJson(item))
              .toList() ??
          [],
      quickStats:
          (json['quickStats'] as List<dynamic>?)
              ?.map((item) => QuickStat.fromJson(item))
              .toList() ??
          [],
      userInfo: json['userInfo'] != null
          ? UserInfo.fromJson(json['userInfo'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayReport': todayReport?.toJson(),
      'recentActivity': recentActivity.map((item) => item.toJson()).toList(),
      'quickStats': quickStats.map((item) => item.toJson()).toList(),
      'userInfo': userInfo?.toJson(),
    };
  }
}

// ==================== Enhanced Models ====================

/// 📊 Enhanced Dashboard Stats Model
class DashboardStatsEnhanced {
  final double todaySales;
  final double weekSales;
  final double monthSales;
  final int todayOrders;
  final int weekOrders;
  final int monthOrders;
  final int activeCustomers;
  final int totalCustomers;
  final double target;
  final List<ChartDataPoint> salesTrend;

  const DashboardStatsEnhanced({
    this.todaySales = 0,
    this.weekSales = 0,
    this.monthSales = 0,
    this.todayOrders = 0,
    this.weekOrders = 0,
    this.monthOrders = 0,
    this.activeCustomers = 0,
    this.totalCustomers = 0,
    this.target = 1000000,
    this.salesTrend = const [],
  });

  double get progressPercentage => target > 0 ? (monthSales / target) : 0;

  DashboardStatsEnhanced copyWith({
    double? todaySales,
    double? weekSales,
    double? monthSales,
    int? todayOrders,
    int? weekOrders,
    int? monthOrders,
    int? activeCustomers,
    int? totalCustomers,
    double? target,
    List<ChartDataPoint>? salesTrend,
  }) {
    return DashboardStatsEnhanced(
      todaySales: todaySales ?? this.todaySales,
      weekSales: weekSales ?? this.weekSales,
      monthSales: monthSales ?? this.monthSales,
      todayOrders: todayOrders ?? this.todayOrders,
      weekOrders: weekOrders ?? this.weekOrders,
      monthOrders: monthOrders ?? this.monthOrders,
      activeCustomers: activeCustomers ?? this.activeCustomers,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      target: target ?? this.target,
      salesTrend: salesTrend ?? this.salesTrend,
    );
  }
}

/// 📈 Chart Data Point for Sales Trend
class ChartDataPoint {
  final DateTime date;
  final double value;
  final String label;

  const ChartDataPoint({
    required this.date,
    required this.value,
    required this.label,
  });
}

/// 📋 Enhanced Activity Model
class ActivityModelEnhanced {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final ActivityType type;
  final Color color;
  final IconData icon;

  const ActivityModelEnhanced({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
    required this.color,
    required this.icon,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

/// Activity Types
enum ActivityType {
  sale,
  customer,
  product,
  delivery,
  payment,
  other,
}

/// 🎯 KPI Card Data
class KpiCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double progress;
  final String? trend;
  final bool isPositiveTrend;

  const KpiCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.progress = 0.0,
    this.trend,
    this.isPositiveTrend = true,
  });
}

/// 🎨 Quick Action Data
class QuickActionData {
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  final bool isEnabled;
  final int? badge;

  const QuickActionData({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    this.isEnabled = true,
    this.badge,
  });
}
