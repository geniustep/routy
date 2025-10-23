import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/translation_helper.dart';

/// ويدجت حالة الخطأ
class ErrorStateWidget extends StatelessWidget {
  final String? titleKey;
  final String? messageKey;
  final String? errorMessage;
  final String? actionLabelKey;
  final VoidCallback? onActionPressed;
  final IconData? icon;

  const ErrorStateWidget({
    super.key,
    this.titleKey,
    this.messageKey,
    this.errorMessage,
    this.actionLabelKey,
    this.onActionPressed,
    this.icon,
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
              icon ?? Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ),

            const SizedBox(height: 24),

            // العنوان
            Text(
              TranslationHelper.getCommonTranslation(
                l10n,
                titleKey ?? 'error_occurred',
              ),
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // الرسالة
            Text(
              errorMessage ??
                  TranslationHelper.getCommonTranslation(
                    l10n,
                    messageKey ?? 'error_loading_data',
                  ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            // زر الإعادة
            if (actionLabelKey != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              FilledButton.tonalIcon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.refresh),
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
