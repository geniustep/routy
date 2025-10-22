import 'package:flutter/material.dart';

class CustomersCreateScreen extends StatelessWidget {
  const CustomersCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Client'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          'Créer un Client',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
