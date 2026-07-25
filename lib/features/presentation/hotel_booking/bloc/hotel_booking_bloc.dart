import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/constants/whatsapp_constants.dart';
import 'package:travel_crm/core/models/inquiry/create_inquiry_request.dart';
import 'package:travel_crm/core/models/inquiry/hotel_booking_request.dart';
import 'package:travel_crm/core/models/inquiry/phone_number_model.dart';
import 'package:travel_crm/core/utils/phone_utils.dart';
import 'package:travel_crm/data/models/amendment/send_whatsapp_message_request.dart';
import 'package:travel_crm/data/models/amendment/whatsapp_template_payload.dart';
import 'package:travel_crm/data/repositories/inquiry_repository.dart';
import '../../inquiry_form/bloc/inquiry_state.dart';
import '../../air_ticket/models/checklist_category_api.dart';
import '../../air_ticket/models/checklist_item.dart';
import '../models/amenity.dart';
import '../models/hotel_category.dart';
import '../models/meal_plan.dart';
import '../models/property_type.dart';
import '../models/room_view.dart';
import '../models/transfer_option.dart';
import 'hotel_booking_event.dart';
import 'hotel_booking_state.dart';

/// BLoC for managing Hotel Booking form state.
/// Handles all form field changes, validation, and submission.
class HotelBookingBloc extends Bloc<HotelBookingEvent, HotelBookingState> {
  HotelBookingBloc({
    required this.inquiryRepository,
  }) : super(HotelBookingState.initial) {
    on<HotelBookingInitialized>(_onInitialized);
    on<CityChanged>(_onCityChanged);
    on<CheckInDateChanged>(_onCheckInDateChanged);
    on<CheckOutDateChanged>(_onCheckOutDateChanged);
    on<RoomsChanged>(_onRoomsChanged);
    on<AdultsChanged>(_onAdultsChanged);
    on<PropertyTypeToggled>(_onPropertyTypeToggled);
    on<HotelCategoryToggled>(_onHotelCategoryToggled);
    on<RoomViewToggled>(_onRoomViewToggled);
    on<AmenityToggled>(_onAmenityToggled);
    on<TransferToggled>(_onTransferToggled);
    on<MealPlanToggled>(_onMealPlanToggled);
    on<BudgetMinChanged>(_onBudgetMinChanged);
    on<BudgetMaxChanged>(_onBudgetMaxChanged);
    on<RemarkChanged>(_onRemarkChanged);
    on<ChecklistUserChanged>(_onChecklistUserChanged);
    on<ChecklistDueDateChanged>(_onChecklistDueDateChanged);
    on<ChecklistDueTimeChanged>(_onChecklistDueTimeChanged);
    on<ChecklistPriorityChanged>(_onChecklistPriorityChanged);
    on<ChecklistCategoryChanged>(_onChecklistCategoryChanged);
    on<ChecklistInLoopChanged>(_onChecklistInLoopChanged);
    on<ChecklistRepeatChanged>(_onChecklistRepeatChanged);
    on<AddChecklistItem>(_onAddChecklistItem);
    on<RemoveChecklistItem>(_onRemoveChecklistItem);
    on<SubmitHotelBooking>(_onSubmitHotelBooking);
    on<ResetHotelBookingForm>(_onResetForm);
  }

  final InquiryRepository inquiryRepository;

  final _uuid = const Uuid();

  // ========== Form Field Event Handlers ==========

  void _onInitialized(
    HotelBookingInitialized event,
    Emitter<HotelBookingState> emit,
  ) {
    emit(const HotelBookingState());
  }

  void _onCityChanged(CityChanged event, Emitter<HotelBookingState> emit) {
    emit(state.copyWith(
      city: event.city,
      cityError: _validateCity(event.city),
    ));
  }

  void _onCheckInDateChanged(
    CheckInDateChanged event,
    Emitter<HotelBookingState> emit,
  ) {
    // Clear check-out if it is no longer after the new check-in.
    final checkOut = state.checkOutDate;
    final clearCheckOut =
        checkOut != null && !checkOut.isAfter(event.checkInDate);
    emit(state.copyWith(
      checkInDate: event.checkInDate,
      checkOutDate: clearCheckOut ? null : checkOut,
      clearCheckInError: true,
      checkOutError: _validateCheckOut(
        clearCheckOut ? null : checkOut,
        event.checkInDate,
      ),
    ));
  }

  void _onCheckOutDateChanged(
    CheckOutDateChanged event,
    Emitter<HotelBookingState> emit,
  ) {
    emit(state.copyWith(
      checkOutDate: event.checkOutDate,
      checkOutError: _validateCheckOut(event.checkOutDate, state.checkInDate),
    ));
  }

  void _onRoomsChanged(RoomsChanged event, Emitter<HotelBookingState> emit) {
    emit(state.copyWith(
      rooms: event.rooms,
      roomGuestsError: _validateRoomGuests(event.rooms, state.adults),
    ));
  }

  void _onAdultsChanged(AdultsChanged event, Emitter<HotelBookingState> emit) {
    emit(state.copyWith(
      adults: event.adults,
      roomGuestsError: _validateRoomGuests(state.rooms, event.adults),
    ));
  }

  void _onPropertyTypeToggled(
    PropertyTypeToggled event,
    Emitter<HotelBookingState> emit,
  ) {
    final updated = Set<HotelPropertyType>.from(state.propertyType);
    if (!updated.add(event.propertyType)) updated.remove(event.propertyType);
    emit(state.copyWith(
      propertyType: updated,
      clearPropertyTypeError: true,
    ));
  }

  void _onHotelCategoryToggled(
    HotelCategoryToggled event,
    Emitter<HotelBookingState> emit,
  ) {
    final updated = Set<HotelCategory>.from(state.hotelCategory);
    if (!updated.add(event.hotelCategory)) updated.remove(event.hotelCategory);
    emit(state.copyWith(
      hotelCategory: updated,
      clearHotelCategoryError: true,
    ));
  }

  void _onRoomViewToggled(
    RoomViewToggled event,
    Emitter<HotelBookingState> emit,
  ) {
    final updated = Set<RoomView>.from(state.roomViews);
    if (!updated.add(event.roomView)) updated.remove(event.roomView);
    emit(state.copyWith(roomViews: updated));
  }

  void _onAmenityToggled(
    AmenityToggled event,
    Emitter<HotelBookingState> emit,
  ) {
    final updated = Set<Amenity>.from(state.amenities);
    if (!updated.add(event.amenity)) updated.remove(event.amenity);
    emit(state.copyWith(amenities: updated));
  }

  void _onTransferToggled(
    TransferToggled event,
    Emitter<HotelBookingState> emit,
  ) {
    final updated = Set<TransferOption>.from(state.transfers);
    if (!updated.add(event.transfer)) updated.remove(event.transfer);
    emit(state.copyWith(transfers: updated));
  }

  void _onMealPlanToggled(
    MealPlanToggled event,
    Emitter<HotelBookingState> emit,
  ) {
    final updated = Set<MealPlan>.from(state.mealPlan);
    if (!updated.add(event.mealPlan)) updated.remove(event.mealPlan);
    emit(state.copyWith(mealPlan: updated));
  }

  void _onBudgetMinChanged(
    BudgetMinChanged event,
    Emitter<HotelBookingState> emit,
  ) {
    emit(state.copyWith(
      budgetMin: event.budgetMin,
      budgetError: _validateBudget(event.budgetMin, state.budgetMax),
    ));
  }

  void _onBudgetMaxChanged(
    BudgetMaxChanged event,
    Emitter<HotelBookingState> emit,
  ) {
    emit(state.copyWith(
      budgetMax: event.budgetMax,
      budgetError: _validateBudget(state.budgetMin, event.budgetMax),
    ));
  }

  void _onRemarkChanged(RemarkChanged event, Emitter<HotelBookingState> emit) {
    emit(state.copyWith(
      remark: event.remark,
      remarkError: _validateRemark(event.remark),
    ));
  }

  // ========== Checklist Event Handlers ==========

  void _onChecklistUserChanged(
    ChecklistUserChanged event,
    Emitter<HotelBookingState> emit,
  ) {
    emit(state.copyWith(checklistUsers: event.users));
  }

  void _onChecklistDueDateChanged(
    ChecklistDueDateChanged event,
    Emitter<HotelBookingState> emit,
  ) {
    final date = event.dueDate;
    if (date == null) {
      emit(state.copyWith(checklistDueDate: null));
      return;
    }
    final existing = state.checklistDueDate;
    final merged = DateTime(
      date.year,
      date.month,
      date.day,
      existing?.hour ?? 0,
      existing?.minute ?? 0,
    );
    emit(state.copyWith(checklistDueDate: merged));
  }

  /// Merges the picked time into the existing due date (defaults to today when
  /// no date has been picked yet).
  void _onChecklistDueTimeChanged(
    ChecklistDueTimeChanged event,
    Emitter<HotelBookingState> emit,
  ) {
    final time = event.dueTime;
    final base = state.checklistDueDate ?? DateTime.now();
    final merged = DateTime(
      base.year,
      base.month,
      base.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
    emit(state.copyWith(checklistDueDate: merged));
  }

  void _onChecklistPriorityChanged(
    ChecklistPriorityChanged event,
    Emitter<HotelBookingState> emit,
  ) {
    emit(state.copyWith(checklistPriority: event.priority));
  }

  void _onChecklistCategoryChanged(
    ChecklistCategoryChanged event,
    Emitter<HotelBookingState> emit,
  ) {
    emit(state.copyWith(checklistCategory: event.category));
  }

  void _onChecklistInLoopChanged(
    ChecklistInLoopChanged event,
    Emitter<HotelBookingState> emit,
  ) {
    emit(state.copyWith(checklistInLoop: event.inLoop));
  }

  void _onChecklistRepeatChanged(
    ChecklistRepeatChanged event,
    Emitter<HotelBookingState> emit,
  ) {
    emit(state.copyWith(checklistRepeat: event.repeat));
  }

  void _onAddChecklistItem(
    AddChecklistItem event,
    Emitter<HotelBookingState> emit,
  ) {
    final newItem = ChecklistItem(
      users: state.checklistUsers,
      dueDate: state.checklistDueDate,
      priority: state.checklistPriority,
      category: state.checklistCategory,
      inLoop: state.checklistInLoop,
      repeat: state.checklistRepeat,
    );

    final updatedItems = [...state.checklistItems, newItem];

    emit(state.copyWith(
      checklistItems: updatedItems,
      checklistUsers: const [],
      checklistDueDate: null,
      checklistPriority: null,
      checklistCategory: '',
      checklistInLoop: false,
      checklistRepeat: false,
    ));
  }

  void _onRemoveChecklistItem(
    RemoveChecklistItem event,
    Emitter<HotelBookingState> emit,
  ) {
    if (event.index >= 0 && event.index < state.checklistItems.length) {
      final updatedItems = List<ChecklistItem>.from(state.checklistItems);
      updatedItems.removeAt(event.index);
      emit(state.copyWith(checklistItems: updatedItems));
    }
  }

  // ========== Form Action Event Handlers ==========

  void _onResetForm(
    ResetHotelBookingForm event,
    Emitter<HotelBookingState> emit,
  ) {
    emit(const HotelBookingState());
  }

  Future<void> _onSubmitHotelBooking(
    SubmitHotelBooking event,
    Emitter<HotelBookingState> emit,
  ) async {
    if (state.isSubmitting) return;

    final errors = _validateAll();
    final hasValidationErrors = errors.values.any((error) => error != null);
    if (hasValidationErrors) {
      emit(state.copyWith(
        cityError: errors['city'],
        checkInError: errors['checkIn'],
        checkOutError: errors['checkOut'],
        roomGuestsError: errors['roomGuests'],
        propertyTypeError: errors['propertyType'],
        hotelCategoryError: errors['hotelCategory'],
        budgetError: errors['budget'],
        remarkError: errors['remark'],
        showValidationMessages: true,
        submissionStatus: HotelBookingSubmissionStatus.idle,
        submissionError: null,
        successMessage: null,
      ));
      return;
    }

    emit(state.copyWith(submissionStatus: HotelBookingSubmissionStatus.submitting));

    try {
      final request = _buildCreateInquiryRequest(state, event.inquiryState);
      final payload = request.toJson();
      final bodyJson = const JsonEncoder.withIndent('  ').convert(payload);
      developer.log('CreateInquiry POST payload:\n$bodyJson', name: 'HotelBookingBloc');
      debugPrint('[HotelBooking Submit] Request body params:\n$bodyJson');
      final response = await inquiryRepository.createInquiry(request);

      // Best-effort: greet the customer and reference on WhatsApp with the
      // approved `hotel_inquiry` template. A failure here must not fail the
      // inquiry creation, so it's handled internally per recipient.
      await _sendGreetingTemplates(
        inquiryId: response.data.inquiry.id,
        inquiryState: event.inquiryState,
      );

      emit(state.copyWith(
        submissionStatus: HotelBookingSubmissionStatus.success,
        successMessage: StringConstant.hotelBookingSubmittedSuccessfully,
      ));
    } catch (e) {
      final message = e is Exception
          ? e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '')
          : e.toString();
      emit(state.copyWith(
        submissionStatus: HotelBookingSubmissionStatus.failure,
        submissionError: message.isEmpty
            ? StringConstant.hotelBookingSubmissionFailed
            : message,
      ));
    }
  }

  /// Greets both the customer and the reference contact on WhatsApp. Each send is
  /// independent and best-effort, so one failing never affects the other or the
  /// inquiry submission result.
  Future<void> _sendGreetingTemplates({
    required String? inquiryId,
    required dynamic inquiryState,
  }) async {
    if (inquiryId == null || inquiryId.isEmpty) {
      developer.log(
        'Skipping WhatsApp greeting: missing inquiryId in create response.',
        name: 'HotelBookingBloc',
      );
      return;
    }

    await _sendGreeting(
      inquiryId: inquiryId,
      recipient: 'customer',
      countryCode: _inquiryPhoneDialCode(inquiryState),
      number: _inquiryPhoneNumber(inquiryState),
      name: _inquiryFullName(inquiryState),
    );

    await _sendGreeting(
      inquiryId: inquiryId,
      recipient: 'reference',
      countryCode: _inquiryReferenceDialCode(inquiryState),
      number: _inquiryReferenceNumber(inquiryState),
      name: _inquiryReferenceName(inquiryState),
    );
  }

  /// Sends a single `hotel_inquiry` template to one recipient.
  /// Best-effort: any failure is logged and swallowed.
  Future<void> _sendGreeting({
    required String inquiryId,
    required String recipient,
    required String countryCode,
    required String number,
    required String name,
  }) async {
    try {
      final to = normalizePeerPhoneE164(
        countryCode: countryCode,
        number: number,
      );
      if (to == null || to.isEmpty) {
        developer.log(
          'Skipping WhatsApp greeting: $recipient phone unavailable.',
          name: 'HotelBookingBloc',
        );
        return;
      }

      final trimmedName = _sanitizeTemplateParam(name);
      final displayName = trimmedName.isEmpty ? 'there' : trimmedName;

      await inquiryRepository.sendWhatsappMessage(
        SendWhatsappMessageRequest(
          to: to,
          sessionId: _uuid.v4(),
          inquiryId: inquiryId,
          type: 'template',
          template: _buildHotelInquiryTemplate(displayName),
        ),
      );
    } catch (e) {
      developer.log(
        'WhatsApp greeting send to $recipient failed (inquiry was still created): $e',
        name: 'HotelBookingBloc',
      );
    }
  }

  /// Builds the approved `hotel_inquiry` template for the current form [state].
  ///   {{1}} name  {{2}} destination  {{3}} check-in  {{4}} check-out
  ///   {{5}} rooms  {{6}} guests  {{7}} notes
  WhatsappTemplatePayload _buildHotelInquiryTemplate(String displayName) {
    final destination = _sanitizeTemplateParam(state.city);
    final rooms = '${state.rooms} ${state.rooms == 1 ? 'Room' : 'Rooms'}';
    final guests = '${state.adults} ${state.adults == 1 ? 'Adult' : 'Adults'}';
    final notes = _hotelNotesParam(state);

    return WhatsappTemplatePayload(
      name: WhatsappConstants.hotelInquiryTemplateName,
      language: WhatsappConstants.templateLanguage,
      bodyParams: [
        displayName,
        destination.isEmpty ? 'To be confirmed' : destination,
        _formatHotelDate(state.checkInDate),
        _formatHotelDate(state.checkOutDate),
        rooms,
        guests,
        notes,
      ],
    );
  }

  /// Formats a date as e.g. "12 August 2026" for the WhatsApp template.
  String _formatHotelDate(DateTime? date) {
    if (date == null) return 'To be confirmed';
    return DateFormat('d MMMM yyyy').format(date);
  }

  /// The notes body param, falling back to "-" when empty (Meta rejects empty
  /// template params).
  String _hotelNotesParam(HotelBookingState state) {
    final sanitized = _sanitizeTemplateParam(state.remark);
    return sanitized.isEmpty ? '-' : sanitized;
  }

  /// Strips characters Meta forbids in template body params (newlines, tabs,
  /// and runs of consecutive spaces).
  String _sanitizeTemplateParam(String value) {
    return value
        .replaceAll(RegExp(r'[\r\n\t]+'), ' ')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
  }

  // ========== Payload Builders ==========

  String _toIso8601(DateTime? date) {
    if (date == null) return '';
    return date.toUtc().toIso8601String();
  }

  CreateInquiryRequest _buildCreateInquiryRequest(
    HotelBookingState state,
    dynamic inquiryState,
  ) {
    final hotelBooking = HotelBookingRequest(
      city: state.city.trim(),
      checkInDate: _toIso8601(state.checkInDate),
      checkOutDate: _toIso8601(state.checkOutDate),
      rooms: state.rooms,
      adults: state.adults,
      propertyType: state.propertyType.map((p) => p.label).toList(),
      hotelCategory: state.hotelCategory.map((c) => c.label).toList(),
      roomViews: state.roomViews.map((v) => v.label).toList(),
      amenities: state.amenities.map((a) => a.label).toList(),
      mealPlan: state.mealPlan.map((m) => m.label).toList(),
      transfers: state.transfers.map((t) => t.label).toList(),
      budgetMin: state.budgetMin.trim(),
      budgetMax: state.budgetMax.trim(),
      remark: state.remark.trim(),
    );

    return CreateInquiryRequest(
      title: _inquiryTitle(inquiryState),
      phoneNumber: PhoneNumberModel(
        countryCode: _inquiryPhoneDialCode(inquiryState),
        number: _inquiryPhoneNumber(inquiryState),
      ),
      fullName: _inquiryFullName(inquiryState),
      email: _inquiryEmail(inquiryState),
      typeOfClient: _inquiryTypeOfClient(inquiryState),
      address: _inquiryAddress(inquiryState),
      referenceNumber: PhoneNumberModel(
        countryCode: _inquiryReferenceDialCode(inquiryState),
        number: _inquiryReferenceNumber(inquiryState),
      ),
      referenceName: _inquiryReferenceName(inquiryState),
      clientBehaviour: _inquiryClientBehaviour(inquiryState),
      typeOfBooking: _inquiryTypeOfBooking(inquiryState),
      status: 'IN_PROGRESS',
      hotelBooking: hotelBooking,
      checklist: _buildChecklistPayload(state),
    );
  }

  /// POST body `checklist`: each row is `{ user, dueDate, priority, category }`
  /// where `user` is a list of the assigned member objects. Empty fields are
  /// omitted; rows with nothing meaningful are dropped.
  List<dynamic> _buildChecklistPayload(HotelBookingState state) {
    final out = <Map<String, dynamic>>[];
    for (final item in state.checklistItems) {
      final m = _checklistItemToJson(item);
      if (m != null) out.add(m);
    }
    if (_hasDraftChecklist(state)) {
      final draft = ChecklistItem(
        users: state.checklistUsers,
        dueDate: state.checklistDueDate,
        priority: state.checklistPriority,
        category: state.checklistCategory,
        inLoop: state.checklistInLoop,
        repeat: state.checklistRepeat,
      );
      final m = _checklistItemToJson(draft);
      if (m != null) out.add(m);
    }
    return out;
  }

  bool _hasDraftChecklist(HotelBookingState state) {
    if (state.checklistUsers.isNotEmpty) return true;
    if (state.checklistDueDate != null) return true;
    if (state.checklistPriority != null) return true;
    if (state.checklistCategory.trim().isNotEmpty) return true;
    return false;
  }

  /// One checklist row for the API, or null if nothing meaningful was filled.
  /// `user` is emitted as a list of member objects.
  Map<String, dynamic>? _checklistItemToJson(ChecklistItem item) {
    final due = item.dueDate;
    final priority = item.priorityApiValue ?? '';
    final category = checklistCategoryToApi(item.category);
    final users = item.users
        .map((u) => u.toJson())
        .whereType<Map<String, dynamic>>()
        .toList();

    final row = <String, dynamic>{};
    if (users.isNotEmpty) row['user'] = users;
    if (due != null) row['dueDate'] = _toIso8601(due);
    if (priority.isNotEmpty) row['priority'] = priority;
    if (category.isNotEmpty) row['category'] = category;
    return row.isEmpty ? null : row;
  }

  // ========== Inquiry Field Mapping Helpers ==========

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
    final value = get(inquiryState);
    return value.trim().isEmpty ? defaultVal : value.trim();
  }

  // ========== Validation Methods ==========

  Map<String, String?> _validateAll() {
    return {
      'city': _validateCity(state.city),
      'checkIn': _validateCheckIn(state.checkInDate),
      'checkOut': _validateCheckOut(state.checkOutDate, state.checkInDate),
      'roomGuests': _validateRoomGuests(state.rooms, state.adults),
      'propertyType':
          state.propertyType.isEmpty ? StringConstant.propertyTypeRequired : null,
      'hotelCategory':
          state.hotelCategory.isEmpty ? StringConstant.hotelCategoryRequired : null,
      'budget': _validateBudget(state.budgetMin, state.budgetMax),
      'remark': _validateRemark(state.remark),
    };
  }

  String? _validateCity(String city) {
    if (city.trim().isEmpty) return StringConstant.cityRequired;
    return null;
  }

  String? _validateCheckIn(DateTime? checkIn) {
    if (checkIn == null) return StringConstant.checkInRequired;
    return null;
  }

  String? _validateCheckOut(DateTime? checkOut, DateTime? checkIn) {
    if (checkOut == null) return StringConstant.checkOutRequired;
    if (checkIn != null && !checkOut.isAfter(checkIn)) {
      return StringConstant.checkOutAfterCheckIn;
    }
    return null;
  }

  String? _validateRoomGuests(int rooms, int adults) {
    if (rooms < 1 || adults < 1) return StringConstant.roomGuestsRequired;
    return null;
  }

  /// Budget is optional; validate only when both bounds are provided and numeric.
  String? _validateBudget(String min, String max) {
    final minTrimmed = min.trim();
    final maxTrimmed = max.trim();
    if (minTrimmed.isEmpty || maxTrimmed.isEmpty) return null;
    final minVal = num.tryParse(minTrimmed);
    final maxVal = num.tryParse(maxTrimmed);
    if (minVal == null || maxVal == null) return null;
    if (maxVal < minVal) return StringConstant.budgetInvalid;
    return null;
  }

  /// Remark is optional — no validation constraints.
  String? _validateRemark(String remark) {
    return null;
  }
}
