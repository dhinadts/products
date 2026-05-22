// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../models/backend_models.dart';
import '../services/backend_api.dart';
import '../state/auth_cubit.dart';

part 'screen_router.dart';
part 'app_shell.dart';
part 'dashboard_screen.dart';
part 'ledger_screen.dart';
part 'reports_screen.dart';
part 'balance_sheet_screen.dart';
part 'settings_screen.dart';
part 'notifications_screen.dart';
part 'help_profile_screen.dart';
part 'common_widgets.dart';

const _primary = Color(0xFF000666);
const _primaryContainer = Color(0xFF1A237E);
const _green = Color(0xFF1B6D24);
const _red = Color(0xFFC31318);
const _softSurface = Color(0xFFF5F2FB);
const _border = Color(0xFFC6C5D4);
const _text = Color(0xFF1B1B21);
const _muted = Color(0xFF454652);

final _backendApi = BackendApi();

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _appBackground(BuildContext context) =>
    Theme.of(context).scaffoldBackgroundColor;

Color _appSurface(BuildContext context) => Theme.of(context).cardColor;

Color _appSoftSurface(BuildContext context) =>
    _isDark(context) ? const Color(0xFF1A2338) : _softSurface;

Color _appHeaderSurface(BuildContext context) =>
    _isDark(context) ? const Color(0xFF202A40) : const Color(0xFFEDEAF3);

Color _appBorder(BuildContext context) =>
    _isDark(context) ? const Color(0xFF334155) : _border;

Color _appText(BuildContext context) => Theme.of(context).colorScheme.onSurface;

Color _appMuted(BuildContext context) =>
    _isDark(context) ? const Color(0xFFB6C2D6) : _muted;

Color _appActiveNav(BuildContext context) =>
    _isDark(context) ? const Color(0xFF172044) : const Color(0xFFE4E1F3);

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}

String _formatCurrency(double value) => '₹ ${_formatIndianAmount(value)}';

String _formatIndianAmount(double value) {
  final sign = value < 0 ? '-' : '';
  final fixed = value.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts.first;
  final decimals = parts.last;

  if (whole.length <= 3) {
    return '$sign$whole.$decimals';
  }

  final lastThree = whole.substring(whole.length - 3);
  var leading = whole.substring(0, whole.length - 3);
  final groups = <String>[];

  while (leading.length > 2) {
    groups.insert(0, leading.substring(leading.length - 2));
    leading = leading.substring(0, leading.length - 2);
  }

  if (leading.isNotEmpty) {
    groups.insert(0, leading);
  }

  return '$sign${groups.join(',')},$lastThree.$decimals';
}

class _ResponsiveGrid extends StatelessWidget {
  final double minTileWidth;
  final List<Widget> children;

  const _ResponsiveGrid({required this.minTileWidth, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / minTileWidth)
            .floor()
            .clamp(1, children.length);
        final width = (constraints.maxWidth - ((columns - 1) * 20)) / columns;

        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: children
              .map((child) => SizedBox(width: width.toDouble(), child: child))
              .toList(),
        );
      },
    );
  }
}

class _FakeInput extends StatelessWidget {
  final String text;
  final IconData icon;

  const _FakeInput(this.text, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: _appBorder(context)),
        borderRadius: BorderRadius.circular(4),
        color: _appSurface(context),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text)),
          Icon(icon, size: 18),
        ],
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PageTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(subtitle,
            style: TextStyle(color: _appMuted(context), fontSize: 18)),
      ],
    );
  }
}

class _TwoLineText extends StatelessWidget {
  final String text;

  const _TwoLineText(this.text);

  @override
  Widget build(BuildContext context) {
    final parts = text.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          parts.first,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        if (parts.length > 1)
          Text(parts.last,
              style: TextStyle(color: _appMuted(context), fontSize: 13)),
      ],
    );
  }
}

/* class _AccountColumn extends StatelessWidget {
  final String title;
  final List<_AccountSection> sections;
  final String totalLabel;
  final String total;

  const _AccountColumn({
    required this.title,
    required this.sections,
    required this.totalLabel,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _appHeaderSurface(context),
              border: Border(
                top: BorderSide(color: _appBorder(context)),
                right: BorderSide(color: _appBorder(context)),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
            child: Row(
              children: [
                Expanded(
                    child: Text(title,
                        style: const TextStyle(color: _primary, fontSize: 18))),
                const Text('AMOUNT (₹)',
                    style: TextStyle(color: _primary, fontSize: 18)),
              ],
            ),
          ),
          ...sections.map(
            (section) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.title,
                      style: const TextStyle(
                          color: _primary, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  ...section.rows.map(
                    (row) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          Expanded(child: Text(row[0])),
                          Text(row[1], textAlign: TextAlign.right),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: _primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    totalLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    total,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 */
