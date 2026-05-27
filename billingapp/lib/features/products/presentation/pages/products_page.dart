import 'package:flutter/material.dart';

import '../../data/repositories/products_repository.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: FutureBuilder(
        future: ProductsRepository().getAll(),
        builder: (context, snapshot) {
          final products = snapshot.data ?? [];
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                    'Barcode: ${product.barcode ?? '-'} | GST ${product.taxPercent}%',
                  ),
                  trailing: Text('₹${product.salePrice.toStringAsFixed(2)}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
