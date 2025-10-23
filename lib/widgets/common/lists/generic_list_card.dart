import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/translation_helper.dart';
import '../../../models/common/item_status.dart';

/// قالب كارد عام لعناصر اللائحة
class GenericListCard extends StatelessWidget {
  // ============= الخصائص الأساسية =============

  /// العنوان الرئيسي
  final String title;

  /// النص الفرعي
  final String? subtitle;

  /// النص الثانوي الإضافي
  final String? secondaryText;

  /// الأيقونة أو الصورة في البداية
  final Widget? leading;

  /// عنصر في النهاية
  final Widget? trailing;

  // ============= الحالة =============

  /// حالة العنصر
  final ItemStatus? status;

  /// لون الحالة
  final Color? statusColor;

  // ============= المعلومات الإضافية =============

  /// قائمة المعلومات الإضافية (chips/badges)
  final List<InfoChip>? infoChips;

  /// معلومات في سطر واحد
  final List<String>? infoItems;

  // ============= الإجراءات =============

  /// أزرار الإجراءات السريعة
  final List<ActionButton>? actions;

  /// إظهار أيقونة المزيد
  final bool showMoreIcon;

  /// عند النقر
  final VoidCallback? onTap;

  /// عند الضغط المطول
  final VoidCallback? onLongPress;

  // ============= التخصيص =============

  /// padding داخلي
  final EdgeInsetsGeometry? padding;

  /// لون الخلفية
  final Color? backgroundColor;

  /// ارتفاع الكارد
  final double? elevation;

  /// شكل الكارد
  final ShapeBorder? shape;

  const GenericListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.secondaryText,
    this.leading,
    this.trailing,
    this.status,
    this.statusColor,
    this.infoChips,
    this.infoItems,
    this.actions,
    this.showMoreIcon = false,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: elevation ?? 1,
      color: backgroundColor,
      shape:
          shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف الأول: Leading + العنوان + Trailing
              Row(
                children: [
                  // Leading (أيقونة أو صورة)
                  if (leading != null) ...[leading!, const SizedBox(width: 12)],

                  // العنوان والنص الفرعي
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // العنوان
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // النص الفرعي
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Trailing (حالة، سعر، أيقونة...)
                  if (trailing != null)
                    trailing!
                  else if (status != null)
                    _buildStatusBadge(context)
                  else if (showMoreIcon)
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),

              // النص الثانوي
              if (secondaryText != null) ...[
                const SizedBox(height: 8),
                Text(
                  secondaryText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // معلومات إضافية (chips)
              if (infoChips != null && infoChips!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: infoChips!.map((chip) {
                    return _buildInfoChip(context, chip);
                  }).toList(),
                ),
              ],

              // معلومات في سطر واحد
              if (infoItems != null && infoItems!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        infoItems!.join(' • '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // أزرار الإجراءات
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!.map((action) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: action.isIcon
                          ? IconButton(
                              icon: Icon(action.icon),
                              onPressed: action.onPressed,
                              color: action.color,
                              tooltip: action.label,
                            )
                          : TextButton.icon(
                              onPressed: action.onPressed,
                              icon: Icon(action.icon, size: 18),
                              label: Text(action.label ?? ''),
                              style: TextButton.styleFrom(
                                foregroundColor: action.color,
                              ),
                            ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final color = statusColor ?? status!.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status!.icon != null) ...[
            Icon(status!.icon, size: 16, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            TranslationHelper.getCommonTranslation(l10n, status!.labelKey),
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, InfoChip chip) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            chip.backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chip.icon != null) ...[
            Icon(
              chip.icon,
              size: 14,
              color: chip.iconColor ?? theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            chip.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: chip.textColor ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// نموذج معلومة إضافية (chip/badge)
class InfoChip {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const InfoChip({
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });
}

/// نموذج زر إجراء
class ActionButton {
  final String? label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final bool isIcon; // عرض كأيقونة فقط أم زر كامل

  const ActionButton({
    this.label,
    required this.icon,
    required this.onPressed,
    this.color,
    this.isIcon = false,
  });
}
