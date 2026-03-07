import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/models/inquiry/airport_code_model.dart';
import 'package:travel_crm/core/models/inquiry/air_ticket_request.dart';
import 'package:travel_crm/core/models/inquiry/create_inquiry_request.dart';
import 'package:travel_crm/core/models/inquiry/flight_segment_request.dart';
import 'package:travel_crm/core/models/inquiry/phone_number_model.dart';
import 'package:travel_crm/data/repositories/inquiry_repository.dart';
import '../../inquiry_form/bloc/inquiry_state.dart';
import 'air_ticket_event.dart';
import 'air_ticket_state.dart';
import '../models/booking_type.dart';
import '../models/checklist_item.dart';
import '../models/flight_segment.dart';

/// BLoC for managing Air Ticket form state
/// Handles all form field changes, validation, and submission
class AirTicketBloc extends Bloc<AirTicketEvent, AirTicketState> {
  AirTicketBloc({
    required this.inquiryRepository,
  }) : super(AirTicketState.initial) {
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
    on<AddFlightSegment>(_onAddFlightSegment);
    on<SegmentFromChanged>(_onSegmentFromChanged);
    on<SegmentToChanged>(_onSegmentToChanged);
    on<SegmentDepartureDateChanged>(_onSegmentDepartureDateChanged);
    on<SegmentReturnDateChanged>(_onSegmentReturnDateChanged);
    on<SegmentSwapLocations>(_onSegmentSwapLocations);
    on<RemoveFlightSegment>(_onRemoveFlightSegment);
  }

  final InquiryRepository inquiryRepository;

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

  /// Handle swap locations event (segment 0)
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

  /// Handle add flight segment (Add another City)
  void _onAddFlightSegment(
    AddFlightSegment event,
    Emitter<AirTicketState> emit,
  ) {
    final updated = [...state.flightSegments, FlightSegment.defaultSegment];
    emit(state.copyWith(flightSegments: updated));
  }

  /// Handle segment from changed (extra segments only; index 0-based in flightSegments)
  void _onSegmentFromChanged(
    SegmentFromChanged event,
    Emitter<AirTicketState> emit,
  ) {
    if (event.segmentIndex < 0 ||
        event.segmentIndex >= state.flightSegments.length) return;
    final list = List<FlightSegment>.from(state.flightSegments);
    list[event.segmentIndex] =
        list[event.segmentIndex].copyWith(from: event.from);
    emit(state.copyWith(flightSegments: list));
  }

  /// Handle segment to changed
  void _onSegmentToChanged(
    SegmentToChanged event,
    Emitter<AirTicketState> emit,
  ) {
    if (event.segmentIndex < 0 ||
        event.segmentIndex >= state.flightSegments.length) return;
    final list = List<FlightSegment>.from(state.flightSegments);
    list[event.segmentIndex] = list[event.segmentIndex].copyWith(to: event.to);
    emit(state.copyWith(flightSegments: list));
  }

  /// Handle segment departure date changed
  void _onSegmentDepartureDateChanged(
    SegmentDepartureDateChanged event,
    Emitter<AirTicketState> emit,
  ) {
    if (event.segmentIndex < 0 ||
        event.segmentIndex >= state.flightSegments.length) return;
    final list = List<FlightSegment>.from(state.flightSegments);
    list[event.segmentIndex] = list[event.segmentIndex]
        .copyWith(departureDate: event.departureDate);
    emit(state.copyWith(flightSegments: list));
  }

  /// Handle segment return date changed
  void _onSegmentReturnDateChanged(
    SegmentReturnDateChanged event,
    Emitter<AirTicketState> emit,
  ) {
    if (event.segmentIndex < 0 ||
        event.segmentIndex >= state.flightSegments.length) return;
    final list = List<FlightSegment>.from(state.flightSegments);
    list[event.segmentIndex] =
        list[event.segmentIndex].copyWith(returnDate: event.returnDate);
    emit(state.copyWith(flightSegments: list));
  }

  /// Handle segment swap locations
  void _onSegmentSwapLocations(
    SegmentSwapLocations event,
    Emitter<AirTicketState> emit,
  ) {
    if (event.segmentIndex < 0 ||
        event.segmentIndex >= state.flightSegments.length) return;
    final seg = state.flightSegments[event.segmentIndex];
    final list = List<FlightSegment>.from(state.flightSegments);
    list[event.segmentIndex] =
        seg.copyWith(from: seg.to, to: seg.from);
    emit(state.copyWith(flightSegments: list));
  }

  /// Handle remove flight segment (extra segments only)
  void _onRemoveFlightSegment(
    RemoveFlightSegment event,
    Emitter<AirTicketState> emit,
  ) {
    if (event.segmentIndex < 0 ||
        event.segmentIndex >= state.flightSegments.length) return;
    final list = List<FlightSegment>.from(state.flightSegments);
    list.removeAt(event.segmentIndex);
    emit(state.copyWith(flightSegments: list));
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
        submissionStatus: AirTicketSubmissionStatus.idle,
        submissionError: null,
        successMessage: null,
      ));
      return;
    }

    emit(state.copyWith(
      submissionStatus: AirTicketSubmissionStatus.submitting,
    ));

    try {
      final request = _buildCreateInquiryRequest(state, event.inquiryState);
      final payload = request.toJson();
      final bodyJson = const JsonEncoder.withIndent('  ').convert(payload);
      developer.log('CreateInquiry POST payload:\n$bodyJson', name: 'AirTicketBloc');
      debugPrint('[AirTicket Submit] Request body params:\n$bodyJson');
      await inquiryRepository.createInquiry(request);
      emit(state.copyWith(
        submissionStatus: AirTicketSubmissionStatus.success,
      ));
    } catch (e) {
      final message = e is Exception ? e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '') : e.toString();
      emit(state.copyWith(
        submissionStatus: AirTicketSubmissionStatus.failure,
        submissionError: message.isEmpty ? 'Submission failed' : message,
      ));
    }
  }

  /// Parses stored airport string "CODE - City|Airport Name" to (code, city).
  ({String code, String city}) _parseAirport(String raw) {
    final valuePart = raw.contains('|') ? raw.split('|').first.trim() : raw;
    final dash = valuePart.indexOf(' - ');
    if (dash < 0) return (code: valuePart, city: valuePart);
    return (
      code: valuePart.substring(0, dash).trim(),
      city: valuePart.substring(dash + 3).trim(),
    );
  }

  String _bookingTypeToApi(AirTicketBookingType? type) {
    if (type == null) return 'ONE_WAY';
    switch (type) {
      case AirTicketBookingType.oneWay:
        return 'ONE_WAY';
      case AirTicketBookingType.roundTrip:
        return 'ROUND_TRIP';
      case AirTicketBookingType.multiCity:
        return 'MULTI_CITY';
    }
  }

  String _toIso8601(DateTime? date) {
    if (date == null) return '';
    return date.toUtc().toIso8601String();
  }

  CreateInquiryRequest _buildCreateInquiryRequest(
    AirTicketState state,
    dynamic inquiryState,
  ) {
    final from = _parseAirport(state.from);
    final to = _parseAirport(state.to);

    final firstSegment = FlightSegmentRequest(
      from: AirportCodeModel(code: from.code, city: from.city),
      to: AirportCodeModel(code: to.code, city: to.city),
      departureDate: _toIso8601(state.departureDate),
      returnDate: state.returnDate != null ? _toIso8601(state.returnDate) : null,
      travellerCount: state.travellerCount,
      travelClass: state.classType.isNotEmpty ? state.classType : 'Economy',
    );

    final segments = <FlightSegmentRequest>[firstSegment];
    for (final seg in state.flightSegments) {
      final segFrom = _parseAirport(seg.from);
      final segTo = _parseAirport(seg.to);
      segments.add(FlightSegmentRequest(
        from: AirportCodeModel(code: segFrom.code, city: segFrom.city),
        to: AirportCodeModel(code: segTo.code, city: segTo.city),
        departureDate: seg.departureDate != null ? _toIso8601(seg.departureDate) : '',
        returnDate: seg.returnDate != null ? _toIso8601(seg.returnDate) : null,
        travellerCount: state.travellerCount,
        travelClass: state.classType.isNotEmpty ? state.classType : 'Economy',
      ));
    }

    final airTicket = AirTicketRequest(
      bookingType: _bookingTypeToApi(state.bookingType),
      flightSegments: segments,
      typeOfVisa: state.visaType?.label ?? '',
      remark: state.remark,
    );

    final title = _inquiryTitle(inquiryState);
    final fullName = _inquiryFullName(inquiryState);
    final phoneDialCode = _inquiryPhoneDialCode(inquiryState);
    final phoneNumber = _inquiryPhoneNumber(inquiryState);
    final email = _inquiryEmail(inquiryState);
    final address = _inquiryAddress(inquiryState);
    final refDialCode = _inquiryReferenceDialCode(inquiryState);
    final refNumber = _inquiryReferenceNumber(inquiryState);
    final referenceName = _inquiryReferenceName(inquiryState);
    final clientBehaviour = _inquiryClientBehaviour(inquiryState);
    final typeOfBooking = _inquiryTypeOfBooking(inquiryState);
    final typeOfClient = _inquiryTypeOfClient(inquiryState);

    return CreateInquiryRequest(
      title: title,
      phoneNumber: PhoneNumberModel(countryCode: phoneDialCode, number: phoneNumber),
      fullName: fullName,
      email: email,
      typeOfClient: typeOfClient,
      address: address,
      referenceNumber: PhoneNumberModel(countryCode: refDialCode, number: refNumber),
      referenceName: referenceName,
      clientBehaviour: clientBehaviour,
      typeOfBooking: typeOfBooking,
      status: 'PENDING',
      airTicket: airTicket,
      checklist: [],
    );
  }

  String _inquiryTitle(dynamic s) => _getInquiryField(s, (InquiryState i) => i.title);
  String _inquiryFullName(dynamic s) =>
      s is InquiryState ? '${s.firstName} ${s.lastName}'.trim() : '';
  String _inquiryPhoneDialCode(dynamic s) =>
      _getInquiryField(s, (InquiryState i) => i.phoneDialCode, defaultVal: '+91');
  String _inquiryPhoneNumber(dynamic s) =>
      _getInquiryField(s, (InquiryState i) => i.phoneNumber);
  String _inquiryEmail(dynamic s) => _getInquiryField(s, (InquiryState i) => i.email);
  String _inquiryAddress(dynamic s) => _getInquiryField(s, (InquiryState i) => i.address);
  String _inquiryReferenceDialCode(dynamic s) =>
      _getInquiryField(s, (InquiryState i) => i.referenceDialCode, defaultVal: '+91');
  String _inquiryReferenceNumber(dynamic s) =>
      _getInquiryField(s, (InquiryState i) => i.referenceNumber);
  String _inquiryReferenceName(dynamic s) =>
      _getInquiryField(s, (InquiryState i) => i.referenceName);
  String _inquiryClientBehaviour(dynamic s) =>
      _getInquiryField(s, (InquiryState i) => i.clientBehaviour);
  String _inquiryTypeOfBooking(dynamic s) =>
      _getInquiryField(s, (InquiryState i) => i.bookingType?.label ?? '');
  String _inquiryTypeOfClient(dynamic s) =>
      _getInquiryField(s, (InquiryState i) => i.typeOfClient?.label ?? '');

  String _getInquiryField(
    dynamic inquiryState,
    String Function(InquiryState) get, {
    String defaultVal = '',
  }) {
    if (inquiryState is! InquiryState) return defaultVal;
    final value = get(inquiryState as InquiryState);
    return value.trim().isEmpty ? defaultVal : value.trim();
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



