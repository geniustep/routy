import 'package:flutter/material.dart';

class DashboardDrawer extends StatelessWidget {
  final String routeName;
  final dynamic controller;

  const DashboardDrawer({super.key, required this.routeName, this.controller});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Text(
              routeName,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              // TODO: الانتقال إلى Dashboard
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Partners'),
            onTap: () {
              Navigator.pop(context);
              // TODO: الانتقال إلى Partners
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              // TODO: الانتقال إلى Products
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Sales'),
            onTap: () {
              Navigator.pop(context);
              // TODO: الانتقال إلى Sales
            },
          ),
        ],
      ),
    );
  }
}
