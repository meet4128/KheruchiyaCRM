# Travel CRM - Flutter Application

## 📋 Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [MVVM + BLoC Pattern](#mvvm--bloc-pattern)
- [Core Components](#core-components)
- [Theme System](#theme-system)
- [Form State Management](#form-state-management)
- [Adding New Features](#adding-new-features)
- [Best Practices](#best-practices)
- [Getting Started](#getting-started)

---

## 🎯 Overview

This Flutter application follows **MVVM (Model-View-ViewModel) architecture** combined with **BLoC (Business Logic Component)** pattern for state management. The project is designed to be:

- **Scalable**: Easy to add new features and screens
- **Maintainable**: Clear separation of concerns
- **Reusable**: Centralized widgets and theme
- **Testable**: Business logic separated from UI
- **Enterprise-ready**: Professional folder structure and patterns

### Tech Stack
- **Flutter**: Latest stable version
- **State Management**: `flutter_bloc` (BLoC pattern with **Events + States**, NOT Cubit)
- **Architecture**: MVVM (Model-View-ViewModel)
- **Theme**: Custom dark-purple gradient theme

### ⚠️ Important: BLoC Pattern (Not Cubit)

This project uses the **full BLoC pattern** with:
- ✅ **Events**: Abstract event classes that extend `BlocEvent`
- ✅ **States**: State classes that extend `BlocState`
- ✅ **BLoC**: Classes that extend `Bloc<Event, State>` with event handlers
- ❌ **NOT Cubit**: We do NOT use `Cubit` or `emit()` directly

**Why Events + States?**
- More explicit and traceable state transitions
- Better for complex business logic
- Easier to test and debug
- Better separation of concerns

---

## 🏗️ Architecture

### MVVM + BLoC Pattern

Our architecture combines MVVM with BLoC to achieve clean separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│                        VIEW (UI)                         │
│  - StatelessWidget / StatefulWidget (UI only)          │
│  - No business logic                                    │
│  - Listens to BLoC states                              │
│  - Dispatches events to BLoC                           │
└─────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────┐
│                    VIEWMODEL (BLoC)                     │
│  - Business logic                                       │
│  - State management                                     │
│  - Validation                                           │
│  - Event handling                                       │
│  - State emission                                       │
└─────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────┐
│                      MODEL (Data)                        │
│  - Data classes                                         │
│  - Entity definitions                                   │
│  - Pure data structures                                 │
└─────────────────────────────────────────────────────────┘
```

### Key Principles

1. **View (UI Layer)**
   - Contains only UI widgets
   - No business logic
   - Uses `BlocBuilder` or `BlocConsumer` to listen to states
   - Dispatches events using `context.read<Bloc>().add(Event())`

2. **ViewModel (BLoC Layer)**
   - Contains all business logic
   - Handles form validation
   - Manages state transitions
   - Emits states based on events

3. **Model (Data Layer)**
   - Pure data classes
   - No business logic
   - Immutable by default
   - Can include serialization/deserialization

---

## 📁 Project Structure

```
lib/
├── core/                          # Shared, reusable code
│   ├── theme/                     # App-wide theme configuration
│   │   ├── app_theme.dart         # Main theme data
│   │   ├── app_colors.dart        # Color definitions
│   │   └── app_text_styles.dart   # Text style definitions
│   ├── widgets/                   # Reusable UI components
│   │   ├── app_text_field.dart    # Custom text field widget
│   │   ├── app_dropdown.dart      # Custom dropdown widget
│   │   ├── app_button.dart        # Custom button widget
│   │   └── app_scaffold.dart      # Layout wrapper with sidebar
│   └── constants/                 # App constants
│       └── app_constants.dart
│
├── features/                      # Feature-based modules
│   └── inquiry/                   # Client Inquiry feature
│       ├── model/                 # Data models
│       │   └── inquiry_model.dart
│       ├── view/                  # UI screens
│       │   └── inquiry_form_screen.dart
│       └── view_model/            # BLoC (ViewModel)
│           ├── inquiry_bloc.dart
│           ├── inquiry_event.dart
│           └── inquiry_state.dart
│
├── routes/                        # Navigation & routing
│   └── app_router.dart
│
└── main.dart                      # App entry point
```

### Structure Explanation

#### `core/` - Shared Foundation
- **Purpose**: Contains code used across multiple features
- **Contains**: Theme, reusable widgets, constants, utilities
- **Rule**: No feature-specific logic here

#### `features/` - Feature Modules
- **Purpose**: Self-contained feature modules
- **Structure**: Each feature has its own `model/`, `view/`, and `view_model/`
- **Rule**: Features should be independent and reusable

#### `routes/` - Navigation
- **Purpose**: Centralized routing configuration
- **Contains**: Route definitions, navigation logic

---

## 🧩 Core Components

### Reusable Widgets

All reusable widgets are located in `core/widgets/` and follow these principles:

1. **Consistent API**: Similar props and behavior across widgets
2. **Theme Integration**: Use app theme automatically
3. **Validation Support**: Built-in validation display
4. **Accessibility**: Proper labels and semantics

#### AppTextField
- **Location**: `core/widgets/app_text_field.dart`
- **Purpose**: Standardized text input field
- **Features**:
  - Label and hint text
  - Error message display
  - Validation support
  - Theme-aware styling
  - Customizable decoration

**Usage Pattern**:
```dart
AppTextField(
  label: 'First Name',
  hint: 'Enter first name',
  value: firstName,
  onChanged: (value) => bloc.add(FirstNameChanged(value)),
  errorText: state.firstNameError,
)
```

#### AppDropdown
- **Location**: `core/widgets/app_dropdown.dart`
- **Purpose**: Standardized dropdown/select field
- **Features**:
  - Label and hint text
  - Error message display
  - Theme-aware styling
  - Customizable options

**Usage Pattern**:
```dart
AppDropdown(
  label: 'Title',
  hint: 'Select title',
  value: selectedTitle,
  items: titleOptions,
  onChanged: (value) => bloc.add(TitleChanged(value)),
  errorText: state.titleError,
)
```

#### AppButton
- **Location**: `core/widgets/app_button.dart`
- **Purpose**: Standardized button component
- **Features**:
  - Primary and secondary variants
  - Loading state
  - Disabled state
  - Theme-aware styling
  - Customizable size

**Usage Pattern**:
```dart
AppButton(
  text: 'Submit',
  onPressed: () => bloc.add(SubmitInquiry()),
  isLoading: state.isSubmitting,
)
```

#### AppScaffold
- **Location**: `core/widgets/app_scaffold.dart`
- **Purpose**: Layout wrapper with sidebar navigation
- **Features**:
  - Sidebar navigation
  - Responsive layout
  - Theme-aware background
  - Content area

**Usage Pattern**:
```dart
AppScaffold(
  currentRoute: '/inquiry',
  child: InquiryFormScreen(),
)
```

---

## 🎨 Theme System

### Centralized Theme Architecture

All theme-related code is centralized in `core/theme/`:

#### AppTheme (`app_theme.dart`)
- **Purpose**: Main theme configuration
- **Contains**: `ThemeData` with all theme properties
- **Usage**: Applied globally via `MaterialApp.theme`

#### AppColors (`app_colors.dart`)
- **Purpose**: Color definitions
- **Contains**: 
  - Primary colors (dark purple gradient)
  - Secondary colors
  - Text colors
  - Background colors
  - Error/success colors
- **Usage**: Import and use throughout the app

#### AppTextStyles (`app_text_styles.dart`)
- **Purpose**: Text style definitions
- **Contains**:
  - Heading styles
  - Body text styles
  - Label styles
  - Button text styles
- **Usage**: Consistent typography across the app

### Theme Features

1. **Dark Theme**: Primary theme with dark-purple gradient
2. **Gradient Backgrounds**: Reusable gradient definitions
3. **Input Decoration**: Consistent form field styling
4. **Text Styles**: Typography scale
5. **Color Palette**: Semantic color system

### Using Theme in Widgets

```dart
// Access colors
final colors = Theme.of(context).extension<AppColors>();

// Access text styles
final textStyles = Theme.of(context).extension<AppTextStyles>();

// Use gradient
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.gradientBackground,
  ),
)
```

---

## 📝 Form State Management

### BLoC-Based Form Management (Events + States Pattern)

Forms are managed entirely through BLoC using the **full BLoC pattern with Events and States** - **no StatefulWidget for form state**, and **no Cubit**.

### Event-Driven Architecture

All form interactions are **Events** that extend `BlocEvent`:

```dart
// Example Events (inquiry_event.dart)
abstract class InquiryEvent extends Equatable {
  const InquiryEvent();
  
  @override
  List<Object?> get props => [];
}

class TitleChanged extends InquiryEvent {
  final String title;
  const TitleChanged(this.title);
  
  @override
  List<Object> get props => [title];
}

class FirstNameChanged extends InquiryEvent {
  final String firstName;
  const FirstNameChanged(this.firstName);
  
  @override
  List<Object> get props => [firstName];
}

class LastNameChanged extends InquiryEvent {
  final String lastName;
  const LastNameChanged(this.lastName);
  
  @override
  List<Object> get props => [lastName];
}

class PhoneChanged extends InquiryEvent {
  final String phone;
  const PhoneChanged(this.phone);
  
  @override
  List<Object> get props => [phone];
}

class EmailChanged extends InquiryEvent {
  final String email;
  const EmailChanged(this.email);
  
  @override
  List<Object> get props => [email];
}

class SubmitInquiry extends InquiryEvent {
  const SubmitInquiry();
}
```

### State Management Flow

```
User Input → Event → BLoC → Validation → State Update → UI Rebuild
```

### State Structure

States extend `BlocState` and are immutable:

```dart
// Example State (inquiry_state.dart)
class InquiryState extends Equatable {
  final String title;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String? titleError;
  final String? firstNameError;
  final String? lastNameError;
  final String? phoneError;
  final String? emailError;
  final bool isSubmitting;
  final bool isSubmitted;
  
  const InquiryState({
    this.title = '',
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.email = '',
    this.titleError,
    this.firstNameError,
    this.lastNameError,
    this.phoneError,
    this.emailError,
    this.isSubmitting = false,
    this.isSubmitted = false,
  });
  
  InquiryState copyWith({
    String? title,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? titleError,
    String? firstNameError,
    String? lastNameError,
    String? phoneError,
    String? emailError,
    bool? isSubmitting,
    bool? isSubmitted,
  }) {
    return InquiryState(
      title: title ?? this.title,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      titleError: titleError,
      firstNameError: firstNameError,
      lastNameError: lastNameError,
      phoneError: phoneError,
      emailError: emailError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
  
  @override
  List<Object?> get props => [
    title,
    firstName,
    lastName,
    phone,
    email,
    titleError,
    firstNameError,
    lastNameError,
    phoneError,
    emailError,
    isSubmitting,
    isSubmitted,
  ];
}
```

### Validation in BLoC

- **Location**: Inside BLoC's event handlers (e.g., `_onField1Changed`)
- **Timing**: On field change event or on submit event
- **Error Storage**: Stored in state (e.g., `field1Error`)
- **Display**: Widgets read errors from state via `BlocBuilder`
- **Pattern**: Validate in event handler → Emit state with error → UI updates

**Example:**
```dart
void _onFirstNameChanged(
  FirstNameChanged event,
  Emitter<InquiryState> emit,
) {
  String? error;
  if (event.firstName.isEmpty) {
    error = 'First name is required';
  } else if (event.firstName.length < 2) {
    error = 'First name must be at least 2 characters';
  }
  
  emit(state.copyWith(
    firstName: event.firstName,
    firstNameError: error,
  ));
}
```

### Benefits

1. **Testable**: Business logic separated from UI
2. **Predictable**: State changes are explicit
3. **Debuggable**: All state transitions are traceable
4. **Reusable**: Same BLoC can be used in different UIs

---

## ➕ Adding New Features

### Step-by-Step Guide

#### 1. Create Feature Folder Structure

```
features/
└── new_feature/
    ├── model/
    │   └── new_feature_model.dart
    ├── view/
    │   └── new_feature_screen.dart
    └── view_model/
        ├── new_feature_bloc.dart
        ├── new_feature_event.dart
        └── new_feature_state.dart
```

#### 2. Define Model

```dart
// model/new_feature_model.dart
class NewFeatureModel {
  final String field1;
  final String field2;
  
  const NewFeatureModel({
    required this.field1,
    required this.field2,
  });
}
```

#### 3. Define Events

```dart
// view_model/new_feature_event.dart
abstract class NewFeatureEvent {}

class Field1Changed extends NewFeatureEvent {
  final String value;
  Field1Changed(this.value);
}

class SubmitForm extends NewFeatureEvent {}
```

#### 4. Define State

```dart
// view_model/new_feature_state.dart
class NewFeatureState {
  final String field1;
  final String? field1Error;
  final bool isSubmitting;
  
  const NewFeatureState({
    this.field1 = '',
    this.field1Error,
    this.isSubmitting = false,
  });
}
```

#### 5. Implement BLoC (Events + States Pattern)

```dart
// view_model/new_feature_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'new_feature_event.dart';
import 'new_feature_state.dart';

class NewFeatureBloc extends Bloc<NewFeatureEvent, NewFeatureState> {
  NewFeatureBloc() : super(const NewFeatureState()) {
    // Register event handlers
    on<Field1Changed>(_onField1Changed);
    on<SubmitForm>(_onSubmitForm);
  }
  
  // Event handler for Field1Changed event
  void _onField1Changed(
    Field1Changed event,
    Emitter<NewFeatureState> emit,
  ) {
    // Validation logic
    String? error;
    if (event.value.isEmpty) {
      error = 'Field 1 is required';
    }
    
    // Emit new state using copyWith
    emit(state.copyWith(
      field1: event.value,
      field1Error: error,
    ));
  }
  
  // Event handler for SubmitForm event
  void _onSubmitForm(
    SubmitForm event,
    Emitter<NewFeatureState> emit,
  ) {
    // Validation and submission logic
    emit(state.copyWith(isSubmitting: true));
    
    // Perform async operation
    // Then emit success state
    emit(state.copyWith(
      isSubmitting: false,
      isSubmitted: true,
    ));
  }
}
```

**Key Points:**
- ✅ Extends `Bloc<Event, State>` (NOT `Cubit`)
- ✅ Uses `on<Event>()` to register event handlers
- ✅ Event handlers receive `(Event event, Emitter<State> emit)` parameters
- ✅ Uses `emit()` inside event handlers (NOT directly in BLoC)
- ✅ States are immutable, use `copyWith()` to create new states

#### 6. Create View

```dart
// view/new_feature_screen.dart
class NewFeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewFeatureBloc(),
      child: AppScaffold(
        child: BlocBuilder<NewFeatureBloc, NewFeatureState>(
          builder: (context, state) {
            return Column(
              children: [
                AppTextField(
                  label: 'Field 1',
                  value: state.field1,
                  onChanged: (value) => 
                    context.read<NewFeatureBloc>().add(Field1Changed(value)),
                  errorText: state.field1Error,
                ),
                AppButton(
                  text: 'Submit',
                  onPressed: () => 
                    context.read<NewFeatureBloc>().add(SubmitForm()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

#### 7. Add Route

```dart
// routes/app_router.dart
'/new-feature': (context) => NewFeatureScreen(),
```

### Reusing Components

When adding a new form screen:

1. ✅ Use `AppTextField` for text inputs
2. ✅ Use `AppDropdown` for dropdowns
3. ✅ Use `AppButton` for actions
4. ✅ Use `AppScaffold` for layout
5. ✅ Follow the same BLoC pattern
6. ✅ Use theme from `core/theme/`

---

## ✅ Best Practices

### 1. Separation of Concerns
- **View**: Only UI rendering
- **BLoC**: Only business logic
- **Model**: Only data structure

### 2. Immutability
- States are immutable
- Use `copyWith` for state updates
- Models are immutable

### 3. Single Responsibility
- Each BLoC handles one feature
- Each widget has one purpose
- Each model represents one entity

### 4. Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `UPPER_SNAKE_CASE`

### 5. Code Organization
- Feature-based folder structure
- Core components in `core/`
- No circular dependencies

### 6. State Management
- No `StatefulWidget` for form state
- All state in BLoC using **Events + States pattern** (NOT Cubit)
- Use `BlocBuilder` for reactive UI
- Use `BlocListener` for side effects
- Events extend `BlocEvent` (or use `Equatable`)
- States extend `BlocState` (or use `Equatable`)
- Use `on<Event>()` to register event handlers
- Use `emit()` inside event handlers to update state

### 7. Validation
- Validation logic in BLoC
- Error messages in state
- Display errors in widgets

### 8. Theme Usage
- Always use theme colors/styles
- No hardcoded colors
- Use theme extensions

### 9. Widget Reusability
- Extract common widgets
- Use composition over inheritance
- Keep widgets small and focused

### 10. Testing
- Test BLoC logic separately
- Test widgets with mock BLoC
- Test models independently

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK
- IDE (VS Code / Android Studio)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd travel_crm
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Dependencies

Key dependencies (to be added):
- `flutter_bloc`: BLoC state management (Events + States pattern)
- `equatable`: Value equality for Events and States (required for BLoC pattern)
- `flutter_svg`: SVG support (if needed)

**Note**: We use `flutter_bloc` with the full BLoC pattern (Events + States), not the Cubit pattern. The `equatable` package is essential for proper event and state comparison in BLoC.

---

## 📚 Additional Resources

### BLoC Pattern
- [BLoC Documentation](https://bloclibrary.dev/)
- [BLoC Best Practices](https://bloclibrary.dev/#/architecture)

### MVVM Pattern
- [MVVM in Flutter](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx)

### Flutter Architecture
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)

---

## 📝 Notes

- This README describes the architecture **before** code generation
- Code will follow the patterns and structure outlined here
- All components will be implemented according to these specifications
- The theme will use a dark-purple gradient as specified
- **Form state management will be 100% BLoC-based using Events + States pattern (NOT Cubit)**
- All BLoCs will extend `Bloc<Event, State>` with event handlers using `on<Event>()`
- Events and States will use `Equatable` for value equality

---

**Next Steps**: Once this README is approved, we'll proceed with step-by-step code generation following this architecture.
