import 'package:equatable/equatable.dart';

enum NavPage {
  dashboard,
  inquiryManagement,
  clientLeads,
  vendorList,
  inquiry,
  messages,
  projectJobs,
  invoices,
  payments,
  inventory,
  team,
  reminders,
  analysis,
}

abstract class NavigationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChangePageEvent extends NavigationEvent {
  final NavPage page;

  ChangePageEvent(this.page);

  @override
  List<Object?> get props => [page];
}

class SyncPageFromRouteEvent extends NavigationEvent {
  final NavPage page;
  SyncPageFromRouteEvent(this.page);
  @override
  List<Object?> get props => [page];
}

class OpenCloseDrawerEvent extends NavigationEvent {
  final bool isDrawerOpen;

  OpenCloseDrawerEvent(this.isDrawerOpen);

  @override
  List<Object?> get props => [isDrawerOpen];
}

class UserLogoutRequested extends NavigationEvent {
  @override
  List<Object?> get props => [];
}

class UserLogoutConfirmed extends NavigationEvent {
  @override
  List<Object?> get props => [];
}

class UserLogoutCancelled extends NavigationEvent {
  @override
  List<Object?> get props => [];
}

class UserLogoutStatusReset extends NavigationEvent {
  @override
  List<Object?> get props => [];
}