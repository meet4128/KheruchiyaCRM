import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/data/repositories/payments_repository.dart';

import 'verify_payment_state.dart';

/// Drives the "Verify payment" confirmation dialog: tracks the confirmation
/// checkbox and submits the verification via
/// `PATCH /payments/{inquiryId}/verify`.
class VerifyPaymentCubit extends Cubit<VerifyPaymentState> {
  VerifyPaymentCubit({
    required PaymentsRepository repository,
    required this.inquiryId,
  })  : _repository = repository,
        super(const VerifyPaymentState());

  final PaymentsRepository _repository;
  final String inquiryId;

  void setConfirmed(bool value) => emit(state.copyWith(confirmed: value));

  Future<void> submit() async {
    if (!state.canSubmit) return;
    if (inquiryId.isEmpty) {
      emit(state.copyWith(
        status: VerifyPaymentStatus.failure,
        errorMessage: 'Inquiry reference is missing for this payment.',
      ));
      return;
    }

    emit(state.copyWith(
      status: VerifyPaymentStatus.submitting,
      clearError: true,
    ));
    try {
      await _repository.verifyPayment(inquiryId: inquiryId, verified: true);
      emit(state.copyWith(status: VerifyPaymentStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: VerifyPaymentStatus.failure,
        errorMessage: _message(e),
      ));
    }
  }

  String _message(Object error) {
    if (error is PaymentsApiException) return error.message;
    if (error is PaymentsUnauthorizedException) {
      return 'You are not authorised to verify payments.';
    }
    return 'Could not verify the payment. Please try again.';
  }
}
