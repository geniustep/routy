import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget {
  final String navigateName;

  const CustomAppBar({super.key, required this.navigateName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(navigateName),
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () {
          Get.back();
        },
        icon: const Icon(Icons.chevron_left, size: 30),
      ),
    );
  }
}
