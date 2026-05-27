import 'package:flutter/material.dart';

import '../../../dashboard/presentation/widgets/billmaster_widgets.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  static const _products = [
    (
      'Lathe Tool - Series X',
      'HSN: 8207 | Tools & Dies',
      '04 Units',
      '₹1,450.00',
      true,
    ),
    (
      'Gas Cylinder - Industrial (47kg)',
      'HSN: 7311 | Containers',
      '42 Units',
      '₹4,200.00',
      false,
    ),
    (
      'M12 Hex Bolts (Grade 8.8)',
      'HSN: 7318 | Fasteners',
      '120 Units',
      '₹12.50',
      true,
    ),
    (
      'CNC Coolant Oil (20L)',
      'HSN: 2710 | Petroleum Oils',
      '15 Units',
      '₹3,850.00',
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mobile = isBillMobile(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            mobile ? 16 : 40,
            mobile ? 16 : 12,
            mobile ? 16 : 40,
            28,
          ),
          child: Column(
            children: [
              if (!mobile) ...[
                const WebPageTitle(
                  title: 'Inventory',
                  subtitle:
                      'Manage stock levels, unit prices, low-stock products and product actions.',
                  help:
                      'Use this page to search inventory, review low-stock items, update product details, and add new products or services for GST billing.',
                ),
                const SizedBox(height: 22),
              ],
              mobile
                  ? Column(
                      children: const [
                        _InventoryOverview(),
                        SizedBox(height: 20),
                        _AddProductCard(),
                      ],
                    )
                  : Row(
                      children: const [
                        Expanded(flex: 2, child: _InventoryOverview()),
                        SizedBox(width: 16),
                        Expanded(child: _AddProductCard()),
                      ],
                    ),
              const SizedBox(height: 26),
              mobile
                  ? Column(
                      children: const [
                        BillSearchField(
                          hint: 'Search parts, tools, or cylinders...',
                        ),
                        SizedBox(height: 10),
                        _FilterButton(),
                      ],
                    )
                  : Row(
                      children: const [
                        Expanded(
                          child: BillSearchField(
                            hint: 'Search parts, tools, or cylinders...',
                          ),
                        ),
                        SizedBox(width: 8),
                        _FilterButton(),
                      ],
                    ),
              const SizedBox(height: 16),
              _InventoryTable(products: _products),
            ],
          ),
        ),
      ],
    );
  }
}

class _InventoryOverview extends StatelessWidget {
  const _InventoryOverview();

  @override
  Widget build(BuildContext context) {
    return BillCard(
      padding: EdgeInsets.all(isBillMobile(context) ? 18 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INVENTORY OVERVIEW',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
              fontFamily: 'serif',
            ),
          ),
          if (!isBillMobile(context)) ...[
            const SizedBox(height: 6),
            const HelpTooltip(
              message:
                  'Shows total products, low-stock count and category count. Review this before billing high-demand items.',
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '1,248 Items',
            style: TextStyle(
              fontSize: isBillMobile(context) ? 24 : 30,
              fontWeight: FontWeight.w900,
              color: billPrimaryText(context),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: const [
              _LegendDot(color: Color(0xFFC5161D), label: '12 Low Stock'),
              SizedBox(width: 26),
              _LegendDot(color: billNavy, label: '84 Categories'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: billBodyText(context))),
      ],
    );
  }
}

class _AddProductCard extends StatelessWidget {
  const _AddProductCard();

  @override
  Widget build(BuildContext context) {
    return BillCard(
      color: const Color(0xFF14334F),
      padding: EdgeInsets.all(isBillMobile(context) ? 28 : 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_box_outlined, color: Color(0xFF8099B3), size: 32),
          SizedBox(height: 10),
          Text(
            'Add New Product',
            style: TextStyle(
              color: Color(0xFF8099B3),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'serif',
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Register new parts or services into GST records.',
            style: TextStyle(color: Color(0xFF7891AA)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          HelpTooltip(
            message:
                'Create a product or service with HSN, price and stock threshold so it can be used in invoices.',
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(isBillMobile(context) ? 118 : 102, 40),
        foregroundColor: const Color(0xFF3F444B),
        backgroundColor: billSurfaceAlt(context),
        side: BorderSide(color: billLine(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {},
      icon: const Icon(Icons.filter_list),
      label: const Text('Filters'),
    );
  }
}

class _InventoryTable extends StatelessWidget {
  const _InventoryTable({required this.products});

  final List<(String, String, String, String, bool)> products;

  @override
  Widget build(BuildContext context) {
    final mobile = isBillMobile(context);
    return BillCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: mobile ? 18 : 16,
              vertical: mobile ? 20 : 16,
            ),
            color: billSurfaceAlt(context),
            child: DefaultTextStyle(
              style: _tableHead.copyWith(color: billBodyText(context)),
              child: Row(
                children: [
                  Expanded(
                    flex: mobile ? 3 : 4,
                    child: const Text('PRODUCT DETAILS'),
                  ),
                  Expanded(
                    flex: mobile ? 2 : 3,
                    child: const Text('STOCK LEVEL'),
                  ),
                  Expanded(flex: 2, child: const Text('UNIT PRICE')),
                  if (!mobile) const Expanded(child: Text('ACTIONS')),
                ],
              ),
            ),
          ),
          ...products.map((product) => _ProductRow(product: product)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            color: billSurfaceAlt(context),
            child: Row(
              children: [
                Text(
                  'Showing 1-4 of 1,248',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: billBodyText(context),
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_left, color: billSecondaryText(context)),
                const SizedBox(width: 18),
                Icon(Icons.chevron_right, color: billSecondaryText(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _tableHead = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  letterSpacing: .8,
  color: Color(0xFF40464E),
);

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});

  final (String, String, String, String, bool) product;

  @override
  Widget build(BuildContext context) {
    final mobile = isBillMobile(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 18 : 16,
        vertical: mobile ? 20 : 18,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: billLine(context))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: mobile ? 3 : 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.$1,
                  style: TextStyle(
                    fontSize: mobile ? 20 : 16,
                    fontWeight: FontWeight.w900,
                    height: mobile ? 1.35 : 1.1,
                    fontFamily: mobile ? null : 'serif',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.$2,
                  style: TextStyle(
                    color: billMuted,
                    fontSize: mobile ? 15 : 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: mobile ? 2 : 3,
            child: Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  product.$3,
                  style: TextStyle(
                    color: product.$5
                        ? const Color(0xFFC50000)
                        : billPrimaryText(context),
                    fontWeight: FontWeight.w900,
                    fontSize: mobile ? 16 : 14,
                  ),
                ),
                if (product.$5)
                  const StatusPill(
                    text: 'LOW STOCK',
                    foreground: Color(0xFFC50000),
                    background: Color(0xFFFFD7D7),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              product.$4,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: mobile ? 20 : 16,
              ),
            ),
          ),
          if (!mobile)
            Expanded(
              child: Row(
                children: [
                  IconButton.outlined(
                    onPressed: () {},
                    icon: const Icon(Icons.assignment_turned_in_outlined),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
