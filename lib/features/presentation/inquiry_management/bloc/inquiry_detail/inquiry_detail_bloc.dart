import 'dart:developer' as developer;

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
    on<InquiryDetailStatusUpdateRequested>(_onStatusUpdate);
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
          status: VendorInquiryRow.statusDisplayLabel(
            inquiry.status ?? row.status,
          ),
        );
      }

      final phoneDisplay = formatPeerPhoneDisplay(peerPhone);
      final referencePhoneE164 = normalizePeerPhoneE164(
        countryCode: inquiry.referenceNumber?.countryCode,
        number: inquiry.referenceNumber?.number,
      );
      final referenceNumberDisplay = formatPeerPhoneDisplay(referencePhoneE164);
      final referenceNameDisplay = _nonEmptyOrDash(inquiry.referenceName);
      final emailDisplay = _nonEmptyOrDash(inquiry.email);
      final addressDisplay = _nonEmptyOrDash(inquiry.address);

      emit(
        state.copyWith(
          status: InquiryDetailStatus.success,
          vendorRow: row.copyWith(
            phoneDisplay: phoneDisplay,
            emailDisplay: emailDisplay,
            addressDisplay: addressDisplay,
            referenceNumberDisplay: referenceNumberDisplay,
            referenceNameDisplay: referenceNameDisplay,
          ),
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

  /// Updates the inquiry status via `PATCH /inquiries/{id}/status` and reflects
  /// the new status on the loaded [VendorInquiryRow]. Runs for the flow's
  /// automatic transitions (New In → Pending on open, first Q&A message →
  /// Followup); errors are logged and swallowed so an automatic bump never
  /// disrupts the detail screen (e.g. a non admin/sales user hitting 403).
  Future<void> _onStatusUpdate(
    InquiryDetailStatusUpdateRequested event,
    Emitter<InquiryDetailState> emit,
  ) async {
    final inquiryId = state.inquiryId;
    final target = event.status.trim();
    if (inquiryId.isEmpty || target.isEmpty) return;

    try {
      final response = await _repository.updateInquiryStatus(inquiryId, target);
      final inquiry = response.data.inquiry;
      final row = state.vendorRow;
      if (row == null) return;
      emit(
        state.copyWith(
          vendorRow: row.copyWith(
            status: VendorInquiryRow.statusDisplayLabel(inquiry.status),
          ),
        ),
      );
    } catch (e) {
      developer.log('Update inquiry status failed: $e', name: 'InquiryDetailBloc');
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

  static String _nonEmptyOrDash(String? v) {
    final t = v?.trim();
    if (t == null || t.isEmpty) return '—';
    return t;
  }
}
