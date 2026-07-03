import 'package:equatable/equatable.dart';
import '../../inquiry_form/bloc/inquiry_state.dart';
import '../models/amenity.dart';
import '../models/hotel_category.dart';
import '../models/meal_plan.dart';
import '../models/property_type.dart';
import '../models/room_view.dart';
import '../models/transfer_option.dart';
import '../../air_ticket/models/checklist_priority.dart';

/// Base class for all Hotel Booking events.
abstract class HotelBookingEvent extends Equatable {
  const HotelBookingEvent();

  @override
  List<Object?> get props => [];
}

// ========== Form Field Change Events ==========

/// Event fired when the hotel booking form is initialized.
class HotelBookingInitialized extends HotelBookingEvent {
  const HotelBookingInitialized();
}

/// Event fired when city or location changes.
class CityChanged extends HotelBookingEvent {
  const CityChanged(this.city);

  final String city;

  @override
  List<Object> get props => [city];
}

/// Event fired when check-in date changes.
class CheckInDateChanged extends HotelBookingEvent {
  const CheckInDateChanged(this.checkInDate);

  final DateTime checkInDate;

  @override
  List<Object> get props => [checkInDate];
}

/// Event fired when check-out date changes.
class CheckOutDateChanged extends HotelBookingEvent {
  const CheckOutDateChanged(this.checkOutDate);

  final DateTime checkOutDate;

  @override
  List<Object> get props => [checkOutDate];
}

/// Event fired when the number of rooms changes.
class RoomsChanged extends HotelBookingEvent {
  const RoomsChanged(this.rooms);

  final int rooms;

  @override
  List<Object> get props => [rooms];
}

/// Event fired when the number of adults changes.
class AdultsChanged extends HotelBookingEvent {
  const AdultsChanged(this.adults);

  final int adults;

  @override
  List<Object> get props => [adults];
}

/// Event fired when a property type is toggled (add/remove).
class PropertyTypeToggled extends HotelBookingEvent {
  const PropertyTypeToggled(this.propertyType);

  final HotelPropertyType propertyType;

  @override
  List<Object> get props => [propertyType];
}

/// Event fired when a hotel category is toggled (add/remove).
class HotelCategoryToggled extends HotelBookingEvent {
  const HotelCategoryToggled(this.hotelCategory);

  final HotelCategory hotelCategory;

  @override
  List<Object> get props => [hotelCategory];
}

/// Event fired when a room view is toggled (add/remove).
class RoomViewToggled extends HotelBookingEvent {
  const RoomViewToggled(this.roomView);

  final RoomView roomView;

  @override
  List<Object> get props => [roomView];
}

/// Event fired when an amenity is toggled (add/remove).
class AmenityToggled extends HotelBookingEvent {
  const AmenityToggled(this.amenity);

  final Amenity amenity;

  @override
  List<Object> get props => [amenity];
}

/// Event fired when a transfer option is toggled (add/remove).
class TransferToggled extends HotelBookingEvent {
  const TransferToggled(this.transfer);

  final TransferOption transfer;

  @override
  List<Object> get props => [transfer];
}

/// Event fired when a meal plan is toggled (add/remove).
class MealPlanToggled extends HotelBookingEvent {
  const MealPlanToggled(this.mealPlan);

  final MealPlan mealPlan;

  @override
  List<Object> get props => [mealPlan];
}

/// Event fired when the minimum budget changes.
class BudgetMinChanged extends HotelBookingEvent {
  const BudgetMinChanged(this.budgetMin);

  final String budgetMin;

  @override
  List<Object> get props => [budgetMin];
}

/// Event fired when the maximum budget changes.
class BudgetMaxChanged extends HotelBookingEvent {
  const BudgetMaxChanged(this.budgetMax);

  final String budgetMax;

  @override
  List<Object> get props => [budgetMax];
}

/// Event fired when remark changes.
class RemarkChanged extends HotelBookingEvent {
  const RemarkChanged(this.remark);

  final String remark;

  @override
  List<Object> get props => [remark];
}

// ========== Checklist Events ==========

/// Event fired when checklist user changes.
class ChecklistUserChanged extends HotelBookingEvent {
  const ChecklistUserChanged(this.user);

  final String user;

  @override
  List<Object> get props => [user];
}

/// Event fired when checklist due date changes.
class ChecklistDueDateChanged extends HotelBookingEvent {
  const ChecklistDueDateChanged(this.dueDate);

  final DateTime? dueDate;

  @override
  List<Object?> get props => [dueDate];
}

/// Event fired when checklist priority changes.
class ChecklistPriorityChanged extends HotelBookingEvent {
  const ChecklistPriorityChanged(this.priority);

  final ChecklistPriority priority;

  @override
  List<Object> get props => [priority];
}

/// Event fired when checklist category changes.
class ChecklistCategoryChanged extends HotelBookingEvent {
  const ChecklistCategoryChanged(this.category);

  final String category;

  @override
  List<Object> get props => [category];
}

/// Event fired when checklist in-loop flag changes.
class ChecklistInLoopChanged extends HotelBookingEvent {
  const ChecklistInLoopChanged(this.inLoop);

  final bool inLoop;

  @override
  List<Object> get props => [inLoop];
}

/// Event fired when checklist repeat flag changes.
class ChecklistRepeatChanged extends HotelBookingEvent {
  const ChecklistRepeatChanged(this.repeat);

  final bool repeat;

  @override
  List<Object> get props => [repeat];
}

/// Event fired when a checklist item is added.
class AddChecklistItem extends HotelBookingEvent {
  const AddChecklistItem();
}

/// Event fired when a checklist item is removed.
class RemoveChecklistItem extends HotelBookingEvent {
  const RemoveChecklistItem(this.index);

  final int index;

  @override
  List<Object> get props => [index];
}

// ========== Form Action Events ==========

/// Event fired when the hotel booking form is submitted.
/// [inquiryState] should be set by the UI from the inquiry snapshot passed to the screen.
class SubmitHotelBooking extends HotelBookingEvent {
  const SubmitHotelBooking({this.inquiryState});

  final InquiryState? inquiryState;

  @override
  List<Object?> get props => [inquiryState];
}

/// Event fired when the form is reset.
class ResetHotelBookingForm extends HotelBookingEvent {
  const ResetHotelBookingForm();
}
