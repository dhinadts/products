import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_scaffold.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Privacy Policy',
      child: ListView(
        padding: Responsive.pagePadding(context),
        children: const [
          SectionHeader(
            title: 'Privacy Policy',
            subtitle: AppConstants.appName,
          ),
          SizedBox(height: 18),
          Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'DHINADTS Billing stores operational billing data locally on your device using SQLite. The app uses Google Mobile Ads test configuration during development. No production ad unit IDs are included. Review and replace this policy with your final legal text before publishing.',
                style: TextStyle(height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
