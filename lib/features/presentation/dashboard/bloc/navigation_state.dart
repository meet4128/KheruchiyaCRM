import 'package:equatable/equatable.dart';
import 'navigation_event.dart';

class NavigationState extends Equatable {
  final NavPage currentPage;

  const NavigationState({required this.currentPage});

  NavigationState copyWith({NavPage? currentPage}) {
    return NavigationState(
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [currentPage];
}
