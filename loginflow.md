# Operations Portal — Login flow (plan)

This document defines the **planned** login experience for the Flutter **web** app: UI parity with the Operations Portal mockup, **BLoC-only** state (no `setState`), alignment with existing `lib/` structure, and integration points with routing and auth. **No implementation work is started here** — this is the blueprint to implement in a follow-up.

---

## 1. Goals

- **Visual**: Match the attached design — split layout (brand gradient left ~40–45%, photographic right ~55–60%), centered glass-style login card, typography hierarchy, gradient primary button, global footer bar.
- **Architecture**: Same patterns as the rest of the app — `flutter_bloc`, `equatable` (or consistent state equality), feature folder under `lib/features/presentation/`, optional repository + `Dio`/`get_it` where appropriate.
- **State**: All interactive UI state (fields, validation, password visibility, remember-me, loading, errors) flows through **`LoginBloc`** — widgets use `BlocBuilder` / `BlocListener` / `context.read<LoginBloc>().add(...)` only. **No `setState`** in the login feature.
- **Routing**: Integrate with existing **`go_router`** setup in `lib/core/constants/path_constants.dart` and `createRouter` — login is a **full-screen route outside** `DashboardShell` so the side menu does not appear on the login page.
- **Auth**: Persist session using existing keys in `SharedPrefUtilsKeys` (`userToken`, `refreshToken`, `isLoggedIn`, `isRememberMe`, etc.) and the inquiry auth APIs already described in `Authorization.md` and used in `DioClient` — exact request body must match backend (see §7).

---

## 2. Feature location (project structure)

Proposed layout (mirrors `client_leads`, `inquiry_management`, etc.):

| Area | Path |
|------|------|
| Bloc | `lib/features/presentation/login/bloc/login_bloc.dart` |
| Events | `lib/features/presentation/login/bloc/login_event.dart` |
| States | `lib/features/presentation/login/bloc/login_state.dart` |
| Screen / view | `lib/features/presentation/login/view/login_screen.dart` (or `operations_portal_login_screen.dart` if naming must be explicit) |
| Small widgets | `lib/features/presentation/login/widgets/` — e.g. `_login_card.dart`, `_brand_pane.dart`, `_app_footer.dart` only if the main file grows too large |
| Page wrapper for router | `lib/features/pages/pages.dart` — add `LoginPage` (thin `StatelessWidget` that provides `BlocProvider` + `LoginScreen`) |

Optional (when wiring API):

| Area | Path |
|------|------|
| Repository | `lib/data/repositories/auth_repository.dart` (or extend an existing auth module if introduced) |
| API client | Reuse `InquiryApiClient` / `DioClient` against `Apis.inquiryBaseUrl` — avoid duplicating HTTP stacks |

---

## 3. UI composition (match mockup)

1. **Root**: `Scaffold` with `body` = `Row` (wide web) — use `LayoutBuilder` / `MediaQuery` for minimum widths; stack or column fallback on narrow widths if required later.
2. **Left — brand pane**: `LinearGradient` (magenta/purple → deep indigo), decorative white arc strokes (`CustomPaint` or positioned `Container` borders), centered text: **KHERUCHIYA** + subtitle **TRAVEL HUB PVT. LTD.** (Inter font family already in `pubspec.yaml`).
3. **Right — login pane** (~half width): Full-bleed **photographic background** (airplane window / wing at sunset) on this side only. Use the project constant **`AssetConstants.icLoginBackgroundView`**, which resolves to `assets/icons/ic_login_background_view.jpg` (see `lib/core/constants/asset_constants.dart`). Implement with e.g. `DecorationImage` / `BoxDecoration` on an `Expanded` right `Flexible` child, `fit: BoxFit.cover` (or `BoxFit.fitHeight` + alignment) so the image fills the right half without stretching awkwardly on wide viewports. Do not hardcode the path string in the login widget — import `AssetConstants` for a single source of truth.
4. **Card**: Semi-transparent dark panel, rounded corners, light border; contains:
   - Title: **OPERATIONS PORTAL**
   - Subtitle: **Login with Kheruchiya Travels**
   - Disclaimer line (small grey)
   - Email field (label + field)
   - Password field (label + field + eye toggle)
   - Row: “Keep me signed in” + “Forgot Password?”
   - Gradient **Submit** button
   - Footer note inside card (admin contact)
5. **Global footer**: Full-width bottom bar — © year **KTHPL CRM**, Powered by **ZEEMO DIGITAL**, center links **COOKIES** / **LEGAL POLICIES**, right **Version** from `package_info_plus` or hardcoded `1.0.0` to match `pubspec` until dynamic versioning is added.

**Input binding**: Prefer **controlled values from `LoginState`** (`email`, `password`) with `onChanged` dispatching events — avoids keeping `TextEditingController` + sync issues without `setState`. If controllers are used for focus/IME, they must be updated from bloc state in a way that does not require `setState` (e.g. single init + bloc-driven text only).

---

## 4. BLoC contract

### 4.1 Events

| Event | Payload | Purpose |
|-------|---------|---------|
| `LoginEmailChanged` | `String email` | Update email; clear field error when user types |
| `LoginPasswordChanged` | `String password` | Update password; clear field error when user types |
| `LoginPasswordVisibilityToggled` | — | Flip `obscurePassword` in state |
| `LoginRememberMeToggled` | `bool value` | Toggle remember-me |
| `LoginSubmitted` | — | Validate → if valid, call login use-case / repository |

Optional later: `LoginForgotPasswordRequested` (navigation only).

### 4.2 State (single model + status)

Use one `LoginState` with `copyWith` (like `ClientLeadsState` / `InquiryManagementState`):

- **Form**: `email`, `password`, `obscurePassword`, `rememberMe`
- **Validation** (before submit): `emailError`, `passwordError` (nullable strings) — set on submit failure or cleared on change
- **Submission**: `status`: `initial` | `loading` | `success` | `failure`
- **Failure**: `errorMessage` (network / server message)

Avoid separate classes per phase unless the team prefers sealed unions; a **status enum + fields** keeps parity with existing blocs and simplifies `BlocBuilder`.

### 4.3 Validation rules (in bloc)

On `LoginSubmitted`:

- Email: non-empty + valid format (regex or `string` helpers in `lib/core/utils/` if present).
- Password: non-empty + minimum length (define constant, e.g. 8 — confirm with product/security).

If invalid: emit state with errors and **do not** call API.

### 4.4 Success path

- On HTTP success: write tokens via `SharedPrefUtils`, set `isLoggedIn` / `isRememberMe` as appropriate, optionally cache user display info if returned (`AuthTokensResponse` / `AuthUser`).
- Emit `status: success`.
- **Navigation**: `BlocListener` on `LoginScreen` calls `context.go(PathConstant.dashboard)` (or first allowed route) when `success`.

### 4.5 Failure path

- Emit `status: failure` with message; UI shows inline banner or `SnackBar` via `SnackBarUtils` / existing patterns.

---

## 5. Routing

1. **Constants**: Add e.g. `PathConstant.login = '/login'` in `path_constants.dart`.
2. **Route tree**: Register login as a **top-level** `GoRoute` **sibling** to `ShellRoute` (not inside `DashboardShell`), so the login page has no sidebar.
3. **`globalRedirect`**: Uncomment/adapt the existing stub — if not authenticated and path is not login (and not public paths), redirect to `PathConstant.login`; if authenticated and path is login, redirect to dashboard. Requires a reliable **“has valid session”** check (token present and optionally not expired, or `isLoggedIn` + token).
4. **Initial location**: Decide whether `/` stays dashboard for dev or redirects to `/login` when no token — document product choice; implementation should be consistent with `globalRedirect`.
5. **`NavigationBloc`**: Login success lands on dashboard; no change to `NavPage` enum required unless you add a dedicated “logged out” state.

---

## 6. Dependency injection (`lib/di/injector.dart`)

- Register `AuthRepository` (if created) and **`LoginBloc`**:
  - Prefer **`BlocProvider` at route level** (in `LoginPage`) with `create: (_) => LoginBloc(authRepository: sl())` so the bloc is scoped to the login route and disposed when leaving.
  - Alternatively `registerFactory` for `LoginBloc` if the team prefers full `get_it` — less common for UI blocs in Flutter.

---

## 7. API and backend alignment (critical)

- **`DioClient`** already implements refresh/login against **`Apis.inquiryAuthLoginPath`** with a **fixed dev-style body** in code. The **UI collects email + password** — the real Operations Portal backend may expect a different JSON payload.
- **Action before coding the HTTP layer**: Confirm with backend (or update server) the exact **`POST /api/v1/auth/login`** contract for password-based login. `Authorization.md` currently shows `userId` / `email` / `role` without password — the plan assumes the repository method will map **email + password** (and remember-me) to whatever the API requires.
- After login works end-to-end: follow `Authorization.md` to remove or gate **`_devAccessToken`** fallback in `DioClient` for production.

---

## 8. Forgot password / footer links

- **Forgot Password?**: For MVP, `GestureDetector` / `TextButton` dispatching an event that navigates to a placeholder route or opens `mailto:` — or wire to `Apis.forgotPassword` in a later task. Document URL in router when added.
- **COOKIES / LEGAL POLICIES**: External URLs or in-app placeholder routes — stub `#` or real URLs from marketing/legal.

---

## 9. Testing and polish (post-MVP)

- Bloc unit tests: validation, success/failure emissions, remember-me persistence calls.
- Widget tests: golden or smoke test for layout at 1870×1000.
- Web: focus order, Enter key to submit, accessible labels.

---

## 10. Implementation order (when starting development)

1. Right-pane background: use **`AssetConstants.icLoginBackgroundView`** (`ic_login_background_view.jpg` under `assets/icons/`). The app already declares the `assets/icons/` folder in `pubspec.yaml`; no extra asset entry is required unless the file moves.
2. `PathConstant.login` + `GoRoute` for login outside shell + `LoginPage` stub.
3. `LoginEvent` / `LoginState` / `LoginBloc` with validation only (mock success).
4. `LoginScreen` UI to match mockup (BLoC only).
5. `AuthRepository` + real API + persistence; connect `LoginSubmitted`.
6. Implement `globalRedirect` + logout clearing prefs (separate small task if not present).
7. Remove dev token fallback when stable (`DioClient`).

---

## 11. References in repo

- Login background asset constant: `lib/core/constants/asset_constants.dart` — `AssetConstants.icLoginBackgroundView`
- Router: `lib/core/constants/path_constants.dart`, `lib/main.dart`
- Navigation shell: `lib/features/presentation/dashboard/view/dashboard_shell.dart`
- Tokens model: `lib/data/models/auth/auth_tokens_response.dart`
- Shared prefs keys: `lib/core/utils/shared_pref_utils.dart`
- Dio / inquiry auth: `lib/core/network/dio_client.dart`, `lib/core/network/apis.dart`
- Auth roadmap: `Authorization.md`

---

*This file is the agreed plan only; implementation should follow it and stay free of `setState` in the login feature.*
