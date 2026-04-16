# Admin Panel (BLoC Plan) — Left Drawer First

This document defines the first implementation phase for the Admin Panel in this CRM.

Scope for this phase:
- Role-based redirect after login to Admin Panel when user role is `admin`.
- Build only the left-side admin drawer/navigation based on the provided screenshot style.
- Do not render real right-side data/list content yet (use placeholder content only).
- Follow current project structure and BLoC pattern already used in the app.

---

## 1. Goal

When a user logs in:
- If role is `admin`, open Admin Panel.
- If role is non-admin, keep current user flow (existing dashboard/modules).

For Admin Panel UI (Phase 1):
- Implement branded left navigation drawer.
- Keep right content panel minimal/placeholder (no table/list/cards data yet).

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

## 3. Phase 1 Scope (What to Build Now)

### 3.1 Role-based entry point

After successful login:
- Read role from auth response (`AuthUser.role`).
- If role is `admin`, route to Admin Panel root route (example: `/admin`).
- Else route to existing non-admin flow.

Note:
- Routing decision should be triggered from login success state handling (BLoC listener + router), not from ad-hoc widget conditions.

### 3.2 Admin shell with left drawer

Create an Admin shell layout:
- Left: fixed/collapsible drawer (styled similar to screenshot).
- Right: placeholder widget (for now), such as:
  - title text `Admin Content Coming Soon`
  - optional empty-state icon/message

No real data widgets in right panel for this phase.

### 3.3 Drawer menu items (initial static set)

Use static items first, with icon + label + selected state:
- Dashboard
- Manage Team
- Invoices
- Payments
- Inventory
- Team
- Reminders
- Analytics

These can map to enum values in admin navigation state.

---

## 4. BLoC Design for Admin Drawer

Introduce a dedicated admin navigation bloc to avoid mixing user-dashboard state.

Suggested location:
- `lib/features/presentation/admin_panel/bloc/admin_navigation_bloc.dart`
- `lib/features/presentation/admin_panel/bloc/admin_navigation_event.dart`
- `lib/features/presentation/admin_panel/bloc/admin_navigation_state.dart`

### 4.1 Events

- `AdminMenuChanged(AdminMenu menu)`  
  Selects drawer item.
- `AdminDrawerToggled(bool isCollapsed)`  
  Handles collapse/expand behavior.

### 4.2 State

State fields:
- `AdminMenu currentMenu`
- `bool isDrawerCollapsed`

Use immutable state with `copyWith` + `Equatable`.

### 4.3 UI usage

- Drawer taps dispatch `AdminMenuChanged`.
- Shell listens via `BlocBuilder` to:
  - highlight selected drawer item
  - update right-side placeholder title based on selected menu
- Drawer collapse/expand is controlled by bloc state.

---

## 5. Suggested File Plan (Phase 1)

New files:
- `lib/features/presentation/admin_panel/bloc/admin_navigation_event.dart`
- `lib/features/presentation/admin_panel/bloc/admin_navigation_state.dart`
- `lib/features/presentation/admin_panel/bloc/admin_navigation_bloc.dart`
- `lib/features/presentation/admin_panel/view/admin_panel_shell.dart`
- `lib/features/presentation/admin_panel/widgets/admin_side_menu.dart`
- `lib/features/presentation/admin_panel/widgets/admin_placeholder_content.dart`

Possible updates:
- `lib/core/constants/path_constants.dart` (add admin route path)
- Login success navigation handler (where role-based route decision is made)
- Router configuration (register admin route/shell)

---

## 6. Routing Plan

Add route for admin panel:
- Example path: `/admin`

Role-based redirect logic:
- `role == 'admin'` -> `/admin`
- otherwise -> existing dashboard/default route

Keep this role check centralized (login success handler and/or global redirect), not scattered in multiple screens.

---

## 7. UI Notes for Drawer (Screenshot-inspired)

- Dark gradient background for drawer.
- Logo at top.
- Vertical menu list with icon + label.
- Selected item visual state (highlight background/text).
- Optional collapsed mode for icon-only drawer.
- Consistent spacing, padding, hover/tap feedback for web UX.

Use current app colors/assets/constants wherever possible to remain visually consistent.

---

## 8. Out of Scope (Current Phase)

- Team table/list rendering on right side.
- Filters, search, tabs, and member details content.
- API integration for admin modules.
- Permission matrix per admin submenu.

These will be done in next phases after drawer shell is finalized.

---

## 9. Next Step After This Doc

Implement Phase 1 code in this order:
1. Add admin route and shell.
2. Add admin navigation bloc (event/state/bloc).
3. Build drawer widget and wire it to bloc.
4. Add right-side placeholder only (no data rendering).
5. Hook login success to role-based route (`admin` -> admin panel).

