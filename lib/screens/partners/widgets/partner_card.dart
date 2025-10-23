import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routy/models/partners/partners_model.dart';
import 'package:routy/models/partners/partner_type.dart';
import 'package:routy/controllers/theme_controller.dart';
import 'package:routy/services/translation_service.dart';
import 'package:routy/app/app_router.dart';

/// 🎴 Partner Card - كارد احترافي لعرض معلومات الشريك
class PartnerCard extends StatelessWidget {
  final PartnerModel partner;
  final VoidCallback? onTap;

  const PartnerCard({super.key, required this.partner, this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        color: themeController.isDarkMode || themeController.isProfessional
            ? Colors.grey[850]
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap:
              onTap ??
              () => Get.toNamed(AppRouter.partnerDetails, arguments: partner),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar + Name + Type Badge
                Row(
                  children: [
                    // Avatar
                    _buildAvatar(),
                    const SizedBox(width: 12),

                    // Name & Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            _getNameString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  themeController.isDarkMode ||
                                      themeController.isProfessional
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Ref or Display Name
                          if (_getRefString() != null)
                            Text(
                              _getRefString()!,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    themeController.isDarkMode ||
                                        themeController.isProfessional
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Type Badge
                    _buildTypeBadge(themeController),
                  ],
                ),

                // Contact Info
                if (partner.primaryPhone != null || _getEmailString() != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      children: [
                        if (partner.primaryPhone != null)
                          _buildContactRow(
                            Icons.phone,
                            partner.primaryPhone!,
                            themeController,
                          ),
                        if (_getEmailString() != null)
                          _buildContactRow(
                            Icons.email,
                            _getEmailString()!,
                            themeController,
                          ),
                      ],
                    ),
                  ),

                // Address
                if (partner.fullAddress != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildContactRow(
                      Icons.location_on,
                      partner.fullAddress!,
                      themeController,
                    ),
                  ),

                // Financial Info (if customer)
                if (partner.isCustomer && _getBalanceDouble() > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _buildFinancialInfo(themeController),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Avatar with initials
  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 24,
      backgroundColor: _getAvatarColor(),
      child: Text(
        partner.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Type Badge (Customer/Supplier/Both)
  Widget _buildTypeBadge(ThemeController theme) {
    Color bgColor;
    Color textColor;
    String label;

    switch (partner.type) {
      case PartnerType.customer:
        bgColor = theme.isDarkMode || theme.isProfessional
            ? Colors.blue.shade900
            : Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        label = TranslationService.instance.translate('customer');
      case PartnerType.supplier:
        bgColor = theme.isDarkMode || theme.isProfessional
            ? Colors.orange.shade900
            : Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        label = TranslationService.instance.translate('supplier');
      case PartnerType.both:
        bgColor = theme.isDarkMode || theme.isProfessional
            ? Colors.purple.shade900
            : Colors.purple.shade50;
        textColor = Colors.purple.shade700;
        label = TranslationService.instance.translate('both');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Contact row (icon + text)
  Widget _buildContactRow(IconData icon, String text, ThemeController theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.isDarkMode || theme.isProfessional
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: theme.isDarkMode || theme.isProfessional
                    ? Colors.grey[300]
                    : Colors.grey[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Financial Info (Balance & Credit)
  Widget _buildFinancialInfo(ThemeController theme) {
    final balance = _getBalanceDouble();
    final isDebt = balance > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDebt
            ? (theme.isDarkMode || theme.isProfessional
                  ? Colors.red.shade900
                  : Colors.red.shade50)
            : (theme.isDarkMode || theme.isProfessional
                  ? Colors.green.shade900
                  : Colors.green.shade50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isDebt ? Icons.arrow_upward : Icons.check_circle,
                size: 16,
                color: isDebt ? Colors.red.shade700 : Colors.green.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                isDebt
                    ? TranslationService.instance.translate('has_debt')
                    : TranslationService.instance.translate('no_debt'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDebt ? Colors.red.shade700 : Colors.green.shade700,
                ),
              ),
            ],
          ),
          if (isDebt)
            Text(
              '${balance.toStringAsFixed(2)} DH',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
        ],
      ),
    );
  }

  /// Get avatar color based on type
  Color _getAvatarColor() {
    return switch (partner.type) {
      PartnerType.customer => Colors.blue.shade600,
      PartnerType.supplier => Colors.orange.shade600,
      PartnerType.both => Colors.purple.shade600,
    };
  }

  // ==================== Helper Methods ====================

  String _getNameString() {
    return (partner.name is String)
        ? partner.name as String
        : partner.name?.toString() ?? 'بدون اسم';
  }

  String? _getRefString() {
    if (partner.ref is String && partner.ref != false) {
      return partner.ref as String;
    }
    if (partner.displayName is String && partner.displayName != false) {
      return partner.displayName as String;
    }
    return null;
  }

  String? _getEmailString() {
    if (partner.email is String && partner.email != false) {
      return partner.email as String;
    }
    return null;
  }

  double _getBalanceDouble() {
    if (partner.balance is num) {
      return (partner.balance as num).toDouble();
    }
    return 0.0;
  }
}
