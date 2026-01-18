import 'package:flutter/material.dart';
import '../widgets/side_menu.dart';

class DashboardShell extends StatelessWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isCollapsedByWidth = constraints.maxWidth < 900;
      return Scaffold(
        body: Row(
          children: [
            SideMenu(isCollapsed: isCollapsedByWidth),
            Expanded(child: child),
          ],
        ),
      );
    });
  }
}
