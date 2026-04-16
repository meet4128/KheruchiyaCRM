import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/admin_panel/bloc/admin_navigation_bloc.dart';
import 'package:travel_crm/features/presentation/admin_panel/bloc/admin_navigation_event.dart';
import 'package:travel_crm/features/presentation/admin_panel/bloc/admin_navigation_state.dart';
import 'package:travel_crm/features/presentation/admin_panel/widgets/admin_placeholder_content.dart';
import 'package:travel_crm/features/presentation/admin_panel/widgets/admin_side_menu.dart';

class AdminPanelShell extends StatelessWidget {
  const AdminPanelShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminNavigationBloc, AdminNavigationState>(
      listenWhen: (previous, current) => previous.logoutStatus != current.logoutStatus,
      listener: (context, state) async {
        if (state.logoutStatus == AdminLogoutStatus.confirmationRequired) {
          final confirmed = await _showLogoutConfirmationDialog(context);
          if (!context.mounted) return;
          context.read<AdminNavigationBloc>().add(
                confirmed ? const AdminLogoutConfirmed() : const AdminLogoutCancelled(),
              );
          return;
        }

        if (state.logoutStatus == AdminLogoutStatus.success) {
          if (!context.mounted) return;
          context.go('/login');
          context.read<AdminNavigationBloc>().add(const AdminLogoutStatusReset());
        }
      },
      child: Scaffold(
        body: Row(
          children: [
            const AdminSideMenu(),
            Expanded(
              child: Container(
                color: AppColors.dark().backgroundDark,
                child: BlocBuilder<AdminNavigationBloc, AdminNavigationState>(
                  builder: (context, state) {
                    return AdminPlaceholderContent(title: state.currentMenu.label);
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
            'Are you sure you want to logout from Admin Panel?',
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
