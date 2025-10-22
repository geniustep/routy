import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    final themes = [
      {
        'name': 'Light',
        'type': CustomThemeType.light,
        'icon': Icons.light_mode,
      },
      {'name': 'Dark', 'type': CustomThemeType.dark, 'icon': Icons.dark_mode},
      {
        'name': 'Professional',
        'type': CustomThemeType.professional,
        'icon': Icons.business,
      },
      {
        'name': 'System',
        'type': CustomThemeType.system,
        'icon': Icons.settings_system_daydream,
      },
    ];

    return Obx(() {
      final currentType = themeController.themeType;

      return AlertDialog(
        title: const Text('Choisir un thème'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: themes.length,
            itemBuilder: (context, index) {
              final theme = themes[index];
              final isSelected = currentType == theme['type'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: isSelected
                    ? themeController.primaryColor.withValues(alpha: 0.1)
                    : null,
                child: ListTile(
                  leading: Icon(
                    theme['icon'] as IconData,
                    color: isSelected
                        ? themeController.primaryColor
                        : Colors.grey,
                  ),
                  title: Text(
                    theme['name'] as String,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? themeController.primaryColor : null,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: themeController.primaryColor,
                        )
                      : null,
                  onTap: () {
                    themeController.setThemeType(
                      theme['type'] as CustomThemeType,
                    );
                    Get.back();
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
        ],
      );
    });
  }
}
