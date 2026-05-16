import 'package:equatable/equatable.dart';
import 'navigation_event.dart';

enum UserLogoutStatus {
  idle,
  confirmationRequired,
  inProgress,
  success,
}

class NavigationState extends Equatable {
  final NavPage currentPage;
  final bool isDrawerOpen;
  final UserLogoutStatus logoutStatus;

  const NavigationState({
    this.currentPage = NavPage.dashboard,
    this.isDrawerOpen = true,
    this.logoutStatus = UserLogoutStatus.idle,
  });

  NavigationState copyWith({
    NavPage? currentPage,
    bool? isDrawerOpen,
    UserLogoutStatus? logoutStatus,
  }) {
    return NavigationState(
      currentPage: currentPage ?? this.currentPage,
      isDrawerOpen: isDrawerOpen ?? this.isDrawerOpen,
      logoutStatus: logoutStatus ?? this.logoutStatus,
    );
  }

  @override
  List<Object?> get props => [currentPage, isDrawerOpen, logoutStatus];
}
