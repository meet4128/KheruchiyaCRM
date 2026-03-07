# API Plan: Airport Search (From / To)

## Overview

Replace the current **static airport list + dialog** behavior with a **remote API call** when the user taps **From** or **To** in the flight details section. Use **Dio** and **Retrofit** for the HTTP client and API definition. All UI state and API-driven behavior must follow the **current app structure** and use **BLoC as state management** (no `setState` for search/API logic).

---

## 1. App Structure & BLoC State Management (Mandatory)

Implementation **must** follow the existing app structure and BLoC-based state management.

### 1.1 State management

- Use **flutter_bloc**: **Bloc** (event-driven) or **Cubit** (method-driven) for all business logic and UI state related to airport search. No `setState` for search query, API loading, results, or errors.
- **Feature-level BLoCs** (e.g. `AirTicketBloc`): live under `lib/features/presentation/<feature>/bloc/` with three files:
  - `*_event.dart` — events extend `Equatable`.
  - `*_state.dart` — state extends `Equatable`, uses `copyWith`.
  - `*_bloc.dart` — `extends Bloc<Event, State>`, registers `on<Event>(_handler)`.
- **Widget-level Cubits** (e.g. `AirportPickerCubit`, `TravellerClassPickerCubit`): live under `lib/core/widgets/<widget>/bloc/` (or next to the feature) with a single state class and methods that `emit(state.copyWith(...))`.
- UI only **dispatches events** (Bloc) or **calls methods** (Cubit) and **listens to state** via `BlocBuilder` / `BlocConsumer` / `context.read<>()`.

### 1.2 Where airport search lives

- **Option A (recommended):** Keep airport picker under `lib/core/widgets/airport_picker/`. Replace or extend the existing **AirportPickerCubit** (or introduce an **AirportSearchBloc** in the same folder) so that:
  - Search state (query, loading, results, error) is held in the bloc/cubit.
  - Debounce and throttle run inside the bloc/cubit (e.g. `Timer` + `lastSearchTimestamp`).
  - The picker UI is provided with `BlocProvider` when the sheet/dialog is opened (same pattern as current `showAirportPicker` and `TravellerClassPickerCubit` in `flight_details_section.dart`).
- **Option B:** If airport search is considered part of the air ticket feature only, add an **AirportSearchBloc** under `lib/features/presentation/air_ticket/bloc/` with events (e.g. `SearchQueryChanged`, `SearchRequested`) and state (loading, list, error); the air ticket screen or flight details section would provide it and the airport picker UI would depend on it.

### 1.3 Providing the bloc

- When the user taps **From** or **To**, the screen opens a bottom sheet (or dialog). That sheet **must** be wrapped with `BlocProvider` (and optionally `RepositoryProvider` if a repository is used) so the sheet’s subtree has access to the airport search Bloc/Cubit. Same pattern as current `BlocProvider` for `AirportPickerCubit` in `airport_picker.dart` and for `TravellerClassPickerCubit` in `flight_details_section.dart`.

### 1.4 Summary

| Rule | Description |
|------|-------------|
| No setState for search | Search query, loading, results, and errors are stored only in Bloc/Cubit state. |
| Events or methods | Use Bloc (events) or Cubit (methods); match the style of the layer (feature vs widget). |
| Folder structure | Feature blocs: `lib/features/.../bloc/`; widget blocs: `lib/core/widgets/.../bloc/`. |
| Provide at sheet | Use `BlocProvider` when opening the airport picker sheet/dialog. |

---

## 2. Current Behavior (to remove)

- Tapping **From** or **To** opens `showAirportPicker()` dialog.
- Dialog shows a **static list** of airports from `kAirports` in `airport_picker_bloc.dart`.

## 3. New Behavior

- Tapping **From** or **To** does **not** open the existing dialog.
- Instead, the app calls the **search-airports API** (see below) and uses the response to show selectable results (e.g. in a new bottom sheet / dialog that lists API results).

---

## 4. API Specification

### Base URL

- **Base:** `https://www.airportroutes.com`
- **Path:** `/api/search-airports/`

### Endpoint

| Item        | Value |
|------------|--------|
| **Method**  | `GET` |
| **URL**     | `https://www.airportroutes.com/api/search-airports/` |
| **Example** | `https://www.airportroutes.com/api/search-airports/?q=delhi&limit=10&scheduled_service=true` |

### Query Parameters

| Parameter          | Type    | Required | Description |
|--------------------|---------|----------|-------------|
| `q`                | string  | Yes      | Search query (e.g. city name "delhi", airport code, or name). |
| `limit`            | integer | No       | Max number of results (e.g. `10`). |
| `scheduled_service`| boolean | No       | Filter by scheduled service (e.g. `true`). |

### Response (to be confirmed)

- **Action:** Inspect actual API response (status code, JSON shape) and document here.
- **Assumption:** Array of airport objects, e.g. with fields like `code`, `name`, `city`, `country`, etc. Response model and UI (list item) will be defined after response shape is known.

---

## 5. Tech Stack

| Layer        | Choice |
|-------------|--------|
| HTTP client | **Dio** (already in `pubspec.yaml`) |
| API client  | **Retrofit** (to add) for type-safe endpoints and query params |
| Code gen     | **retrofit_generator** (dev dependency) for generating Retrofit implementation |

---

## 6. Throttle & Debounce (Search)

Search will use **debounce** and **throttle** so we don’t call the API on every keystroke or too frequently.

### 6.1 Debounce

- **Purpose:** Trigger the search API only after the user **stops typing** for a short period.
- **Behavior:** On each change of the search text, start (or reset) a timer. When the timer fires after **X ms** with no new input, perform the API call with the current query.
- **Suggested duration:** 300–500 ms (e.g. `400 ms`). Tune as needed.
- **Effect:** Typing "delhi" triggers at most one request (after the user pauses), not five (one per character).

### 6.2 Throttle

- **Purpose:** Cap how often the search API can be called (e.g. rapid retriggers from debounce reset or repeated taps).
- **Behavior:** If the last search request was sent less than **Y ms** ago, skip or postpone the next one until the throttle window has passed.
- **Suggested duration:** 800–1500 ms (e.g. `1000 ms`). Should be ≥ debounce so debounce usually fires first; throttle acts as a safety limit.
- **Effect:** Prevents bursts of requests (e.g. after pasting long text or multiple quick actions).

### 6.3 How We Use Them Together

| Technique | When it runs | Role |
|-----------|----------------|------|
| **Debounce** | On every search query change (e.g. text field) | Wait for typing to settle, then call API once. |
| **Throttle** | Before issuing any search request | Ensure we never send more than one request per Y ms. |

- **Flow:** User types → debounce timer resets on each keystroke → after 400 ms idle, debounce fires → throttle checks “has 1000 ms passed since last request?” → if yes, send request; if no, skip or delay.
- **Implementation:** Implement debounce in the UI layer or BLoC (e.g. `Timer` + cancel on new input, or a small utility/extension). Apply throttle in the same place or in the repository before calling the Retrofit client (e.g. track `lastSearchTime` and skip if within 1000 ms).

---

## 7. Implementation Plan

### 7.1 Dependencies

- Add **retrofit** and **retrofit_generator** (and **json_serializable** if not already present) per [Retrofit Dart](https://pub.dev/packages/retrofit) setup.

### 7.2 New / Updated Files

1. **API base URL**
   - Either extend `lib/core/network/apis.dart` with an airport API base (e.g. `airportBaseUrl = 'https://www.airportroutes.com'`) or add a dedicated constant for this external service.
   - Use a **separate Dio instance** or **Dio with baseUrl override** for `airportroutes.com` so existing interceptors (e.g. auth for `test.mixergy.io`) do not apply to this public API.

2. **Retrofit client**
   - New file, e.g. `lib/core/network/airport_api_client.dart` (or under `lib/data/remote/` if you introduce a data layer).
   - Define a Retrofit interface with a method, e.g.:
     - `@GET('/api/search-airports/')`  
     - `Future<SearchAirportsResponse> searchAirports(@Queries() SearchAirportsQuery query);`
   - Query DTO: `q`, `limit`, `scheduled_service` (map from bool to `"true"` / `"false"` or omit if not required).

3. **Models**
   - `SearchAirportsQuery`: `q`, `limit`, `scheduled_service`.
   - Response model (name TBD after response inspection): e.g. `SearchAirportsResponse` with a list of airport items; each item model with at least `code` (and name/city/country as needed for UI).

4. **Repository / use case (optional but recommended)**
   - e.g. `AirportRepository.searchAirports(String query)` that calls the Retrofit client and returns a list of airport models (or a Result type).
   - Keeps **BLoC/Cubit** free of HTTP details; bloc/cubit only calls the repository and emits state.

5. **BLoC / Cubit (must follow §1 App structure)**
   - Replace or extend the current airport picker state (e.g. `AirportPickerCubit` in `lib/core/widgets/airport_picker/bloc/airport_picker_bloc.dart`, or add a new Bloc with event/state files in the same folder).
   - **State management only in Bloc/Cubit:** All search state (query, loading, results, error) lives in bloc/cubit state. No `setState` in the picker UI.
   - On “search” (user types in the sheet): apply **debounce** (e.g. 400 ms) inside the bloc/cubit so the API is called only after the user stops typing; apply **throttle** (e.g. 1000 ms) before each request.
   - Expose:
     - **If Bloc:** events such as `AirportSearchQueryChanged(String query)`; handler runs debounce/throttle and calls repository, then emits state (loading → success with list or failure with error).
     - **If Cubit:** method `searchQueryChanged(String query)` that updates query, runs debounce/throttle, calls repository, and emits loading/success/error state.
   - State fields: at least `searchQuery`, `airports` (list), `isLoading`, `errorMessage`. No dependency on static `kAirports` for this flow.
   - When the airport picker is opened (sheet/dialog), wrap the sheet content with `BlocProvider` (and `RepositoryProvider` if a repository is used), same pattern as current `airport_picker.dart` and `TravellerClassPickerCubit` in `flight_details_section.dart`.

6. **UI (flight_details_section / airport picker)**
   - **From / To tap:** Do **not** call `showAirportPicker()` with static list. Open the new API-based picker sheet/dialog, wrapped with `BlocProvider` (and optionally `RepositoryProvider`).
   - **No setState:** As the user types, the text field only dispatches an event (Bloc) or calls a method (Cubit), e.g. `SearchQueryChanged(query)`. Debounce and throttle run inside the bloc/cubit. The UI uses `BlocBuilder` / `BlocConsumer` to show loading, list of airports, or error from state.
   - Display API results from state; on item tap, call `onFromChanged` / `onToChanged` with the selected airport and close the sheet.

7. **Debounce / Throttle implementation**
   - **Debounce:** Inside the Bloc/Cubit, on each `SearchQueryChanged(query)` (or `searchQueryChanged(query)`), cancel any pending timer and start a new timer (e.g. 400 ms). When the timer fires, apply throttle then call the repository and emit loading/success/error state.
   - **Throttle:** Before calling the repository, check `lastSearchTimestamp`; if now - lastSearchTimestamp < 1000 ms, skip or reschedule. After a successful request, update `lastSearchTimestamp`.
   - Optional: extract a small `Debouncer` / `Throttler` utility (or use an existing package) and reuse for other search fields later.

### 7.3 Flow Summary

1. User taps **From** (or **To**).
2. App opens a search UI (e.g. bottom sheet) with a search field (optional initial query).
3. User types (e.g. "delhi"). Each keystroke updates the query and resets the **debounce** timer; no API call yet.
4. After **400 ms** with no new input, debounce fires. **Throttle** checks: if 1000 ms passed since last request, call `GET .../search-airports/?q=delhi&limit=10&scheduled_service=true` via Retrofit/Dio.
5. Show loading then list of airports from response.
6. User selects an airport → `onFromChanged` / `onToChanged` with selected value → close sheet and update From/To display.

---

## 8. Out of Scope for This Plan

- Caching, retries, and offline behavior (can be added later).
- Authentication for airportroutes.com (assumed public endpoint unless you confirm otherwise).

---

## 9. Next Steps

1. **Confirm API response shape:** Call the endpoint (e.g. with `q=delhi&limit=10&scheduled_service=true`) and document the exact JSON structure.
2. Add **retrofit** (and code gen) to the project and create the **airport API client** and **models**.
3. Introduce a **separate Dio** (or baseUrl) for `https://www.airportroutes.com` and wire it to the Retrofit client.
4. Implement **repository/use case** and **BLoC/Cubit** for search per **§1 App structure** (no setState; state only in bloc/cubit; provide with BlocProvider at sheet). Include **debounce** (e.g. 400 ms) and **throttle** (e.g. 1000 ms) inside the bloc/cubit.
5. Update **flight_details_section** and airport picker UI to use API-driven search (BlocBuilder/BlocConsumer on bloc state) and remove static dialog for From/To.
