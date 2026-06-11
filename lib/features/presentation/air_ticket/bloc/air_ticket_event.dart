import 'package:equatable/equatable.dart';
import '../../inquiry_form/bloc/inquiry_state.dart';
import '../models/booking_type.dart';
import '../models/traveller_breakdown.dart';
import '../models/checklist_priority.dart';
import '../models/priority.dart';
import '../models/visa_type.dart';

/// Base class for all Air Ticket events
abstract class AirTicketEvent extends Equatable {
  const AirTicketEvent();

  @override
  List<Object?> get props => [];
}

// ========== Form Field Change Events ==========

/// Event fired when air ticket form is initialized
class AirTicketInitialized extends AirTicketEvent {
  const AirTicketInitialized();

  @override
  List<Object> get props => [];
}

/// Event fired when booking type changes
class BookingTypeChanged extends AirTicketEvent {
  const BookingTypeChanged(this.bookingType);

  final AirTicketBookingType bookingType;

  @override
  List<Object> get props => [bookingType];
}

/// Event fired when from location changes
class FromLocationChanged extends AirTicketEvent {
  const FromLocationChanged(this.from);

  final String from;

  @override
  List<Object> get props => [from];
}

/// Event fired when to location changes
class ToLocationChanged extends AirTicketEvent {
  const ToLocationChanged(this.to);

  final String to;

  @override
  List<Object> get props => [to];
}

/// Event fired when departure date changes
class DepartureDateChanged extends AirTicketEvent {
  const DepartureDateChanged(this.departureDate);

  final DateTime departureDate;

  @override
  List<Object> get props => [departureDate];
}

/// Event fired when return date changes
class ReturnDateChanged extends AirTicketEvent {
  const ReturnDateChanged(this.returnDate);

  final DateTime? returnDate;

  @override
  List<Object?> get props => [returnDate];
}

/// Event fired when traveller breakdown (adult / child / infant) changes
class TravellerBreakdownChanged extends AirTicketEvent {
  const TravellerBreakdownChanged(this.breakdown);

  final TravellerBreakdown breakdown;

  @override
  List<Object> get props => [breakdown];
}

/// Event fired when class type changes
class ClassTypeChanged extends AirTicketEvent {
  const ClassTypeChanged(this.classType);

  final String classType;

  @override
  List<Object> get props => [classType];
}

/// Event fired when visa type changes
class VisaTypeChanged extends AirTicketEvent {
  const VisaTypeChanged(this.visaType);

  final VisaType visaType;

  @override
  List<Object> get props => [visaType];
}

/// Event fired when remark changes
class RemarkChanged extends AirTicketEvent {
  const RemarkChanged(this.remark);

  final String remark;

  @override
  List<Object> get props => [remark];
}

/// Event fired when priority changes
class PriorityChanged extends AirTicketEvent {
  const PriorityChanged(this.priority);

  final Priority priority;

  @override
  List<Object> get props => [priority];
}

/// Event fired when follow-up type changes
class FollowUpTypeChanged extends AirTicketEvent {
  const FollowUpTypeChanged(this.followUpType);

  final String followUpType;

  @override
  List<Object> get props => [followUpType];
}

// ========== Checklist Events ==========

/// Event fired when checklist user changes
class ChecklistUserChanged extends AirTicketEvent {
  const ChecklistUserChanged(this.user);

  final String user;

  @override
  List<Object> get props => [user];
}

/// Event fired when checklist due date changes
class ChecklistDueDateChanged extends AirTicketEvent {
  const ChecklistDueDateChanged(this.dueDate);

  final DateTime? dueDate;

  @override
  List<Object?> get props => [dueDate];
}

/// Event fired when checklist priority changes
class ChecklistPriorityChanged extends AirTicketEvent {
  const ChecklistPriorityChanged(this.priority);

  final ChecklistPriority priority;

  @override
  List<Object> get props => [priority];
}

/// Event fired when checklist category changes
class ChecklistCategoryChanged extends AirTicketEvent {
  const ChecklistCategoryChanged(this.category);

  final String category;

  @override
  List<Object> get props => [category];
}

/// Event fired when checklist in loop flag changes
class ChecklistInLoopChanged extends AirTicketEvent {
  const ChecklistInLoopChanged(this.inLoop);

  final bool inLoop;

  @override
  List<Object> get props => [inLoop];
}

/// Event fired when checklist repeat flag changes
class ChecklistRepeatChanged extends AirTicketEvent {
  const ChecklistRepeatChanged(this.repeat);

  final bool repeat;

  @override
  List<Object> get props => [repeat];
}

/// Event fired when a checklist item is added
class AddChecklistItem extends AirTicketEvent {
  const AddChecklistItem();

  @override
  List<Object> get props => [];
}

/// Event fired when a checklist item is removed
class RemoveChecklistItem extends AirTicketEvent {
  const RemoveChecklistItem(this.index);

  final int index;

  @override
  List<Object> get props => [index];
}

// ========== Form Action Events ==========

/// Event fired when air ticket form is submitted.
/// [inquiryState] should be set by the UI from context.read<InquiryBloc>().state when both forms are on the same page.
class SubmitAirTicket extends AirTicketEvent {
  const SubmitAirTicket({this.inquiryState});

  final InquiryState? inquiryState;

  @override
  List<Object?> get props => [inquiryState];
}

/// Event fired when form is reset
class ResetAirTicketForm extends AirTicketEvent {
  const ResetAirTicketForm();

  @override
  List<Object> get props => [];
}

/// Event fired when locations are swapped (segment 0)
class SwapLocations extends AirTicketEvent {
  const SwapLocations();

  @override
  List<Object> get props => [];
}

/// Event fired when user adds another flight segment (Add another City)
class AddFlightSegment extends AirTicketEvent {
  const AddFlightSegment();

  @override
  List<Object> get props => [];
}

/// Event fired when from location changes for an extra segment (index 0 = first extra)
class SegmentFromChanged extends AirTicketEvent {
  const SegmentFromChanged(this.segmentIndex, this.from);

  final int segmentIndex;
  final String from;

  @override
  List<Object> get props => [segmentIndex, from];
}

/// Event fired when to location changes for an extra segment
class SegmentToChanged extends AirTicketEvent {
  const SegmentToChanged(this.segmentIndex, this.to);

  final int segmentIndex;
  final String to;

  @override
  List<Object> get props => [segmentIndex, to];
}

/// Event fired when departure date changes for an extra segment
class SegmentDepartureDateChanged extends AirTicketEvent {
  const SegmentDepartureDateChanged(this.segmentIndex, this.departureDate);

  final int segmentIndex;
  final DateTime departureDate;

  @override
  List<Object> get props => [segmentIndex, departureDate];
}

/// Event fired when return date changes for an extra segment
class SegmentReturnDateChanged extends AirTicketEvent {
  const SegmentReturnDateChanged(this.segmentIndex, this.returnDate);

  final int segmentIndex;
  final DateTime? returnDate;

  @override
  List<Object?> get props => [segmentIndex, returnDate];
}

/// Event fired when locations are swapped in an extra segment
class SegmentSwapLocations extends AirTicketEvent {
  const SegmentSwapLocations(this.segmentIndex);

  final int segmentIndex;

  @override
  List<Object> get props => [segmentIndex];
}

/// Event fired when user removes an extra flight segment (index 0-based in flightSegments)
class RemoveFlightSegment extends AirTicketEvent {
  const RemoveFlightSegment(this.segmentIndex);

  final int segmentIndex;

  @override
  List<Object> get props => [segmentIndex];
}



