import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'inquiry_management_event.dart';

part 'inquiry_management_state.dart';

class InquiryManagementBloc extends Bloc<InquiryManagementEvent, InquiryManagementState> {
  InquiryManagementBloc() : super(InquiryManagementInitial()) {
    on<InquiryManagementEvent>(_onInquiryManagementEvent);
  }

  void _onInquiryManagementEvent(
    InquiryManagementEvent event,
    Emitter<InquiryManagementState> emit,
  ) {}
}
