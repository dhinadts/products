import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';

class PrintActionButtons extends StatelessWidget {
  const PrintActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    final primaryButtons = [
      FilledButton.icon(
        onPressed: () => context.read<BillingBloc>().add(const BillingSaved()),
        icon: const Icon(Icons.save_outlined),
        label: const Text('Save'),
      ),
      OutlinedButton.icon(
        onPressed: () =>
            context.read<BillingBloc>().add(const BillingThermalPrinted()),
        icon: const Icon(Icons.receipt_long),
        label: const Text('Receipt'),
      ),
      OutlinedButton.icon(
        onPressed: () =>
            context.read<BillingBloc>().add(const BillingDemoItemsAdded()),
        icon: const Icon(Icons.playlist_add),
        label: const Text('Demo'),
      ),
    ];
    if (mobile) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              for (var i = 0; i < primaryButtons.length; i++) ...[
                Expanded(child: primaryButtons[i]),
                if (i != primaryButtons.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.read<BillingBloc>().add(
                    const BillingPdfPrinted(),
                  ),
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('PDF'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.read<BillingBloc>().add(const BillingPdfShared()),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share'),
                ),
              ),
              IconButton(
                tooltip: 'New bill',
                onPressed: () =>
                    context.read<BillingBloc>().add(const BillingCleared()),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ],
      );
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...primaryButtons,
        OutlinedButton.icon(
          onPressed: () =>
              context.read<BillingBloc>().add(const BillingPdfPrinted()),
          icon: const Icon(Icons.print_outlined),
          label: const Text('A4 PDF Print'),
        ),
        OutlinedButton.icon(
          onPressed: () =>
              context.read<BillingBloc>().add(const BillingPdfShared()),
          icon: const Icon(Icons.share_outlined),
          label: const Text('Share PDF'),
        ),
        TextButton.icon(
          onPressed: () =>
              context.read<BillingBloc>().add(const BillingCleared()),
          icon: const Icon(Icons.refresh),
          label: const Text('New Bill'),
        ),
      ],
    );
  }
}
