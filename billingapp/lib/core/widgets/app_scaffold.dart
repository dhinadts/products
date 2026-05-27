import 'package:flutter/material.dart';

import '../ads/banner_ad_widget.dart';
import '../constants/app_constants.dart';
import '../utils/responsive.dart';
import '../../features/dashboard/presentation/widgets/company_drawer.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.floatingActionButton,
    this.showDrawer = true,
  });

  final String title;
  final Widget child;
  final Widget? floatingActionButton;
  final bool showDrawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: showDrawer ? const CompanyDrawer() : null,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Responsive.maxContentWidth(context),
                      ),
                      child: child,
                    ),
                  ),
                ),
                if (floatingActionButton != null)
                  _MovableFab(child: floatingActionButton!),
              ],
            ),
          ),
          const SafeArea(top: false, child: BannerAdWidget()),
        ],
      ),
    );
  }
}

class _MovableFab extends StatefulWidget {
  const _MovableFab({required this.child});

  final Widget child;

  @override
  State<_MovableFab> createState() => _MovableFabState();
}

class _MovableFabState extends State<_MovableFab> {
  Offset? _position;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const size = 58.0;
          const margin = 16.0;
          final fallback = Offset(
            constraints.maxWidth - size - margin,
            constraints.maxHeight - size - margin,
          );
          final position = _clamp(_position ?? fallback, constraints, size);
          return Stack(
            children: [
              Positioned(
                left: position.dx,
                top: position.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _position = _clamp(
                        position + details.delta,
                        constraints,
                        size,
                      );
                    });
                  },
                  child: SizedBox.square(
                    dimension: size,
                    child: FittedBox(child: widget.child),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Offset _clamp(Offset value, BoxConstraints constraints, double size) {
    return Offset(
      value.dx.clamp(8.0, constraints.maxWidth - size - 8.0).toDouble(),
      value.dy.clamp(8.0, constraints.maxHeight - size - 8.0).toDouble(),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle = AppConstants.companyName,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
