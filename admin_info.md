# Admin Panel (BLoC Plan) — Phase 2 Team Members UI

This document defines **Phase 2** for the Admin Panel in this CRM.

Scope for this phase:
- Keep existing role-based admin routing flow from login.
- Build/update the admin left drawer (navigation) to match the new design direction.
- Build the Team Members screen UI based on the latest attached design.
- Add left-side role block, members table/list, row actions (edit/delete), and right-side filter menu.
- Follow current project structure and BLoC pattern already used in the app.

---

## 1. Goal (Phase 2)

When a user enters Admin Panel:
- Show admin drawer on the left with selected menu state and navigation items.
- Open Team Members management screen when user taps `Manage Team` in drawer.
- Show role section on left (example: `Admin (3)` with description).
- Show members list/table with row-level `edit` and `delete` actions.
- Show right-side/top-right menu options: `Sort & Filter`, `All`, `Online`, `Idle`, `Offline`.

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

## 3. Phase 2 Scope (What to Build Now)

### 3.1 Admin route and feature entry

Reuse current logic:
- Read role from auth response (`AuthUser.role`) and stored session.
- If role is `admin`, route to admin root route (example: `/admin`).
- Team members view should be active from admin shell navigation.

### 3.2 Admin drawer (mandatory)

Build or update the left admin drawer first so it stays visible while Team Members content changes on the right.

Drawer requirements:
- Reuse existing side menu patterns from dashboard and adapt for admin panel.
- Include menu items with active/selected state, icon + label.
- Keep spacing, typography, and colors aligned with the attached design and current app theme.
- Tapping `Manage Team` must render Phase 2 Team Members UI on the right content area.

### 3.3 Team Members screen layout (design parity)

Create the Team Members area with these sections:
- Header area:
  - Title: `Team Members`
  - Subtitle: `Manage your members and edit their roles and permissions.`
  - CTA button: `Add Members`
- Search and filter area:
  - Search text field (example placeholder: `Search members...`)
  - Right-aligned controls: `Sort & Filter`, `All`, `Online`, `Idle`, `Offline`
- Body split:
  - Left block: selected role info (example `Admin (3)` + helper text)
  - Right block: members table/list

### 3.4 Members table/list

Table columns:
- Select checkbox
- Name
- D.O.J
- Email
- Status
- Action

Row action expectations:
- Edit icon/button -> open edit-member flow.
- Delete icon/button -> open delete confirmation flow.
- Status display should support at least: `Online`, `Idle`, `Offline`.

---

## 4. BLoC Design for Drawer + Team Members

Keep admin navigation bloc separate, and add a dedicated Team Members bloc.

Suggested location:
- `lib/features/presentation/admin_panel/bloc/admin_navigation_bloc.dart`
- `lib/features/presentation/admin_panel/bloc/admin_navigation_event.dart`
- `lib/features/presentation/admin_panel/bloc/admin_navigation_state.dart`
- `lib/features/presentation/admin_panel/team_members/bloc/team_members_bloc.dart`
- `lib/features/presentation/admin_panel/team_members/bloc/team_members_event.dart`
- `lib/features/presentation/admin_panel/team_members/bloc/team_members_state.dart`

### 4.1 Team Members events

- `TeamMembersFetched()`
- `TeamMembersSearchChanged(String query)`
- `TeamMembersFilterChanged(MemberStatusFilter filter)`  
  (`all`, `online`, `idle`, `offline`)
- `TeamMembersSortFilterTapped()`  
  (opens sort/filter panel or menu in UI layer)
- `TeamMemberEditTapped(String memberId)`
- `TeamMemberDeleteTapped(String memberId)`

Admin navigation events (existing or updated):
- `AdminMenuChanged(AdminMenu menu)`
- `AdminDrawerToggled(bool isCollapsed)`

### 4.2 Team Members state

State fields:
- `List<TeamMemberUiModel> allMembers`
- `List<TeamMemberUiModel> visibleMembers`
- `String searchQuery`
- `MemberStatusFilter selectedFilter`
- `bool isLoading`
- `String? errorMessage`

Use immutable state with `copyWith` + `Equatable`.

### 4.3 UI usage

- Search field changes dispatch `TeamMembersSearchChanged`.
- Filter chips dispatch `TeamMembersFilterChanged`.
- Table rows are rendered from `visibleMembers`.
- Edit/Delete icons dispatch row actions.
- Sort & Filter button can trigger a local menu/sheet and then dispatch appropriate bloc event.
- Drawer taps dispatch `AdminMenuChanged` to swap right-side content screen.
- `AdminMenu.manageTeam` should map to `TeamMembersScreen` (Phase 2 UI).

---

## 5. Suggested File Plan (Phase 2)

New files:
- `lib/features/presentation/admin_panel/widgets/admin_side_menu.dart` (if not already present)
- `lib/features/presentation/admin_panel/team_members/bloc/team_members_event.dart`
- `lib/features/presentation/admin_panel/team_members/bloc/team_members_state.dart`
- `lib/features/presentation/admin_panel/team_members/bloc/team_members_bloc.dart`
- `lib/features/presentation/admin_panel/team_members/view/team_members_screen.dart`
- `lib/features/presentation/admin_panel/team_members/widgets/team_members_header.dart`
- `lib/features/presentation/admin_panel/team_members/widgets/team_members_filters_bar.dart`
- `lib/features/presentation/admin_panel/team_members/widgets/role_summary_panel.dart`
- `lib/features/presentation/admin_panel/team_members/widgets/team_members_table.dart`
- `lib/features/presentation/admin_panel/team_members/widgets/team_member_row_actions.dart`

Possible updates:
- `lib/features/presentation/admin_panel/view/admin_panel_shell.dart` (render Team Members page)
- `lib/features/presentation/admin_panel/bloc/admin_navigation_bloc.dart` (wire drawer selection)
- `lib/core/constants/path_constants.dart` (ensure admin/team-members path exists)
- Router configuration (register team members route under admin)

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

---

## 7. UI Notes (Screenshot-inspired)

- Keep the current admin theme (dark/purple surface and contrast hierarchy).
- Drawer should stay fixed on the left and clearly separate navigation from content.
- Drawer item selection must be visually strong (highlight/contrast) to match design intent.
- Left role panel and right table card should be visually separated with clear borders/background.
- Status indicators should use colored dots + text (`Online`, `Idle`, `Offline`).
- Filter chips (`All`, `Online`, `Idle`, `Offline`) must show clear selected/unselected states.
- `Sort & Filter` should appear on the same row, right side aligned, before status chips.
- Row actions (edit/delete) should be compact icon buttons with hover feedback.

---

## 8. Out of Scope (Current Phase 2)

- Backend API integration for edit/delete (can use mock/static data first).
- Advanced server-side sort, pagination, and permission matrix rules.
- Real-time presence sync (status can be UI/mock-driven initially).

---

## 9. Implementation Flow (Phase 2)

Implement in this order:
1. Finalize admin route to open admin shell for admin users.
2. Build/update admin drawer and wire it with `admin_navigation_bloc`.
3. Create Team Members bloc (event/state/bloc) with search + status filter.
4. Map drawer `Manage Team` selection to `TeamMembersScreen` render/route.
5. Build header, search, right-side filter menu, and left role summary panel.
6. Build members table with status badge and edit/delete row actions.
7. Wire bloc updates to UI interactions and selected filter chip states.
8. Keep styles consistent with existing admin shell/theme widgets.

