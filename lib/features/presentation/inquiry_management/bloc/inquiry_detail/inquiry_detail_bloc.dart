import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/utils/phone_utils.dart' show formatPeerPhoneDisplay, normalizePeerPhoneE164;
import 'package:travel_crm/data/models/amendment/finalize_amendment_request.dart';
import 'package:travel_crm/data/models/inquiry/list_inquiry_item.dart';
import 'package:travel_crm/data/repositories/inquiry_repository.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/inquiry_detail/inquiry_detail_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/inquiry_detail/inquiry_detail_state.dart';
import 'package:travel_crm/features/presentation/inquiry_management/mappers/amendment_mapper.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/vendor_inquiry_row.dart';

class InquiryDetailBloc extends Bloc<InquiryDetailEvent, InquiryDetailState> {
  InquiryDetailBloc({
    required InquiryRepository inquiryRepository,
    VendorInquiryRow? initialVendorRow,
  })  : _repository = inquiryRepository,
        super(
          InquiryDetailState(
            inquiryId: initialVendorRow?.bookingId ?? '',
            vendorRow: initialVendorRow,
          ),
        ) {
    on<InquiryDetailStarted>(_onStarted);
    on<InquiryDetailRefreshRequested>(_onRefresh);
    on<InquiryDetailSessionIdAssigned>(_onSessionAssigned);
    on<InquiryDetailSessionCleared>(_onSessionCleared);
    on<InquiryDetailFinalizeRequested>(_onFinalize);
  }

  final InquiryRepository _repository;

  Future<void> _onStarted(
    InquiryDetailStarted event,
    Emitter<InquiryDetailState> emit,
  ) async {
    await _loadDetail(emit, inquiryId: event.inquiryId);
  }

  Future<void> _onRefresh(
    InquiryDetailRefreshRequested event,
    Emitter<InquiryDetailState> emit,
  ) async {
    if (state.inquiryId.isEmpty) return;
    await _loadDetail(emit, inquiryId: state.inquiryId);
  }

  Future<void> _loadDetail(
    Emitter<InquiryDetailState> emit, {
    required String inquiryId,
  }) async {
    if (inquiryId.isEmpty) {
      emit(
        state.copyWith(
          status: InquiryDetailStatus.failure,
          errorMessage: 'Inquiry id is missing.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        inquiryId: inquiryId,
        status: InquiryDetailStatus.loading,
        clearErrorMessage: true,
      ),
    );

    try {
      final response = await _repository.getInquiryDetail(inquiryId);
      final inquiry = response.data.inquiry;
      final peerPhone = normalizePeerPhoneE164(
        countryCode: inquiry.phoneNumber?.countryCode,
        number: inquiry.phoneNumber?.number,
      );

      final amendments =
          inquiry.amendments.map(amendmentCardFromDto).toList(growable: false);

      VendorInquiryRow? row = state.vendorRow;
      if (row == null || row.bookingId != inquiryId) {
        row = VendorInquiryRow.fromListInquiryItem(
          ListInquiryItem(
            id: inquiry.id,
            title: inquiry.title,
            fullName: inquiry.fullName,
            typeOfBooking: inquiry.typeOfBooking,
            typeOfClient: inquiry.typeOfClient,
            status: inquiry.status,
            createdAt: inquiry.createdAt,
            checklist: inquiry.checklist,
            user: inquiry.user,
            assignedTo: inquiry.assignedTo,
          ),
        );
      } else {
        row = row.copyWith(
          checklist: inquiry.checklist.isNotEmpty ? inquiry.checklist : row.checklist,
          status: inquiry.status ?? row.status,
        );
      }

      final phoneDisplay = formatPeerPhoneDisplay(peerPhone);

      emit(
        state.copyWith(
          status: InquiryDetailStatus.success,
          vendorRow: row.copyWith(phoneDisplay: phoneDisplay),
          peerPhoneE164: peerPhone ?? '',
          amendments: amendments,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: InquiryDetailStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSessionAssigned(
    InquiryDetailSessionIdAssigned event,
    Emitter<InquiryDetailState> emit,
  ) {
    emit(state.copyWith(activeSessionId: event.sessionId));
  }

  void _onSessionCleared(
    InquiryDetailSessionCleared event,
    Emitter<InquiryDetailState> emit,
  ) {
    emit(state.copyWith(clearActiveSessionId: true));
  }

  Future<void> _onFinalize(
    InquiryDetailFinalizeRequested event,
    Emitter<InquiryDetailState> emit,
  ) async {
    final sessionId = state.activeSessionId;
    if (state.inquiryId.isEmpty) return;

    emit(
      state.copyWith(
        finalizeStatus: InquiryDetailFinalizeStatus.submitting,
        clearFinalizeErrorMessage: true,
      ),
    );

    try {
      await _repository.finalizeAmendment(
        inquiryId: state.inquiryId,
        request: FinalizeAmendmentRequest(
          action: event.action,
          amendmentType: event.amendmentTypeApi,
          sessionId: sessionId,
          amountCharged: event.amountCharged,
        ),
      );

      emit(
        state.copyWith(
          finalizeStatus: InquiryDetailFinalizeStatus.success,
          clearActiveSessionId: true,
        ),
      );

      await _loadDetail(emit, inquiryId: state.inquiryId);

      emit(
        state.copyWith(
          finalizeStatus: InquiryDetailFinalizeStatus.idle,
          clearActiveSessionId: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          finalizeStatus: InquiryDetailFinalizeStatus.failure,
          finalizeErrorMessage: e.toString(),
        ),
      );
    }
  }
}
