import 'package:flutter/material.dart';

const billNavy = Color(0xFF001B33);
const billBg = Color(0xFFF3F8FC);
const billBorder = Color(0xFFC2CAD4);
const billMuted = Color(0xFF6F7680);
const billBlue = Color(0xFFB8DCFF);

bool isBillMobile(BuildContext context) =>
    MediaQuery.sizeOf(context).width < 700;

bool isBillDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color billPageBg(BuildContext context) =>
    isBillDark(context) ? const Color(0xFF0E141B) : billBg;

Color billSurface(BuildContext context) =>
    isBillDark(context) ? const Color(0xFF17212B) : Colors.white;

Color billSurfaceAlt(BuildContext context) =>
    isBillDark(context) ? const Color(0xFF202B36) : const Color(0xFFF1F5F9);

Color billPrimaryText(BuildContext context) =>
    isBillDark(context) ? const Color(0xFFEAF2FA) : billNavy;

Color billBodyText(BuildContext context) =>
    isBillDark(context) ? const Color(0xFFD6DEE7) : const Color(0xFF343941);

Color billSecondaryText(BuildContext context) =>
    isBillDark(context) ? const Color(0xFF9EADBA) : billMuted;

Color billLine(BuildContext context) =>
    isBillDark(context) ? const Color(0xFF2B3844) : billBorder;

class BillTopBar extends StatelessWidget {
  const BillTopBar({
    super.key,
    required this.avatar,
    this.showBell = false,
    this.trailingInitials,
  });

  final String avatar;
  final bool showBell;
  final String? trailingInitials;

  @override
  Widget build(BuildContext context) {
    final mobile = isBillMobile(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(mobile ? 16 : 16, mobile ? 8 : 8, 16, 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              avatar,
              width: mobile ? 48 : 40,
              height: mobile ? 48 : 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: mobile ? 48 : 40,
                height: mobile ? 48 : 40,
                decoration: BoxDecoration(
                  color: billNavy,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.store, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'BillMaster GST',
            style: TextStyle(
              fontSize: mobile ? 24 : 20,
              fontWeight: FontWeight.w900,
              color: billNavy,
            ),
          ),
          const Spacer(),
          const Icon(Icons.search, size: 26, color: billNavy),
          if (showBell) ...[
            const SizedBox(width: 24),
            const Icon(Icons.notifications_none, size: 24, color: billNavy),
          ],
          if (trailingInitials != null) ...[
            const SizedBox(width: 18),
            CircleAvatar(
              radius: mobile ? 16 : 16,
              backgroundColor: billNavy,
              child: Text(
                trailingInitials!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BillCard extends StatelessWidget {
  const BillCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color == Colors.white ? billSurface(context) : color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: billLine(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isBillDark(context) ? .18 : .04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class BillSearchField extends StatelessWidget {
  const BillSearchField({super.key, required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isBillMobile(context) ? 52 : 58,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: billSurface(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: billLine(context)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: billSecondaryText(context)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hint,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isBillMobile(context) ? 15 : 16,
                color: billSecondaryText(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.text,
    required this.foreground,
    required this.background,
  });

  final String text;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class HelpTooltip extends StatelessWidget {
  const HelpTooltip({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      child: Icon(
        Icons.help_outline,
        size: 18,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: .72),
      ),
    );
  }
}

class WebPageTitle extends StatelessWidget {
  const WebPageTitle({
    super.key,
    required this.title,
    required this.help,
    this.subtitle,
  });

  final String title;
  final String help;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: billPrimaryText(context),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(color: billSecondaryText(context)),
                ),
              ],
            ],
          ),
        ),
        HelpTooltip(message: help),
      ],
    );
  }
}
