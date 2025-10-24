import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/translation_helper.dart';

/// ويدجت الحالة الفارغة
class EmptyStateWidget extends StatelessWidget {
  final String? titleKey;
  final String? messageKey;
  final IconData? icon;
  final String? actionLabelKey;
  final VoidCallback? onActionPressed;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    this.titleKey,
    this.messageKey,
    this.icon,
    this.actionLabelKey,
    this.onActionPressed,
    this.iconSize = 100,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الأيقونة
            Icon(
              icon ?? Icons.inbox_outlined,
              size: iconSize,
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),

            const SizedBox(height: 24),

            // العنوان
            Text(
              TranslationHelper.getCommonTranslation(
                l10n,
                titleKey ?? 'no_data_found',
              ),
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // الرسالة
            if (messageKey != null)
              Text(
                TranslationHelper.getCommonTranslation(l10n, messageKey!),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

            // زر الإجراء
            if (actionLabelKey != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(
                  TranslationHelper.getCommonTranslation(l10n, actionLabelKey!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
