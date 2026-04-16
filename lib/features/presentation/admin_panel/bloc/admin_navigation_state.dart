import 'package:equatable/equatable.dart';

enum AdminMenu {
  dashboard,
  manageTeam,
  invoices,
  payments,
  inventory,
  team,
  reminders,
  analytics,
}

enum AdminLogoutStatus {
  idle,
  confirmationRequired,
  inProgress,
  success,
}

extension AdminMenuX on AdminMenu {
  String get label {
    switch (this) {
      case AdminMenu.dashboard:
        return 'Dashboard';
      case AdminMenu.manageTeam:
        return 'Manage Team';
      case AdminMenu.invoices:
        return 'Invoices';
      case AdminMenu.payments:
        return 'Payments';
      case AdminMenu.inventory:
        return 'Inventory';
      case AdminMenu.team:
        return 'Team';
      case AdminMenu.reminders:
        return 'Reminders';
      case AdminMenu.analytics:
        return 'Analytics';
    }
  }
}

class AdminNavigationState extends Equatable {
  const AdminNavigationState({
    this.currentMenu = AdminMenu.dashboard,
    this.isDrawerCollapsed = false,
    this.logoutStatus = AdminLogoutStatus.idle,
  });

  final AdminMenu currentMenu;
  final bool isDrawerCollapsed;
  final AdminLogoutStatus logoutStatus;

  AdminNavigationState copyWith({
    AdminMenu? currentMenu,
    bool? isDrawerCollapsed,
    AdminLogoutStatus? logoutStatus,
  }) {
    return AdminNavigationState(
      currentMenu: currentMenu ?? this.currentMenu,
      isDrawerCollapsed: isDrawerCollapsed ?? this.isDrawerCollapsed,
      logoutStatus: logoutStatus ?? this.logoutStatus,
    );
  }

  @override
  List<Object?> get props => [currentMenu, isDrawerCollapsed, logoutStatus];
}
