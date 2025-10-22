import 'package:flutter/material.dart';

class SalesCreateScreen extends StatelessWidget {
  const SalesCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Vente'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          'Créer une Vente',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
