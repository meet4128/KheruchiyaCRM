import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/account_panel/bloc/account_navigation_bloc.dart';
import 'package:travel_crm/features/presentation/account_panel/bloc/account_navigation_event.dart';
import 'package:travel_crm/features/presentation/account_panel/bloc/account_navigation_state.dart';

class AccountSideMenu extends StatelessWidget {
  const AccountSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountNavigationBloc, AccountNavigationState>(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                          context.read<AccountNavigationBloc>().add(
                                AccountDrawerToggled(!state.isDrawerCollapsed),
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
                      _AccountMenuTile(
                        menu: AccountMenu.dashboard,
                        iconAsset: AssetConstants.icDashboard,
                        collapsed: state.isDrawerCollapsed,
                      ),
                      _AccountMenuTile(
                        menu: AccountMenu.upcoming,
                        iconAsset: AssetConstants.icClock,
                        collapsed: state.isDrawerCollapsed,
                      ),
                      _AccountMenuTile(
                        menu: AccountMenu.pastSevenDays,
                        iconAsset: AssetConstants.icCalendar,
                        collapsed: state.isDrawerCollapsed,
                      ),
                      _AccountMenuTile(
                        menu: AccountMenu.unverified,
                        iconAsset: AssetConstants.icReminders,
                        collapsed: state.isDrawerCollapsed,
                        badgeCount: state.unverifiedCount,
                      ),
                      _AccountMenuTile(
                        menu: AccountMenu.paid,
                        iconAsset: AssetConstants.icPayments,
                        collapsed: state.isDrawerCollapsed,
                      ),
                      _AccountMenuTile(
                        menu: AccountMenu.overdue,
                        iconAsset: AssetConstants.icTimer,
                        collapsed: state.isDrawerCollapsed,
                      ),
                      _AccountMenuTile(
                        menu: AccountMenu.all,
                        iconAsset: AssetConstants.icInvoices,
                        collapsed: state.isDrawerCollapsed,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: AppColors.dark().borderPrimary.withValues(alpha: 0.65),
                  height: 1,
                ),
                _AccountMenuTile(
                  menu: AccountMenu.settings,
                  iconAsset: AssetConstants.icSetting,
                  collapsed: state.isDrawerCollapsed,
                ),
                _LogoutTile(collapsed: state.isDrawerCollapsed),
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
            context
                .read<AccountNavigationBloc>()
                .add(const AccountLogoutRequested());
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

class _AccountMenuTile extends StatelessWidget {
  const _AccountMenuTile({
    required this.menu,
    required this.iconAsset,
    required this.collapsed,
    this.badgeCount = 0,
  });

  final AccountMenu menu;
  final String iconAsset;
  final bool collapsed;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountNavigationBloc, AccountNavigationState>(
      buildWhen: (previous, current) =>
          previous.currentMenu != current.currentMenu,
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
                context
                    .read<AccountNavigationBloc>()
                    .add(AccountMenuChanged(menu));
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (badgeCount > 0) _NewBadge(count: badgeCount),
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

class _NewBadge extends StatelessWidget {
  const _NewBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.dark().secondary.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.dark().secondary.withValues(alpha: 0.65),
        ),
      ),
      child: Text(
        '$count New',
        style: TextStyle(
          color: AppColors.dark().textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
