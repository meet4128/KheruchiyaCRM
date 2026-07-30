import 'package:flutter/material.dart';
import 'package:travel_crm/core/theme/app_colors.dart';

class AccountPlaceholderContent extends StatelessWidget {
  const AccountPlaceholderContent({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 72,
            color: AppColors.dark().textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: AppColors.dark().textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Accounting Content Coming Soon',
            style: TextStyle(
              color: AppColors.dark().textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
