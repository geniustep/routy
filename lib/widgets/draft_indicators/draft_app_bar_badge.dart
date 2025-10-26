import 'package:flutter/material.dart';

class DraftAppBarBadge extends StatelessWidget {
  final bool showOnlyWhenHasDrafts;
  final Color iconColor;
  final Color badgeColor;

  const DraftAppBarBadge({
    super.key,
    this.showOnlyWhenHasDrafts = false,
    this.iconColor = Colors.white,
    this.badgeColor = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        // TODO: تنفيذ الانتقال إلى المسودات
      },
      icon: Stack(
        children: [
          Icon(Icons.edit, color: iconColor),
          if (!showOnlyWhenHasDrafts)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                child: const Text(
                  '0',
                  style: TextStyle(color: Colors.white, fontSize: 8),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
