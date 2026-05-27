import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_model.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';

class ProductSearchWidget extends StatefulWidget {
  const ProductSearchWidget({super.key, required this.products});

  final List<ProductModel> products;

  @override
  State<ProductSearchWidget> createState() => _ProductSearchWidgetState();
}

class _ProductSearchWidgetState extends State<ProductSearchWidget> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Barcode / product name / manual item',
            prefixIcon: const Icon(Icons.qr_code_scanner),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                context.read<BillingBloc>().add(
                  BillingManualItemAdded(_controller.text),
                );
                _controller.clear();
              },
            ),
          ),
          onSubmitted: (value) {
            context.read<BillingBloc>().add(BillingManualItemAdded(value));
            _controller.clear();
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.products.map((product) {
            return ActionChip(
              avatar: const Icon(Icons.shopping_basket_outlined, size: 18),
              label: Text(
                '${product.name} ₹${product.salePrice.toStringAsFixed(0)}',
              ),
              onPressed: () =>
                  context.read<BillingBloc>().add(BillingProductAdded(product)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
