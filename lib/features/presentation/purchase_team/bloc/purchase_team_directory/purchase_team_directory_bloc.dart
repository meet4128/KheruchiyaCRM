import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/data/models/members/member_directory_response.dart';
import 'package:travel_crm/data/models/purchase_chat/purchase_chat_inbox_item.dart';
import 'package:travel_crm/data/models/purchase_chat/purchase_chat_inbox_response.dart';
import 'package:travel_crm/data/repositories/purchase_chat_repository.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_directory/purchase_team_directory_event.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_directory/purchase_team_directory_state.dart';
import 'package:travel_crm/features/presentation/purchase_team/mappers/member_directory_mapper.dart';

class PurchaseTeamDirectoryBloc
    extends Bloc<PurchaseTeamDirectoryEvent, PurchaseTeamDirectoryState> {
  PurchaseTeamDirectoryBloc({required PurchaseChatRepository repository})
      : _repository = repository,
        super(const PurchaseTeamDirectoryState()) {
    on<PurchaseTeamDirectoryStarted>(_onStarted);
    on<PurchaseTeamDirectorySearchChanged>(_onSearchChanged);
    on<PurchaseTeamDirectoryMemberSelected>(_onMemberSelected);
    on<PurchaseTeamDirectoryRefreshRequested>(_onRefresh);
  }

  final PurchaseChatRepository _repository;
  Timer? _searchDebounce;

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  Future<void> _onStarted(
    PurchaseTeamDirectoryStarted event,
    Emitter<PurchaseTeamDirectoryState> emit,
  ) async {
    emit(
      state.copyWith(
        inquiryId: event.inquiryId,
        status: PurchaseTeamDirectoryStatus.loading,
        clearErrorMessage: true,
      ),
    );
    await _load(emit);
  }

  Future<void> _onRefresh(
    PurchaseTeamDirectoryRefreshRequested event,
    Emitter<PurchaseTeamDirectoryState> emit,
  ) async {
    emit(state.copyWith(status: PurchaseTeamDirectoryStatus.loading, clearErrorMessage: true));
    await _load(emit);
  }

  void _onSearchChanged(
    PurchaseTeamDirectorySearchChanged event,
    Emitter<PurchaseTeamDirectoryState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      add(const PurchaseTeamDirectoryRefreshRequested());
    });
  }

  void _onMemberSelected(
    PurchaseTeamDirectoryMemberSelected event,
    Emitter<PurchaseTeamDirectoryState> emit,
  ) {
    if (event.memberId.isEmpty) {
      emit(state.copyWith(clearSelectedMemberId: true));
      return;
    }
    emit(state.copyWith(selectedMemberId: event.memberId));
  }

  Future<void> _load(Emitter<PurchaseTeamDirectoryState> emit) async {
    try {
      final inquiryId = state.inquiryId;
      final search = state.searchQuery.trim();

      final directoryFuture = _repository.getMemberDirectory(
        search: search.isEmpty ? null : search,
      );

      if (inquiryId != null && inquiryId.isNotEmpty) {
        final results = await Future.wait<Object>([
          directoryFuture,
          _repository.listPurchaseChats(inquiryId: inquiryId),
        ]);
        final directory = results[0] as MemberDirectoryResponse;
        final inbox = results[1] as PurchaseChatInboxResponse;

        final inboxMap = <String, PurchaseChatInboxItem>{};
        for (final item in inbox.data.items) {
          final id = item.purchaseTeamMemberId;
          if (id != null && id.isNotEmpty) {
            inboxMap[id] = item;
          }
        }

        final members = purchaseTeamMembersFromDirectory(
          directory.data.items,
          inboxByMemberId: inboxMap,
        );

        emit(
          state.copyWith(
            status: PurchaseTeamDirectoryStatus.success,
            members: members,
            clearErrorMessage: true,
          ),
        );
        return;
      }

      final directory = await directoryFuture;
      final members = purchaseTeamMembersFromDirectory(directory.data.items);

      emit(
        state.copyWith(
          status: PurchaseTeamDirectoryStatus.success,
          members: members,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PurchaseTeamDirectoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
