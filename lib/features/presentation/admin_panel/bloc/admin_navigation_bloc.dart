import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/utils/shared_pref_utils.dart';
import 'admin_navigation_event.dart';
import 'admin_navigation_state.dart';

class AdminNavigationBloc extends Bloc<AdminNavigationEvent, AdminNavigationState> {
  AdminNavigationBloc() : super(const AdminNavigationState()) {
    on<AdminMenuChanged>((event, emit) {
      if (event.menu != state.currentMenu) {
        emit(state.copyWith(currentMenu: event.menu));
      }
    });

    on<AdminDrawerToggled>((event, emit) {
      if (event.isCollapsed != state.isDrawerCollapsed) {
        emit(state.copyWith(isDrawerCollapsed: event.isCollapsed));
      }
    });

    on<AdminLogoutRequested>((event, emit) {
      emit(state.copyWith(logoutStatus: AdminLogoutStatus.confirmationRequired));
    });

    on<AdminLogoutCancelled>((event, emit) {
      emit(state.copyWith(logoutStatus: AdminLogoutStatus.idle));
    });

    on<AdminLogoutConfirmed>((event, emit) async {
      emit(state.copyWith(logoutStatus: AdminLogoutStatus.inProgress));
      await SharedPrefUtils.clearSharedPref();
      emit(state.copyWith(logoutStatus: AdminLogoutStatus.success));
    });

    on<AdminLogoutStatusReset>((event, emit) {
      if (state.logoutStatus != AdminLogoutStatus.idle) {
        emit(state.copyWith(logoutStatus: AdminLogoutStatus.idle));
      }
    });
  }
}
