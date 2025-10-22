import 'package:flutter/material.dart';

class SalesListScreen extends StatelessWidget {
  const SalesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventes'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          'Liste des Ventes',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
