// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

class _Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _appSurface(context),
        border: Border.all(color: _appBorder(context)),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: padding,
      child: child,
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? note;
  final IconData? icon;
  final Color? accent;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    this.note,
    this.icon,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: Container(
        decoration: BoxDecoration(
          color: _appSurface(context),
          border: Border.all(
            color: accent ?? _appBorder(context),
            width: accent == null ? 1 : 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // ← distributes space evenly
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color:
                          _appMuted(context), // ← muted label, value pops more
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withAlpha(18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 26,
              child: note != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _appMuted(context).withAlpha(18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        note!,
                        style: TextStyle(
                          color: _appMuted(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPanelMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyPanelMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _appMuted(context), size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: _appMuted(context)),
          ),
        ],
      ),
    );
  }
}

class _DataPanel extends StatelessWidget {
  final String? title;
  final String? action;
  final List<String> columns;
  final List<List<Widget>> rows;
  final Widget? footer;

  const _DataPanel({
    required this.columns,
    required this.rows,
    this.title,
    // Kept for existing/common table callers; page-specific tables can ignore it.
    // ignore: unused_element_parameter
    this.action,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tableMinWidth =
              constraints.maxWidth < 900 ? 900.0 : constraints.maxWidth;

          return Column(
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title!,
                          style: const TextStyle(
                              color: _primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (action != null)
                        Text(
                          action!,
                          style: const TextStyle(
                            color: _primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      if (action != null)
                        const Icon(Icons.arrow_forward, color: _primary),
                    ],
                  ),
                ),
              _HorizontalScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: tableMinWidth),
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(_appHeaderSurface(context)),
                    border: TableBorder(
                        horizontalInside:
                            BorderSide(color: _appBorder(context))),
                    columnSpacing: 20,
                    headingTextStyle: TextStyle(
                      color: _appText(context),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      fontSize: 14,
                    ),
                    dataTextStyle:
                        TextStyle(color: _appText(context), fontSize: 15),
                    columns: columns
                        .map((column) => DataColumn(
                            label: Expanded(
                                child: Text(column,
                                    overflow: TextOverflow.ellipsis))))
                        .toList(),
                    rows: rows
                        .map((row) => DataRow(
                            cells: row.map((cell) => DataCell(cell)).toList()))
                        .toList(),
                  ),
                ),
              ),
              if (footer != null) footer!,
            ],
          );
        },
      ),
    );
  }
}

class _HorizontalScrollView extends StatefulWidget {
  final Widget child;

  const _HorizontalScrollView({required this.child});

  @override
  State<_HorizontalScrollView> createState() => _HorizontalScrollViewState();
}

class _HorizontalScrollViewState extends State<_HorizontalScrollView> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      notificationPredicate: (notification) => notification.depth == 0,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        child: widget.child,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  final bool large;

  const _Chip({
    required this.label,
    required this.color,
    this.filled = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 9 : 5,
      ),
      decoration: BoxDecoration(
        color: filled ? color.withAlpha(85) : color.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: large ? 16 : 12,
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String label;

  const _Label(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.8),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 7, backgroundColor: color),
        const SizedBox(width: 7),
        Text(label),
      ],
    );
  }
}

class _KpiBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _KpiBlock(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 18),
      decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(label),
          Text(value,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _OutlineAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primary,
        side: const BorderSide(color: _primary),
        minimumSize: const Size(150, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
