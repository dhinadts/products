import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_scaffold.dart';

class CompanyDetailsPage extends StatelessWidget {
  const CompanyDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Company Details',
      child: ListView(
        padding: Responsive.pagePadding(context),
        children: const [
          SectionHeader(title: 'Company Details'),
          SizedBox(height: 18),
          Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.companyName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'IT solutions, support, billing, ledger, and business software services.',
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Business dashboard prepared for scalable mobile, tablet, and web workflows.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
