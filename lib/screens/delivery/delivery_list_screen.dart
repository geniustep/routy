import 'package:flutter/material.dart';

class DeliveryListScreen extends StatelessWidget {
  const DeliveryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livraisons'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          'Liste des Livraisons',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
