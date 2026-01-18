import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'air_ticket_event.dart';
import 'air_ticket_state.dart';
import '../models/booking_type.dart';
import '../models/checklist_item.dart';

/// BLoC for managing Air Ticket form state
/// Handles all form field changes, validation, and submission
class AirTicketBloc extends Bloc<AirTicketEvent, AirTicketState> {
  AirTicketBloc() : super(const AirTicketState()) {
    // Register event handlers
    on<AirTicketInitialized>(_onInitialized);
    on<BookingTypeChanged>(_onBookingTypeChanged);
    on<FromLocationChanged>(_onFromLocationChanged);
    on<ToLocationChanged>(_onToLocationChanged);
    on<DepartureDateChanged>(_onDepartureDateChanged);
    on<ReturnDateChanged>(_onReturnDateChanged);
    on<TravellerCountChanged>(_onTravellerCountChanged);
    on<ClassTypeChanged>(_onClassTypeChanged);
    on<VisaTypeChanged>(_onVisaTypeChanged);
    on<RemarkChanged>(_onRemarkChanged);
    on<PriorityChanged>(_onPriorityChanged);
    on<FollowUpTypeChanged>(_onFollowUpTypeChanged);
    on<ChecklistUserChanged>(_onChecklistUserChanged);
    on<ChecklistDueDateChanged>(_onChecklistDueDateChanged);
    on<ChecklistPriorityChanged>(_onChecklistPriorityChanged);
    on<ChecklistCategoryChanged>(_onChecklistCategoryChanged);
    on<ChecklistInLoopChanged>(_onChecklistInLoopChanged);
    on<ChecklistRepeatChanged>(_onChecklistRepeatChanged);
    on<AddChecklistItem>(_onAddChecklistItem);
    on<RemoveChecklistItem>(_onRemoveChecklistItem);
    on<SubmitAirTicket>(_onSubmitAirTicket);
    on<ResetAirTicketForm>(_onResetForm);
    on<SwapLocations>(_onSwapLocations);
  }

  // ========== Form Field Event Handlers ==========

  /// Handle initialization event
  void _onInitialized(
    AirTicketInitialized event,
    Emitter<AirTicketState> emit,
  ) {
    emit(const AirTicketState());
  }

  /// Handle booking type changed event
  /// Also handles return date logic based on booking type
  void _onBookingTypeChanged(
    BookingTypeChanged event,
    Emitter<AirTicketState> emit,
  ) {
    // Clear return date if booking type is One Way
    final returnDate = event.bookingType == AirTicketBookingType.oneWay
        ? null
        : state.returnDate;

    // Clear return date error if One Way
    final returnDateError = event.bookingType == AirTicketBookingType.oneWay
        ? null
        : state.returnDateError;

    emit(state.copyWith(
      bookingType: event.bookingType,
      returnDate: returnDate,
      returnDateError: returnDateError,
      clearReturnDateError: event.bookingType == AirTicketBookingType.oneWay,
    ));
  }

  /// Handle from location changed event
  void _onFromLocationChanged(
    FromLocationChanged event,
    Emitter<AirTicketState> emit,
  ) {
    final error = _validateFromLocation(event.from);
    emit(state.copyWith(
      from: event.from,
      fromError: error,
      clearFromError: error == null,
    ));
  }

  /// Handle to location changed event
  void _onToLocationChanged(
    ToLocationChanged event,
    Emitter<AirTicketState> emit,
  ) {
    final error = _validateToLocation(event.to, state.from);
    emit(state.copyWith(
      to: event.to,
      toError: error,
      clearToError: error == null,
    ));
  }

  /// Handle departure date changed event
  void _onDepartureDateChanged(
    DepartureDateChanged event,
    Emitter<AirTicketState> emit,
  ) {
    final error = _validateDepartureDate(event.departureDate);
    
    // If return date exists and is before new departure date, clear it
    final returnDate = state.returnDate != null &&
            state.returnDate!.isBefore(event.departureDate)
        ? null
        : state.returnDate;

    emit(state.copyWith(
      departureDate: event.departureDate,
      departureDateError: error,
      returnDate: returnDate,
      clearDepartureDateError: error == null,
    ));
  }

  /// Handle return date changed event
  /// Only validated for Round Trip booking type
  void _onReturnDateChanged(
    ReturnDateChanged event,
    Emitter<AirTicketState> emit,
  ) {
    final error = _validateReturnDate(
      event.returnDate,
      state.departureDate,
      state.bookingType,
    );
    emit(state.copyWith(
      returnDate: event.returnDate,
      returnDateError: error,
      clearReturnDateError: error == null,
    ));
  }

  /// Handle traveller count changed event
  void _onTravellerCountChanged(
    TravellerCountChanged event,
    Emitter<AirTicketState> emit,
  ) {
    final error = _validateTravellerCount(event.count);
    emit(state.copyWith(
      travellerCount: event.count,
      travellerCountError: error,
      clearTravellerCountError: error == null,
    ));
  }

  /// Handle class type changed event
  void _onClassTypeChanged(
    ClassTypeChanged event,
    Emitter<AirTicketState> emit,
  ) {
    emit(state.copyWith(classType: event.classType));
  }

  /// Handle visa type changed event
  void _onVisaTypeChanged(
    VisaTypeChanged event,
    Emitter<AirTicketState> emit,
  ) {
    emit(state.copyWith(
      visaType: event.visaType,
      visaTypeError: null,
      clearVisaTypeError: true,
    ));
  }

  /// Handle remark changed event
  void _onRemarkChanged(
    RemarkChanged event,
    Emitter<AirTicketState> emit,
  ) {
    final error = _validateRemark(event.remark);
    emit(state.copyWith(
      remark: event.remark,
      remarkError: error,
      clearRemarkError: error == null,
    ));
  }

  /// Handle priority changed event
  void _onPriorityChanged(
    PriorityChanged event,
    Emitter<AirTicketState> emit,
  ) {
    emit(state.copyWith(priority: event.priority));
  }

  /// Handle follow-up type changed event
  void _onFollowUpTypeChanged(
    FollowUpTypeChanged event,
    Emitter<AirTicketState> emit,
  ) {
    emit(state.copyWith(followUpType: event.followUpType));
  }

  // ========== Checklist Event Handlers ==========

  /// Handle checklist user changed event
  void _onChecklistUserChanged(
    ChecklistUserChanged event,
    Emitter<AirTicketState> emit,
  ) {
    emit(state.copyWith(checklistUser: event.user));
  }

  /// Handle checklist due date changed event
  void _onChecklistDueDateChanged(
    ChecklistDueDateChanged event,
    Emitter<AirTicketState> emit,
  ) {
    emit(state.copyWith(checklistDueDate: event.dueDate));
  }

  /// Handle checklist priority changed event
  void _onChecklistPriorityChanged(
    ChecklistPriorityChanged event,
    Emitter<AirTicketState> emit,
  ) {
    emit(state.copyWith(checklistPriority: event.priority));
  }

  /// Handle checklist category changed event
  void _onChecklistCategoryChanged(
    ChecklistCategoryChanged event,
    Emitter<AirTicketState> emit,
  ) {
    emit(state.copyWith(checklistCategory: event.category));
  }

  /// Handle checklist in loop changed event
  void _onChecklistInLoopChanged(
    ChecklistInLoopChanged event,
    Emitter<AirTicketState> emit,
  ) {
    emit(state.copyWith(checklistInLoop: event.inLoop));
  }

  /// Handle checklist repeat changed event
  void _onChecklistRepeatChanged(
    ChecklistRepeatChanged event,
    Emitter<AirTicketState> emit,
  ) {
    emit(state.copyWith(checklistRepeat: event.repeat));
  }

  /// Handle add checklist item event
  void _onAddChecklistItem(
    AddChecklistItem event,
    Emitter<AirTicketState> emit,
  ) {
    final newItem = ChecklistItem(
      user: state.checklistUser,
      dueDate: state.checklistDueDate,
      priority: state.checklistPriority,
      category: state.checklistCategory,
      inLoop: state.checklistInLoop,
      repeat: state.checklistRepeat,
    );

    final updatedItems = [...state.checklistItems, newItem];

    emit(state.copyWith(
      checklistItems: updatedItems,
      // Reset checklist form fields
      checklistUser: '',
      checklistDueDate: null,
      checklistPriority: null,
      checklistCategory: '',
      checklistInLoop: false,
      checklistRepeat: false,
    ));
  }

  /// Handle remove checklist item event
  void _onRemoveChecklistItem(
    RemoveChecklistItem event,
    Emitter<AirTicketState> emit,
  ) {
    if (event.index >= 0 && event.index < state.checklistItems.length) {
      final updatedItems = List<ChecklistItem>.from(state.checklistItems);
      updatedItems.removeAt(event.index);
      emit(state.copyWith(checklistItems: updatedItems));
    }
  }

  // ========== Form Action Event Handlers ==========

  /// Handle swap locations event
  void _onSwapLocations(
    SwapLocations event,
    Emitter<AirTicketState> emit,
  ) {
    final from = state.to;
    final to = state.from;
    final fromError = state.toError;
    final toError = state.fromError;

    emit(state.copyWith(
      from: from,
      to: to,
      fromError: fromError,
      toError: toError,
    ));
  }

  /// Handle reset form event
  void _onResetForm(
    ResetAirTicketForm event,
    Emitter<AirTicketState> emit,
  ) {
    emit(const AirTicketState());
  }

  /// Handle submit air ticket event
  /// Validates all fields and simulates API submission
  void _onSubmitAirTicket(
    SubmitAirTicket event,
    Emitter<AirTicketState> emit,
  ) async {
    // Don't allow submission if already submitting
    if (state.isSubmitting) {
      return;
    }

    // Validate all fields - validation happens ONLY in BLoC
    final errors = _validateAll();

    // If there are validation errors, show them and prevent submission
    final hasValidationErrors = errors.values.any((error) => error != null);
    if (hasValidationErrors) {
      emit(state.copyWith(
        fromError: errors['from'],
        toError: errors['to'],
        departureDateError: errors['departureDate'],
        returnDateError: errors['returnDate'],
        travellerCountError: errors['travellerCount'],
        visaTypeError: errors['visaType'],
        remarkError: errors['remark'],
        showValidationMessages: true,
        status: AirTicketSubmissionStatus.idle,
        errorMessage: null,
        successMessage: null,
      ));
      return;
    }

    // All validations passed - start submission
    emit(state.copyWith(
      status: AirTicketSubmissionStatus.submitting,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      // Simulate API call using Future.delayed
      // TODO: Replace with actual API call when ready
      await Future.delayed(const Duration(seconds: 2));

      // Simulate successful API response
      emit(state.copyWith(
        status: AirTicketSubmissionStatus.success,
        successMessage: StringConstant.airTicketSubmittedSuccessfully,
        errorMessage: null,
      ));
    } catch (e) {
      // Handle API error
      emit(state.copyWith(
        status: AirTicketSubmissionStatus.failure,
        errorMessage: StringConstant.airTicketSubmissionFailed,
        successMessage: null,
      ));
    }
  }

  // ========== Validation Methods ==========

  /// Validate all fields
  Map<String, String?> _validateAll() {
    return {
      'from': _validateFromLocation(state.from),
      'to': _validateToLocation(state.to, state.from),
      'departureDate': _validateDepartureDate(state.departureDate),
      'returnDate': _validateReturnDate(
        state.returnDate,
        state.departureDate,
        state.bookingType,
      ),
      'travellerCount': _validateTravellerCount(state.travellerCount),
      'visaType': state.visaType == null ? StringConstant.visaTypeRequired : null,
      'remark': _validateRemark(state.remark),
    };
  }

  /// Validate from location
  String? _validateFromLocation(String from) {
    if (from.trim().isEmpty) {
      return StringConstant.fromLocationRequired;
    }
    if (from.trim().length < 2) {
      return StringConstant.fromLocationMinLength;
    }
    return null;
  }

  /// Validate to location
  String? _validateToLocation(String to, String from) {
    if (to.trim().isEmpty) {
      return StringConstant.toLocationRequired;
    }
    if (to.trim().length < 2) {
      return StringConstant.toLocationMinLength;
    }
    if (to.trim().toLowerCase() == from.trim().toLowerCase()) {
      return StringConstant.toLocationDifferent;
    }
    return null;
  }

  /// Validate departure date
  String? _validateDepartureDate(DateTime? date) {
    if (date == null) {
      return StringConstant.departureDateRequired;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final departure = DateTime(date.year, date.month, date.day);
    if (departure.isBefore(today)) {
      return StringConstant.departureDatePast;
    }
    return null;
  }

  /// Validate return date
  /// Only required for Round Trip booking type
  String? _validateReturnDate(
    DateTime? returnDate,
    DateTime? departureDate,
    AirTicketBookingType? bookingType,
  ) {
    // Return date is only required for Round Trip
    if (bookingType == AirTicketBookingType.roundTrip) {
      if (returnDate == null) {
        return StringConstant.returnDateRequired;
      }
      if (departureDate == null) {
        return StringConstant.departureDateMustBeSet;
      }
      if (returnDate.isBefore(departureDate) ||
          returnDate.isAtSameMomentAs(departureDate)) {
        return StringConstant.returnDateAfterDeparture;
      }
    }
    // For One Way and Multi City, return date is optional
    return null;
  }

  /// Validate traveller count
  String? _validateTravellerCount(int count) {
    if (count < 1) {
      return StringConstant.travellerCountRequired;
    }
    if (count > 9) {
      return StringConstant.travellerCountMax;
    }
    return null;
  }

  /// Validate remark
  String? _validateRemark(String remark) {
    if (remark.trim().isEmpty) {
      return StringConstant.remarkRequired;
    }
    if (remark.trim().length < 3) {
      return StringConstant.remarkMinLength;
    }
    return null;
  }
}



