import 'package:equatable/equatable.dart';
import 'package:travel_crm/features/presentation/air_ticket/utils/flight_travel_scope.dart';
import '../models/booking_type.dart';
import '../models/checklist_priority.dart';
import '../models/priority.dart';
import '../models/visa_type.dart';
import '../models/checklist_item.dart';
import '../models/flight_segment.dart';
import 'air_ticket_event.dart';

/// Submission status enum for air ticket form
enum AirTicketSubmissionStatus {
  idle,
  submitting,
  success,
  failure,
}

/// State class for Air Ticket form
class AirTicketState extends Equatable {
  const AirTicketState({
    this.bookingType,
    this.from = '',
    this.to = '',
    this.departureDate,
    this.returnDate,
    this.travellerCount = 1,
    this.classType = '',
    this.visaType,
    this.remark = '',
    this.priority,
    this.followUpType = '',
    this.checklistUser = '',
    this.checklistDueDate,
    this.checklistPriority,
    this.checklistCategory = '',
    this.checklistInLoop = false,
    this.checklistRepeat = false,
    this.checklistItems = const [],
    this.flightSegments = const [],
    this.fromError,
    this.toError,
    this.departureDateError,
    this.returnDateError,
    this.travellerCountError,
    this.visaTypeError,
    this.remarkError,
    this.showValidationMessages = false,
    this.submissionStatus = AirTicketSubmissionStatus.idle,
    this.successMessage,
    this.submissionError,
  });

  /// Initial state for the air ticket form.
  static AirTicketState get initial => const AirTicketState();

  // Form field values
  final AirTicketBookingType? bookingType;
  final String from;
  final String to;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final int travellerCount;
  final String classType;
  final VisaType? visaType;
  final String remark;
  final Priority? priority;
  final String followUpType;

  // Checklist current values (for adding new items)
  final String checklistUser;
  final DateTime? checklistDueDate;
  final ChecklistPriority? checklistPriority;
  final String checklistCategory;
  final bool checklistInLoop;
  final bool checklistRepeat;

  // Checklist items list
  final List<ChecklistItem> checklistItems;

  // Additional flight segments (segment 0 = from/to/departureDate/returnDate above)
  final List<FlightSegment> flightSegments;

  // Validation errors
  final String? fromError;
  final String? toError;
  final String? departureDateError;
  final String? returnDateError;
  final String? travellerCountError;
  final String? visaTypeError;
  final String? remarkError;

  // UI state
  final bool showValidationMessages;
  final AirTicketSubmissionStatus submissionStatus;
  final String? successMessage;
  final String? submissionError;

  /// Check if form has any validation errors
  bool get hasErrors =>
      fromError != null ||
      toError != null ||
      departureDateError != null ||
      returnDateError != null ||
      travellerCountError != null ||
      visaTypeError != null ||
      remarkError != null;

  /// Check if form is submitting
  bool get isSubmitting => submissionStatus == AirTicketSubmissionStatus.submitting;

  /// Check if form submission was successful
  bool get isSuccess => submissionStatus == AirTicketSubmissionStatus.success;

  /// Visa field applies only when at least one segment is international (different countries).
  bool get requiresVisaSelection => FlightTravelScope.requiresVisaSelection(
        from: from,
        to: to,
        flightSegments: flightSegments,
      );

  /// Check if form is valid (no errors and all required fields filled)
  /// This is computed from state - UI remains dumb
  bool get isValid {
    // First check: No validation errors present
    if (hasErrors) return false;

    // Second check: All required fields are filled
    if (bookingType == null) return false;
    if (from.trim().isEmpty) return false;
    if (to.trim().isEmpty) return false;
    if (departureDate == null) return false;
    
    // Return date is required only for Round Trip
    if (bookingType == AirTicketBookingType.roundTrip && returnDate == null) {
      return false;
    }
    
    if (travellerCount < 1) return false;
    if (classType.trim().isEmpty) return false;
    if (requiresVisaSelection && visaType == null) return false;
    if (remark.trim().isEmpty) return false;

    // All checks passed - form is valid
    return true;
  }

  /// Create a copy of the state with updated values
  AirTicketState copyWith({
    AirTicketBookingType? bookingType,
    String? from,
    String? to,
    DateTime? departureDate,
    DateTime? returnDate,
    int? travellerCount,
    String? classType,
    VisaType? visaType,
    String? remark,
    Priority? priority,
    String? followUpType,
    String? checklistUser,
    DateTime? checklistDueDate,
    ChecklistPriority? checklistPriority,
    String? checklistCategory,
    bool? checklistInLoop,
    bool? checklistRepeat,
    List<ChecklistItem>? checklistItems,
    List<FlightSegment>? flightSegments,
    String? fromError,
    String? toError,
    String? departureDateError,
    String? returnDateError,
    String? travellerCountError,
    String? visaTypeError,
    String? remarkError,
    bool? showValidationMessages,
    AirTicketSubmissionStatus? submissionStatus,
    String? successMessage,
    String? submissionError,
    bool clearFromError = false,
    bool clearToError = false,
    bool clearDepartureDateError = false,
    bool clearReturnDateError = false,
    bool clearTravellerCountError = false,
    bool clearVisaTypeError = false,
    bool clearRemarkError = false,
    bool clearVisaType = false,
  }) {
    return AirTicketState(
      bookingType: bookingType ?? this.bookingType,
      from: from ?? this.from,
      to: to ?? this.to,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      travellerCount: travellerCount ?? this.travellerCount,
      classType: classType ?? this.classType,
      visaType: clearVisaType ? null : (visaType ?? this.visaType),
      remark: remark ?? this.remark,
      priority: priority ?? this.priority,
      followUpType: followUpType ?? this.followUpType,
      checklistUser: checklistUser ?? this.checklistUser,
      checklistDueDate: checklistDueDate ?? this.checklistDueDate,
      checklistPriority: checklistPriority ?? this.checklistPriority,
      checklistCategory: checklistCategory ?? this.checklistCategory,
      checklistInLoop: checklistInLoop ?? this.checklistInLoop,
      checklistRepeat: checklistRepeat ?? this.checklistRepeat,
      checklistItems: checklistItems ?? this.checklistItems,
      flightSegments: flightSegments ?? this.flightSegments,
      fromError: clearFromError
          ? null
          : (fromError ?? (from != null ? null : this.fromError)),
      toError: clearToError
          ? null
          : (toError ?? (to != null ? null : this.toError)),
      departureDateError: clearDepartureDateError
          ? null
          : (departureDateError ??
              (departureDate != null ? null : this.departureDateError)),
      returnDateError: clearReturnDateError
          ? null
          : (returnDateError ??
              (returnDate != null ? null : this.returnDateError)),
      travellerCountError: clearTravellerCountError
          ? null
          : (travellerCountError ??
              (travellerCount != null ? null : this.travellerCountError)),
      visaTypeError: clearVisaTypeError
          ? null
          : (visaTypeError ??
              (visaType != null ? null : this.visaTypeError)),
      remarkError: clearRemarkError
          ? null
          : (remarkError ?? (remark != null ? null : this.remarkError)),
      showValidationMessages:
          showValidationMessages ?? this.showValidationMessages,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      successMessage: successMessage ?? this.successMessage,
      submissionError: submissionError ?? this.submissionError,
    );
  }

  @override
  List<Object?> get props => [
        bookingType,
        from,
        to,
        departureDate,
        returnDate,
        travellerCount,
        classType,
        visaType,
        remark,
        priority,
        followUpType,
        checklistUser,
        checklistDueDate,
        checklistPriority,
        checklistCategory,
        checklistInLoop,
        checklistRepeat,
        checklistItems,
        flightSegments,
        fromError,
        toError,
        departureDateError,
        returnDateError,
        travellerCountError,
        visaTypeError,
        remarkError,
        showValidationMessages,
        submissionStatus,
        successMessage,
        submissionError,
      ];
}



