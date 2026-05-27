import 'package:flutter/material.dart';

import '../../../../core/printer/pdf_print_service.dart';
import '../../../../core/printer/thermal_printer_service.dart';
import '../../../dashboard/presentation/widgets/billmaster_widgets.dart';

class RecordsTab extends StatefulWidget {
  const RecordsTab({super.key});

  @override
  State<RecordsTab> createState() => _RecordsTabState();
}

class _RecordsTabState extends State<RecordsTab> {
  bool _printing = false;

  @override
  Widget build(BuildContext context) {
    final mobile = isBillMobile(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              mobile ? 16 : 0,
              mobile ? 12 : 12,
              mobile ? 16 : 0,
              24,
            ),
            children: [
              if (!mobile) ...[
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 864),
                    child: const WebPageTitle(
                      title: 'Invoices',
                      subtitle:
                          'Create GST-ready invoices and review tax totals before printing.',
                      help:
                          'Fill customer, date and item lines first. The totals section shows subtotal, CGST, SGST and final invoice amount before saving or printing.',
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ],
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: mobile ? 480 : 864),
                  child: _InvoiceCard(mobile: mobile),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: mobile ? 480 : 864),
                  child: mobile
                      ? Column(
                          children: const [
                            _ComplianceCard(),
                            SizedBox(height: 16),
                            _SessionCard(),
                          ],
                        )
                      : Row(
                          children: const [
                            Expanded(flex: 2, child: _ComplianceCard()),
                            SizedBox(width: 16),
                            Expanded(child: _SessionCard()),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: mobile ? 16 : 40,
              vertical: mobile ? 10 : 14,
            ),
            decoration: BoxDecoration(
              color: billSurface(context),
              border: Border(top: BorderSide(color: billLine(context))),
            ),
            child: mobile
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 50),
                            backgroundColor: billNavy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _printing ? null : _printSampleInvoice,
                          icon: _printing
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.print_outlined),
                          label: const Text('PRINT SAMPLE INVOICE'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            foregroundColor: billNavy,
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('SAVE DRAFT'),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 58),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            foregroundColor: billNavy,
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('SAVE DRAFT'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 58),
                            backgroundColor: billNavy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _printing ? null : _printSampleInvoice,
                          icon: _printing
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.print_outlined),
                          label: const Text('SAVE & PRINT INVOICE'),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _printSampleInvoice() async {
    setState(() => _printing = true);
    try {
      await PdfPrintService().printPdfInvoice(
        ThermalPrinterService().sampleInvoice(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sample invoice opened for printing.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sample invoice print failed. $error')),
      );
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.mobile});

  final bool mobile;

  @override
  Widget build(BuildContext context) {
    return BillCard(
      padding: EdgeInsets.all(mobile ? 24 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mobile
              ? Column(
                  children: const [
                    _CustomerBox(),
                    SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniField(
                            label: 'DATE',
                            value: '10/27/2023',
                            icon: Icons.calendar_today,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _MiniField(
                            label: 'INVOICE #',
                            value: 'INV-2023-042',
                            bold: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(flex: 2, child: _CustomerBox()),
                    SizedBox(width: 32),
                    Expanded(
                      child: _MiniField(
                        label: 'DATE',
                        value: '10/27/2023',
                        icon: Icons.calendar_today,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _MiniField(
                        label: 'INVOICE #',
                        value: 'INV-2023-042',
                        bold: true,
                      ),
                    ),
                  ],
                ),
          SizedBox(height: mobile ? 22 : 34),
          if (mobile) ...const [
            _MobileInvoiceLine(
              item: 'Rice 5kg Bag',
              hsn: '1006',
              qty: '1',
              rate: '360.00',
              amount: '₹378.00',
            ),
            SizedBox(height: 10),
            _MobileInvoiceLine(
              item: 'Sunflower Oil 1L',
              hsn: '1512',
              qty: '2',
              rate: '145.00',
              amount: '₹294.00',
            ),
            SizedBox(height: 10),
            _MobileInvoiceLine(
              item: 'Premium Soap Pack',
              hsn: '3401',
              qty: '3',
              rate: '75.00',
              amount: '₹265.50',
            ),
          ] else ...const [
            _InvoiceHeader(),
            Divider(color: billBorder),
            _InvoiceLine(
              item: 'Rice 5kg Bag',
              hsn: '1006',
              qty: '1',
              rate: '360.00',
              amount: '₹378.00',
            ),
            Divider(color: Color(0xFFE8EDF2)),
            _InvoiceLine(
              item: 'Sunflower Oil 1L',
              hsn: '1512',
              qty: '2',
              rate: '145.00',
              amount: '₹294.00',
            ),
            Divider(color: Color(0xFFE8EDF2)),
            _InvoiceLine(
              item: 'Premium Soap Pack',
              hsn: '3401',
              qty: '3',
              rate: '75.00',
              amount: '₹265.50',
            ),
            Divider(color: Color(0xFFE8EDF2)),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.add_circle_outline, size: 18, color: billNavy),
                SizedBox(width: 6),
                Text('ADD NEW LINE', style: TextStyle(color: billNavy)),
              ],
            ),
          ),
          const Divider(color: billBorder, thickness: 1.5),
          const SizedBox(height: 32),
          mobile
              ? Column(
                  children: const [
                    _NotesBox(),
                    SizedBox(height: 28),
                    _TotalsBox(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(child: _NotesBox()),
                    SizedBox(width: 86),
                    Expanded(child: _TotalsBox()),
                  ],
                ),
        ],
      ),
    );
  }
}

class _CustomerBox extends StatelessWidget {
  const _CustomerBox();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CUSTOMER DETAILS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(minHeight: 42),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: billSurfaceAlt(context),
            border: Border.all(color: billLine(context)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
            children: [
              Icon(Icons.person_outline, size: 18, color: billMuted),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Walk-in Customer',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'GSTIN: 27AAAAA0000A1Z5 • Chennai, TN',
          style: TextStyle(color: billSecondaryText(context), fontSize: 12),
        ),
      ],
    );
  }
}

class _MiniField extends StatelessWidget {
  const _MiniField({
    required this.label,
    required this.value,
    this.icon,
    this.bold = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: billSurfaceAlt(context),
            border: Border.all(color: billLine(context)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: bold ? FontWeight.w900 : FontWeight.w400,
                  ),
                ),
              ),
              if (icon != null) Icon(icon, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _InvoiceHeader extends StatelessWidget {
  const _InvoiceHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text('ITEM NAME / DESCRIPTION', style: _headerStyle),
          ),
          Expanded(child: Text('QTY', style: _headerStyle)),
          Expanded(child: Text('RATE', style: _headerStyle)),
          Expanded(child: Text('AMOUNT', style: _headerStyle)),
        ],
      ),
    );
  }
}

const _headerStyle = TextStyle(
  color: Color(0xFFB6BDC6),
  fontSize: 12,
  fontWeight: FontWeight.w900,
);

class _InvoiceLine extends StatelessWidget {
  const _InvoiceLine({
    required this.item,
    required this.hsn,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  final String item;
  final String hsn;
  final String qty;
  final String rate;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 7),
                Text(
                  'HSN: $hsn',
                  style: const TextStyle(color: billMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(child: Text(qty, style: const TextStyle(fontSize: 16))),
          Expanded(child: Text(rate, style: const TextStyle(fontSize: 16))),
          Expanded(
            child: Text(
              amount,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileInvoiceLine extends StatelessWidget {
  const _MobileInvoiceLine({
    required this.item,
    required this.hsn,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  final String item;
  final String hsn;
  final String qty;
  final String rate;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: billSurfaceAlt(context),
        border: Border.all(color: billLine(context)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            'HSN: $hsn',
            style: TextStyle(color: billSecondaryText(context)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MobileMetric(label: 'Qty', value: qty),
              ),
              Expanded(
                child: _MobileMetric(label: 'Rate', value: rate),
              ),
              Expanded(
                child: _MobileMetric(
                  label: 'Amount',
                  value: amount,
                  alignEnd: true,
                  bold: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileMetric extends StatelessWidget {
  const _MobileMetric({
    required this.label,
    required this.value,
    this.alignEnd = false,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool alignEnd;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: billSecondaryText(context), fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _NotesBox extends StatelessWidget {
  const _NotesBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: billSurfaceAlt(context),
        border: Border.all(color: billLine(context)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'NOTES / TERMS\n1. Goods once sold will not be taken back.\n2. Interest @18% will be charged if payment is not made within 30 days.',
        style: TextStyle(height: 1.45),
      ),
    );
  }
}

class _TotalsBox extends StatelessWidget {
  const _TotalsBox();

  @override
  Widget build(BuildContext context) {
    final mobile = isBillMobile(context);
    return Column(
      children: [
        const _TotalRow('Subtotal', '₹875.00'),
        const _TotalRow('Discount', '₹10.00'),
        const _TotalRow('GST', '₹72.50'),
        const Divider(color: billBorder),
        Row(
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontSize: mobile ? 18 : 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Text(
              '₹937.50',
              style: TextStyle(
                fontSize: mobile ? 22 : 30,
                fontWeight: FontWeight.w900,
                color: billNavy,
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Rupees Nine Hundred Thirty Seven and Fifty Paise Only',
            style: TextStyle(
              color: billMuted,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Color(0xFF4D5259)),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF4D5259),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceCard extends StatelessWidget {
  const _ComplianceCard();

  @override
  Widget build(BuildContext context) {
    return BillCard(
      color: const Color(0xFF14334F),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: const [
          SizedBox(
            width: 64,
            height: 64,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF294A68),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: Icon(
                Icons.verified_outlined,
                color: Color(0xFF88A5C2),
                size: 32,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Compliance Ready\n',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text:
                        'This invoice automatically calculates SGST/CGST based on your business location in Maharashtra (MH).',
                  ),
                ],
              ),
              style: TextStyle(color: Color(0xFF7E9AB5), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Image.asset(
            'assets/gst_billing_ledger/invoice_generator.png',
            height: isBillMobile(context) ? 196 : 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: ColoredBox(color: Colors.black.withValues(alpha: .25)),
          ),
          const Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              'CURRENT SESSION\nActive for 12m',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
