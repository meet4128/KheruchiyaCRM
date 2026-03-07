# API Plan: Create Inquiry (POST)

## Overview

When the user taps **Submit** on the Air Ticket form (`SubmitAirTicket` in `lib/features/presentation/air_ticket/air_ticket_form_screen.dart`), the app must call the **Create Inquiry** API with a JSON body that combines:

1. **Inquiry form data** — from the previous screen `lib/features/presentation/inquiry_form/inquiry_form_screen.dart` (title, phone, fullName, email, reference, clientBehaviour, typeOfBooking, status, etc.).
2. **Air ticket form data** — from the current Air Ticket state (bookingType, flightSegments, typeOfVisa, remark, checklist).

Implementation must follow the **current app structure** and **BLoC** pattern (see `api_plan.md`). No `setState` for submission; validation and API call are driven by `AirTicketBloc` (or a repository called from the bloc).

---

## 1. App Structure & BLoC (Mandatory)

- **Trigger:** `SubmitAirTicket` event in `AirTicketBloc` (already fired from the checklist section Submit button).
- **State:** Submission status (`idle` / `submitting` / `success` / `failure`), success/error messages live in `AirTicketState`; keep existing validation in the bloc.
- **Data for payload:** On submit, the bloc must have access to:
  - **Inquiry form:** Data from `InquiryBloc` state (inquiry form screen). When both forms are on the same page, read `InquiryBloc` state when handling `SubmitAirTicket`; or pass a snapshot (e.g. `InquiryFormData`) with the event.
  - **Air ticket:** Current `AirTicketState` (from, to, departureDate, returnDate, bookingType, flightSegments, travellerCount, classType, visaType, remark, checklistItems, etc.).
- **API call:** Should be performed from a **repository** (or use case) invoked by the bloc; the bloc emits `submitting` → then `success` or `failure` based on the result.
- **Loading UI:** While the API is in progress, show a **centered loading progress dialog** (or overlay) that matches the current app theme; see §1.1 below.

### 1.1 Loading progress dialog (while waiting for API response)

- **Requirement:** When the create-inquiry API is being called and the app is waiting for the response, show a **loading progress dialog** in the **center of the screen** so the user knows the request is in progress and cannot submit again.
- **Theme:** The dialog/overlay must **match the current theme** (e.g. use `AppTheme.colors(context)` for background, accent, and text; dark gradient surfaces and secondary/purple accent consistent with the rest of the app).
- **Visibility:** Show as soon as the bloc emits `submitting` (or right before the repository call); hide when the bloc emits `success` or `failure` (or when the repository Future completes).
- **Package (pub.dev):** Use one of the following so the implementation is consistent and maintainable:
  - **[loading_overlay](https://pub.dev/packages/loading_overlay)** — Wrap the screen (or a subtree) with `LoadingOverlay(isLoading: state.isSubmitting, color: ..., child: ...)`. Customize `color` (barrier), `widget` (e.g. themed `CircularProgressIndicator`), and optional loading message. Fits BLoC: drive `isLoading` from `AirTicketState.status == AirTicketSubmissionStatus.submitting`.
  - **Alternative: [flutter_loading_overlay](https://pub.dev/packages/flutter_loading_overlay)** — Global overlay via `startLoading` / `stopLoading`; initialize with a navigator key and pass theme-aligned styling (opacity, overlay color, indicator).
- **Implementation note:** Prefer driving the overlay from **state** (e.g. `BlocListener<AirTicketBloc, AirTicketState>` that shows the dialog when `status == submitting` and pops it when `status` becomes `success` or `failure`), or a single overlay widget that reads `state.isSubmitting` so it stays in sync with the bloc. Style the progress indicator and barrier with `AppTheme` (e.g. `colors.backgroundMedium`, `colors.secondary`) so it matches the current theme.

---

## 2. API Specification

### Base URL & Endpoint

| Item        | Value |
|------------|--------|
| **Base URL** | `http://localhost:5001` |
| **Path**     | `/api/v1/inquiries` |
| **Method**   | `POST` |
| **URL**      | `http://localhost:5001/api/v1/inquiries` |

### Request Body (JSON)

Content-Type: `application/json`.

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Inquiry title (from inquiry form). |
| `phoneNumber` | object | `{ "countryCode": "+91", "number": "9876543210" }` (from inquiry form). |
| `fullName` | string | From inquiry form (firstName + lastName or single fullName). |
| `email` | string | From inquiry form. |
| `typeOfClient` | string | From inquiry form (if present). |
| `address` | string | From inquiry form. |
| `referenceNumber` | object | `{ "countryCode": "+91", "number": "9876543210" }` (from inquiry form). |
| `referenceName` | string | From inquiry form. |
| `clientBehaviour` | string | From inquiry form. |
| `typeOfBooking` | string | From inquiry form (e.g. booking type label). |
| `status` | string | e.g. `"PENDING"`. |
| `airTicket` | object | See below. |
| `checklist` | array | From air ticket checklist (structure TBD from backend). |

### `airTicket` object

| Field | Type | Description |
|-------|------|-------------|
| `bookingType` | string | `"ONE_WAY"` \| `"ROUND_TRIP"` \| `"MULTI_CITY"` (map from `AirTicketBookingType`). |
| `flightSegments` | array | List of segment objects (see below). |
| `typeOfVisa` | string | From air ticket form (e.g. `VisaType.label`). |
| `remark` | string | From air ticket form. |

### `flightSegments[]` item

| Field | Type | Description |
|-------|------|-------------|
| `from` | object | `{ "code": "BOM", "city": "Mumbai" }` — parse from stored value (e.g. `"CODE - City\|Airport Name"` → code + city). |
| `to` | object | `{ "code": "DXB", "city": "Dubai" }` — same parsing. |
| `departureDate` | string | ISO 8601 (e.g. `"2026-03-07T10:51:34.822Z"`). |
| `returnDate` | string (optional) | ISO 8601 for round trip. |
| `travellerCount` | integer | From air ticket state. |
| `travelClass` | string | From air ticket state (e.g. Economy, Business, First). |

### Example request body

```json
{
  "title": "string",
  "phoneNumber": {
    "countryCode": "+91",
    "number": "9876543210"
  },
  "fullName": "string",
  "email": "user@example.com",
  "typeOfClient": "string",
  "address": "string",
  "referenceNumber": {
    "countryCode": "+91",
    "number": "9876543210"
  },
  "referenceName": "string",
  "clientBehaviour": "string",
  "typeOfBooking": "string",
  "status": "PENDING",
  "airTicket": {
    "bookingType": "ONE_WAY",
    "flightSegments": [
      {
        "from": {
          "code": "BOM",
          "city": "Mumbai"
        },
        "to": {
          "code": "DXB",
          "city": "Dubai"
        },
        "departureDate": "2026-03-07T10:51:34.822Z",
        "travellerCount": 1,
        "travelClass": "Economy"
      }
    ],
    "typeOfVisa": "Visitor Visa",
    "remark": "string"
  },
  "checklist": []
}
```

---

## 3. Data Mapping (Current App → API)

| API field | Source |
|-----------|--------|
| `title` | Inquiry form: `InquiryState.title` |
| `phoneNumber.countryCode`, `phoneNumber.number` | Inquiry form: `InquiryState.phoneDialCode`, `InquiryState.phoneNumber` |
| `fullName` | Inquiry form: `InquiryState.firstName` + `InquiryState.lastName` (or single fullName field) |
| `email` | Inquiry form: `InquiryState.email` |
| `address` | Inquiry form: `InquiryState.address` |
| `referenceNumber`, `referenceName` | Inquiry form: `InquiryState.referenceDialCode`, `InquiryState.referenceNumber`, `InquiryState.referenceName` |
| `clientBehaviour` | Inquiry form: `InquiryState.clientBehaviour` |
| `typeOfBooking` | Inquiry form: `InquiryState.bookingType` (e.g. label) |
| `airTicket.bookingType` | `AirTicketState.bookingType` → `ONE_WAY` / `ROUND_TRIP` / `MULTI_CITY` |
| `airTicket.flightSegments` | Build from main segment (`state.from`, `state.to`, `state.departureDate`, `state.returnDate`, …) + `state.flightSegments`; parse from/to strings to `{ code, city }` (e.g. split `"CODE - City\|Airport Name"`). |
| `airTicket.typeOfVisa` | `AirTicketState.visaType?.label` |
| `airTicket.remark` | `AirTicketState.remark` |
| `checklist` | `AirTicketState.checklistItems` (map to API shape when backend contract is known). |

---

## 4. Tech Stack

| Layer | Choice |
|-------|--------|
| HTTP client | **Dio** (existing) |
| API client | **Retrofit** for type-safe POST and JSON body |
| Code gen | **retrofit_generator**, **json_serializable** (existing) |
| State | **flutter_bloc** — `AirTicketBloc` handles `SubmitAirTicket`, calls repository, emits submitting/success/failure |
| Loading dialog | **loading_overlay** ([pub.dev](https://pub.dev/packages/loading_overlay)) — centered progress overlay driven by `state.isSubmitting`; style with `AppTheme` to match current theme |

---

## 5. Implementation Plan (Outline)

1. **Base URL** — Add create-inquiry base (e.g. `http://localhost:5001`) in `lib/core/network/apis.dart` or a dedicated constant; use a Dio instance (or baseUrl) for this backend.
2. **Models** — Request DTO(s) for the JSON body (e.g. `CreateInquiryRequest`, nested `PhoneNumber`, `AirTicketRequest`, `FlightSegmentRequest`, etc.) with `json_serializable`.
3. **Retrofit client** — e.g. `InquiryApiClient` with `@POST('/api/v1/inquiries') Future<...> createInquiry(@Body() CreateInquiryRequest body);`
4. **Repository** — e.g. `InquiryRepository.createInquiry(CreateInquiryRequest)` (or build request from two state snapshots) calling the Retrofit client.
5. **Bloc** — In `_onSubmitAirTicket`: after validation, emit `submitting`; get inquiry form data (from event or `InquiryBloc` when on same page) + current air ticket state → build request → call repository → emit `success` or `failure`.
6. **Inquiry form data on submit** — Ensure Submit has access to inquiry form data (same page with both forms and both blocs, or pass snapshot with `SubmitAirTicket`); see §1.
7. **Loading progress dialog** — Add dependency **loading_overlay** (or chosen alternative) to `pubspec.yaml`. While the API is in progress (`state.status == submitting`), show a centered loading overlay/dialog (e.g. wrap the air ticket screen content with `LoadingOverlay(isLoading: state.isSubmitting, color: AppTheme barrier, widget: themed CircularProgressIndicator)` or equivalent). Drive visibility from `AirTicketState.status` (e.g. via `BlocBuilder`/`BlocListener`) and style with `AppTheme.colors(context)` so the dialog matches the current theme.

---

## 6. Out of Scope for This Doc

- Response body shape and error handling (document when backend is fixed).
- Authentication / headers (add when required).
- Checklist array structure (align with backend).
