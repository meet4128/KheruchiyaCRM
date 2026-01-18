import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Menu item model for sidebar navigation
class SidebarMenuItem {
  const SidebarMenuItem({
    required this.id,
    required this.label,
    required this.icon,
    this.route,
    this.onTap,
  });

  /// Unique identifier for the menu item
  final String id;

  /// Display label
  final String label;

  /// Icon data
  final IconData icon;

  /// Optional route path
  final String? route;

  /// Optional onTap callback (takes precedence over route)
  final VoidCallback? onTap;
}

/// Reusable sidebar widget for desktop/web layouts
/// Supports dark gradient background, menu items with icons, and selection states
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.menuItems,
    this.selectedItemId,
    this.onItemSelected,
    this.width = 280,
    this.header,
    this.footer,
  });

  /// List of menu items to display
  final List<SidebarMenuItem> menuItems;

  /// Currently selected item ID
  final String? selectedItemId;

  /// Callback when an item is selected
  final ValueChanged<String>? onItemSelected;

  /// Sidebar width
  final double width;

  /// Optional header widget (e.g., logo, app name)
  final Widget? header;

  /// Optional footer widget (e.g., user profile, settings)
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: AppTheme.gradientBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          if (header != null) ...[
            Container(
              padding: const EdgeInsets.all(24),
              child: header,
            ),
            Divider(
              color: colors.borderSecondary,
              height: 1,
              thickness: 1,
            ),
          ],

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: menuItems.map((item) {
                final isSelected = selectedItemId == item.id;
                return _SidebarMenuItemWidget(
                  item: item,
                  isSelected: isSelected,
                  onTap: () {
                    if (onItemSelected != null) {
                      onItemSelected!(item.id);
                    }
                    if (item.onTap != null) {
                      item.onTap!();
                    }
                  },
                );
              }).toList(),
            ),
          ),

          // Footer
          if (footer != null) ...[
            Divider(
              color: colors.borderSecondary,
              height: 1,
              thickness: 1,
            ),
            Container(
              padding: const EdgeInsets.all(24),
              child: footer,
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual sidebar menu item widget
class _SidebarMenuItemWidget extends StatefulWidget {
  const _SidebarMenuItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final SidebarMenuItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_SidebarMenuItemWidget> createState() => _SidebarMenuItemWidgetState();
}

class _SidebarMenuItemWidgetState extends State<_SidebarMenuItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? colors.secondary.withOpacity(0.2)
                : (_isHovered
                    ? colors.primaryLight.withOpacity(0.1)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: widget.isSelected
                ? Border.all(
                    color: colors.secondary,
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Icon
              Icon(
                widget.item.icon,
                color: widget.isSelected
                    ? colors.secondary
                    : (_isHovered
                        ? colors.textPrimary
                        : colors.textSecondary),
                size: 20,
              ),
              const SizedBox(width: 12),
              // Label
              Expanded(
                child: Text(
                  widget.item.label,
                  style: widget.isSelected
                      ? textStyles.labelLarge.copyWith(
                          color: colors.secondary,
                          fontWeight: FontWeight.w600,
                        )
                      : textStyles.labelLarge.copyWith(
                          color: _isHovered
                              ? colors.textPrimary
                              : colors.textSecondary,
                        ),
                ),
              ),
              // Selected indicator
              if (widget.isSelected)
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}










