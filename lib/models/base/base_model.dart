/// 🏗️ BaseModel - الأساس لجميع Models في التطبيق
///
/// يوفر:
/// - ✅ Structure موحدة
/// - ✅ JSON Serialization
/// - ✅ Sync Status
/// - ✅ Timestamps
abstract class BaseModel {
  /// ID المحلي (SQLite)
  final int? id;

  /// ID من Odoo
  final int? odooId;

  /// تاريخ الإنشاء
  final DateTime? createdAt;

  /// تاريخ آخر تحديث
  final DateTime? updatedAt;

  /// هل تمت المزامنة مع Odoo؟
  final bool synced;

  /// حالة المزامنة
  final SyncStatus syncStatus;

  const BaseModel({
    this.id,
    this.odooId,
    this.createdAt,
    this.updatedAt,
    this.synced = false,
    this.syncStatus = SyncStatus.pending,
  });

  /// تحويل إلى JSON
  Map<String, dynamic> toJson();

  /// نسخ مع تعديلات
  BaseModel copyWith();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel &&
        other.runtimeType == runtimeType &&
        other.id == id &&
        other.odooId == odooId;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, odooId);

  @override
  String toString() {
    return '$runtimeType(id: $id, odooId: $odooId, synced: $synced)';
  }
}

/// حالات المزامنة
enum SyncStatus {
  /// في انتظار المزامنة
  pending,

  /// جاري المزامنة
  syncing,

  /// تمت المزامنة بنجاح
  synced,

  /// فشلت المزامنة
  failed,

  /// تعارض في البيانات
  conflict;

  String get label {
    switch (this) {
      case SyncStatus.pending:
        return 'في الانتظار';
      case SyncStatus.syncing:
        return 'جاري المزامنة';
      case SyncStatus.synced:
        return 'تمت المزامنة';
      case SyncStatus.failed:
        return 'فشل';
      case SyncStatus.conflict:
        return 'تعارض';
    }
  }

  bool get isPending => this == SyncStatus.pending;
  bool get isSyncing => this == SyncStatus.syncing;
  bool get isSynced => this == SyncStatus.synced;
  bool get isFailed => this == SyncStatus.failed;
  bool get hasConflict => this == SyncStatus.conflict;
}

/// Extension للـ DateTime
extension DateTimeX on DateTime {
  /// تحويل لـ ISO String
  String toIso() => toIso8601String();

  /// تحويل من ISO String
  static DateTime? fromIso(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso);
    } catch (e) {
      return null;
    }
  }

  /// هل اليوم؟
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// هل الأمس؟
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Format نسبي
  String toRelative() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (isToday) {
      return 'اليوم';
    } else if (isYesterday) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inDays < 30) {
      return 'منذ ${(difference.inDays / 7).floor()} أسبوع';
    } else if (difference.inDays < 365) {
      return 'منذ ${(difference.inDays / 30).floor()} شهر';
    } else {
      return 'منذ ${(difference.inDays / 365).floor()} سنة';
    }
  }
}
