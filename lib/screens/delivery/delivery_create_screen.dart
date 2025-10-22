import 'package:flutter/material.dart';

class DeliveryCreateScreen extends StatelessWidget {
  const DeliveryCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Livraison'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          'Créer une Livraison',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
