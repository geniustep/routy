import 'package:flutter/material.dart';

class ProductsCreateScreen extends StatelessWidget {
  const ProductsCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Produit'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          'Créer un Produit',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
