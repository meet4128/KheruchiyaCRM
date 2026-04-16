import 'package:flutter/material.dart';
import 'package:travel_crm/core/theme/app_colors.dart';

class RoleSummaryPanel extends StatelessWidget {
  const RoleSummaryPanel({super.key, required this.memberCount});

  final int memberCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.dark().backgroundMedium,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dark().borderPrimary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin ($memberCount)',
            style: TextStyle(
              color: AppColors.dark().textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Manage user accounts, permissions, and access levels within the app to ensure smooth operation and security.',
            style: TextStyle(
              color: AppColors.dark().textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
