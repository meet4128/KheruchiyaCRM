import 'package:equatable/equatable.dart';
import 'admin_navigation_state.dart';

abstract class AdminNavigationEvent extends Equatable {
  const AdminNavigationEvent();

  @override
  List<Object?> get props => [];
}

class AdminMenuChanged extends AdminNavigationEvent {
  const AdminMenuChanged(this.menu);

  final AdminMenu menu;

  @override
  List<Object?> get props => [menu];
}

class AdminDrawerToggled extends AdminNavigationEvent {
  const AdminDrawerToggled(this.isCollapsed);

  final bool isCollapsed;

  @override
  List<Object?> get props => [isCollapsed];
}

class AdminLogoutRequested extends AdminNavigationEvent {
  const AdminLogoutRequested();
}

class AdminLogoutConfirmed extends AdminNavigationEvent {
  const AdminLogoutConfirmed();
}

class AdminLogoutCancelled extends AdminNavigationEvent {
  const AdminLogoutCancelled();
}

class AdminLogoutStatusReset extends AdminNavigationEvent {
  const AdminLogoutStatusReset();
}
