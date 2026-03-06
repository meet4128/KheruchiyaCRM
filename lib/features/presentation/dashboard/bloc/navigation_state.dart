import 'package:equatable/equatable.dart';
import 'navigation_event.dart';

class NavigationState extends Equatable {
  final NavPage currentPage;
  final bool isDrawerOpen;

  const NavigationState({this.currentPage=NavPage.dashboard, this.isDrawerOpen=true});

  NavigationState copyWith({NavPage? currentPage, bool? isDrawerOpen}) {
    return NavigationState(
      currentPage: currentPage ?? this.currentPage,
      isDrawerOpen: isDrawerOpen ?? this.isDrawerOpen,
    );
  }

  @override
  List<Object?> get props => [currentPage,isDrawerOpen];
}
