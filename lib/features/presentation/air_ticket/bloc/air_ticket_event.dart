import 'package:equatable/equatable.dart';
import '../models/booking_type.dart';
import '../models/visa_type.dart';
import '../models/priority.dart';

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

/// Event fired when traveller count changes
class TravellerCountChanged extends AirTicketEvent {
  const TravellerCountChanged(this.count);

  final int count;

  @override
  List<Object> get props => [count];
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

  final Priority priority;

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

/// Event fired when air ticket form is submitted
class SubmitAirTicket extends AirTicketEvent {
  const SubmitAirTicket();

  @override
  List<Object> get props => [];
}

/// Event fired when form is reset
class ResetAirTicketForm extends AirTicketEvent {
  const ResetAirTicketForm();

  @override
  List<Object> get props => [];
}

/// Event fired when locations are swapped
class SwapLocations extends AirTicketEvent {
  const SwapLocations();

  @override
  List<Object> get props => [];
}



