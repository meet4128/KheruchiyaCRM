import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/network/inquiry_api_client.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_by_phone_item.dart';
import 'package:travel_crm/data/repositories/inquiry_repository.dart';
import 'inquiry_event.dart';
import 'inquiry_state.dart';

/// Minimum digits typed before a phone auto-fill lookup fires.
const int _minPhoneDigitsForLookup = 7;

/// Debounce window for the phone lookup — collapses rapid typing into one call.
const Duration _phoneLookupDebounce = Duration(milliseconds: 400);

/// BLoC for managing Inquiry form state
/// Handles all form field changes, validation, and submission
class InquiryBloc extends Bloc<InquiryEvent, InquiryState> {
  InquiryBloc(this.inquiryRepository) : super(const InquiryState()) {
    // Register event handlers
    on<InquiryInitialized>(_onInitialized);
    on<TitleChanged>(_onTitleChanged);
    on<FirstNameChanged>(_onFirstNameChanged);
    on<LastNameChanged>(_onLastNameChanged);
    on<PhoneChanged>(_onPhoneChanged);
    on<PhoneLookupRequested>(_onPhoneLookupRequested);
    on<EmailChanged>(_onEmailChanged);
    on<AddressChanged>(_onAddressChanged);
    on<BookingTypeChanged>(_onBookingTypeChanged);
    on<TypeOfClientChanged>(_onTypeOfClientChanged);
    on<ClearPendingNavigateToAirTicket>(_onClearPendingNavigateToAirTicket);
    on<ClearPendingNavigateToHotelBooking>(_onClearPendingNavigateToHotelBooking);
    on<ReferenceNameChanged>(_onReferenceNameChanged);
    on<ReferenceNumberChanged>(_onReferenceNumberChanged);
    on<PhoneDialCodeChanged>(_onPhoneDialCodeChanged);
    on<ReferenceDialCodeChanged>(_onReferenceDialCodeChanged);
    on<ClientBehaviourChanged>(_onClientBehaviourChanged);
    on<SubmitInquiry>(_onSubmitInquiry);
    on<ResetInquiryForm>(_onResetInquiryForm);

    // Support for legacy event (for backward compatibility)
    on<InquiryFieldChanged>(_onFieldChanged);
    on<InquiryBookingTypeChanged>(_onBookingTypeChangedLegacy);
    on<InquiryPhoneDialCodeChanged>(_onDialCodeChangedLegacy);
    on<InquirySubmitRequested>(_onSubmitRequestedLegacy);
  }

  /// Repository used to look up existing inquiries by phone for auto-fill.
  final InquiryRepository inquiryRepository;

  /// Values written by the most recent successful phone auto-fill. Kept so a
  /// later no-match lookup (or too-short number) can blank exactly those fields
  /// without touching anything the user typed by hand. Null when nothing has
  /// been auto-filled since the last edit/reset.
  _AutoFillSnapshot? _autoFillSnapshot;

  /// Debounces the phone lookup while the user is still typing (matches the
  /// project's `Timer`-based search-debounce convention).
  Timer? _phoneLookupDebounceTimer;

  @override
  Future<void> close() {
    _phoneLookupDebounceTimer?.cancel();
    return super.close();
  }

  /// Handle initialization event
  void _onInitialized(
    InquiryInitialized event,
    Emitter<InquiryState> emit,
  ) {
    _autoFillSnapshot = null;
    emit(const InquiryState());
  }

  /// Clears draft fields so a new inquiry does not reuse prior input.
  void _onResetInquiryForm(
    ResetInquiryForm event,
    Emitter<InquiryState> emit,
  ) {
    _autoFillSnapshot = null;
    emit(const InquiryState());
  }

  /// Handle title changed event
  void _onTitleChanged(
    TitleChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validateTitle(event.title);
    emit(state.copyWith(
      title: event.title,
      titleError: error,
      clearTitleError: error == null,
    ));
  }

  /// Handle first name changed event
  void _onFirstNameChanged(
    FirstNameChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validateFirstName(event.firstName);
    emit(state.copyWith(
      firstName: event.firstName,
      firstNameError: error,
      clearFirstNameError: error == null,
    ));
  }

  /// Handle last name changed event
  void _onLastNameChanged(
    LastNameChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validateLastName(event.lastName);
    emit(state.copyWith(
      lastName: event.lastName,
      lastNameError: error,
      clearLastNameError: error == null,
    ));
  }

  /// Handle phone changed event.
  ///
  /// Updates the field immediately, then (debounced) fires a lookup so an
  /// existing client's details auto-fill the rest of the form.
  void _onPhoneChanged(
    PhoneChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validatePhone(event.phone);
    var next = state.copyWith(
      phoneNumber: event.phone,
      phoneError: error,
      clearPhoneError: error == null,
      // User is editing the phone again — drop any prior auto-fill hint.
      phoneAutoFilled: false,
    );

    final digits = event.phone.replaceAll(RegExp(r'\D'), '');
    _phoneLookupDebounceTimer?.cancel();
    if (digits.length >= _minPhoneDigitsForLookup) {
      emit(next);
      final countryCode = next.phoneDialCode;
      _phoneLookupDebounceTimer = Timer(_phoneLookupDebounce, () {
        add(PhoneLookupRequested(number: digits, countryCode: countryCode));
      });
    } else {
      // Too few digits to match anything — blank any prior auto-filled data.
      if (_autoFillSnapshot != null) {
        next = _clearAutoFilled(next);
      }
      emit(next);
    }
  }

  /// Looks up an existing inquiry by phone and auto-fills the client-identity
  /// fields. Never overwrites the phone being typed or the booking type, and
  /// fails silently — auto-fill is a convenience, not a blocker.
  Future<void> _onPhoneLookupRequested(
    PhoneLookupRequested event,
    Emitter<InquiryState> emit,
  ) async {
    // Guard: only search if the field still holds the requested number.
    final currentDigits = state.phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (currentDigits != event.number) return;

    emit(state.copyWith(isPhoneLookupLoading: true));
    try {
      final response = await inquiryRepository.searchInquiriesByPhone(
        InquiryByPhoneQuery(
          number: event.number,
          countryCode: event.countryCode,
        ),
      );
      if (emit.isDone) return;

      // Discard stale results if the user kept editing while we waited.
      final nowDigits = state.phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (nowDigits != event.number) {
        emit(state.copyWith(isPhoneLookupLoading: false));
        return;
      }

      final items = response.data.items;
      if (items.isEmpty) {
        // No match — new client. Blank any fields a prior auto-fill wrote,
        // then leave the rest of the form untouched.
        if (_autoFillSnapshot != null) {
          emit(_clearAutoFilled(state));
        } else {
          emit(state.copyWith(
            isPhoneLookupLoading: false,
            phoneAutoFilled: false,
          ));
        }
        return;
      }

      emit(_applyPhoneMatch(state, items.first));
    } catch (_) {
      if (emit.isDone) return;
      emit(state.copyWith(isPhoneLookupLoading: false));
    }
  }

  /// Merges a matched inquiry into [s]. Only non-empty fields from the match
  /// are applied (passing `null` to [InquiryState.copyWith] keeps the current
  /// value), so blanks never clobber what the user already typed.
  InquiryState _applyPhoneMatch(InquiryState s, InquiryByPhoneItem item) {
    final fullName = (item.fullName ?? '').trim();
    final hasName = fullName.isNotEmpty;
    final nameParts = hasName ? fullName.split(RegExp(r'\s+')) : const <String>[];
    final first = hasName ? nameParts.first : null;
    final last = hasName
        ? (nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '')
        : null;

    final applied = s.copyWith(
      isPhoneLookupLoading: false,
      phoneAutoFilled: true,
      title: _nonEmpty(item.title),
      firstName: first,
      lastName: last,
      email: _nonEmpty(item.email),
      address: _nonEmpty(item.address),
      referenceName: _nonEmpty(item.referenceName),
      referenceNumber: _nonEmpty(item.referenceNumber?.number),
      referenceDialCode: _nonEmpty(item.referenceNumber?.countryCode),
      clientBehaviour: _nonEmpty(item.clientBehaviour),
      typeOfClient: _clientTypeFromLabel(item.typeOfClient),
    );

    // Remember what we wrote so a later no-match can blank exactly these.
    _autoFillSnapshot = _AutoFillSnapshot.of(applied);
    return applied;
  }

  /// Blanks the fields written by the last auto-fill, but only where the user
  /// has not since changed them (current value still equals the filled value).
  /// Resets the snapshot so subsequent no-match lookups are no-ops.
  InquiryState _clearAutoFilled(InquiryState s) {
    final snap = _autoFillSnapshot;
    _autoFillSnapshot = null;
    if (snap == null) {
      return s.copyWith(isPhoneLookupLoading: false, phoneAutoFilled: false);
    }

    final clearTypeOfClient = s.typeOfClient == snap.typeOfClient;
    return s.copyWith(
      isPhoneLookupLoading: false,
      phoneAutoFilled: false,
      title: s.title == snap.title ? '' : null,
      firstName: s.firstName == snap.firstName ? '' : null,
      lastName: s.lastName == snap.lastName ? '' : null,
      email: s.email == snap.email ? '' : null,
      address: s.address == snap.address ? '' : null,
      referenceName: s.referenceName == snap.referenceName ? '' : null,
      referenceNumber: s.referenceNumber == snap.referenceNumber ? '' : null,
      referenceDialCode:
          s.referenceDialCode == snap.referenceDialCode ? '+91' : null,
      clientBehaviour: s.clientBehaviour == snap.clientBehaviour ? '' : null,
      // typeOfClient omitted: keeps current unless clearTypeOfClient is set.
      clearTypeOfClient: clearTypeOfClient,
    );
  }

  /// Returns [value] when it has content, else `null` (so copyWith keeps current).
  String? _nonEmpty(String? value) =>
      (value != null && value.trim().isNotEmpty) ? value : null;

  /// Maps a backend `typeOfClient` label (e.g. `"Customer"`) to [ClientType].
  ClientType? _clientTypeFromLabel(String? label) {
    if (label == null || label.trim().isEmpty) return null;
    final normalized = label.trim().toLowerCase();
    for (final type in ClientType.values) {
      if (type.label.toLowerCase() == normalized) return type;
    }
    return null;
  }

  /// Handle email changed event
  void _onEmailChanged(
    EmailChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validateEmail(event.email);
    emit(state.copyWith(
      email: event.email,
      emailError: error,
      clearEmailError: error == null,
    ));
  }

  /// Handle address changed event
  void _onAddressChanged(
    AddressChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validateAddress(event.address);
    emit(state.copyWith(
      address: event.address,
      addressError: error,
      clearAddressError: error == null,
    ));
  }

  /// Handle booking type changed event (typeOfBooking).
  /// When user selects Flight or Hotel, run full form validation; only allow
  /// navigate to the matching sub-form if valid.
  void _onBookingTypeChanged(
    BookingTypeChanged event,
    Emitter<InquiryState> emit,
  ) {
    final nextState = state.copyWith(
      bookingType: event.bookingType,
      bookingTypeError: null,
      clearBookingTypeError: true,
      pendingNavigateToAirTicket: false,
      pendingNavigateToHotelBooking: false,
    );

    final isFlight = event.bookingType == BookingType.flight;
    final isHotel = event.bookingType == BookingType.hotel;

    if (isFlight || isHotel) {
      final errors = _validateAllForState(nextState);
      final hasErrors = errors.values.any((e) => e != null);
      if (hasErrors) {
        emit(nextState.copyWith(
          titleError: errors[InquiryField.title],
          firstNameError: errors[InquiryField.firstName],
          lastNameError: errors[InquiryField.lastName],
          phoneError: errors[InquiryField.phoneNumber],
          emailError: errors[InquiryField.email],
          addressError: errors[InquiryField.address],
          bookingTypeError: errors[InquiryField.bookingType],
          referenceNameError: errors[InquiryField.referenceName],
          referenceNumberError: errors[InquiryField.referenceNumber],
          clientBehaviourError: errors[InquiryField.clientBehaviour],
          showValidationMessages: true,
          pendingNavigateToAirTicket: false,
          pendingNavigateToHotelBooking: false,
        ));
      } else {
        emit(nextState.copyWith(
          pendingNavigateToAirTicket: isFlight,
          pendingNavigateToHotelBooking: isHotel,
        ));
      }
    } else {
      emit(nextState);
    }
  }

  /// Clears the pending-navigate flag after listener has performed navigation.
  void _onClearPendingNavigateToAirTicket(
    ClearPendingNavigateToAirTicket event,
    Emitter<InquiryState> emit,
  ) {
    emit(state.copyWith(pendingNavigateToAirTicket: false));
  }

  /// Clears the pending-navigate flag after listener has navigated to hotel booking.
  void _onClearPendingNavigateToHotelBooking(
    ClearPendingNavigateToHotelBooking event,
    Emitter<InquiryState> emit,
  ) {
    emit(state.copyWith(pendingNavigateToHotelBooking: false));
  }

  /// Handle type of client changed event (typeOfClient — independent from typeOfBooking)
  void _onTypeOfClientChanged(
    TypeOfClientChanged event,
    Emitter<InquiryState> emit,
  ) {
    emit(state.copyWith(typeOfClient: event.typeOfClient));
  }

  /// Handle reference name changed event
  void _onReferenceNameChanged(
    ReferenceNameChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validateReferenceName(event.referenceName);
    emit(state.copyWith(
      referenceName: event.referenceName,
      referenceNameError: error,
      clearReferenceNameError: error == null,
    ));
  }

  /// Handle reference number changed event
  void _onReferenceNumberChanged(
    ReferenceNumberChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validateReferenceNumber(event.referenceNumber);
    emit(state.copyWith(
      referenceNumber: event.referenceNumber,
      referenceNumberError: error,
      clearReferenceNumberError: error == null,
    ));
  }

  /// Handle phone dial code changed event
  void _onPhoneDialCodeChanged(
    PhoneDialCodeChanged event,
    Emitter<InquiryState> emit,
  ) {
    emit(state.copyWith(phoneDialCode: event.dialCode));
  }

  /// Handle reference dial code changed event
  void _onReferenceDialCodeChanged(
    ReferenceDialCodeChanged event,
    Emitter<InquiryState> emit,
  ) {
    emit(state.copyWith(referenceDialCode: event.dialCode));
  }

  /// Handle client behaviour changed event
  void _onClientBehaviourChanged(
    ClientBehaviourChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validateClientBehaviour(event.clientBehaviour);
    emit(state.copyWith(
      clientBehaviour: event.clientBehaviour,
      clientBehaviourError: error,
      clearClientBehaviourError: error == null,
    ));
  }

  /// Handle submit inquiry event
  /// Validates all fields and simulates API submission
  void _onSubmitInquiry(
    SubmitInquiry event,
    Emitter<InquiryState> emit,
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
        titleError: errors[InquiryField.title],
        firstNameError: errors[InquiryField.firstName],
        lastNameError: errors[InquiryField.lastName],
        phoneError: errors[InquiryField.phoneNumber],
        emailError: errors[InquiryField.email],
        addressError: errors[InquiryField.address],
        bookingTypeError: errors[InquiryField.bookingType],
        referenceNameError: errors[InquiryField.referenceName],
        referenceNumberError: errors[InquiryField.referenceNumber],
        clientBehaviourError: errors[InquiryField.clientBehaviour],
        showValidationMessages: true,
        status: InquirySubmissionStatus.idle,
        errorMessage: null,
        successMessage: null,
      ));
      return;
    }

    // All validations passed - start submission
    emit(state.copyWith(
      status: InquirySubmissionStatus.submitting,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      // Simulate API call using Future.delayed
      // TODO: Replace with actual API call when ready
      await Future.delayed(const Duration(seconds: 2));

      // Simulate successful API response
      emit(state.copyWith(
        status: InquirySubmissionStatus.success,
        successMessage: StringConstant.inquirySubmittedSuccessfully,
        errorMessage: null,
      ));
    } catch (e) {
      // Handle API error
      emit(state.copyWith(
        status: InquirySubmissionStatus.failure,
        errorMessage: StringConstant.inquirySubmissionFailed,
        successMessage: null,
      ));
    }
  }

  // ========== Legacy Event Handlers (for backward compatibility) ==========

  /// Legacy handler for field changed event
  void _onFieldChanged(
    InquiryFieldChanged event,
    Emitter<InquiryState> emit,
  ) {
    switch (event.field) {
      case InquiryField.title:
        add(TitleChanged(event.value));
        break;
      case InquiryField.firstName:
        add(FirstNameChanged(event.value));
        break;
      case InquiryField.lastName:
        add(LastNameChanged(event.value));
        break;
      case InquiryField.phoneNumber:
        add(PhoneChanged(event.value));
        break;
      case InquiryField.email:
        add(EmailChanged(event.value));
        break;
      case InquiryField.address:
        add(AddressChanged(event.value));
        break;
      case InquiryField.referenceName:
        add(ReferenceNameChanged(event.value));
        break;
      case InquiryField.referenceNumber:
        add(ReferenceNumberChanged(event.value));
        break;
      case InquiryField.clientBehaviour:
        add(ClientBehaviourChanged(event.value));
        break;
      case InquiryField.bookingType:
        // Handled separately
        break;
    }
  }

  /// Legacy handler for booking type changed
  void _onBookingTypeChangedLegacy(
    InquiryBookingTypeChanged event,
    Emitter<InquiryState> emit,
  ) {
    add(BookingTypeChanged(event.bookingType));
  }

  /// Legacy handler for dial code changed
  void _onDialCodeChangedLegacy(
    InquiryPhoneDialCodeChanged event,
    Emitter<InquiryState> emit,
  ) {
    if (event.isReference) {
      add(ReferenceDialCodeChanged(event.dialCode));
    } else {
      add(PhoneDialCodeChanged(event.dialCode));
    }
  }

  /// Legacy handler for submit requested
  void _onSubmitRequestedLegacy(
    InquirySubmitRequested event,
    Emitter<InquiryState> emit,
  ) {
    add(const SubmitInquiry());
  }

  // ========== Validation Methods ==========

  /// Validate all fields
  Map<InquiryField, String?> _validateAll() {
    return _validateAllForState(state);
  }

  /// Validate all fields for a given state (e.g. before navigate to air ticket).
  Map<InquiryField, String?> _validateAllForState(InquiryState s) {
    return {
      InquiryField.title: _validateTitle(s.title),
      InquiryField.firstName: _validateFirstName(s.firstName),
      InquiryField.lastName: _validateLastName(s.lastName),
      InquiryField.phoneNumber: _validatePhone(s.phoneNumber),
      InquiryField.email: _validateEmail(s.email),
      InquiryField.address: _validateAddress(s.address),
      InquiryField.bookingType: s.bookingType == null
          ? StringConstant.typeOfBookingRequired
          : null,
      InquiryField.referenceName: _validateReferenceName(s.referenceName),
      InquiryField.referenceNumber:
          _validateReferenceNumber(s.referenceNumber),
      InquiryField.clientBehaviour:
          _validateClientBehaviour(s.clientBehaviour),
    };
  }

  /// Validate title
  String? _validateTitle(String value) {
    if (value.trim().isEmpty) {
      return StringConstant.titleRequired;
    }
    return null;
  }

  /// Validate first name (used as Full Name when single field)
  String? _validateFirstName(String value) {
    if (value.trim().isEmpty) {
      return StringConstant.fullNameRequired;
    }
    if (value.trim().length < 2) {
      return StringConstant.firstNameMinLength;
    }
    return null;
  }

  /// Validate last name (optional when using single Full Name field)
  String? _validateLastName(String value) {
    return null;
  }

  /// Validate phone number
  String? _validatePhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return StringConstant.phoneNumberRequired;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
      return StringConstant.phoneNumberDigitsOnly;
    }
    if (trimmed.length < 6 || trimmed.length > 15) {
      return StringConstant.phoneNumberLength;
    }
    return null;
  }

  /// Validate email
  String? _validateEmail(String value) {
    if (value.trim().isEmpty) {
      return StringConstant.emailRequired;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return StringConstant.emailInvalid;
    }
    return null;
  }

  /// Validate address
  String? _validateAddress(String value) {
    if (value.trim().isEmpty) {
      return StringConstant.addressRequired;
    }
    if (value.trim().length < 5) {
      return StringConstant.addressMinLength;
    }
    return null;
  }

  /// Validate reference name
  String? _validateReferenceName(String value) {
    if (value.trim().isEmpty) {
      return StringConstant.referenceNameRequired;
    }
    if (value.trim().length < 2) {
      return StringConstant.referenceNameMinLength;
    }
    return null;
  }

  /// Validate reference number
  String? _validateReferenceNumber(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return StringConstant.referenceNumberRequired;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
      return StringConstant.referenceNumberDigitsOnly;
    }
    if (trimmed.length < 6 || trimmed.length > 15) {
      return StringConstant.referenceNumberLength;
    }
    return null;
  }

  /// Validate client behaviour
  String? _validateClientBehaviour(String value) {
    if (value.trim().isEmpty) {
      return StringConstant.clientBehaviourRequired;
    }
    return null;
  }
}

/// Snapshot of the field values written by a phone auto-fill, used to blank
/// exactly those fields when a later lookup finds no match.
class _AutoFillSnapshot {
  const _AutoFillSnapshot({
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.address,
    required this.referenceName,
    required this.referenceNumber,
    required this.referenceDialCode,
    required this.clientBehaviour,
    required this.typeOfClient,
  });

  factory _AutoFillSnapshot.of(InquiryState s) => _AutoFillSnapshot(
        title: s.title,
        firstName: s.firstName,
        lastName: s.lastName,
        email: s.email,
        address: s.address,
        referenceName: s.referenceName,
        referenceNumber: s.referenceNumber,
        referenceDialCode: s.referenceDialCode,
        clientBehaviour: s.clientBehaviour,
        typeOfClient: s.typeOfClient,
      );

  final String title;
  final String firstName;
  final String lastName;
  final String email;
  final String address;
  final String referenceName;
  final String referenceNumber;
  final String referenceDialCode;
  final String clientBehaviour;
  final ClientType? typeOfClient;
}
