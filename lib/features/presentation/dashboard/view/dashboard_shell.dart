import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/features/presentation/dashboard/bloc/navigation_bloc.dart';
import 'package:travel_crm/features/presentation/dashboard/bloc/navigation_event.dart';
import 'package:travel_crm/features/presentation/dashboard/bloc/navigation_state.dart';
import '../widgets/side_menu.dart';

class DashboardShell extends StatelessWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      listenWhen: (previous, current) => previous.logoutStatus != current.logoutStatus,
      listener: (context, state) async {
        if (state.logoutStatus == UserLogoutStatus.confirmationRequired) {
          final confirmed = await _showLogoutConfirmationDialog(context);
          if (!context.mounted) return;
          context.read<NavigationBloc>().add(
                confirmed ? UserLogoutConfirmed() : UserLogoutCancelled(),
              );
          return;
        }

        if (state.logoutStatus == UserLogoutStatus.success) {
          if (!context.mounted) return;
          context.go(PathConstant.login);
          context.read<NavigationBloc>().add(UserLogoutStatusReset());
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCollapsedByWidth = constraints.maxWidth < 900;
          return Scaffold(
            body: BlocBuilder<NavigationBloc, NavigationState>(
              builder: (context, state) {
                return Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: state.isDrawerOpen ? 250 : 0,
                      child: SideMenu(
                        isCollapsed: isCollapsedByWidth,
                        state: state,
                      ),
                    ),
                    Expanded(child: child),
                  ],
                );
              },
            ),
          );
        },
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
            'Are you sure you want to logout?',
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
