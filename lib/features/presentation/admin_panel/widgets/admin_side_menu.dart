import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/admin_panel/bloc/admin_navigation_bloc.dart';
import 'package:travel_crm/features/presentation/admin_panel/bloc/admin_navigation_event.dart';
import 'package:travel_crm/features/presentation/admin_panel/bloc/admin_navigation_state.dart';

class AdminSideMenu extends StatelessWidget {
  const AdminSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminNavigationBloc, AdminNavigationState>(
      builder: (context, state) {
        return Container(
          width: state.isDrawerCollapsed ? 84 : 260,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.dark().primaryDark,
                AppColors.dark().primaryMedium,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Image.asset(
                          AssetConstants.icCRMLogoNew,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<AdminNavigationBloc>().add(
                                AdminDrawerToggled(!state.isDrawerCollapsed),
                              );
                        },
                        icon: Icon(
                          state.isDrawerCollapsed
                              ? Icons.keyboard_double_arrow_right_rounded
                              : Icons.keyboard_double_arrow_left_rounded,
                          color: AppColors.dark().textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: AppColors.dark().borderPrimary.withValues(alpha: 0.65),
                  height: 1,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: [
                      _AdminMenuTile(
                        menu: AdminMenu.dashboard,
                        iconAsset: AssetConstants.icDashboard,
                        collapsed: state.isDrawerCollapsed,
                      ),
                      _AdminMenuTile(
                        menu: AdminMenu.manageTeam,
                        iconAsset: AssetConstants.icTeams,
                        collapsed: state.isDrawerCollapsed,
                      ),
                      _AdminMenuTile(
                        menu: AdminMenu.invoices,
                        iconAsset: AssetConstants.icInvoices,
                        collapsed: state.isDrawerCollapsed,
                      ),
                      _AdminMenuTile(
                        menu: AdminMenu.payments,
                        iconAsset: AssetConstants.icPayments,
                        collapsed: state.isDrawerCollapsed,
                      ),
                      _AdminMenuTile(
                        menu: AdminMenu.inventory,
                        iconAsset: AssetConstants.icInventory,
                        collapsed: state.isDrawerCollapsed,
                      ),
                      _AdminMenuTile(
                        menu: AdminMenu.team,
                        iconAsset: AssetConstants.icTeams,
                        collapsed: state.isDrawerCollapsed,
                      ),
                      _AdminMenuTile(
                        menu: AdminMenu.reminders,
                        iconAsset: AssetConstants.icReminders,
                        collapsed: state.isDrawerCollapsed,
                      ),
                      _AdminMenuTile(
                        menu: AdminMenu.analytics,
                        iconAsset: AssetConstants.icAnalytics,
                        collapsed: state.isDrawerCollapsed,
                      ),
                      _LogoutTile(collapsed: state.isDrawerCollapsed),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            context.read<AdminNavigationBloc>().add(const AdminLogoutRequested());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: AppColors.dark().textSecondary,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Logout',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.dark().textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminMenuTile extends StatelessWidget {
  const _AdminMenuTile({
    required this.menu,
    required this.iconAsset,
    required this.collapsed,
  });

  final AdminMenu menu;
  final String iconAsset;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminNavigationBloc, AdminNavigationState>(
      buildWhen: (previous, current) => previous.currentMenu != current.currentMenu,
      builder: (context, state) {
        final selected = state.currentMenu == menu;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Material(
            color: selected
                ? AppColors.dark().secondary.withValues(alpha: 0.24)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                context.read<AdminNavigationBloc>().add(AdminMenuChanged(menu));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      iconAsset,
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        selected
                            ? AppColors.dark().textPrimary
                            : AppColors.dark().textSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    if (!collapsed) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          menu.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? AppColors.dark().textPrimary
                                : AppColors.dark().textSecondary,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
