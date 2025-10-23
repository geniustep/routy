/// نموذج خيارات الفلترة
class FilterOption {
  final String id;
  final String labelKey; // مفتاح الترجمة
  final dynamic value;
  final FilterType type;
  bool isSelected;

  FilterOption({
    required this.id,
    required this.labelKey,
    required this.value,
    required this.type,
    this.isSelected = false,
  });

  FilterOption copyWith({
    String? id,
    String? labelKey,
    dynamic value,
    FilterType? type,
    bool? isSelected,
  }) {
    return FilterOption(
      id: id ?? this.id,
      labelKey: labelKey ?? this.labelKey,
      value: value ?? this.value,
      type: type ?? this.type,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// أنواع الفلترة
enum FilterType {
  status, // حالة
  date, // تاريخ
  range, // مدى (سعر، كمية...)
  category, // تصنيف
  custom, // مخصص
}

/// مجموعة فلاتر
class FilterGroup {
  final String titleKey; // مفتاح عنوان المجموعة
  final List<FilterOption> options;
  final bool allowMultiple; // السماح باختيار متعدد

  FilterGroup({
    required this.titleKey,
    required this.options,
    this.allowMultiple = true,
  });

  /// الحصول على الخيارات المحددة
  List<FilterOption> get selectedOptions {
    return options.where((option) => option.isSelected).toList();
  }

  /// مسح جميع التحديدات
  void clearSelections() {
    for (var option in options) {
      option.isSelected = false;
    }
  }
}
