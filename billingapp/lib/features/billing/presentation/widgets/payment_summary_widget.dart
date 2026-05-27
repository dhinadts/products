import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/bill_model.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../bloc/billing_state.dart';

class PaymentSummaryWidget extends StatelessWidget {
  const PaymentSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillingBloc, BillingState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bill ${state.billNumber}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                _row('Subtotal', state.subtotal),
                _row('Discount', state.totalDiscount),
                _row('Tax', state.taxAmount),
                const Divider(),
                _row('Grand Total', state.grandTotal, bold: true),
                const SizedBox(height: 14),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Bill discount'),
                  onChanged: (value) => context.read<BillingBloc>().add(
                    BillingDiscountChanged(double.tryParse(value) ?? 0),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<PaymentMode>(
                  initialValue: state.paymentMode,
                  decoration: const InputDecoration(labelText: 'Payment mode'),
                  items: PaymentMode.values
                      .map(
                        (mode) => DropdownMenuItem(
                          value: mode,
                          child: Text(mode.label),
                        ),
                      )
                      .toList(),
                  onChanged: (mode) {
                    if (mode != null) {
                      context.read<BillingBloc>().add(
                        BillingPaymentModeChanged(mode),
                      );
                    }
                  },
                ),
                const SizedBox(height: 14),
                _PaymentActionPanel(state: state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentActionPanel extends StatelessWidget {
  const _PaymentActionPanel({required this.state});

  final BillingState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillingBloc>();
    final completed = state.paymentCompleted;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: switch (state.paymentMode) {
        PaymentMode.cash => _PaymentStatus(
          icon: Icons.payments_outlined,
          text: 'Cash payment can be collected at counter.',
          completed: true,
          action: FilledButton.icon(
            onPressed: () => bloc.add(const BillingPaymentConfirmed()),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Confirm Cash'),
          ),
        ),
        PaymentMode.upi => Column(
          key: const ValueKey('upi'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PaymentStatus(
              icon: Icons.qr_code_2_outlined,
              text: completed
                  ? 'UPI payment confirmed.'
                  : 'Open any installed UPI app to collect payment.',
              completed: completed,
              action: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => bloc.add(const BillingUpiPaymentStarted()),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open UPI App'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => bloc.add(const BillingPaymentConfirmed()),
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Mark Paid'),
                  ),
                ],
              ),
            ),
          ],
        ),
        PaymentMode.card => Column(
          key: const ValueKey('card'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Gateway / terminal reference',
                prefixIcon: Icon(Icons.credit_card),
              ),
              onChanged: (value) =>
                  bloc.add(BillingPaymentReferenceChanged(value)),
            ),
            const SizedBox(height: 10),
            _PaymentStatus(
              icon: Icons.credit_score_outlined,
              text: completed
                  ? 'Card payment recorded.'
                  : 'Open secure checkout. Card number, expiry and CVC are collected by the gateway.',
              completed: completed,
              action: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () =>
                        bloc.add(const BillingCardPaymentStarted()),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open Card Checkout'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => bloc.add(const BillingPaymentConfirmed()),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirm Paid'),
                  ),
                ],
              ),
            ),
          ],
        ),
      },
    );
  }
}

class _PaymentStatus extends StatelessWidget {
  const _PaymentStatus({
    required this.icon,
    required this.text,
    required this.completed,
    required this.action,
  });

  final IconData icon;
  final String text;
  final bool completed;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('$text$completed'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: completed
            ? Colors.green.withValues(alpha: .10)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: completed
              ? Colors.green.withValues(alpha: .45)
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: completed ? Colors.green : null),
              const SizedBox(width: 10),
              Expanded(child: Text(text)),
              if (completed)
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
          const SizedBox(height: 10),
          action,
        ],
      ),
    );
  }
}
