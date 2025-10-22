import 'package:flutter/material.dart';

class CustomersListScreen extends StatelessWidget {
  const CustomersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          'Liste des Clients',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
