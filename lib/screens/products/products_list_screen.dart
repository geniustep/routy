import 'package:flutter/material.dart';

class ProductsListScreen extends StatelessWidget {
  const ProductsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          'Liste des Produits',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
