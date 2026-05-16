import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/utils/shared_pref_utils.dart';
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

    on<OpenCloseDrawerEvent>((event, emit) {
      if (event.isDrawerOpen != state.isDrawerOpen) {
        emit(state.copyWith(isDrawerOpen: event.isDrawerOpen));
      }
    });

    on<UserLogoutRequested>((event, emit) {
      emit(state.copyWith(logoutStatus: UserLogoutStatus.confirmationRequired));
    });

    on<UserLogoutCancelled>((event, emit) {
      emit(state.copyWith(logoutStatus: UserLogoutStatus.idle));
    });

    on<UserLogoutConfirmed>((event, emit) async {
      emit(state.copyWith(logoutStatus: UserLogoutStatus.inProgress));
      await SharedPrefUtils.clearSharedPref();
      emit(state.copyWith(logoutStatus: UserLogoutStatus.success));
    });

    on<UserLogoutStatusReset>((event, emit) {
      if (state.logoutStatus != UserLogoutStatus.idle) {
        emit(state.copyWith(logoutStatus: UserLogoutStatus.idle));
      }
    });
  }
}
