# API Plan: List Inquiries (GET)

## Overview

The **Inquiry Management** feature needs a **List Inquiries** API flow to fetch inquiries with pagination + filters for displaying in the inquiry management UI.

- **Endpoint**: `GET /api/v1/inquiries`
- **Required params**: `page`, `limit`
- **Optional params**: `typeOfBooking`, `typeOfClient`, `status`, `search`, `sort`

Implementation must follow the **current app architecture** and **BLoC** state management style (same pattern used for Create Inquiry).

---

## 1. App Structure & BLoC (Mandatory)

### 1.1 Where this logic lives

- **UI** (renders list + dispatches events):
  - `lib/features/presentation/inquiry_management/view/inquiry_management_screen.dart`
- **BLoC** (holds state + triggers API via repository):
  - `lib/features/presentation/inquiry_management/bloc/inquiry_management_bloc.dart`
  - `lib/features/presentation/inquiry_management/bloc/inquiry_management_event.dart`
  - `lib/features/presentation/inquiry_management/bloc/inquiry_management_state.dart`
- **Repository** (API communication only; no UI logic):
  - `lib/data/repositories/inquiry_repository.dart`
- **Retrofit API client**:
  - `lib/core/network/inquiry_api_client.dart` (+ `*.g.dart`)

### 1.2 Rules (must follow)

- No `setState` for API/data logic (pagination, filters, search, sort, loading, errors).
- UI only dispatches **events** to `InquiryManagementBloc`.
- Bloc calls the **repository**, repository calls the **Retrofit client**.
- Bloc emits loading/success/failure via `InquiryManagementState`.

---

## 2. API Specification

### Base URL & Endpoint

| Item | Value |
|------|-------|
| **Base URL** | `Apis.inquiryBaseUrl` (see `lib/core/network/apis.dart`) |
| **Path** | `/api/v1/inquiries` |
| **Method** | `GET` |

### Auth / Headers

This endpoint **requires an auth token**.

| Header | Value |
|--------|-------|
| `Authorization` | `Bearer <accessToken>` |
| `Content-Type` | `application/json` |

**Token source (current app)**:

- Access token is stored in shared prefs under `SharedPrefUtilsKeys.userToken` (see `lib/core/utils/shared_pref_utils.dart`).
- Requests automatically attach `Authorization: Bearer ...` via `DioClient` interceptor (see `lib/core/network/dio_client.dart`).

### Query Parameters

| Param | Type | Required | Description |
|------|------|----------|-------------|
| `page` | integer | Yes | Page number (pagination). |
| `limit` | integer | Yes | Items per page (pagination). |
| `typeOfBooking` | string | No | Filter by booking type. |
| `typeOfClient` | string | No | Filter by client type. |
| `status` | string | No | Filter by inquiry status (e.g. `PENDING`). |
| `search` | string | No | Text search (e.g. inquiry number, customer name, phone, etc. as supported by backend). |
| `sort` | string | No | Sort key/direction (backend-defined; e.g. `createdAt:desc`). |

### Example URL

```text
/api/v1/inquiries?page=1&limit=20&status=PENDING&search=hardik&sort=createdAt:desc
```

---

## 3. Retrofit Client (Current Style)

Update the existing `InquiryApiClient` to add a GET method for listing inquiries using query params.

- File: `lib/core/network/inquiry_api_client.dart`
- Existing method: `createInquiry(@Body() CreateInquiryRequest body)`
- Add a new method like:
  - `@GET('/api/v1/inquiries')`
  - `Future<ListInquiriesResponse> listInquiries(...)`

### Query param passing (recommended)

Use `@Queries()` with a small query DTO so the BLoC can pass around pagination + filters cleanly:

- `ListInquiriesQuery`
  - `page` (required)
  - `limit` (required)
  - `typeOfBooking` (optional)
  - `typeOfClient` (optional)
  - `status` (optional)
  - `search` (optional)
  - `sort` (optional)

---

## 4. Repository Layer

Extend `InquiryRepository` (same file used for Create Inquiry) with a method:

- `Future<ListInquiriesResponse> listInquiries(ListInquiriesQuery query)`

Repository responsibility:

- Call `apiClient.listInquiries(...)`
- Parse/normalize server errors into user-facing messages (follow same error surfacing approach as `createInquiry` where applicable)
- No UI logic and no widget dependencies

---

## 5. BLoC Flow (InquiryManagementBloc)

### 5.1 State (must include at minimum)

`InquiryManagementState` should represent:

- **Pagination**
  - `page` (required)
  - `limit` (required)
  - `hasMore` (optional; inferred from response if backend supports)
- **Filters**
  - `typeOfBooking`
  - `typeOfClient`
  - `status`
  - `search`
  - `sort`
- **Data**
  - `items` (list of inquiries)
- **Request status**
  - `status`: `idle` / `loading` / `success` / `failure`
  - `errorMessage` (nullable)
  - Optional: separate flags for `isRefreshing`, `isLoadingMore` to keep UI smooth

### 5.2 Events (example set)

Use events to keep UI “dumb” and all logic in bloc:

- `InquiryManagementInitialized(page, limit)`  
  - Fired when the screen loads.
- `InquiryManagementRefreshed()`  
  - Re-fetch page 1 with current filters.
- `InquiryManagementPageRequested(page)` / `InquiryManagementLoadMoreRequested()`  
  - Pagination (next page).
- `InquiryManagementFiltersChanged({typeOfBooking, typeOfClient, status})`  
  - Should reset to page 1 and fetch.
- `InquiryManagementSearchChanged(search)`  
  - Should reset to page 1 and fetch (debounce optional if UI is typing-driven).
- `InquiryManagementSortChanged(sort)`  
  - Should reset to page 1 and fetch.

### 5.3 Bloc handler rules

- `page` and `limit` are **mandatory** for every request.
- On filter/search/sort change:
  - Reset `page` to 1
  - Clear current items (or keep and show overlay loading) based on UX
  - Fetch first page with updated params
- On load more:
  - Prevent duplicate requests while already loading more
  - Append results into `items`

---

## 6. UI Wiring (Inquiry Management Screens)

- Screen: `lib/features/presentation/inquiry_management/view/inquiry_management_screen.dart`
- Provide and consume `InquiryManagementBloc` using the existing approach (`BlocConsumer` is already used).

UI responsibilities:

- Dispatch `InquiryManagementInitialized(page: 1, limit: <default>)` on entry.
- Provide controls for:
  - pagination (load more / next page)
  - filters (typeOfBooking/typeOfClient/status)
  - search
  - sort
- Render:
  - loading states from bloc state
  - error states from bloc state
  - list data from bloc state

---

## 7. Response Model (Backend Contract)

Response shape is backend-defined. The app needs a response DTO that supports at least:

- list of inquiries (items)
- total or page metadata if backend provides (optional but helpful)

Examples (one of these patterns is common):

- **Pattern A**: `{ "items": [...], "page": 1, "limit": 20, "total": 123 }`
- **Pattern B**: `{ "data": [...], "meta": { "page": 1, "limit": 20, "total": 123 } }`
- **Pattern C**: just an array `[...]` (then `hasMore` is inferred by `items.length == limit`)

Once backend response is confirmed, define:

- `ListInquiryItem` (fields needed for UI cards/rows)
- `ListInquiriesResponse` (items + meta if present)

---

## 8. Tech Stack (Aligned With Current Project)

| Layer | Choice |
|------|--------|
| HTTP client | **Dio** |
| API client | **Retrofit** (`InquiryApiClient`) |
| State management | **flutter_bloc** (`InquiryManagementBloc`) |
| Code gen | **retrofit_generator**, **json_serializable** |

---

## 9. `VendorListView` integration (replace static table data)

Screen:

- `lib/features/presentation/inquiry_management/view/vendor_list_view.dart`

### 9.1 Current state of the screen

The table currently renders **static rows** from the local constant list:

- `_rows` (`List<_VendorRowData>`)

And `_buildTable()` uses:

- `List.generate(_rows.length, ...)` → `_buildTableRow(_rows[index], ...)`

To integrate `GET /api/v1/inquiries`, this screen must render from **BLoC state** (API response), not `_rows`.

### 9.2 UI fields in this screen that must be driven by API/BLoC

These fields exist in `_VendorRowData` and are displayed in `_buildTable()`:

| UI field (current) | Table column key | Source (API item) |
|---|---|---|
| `inquiryNo` | `inquiry` | inquiry number / code (backend field) |
| `generatedAt` | `generated` | created timestamp (format in UI) |
| `name` | `name` | customer full name |
| `bookingType` | `booking` | `typeOfBooking` |
| `priorityType`, `priorityText` | `priority` | priority / SLA or remaining time (backend-defined) |
| `assignedToNames`, `assignedToText` | `assigned` | assignees (backend-defined) |
| `status` | `status` | `status` |

Other UI controls that map to API query params:

- **Search box** (`_searchController` in `_buildToolbar`) → `search`
- **Summary chips** (`_summaryItems` in `_buildSummaryStatusRow`) → typically `status` filter (and/or a special “All” case)
- **Refresh** button(s) → re-fetch current page with current filters (`InquiryManagementRefreshed`)

### 9.3 Required query params (pagination) for this screen

Every list call must include:

- `page` (int) — default `1` when the screen opens
- `limit` (int) — choose a default like `20`

Store these in `InquiryManagementState` so pagination is consistent across refresh/filter/search actions.

### 9.4 BLoC-driven rendering plan for `_buildTable()`

Replace the static `_rows` usage with bloc state:

- Maintain in bloc state:
  - `items` (list of inquiry items from API)
  - `status` (`loading`/`success`/`failure`)
  - `errorMessage` (nullable)
  - `page`, `limit` (required)
  - active filters: `status`, `search`, `typeOfBooking`, `typeOfClient`, `sort`

Then the table builder should:

- If state is `loading` and `items` is empty → show a table skeleton/loading row(s)
- If state is `failure` and `items` is empty → show an error row/empty state with retry
- Otherwise → build rows from `state.items`

### 9.5 Mapping API items to the table row model

Recommended approach:

- Define a lightweight UI mapper (in bloc or a small helper) that converts each API inquiry item into the values needed by the table row renderer (what `_VendorRowData` currently holds).
- Format dates and display strings at a single place (avoid scattering formatting in `_buildDataCellContent`).

If you keep `_VendorRowData` as a UI-only structure, populate it from API items:

- `inquiryNo` ← API: inquiry number/code
- `generatedAt` ← API: `createdAt` (format like `dd/MM/yyyy @ h:mma`)
- `name` ← API: `fullName`
- `bookingType` ← API: `typeOfBooking`
- `status` ← API: `status`
- `assignedToNames/text` ← API: assignees list (or empty if none)
- `priorityType/text` ← API: priority/SLA (if backend does not provide, keep a placeholder until available)

### 9.6 Wiring the existing UI controls to bloc events (no `setState` for data)

This screen currently uses `setState` for summary selection and does not dispatch search changes.
For the API integration:

- Summary chip tap → `InquiryManagementFiltersChanged(status: <mappedStatus>)`
- Search text change (with debounce) → `InquiryManagementSearchChanged(search)`
- Refresh tap → `InquiryManagementRefreshed()`

All of these should result in `page=1` fetch with updated query params.

### 9.7 Pagination UI (page numbers below the table)

This listing supports pagination via **page numbers** shown **below** the table. Tapping a page number must load that page’s data using the same filters/search/sort.

#### What the BLoC must store

In addition to `page` and `limit`, `InquiryManagementState` should include enough metadata to render page buttons:

- `total` (total items) **or**
- `totalPages` **or**
- `hasMore` + a backend-provided page list

Recommended (if backend provides totals):

- `total` (int)
- Derive `totalPages = ceil(total / limit)`

Fallback (if backend does not provide totals):

- Use `hasMore = items.length == limit` to decide if “Next” exists
- Page-number UI cannot be fully accurate without totals; in that case show only Prev/Next until totals are available

#### Events

Add an explicit event to handle page taps:

- `InquiryManagementPageChanged(int page)`

Rules:

- Do not lose current `typeOfBooking`, `typeOfClient`, `status`, `search`, `sort`
- Fetch with required params: `page` + `limit`
- Prevent duplicate requests if the requested page is already loading

#### UI wiring (for `vendor_list_view.dart`)

Below `_buildTable()` render a pagination bar (example behavior):

- Render buttons for `1..totalPages` (or a window like `1 2 3 ... 10`)
- Highlight the active page (`state.page`)
- On tap: dispatch `InquiryManagementPageChanged(tappedPage)`

On any filter/search/sort change:

- Reset `page = 1`
- Fetch page 1 data


