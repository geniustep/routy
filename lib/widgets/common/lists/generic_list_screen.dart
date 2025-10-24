import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/translation_helper.dart';
import '../../../models/common/filter_option.dart';
import '../../../models/common/sort_option.dart';
import '../../../models/common/list_item_action.dart';
import '../states/empty_state_widget.dart';
import '../states/loading_state_widget.dart';
import '../states/error_state_widget.dart';

/// حالة اللائحة
enum ListState { initial, loading, loaded, empty, error, loadingMore }

/// القالب العام للائحة
class GenericListScreen<T> extends StatefulWidget {
  // ============= الخصائص الأساسية =============

  /// عنوان اللائحة
  final String titleKey;

  /// دالة جلب البيانات
  final Future<List<T>> Function({
    String? searchQuery,
    List<FilterOption>? filters,
    SortOption? sortOption,
    int? page,
  })
  fetchData;

  /// بناء عنصر اللائحة
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// عند النقر على عنصر
  final Function(T item)? onItemTap;

  // ============= خيارات الفلترة والترتيب =============

  /// مجموعات الفلاتر
  final List<FilterGroup>? filterGroups;

  /// خيارات الترتيب
  final List<SortOption>? sortOptions;

  /// تفعيل البحث
  final bool enableSearch;

  /// Placeholder للبحث
  final String? searchHintKey;

  // ============= نقاط التوسيع والتخصيص =============

  /// هيدر مخصص أعلى اللائحة
  final Widget? customHeader;

  /// أزرار إضافية في AppBar
  final List<Widget>? customActions;

  /// زر الإضافة العائم
  final Widget? floatingActionButton;

  /// حالة فارغة مخصصة
  final Widget? customEmptyState;

  /// حالة خطأ مخصصة
  final Widget Function(String error)? customErrorState;

  /// إجراءات على العناصر
  final List<ListItemAction<T>>? itemActions;

  /// إجراءات السحب
  final List<SwipeAction<T>>? leadingSwipeActions;
  final List<SwipeAction<T>>? trailingSwipeActions;

  // ============= خيارات إضافية =============

  /// تفعيل Pull-to-Refresh
  final bool enableRefresh;

  /// تفعيل Pagination
  final bool enablePagination;

  /// عدد العناصر في الصفحة
  final int itemsPerPage;

  /// فاصل بين العناصر
  final Widget? separator;

  /// padding للائحة
  final EdgeInsetsGeometry? listPadding;

  const GenericListScreen({
    super.key,
    required this.titleKey,
    required this.fetchData,
    required this.itemBuilder,
    this.onItemTap,
    this.filterGroups,
    this.sortOptions,
    this.enableSearch = true,
    this.searchHintKey,
    this.customHeader,
    this.customActions,
    this.floatingActionButton,
    this.customEmptyState,
    this.customErrorState,
    this.itemActions,
    this.leadingSwipeActions,
    this.trailingSwipeActions,
    this.enableRefresh = true,
    this.enablePagination = true,
    this.itemsPerPage = 20,
    this.separator,
    this.listPadding,
  });

  @override
  State<GenericListScreen<T>> createState() => _GenericListScreenState<T>();
}

class _GenericListScreenState<T> extends State<GenericListScreen<T>> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // الحالة
  ListState _state = ListState.initial;
  List<T> _items = [];
  String? _errorMessage;

  // البحث والفلترة
  String _searchQuery = '';
  List<FilterOption> _activeFilters = [];
  SortOption? _activeSortOption;

  // Pagination
  int _currentPage = 1;
  bool _hasMorePages = true;

  @override
  void initState() {
    super.initState();
    _loadData();

    if (widget.enablePagination) {
      _scrollController.addListener(_onScroll);
    }

    // Debounce للبحث
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============= تحميل البيانات =============

  Future<void> _loadData({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMorePages = true;
    }

    setState(() {
      _state = isRefresh || _items.isEmpty
          ? ListState.loading
          : ListState.loadingMore;
      if (isRefresh) _items.clear();
    });

    try {
      final newItems = await widget.fetchData(
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        filters: _activeFilters.isEmpty ? null : _activeFilters,
        sortOption: _activeSortOption,
        page: widget.enablePagination ? _currentPage : null,
      );

      setState(() {
        if (isRefresh) {
          _items = newItems;
        } else {
          _items.addAll(newItems);
        }

        _hasMorePages = newItems.length >= widget.itemsPerPage;
        _state = _items.isEmpty ? ListState.empty : ListState.loaded;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _state = ListState.error;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (!_hasMorePages || _state == ListState.loadingMore) return;

    _currentPage++;
    await _loadData();
  }

  // ============= معالجة الأحداث =============

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreData();
    }
  }

  void _onSearchChanged() {
    // Debounce
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text != _searchQuery) {
        setState(() {
          _searchQuery = _searchController.text;
        });
        _loadData(isRefresh: true);
      }
    });
  }

  void _onFilterChanged(List<FilterOption> filters) {
    setState(() {
      _activeFilters = filters;
    });
    _loadData(isRefresh: true);
  }

  void _onSortChanged(SortOption? sortOption) {
    setState(() {
      _activeSortOption = sortOption;
    });
    _loadData(isRefresh: true);
  }

  // ============= بناء الواجهة =============

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: widget.floatingActionButton,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.titleKey),
      actions: [
        // زر البحث
        if (widget.enableSearch)
          IconButton(icon: const Icon(Icons.search), onPressed: _showSearchBar),

        // زر الفلترة
        if (widget.filterGroups != null && widget.filterGroups!.isNotEmpty)
          IconButton(
            icon: Badge(
              isLabelVisible: _activeFilters.isNotEmpty,
              label: Text('${_activeFilters.length}'),
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilterSheet,
          ),

        // زر الترتيب
        if (widget.sortOptions != null && widget.sortOptions!.isNotEmpty)
          IconButton(icon: const Icon(Icons.sort), onPressed: _showSortSheet),

        // أزرار مخصصة
        ...?widget.customActions,
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // شريط البحث
        if (widget.enableSearch && _searchQuery.isNotEmpty) _buildSearchBar(),

        // الهيدر المخصص
        if (widget.customHeader != null) widget.customHeader!,

        // المحتوى الرئيسي
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText:
              widget.searchHintKey ??
              TranslationHelper.getCommonTranslation(l10n, 'search'),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
              _loadData(isRefresh: true);
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case ListState.loading:
        return const LoadingStateWidget();

      case ListState.error:
        return widget.customErrorState?.call(_errorMessage ?? '') ??
            ErrorStateWidget(
              errorMessage: _errorMessage,
              actionLabelKey: 'retry',
              onActionPressed: () => _loadData(isRefresh: true),
            );

      case ListState.empty:
        return widget.customEmptyState ??
            EmptyStateWidget(
              titleKey: 'no_items_found',
              messageKey: 'try_different_search',
            );

      case ListState.loaded:
      case ListState.loadingMore:
        return _buildList();

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildList() {
    final listView = ListView.separated(
      controller: _scrollController,
      padding: widget.listPadding ?? const EdgeInsets.all(16),
      itemCount: _items.length + (_state == ListState.loadingMore ? 1 : 0),
      separatorBuilder: (context, index) {
        return widget.separator ?? const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const LoadingItemWidget();
        }

        final item = _items[index];
        final itemWidget = widget.itemBuilder(context, item, index);

        return InkWell(
          onTap: widget.onItemTap != null
              ? () => widget.onItemTap!(item)
              : null,
          child: itemWidget,
        );
      },
    );

    if (widget.enableRefresh) {
      return RefreshIndicator(
        onRefresh: () => _loadData(isRefresh: true),
        child: listView,
      );
    }

    return listView;
  }

  // ============= Bottom Sheets =============

  void _showSearchBar() {
    setState(() {
      _searchQuery = '';
    });
  }

  void _showFilterSheet() {
    if (widget.filterGroups == null || widget.filterGroups!.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    TranslationHelper.getCommonTranslation(l10n, 'filter'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        for (var group in widget.filterGroups!) {
                          group.clearSelections();
                        }
                        _activeFilters.clear();
                      });
                      _loadData(isRefresh: true);
                      Get.back();
                    },
                    child: Text(l10n.reset),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Filter Groups
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20),
                itemCount: widget.filterGroups!.length,
                itemBuilder: (context, index) {
                  final group = widget.filterGroups![index];
                  return _buildFilterGroup(group, l10n);
                },
              ),
            ),

            // Apply Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton(
                onPressed: () {
                  final selectedFilters = <FilterOption>[];
                  for (var group in widget.filterGroups!) {
                    selectedFilters.addAll(group.selectedOptions);
                  }
                  _onFilterChanged(selectedFilters);
                  Get.back();
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  TranslationHelper.getCommonTranslation(l10n, 'apply'),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildFilterGroup(FilterGroup group, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.titleKey,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: group.options.map((option) {
            return FilterChip(
              label: Text(
                TranslationHelper.getCommonTranslation(l10n, option.labelKey),
              ),
              selected: option.isSelected,
              onSelected: (selected) {
                setState(() {
                  if (group.allowMultiple) {
                    option.isSelected = selected;
                  } else {
                    for (var opt in group.options) {
                      opt.isSelected = false;
                    }
                    option.isSelected = true;
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showSortSheet() {
    if (widget.sortOptions == null || widget.sortOptions!.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    TranslationHelper.getCommonTranslation(l10n, 'sort_by'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Sort Options
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.sortOptions!.length,
              itemBuilder: (context, index) {
                final option = widget.sortOptions![index];
                return RadioListTile<String>(
                  title: Text(
                    TranslationHelper.getCommonTranslation(
                      l10n,
                      option.labelKey,
                    ),
                  ),
                  subtitle: Text(
                    option.order == SortOrder.ascending
                        ? '↑ تصاعدي'
                        : '↓ تنازلي',
                  ),
                  value: option.id,
                  groupValue: _activeSortOption?.id,
                  onChanged: (value) {
                    setState(() {
                      for (var opt in widget.sortOptions!) {
                        opt.isSelected = false;
                      }
                      option.isSelected = true;
                      _activeSortOption = option;
                    });
                    _onSortChanged(option);
                    Get.back();
                  },
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
