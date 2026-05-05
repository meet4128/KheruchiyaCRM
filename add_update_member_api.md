# Add / Update Member — API integration plan

This document defines how to integrate **POST `/api/v1/members`** (create) and **PATCH `/api/v1/members/{id}`** (update) with the existing **Add Member** wizard, without breaking the current UX or BLoC-driven flow. Work is **phase by phase**; each phase should leave the app buildable and behavior predictable.

**API contract (reference)**

- **Create:** `POST /api/v1/members` — JSON body as provided by backend.
- **Update:** `PATCH /api/v1/members/{id}` — same field shape (partial updates per backend rules; client can send full DTO for simplicity in MVP).

**Host & auth (project alignment)**

- Paths are under **`/api/v1/...`**, consistent with **`InquiryApiClient`** (`create_inquiry`, `list_inquiries`).
- **`lib/di/injector.dart`** wires **`InquiryApiClient(DioClient.getInstance(), baseUrl: Apis.inquiryBaseUrl)`** so **Bearer** and existing interceptors apply to the inquiry host.
- **Recommendation:** add member endpoints to the **same Retrofit client** (`InquiryApiClient`) **or** introduce **`MembersApiClient`** built with the **same `Dio` instance and `Apis.inquiryBaseUrl`** — do **not** introduce a second Dio stack without a strong reason.

---

## 1. UI / state → JSON mapping

Map from **`AddMemberState`** (and related enums) to the API body. Adjust names if backend uses different casing.

| API field | Source |
|-----------|--------|
| `fullName` | `state.fullName` |
| `personalEmail` | `state.personalEmail` |
| `phoneNumber` | `{ "countryCode": state.phoneDialCode, "number": state.phoneNumber }` |
| `homePhoneNumber` | `{ "countryCode": state.homePhoneDialCode, "number": state.homePhoneNumber }` |
| `dateOfBirth` | `state.dob` → ISO `yyyy-MM-dd` |
| `gender` | `state.gender` → `"male"` / `"female"` (lowercase string) |
| `maritalStatus` | Normalize UI values (`Married`, `Unmarried`, `Widow`) → backend enum (e.g. `married`, `unmarried`, `widow`) — **confirm with API** |
| `dateOfAnniversary` | `state.anniversaryDate` → ISO or omit if null |
| `addressLine1` | `state.address` |
| `addressLine2` | `state.addressLine2` (may be empty) |
| `zipCode` | `state.zipCode` |
| `city` | `state.city` |
| `firstName` | `state.firstName` |
| `lastName` | `state.lastName` |
| `employeeId` | `state.employeeId` |
| `designation` | `state.designation` |
| `employmentStatus` | Normalize dropdown (`Active`, …) → e.g. `active` — **confirm with API** |
| `dateOfJoining` | `state.dateOfJoining` → ISO `yyyy-MM-dd` |
| `departmentRoles` | `state.roleRows` → `[{ "department": row.department, "role": row.role }]` |
| `officePhoneNumber` | `{ "countryCode": state.officePhoneDialCode, "number": state.officePhoneNumber }` |
| `aadharDocumentUrl` | From upload pipeline or `null` / omit until URLs exist |
| `panDocumentUrl` | Same |
| `cancelChequeDocumentUrl` | Same |

**Attachments today:** the app stores **local pick** (`fileName`, `path`). The API expects **URLs**. Until a **upload + URL** step exists, send **`null`**, omit keys, or empty string **per backend contract** — document the chosen rule in Phase 4.

---

## 2. Architecture principles (do not break current flow)

1. **Keep `AddMemberBloc` as the single wizard orchestrator** — same events (`AddMemberSubmitPressed`, field `*Changed`, etc.).
2. **Move HTTP only into a repository** (e.g. **`MembersRepository`**), mirroring **`InquiryRepository`**: catch `DioException`, map **401** / **422** to typed failures or messages; no `BuildContext` in repository.
3. **Optional request DTOs** under `lib/data/models/members/` (or `lib/core/models/members/`) with **`json_serializable`** / **`toJson()`** consistent with **`CreateInquiryRequest`**.
4. **Inject repository** via **GetIt** (see **`injector.dart`**); **`AddMemberBloc`** receives **`MembersRepository`** in constructor — update **`TeamMembersScreen`** / dialog host:  
   `BlocProvider(create: (_) => AddMemberBloc(sl<MembersRepository>())..add(...))`  
   (or factory registration if you prefer `sl()` inside create).
5. **Submit handler** today: validate phone → `submitting` → delay → `success`. **After integration:** validate phone (unchanged product rule) → `submitting` → **`await repository.createMember(request)`** → `success` or `failure` with message. Remove artificial delay unless UX wants a minimum spinner duration.
6. **PATCH / edit flow** is **separate entry** (e.g. pre-fill bloc from `MemberDetail`, pass `memberId`). Do not overload create dialog until Phase 7+.

---

## 3. Error handling (match `InquiryRepository`)

- **401:** log + throw (or typed **`UnauthorizedException`**) — global/session handling can mirror inquiry screens.
- **422:** parse `message` / `errors` map like **`InquiryRepository._parseValidationError`** — reuse or extract a small shared helper to avoid drift.
- **Network / 5xx:** user-facing message; emit **`AddMemberSubmitStatus.failure`** and optional **`errorMessage`** on state if product wants inline banner (small BLoC extension).

---

# Implementation phases

Complete in order. Verify **`dart analyze`** and manual **Add Member** flow after each phase.

---

## Phase 1 — API surface & models (no BLoC behavior change)

**Goal:** Typed contracts and Retrofit methods; **no** wiring into submit yet.

**Tasks**

1. Add **`Apis`** constants (optional but consistent):  
   `static const String membersPath = '/api/v1/members';`  
   (Paths can also stay inline in Retrofit annotations.)
2. Add JSON models, e.g.:
   - `PhoneNumberDto` / nested map: `{ countryCode, number }`
   - `DepartmentRoleDto` / `{ department, role }`
   - `CreateMemberRequest` — fields matching POST body
   - `UpdateMemberRequest` — same fields optional where backend supports PATCH partials (or duplicate full DTO with nullable fields — **confirm backend**)
3. Extend **`InquiryApiClient`** (or add **`MembersApiClient`**) with:
   - `@POST('/api/v1/members') Future<...> createMember(@Body() CreateMemberRequest body);`
   - `@PATCH('/api/v1/members/{id}') Future<...> updateMember(@Path('id') String id, @Body() UpdateMemberRequest body);`
4. Run **`build_runner`** for Retrofit / json_serializable generated files.

**Exit criteria:** Project compiles; no call sites yet; current Add Member still uses mock/delay submit.

---

## Phase 2 — `MembersRepository`

**Goal:** Encapsulate HTTP + errors; same pattern as **`InquiryRepository`**.

**Tasks**

1. Add **`lib/data/repositories/members_repository.dart`** with:
   - `Future<MemberCreatedResponse> createMember(CreateMemberRequest request)`  
     (or `Future<void>` if API returns empty — align return type to real response, e.g. `{ id, ... }`.)
   - `Future<void> updateMember(String id, UpdateMemberRequest request)` (or return updated entity).
2. Map **`DioException`** to domain exceptions or strings (reuse 422 parsing pattern).
3. Register in **`injector.dart`**:  
   `sl.registerLazySingleton<MembersRepository>(() => MembersRepository(sl<InquiryApiClient>()));`  
   (Adjust if you used a separate Retrofit client.)

**Exit criteria:** Repository unit-testable / manually callable from a throwaway snippet; **still not** used by **`AddMemberBloc`**.

---

## Phase 3 — `AddMemberState` → `CreateMemberRequest` mapper

**Goal:** Pure mapping function(s), no side effects.

**Tasks**

1. Add e.g. **`lib/features/presentation/admin_panel/team_members/add_member/data/add_member_request_mapper.dart`** (or under `data/mappers/`) with:
   - `CreateMemberRequest mapStateToCreateRequest(AddMemberState state)`
2. Implement enum / dropdown normalization (**marital status**, **employment status**, **gender**).
3. ISO dates via **`intl`** `DateFormat('yyyy-MM-dd')` in UTC/local per API spec.
4. **`departmentRoles`** from **`state.roleRows`**; skip empty rows if any.
5. Document URLs: **`null`** or omit until Phase 6 upload.

**Exit criteria:** Mapper covered by unit tests (recommended) or manual assertion in debug; **not** called from BLoC yet.

---

## Phase 4 — Wire create into `AddMemberBloc` (replace mock)

**Goal:** **Submit** calls **`MembersRepository.createMember`**; success/failure drives existing UI (dialog pop + SnackBar on success).

**Tasks**

1. Add **`MembersRepository`** to **`AddMemberBloc`** constructor; update **`TeamMembersScreen._openAddMemberDialog`** `BlocProvider` to pass **`sl<MembersRepository>()`** (ensure **`setup()`** ran before).
2. In **`_onSubmitPressed`** (after phone validation):
   - Build request via mapper.
   - `emit(…submitting…)`.
   - `try { await repo.createMember(...); emit(…success…); } catch (e) { emit(…failure… + message); }`
3. Remove **`Future.delayed`** mock.
4. **`BlocListener`**: on **`failure`**, show **`SnackBar`** with message; **do not** pop dialog unless product wants that.

**Non-regression checklist**

- Step 1 **Next** unchanged.
- Step 2 **Back** / fields / attachments UI unchanged.
- Only **office phone** required on submit (current product rule) unless product changes.

**Exit criteria:** Creating a member hits real **POST**; errors surface without crashing; token behavior matches other inquiry APIs.

---

## Phase 5 — Document URLs (optional follow-up)

**Goal:** Populate **`aadharDocumentUrl`**, **`panDocumentUrl`**, **`cancelChequeDocumentUrl`**.

**Tasks**

1. Confirm backend: **pre-signed upload**, **multipart on same POST**, or **separate upload endpoint**.
2. Implement upload helper + call **before** or **inside** `createMember`; pass returned URLs into mapper.
3. Handle upload failures (partial success policy).

**Exit criteria:** Attachments in UI result in non-empty URLs when backend requires them.

---

## Phase 6 — PATCH update flow (edit member)

**Goal:** Reuse or parallel **BLoC** for **`PATCH /api/v1/members/{id}`**.

**Tasks**

1. **`UpdateMemberRequest`**: nullable / partial fields per backend.
2. **`MembersRepository.updateMember(id, request)`**.
3. Entry point: **Team table “Edit”** loads existing member → navigates/opens dialog with **`AddMemberBloc`** initial state hydrated **or** dedicated **`EditMemberBloc`** — prefer **single bloc** with optional **`String? editingMemberId`** and **`AddMemberLoadedForEdit`** event to avoid duplicating forms.
4. Submit on edit: **PATCH** instead of **POST** when **`editingMemberId != null`**.

**Exit criteria:** Edit saves via **PATCH**; create still uses **POST** only.

---

## Phase 7 — Polish

- **`StringConstant`** for generic API error strings if needed.
- Retry / offline policy (out of scope unless product asks).
- List refresh: after success, dispatch **`TeamMembersFetched`** (or equivalent) on parent — **coordinate with `TeamMembersBloc`**.

---

## Summary

| Phase | Deliverable |
|-------|-------------|
| 1 | Models + Retrofit **POST/PATCH** declarations |
| 2 | **`MembersRepository`** + DI |
| 3 | **`AddMemberState` → `CreateMemberRequest`** mapper |
| 4 | **`AddMemberBloc`** create path + listener error handling |
| 5 | Document upload → URLs (if required) |
| 6 | **PATCH** edit flow + hydrated state |
| 7 | Parent list refresh, copy, edge cases |

This preserves the **existing BLoC + repository + Retrofit + GetIt** structure used by **Inquiry** features and avoids changing the wizard UX unless explicitly required by the API.
