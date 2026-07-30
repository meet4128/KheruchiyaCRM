import 'package:equatable/equatable.dart';

enum AccountMenu {
  dashboard,
  upcoming,
  pastSevenDays,
  unverified,
  paid,
  overdue,
  all,
  settings,
}

enum AccountLogoutStatus {
  idle,
  confirmationRequired,
  inProgress,
  success,
}

extension AccountMenuX on AccountMenu {
  String get label {
    switch (this) {
      case AccountMenu.dashboard:
        return 'Dashboard';
      case AccountMenu.upcoming:
        return 'Upcoming';
      case AccountMenu.pastSevenDays:
        return 'Past 7 Days';
      case AccountMenu.unverified:
        return 'Unverified';
      case AccountMenu.paid:
        return 'Paid';
      case AccountMenu.overdue:
        return 'Overdue';
      case AccountMenu.all:
        return 'All';
      case AccountMenu.settings:
        return 'Settings';
    }
  }
}

class AccountNavigationState extends Equatable {
  const AccountNavigationState({
    this.currentMenu = AccountMenu.dashboard,
    this.isDrawerCollapsed = false,
    this.unverifiedCount = 0,
    this.logoutStatus = AccountLogoutStatus.idle,
  });

  final AccountMenu currentMenu;
  final bool isDrawerCollapsed;

  /// Count shown as the "New" badge next to the Unverified menu item. Zero
  /// hides the badge. Wired through the bloc so it can be driven by API data
  /// later without touching the widget.
  final int unverifiedCount;
  final AccountLogoutStatus logoutStatus;

  AccountNavigationState copyWith({
    AccountMenu? currentMenu,
    bool? isDrawerCollapsed,
    int? unverifiedCount,
    AccountLogoutStatus? logoutStatus,
  }) {
    return AccountNavigationState(
      currentMenu: currentMenu ?? this.currentMenu,
      isDrawerCollapsed: isDrawerCollapsed ?? this.isDrawerCollapsed,
      unverifiedCount: unverifiedCount ?? this.unverifiedCount,
      logoutStatus: logoutStatus ?? this.logoutStatus,
    );
  }

  @override
  List<Object?> get props => [
        currentMenu,
        isDrawerCollapsed,
        unverifiedCount,
        logoutStatus,
      ];
}
