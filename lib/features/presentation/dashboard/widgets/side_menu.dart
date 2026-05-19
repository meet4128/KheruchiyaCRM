import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import '../../../../core/constants/asset_constants.dart';
import '../bloc/navigation_bloc.dart';
import '../bloc/navigation_event.dart';
import '../bloc/navigation_state.dart';

class SideMenu extends StatefulWidget {
  final bool isCollapsed;
  final NavigationState state;
  const SideMenu({super.key, required this.isCollapsed,required this.state});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> with SingleTickerProviderStateMixin {
  // When user hovers over sidebar, it expands if collapsed.
  bool _hovering = false;
  late final AnimationController _controller;

  // width: collapsedWidth <-> expandedWidth
  static const double collapsedWidth = 70;
  static const double expandedWidth = 260;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get effectiveCollapsed => widget.isCollapsed && !_hovering;

  double get width => effectiveCollapsed ? collapsedWidth : expandedWidth;

  void _setHover(bool hovering) {
    if (_hovering == hovering) return;
    setState(() => _hovering = hovering);
    if (hovering) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: width,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.dark().primaryDark, // Deep dark purple
              AppColors.dark().primaryMedium, // Medium purple
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    //FlutterLogo(size: 36),
                    GestureDetector(
                      onTap: (){
                        context.read<NavigationBloc>().add(OpenCloseDrawerEvent(false));
                      },
                      child: Image.asset(
                        AssetConstants.icCRMLogoNew,
                      ),
                    ),
                    // if (!effectiveCollapsed) ...[
                    //   const SizedBox(width: 12),
                    //   const Text(
                    //     StringConstant.myCRM,
                    //     style: TextStyle(
                    //       color: Colors.white,
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ],
                  ],
                ),
              ),

              Divider(color: AppColors.dark().borderPrimary.withOpacity(0.5), height: 1, thickness: 1),

              // menu
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _menuItem(
                        context,
                        AssetConstants.icDashboard,
                        PathConstant.dashboardConstant,
                        NavPage.dashboard,
                        widget.state,
                      ),
                      _menuItem(
                        context,
                        AssetConstants.icInquiry,
                        PathConstant.inquiryManagementConstant,
                        NavPage.inquiryManagement,
                        widget.state,
                      ),
                      _menuItem(
                        context,
                        AssetConstants.icInquiry,
                        PathConstant.clientLeadsConstant,
                        NavPage.clientLeads,
                        widget.state,
                      ),
                      _menuItem(
                        context,
                        AssetConstants.icMessageText,
                        PathConstant.messagesConstant,
                        NavPage.messages,
                        widget.state,
                      ),
                      _menuItem(
                        context,
                        AssetConstants.icInvoices,
                        PathConstant.invoicesConstant,
                        NavPage.invoices,
                        widget.state,
                      ),
                      _menuItem(
                        context,
                        AssetConstants.icPayments,
                        PathConstant.paymentsConstant,
                        NavPage.payments,
                        widget.state,
                      ),
                      _menuItem(
                        context,
                        AssetConstants.icInventory,
                        PathConstant.inventoryConstant,
                        NavPage.inventory,
                        widget.state,
                      ),
                      _menuItem(
                        context,
                        AssetConstants.icTeams,
                        PathConstant.teamConstant,
                        NavPage.team,
                        widget.state,
                      ),
                      _menuItem(
                        context,
                        AssetConstants.icReminders,
                        PathConstant.remindersConstant,
                        NavPage.reminders,
                        widget.state,
                      ),
                      _menuItem(
                        context,
                        AssetConstants.icAnalytics,
                        PathConstant.analysisConstant,
                        NavPage.analysis,
                        widget.state,
                      ),
                      _logoutItem(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    String assetName,
    String title,
    NavPage page,
    NavigationState state,
  ) {
    final selected = state.currentPage == page;
    final collapsed = effectiveCollapsed;
    return Material(
      color: selected ? AppColors.dark().primaryLight.withOpacity(0.5) : Colors.transparent,
      child: InkWell(
        onTap: (){
          context.read<NavigationBloc>().add(ChangePageEvent(page));
        },
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              const SizedBox(width: 12),
              SvgPicture.asset(
                assetName,
                width: 20,
                  height: 20,
              ),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style:  TextStyle(color: selected?Colors.white:AppColors.dark().textSecondary)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutItem(BuildContext context) {
    final collapsed = effectiveCollapsed;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<NavigationBloc>().add(UserLogoutRequested());
        },
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              const SizedBox(width: 12),
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
                    style: TextStyle(color: AppColors.dark().textSecondary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
