import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import '../bloc/navigation_bloc.dart';
import '../bloc/navigation_event.dart';
import '../bloc/navigation_state.dart';

class SideMenu extends StatefulWidget {
  final bool isCollapsed;

  const SideMenu({super.key, required this.isCollapsed});

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
    final navBloc = context.watch<NavigationBloc>();
    final state = navBloc.state;

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
              Color(0xFF1A0B2E), // Deep dark purple
              Color(0xFF2D1B4E), // Medium purple
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
                    FlutterLogo(size: 36),
                    if (!effectiveCollapsed) ...[
                      const SizedBox(width: 12),
                      const Text(
                        StringConstant.myCRM,
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),

              Divider(
                color: Color(0xFF3D3551).withOpacity(0.5),
                height: 1,
                thickness: 1,
              ),

              // menu
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _menuItem(context, Icons.dashboard, PathConstant.dashboardConstant, NavPage.dashboard, state),
                      _menuItem(context, Icons.person_search, PathConstant.clientLeadsConstant, NavPage.clientLeads, state),
                      _menuItem(context, Icons.work_outline, PathConstant.projectJobsConstant, NavPage.projectJobs, state),
                      _menuItem(context, Icons.receipt_long, PathConstant.invoicesConstant, NavPage.invoices, state),
                      _menuItem(context, Icons.payment, PathConstant.paymentsConstant, NavPage.payments, state),
                      _menuItem(context, Icons.inventory_2, PathConstant.invoicesConstant, NavPage.inventory, state),
                      _menuItem(context, Icons.group, PathConstant.teamConstant, NavPage.team, state),
                      _menuItem(context, Icons.alarm, PathConstant.remindersConstant, NavPage.reminders, state),
                      _menuItem(context, Icons.analytics, PathConstant.analysisConstant, NavPage.analysis, state),
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

  Widget _menuItem(BuildContext context, IconData icon, String title, NavPage page, NavigationState state) {
    final selected = state.currentPage == page;
    final collapsed = effectiveCollapsed;
    return Material(
      color: selected ? Color(0xFF4A2C6B).withOpacity(0.5) : Colors.transparent,
      child: InkWell(
        onTap: () => context.read<NavigationBloc>().add(ChangePageEvent(page)),
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(icon, color: Colors.white),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: const TextStyle(color: Colors.white)),
                ),
                if (selected)
                  const Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: Icon(Icons.chevron_right, color: Colors.white70),
                  )
                else
                  const SizedBox(width: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
