import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final String buttonName;
  final String routeName;
  final VoidCallback onTap;

  const CustomFloatingActionButton({
    super.key,
    required this.buttonName,
    required this.routeName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onTap,
      label: Text(buttonName),
      icon: const Icon(Icons.add),
    );
  }
}
