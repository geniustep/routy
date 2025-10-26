import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routy/controllers/partner_controller.dart';
import 'package:routy/controllers/theme_controller.dart';
import 'package:routy/models/partners/partner_type.dart';
import 'package:routy/models/partners/partners_model.dart';
import 'package:routy/services/translation_service.dart';
import 'package:routy/config/responsive/responsive_design.dart';
import 'package:routy/config/core/app_config.dart';
import 'package:routy/app/app_router.dart';
import 'widgets/partner_card.dart';

/// 🏢 Partners Screen - شاشة عرض الشركاء
class PartnersScreen extends GetView<PartnerController> {
  final PartnerType? initialFilter;
  final bool selectMode;
  final String? title;
  final bool showCustomersOnly;

  const PartnersScreen({
    super.key,
    this.initialFilter,
    this.selectMode = false,
    this.title,
    this.showCustomersOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    // Apply initial filter if provided
    if (initialFilter != null &&
        controller.currentTypeFilter != initialFilter.toString()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.filterByType(initialFilter.toString());
      });
    }

    return Obx(
      () => Scaffold(
        backgroundColor: themeController.isDarkMode
            ? Colors.grey[900]
            : themeController.isProfessional
            ? const Color(0xFF0F172A)
            : Colors.grey[50],
        appBar: _buildAppBar(themeController),
        body: Column(
          children: [
            // Search Bar
            _buildSearchBar(themeController),

            // Filters
            _buildFilters(themeController),

            // Stats
            _buildStats(context, themeController),

            // Partners List
            Expanded(child: _buildPartnersList(context, themeController)),
          ],
        ),
        floatingActionButton: _buildFAB(themeController),
      ),
    );
  }

  /// AppBar
  PreferredSizeWidget _buildAppBar(ThemeController theme) {
    return AppBar(
      title: Text(
        selectMode
            ? (title ?? 'اختيار العميل')
            : TranslationService.instance.translate('partners'),
      ),
      backgroundColor: theme.isProfessional
          ? theme.primaryColor
          : theme.isDarkMode
          ? Colors.grey[800]
          : Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: selectMode
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Get.back(),
              tooltip: 'إلغاء',
            )
          : null,
      actions: selectMode
          ? [
              // في وضع الاختيار، لا نعرض خريطة أو تحديث
              const SizedBox.shrink(),
            ]
          : [
              // Map view - يظهر فقط إذا كان هناك شركاء بإحداثيات
              Obx(() {
                final hasPartnersWithLocation = controller.partners.any(
                  (p) => p.hasLocation,
                );

                if (!hasPartnersWithLocation) {
                  return const SizedBox.shrink();
                }

                return IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: () => Get.toNamed(AppRouter.partnersMap),
                  tooltip: TranslationService.instance.translate('map'),
                );
              }),

              // Refresh
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  // TODO: إعادة تحميل الشركاء
                },
                tooltip: TranslationService.instance.translate('refresh'),
              ),

              // More options
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'export':
                      Get.snackbar(
                        TranslationService.instance.translate(
                          'export_partners',
                        ),
                        TranslationService.instance.translate('coming_soon'),
                      );
                      break;
                    case 'import':
                      Get.snackbar(
                        TranslationService.instance.translate(
                          'import_partners',
                        ),
                        TranslationService.instance.translate('coming_soon'),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        const Icon(Icons.download),
                        const SizedBox(width: 8),
                        Text(
                          TranslationService.instance.translate(
                            'export_partners',
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'import',
                    child: Row(
                      children: [
                        const Icon(Icons.upload),
                        const SizedBox(width: 8),
                        Text(
                          TranslationService.instance.translate(
                            'import_partners',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
    );
  }

  /// Search Bar
  Widget _buildSearchBar(ThemeController theme) {
    return Padding(
      padding: ResponsiveDesign.getPadding(Get.context!),
      child: TextField(
        onChanged: (value) {
          controller.searchPartners(value);
        },
        style: TextStyle(
          color: theme.isDarkMode || theme.isProfessional
              ? Colors.white
              : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: TranslationService.instance.translate('search_partner'),
          hintStyle: TextStyle(
            color: theme.isDarkMode || theme.isProfessional
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.isDarkMode || theme.isProfessional
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
          suffixIcon: Obx(
            () => controller.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.searchPartners(''),
                    color: theme.isDarkMode || theme.isProfessional
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  )
                : const SizedBox.shrink(),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: theme.isDarkMode || theme.isProfessional
              ? Colors.grey[800]
              : Colors.white,
        ),
      ),
    );
  }

  /// Filters (Customer/Supplier/Both)
  Widget _buildFilters(ThemeController theme) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: ResponsiveDesign.getPadding(Get.context!),
        child: Row(
          children: [
            _buildFilterChip(
              label: TranslationService.instance.translate('all_partners'),
              isSelected: controller.currentTypeFilter == 'all',
              onTap: () => controller.filterByType('all'),
              theme: theme,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: TranslationService.instance.translate('customers_only'),
              isSelected: controller.currentTypeFilter == 'customer',
              onTap: () => controller.filterByType('customer'),
              color: Colors.blue,
              theme: theme,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: TranslationService.instance.translate('suppliers_only'),
              isSelected: controller.currentTypeFilter == 'supplier',
              onTap: () => controller.filterByType('supplier'),
              color: Colors.orange,
              theme: theme,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: TranslationService.instance.translate('both_types'),
              isSelected: controller.currentTypeFilter == 'both',
              onTap: () => controller.filterByType('both'),
              color: Colors.purple,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  /// Filter Chip
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeController theme,
    Color? color,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: theme.isDarkMode || theme.isProfessional
          ? Colors.grey[800]
          : Colors.grey[100],
      selectedColor: color?.withValues(alpha: 0.2) ?? Colors.blue.shade100,
      checkmarkColor: color ?? Colors.blue,
      labelStyle: TextStyle(
        color: isSelected
            ? (color ?? Colors.blue)
            : (theme.isDarkMode || theme.isProfessional
                  ? Colors.grey[300]
                  : Colors.grey[700]),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  /// Stats (Total, Customers, Suppliers)
  Widget _buildStats(BuildContext context, ThemeController theme) {
    final isSmallScreen =
        ResponsiveDesign.getScreenSize(context) == ScreenSize.small;

    return Obx(
      () => Container(
        margin: ResponsiveDesign.getPadding(context),
        padding: ResponsiveDesign.getPadding(context),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.isProfessional
                ? [
                    theme.primaryColor,
                    theme.primaryColor.withValues(alpha: 0.8),
                  ]
                : theme.isDarkMode
                ? [Colors.grey[800]!, Colors.grey[700]!]
                : [Colors.blue.shade400, Colors.blue.shade600],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color:
                  (theme.isProfessional
                          ? theme.primaryColor
                          : Colors.blue.shade200)
                      .withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.people,
              label: TranslationService.instance.translate('all_partners'),
              value: controller.partners.length.toString(),
              isSmall: isSmallScreen,
            ),
            _buildStatItem(
              icon: Icons.person,
              label: TranslationService.instance.translate('customers_only'),
              value: controller.partners
                  .where((p) => p.isCustomer)
                  .length
                  .toString(),
              isSmall: isSmallScreen,
            ),
            _buildStatItem(
              icon: Icons.store,
              label: TranslationService.instance.translate('suppliers_only'),
              value: controller.partners
                  .where((p) => p.isSupplier)
                  .length
                  .toString(),
              isSmall: isSmallScreen,
            ),
          ],
        ),
      ),
    );
  }

  /// Stat Item
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isSmall,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: isSmall ? 24 : 28),
        SizedBox(height: isSmall ? 2 : 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmall ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: isSmall ? 10 : 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Partners List
  Widget _buildPartnersList(BuildContext context, ThemeController theme) {
    return Obx(() {
      // Loading State
      if (controller.isLoading && controller.partners.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            color: theme.isProfessional ? theme.primaryColor : Colors.blue,
          ),
        );
      }

      // Error State
      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.isDarkMode || theme.isProfessional
                      ? Colors.white
                      : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: إعادة تحميل الشركاء
                },
                icon: const Icon(Icons.refresh),
                label: Text(TranslationService.instance.translate('retry')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.isProfessional
                      ? theme.primaryColor
                      : Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      // Empty State
      if (controller.partners.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 80,
                color: theme.isDarkMode || theme.isProfessional
                    ? Colors.grey[600]
                    : Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                controller.searchQuery.isNotEmpty
                    ? TranslationService.instance.translate('no_results')
                    : TranslationService.instance.translate('no_partners'),
                style: TextStyle(
                  fontSize: 18,
                  color: theme.isDarkMode || theme.isProfessional
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.searchQuery.isNotEmpty
                    ? TranslationService.instance.translate(
                        'try_different_search',
                      )
                    : TranslationService.instance.translate('start_adding'),
                style: TextStyle(
                  fontSize: 14,
                  color: theme.isDarkMode || theme.isProfessional
                      ? Colors.grey[500]
                      : Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }

      // Partners List
      return RefreshIndicator(
        onRefresh: () async {
          // TODO: إعادة تحميل الشركاء
        },
        color: theme.isProfessional ? theme.primaryColor : Colors.blue,
        child: ListView.builder(
          itemCount: controller.partners.length,
          padding: EdgeInsets.only(
            bottom: ResponsiveDesign.getScreenSize(context) == ScreenSize.small
                ? 80
                : 16,
          ),
          itemBuilder: (context, index) {
            final partner = controller.partners[index];

            // في وضع الاختيار، إظهار العملاء فقط إذا طُلب ذلك
            if (showCustomersOnly && !partner.isCustomer) {
              return const SizedBox.shrink();
            }

            return selectMode
                ? _buildSelectablePartnerCard(partner, theme)
                : PartnerCard(partner: partner);
          },
        ),
      );
    });
  }

  /// Selectable Partner Card for selection mode
  Widget _buildSelectablePartnerCard(
    PartnerModel partner,
    ThemeController theme,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.isProfessional
              ? theme.primaryColor
              : Colors.blue,
          child: Text(
            (partner.displayName ?? partner.name ?? '?')
                .substring(0, 1)
                .toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          partner.displayName ?? partner.name ?? 'غير محدد',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (partner.email != null && partner.email != false)
              Text('📧 ${partner.email}'),
            if (partner.phone != null && partner.phone != false)
              Text('📞 ${partner.phone}'),
            if (partner.mobile != null && partner.mobile != false)
              Text('📱 ${partner.mobile}'),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.isProfessional ? theme.primaryColor : Colors.blue,
        ),
        onTap: () {
          // إرجاع العميل المختار
          Get.back(result: partner);
        },
      ),
    );
  }

  /// Floating Action Button
  Widget _buildFAB(ThemeController theme) {
    // في وضع الاختيار، لا نعرض FAB
    if (selectMode) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: () {
        Get.snackbar(
          TranslationService.instance.translate('add_partner'),
          TranslationService.instance.translate('coming_soon'),
        );
      },
      icon: const Icon(Icons.add),
      label: Text(TranslationService.instance.translate('add_partner')),
      backgroundColor: theme.isProfessional ? theme.primaryColor : Colors.blue,
      foregroundColor: Colors.white,
    );
  }
}
