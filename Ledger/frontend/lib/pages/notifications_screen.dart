// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/notifications',
      searchHint: 'Search notifications...',
      floatingIcon: Icons.done_all,
      child: _NotificationsContent(),
    );
  }
}

class _NotificationsContent extends StatelessWidget {
  const _NotificationsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PageTitle(
          title: 'Notifications',
          subtitle: 'Latest compliance alerts, ledger activity, and approvals.',
        ),
        const SizedBox(height: 24),
        _Panel(
          padding: EdgeInsets.zero,
          child: FutureBuilder<List<AppNotification>>(
            future: _backendApi.fetchNotifications(),
            builder: (context, snapshot) {
              final notifications = snapshot.data;
              final items = notifications == null
                  ? const <_NotificationItem>[]
                  : notifications.map(_NotificationItem.fromApi).toList();

              if (items.isEmpty) {
                return const _EmptyPanelMessage(
                  icon: Icons.notifications_none,
                  title: 'No notifications yet',
                  subtitle: 'Alerts will appear here after real activity.',
                );
              }

              return Column(
                children:
                    items.map((item) => _NotificationTile(item: item)).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final String title;
  final String detail;
  final String time;
  final Color color;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.detail,
    required this.time,
    required this.color,
  });

  factory _NotificationItem.fromApi(AppNotification notification) {
    IconData icon;
    switch (notification.level) {
      case 'success':
        icon = Icons.payments_outlined;
        break;
      case 'warning':
      case 'error':
        icon = Icons.warning_amber_outlined;
        break;
      default:
        icon = Icons.notifications_active_outlined;
    }

    return _NotificationItem(
      icon: icon,
      title: notification.title,
      detail: notification.detail,
      time: notification.time,
      color: notification.color,
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final _NotificationItem item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _appBorder(context))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, color: item.color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        if (compact)
                          Text(item.time,
                              style: TextStyle(
                                  color: _appMuted(context), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(item.detail,
                        style: TextStyle(color: _appMuted(context))),
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 16),
                Text(item.time,
                    style: TextStyle(color: _appMuted(context), fontSize: 12)),
              ],
            ],
          );
        },
      ),
    );
  }
}
