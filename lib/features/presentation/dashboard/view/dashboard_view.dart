import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/features/presentation/dashboard/bloc/navigation_state.dart';
import '../bloc/navigation_bloc.dart';
import '../widgets/side_menu.dart';
import '../widgets/web_content.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationBloc(),
      child: const _DashboardLayout(),
    );
  }
}

class _DashboardLayout extends StatelessWidget {
  const _DashboardLayout();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final bool isCollapsed = box.maxWidth < 900;

        return BlocBuilder<NavigationBloc,NavigationState>(
          builder: (context,state) {
            return Scaffold(
              body: Row(
                children: [
                  SideMenu(isCollapsed: isCollapsed,state: state),
                  const Expanded(child: WebContent()),
                ],
              ),
            );
          }
        );
      },
    );
  }
}
