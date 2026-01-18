import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc()
      : super(const NavigationState(currentPage: NavPage.dashboard)) {
    on<ChangePageEvent>((event, emit) {
      emit(state.copyWith(currentPage: event.page));
    });

    on<SyncPageFromRouteEvent>((event, emit) {
      // Router-to-bloc sync: update bloc without causing route loop
      if (event.page != state.currentPage) {
        emit(state.copyWith(currentPage: event.page));
      }
    });
  }
}
