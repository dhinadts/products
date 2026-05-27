import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/utils/responsive.dart';
import '../../../dashboard/presentation/widgets/company_drawer.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../bloc/billing_state.dart';
import '../widgets/cart_table_widget.dart';
import '../widgets/payment_summary_widget.dart';
import '../widgets/print_action_buttons.dart';
import '../widgets/product_search_widget.dart';

class BillingPage extends StatelessWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BillingBloc()..add(const BillingStarted()),
      child: BlocListener<BillingBloc, BillingState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        child: Scaffold(
          drawer: const CompanyDrawer(),
          appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                tooltip: 'Menu',
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu),
              ),
            ),
            title: const Text('Grocery POS Billing'),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  tooltip: 'Modules',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.apps_outlined),
                ),
              ),
              IconButton(
                tooltip: 'Printer settings',
                onPressed: () => context.pushNamed(RouteNames.printerSettings),
                icon: const Icon(Icons.settings_input_component_outlined),
              ),
            ],
          ),
          body: BlocBuilder<BillingBloc, BillingState>(
            builder: (context, state) {
              if (state.status == BillingStatus.loading ||
                  state.status == BillingStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              final width = MediaQuery.sizeOf(context).width;
              if (width >= 1100) return _desktop(state);
              if (width >= 700) return _tablet(context, state);
              return _mobile(state);
            },
          ),
          bottomNavigationBar: MediaQuery.sizeOf(context).width < 700
              ? const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: PrintActionButtons(),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _desktop(BillingState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ListView(
              children: [
                ProductSearchWidget(products: state.products),
                const SizedBox(height: 16),
                const CartTableWidget(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const SizedBox(
            width: 360,
            child: Column(
              children: [
                PaymentSummaryWidget(),
                SizedBox(height: 16),
                PrintActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tablet(BuildContext context, BillingState state) {
    return Padding(
      padding: Responsive.pagePadding(context),
      child: Row(
        children: [
          Expanded(child: ProductSearchWidget(products: state.products)),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(child: CartTableWidget()),
                ),
                PaymentSummaryWidget(),
                PrintActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobile(BillingState state) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 156),
      children: [
        ProductSearchWidget(products: state.products),
        const SizedBox(height: 12),
        const CartTableWidget(),
        const SizedBox(height: 12),
        const PaymentSummaryWidget(),
      ],
    );
  }
}
