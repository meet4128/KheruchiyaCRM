import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/utils/shared_pref_utils.dart';
import 'account_navigation_event.dart';
import 'account_navigation_state.dart';

class AccountNavigationBloc
    extends Bloc<AccountNavigationEvent, AccountNavigationState> {
  AccountNavigationBloc() : super(const AccountNavigationState()) {
    on<AccountMenuChanged>((event, emit) {
      if (event.menu != state.currentMenu) {
        emit(state.copyWith(currentMenu: event.menu));
      }
    });

    on<AccountDrawerToggled>((event, emit) {
      if (event.isCollapsed != state.isDrawerCollapsed) {
        emit(state.copyWith(isDrawerCollapsed: event.isCollapsed));
      }
    });

    on<AccountUnverifiedCountUpdated>((event, emit) {
      if (event.count != state.unverifiedCount) {
        emit(state.copyWith(unverifiedCount: event.count));
      }
    });

    on<AccountLogoutRequested>((event, emit) {
      emit(state.copyWith(
        logoutStatus: AccountLogoutStatus.confirmationRequired,
      ));
    });

    on<AccountLogoutCancelled>((event, emit) {
      emit(state.copyWith(logoutStatus: AccountLogoutStatus.idle));
    });

    on<AccountLogoutConfirmed>((event, emit) async {
      emit(state.copyWith(logoutStatus: AccountLogoutStatus.inProgress));
      await SharedPrefUtils.clearSharedPref();
      emit(state.copyWith(logoutStatus: AccountLogoutStatus.success));
    });

    on<AccountLogoutStatusReset>((event, emit) {
      if (state.logoutStatus != AccountLogoutStatus.idle) {
        emit(state.copyWith(logoutStatus: AccountLogoutStatus.idle));
      }
    });
  }
}
