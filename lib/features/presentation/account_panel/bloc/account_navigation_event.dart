import 'package:equatable/equatable.dart';
import 'account_navigation_state.dart';

abstract class AccountNavigationEvent extends Equatable {
  const AccountNavigationEvent();

  @override
  List<Object?> get props => [];
}

class AccountMenuChanged extends AccountNavigationEvent {
  const AccountMenuChanged(this.menu);

  final AccountMenu menu;

  @override
  List<Object?> get props => [menu];
}

class AccountDrawerToggled extends AccountNavigationEvent {
  const AccountDrawerToggled(this.isCollapsed);

  final bool isCollapsed;

  @override
  List<Object?> get props => [isCollapsed];
}

/// Updates the "New" badge next to the Unverified menu item. Dispatched by the
/// unverified-payments screen with the latest `totalItems` count.
class AccountUnverifiedCountUpdated extends AccountNavigationEvent {
  const AccountUnverifiedCountUpdated(this.count);

  final int count;

  @override
  List<Object?> get props => [count];
}

class AccountLogoutRequested extends AccountNavigationEvent {
  const AccountLogoutRequested();
}

class AccountLogoutConfirmed extends AccountNavigationEvent {
  const AccountLogoutConfirmed();
}

class AccountLogoutCancelled extends AccountNavigationEvent {
  const AccountLogoutCancelled();
}

class AccountLogoutStatusReset extends AccountNavigationEvent {
  const AccountLogoutStatusReset();
}
