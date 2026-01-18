# Air Ticket Booking Form - Development Plan

## 📋 Overview

This document outlines the development flow and architecture for implementing the **Air Ticket Booking Form** feature. The implementation will follow the project's established patterns: **MVVM architecture**, **BLoC pattern with Events & States**, **StatelessWidget-first approach**, and **centralized reusable components**.

---

## 🏗️ Architecture Overview

### MVVM + BLoC Pattern

```
┌─────────────────────────────────────────────────────────┐
│                    VIEW (UI Layer)                        │
│  - AirTicketFormScreen (StatelessWidget)                │
│  - AirTicketView (BLoC Provider Wrapper)                │
│  - Reusable UI Components                                │
│  - No business logic                                     │
│  - Listens to AirTicketBloc states                      │
│  - Dispatches events to AirTicketBloc                   │
└─────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────┐
│              VIEWMODEL (BLoC Layer)                      │
│  - AirTicketBloc (extends Bloc<Event, State>)           │
│  - Business logic & validation                          │
│  - State management                                      │
│  - Event handlers                                       │
│  - Form validation                                       │
│  - API integration (future)                              │
└─────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────┐
│                  MODEL (Data Layer)                      │
│  - AirTicketState (immutable data class)                 │
│  - AirTicketEvent (event definitions)                   │
│  - Enums (BookingType, VisaType, Priority, etc.)       │
│  - Data models (FlightDetails, TravellerInfo, etc.)    │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Folder Structure

```
lib/features/presentation/air_ticket/
├── bloc/
│   ├── air_ticket_event.dart          # All events (extends Equatable)
│   ├── air_ticket_state.dart           # State class (extends Equatable)
│   └── air_ticket_bloc.dart            # BLoC implementation
├── models/
│   ├── booking_type.dart                # BookingType enum (OneWay, RoundTrip, MultiCity)
│   ├── visa_type.dart                  # VisaType enum (Visitor, Student, PR, WorkPermit)
│   ├── flight_details.dart             # FlightDetails data class
│   ├── traveller_info.dart             # TravellerInfo data class
│   └── checklist_item.dart             # ChecklistItem data class
├── widgets/
│   ├── booking_type_selector.dart      # Pill-shaped booking type buttons
│   ├── flight_details_section.dart     # From/To/Departure/Return fields
│   ├── traveller_class_selector.dart   # Traveller & Class dropdown
│   ├── visa_type_selector.dart          # Radio-style visa type buttons
│   ├── checklist_section.dart           # Add Checklist section
│   └── checklist_item_widget.dart       # Individual checklist item
├── air_ticket_form_screen.dart          # Main form screen (StatelessWidget)
└── air_ticket_view.dart                 # BLoC provider wrapper
```

---

## 🔄 Development Flow

### Phase 1: Data Models & Enums

**Step 1.1: Create Enums**
- `BookingType` enum: `oneWay`, `roundTrip`, `multiCity`
- `VisaType` enum: `visitorVisa`, `studentVisa`, `pr`, `workPermit`
- `Priority` enum: `low`, `medium`, `high`, `urgent`
- `Category` enum: (define categories as needed)

**Step 1.2: Create Data Models**
- `FlightDetails` class: from, to, departureDate, returnDate
- `TravellerInfo` class: count, classType (Economy, Business, First)
- `ChecklistItem` class: user, dueDate, priority, category, inLoop, repeat

---

### Phase 2: BLoC Implementation (Events & States)

**Step 2.1: Define Events (`air_ticket_event.dart`)**
- Base: `AirTicketEvent extends Equatable`
- Field change events:
  - `BookingTypeChanged(BookingType type)`
  - `FromLocationChanged(String from)`
  - `ToLocationChanged(String to)`
  - `DepartureDateChanged(DateTime date)`
  - `ReturnDateChanged(DateTime? date)`
  - `TravellerCountChanged(int count)`
  - `ClassTypeChanged(String classType)`
  - `VisaTypeChanged(VisaType type)`
  - `RemarkChanged(String remark)`
- Checklist events:
  - `ChecklistUserChanged(String user)`
  - `ChecklistDueDateChanged(DateTime? date)`
  - `ChecklistPriorityChanged(Priority priority)`
  - `ChecklistCategoryChanged(String category)`
  - `ChecklistInLoopChanged(bool inLoop)`
  - `ChecklistRepeatChanged(bool repeat)`
  - `AddChecklistItem()`
  - `RemoveChecklistItem(int index)`
- Form actions:
  - `AirTicketInitialized()`
  - `SubmitAirTicket()`
  - `ResetForm()`

**Step 2.2: Define State (`air_ticket_state.dart`)**
- Base: `AirTicketState extends Equatable`
- Form field values:
  - `BookingType? bookingType`
  - `String from`
  - `String to`
  - `DateTime? departureDate`
  - `DateTime? returnDate`
  - `int travellerCount`
  - `String classType`
  - `VisaType? visaType`
  - `String remark`
- Checklist data:
  - `List<ChecklistItem> checklistItems`
- Validation errors (one per field):
  - `String? fromError`
  - `String? toError`
  - `String? departureDateError`
  - `String? returnDateError`
  - `String? travellerCountError`
  - `String? visaTypeError`
  - `String? remarkError`
- UI state flags:
  - `bool showValidationMessages`
  - `AirTicketSubmissionStatus status` (idle, submitting, success, failure)
  - `String? successMessage`
  - `String? errorMessage`
- Computed getters:
  - `bool get isValid` - checks all required fields and no errors
  - `bool get isSubmitting` - checks if status == submitting
  - `bool get hasErrors` - checks if any validation errors exist

**Step 2.3: Implement BLoC (`air_ticket_bloc.dart`)**
- Extends: `Bloc<AirTicketEvent, AirTicketState>`
- Event handlers:
  - `_onInitialized()` - reset to initial state
  - `_onBookingTypeChanged()` - update booking type, validate, handle return date logic
  - `_onFromLocationChanged()` - update from location, validate
  - `_onToLocationChanged()` - update to location, validate
  - `_onDepartureDateChanged()` - update departure date, validate
  - `_onReturnDateChanged()` - update return date, validate (only for round trip)
  - `_onTravellerCountChanged()` - update traveller count, validate
  - `_onClassTypeChanged()` - update class type
  - `_onVisaTypeChanged()` - update visa type, validate
  - `_onRemarkChanged()` - update remark, validate
  - `_onChecklistUserChanged()` - update checklist user
  - `_onChecklistDueDateChanged()` - update checklist due date
  - `_onChecklistPriorityChanged()` - update checklist priority
  - `_onChecklistCategoryChanged()` - update checklist category
  - `_onChecklistInLoopChanged()` - update checklist in loop flag
  - `_onChecklistRepeatChanged()` - update checklist repeat flag
  - `_onAddChecklistItem()` - add new checklist item
  - `_onRemoveChecklistItem()` - remove checklist item
  - `_onSubmitAirTicket()` - validate all fields, submit form, simulate API call
- Validation methods (private):
  - `_validateFromLocation(String from) -> String?`
  - `_validateToLocation(String to) -> String?`
  - `_validateDepartureDate(DateTime? date) -> String?`
  - `_validateReturnDate(DateTime? date, BookingType? type) -> String?`
  - `_validateTravellerCount(int count) -> String?`
  - `_validateVisaType(VisaType? type) -> String?`
  - `_validateRemark(String remark) -> String?`
  - `_validateAll() -> void` - validates all fields and sets errors
- Business logic:
  - Return date should be disabled/hidden for "One Way" booking
  - Return date should be required for "Round Trip" booking
  - Multi-city booking may need additional fields (future enhancement)

---

### Phase 3: Reusable UI Components

**Step 3.1: Booking Type Selector Widget**
- Location: `widgets/booking_type_selector.dart`
- Type: `StatelessWidget`
- Props:
  - `BookingType? selectedType`
  - `ValueChanged<BookingType> onChanged`
- Features:
  - Three pill-shaped buttons (One Way, Round Trip, Multi City)
  - Selected state: purple background, white checkmark icon, white text
  - Unselected state: dark background, white text
  - Uses theme colors and gradients
  - Responsive layout

**Step 3.2: Flight Details Section Widget**
- Location: `widgets/flight_details_section.dart`
- Type: `StatelessWidget`
- Props:
  - `String from`
  - `String to`
  - `DateTime? departureDate`
  - `DateTime? returnDate`
  - `BookingType? bookingType`
  - `String? fromError`
  - `String? toError`
  - `String? departureDateError`
  - `String? returnDateError`
  - `ValueChanged<String> onFromChanged`
  - `ValueChanged<String> onToChanged`
  - `ValueChanged<DateTime> onDepartureDateChanged`
  - `ValueChanged<DateTime?> onReturnDateChanged`
  - `VoidCallback onSwapLocations`
- Features:
  - From/To fields with airport codes and full names
  - Swap icon button between From/To
  - Departure date picker
  - Return date picker (conditionally shown based on booking type)
  - Date formatting (e.g., "THU, 20 NOV")
  - Error text display
  - Uses `AppTextField` and date picker components

**Step 3.3: Traveller & Class Selector Widget**
- Location: `widgets/traveller_class_selector.dart`
- Type: `StatelessWidget`
- Props:
  - `int travellerCount`
  - `String classType`
  - `String? error`
  - `ValueChanged<int> onTravellerCountChanged`
  - `ValueChanged<String> onClassTypeChanged`
- Features:
  - Dropdown or selector for traveller count
  - Dropdown for class type (Economy, Business, First)
  - Displays as "1 Traveller, Economy"
  - Uses `AppDropdown` component

**Step 3.4: Visa Type Selector Widget**
- Location: `widgets/visa_type_selector.dart`
- Type: `StatelessWidget`
- Props:
  - `VisaType? selectedType`
  - `String? error`
  - `ValueChanged<VisaType> onChanged`
- Features:
  - Four radio-style buttons (Visitor Visa, Student Visa, PR, Work Permit)
  - Selected state: purple background, white checkmark icon, white text
  - Unselected state: dark background, white text
  - Horizontal layout
  - Uses theme colors

**Step 3.5: Checklist Section Widget**
- Location: `widgets/checklist_section.dart`
- Type: `StatelessWidget`
- Props:
  - `List<ChecklistItem> items`
  - `String? user`
  - `DateTime? dueDate`
  - `Priority? priority`
  - `String? category`
  - `bool inLoop`
  - `bool repeat`
  - `ValueChanged<String> onUserChanged`
  - `ValueChanged<DateTime?> onDueDateChanged`
  - `ValueChanged<Priority> onPriorityChanged`
  - `ValueChanged<String> onCategoryChanged`
  - `ValueChanged<bool> onInLoopChanged`
  - `ValueChanged<bool> onRepeatChanged`
  - `VoidCallback onAddItem`
  - `VoidCallback onRemoveItem(int index)`
- Features:
  - Five horizontal buttons/fields: User, Due Date, Set Priority, Category, In Loop
  - Each button shows icon and text
  - Action bar at bottom: Repeat checkbox, action icons (undo, clock, delete), Submit button
  - Uses theme colors and gradients

**Step 3.6: Checklist Item Widget**
- Location: `widgets/checklist_item_widget.dart`
- Type: `StatelessWidget`
- Props:
  - `ChecklistItem item`
  - `VoidCallback onRemove`
- Features:
  - Displays individual checklist item
  - Remove button
  - Uses theme styling

---

### Phase 4: Main Form Screen

**Step 4.1: Air Ticket Form Screen**
- Location: `air_ticket_form_screen.dart`
- Type: `StatelessWidget`
- Structure:
  - Uses `BlocBuilder<AirTicketBloc, AirTicketState>` to listen to state
  - No `StatefulWidget` - all state comes from BLoC
  - Layout:
    - Top: Header section (title, subtitle, arrow icon)
    - Main: Form card with gradient background
      - Section title: "Air Ticket Form" with subtitle
      - Contact info text on right
      - Booking type selector
      - Flight details section
      - Traveller & class selector
      - Visa type selector
      - Remark field
    - Bottom: Checklist section
  - Event dispatching:
    - Each field change dispatches corresponding event
    - `context.read<AirTicketBloc>().add(Event())`
  - Error display:
    - Each field shows `errorText` from state
    - Uses `AppTextField` and `AppDropdown` errorText prop
  - Validation:
    - All validation happens in BLoC
    - UI only displays errors from state
  - Submit button:
    - Disabled when `state.isValid == false`
    - Shows loading indicator when `state.isSubmitting == true`
    - Dispatches `SubmitAirTicket()` event

**Step 4.2: Air Ticket View (BLoC Provider)**
- Location: `air_ticket_view.dart`
- Type: `StatelessWidget`
- Purpose: Provides `AirTicketBloc` to the widget tree
- Structure:
  - `BlocProvider<AirTicketBloc>` wrapping `AirTicketFormScreen`
  - `BlocListener<AirTicketBloc, AirTicketState>` for side effects:
    - Show success snackbar on success
    - Show error snackbar on failure
  - Scaffold with gradient background
  - No sidebar (full-width form)

---

### Phase 5: Integration & Styling

**Step 5.1: Theme Integration**
- Use `AppTheme.colors(context)` for all colors
- Use `AppTheme.textStyles(context)` for all text styles
- Use `AppTheme.gradientBackground` for card backgrounds
- Use existing `AppTextField`, `AppDropdown`, `AppButton` components
- Match gradient colors: `Color(0xFF1F1A2E)` → `Color(0xFF2A2338)`

**Step 5.2: Responsive Design**
- Use `LayoutBuilder` for responsive layouts
- Desktop: Full-width form card
- Tablet: Adjusted spacing
- Mobile: Stacked layout (if needed)

**Step 5.3: Form Validation Flow**
- Real-time validation on field change
- Validation errors stored in state
- Form validity computed in state getter
- Submit button disabled when invalid
- All validation logic in BLoC (UI remains dumb)

---

## 🎨 UI Component Requirements

### Reusable Components to Use
- `AppTextField` - for text inputs (From, To, Remark)
- `AppDropdown` - for dropdowns (Traveller, Class)
- `AppButton` - for submit button
- `AppFormCard` - for form container with gradient
- `AppSectionTitle` - for section titles
- `DialCodePicker` - (if needed for phone numbers)

### Custom Components to Create
- `BookingTypeSelector` - pill-shaped booking type buttons
- `VisaTypeSelector` - radio-style visa type buttons
- `FlightDetailsSection` - From/To/Departure/Return fields
- `TravellerClassSelector` - traveller count and class dropdown
- `ChecklistSection` - checklist management section
- `DatePickerField` - custom date picker field

---

## 🔄 State Management Flow

### User Interaction Flow

```
User Input
    ↓
UI Dispatches Event (e.g., FromLocationChanged)
    ↓
AirTicketBloc Receives Event
    ↓
BLoC Validates Input
    ↓
BLoC Emits New State (with updated value and error)
    ↓
BlocBuilder Rebuilds UI
    ↓
UI Displays Updated Value and Error (if any)
```

### Form Submission Flow

```
User Clicks Submit Button
    ↓
UI Dispatches SubmitAirTicket Event
    ↓
BLoC Validates All Fields (_validateAll)
    ↓
If Invalid: Emit State with Errors
    ↓
If Valid: Emit Submitting State
    ↓
BLoC Simulates API Call (Future.delayed)
    ↓
On Success: Emit Success State
    ↓
On Failure: Emit Failure State with Error Message
    ↓
BlocListener Shows Snackbar
```

---

## ✅ Validation Rules

### Required Fields
- From location
- To location
- Departure date
- Return date (only for Round Trip)
- Traveller count (minimum 1)
- Visa type
- Remark

### Validation Logic
- From and To must be different
- Departure date must be today or future
- Return date must be after departure date (for Round Trip)
- Traveller count must be between 1 and 9
- Remark must not be empty

---

## 🚀 Future Enhancements

1. **Multi-City Booking**: Additional fields for multiple destinations
2. **API Integration**: Replace simulated API calls with real endpoints
3. **Flight Search**: Integration with flight search API
4. **Date Range Validation**: More sophisticated date validation
5. **Traveller Details**: Expand traveller info (names, ages, etc.)
6. **Save Draft**: Save form data locally
7. **Form History**: View previously submitted forms

---

## 📝 Implementation Checklist

### Phase 1: Foundation
- [ ] Create enums (BookingType, VisaType, Priority, Category)
- [ ] Create data models (FlightDetails, TravellerInfo, ChecklistItem)
- [ ] Set up folder structure

### Phase 2: BLoC
- [ ] Define all events in `air_ticket_event.dart`
- [ ] Define state class in `air_ticket_state.dart`
- [ ] Implement BLoC with all event handlers
- [ ] Implement validation methods
- [ ] Test BLoC logic

### Phase 3: UI Components
- [ ] Create BookingTypeSelector widget
- [ ] Create VisaTypeSelector widget
- [ ] Create FlightDetailsSection widget
- [ ] Create TravellerClassSelector widget
- [ ] Create ChecklistSection widget
- [ ] Create ChecklistItemWidget
- [ ] Create DatePickerField component

### Phase 4: Main Screen
- [ ] Create AirTicketFormScreen
- [ ] Create AirTicketView (BLoC provider)
- [ ] Wire up all fields to BLoC
- [ ] Implement error display
- [ ] Implement submit button logic

### Phase 5: Polish
- [ ] Apply theme colors and styles
- [ ] Test responsive design
- [ ] Test form validation
- [ ] Test form submission
- [ ] Code review and refactoring

---

## 🎯 Key Principles

1. **StatelessWidget First**: All UI components are StatelessWidget unless absolutely necessary
2. **BLoC for State**: All form state managed through BLoC (Events + States, NOT Cubit)
3. **No Business Logic in UI**: All validation and business logic in BLoC
4. **Reusable Components**: Use existing AppTextField, AppDropdown, etc.
5. **Theme Consistency**: Use centralized theme colors and styles
6. **MVVM Separation**: Clear separation between View, ViewModel (BLoC), and Model
7. **Immutable State**: State classes are immutable using Equatable
8. **Event-Driven**: All user actions trigger events, not direct state changes

---

## 📚 References

- Main README.md for overall architecture
- `lib/features/presentation/inquiry_form/` for reference implementation
- `lib/core/widgets/` for reusable components
- `lib/core/theme/` for theme system

---

**Note**: This document serves as a development guide. Follow this flow step-by-step to ensure consistency with the existing codebase architecture and patterns.






