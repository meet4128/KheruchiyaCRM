# Admin Panel (BLoC Plan) — Phase 3 Multi-Section Team Management UI

This document defines **Phase 3** for the Admin Panel in this CRM.

Scope for this phase:
- Keep existing role-based admin routing flow from login.
- Keep the left admin drawer visible and functional at all times.
- Extend `Manage Team` screen to support **multiple list sections** in a single scrollable page.
- Divide the page into 4 sections:
  - `Admin Data`
  - `Sales Team Data`
  - `Purchase Team Data`
  - `Accounts Team Data`
- Follow the current project structure and BLoC pattern already used in the app.

---

## 1. Goal (Phase 3)

When a user enters Admin Panel:
- Show admin drawer on the left with selected menu state and navigation items.
- Open Team Members management screen when user taps `Manage Team` in drawer.
- Render a unified page with multiple data sections (`Admin`, `Sales`, `Purchase`, `Accounts`) as per attached design.
- Keep each section styled consistently with card/list table layout and row actions (`edit`, `delete`).
- Keep top controls (`Sort & Filter`, status chips, search) where applicable per section block.

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

## 3. Phase 3 Scope (What to Build Now)

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

### 3.3 Team Members multi-section layout (design parity)

Create the Team Members area with this high-level structure:
- Header area:
  - Title: `Team Members`
  - Subtitle: `Manage your members and edit their roles and permissions.`
  - CTA button: `Add Members`
- Search and filter area:
  - Search text field (example placeholder: `Search members...`)
  - Right-aligned controls: `Sort & Filter`, `All`, `Online`, `Idle`, `Offline`
- Body sections (single vertical scroll):
  1. `Admin Data` section:
     - Left info panel (role title + description)
     - Right list/table with `Status` + `Action`
  2. `Sales Team Data` section:
     - Left info panel + top performers mini list
     - Right category tabs (e.g. `All`, `Flight`, `Hotel`, etc.)
     - Team list/table with department/action columns
  3. `Purchase Team Data` section:
     - Same structural pattern as Sales section
  4. `Accounts Team Data` section:
     - Same structural pattern as Sales section

### 3.4 List/Table behavior by section

Common list behavior:
- Row checkbox (single or bulk future support)
- Name, D.O.J, Email columns
- Row `Edit` and `Delete` actions
- Consistent table header, row spacing, and hover states

Section-specific fields:
- `Admin Data` table uses `Status` (`Online`, `Idle`, `Offline`)
- `Sales/Purchase/Accounts` tables use `Department` (or matching business attribute), based on design

---

## 4. BLoC Design for Drawer + Team Members (Phase 3)

Keep admin navigation bloc separate, and expand Team Members state to support multi-section data.

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
- `TeamMembersSectionChanged(TeamSection section)`  
  (`admin`, `sales`, `purchase`, `accounts`) where needed for focused interactions
- `TeamCategoryTabChanged(TeamSection section, TeamCategoryTab tab)`  
  (for Sales/Purchase/Accounts category tabs)
- `TeamMemberEditTapped(String memberId)`
- `TeamMemberDeleteTapped(String memberId)`

Admin navigation events (existing or updated):
- `AdminMenuChanged(AdminMenu menu)`
- `AdminDrawerToggled(bool isCollapsed)`

### 4.2 Team Members state

State fields:
- `List<TeamMemberUiModel> adminMembers`
- `List<TeamMemberUiModel> salesMembers`
- `List<TeamMemberUiModel> purchaseMembers`
- `List<TeamMemberUiModel> accountsMembers`
- `Map<TeamSection, List<TeamMemberUiModel>> visibleMembersBySection`
- `String searchQuery`
- `MemberStatusFilter selectedFilter`
- `Map<TeamSection, TeamCategoryTab> selectedCategoryTabBySection`
- `bool isLoading`
- `String? errorMessage`

Use immutable state with `copyWith` + `Equatable`.

### 4.3 UI usage

- Search field changes dispatch `TeamMembersSearchChanged`.
- Filter chips dispatch `TeamMembersFilterChanged`.
- Sales/Purchase/Accounts tabs dispatch `TeamCategoryTabChanged`.
- Table rows are rendered from `visibleMembersBySection[section]`.
- Edit/Delete icons dispatch row actions.
- Sort & Filter button can trigger a local menu/sheet and then dispatch appropriate bloc event.
- Drawer taps dispatch `AdminMenuChanged` to swap right-side content screen.
- `AdminMenu.manageTeam` should map to `TeamMembersScreen` (Phase 3 multi-section UI).

---

## 5. Suggested File Plan (Phase 3)

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

---

## 8. Out of Scope (Current Phase 3)

- Backend API integration for edit/delete (can use mock/static data first).
- Advanced server-side sort, pagination, and permission matrix rules.
- Real-time presence sync (status can be UI/mock-driven initially).
- Cross-section analytics and performance calculations beyond UI placeholders.

---

## 9. Implementation Flow (Phase 3)

Implement in this order:
1. Finalize admin route to open admin shell for admin users.
2. Build/update admin drawer and wire it with `admin_navigation_bloc`.
3. Expand Team Members bloc (event/state/bloc) for section-wise data models.
4. Map drawer `Manage Team` selection to Phase 3 `TeamMembersScreen`.
5. Build page header and global search/filter controls.
6. Build `Admin Data` block (left panel + status-based table).
7. Build `Sales Team Data` block (left panel + top performers + tabbed table).
8. Build `Purchase Team Data` block (same component pattern as Sales).
9. Build `Accounts Team Data` block (same component pattern as Sales).
10. Wire bloc updates to section-wise filters, tabs, and row actions.
11. Keep styles consistent with existing admin shell/theme widgets.

