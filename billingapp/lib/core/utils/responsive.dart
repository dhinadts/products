import 'package:flutter/widgets.dart';

enum DeviceType { mobile, tablet, desktop }

class Responsive {
  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1024) return DeviceType.desktop;
    if (width >= 700) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool isMobile(BuildContext context) =>
      deviceType(context) == DeviceType.mobile;

  static double maxContentWidth(BuildContext context) {
    return switch (deviceType(context)) {
      DeviceType.mobile => double.infinity,
      DeviceType.tablet => 860,
      DeviceType.desktop => 1180,
    };
  }

  static EdgeInsets pagePadding(BuildContext context) {
    return switch (deviceType(context)) {
      DeviceType.mobile => const EdgeInsets.all(16),
      DeviceType.tablet => const EdgeInsets.all(24),
      DeviceType.desktop => const EdgeInsets.all(32),
    };
  }
}
