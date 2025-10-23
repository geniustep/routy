/// نموذج خيارات الترتيب
class SortOption {
  final String id;
  final String labelKey; // مفتاح الترجمة
  final String field; // الحقل المراد الترتيب حسبه
  final SortOrder order;
  bool isSelected;

  SortOption({
    required this.id,
    required this.labelKey,
    required this.field,
    this.order = SortOrder.descending,
    this.isSelected = false,
  });

  SortOption copyWith({
    String? id,
    String? labelKey,
    String? field,
    SortOrder? order,
    bool? isSelected,
  }) {
    return SortOption(
      id: id ?? this.id,
      labelKey: labelKey ?? this.labelKey,
      field: field ?? this.field,
      order: order ?? this.order,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// عكس الترتيب
  SortOption toggleOrder() {
    return copyWith(
      order: order == SortOrder.ascending
          ? SortOrder.descending
          : SortOrder.ascending,
    );
  }
}

/// اتجاه الترتيب
enum SortOrder {
  ascending, // تصاعدي
  descending, // تنازلي
}
