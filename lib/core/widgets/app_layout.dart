import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_sidebar.dart';

/// Reusable layout widget for desktop/web screens
/// Provides a left sidebar navigation and main content area
class AppLayout extends StatelessWidget {
  const AppLayout({
    super.key,
    required this.child,
    required this.sidebarMenuItems,
    this.selectedMenuItemId,
    this.onMenuItemSelected,
    this.sidebarWidth = 280,
    this.sidebarHeader,
    this.sidebarFooter,
    this.contentPadding,
    this.showSidebar = true,
  });

  /// Main content widget
  final Widget child;

  /// Sidebar menu items
  final List<SidebarMenuItem> sidebarMenuItems;

  /// Currently selected menu item ID
  final String? selectedMenuItemId;

  /// Callback when a menu item is selected
  final ValueChanged<String>? onMenuItemSelected;

  /// Sidebar width
  final double sidebarWidth;

  /// Optional sidebar header widget
  final Widget? sidebarHeader;

  /// Optional sidebar footer widget
  final Widget? sidebarFooter;

  /// Padding for the content area
  final EdgeInsets? contentPadding;

  /// Whether to show the sidebar (useful for responsive design)
  final bool showSidebar;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.gradientBackground,
        ),
        child: Row(
        children: [
          // Sidebar
          if (showSidebar)
            AppSidebar(
              menuItems: sidebarMenuItems,
              selectedItemId: selectedMenuItemId,
              onItemSelected: onMenuItemSelected,
              width: sidebarWidth,
              header: sidebarHeader,
              footer: sidebarFooter,
            ),

          // Main Content Area
          Expanded(
            child: Padding(
              padding: contentPadding ??
                  const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ],
        ),
      ),
    );
  }
}

