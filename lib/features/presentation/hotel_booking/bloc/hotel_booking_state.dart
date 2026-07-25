import 'package:equatable/equatable.dart';
import '../models/amenity.dart';
import '../models/hotel_category.dart';
import '../models/meal_plan.dart';
import '../models/property_type.dart';
import '../models/room_view.dart';
import '../models/transfer_option.dart';
import '../../air_ticket/models/checklist_item.dart';
import '../../air_ticket/models/checklist_priority.dart';
import '../../air_ticket/models/checklist_user.dart';

/// Submission status enum for hotel booking form.
enum HotelBookingSubmissionStatus {
  idle,
  submitting,
  success,
  failure,
}

/// State class for the Hotel Booking form.
class HotelBookingState extends Equatable {
  const HotelBookingState({
    this.city = '',
    this.checkInDate,
    this.checkOutDate,
    this.rooms = 1,
    this.adults = 1,
    this.propertyType = const <HotelPropertyType>{},
    this.hotelCategory = const <HotelCategory>{},
    this.roomViews = const <RoomView>{},
    this.amenities = const <Amenity>{},
    this.mealPlan = const <MealPlan>{},
    this.transfers = const <TransferOption>{},
    this.budgetMin = '',
    this.budgetMax = '',
    this.remark = '',
    this.checklistUsers = const [],
    this.checklistDueDate,
    this.checklistPriority,
    this.checklistCategory = '',
    this.checklistInLoop = false,
    this.checklistRepeat = false,
    this.checklistItems = const [],
    this.cityError,
    this.checkInError,
    this.checkOutError,
    this.roomGuestsError,
    this.propertyTypeError,
    this.hotelCategoryError,
    this.budgetError,
    this.remarkError,
    this.showValidationMessages = false,
    this.submissionStatus = HotelBookingSubmissionStatus.idle,
    this.successMessage,
    this.submissionError,
  });

  /// Initial state for the hotel booking form.
  static HotelBookingState get initial => const HotelBookingState();

  // Form field values
  final String city;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int rooms;
  final int adults;
  final Set<HotelPropertyType> propertyType;
  final Set<HotelCategory> hotelCategory;
  final Set<RoomView> roomViews;
  final Set<Amenity> amenities;
  final Set<MealPlan> mealPlan;
  final Set<TransferOption> transfers;
  final String budgetMin;
  final String budgetMax;
  final String remark;

  // Checklist current values (for adding new items)
  final List<ChecklistUser> checklistUsers;
  final DateTime? checklistDueDate;
  final ChecklistPriority? checklistPriority;
  final String checklistCategory;
  final bool checklistInLoop;
  final bool checklistRepeat;

  // Checklist items list
  final List<ChecklistItem> checklistItems;

  // Validation errors
  final String? cityError;
  final String? checkInError;
  final String? checkOutError;
  final String? roomGuestsError;
  final String? propertyTypeError;
  final String? hotelCategoryError;
  final String? budgetError;
  final String? remarkError;

  // UI state
  final bool showValidationMessages;
  final HotelBookingSubmissionStatus submissionStatus;
  final String? successMessage;
  final String? submissionError;

  /// Check if the form has any validation errors.
  bool get hasErrors =>
      cityError != null ||
      checkInError != null ||
      checkOutError != null ||
      roomGuestsError != null ||
      propertyTypeError != null ||
      hotelCategoryError != null ||
      budgetError != null ||
      remarkError != null;

  /// Check if the form is submitting.
  bool get isSubmitting =>
      submissionStatus == HotelBookingSubmissionStatus.submitting;

  /// Check if the form submission was successful.
  bool get isSuccess =>
      submissionStatus == HotelBookingSubmissionStatus.success;

  /// Check if the form is valid (no errors and all required fields filled).
  /// Computed from state - UI remains dumb.
  bool get isValid {
    if (hasErrors) return false;

    if (city.trim().isEmpty) return false;
    if (checkInDate == null) return false;
    if (checkOutDate == null) return false;
    if (checkOutDate!.isBefore(checkInDate!) ||
        checkOutDate!.isAtSameMomentAs(checkInDate!)) {
      return false;
    }
    if (rooms < 1 || adults < 1) return false;
    if (propertyType.isEmpty) return false;
    if (hotelCategory.isEmpty) return false;
    // Remark is optional.

    return true;
  }

  /// Create a copy of the state with updated values.
  HotelBookingState copyWith({
    String? city,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? rooms,
    int? adults,
    Set<HotelPropertyType>? propertyType,
    Set<HotelCategory>? hotelCategory,
    Set<RoomView>? roomViews,
    Set<Amenity>? amenities,
    Set<MealPlan>? mealPlan,
    Set<TransferOption>? transfers,
    String? budgetMin,
    String? budgetMax,
    String? remark,
    List<ChecklistUser>? checklistUsers,
    DateTime? checklistDueDate,
    ChecklistPriority? checklistPriority,
    String? checklistCategory,
    bool? checklistInLoop,
    bool? checklistRepeat,
    List<ChecklistItem>? checklistItems,
    String? cityError,
    String? checkInError,
    String? checkOutError,
    String? roomGuestsError,
    String? propertyTypeError,
    String? hotelCategoryError,
    String? budgetError,
    String? remarkError,
    bool? showValidationMessages,
    HotelBookingSubmissionStatus? submissionStatus,
    String? successMessage,
    String? submissionError,
    bool clearCityError = false,
    bool clearCheckInError = false,
    bool clearCheckOutError = false,
    bool clearRoomGuestsError = false,
    bool clearPropertyTypeError = false,
    bool clearHotelCategoryError = false,
    bool clearBudgetError = false,
    bool clearRemarkError = false,
  }) {
    return HotelBookingState(
      city: city ?? this.city,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      rooms: rooms ?? this.rooms,
      adults: adults ?? this.adults,
      propertyType: propertyType ?? this.propertyType,
      hotelCategory: hotelCategory ?? this.hotelCategory,
      roomViews: roomViews ?? this.roomViews,
      amenities: amenities ?? this.amenities,
      mealPlan: mealPlan ?? this.mealPlan,
      transfers: transfers ?? this.transfers,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      remark: remark ?? this.remark,
      checklistUsers: checklistUsers ?? this.checklistUsers,
      checklistDueDate: checklistDueDate ?? this.checklistDueDate,
      checklistPriority: checklistPriority ?? this.checklistPriority,
      checklistCategory: checklistCategory ?? this.checklistCategory,
      checklistInLoop: checklistInLoop ?? this.checklistInLoop,
      checklistRepeat: checklistRepeat ?? this.checklistRepeat,
      checklistItems: checklistItems ?? this.checklistItems,
      cityError: clearCityError
          ? null
          : (cityError ?? (city != null ? null : this.cityError)),
      checkInError: clearCheckInError
          ? null
          : (checkInError ??
              (checkInDate != null ? null : this.checkInError)),
      checkOutError: clearCheckOutError
          ? null
          : (checkOutError ??
              (checkOutDate != null ? null : this.checkOutError)),
      roomGuestsError: clearRoomGuestsError
          ? null
          : (roomGuestsError ??
              (rooms != null || adults != null ? null : this.roomGuestsError)),
      propertyTypeError: clearPropertyTypeError
          ? null
          : (propertyTypeError ??
              (propertyType != null ? null : this.propertyTypeError)),
      hotelCategoryError: clearHotelCategoryError
          ? null
          : (hotelCategoryError ??
              (hotelCategory != null ? null : this.hotelCategoryError)),
      budgetError: clearBudgetError
          ? null
          : (budgetError ??
              (budgetMin != null || budgetMax != null
                  ? null
                  : this.budgetError)),
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
        city,
        checkInDate,
        checkOutDate,
        rooms,
        adults,
        propertyType,
        hotelCategory,
        roomViews,
        amenities,
        mealPlan,
        transfers,
        budgetMin,
        budgetMax,
        remark,
        checklistUsers,
        checklistDueDate,
        checklistPriority,
        checklistCategory,
        checklistInLoop,
        checklistRepeat,
        checklistItems,
        cityError,
        checkInError,
        checkOutError,
        roomGuestsError,
        propertyTypeError,
        hotelCategoryError,
        budgetError,
        remarkError,
        showValidationMessages,
        submissionStatus,
        successMessage,
        submissionError,
      ];
}
