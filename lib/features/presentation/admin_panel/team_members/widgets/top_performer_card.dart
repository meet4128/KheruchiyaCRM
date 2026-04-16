import 'package:flutter/material.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_state.dart';

class TopPerformerCard extends StatelessWidget {
  const TopPerformerCard({
    super.key,
    required this.performers,
  });

  final List<TopPerformerUiModel> performers;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dark().backgroundMedium,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dark().borderPrimary.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.dark().primaryDark.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Name',
                    style: TextStyle(
                      color: AppColors.dark().textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'Team',
                  style: TextStyle(
                    color: AppColors.dark().textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...performers.map(
            (performer) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      performer.name,
                      style: TextStyle(
                        color: AppColors.dark().textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    performer.team,
                    style: TextStyle(
                      color: AppColors.dark().textSecondary,
                      fontSize: 12,
                    ),
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
