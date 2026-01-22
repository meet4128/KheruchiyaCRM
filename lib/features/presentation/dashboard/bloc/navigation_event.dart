import 'package:equatable/equatable.dart';

enum NavPage {
  dashboard,
  inquiryManagement,
  clientLeads,
  inquiry,
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
