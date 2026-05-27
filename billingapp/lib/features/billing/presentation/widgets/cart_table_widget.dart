import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../bloc/billing_state.dart';

class CartTableWidget extends StatelessWidget {
  const CartTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillingBloc, BillingState>(
      builder: (context, state) {
        final mobile = MediaQuery.sizeOf(context).width < 700;
        if (state.items.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No items added. Scan barcode or select a product.',
                ),
              ),
            ),
          );
        }
        if (mobile) {
          return Column(
            children: [
              for (var i = 0; i < state.items.length; i++)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                state.items[i].itemName,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove item',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => context.read<BillingBloc>().add(
                                BillingItemRemoved(i),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _NumberCell(
                                label: 'Qty',
                                value: state.items[i].quantity,
                                onSubmitted: (value) => context
                                    .read<BillingBloc>()
                                    .add(BillingQuantityChanged(i, value)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _NumberCell(
                                label: 'Rate',
                                value: state.items[i].rate,
                                onSubmitted: (value) => context
                                    .read<BillingBloc>()
                                    .add(BillingPriceChanged(i, value)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'GST ${state.items[i].taxPercent.toStringAsFixed(1)}%',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const Spacer(),
                            Text(
                              '₹${state.items[i].total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }
        return Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Item')),
                DataColumn(label: Text('Qty')),
                DataColumn(label: Text('Rate')),
                DataColumn(label: Text('GST')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('')),
              ],
              rows: [
                for (var i = 0; i < state.items.length; i++)
                  DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 180,
                          child: Text(state.items[i].itemName),
                        ),
                      ),
                      DataCell(
                        _NumberCell(
                          value: state.items[i].quantity,
                          onSubmitted: (value) => context
                              .read<BillingBloc>()
                              .add(BillingQuantityChanged(i, value)),
                        ),
                      ),
                      DataCell(
                        _NumberCell(
                          value: state.items[i].rate,
                          onSubmitted: (value) => context
                              .read<BillingBloc>()
                              .add(BillingPriceChanged(i, value)),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${state.items[i].taxPercent.toStringAsFixed(1)}%',
                        ),
                      ),
                      DataCell(
                        Text('₹${state.items[i].total.toStringAsFixed(2)}'),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => context.read<BillingBloc>().add(
                            BillingItemRemoved(i),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NumberCell extends StatelessWidget {
  const _NumberCell({
    this.label,
    required this.value,
    required this.onSubmitted,
  });

  final String? label;
  final double value;
  final ValueChanged<double> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: TextFormField(
        initialValue: value.toStringAsFixed(
          value.truncateToDouble() == value ? 0 : 2,
        ),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.all(8),
        ),
        onFieldSubmitted: (text) => onSubmitted(double.tryParse(text) ?? value),
      ),
    );
  }
}
