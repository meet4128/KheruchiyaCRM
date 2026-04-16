import 'package:flutter/material.dart';
import 'package:travel_crm/core/theme/app_colors.dart';

class RoleSummaryPanel extends StatelessWidget {
  const RoleSummaryPanel({
    super.key,
    required this.title,
    required this.memberCount,
    required this.description,
  });

  final String title;
  final int memberCount;
  final String description;

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
            '$title ($memberCount)',
            style: TextStyle(
              color: AppColors.dark().textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
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
