# Admin Panel (BLoC Plan) — Phase 4 Add Member Dialog Flow

This document defines **Phase 4** for the Admin Panel in this CRM.

Scope for this phase:
- Keep existing role-based admin routing flow from login.
- Keep the left admin drawer visible and functional at all times.
- Keep existing Phase 3 multi-section list layout under `Manage Team`.
- Add `Add Member` dialog flow when tapping `Add Members` button.
- Build the form UI based on attached screenshot (personal information step).
- Follow the current project structure and BLoC pattern already used in the app.
- Follow the current project structure and BLoC pattern already used in the app.

---

## 1. Goal (Phase 4)

When a user enters Admin Panel:
- Show admin drawer on the left with selected menu state and navigation items.
- Open Team Members management screen when user taps `Manage Team` in drawer.
- Keep Phase 3 multi-section team list behavior unchanged.
- When user taps `Add Members`, show modal dialog exactly in the visual structure of attached screenshot.
- Dialog should collect personal information fields and validate required inputs via BLoC-driven state.

---

## 2. Existing Structure Alignment (Mandatory)

Keep consistency with current folders:
- Feature screens/blocs are under `lib/features/presentation/<feature>/...`
- BLoC files stay in `bloc/` with:
  - `*_event.dart`
  - `*_state.dart`
  - `*_bloc.dart`
- Shared constants live in `lib/core/constants/`
- Existing dashboard shell and side menu patterns should be reused/extended, not rewritten from scratch.

Reference patterns already present:
- `lib/features/presentation/dashboard/widgets/side_menu.dart`
- `lib/features/presentation/dashboard/bloc/navigation_bloc.dart`
- `lib/features/presentation/login/bloc/login_bloc.dart`
- `lib/data/models/auth/auth_tokens_response.dart` (`AuthUser.role`)

---

## 3. Phase 4 Scope (What to Build Now)

### 3.1 Admin route and feature entry

Reuse current logic:
- Read role from auth response (`AuthUser.role`) and stored session.
- If role is `admin`, route to admin root route (example: `/admin`).
- Team members multi-section view should open from admin shell when `Manage Team` is selected.

### 3.2 Admin drawer (mandatory)

Build or update the left admin drawer first so it stays visible while Team Members content changes on the right.

Drawer requirements:
- Reuse existing side menu patterns from dashboard and adapt for admin panel.
- Include menu items with active/selected state, icon + label.
- Keep spacing, typography, and colors aligned with the attached design and current app theme.
- Tapping `Manage Team` must render Phase 3 Team Members multi-section UI on the right content area.

### 3.3 `Add Members` dialog trigger and visibility

`Add Members` button behavior:
- Located in `Team Members` header.
- On tap, open centered modal dialog overlay (desktop/web style) with dismiss icon.
- Dialog should support close via:
  - close icon tap,
  - optional outside-tap (configurable),
  - explicit cancel/close action if included later.

Use bloc event-driven approach instead of local ad-hoc booleans where possible.

### 3.4 Add Member dialog layout (design parity)

Dialog structure:
- Title row:
  - `Add Member`
  - close icon on top-right
- Section heading:
  - `Personal Information`
  - helper subtitle text
- Form grid (2-column layout on desktop):
  - Full name
  - Personal E-mail Id
  - Phone Number (country code + number)
  - Home Phone Number (country code + number)
  - D.O.B (date picker)
  - Gender (Male / Female)
  - Marital Status (dropdown)
  - Date of Anniversary
  - Address
  - Address Line 2
  - Zip code
  - City
- Footer:
  - Primary button: `Next`
  - Helper text: complete required details before next operational form

### 3.5 Phase relationship with Phase 3 sections

Phase 4 should not remove existing sections:
- `Admin Data`
- `Sales Team Data`
- `Purchase Team Data`
- `Accounts Team Data`

Dialog opens above current screen regardless of active section state.

---

## 4. BLoC Design for Drawer + Team Members + Add Member Dialog (Phase 4)

Keep admin navigation bloc separate, keep team members bloc for list sections, and add dedicated dialog/form bloc.

Suggested location:
- `lib/features/presentation/admin_panel/bloc/admin_navigation_bloc.dart`
- `lib/features/presentation/admin_panel/bloc/admin_navigation_event.dart`
- `lib/features/presentation/admin_panel/bloc/admin_navigation_state.dart`
- `lib/features/presentation/admin_panel/team_members/bloc/team_members_bloc.dart`
- `lib/features/presentation/admin_panel/team_members/bloc/team_members_event.dart`
- `lib/features/presentation/admin_panel/team_members/bloc/team_members_state.dart`
- `lib/features/presentation/admin_panel/team_members/add_member/bloc/add_member_bloc.dart`
- `lib/features/presentation/admin_panel/team_members/add_member/bloc/add_member_event.dart`
- `lib/features/presentation/admin_panel/team_members/add_member/bloc/add_member_state.dart`

### 4.1 Team Members events

- `TeamMembersFetched()`
- `TeamMembersSearchChanged(String query)`
- `TeamMembersFilterChanged(MemberStatusFilter filter)`  
  (`all`, `online`, `idle`, `offline`)
- `TeamMembersSortFilterTapped()`  
  (opens sort/filter panel or menu in UI layer)
- `TeamMembersSectionChanged(TeamSection section)`  
  (`admin`, `sales`, `purchase`, `accounts`) where needed for focused interactions
- `TeamCategoryTabChanged(TeamSection section, TeamCategoryTab tab)`  
  (for Sales/Purchase/Accounts category tabs)
- `AddMemberTapped()`  
  (request dialog open)
- `TeamMemberEditTapped(String memberId)`
- `TeamMemberDeleteTapped(String memberId)`

### 4.2 Add Member dialog events

- `AddMemberDialogOpened()`
- `AddMemberDialogClosed()`
- `AddMemberFullNameChanged(String value)`
- `AddMemberPersonalEmailChanged(String value)`
- `AddMemberPhoneChanged(String dialCode, String number)`
- `AddMemberHomePhoneChanged(String dialCode, String number)`
- `AddMemberDobChanged(DateTime value)`
- `AddMemberGenderChanged(AddMemberGender value)`
- `AddMemberMaritalStatusChanged(String value)`
- `AddMemberAnniversaryChanged(DateTime value)`
- `AddMemberAddressChanged(String value)`
- `AddMemberAddressLine2Changed(String value)`
- `AddMemberZipCodeChanged(String value)`
- `AddMemberCityChanged(String value)`
- `AddMemberNextPressed()`

Admin navigation events (existing or updated):
- `AdminMenuChanged(AdminMenu menu)`
- `AdminDrawerToggled(bool isCollapsed)`

### 4.3 Team Members state

State fields:
- `List<TeamMemberUiModel> adminMembers`
- `List<TeamMemberUiModel> salesMembers`
- `List<TeamMemberUiModel> purchaseMembers`
- `List<TeamMemberUiModel> accountsMembers`
- `Map<TeamSection, List<TeamMemberUiModel>> visibleMembersBySection`
- `String searchQuery`
- `MemberStatusFilter selectedFilter`
- `Map<TeamSection, TeamCategoryTab> selectedCategoryTabBySection`
- `bool isAddMemberDialogOpen` (or UI listener trigger)
- `bool isLoading`
- `String? errorMessage`

Use immutable state with `copyWith` + `Equatable`.

### 4.4 Add Member state

State fields:
- `bool isDialogOpen`
- `String fullName`
- `String personalEmail`
- `String phoneDialCode`
- `String phoneNumber`
- `String homePhoneDialCode`
- `String homePhoneNumber`
- `DateTime? dob`
- `AddMemberGender? gender`
- `String maritalStatus`
- `DateTime? anniversaryDate`
- `String address`
- `String addressLine2`
- `String zipCode`
- `String city`
- Validation error fields for required inputs
- `AddMemberSubmitStatus status` (`initial`, `invalid`, `valid`, `submitting`, `success`, `failure`)

Use immutable state + `copyWith` + `Equatable`.

### 4.5 UI usage

- Search field changes dispatch `TeamMembersSearchChanged`.
- Filter chips dispatch `TeamMembersFilterChanged`.
- Sales/Purchase/Accounts tabs dispatch `TeamCategoryTabChanged`.
- Table rows are rendered from `visibleMembersBySection[section]`.
- Edit/Delete icons dispatch row actions.
- Sort & Filter button can trigger a local menu/sheet and then dispatch appropriate bloc event.
- Drawer taps dispatch `AdminMenuChanged` to swap right-side content screen.
- `AdminMenu.manageTeam` maps to `TeamMembersScreen` (Phase 3 multi-section UI).
- `Add Members` button dispatches open-dialog event and shows `AddMemberDialog`.
- Form fields dispatch granular change events to `AddMemberBloc`.
- `Next` button validates required fields and moves to next step only on valid state.

---

## 5. Suggested File Plan (Phase 4)

New files:
- `lib/features/presentation/admin_panel/widgets/admin_side_menu.dart` (if not already present)
- `lib/features/presentation/admin_panel/team_members/bloc/team_members_event.dart`
- `lib/features/presentation/admin_panel/team_members/bloc/team_members_state.dart`
- `lib/features/presentation/admin_panel/team_members/bloc/team_members_bloc.dart`
- `lib/features/presentation/admin_panel/team_members/view/team_members_screen.dart`
- `lib/features/presentation/admin_panel/team_members/widgets/team_members_header.dart`
- `lib/features/presentation/admin_panel/team_members/widgets/team_members_filters_bar.dart`
- `lib/features/presentation/admin_panel/team_members/widgets/role_summary_panel.dart` (reusable for all 4 sections)
- `lib/features/presentation/admin_panel/team_members/widgets/team_members_table.dart` (section-aware)
- `lib/features/presentation/admin_panel/team_members/widgets/team_member_row_actions.dart`
- `lib/features/presentation/admin_panel/team_members/widgets/team_section_block.dart`
- `lib/features/presentation/admin_panel/team_members/widgets/team_section_tabs.dart`
- `lib/features/presentation/admin_panel/team_members/widgets/top_performer_card.dart`
- `lib/features/presentation/admin_panel/team_members/add_member/bloc/add_member_event.dart`
- `lib/features/presentation/admin_panel/team_members/add_member/bloc/add_member_state.dart`
- `lib/features/presentation/admin_panel/team_members/add_member/bloc/add_member_bloc.dart`
- `lib/features/presentation/admin_panel/team_members/add_member/view/add_member_dialog.dart`
- `lib/features/presentation/admin_panel/team_members/add_member/widgets/add_member_personal_info_form.dart`
- `lib/features/presentation/admin_panel/team_members/add_member/widgets/add_member_phone_field.dart`
- `lib/features/presentation/admin_panel/team_members/add_member/widgets/add_member_gender_field.dart`

Possible updates:
- `lib/features/presentation/admin_panel/view/admin_panel_shell.dart` (render Team Members page)
- `lib/features/presentation/admin_panel/bloc/admin_navigation_bloc.dart` (wire drawer selection)
- `lib/core/constants/path_constants.dart` (ensure admin/team-members path exists)
- Router configuration (register team members route under admin)
- `lib/features/presentation/admin_panel/team_members/widgets/team_members_header.dart` (`Add Members` click wiring)
- `lib/features/presentation/admin_panel/team_members/view/team_members_screen.dart` (dialog host/listener)

---

## 6. Routing Plan

Add/confirm routes:
- `/admin`
- `/admin/team-members`

Role-based redirect logic:
- `role == 'admin'` -> `/admin`
- otherwise -> existing dashboard/default route

Keep this role check centralized (login success handler and/or global redirect), not scattered in multiple screens.

Navigation behavior inside admin shell:
- Default screen can remain existing admin default.
- On tap of drawer `Manage Team`, navigate/render `/admin/team-members` (or equivalent in-shell state route).
- Keep the selected drawer state in sync with the currently rendered admin content.
- Preserve scroll state/section state when feasible in the same session.

---

## 7. UI Notes (Screenshot-inspired)

- Keep the current admin theme (dark/purple surface and contrast hierarchy).
- Drawer should stay fixed on the left and clearly separate navigation from content.
- Drawer item selection must be visually strong (highlight/contrast) to match design intent.
- Each section should visually split left info panel and right table/list card.
- Status indicators should use colored dots + text (`Online`, `Idle`, `Offline`).
- Filter chips (`All`, `Online`, `Idle`, `Offline`) must show clear selected/unselected states.
- `Sort & Filter` should appear on the same row, right side aligned, before status chips.
- Row actions (edit/delete) should be compact icon buttons with hover feedback.
- Sales/Purchase/Accounts sections should include category tabs exactly as in design rhythm.
- Multi-section page must scroll smoothly and maintain consistent section spacing/dividers.
- Add Member dialog should use dark translucent backdrop and centered card container.
- Dialog uses clear section dividers and compact form spacing similar to attached screenshot.
- Input controls should match existing field style language (border radius, border color, text color).
- `Next` button should be full-width and visually primary within dialog footer.

---

## 8. Out of Scope (Current Phase 4)

- Backend API integration for edit/delete (can use mock/static data first).
- Advanced server-side sort, pagination, and permission matrix rules.
- Real-time presence sync (status can be UI/mock-driven initially).
- Cross-section analytics and performance calculations beyond UI placeholders.
- Final backend create-member API integration (can keep submit mocked in Phase 4).
- Multi-step operational form screens after `Next` (Phase 5+).

---

## 9. Implementation Flow (Phase 4)

Implement in this order:
1. Finalize admin route to open admin shell for admin users.
2. Build/update admin drawer and wire it with `admin_navigation_bloc`.
3. Keep existing Phase 3 multi-section team screen as baseline.
4. Add `Add Members` CTA wiring from header to dialog open event.
5. Create `add_member` bloc (event/state/bloc) for personal information form step.
6. Build dialog shell (`Add Member`, close icon, section heading, divider layout).
7. Build 2-column personal info form widgets and bind to `AddMemberBloc`.
8. Implement form validation and `Next` button submission guard.
9. Keep dialog lifecycle controlled through bloc events and UI listeners.
10. Keep styles consistent with existing admin shell/theme widgets.

