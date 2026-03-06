import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/features/presentation/dashboard/bloc/navigation_bloc.dart';
import 'package:travel_crm/features/presentation/dashboard/bloc/navigation_state.dart';
import '../widgets/side_menu.dart';

class DashboardShell extends StatelessWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Use the globally provided NavigationBloc (from main.dart) so that
    // router <-> bloc sync via SyncPageFromRouteEvent works correctly.
    return BlocListener<NavigationBloc, NavigationState>(
      listener: (context, state) {},
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
}
