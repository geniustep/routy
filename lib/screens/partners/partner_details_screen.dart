import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:routy/controllers/theme_controller.dart';
import 'package:routy/models/partners/partners_model.dart';
import 'package:routy/models/partners/partner_type.dart';
import 'package:routy/services/translation_service.dart';
import 'package:routy/config/responsive/responsive_design.dart';
import 'package:routy/app/app_router.dart';

/// 📄 Partner Details Screen - صفحة تفاصيل الشريك
class PartnerDetailsScreen extends StatelessWidget {
  final PartnerModel partner;

  const PartnerDetailsScreen({super.key, required this.partner});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => Scaffold(
        backgroundColor: themeController.isDarkMode
            ? Colors.grey[900]
            : themeController.isProfessional
            ? const Color(0xFF0F172A)
            : Colors.grey[50],
        body: CustomScrollView(
          slivers: [
            // App Bar with Hero
            _buildSliverAppBar(themeController),

            // Content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Header Card
                  _buildHeaderCard(context, themeController),

                  // Contact Info
                  _buildContactSection(context, themeController),

                  // Address Info
                  if (partner.fullAddress != null)
                    _buildAddressSection(context, themeController),

                  // Financial Info
                  if (partner.isCustomer)
                    _buildFinancialSection(context, themeController),

                  // Additional Info
                  _buildAdditionalInfoSection(context, themeController),

                  // Actions
                  _buildActionsSection(context, themeController),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFAB(themeController),
      ),
    );
  }

  /// Sliver App Bar
  Widget _buildSliverAppBar(ThemeController theme) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: theme.isProfessional
          ? theme.primaryColor
          : theme.isDarkMode
          ? Colors.grey[850]
          : _getPartnerColor(),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _getNameString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.isProfessional
                  ? [
                      theme.primaryColor,
                      theme.primaryColor.withValues(alpha: 0.7),
                    ]
                  : [
                      _getPartnerColor(),
                      _getPartnerColor().withValues(alpha: 0.7),
                    ],
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'partner_${partner.id}',
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  partner.initials,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _getPartnerColor(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Header Card
  Widget _buildHeaderCard(BuildContext context, ThemeController theme) {
    return Container(
      margin: ResponsiveDesign.getPadding(context),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDarkMode || theme.isProfessional
            ? Colors.grey[850]
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Type Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTypeBadge(theme),
              if (partner.isCustomer && partner.hasDebt) ...[
                const SizedBox(width: 8),
                _buildDebtBadge(theme),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            _getNameString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.isDarkMode || theme.isProfessional
                  ? Colors.white
                  : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          if (_getRefString() != null) ...[
            const SizedBox(height: 8),
            Text(
              'Réf: ${_getRefString()}',
              style: TextStyle(
                fontSize: 14,
                color: theme.isDarkMode || theme.isProfessional
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Contact Section
  Widget _buildContactSection(BuildContext context, ThemeController theme) {
    final hasContact =
        partner.primaryPhone != null ||
        _getEmailString() != null ||
        _getMobileString() != null;

    if (!hasContact) return const SizedBox.shrink();

    return _buildSection(
      context: context,
      theme: theme,
      title: TranslationService.instance.translate('contact'),
      icon: Icons.contact_phone,
      children: [
        if (partner.primaryPhone != null)
          _buildInfoTile(
            icon: Icons.phone,
            title: TranslationService.instance.translate('phone'),
            value: partner.primaryPhone!,
            onTap: () => _makePhoneCall(partner.primaryPhone!),
            theme: theme,
          ),
        if (_getMobileString() != null)
          _buildInfoTile(
            icon: Icons.smartphone,
            title: TranslationService.instance.translate('mobile'),
            value: _getMobileString()!,
            onTap: () => _makePhoneCall(_getMobileString()!),
            theme: theme,
          ),
        if (_getEmailString() != null)
          _buildInfoTile(
            icon: Icons.email,
            title: TranslationService.instance.translate('email'),
            value: _getEmailString()!,
            onTap: () => _sendEmail(_getEmailString()!),
            theme: theme,
          ),
      ],
    );
  }

  /// Address Section
  Widget _buildAddressSection(BuildContext context, ThemeController theme) {
    return _buildSection(
      context: context,
      theme: theme,
      title: TranslationService.instance.translate('address'),
      icon: Icons.location_on,
      children: [
        _buildInfoTile(
          icon: Icons.location_city,
          title: TranslationService.instance.translate('full_address'),
          value: partner.fullAddress!,
          onTap: partner.hasLocation ? () => _openMap() : null,
          theme: theme,
        ),
        if (_getCityString() != null)
          _buildInfoTile(
            icon: Icons.location_city,
            title: TranslationService.instance.translate('city'),
            value: _getCityString()!,
            theme: theme,
          ),
        if (_getCountryString() != null)
          _buildInfoTile(
            icon: Icons.flag,
            title: TranslationService.instance.translate('country'),
            value: _getCountryString()!,
            theme: theme,
          ),
        if (_getZipString() != null)
          _buildInfoTile(
            icon: Icons.markunread_mailbox,
            title: TranslationService.instance.translate('zip'),
            value: _getZipString()!,
            theme: theme,
          ),
        // زر الخريطة مع المسافة إذا كان لديه إحداثيات
        if (partner.hasLocation) _buildMapButton(context, theme),
      ],
    );
  }

  /// Build Map Button with Distance
  Widget _buildMapButton(BuildContext context, ThemeController theme) {
    return FutureBuilder<String>(
      future: _calculateDistance(),
      builder: (context, snapshot) {
        final distanceText = snapshot.hasData ? snapshot.data! : '...';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            onPressed: () => _openMapForPartner(),
            icon: const Icon(Icons.map),
            label: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TranslationService.instance.translate('view_on_map'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (snapshot.hasData)
                  Text(
                    '📍 $distanceText',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.isProfessional
                  ? theme.primaryColor
                  : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Calculate distance between user and partner
  Future<String> _calculateDistance() async {
    try {
      // الحصول على موقع المستخدم الحالي
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return TranslationService.instance.translate('location_unavailable');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // حساب المسافة
      final partnerLat = (partner.partnerLatitude is num)
          ? (partner.partnerLatitude as num).toDouble()
          : 0.0;
      final partnerLng = (partner.partnerLongitude is num)
          ? (partner.partnerLongitude as num).toDouble()
          : 0.0;

      final distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        partnerLat,
        partnerLng,
      );

      // تحويل لـ كم أو متر
      if (distanceInMeters >= 1000) {
        final distanceInKm = distanceInMeters / 1000;
        return '${distanceInKm.toStringAsFixed(1)} km';
      } else {
        return '${distanceInMeters.toStringAsFixed(0)} m';
      }
    } catch (e) {
      return TranslationService.instance.translate('distance_unavailable');
    }
  }

  /// Open map centered on partner location
  void _openMapForPartner() {
    // الانتقال للخريطة مع تمرير معلومات الشريك
    Get.toNamed(AppRouter.partnersMap, arguments: {'focusPartner': partner});
  }

  /// Financial Section
  Widget _buildFinancialSection(BuildContext context, ThemeController theme) {
    final balance = _getBalanceDouble();
    final isDebt = balance > 0;

    return _buildSection(
      context: context,
      theme: theme,
      title: TranslationService.instance.translate('financial'),
      icon: Icons.account_balance_wallet,
      children: [
        // Main Balance Card - يظهر بوضوح إذا كان مديون أو دائن
        _buildFinancialCard(
          theme: theme,
          title: isDebt
              ? TranslationService.instance.translate('debt_amount')
              : TranslationService.instance.translate('credit_amount'),
          value: balance.abs(),
          color: isDebt ? Colors.red : Colors.green,
          icon: isDebt ? Icons.trending_up : Icons.trending_down,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFinancialCard(
                theme: theme,
                title: TranslationService.instance.translate('credit_limit'),
                value: _getCreditLimitDouble(),
                color: Colors.blue,
                icon: Icons.credit_card,
                isSmall: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFinancialCard(
                theme: theme,
                title: TranslationService.instance.translate('usage'),
                value: partner.creditUsagePercentage,
                color: partner.exceededCreditLimit ? Colors.red : Colors.orange,
                icon: Icons.pie_chart,
                isSmall: true,
                isPercentage: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Additional Info Section
  Widget _buildAdditionalInfoSection(
    BuildContext context,
    ThemeController theme,
  ) {
    return _buildSection(
      context: context,
      theme: theme,
      title: TranslationService.instance.translate('additional_info'),
      icon: Icons.info_outline,
      children: [
        _buildInfoTile(
          icon: Icons.tag,
          title: 'ID',
          value: partner.id?.toString() ?? 'N/A',
          theme: theme,
        ),
        if (_getVatString() != null)
          _buildInfoTile(
            icon: Icons.receipt_long,
            title: TranslationService.instance.translate('vat'),
            value: _getVatString()!,
            theme: theme,
          ),
        _buildInfoTile(
          icon: Icons.check_circle,
          title: TranslationService.instance.translate('active'),
          value: partner.active == true
              ? TranslationService.instance.translate('yes')
              : TranslationService.instance.translate('no'),
          theme: theme,
        ),
      ],
    );
  }

  /// Actions Section
  Widget _buildActionsSection(BuildContext context, ThemeController theme) {
    return Container(
      margin: ResponsiveDesign.getPadding(context),
      child: Column(
        children: [
          // Primary Actions
          Row(
            children: [
              if (partner.primaryPhone != null)
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.call,
                    label: TranslationService.instance.translate('call'),
                    color: Colors.green,
                    onTap: () => _makePhoneCall(partner.primaryPhone!),
                  ),
                ),
              if (partner.primaryPhone != null && _getEmailString() != null)
                const SizedBox(width: 12),
              if (_getEmailString() != null)
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.email,
                    label: TranslationService.instance.translate('email'),
                    color: Colors.blue,
                    onTap: () => _sendEmail(_getEmailString()!),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Secondary Actions
          Row(
            children: [
              if (partner.hasLocation)
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.map,
                    label: TranslationService.instance.translate('map'),
                    color: Colors.teal,
                    onTap: _openMap,
                  ),
                ),
              if (partner.hasLocation) const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.edit,
                  label: TranslationService.instance.translate('edit'),
                  color: theme.isProfessional
                      ? theme.primaryColor
                      : Colors.orange,
                  onTap: _editPartner,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build Section
  Widget _buildSection({
    required BuildContext context,
    required ThemeController theme,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: ResponsiveDesign.getPadding(context),
      decoration: BoxDecoration(
        color: theme.isDarkMode || theme.isProfessional
            ? Colors.grey[850]
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: theme.isProfessional
                      ? theme.primaryColor
                      : _getPartnerColor(),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.isDarkMode || theme.isProfessional
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  /// Info Tile
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required ThemeController theme,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (theme.isDarkMode || theme.isProfessional
                    ? Colors.grey[800]
                    : Colors.grey[100])!,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: theme.isProfessional
                    ? theme.primaryColor
                    : _getPartnerColor(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.isDarkMode || theme.isProfessional
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.isDarkMode || theme.isProfessional
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.isDarkMode || theme.isProfessional
                    ? Colors.grey[600]
                    : Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  /// Financial Card
  Widget _buildFinancialCard({
    required ThemeController theme,
    required String title,
    required double value,
    required Color color,
    required IconData icon,
    bool isSmall = false,
    bool isPercentage = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isSmall ? 20 : 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmall ? 12 : 14,
                    color: theme.isDarkMode || theme.isProfessional
                        ? Colors.grey[400]
                        : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isPercentage
                ? '${value.toStringAsFixed(0)}%'
                : '${value.toStringAsFixed(2)} DH',
            style: TextStyle(
              fontSize: isSmall ? 18 : 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Action Button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Type Badge
  Widget _buildTypeBadge(ThemeController theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getPartnerColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getPartnerColor()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getPartnerIcon(), color: _getPartnerColor(), size: 16),
          const SizedBox(width: 6),
          Text(
            _getPartnerTypeLabel(),
            style: TextStyle(
              color: _getPartnerColor(),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Debt Badge
  Widget _buildDebtBadge(ThemeController theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning, color: Colors.red, size: 16),
          const SizedBox(width: 6),
          Text(
            TranslationService.instance.translate('has_debt'),
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// FAB
  Widget _buildFAB(ThemeController theme) {
    return FloatingActionButton.extended(
      onPressed: _editPartner,
      icon: const Icon(Icons.edit),
      label: Text(TranslationService.instance.translate('edit')),
      backgroundColor: theme.isProfessional
          ? theme.primaryColor
          : _getPartnerColor(),
      foregroundColor: Colors.white,
    );
  }

  // Helper Methods
  Color _getPartnerColor() {
    switch (partner.type) {
      case PartnerType.customer:
        return Colors.green;
      case PartnerType.supplier:
        return Colors.orange;
      case PartnerType.both:
        return Colors.purple;
    }
  }

  IconData _getPartnerIcon() {
    switch (partner.type) {
      case PartnerType.customer:
        return Icons.person;
      case PartnerType.supplier:
        return Icons.store;
      case PartnerType.both:
        return Icons.business_center;
    }
  }

  String _getPartnerTypeLabel() {
    switch (partner.type) {
      case PartnerType.customer:
        return TranslationService.instance.translate('customer');
      case PartnerType.supplier:
        return TranslationService.instance.translate('supplier');
      case PartnerType.both:
        return TranslationService.instance.translate('both');
    }
  }

  String _getNameString() {
    return (partner.name is String)
        ? partner.name as String
        : partner.name?.toString() ?? 'N/A';
  }

  String? _getRefString() {
    if (partner.ref == null || partner.ref == false) return null;
    return partner.ref is String
        ? partner.ref as String
        : partner.ref.toString();
  }

  String? _getEmailString() {
    if (partner.email == null || partner.email == false) return null;
    return partner.email is String ? partner.email as String : null;
  }

  String? _getMobileString() {
    if (partner.mobile == null || partner.mobile == false) return null;
    return partner.mobile is String ? partner.mobile as String : null;
  }

  String? _getCityString() {
    if (partner.city == null || partner.city == false) return null;
    return partner.city is String
        ? partner.city as String
        : partner.city.toString();
  }

  String? _getCountryString() {
    if (partner.countryId == null || partner.countryId == false) return null;
    if (partner.countryId is List && (partner.countryId as List).length > 1) {
      return (partner.countryId as List)[1].toString();
    }
    return partner.countryId.toString();
  }

  String? _getZipString() {
    if (partner.zip == null || partner.zip == false) return null;
    return partner.zip is String
        ? partner.zip as String
        : partner.zip.toString();
  }

  String? _getVatString() {
    if (partner.vat == null || partner.vat == false) return null;
    return partner.vat is String
        ? partner.vat as String
        : partner.vat.toString();
  }

  double _getBalanceDouble() {
    // استخدام balance بدلاً من totalDue لأن API ترسل credit في حقل balance
    if (partner.balance == null || partner.balance == false) return 0.0;
    if (partner.balance is num) return (partner.balance as num).toDouble();
    return 0.0;
  }

  double _getCreditLimitDouble() {
    // التعامل مع false و null من Odoo
    if (partner.creditLimit == null || partner.creditLimit == false) return 0.0;
    if (partner.creditLimit is num)
      return (partner.creditLimit as num).toDouble();
    return 0.0;
  }

  // Actions
  void _makePhoneCall(String phone) {
    Get.snackbar(
      TranslationService.instance.translate('call'),
      phone,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _sendEmail(String email) {
    Get.snackbar(
      TranslationService.instance.translate('email'),
      email,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _openMap() {
    Get.toNamed(AppRouter.partnersMap);
  }

  void _editPartner() {
    Get.snackbar(
      TranslationService.instance.translate('edit'),
      TranslationService.instance.translate('coming_soon'),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
