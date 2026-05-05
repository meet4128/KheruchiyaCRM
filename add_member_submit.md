# Add Member — Step 2: Operation Information & Submit (plan)

This document defines the **second step** of the Add Member dialog (**Operation Information**), attachments, **Back** / **Submit**, and how it must follow the **current admin theme** (`AppColors`), **existing dialog layout**, and **BLoC pattern**. Work is split into **phases** so each PR or milestone stays reviewable.

**Reference implementation today**

- Dialog host: `lib/features/presentation/admin_panel/team_members/add_member/view/add_member_dialog.dart`
- Step 1 UI: `lib/features/presentation/admin_panel/team_members/add_member/widgets/add_member_personal_info_form.dart`
- BLoC: `add_member_bloc.dart` / `add_member_event.dart` / `add_member_state.dart`
- Reusable field widgets: `add_member_phone_field.dart`, `add_member_gender_field.dart`, `app_text_field.dart`, `app_date_picker.dart`
- Theme: `lib/core/theme/app_colors.dart` — **`AppColors.dark()`** (same source as the current dialog and forms)

---

## Theme & design system (mandatory for all phases)

All new UI must **match Step 1** and the admin dialog — **no ad-hoc palettes** outside `AppColors.dark()` unless the product explicitly extends the theme.

### Colours & surfaces

| Use case | Source |
|----------|--------|
| Dialog card background | `AppColors.dark().backgroundMedium` with opacity ~`0.95` (same as current `add_member_dialog.dart`) |
| Dialog outer border | `AppColors.dark().borderPrimary` with opacity ~`0.55` |
| Dividers (header / body / footer) | `AppColors.dark().borderPrimary` with opacity ~`0.35`, `height: 1` |
| Section title | `AppColors.dark().textPrimary`, `FontWeight.w600` (match `_PersonalInfoHeading` scale) |
| Section subtitle / helper / footer hint | `AppColors.dark().textSecondary`, small size (e.g. `12–13`) |
| Body scroll padding | `EdgeInsets.all(20)` — same as current dialog body |
| Field vertical gap between rows | `14` — same as `AddMemberPersonalInfoForm` |

### Controls

| Control | Rule |
|---------|------|
| Text fields | **`AppTextField`** (uses theme input colours: `inputBackground`, `inputBorder`, `inputBorderFocused`, `inputErrorBorder`, `error` for messages) |
| Phone rows | **`AddMemberPhoneField`** — same pattern as personal step (`+91` default acceptable for office phone) |
| Date of joining | **`AppDatePicker`** — same as DOB on Step 1 |
| Secondary action (**Back**, optional neutral) | **`OutlinedButton`** — mirror Step 1 **Next**: `foregroundColor: textPrimary`, `side: borderPrimary` (~0.65 alpha), `padding` vertical ~`18`, `borderRadius` ~`10` |
| Primary action (**Submit**, **+ Add Role**) | **Gradient or filled** using **`accent` → `secondary` → `primaryLight`** (or `secondaryLight`) from `AppColors.dark()` — aligns with “purple gradient” mock without copying arbitrary hex from Figma. Prefer a small private widget (e.g. `_GradientPrimaryButton`) **local to add_member** first; extract to shared only if reused elsewhere. |
| Close icon | `AppColors.dark().textSecondary` |

### Layout

- Keep dialog **`width: 900`**, **`maxHeight: 760`**, **`borderRadius: 18`** unless product requests responsive breakpoints.
- Step 2 form: reuse the **two-column grid** pattern (`_TwoColumn`) from `add_member_personal_info_form.dart` for visual rhythm; extract `add_member_form_layout.dart` **only** if duplication becomes painful (Phase 2+ decision).

### Copy

- After strings stabilize, move user-visible literals to **`StringConstant`** (project convention); Phase 5 can consolidate.

---

## Product flow (unchanged intent)

1. Admin opens **Add Member** (same entry as today).
2. **Step 1 — Personal Information**: **Next** validates via `AddMemberNextPressed`.
3. On success → **Step 2 — Operation Information** (same `Dialog`, same `AddMemberBloc`).
4. **Back** → Step 1; **preserve Step 1 data**; default **preserve Step 2 draft** when going Back.
5. **Submit** → validate Step 2 → mock or API later → close / feedback.

---

## Architecture: single BLoC

**Extend `AddMemberBloc` + `AddMemberState`** with `currentStep` and Step 2 fields (one wizard, one `BlocProvider`). Granular **events**, immutable **state**, **`copyWith`**, **`Equatable`** — same as Step 1.

---

## Field inventory (Step 2 — for implementation phases)

| Block | Fields |
|-------|--------|
| Grid | First Name, Last Name, Employee ID, Designation, Employment Status (dropdown), Date of joining |
| Type of Role | Department dropdown, Role dropdown, **+ Add Role** (supports multiple rows per product) |
| Phone | Office Phone **required**; optional **Allotted** label copy above field (match mock) |
| Attachments | Aadhar, PAN, Cancel Cheque slots |
| Footer | **Back**, **Submit**, helper line about editing from action column |

Correct placeholder typos from the mock where they say “work e-mail” on non-email fields.

---

# Implementation phases

Complete phases **in order**; each phase should leave the app **buildable** and **visually on-theme**.

---

## Phase 1 — Wizard foundation (BLoC + dialog shell)

**Goal:** Step switching and footers without building the full Operation form yet.

**State**

- Add `AddMemberStep` enum: `personal` | `operation` (default `personal`).
- Add to `AddMemberState` + `props` + `copyWith`.

**Events**

- `AddMemberBackPressed` → set `currentStep` to `personal`.
- Keep `AddMemberNextPressed`; change behaviour: on **valid Step 1**, `emit(state.copyWith(currentStep: AddMemberStep.operation))` — **do not** set `AddMemberSubmitStatus.success` for “step 1 passed” (removes ambiguity for final submit).

**Bloc**

- `_onNextPressed`: only Step 1 validation (existing rules).
- `_onBackPressed`: `currentStep: personal`.
- `AddMemberDialogOpened`: ensure fresh state resets `currentStep` to `personal` (already `const AddMemberState()` if defaults are correct).

**UI (`add_member_dialog.dart`)**

- **Heading**: if `personal` → existing `_PersonalInfoHeading`; if `operation` → new widget **Operation Information** + subtitle *Fill the form with correct details* using **Theme section** typography.
- **Body**: if `personal` → `AddMemberPersonalInfoForm()`; if `operation` → **temporary placeholder** (`SizedBox` + `textSecondary` “Operation form — Phase 2”) so layout is testable.
- **Footer**: if `personal` → current **Next** + helper; if `operation` → **Back** only (OutlinedButton per theme table) **or** Back + disabled **Submit** with label — optional; minimum is **Back** working.

**BlocConsumer**

- Remove / replace listener that fires SnackBar on `success` for step-1-only success (see Phase 1 bloc change).

**Exit criteria:** Next → see placeholder Step 2; Back → Step 1 with data intact; theme matches existing dialog.

---

## Phase 2 — Operation Information form (fields only)

**Goal:** Full **Operation Information** grid on theme; **no** dynamic role rows yet (single department + role row OK as static first row), **no** file picker yet.

**New file**

- `widgets/add_member_operation_info_form.dart` — `BlocBuilder<AddMemberBloc, AddMemberState>`, `_TwoColumn`, spacing `14`, **Theme section** rules.

**State & events**

- Strings: `firstName`, `lastName`, `employeeId`, `designation`, `employmentStatus`, `dateOfJoining` (`DateTime?`), `officePhoneDialCode`, `officePhoneNumber`.
- Optional: single `department`, `role` strings for one row until Phase 3.
- Nullable `String?` errors for validated fields.
- `*Changed` events mirroring Step 1 naming style.

**Bloc**

- Handlers clear field errors and reset final-submit-related status when editing (same pattern as Step 1 field handlers).

**Dialog**

- Replace Phase 1 placeholder with `AddMemberOperationInfoForm()`.

**Exit criteria:** All grid fields + office phone render and bind to bloc; dropdowns use MVP static options (same approach as marital status on Step 1); date picker matches Step 1 styling.

---

## Phase 3 — Type of Role (multi-row)

**Goal:** **+ Add Role** and multiple `{department, role}` rows per mock.

**State**

- `List<MemberRoleAssignment>` (or two parallel `List<String>` if minimal) with Equatable-friendly items.
- Errors: e.g. per-row validation flags or aggregate message (document choice in bloc).

**Events**

- `AddMemberRoleRowAdded`, optional `AddMemberRoleRowRemoved(int index)`.
- `AddMemberRoleDepartmentChanged(int index, String value)`, `AddMemberRoleRoleChanged(int index, String value)` (names adjustable).

**UI**

- Row layout: department dropdown + role dropdown + **+ Add Role** button (gradient per **Theme section**).
- First row may be non-removable; later rows removable if product agrees.

**Exit criteria:** Add Role appends row; each row edits independently; validation rules documented (e.g. at least one complete department+role before submit — product call).

---

## Phase 4 — Attach Documents

**Goal:** Three attachment slots on theme (labels, icons, delete for filled slot).

**Dependency**

- Add `file_picker` (or existing project-wide picker) in `pubspec.yaml` if not already present.

**State**

- Small model per slot: `fileName`, optional `path` / `bytes` (web-safe strategy in implementation).

**Events**

- `AddMemberAttachmentPicked(slot, ...)`, `AddMemberAttachmentCleared(slot)`.

**New file (optional)**

- `widgets/add_member_attachment_slot.dart` — slot UI using `surface` / `borderPrimary`, clip icon, trash for clear.

**Exit criteria:** Pick file shows name; clear restores empty state; no regressions on Step 1.

---

## Phase 5 — Submit, validation polish & copy

**Goal:** **Submit** validates Step 2, loading state, mock success path, dialog close or parent refresh.

**Events**

- `AddMemberSubmitPressed`.

**Bloc**

- **Required on submit (product / mock):** validate **office phone only** (`AppTextFieldValidators.phone`). Other Step 2 fields and attachments remain optional for MVP.
- Emit `AddMemberSubmitStatus.submitting` → mock `success` / `failure`.
- On success: UI `BlocListener` closes dialog and optionally `Navigator.pop` + SnackBar (coordinate with whoever opens `AddMemberDialog`).

**UI (`add_member_dialog.dart`)**

- Step 2 footer: **Back** and **Submit** on one row (equal width), then helper text (*You can edit even after submitting…*) using `textSecondary` `12`.

**Copy**

- Promote stable strings to **`StringConstant`**.

**Exit criteria:** Invalid submit shows errors; valid submit completes mock flow; full wizard matches **Theme & design system** checklist.

---

## File touch list (by phase)

| Phase | Typical paths |
|-------|----------------|
| 1 | `add_member_state.dart`, `add_member_event.dart`, `add_member_bloc.dart`, `add_member_dialog.dart` |
| 2 | `add_member_operation_info_form.dart` + state/event/bloc updates |
| 3 | operation form + state/event/bloc + optional `member_role_assignment.dart` |
| 4 | attachment widget + state/event/bloc + `pubspec.yaml` |
| 5 | bloc submit + dialog footer + `string_constants.dart` |

---

## Testing / QA (run after Phase 5, spot-check after each phase)

- Next invalid Step 1 → stay on Step 1, errors visible.
- Next valid Step 1 → Step 2, personal data intact.
- Back Step 2 → Step 1, both steps’ data preserved.
- Submit invalid Step 2 → errors.
- Close dialog → reopen → Step 1, clean state.
- Visual: Step 2 colours, borders, typography match Step 1 and **Theme & design system** table.

---

## Out of scope (defer)

- Real **create member** API + multipart upload.
- **Edit member** from table row (footer copy is forward-looking).
- Loading department/role from server (Phase 2–3 use static lists).

---

## Summary

Follow **`AppColors.dark()`** and the **existing Add Member dialog + `AppTextField` / phone / date** patterns for every control. Implement in **five phases**: (1) wizard shell + Next/Back refactor, (2) operation grid, (3) multi role rows, (4) attachments, (5) submit + strings + QA. Single **`AddMemberBloc`** with `currentStep` and granular events keeps parity with the current project structure.
