import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

/// ويدجت حالة التحميل
class LoadingStateWidget extends StatelessWidget {
  final String? messageKey;
  final bool showMessage;

  const LoadingStateWidget({
    super.key,
    this.messageKey,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // مؤشر التحميل
          CircularProgressIndicator(
            strokeWidth: 3,
            color: theme.colorScheme.primary,
          ),

          if (showMessage) ...[
            const SizedBox(height: 24),

            // رسالة التحميل
            Text(
              messageKey != null ? messageKey! : l10n.loading,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ويدجت تحميل صغير للاستخدام في القوائم
class LoadingItemWidget extends StatelessWidget {
  const LoadingItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
