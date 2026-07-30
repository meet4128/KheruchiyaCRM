import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/account_panel/bloc/account_navigation_bloc.dart';
import 'package:travel_crm/features/presentation/account_panel/bloc/account_navigation_event.dart';
import 'package:travel_crm/features/presentation/account_panel/bloc/account_navigation_state.dart';
import 'package:travel_crm/features/presentation/account_panel/payments/view/unverified_payments_screen.dart';
import 'package:travel_crm/features/presentation/account_panel/widgets/account_placeholder_content.dart';
import 'package:travel_crm/features/presentation/account_panel/widgets/account_side_menu.dart';

class AccountPanelShell extends StatelessWidget {
  const AccountPanelShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountNavigationBloc, AccountNavigationState>(
      listenWhen: (previous, current) =>
          previous.logoutStatus != current.logoutStatus,
      listener: (context, state) async {
        if (state.logoutStatus == AccountLogoutStatus.confirmationRequired) {
          final confirmed = await _showLogoutConfirmationDialog(context);
          if (!context.mounted) return;
          context.read<AccountNavigationBloc>().add(
                confirmed
                    ? const AccountLogoutConfirmed()
                    : const AccountLogoutCancelled(),
              );
          return;
        }

        if (state.logoutStatus == AccountLogoutStatus.success) {
          if (!context.mounted) return;
          context.go(PathConstant.login);
          context
              .read<AccountNavigationBloc>()
              .add(const AccountLogoutStatusReset());
        }
      },
      child: Scaffold(
        body: Row(
          children: [
            const AccountSideMenu(),
            Expanded(
              child: Container(
                color: AppColors.dark().backgroundDark,
                child: BlocBuilder<AccountNavigationBloc, AccountNavigationState>(
                  buildWhen: (previous, current) =>
                      previous.currentMenu != current.currentMenu,
                  builder: (context, state) {
                    if (state.currentMenu == AccountMenu.unverified) {
                      return const UnverifiedPaymentsScreen();
                    }
                    return AccountPlaceholderContent(
                      title: state.currentMenu.label,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.dark().backgroundMedium,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            'Confirm Logout',
            style: TextStyle(
              color: AppColors.dark().textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to logout from Accounting?',
            style: TextStyle(color: AppColors.dark().textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.dark().textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark().secondary,
                foregroundColor: AppColors.dark().textPrimary,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
