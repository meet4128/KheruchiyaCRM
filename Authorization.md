# Authorization (Dynamic Token) — API Flow

## Overview

The project currently attaches `Authorization: Bearer <token>` in `DioClient` (`lib/core/network/dio_client.dart`) and falls back to a **static dev token** when `SharedPrefUtilsKeys.userToken` is empty.

Goal: **make token fully dynamic** by integrating the backend login endpoint:

- `POST /api/v1/auth/login`
- Base URL: `Apis.inquiryBaseUrl` (e.g. `http://192.168.1.7:5001`)
- Body:

```json
{
  "userId": "dev-user",
  "email": "meet@example.com",
  "role": "user"
}
```

When the API returns **401 (token expired/invalid)**, the app should:

1. Call `POST /api/v1/auth/login`
2. Store the returned access token in shared prefs (`SharedPrefUtilsKeys.userToken`)
3. Retry the original request once with the new token
4. If login fails, show a clear message (snackbar) and/or navigate to login (future)

All logic must follow the existing **BLoC + repository** architecture.

---

## 1. Where token is stored (current app)

- Shared prefs keys: `lib/core/utils/shared_pref_utils.dart`
  - `SharedPrefUtilsKeys.userToken`

---

## 2. Current networking behavior (important)

File: `lib/core/network/dio_client.dart`

- Adds `Authorization: Bearer <token>` for all requests except:
  - `Apis.login`
  - `Apis.forgotPassword`
  - `Apis.refreshTokenUrl`
- On 401 it currently attempts `_refreshAccessToken()` (uses `Apis.refreshTokenUrl`)
- If `SharedPrefUtilsKeys.userToken` is empty it uses `_devAccessToken` fallback

To fully switch to dynamic auth for inquiry APIs:

- Remove/disable the `_devAccessToken` fallback once login flow is wired.
- Update the 401 handler to use **`POST /api/v1/auth/login`** instead of `/account/refresh` for the inquiry server.

---

## 3. API: Login (POST `/api/v1/auth/login`)

### Endpoint

| Item | Value |
|------|------|
| Method | `POST` |
| Path | `/api/v1/auth/login` |
| Base URL | `Apis.inquiryBaseUrl` |

### Request headers

- `Content-Type: application/json`
- No `Authorization` header required for this endpoint

### Request body

```json
{
  "userId": "dev-user",
  "email": "meet@example.com",
  "role": "user"
}
```

### Response (expected)

Backend should return an access token (field name depends on backend). Common patterns:

- `{ "accessToken": "<jwt>" }`
- `{ "token": "<jwt>" }`
- `{ "data": { "accessToken": "<jwt>" } }`

Store the token to:

- `SharedPrefUtils.setValue(SharedPrefUtilsKeys.userToken, accessToken)`

---

## 4. Architecture (BLoC-friendly)

### 4.1 Retrofit client(s)

Add an auth Retrofit client dedicated to inquiry server auth, e.g.:

- `lib/core/network/auth_api_client.dart`
  - `@POST('/api/v1/auth/login') Future<LoginResponse> login(@Body() LoginRequest body);`

Keep it separate from `InquiryApiClient` to keep responsibilities clear.

### 4.2 Repository layer

Add a repository that owns login call + token persistence:

- `lib/data/repositories/auth_repository.dart`

Responsibilities:

- call auth API client
- parse token from response
- save token to `SharedPrefUtilsKeys.userToken`
- return token (or bool) to caller

No UI logic in repository.

### 4.3 BLoC layer

There are two acceptable patterns:

#### Pattern A (recommended): Handle 401 + re-login at Dio interceptor level

This keeps BLoC code clean; blocs only call repositories and deal with success/failure.

Flow:

1. Any inquiry request returns **401**
2. `DioClient.onError` detects 401 and `_needsAuth(...) == true`
3. Call `_loginAndStoreAccessToken()` (uses `POST /api/v1/auth/login`)
4. If login succeeds:
   - load `SharedPrefUtilsKeys.userToken`
   - retry original request once with new header
5. If login fails:
   - clear stored token
   - allow error to bubble up (BLoC sets failure state)
   - UI shows snackbar “Session expired, please log in again”

#### Pattern B: Handle 401 in repository/BLoC

Use only if you want explicit control per feature.

Flow:

1. Repository catches 401 and calls `AuthRepository.login()`
2. If login succeeds, repository retries the original call
3. If login fails, repository throws a user-facing exception

---

## 5. Required changes checklist (implementation guide)

### 5.1 Networking (`DioClient`)

File: `lib/core/network/dio_client.dart`

- Add inquiry-auth login path constant in `Apis`:
  - `static const String inquiryAuthLogin = '/api/v1/auth/login';` (or full URL)
- Update `_needsAuth` so it **excludes** inquiry login endpoint too.
- Add a new helper similar to `_refreshAccessToken()`:
  - `_loginAndStoreAccessToken()`
  - Use a lock (`Completer`) like `_refreshLock` to avoid multiple parallel logins.
- Remove the static dev token fallback:
  - Remove `static const String _devAccessToken = ...`
  - Remove `if (token.isEmpty) token = _devAccessToken;`
  - Ensure `Authorization` is attached **only** when `SharedPrefUtilsKeys.userToken` exists (non-empty).
- Update refresh/login logic so a real token is obtained via `POST /api/v1/auth/login` and stored in `SharedPrefUtilsKeys.userToken`.

### 5.2 Auth models (minimal)

- `LoginRequest` with `userId`, `email`, `role`
- `LoginResponse` (shape based on backend; extract `accessToken`)

### 5.3 Repositories

- `AuthRepository.login()`:
  - calls auth API
  - extracts token
  - stores to shared prefs

### 5.4 UI behavior (snackbar)

When login cannot be refreshed automatically:

- BLoC should emit failure with message: “Session expired or invalid. Please log in again.”
- UI should show snackbar on failure.

This is already consistent with the current Inquiry Management UI pattern (snackbar on auth failures).

---

## 6. Example curl (for backend verification)

```bash
curl -X 'POST' \
  'http://192.168.1.7:5001/api/v1/auth/login' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "userId": "dev-user",
  "email": "meet@example.com",
  "role": "user"
}'
```

