import 'package:flutter/material.dart';
import 'package:travel_crm/core/theme/app_colors.dart';

class TeamMembersHeader extends StatelessWidget {
  const TeamMembersHeader({super.key, required this.onAddMembersTap});

  final VoidCallback onAddMembersTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Team Members',
                style: TextStyle(
                  color: AppColors.dark().textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage your members and edit their roles and permissions.',
                style: TextStyle(
                  color: AppColors.dark().textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: onAddMembersTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dark().secondary,
            foregroundColor: AppColors.dark().textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Add Members'),
        ),
      ],
    );
  }
}
