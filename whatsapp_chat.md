# WhatsApp Chat API — Integration Plan (Inquiry Q&A Section)

This document defines how to connect the **existing WhatsApp-style UI** (`QnaChatSectionBody` / `QnaChatBloc`) to the **real WhatsApp backend APIs**, replacing the current **mock-only** load/send in `qna_chat_bloc.dart`.

**Supersedes** the generic “Phase 6” endpoints in `inquiry_management_chats.md` (`/inquiries/{id}/qna-messages`). Use **this doc** for API work.

**UI entry (unchanged placement):**

| File | Role |
|------|------|
| `lib/features/presentation/inquiry_management/widget/qna_notes.dart` | `BlocProvider`, `peerPhone` + `inquiryId`, `Expansible` header |
| `lib/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_section_body.dart` | Chat viewport + composer host |
| `lib/features/presentation/inquiry_management/bloc/qna_chat/` | All load/send/refresh logic |
| `lib/features/presentation/inquiry_management/view/inquiry_management_screen.dart` | Passes customer phone into `QnaNotes` |

**Auth:** Same as inquiries/members — `DioClient` + `Authorization: Bearer <accessToken>` from `SharedPrefUtilsKeys.userToken` after login.

**Base URL:** `Apis.inquiryBaseUrl` (default `http://localhost:5001`) — same host as `/api/v1/inquiries`, `/api/v1/auth/login`.

---

## 1. Objective

| Today (mock) | After integration |
|--------------|-------------------|
| `_mockSeedMessages()` on start | `GET .../conversations/{peerPhone}/messages` |
| Local append on send | `POST /api/v1/whatsapp/send` then refresh or merge response |
| `inquiryId` only in bloc | **`peerPhone`** (E.164 digits, no `+`) drives API calls |
| No network errors | Handle 401 / 422 / 502 with user-facing messages |

**Inquiry detail flow (this screen):**

1. User opens inquiry detail → `QnaNotes` expands “Question & answer”.
2. Bloc loads messages for **`peerPhone`** (customer WhatsApp number).
3. User types in composer → **POST send** with `{ to: peerPhone, text }`.
4. **Refresh** (pull-to-refresh or poll) → **GET messages** again (webhook stores inbound on server).

**Chat list API** (`GET /conversations`) is documented for a **future inbox screen**; the inquiry embedded section only **requires** messages + send once `peerPhone` is known.

---

## 2. API specification (backend contract)

### 2.1 Send message

| Item | Value |
|------|--------|
| **Method** | `POST` |
| **Path** | `/api/v1/whatsapp/send` |
| **Headers** | `Content-Type: application/json`, `Authorization: Bearer <token>` |

**Body:**

| Field | Type | Rules |
|-------|------|--------|
| `to` | string | E.164 digits only, **no `+`**, 10–15 digits, e.g. `919876543210` |
| `text` | string | 1–4096 characters |

**Success (200):**

```json
{
  "status": "success",
  "data": {
    "graph": {
      "messages": [{ "id": "wamid.xxx" }]
    }
  }
}
```

### 2.2 List conversations (optional for inquiry section)

| Item | Value |
|------|--------|
| **Method** | `GET` |
| **Path** | `/api/v1/whatsapp/conversations` |
| **Query** | `page` (default 1), `limit` (default 10, max 100), `search` (optional phone substring) |

**Success (200):** `data.items[]` with `peerPhone`, `lastMessage`, `lastActivityAt`, `messageCount`, pagination meta.

**Use when:** Building a global WhatsApp inbox, or resolving `peerPhone` by search — **not required** for Phase 3 if inquiry already has phone.

### 2.3 Messages in one chat (required)

| Item | Value |
|------|--------|
| **Method** | `GET` |
| **Path** | `/api/v1/whatsapp/conversations/{peerPhone}/messages` |
| **Query** | `page` (default 1), `limit` (default 50, max 100), `sort` (default `createdAt`; `-createdAt` = newest first) |

**Success (200):** `data.peerPhone`, `data.items[]`, `page`, `limit`, `totalItems`, `totalPages`.

**Message item:**

| Field | Description |
|-------|-------------|
| `wamid` | Message id |
| `direction` | `inbound` = customer → you, `outbound` = you → customer |
| `peerPhone` | E.164 digits |
| `type` | e.g. `text` (v1: support `text` only in UI) |
| `text` | Body for text messages |
| `waTimestamp` | Optional WhatsApp time |
| `createdAt` | Stored time (use for UI timestamps + date pills) |

### 2.4 Errors

| Status | Meaning |
|--------|---------|
| 401 | Missing or invalid JWT |
| 422 | Bad `to`, empty `text`, invalid `peerPhone` in URL |
| 502 | WhatsApp Graph API failure |

### 2.5 Receiving inbound (server-side)

Meta webhook → backend stores message → Flutter sees it on next **GET messages** (poll or pull-to-refresh). No WebSocket in v1 plan.

---

## 3. Mapping API → existing UI model

Keep `QnaChatMessage` / bubbles unchanged; map in a small helper (bloc or `mappers/whatsapp_message_mapper.dart`).

| API | `QnaChatMessage` |
|-----|------------------|
| `direction: inbound` | `QnaChatMessageKind.question` → **left** gray bubble |
| `direction: outbound` | `QnaChatMessageKind.answer` → **right** purple bubble |
| `text` | `body` |
| `type: text` | `QnaChatMessageContentType.text` |
| `wamid` | `id` |
| `createdAt` | `createdAt` (parse ISO → `DateTime`) |
| Non-text `type` (future) | `structured` or placeholder “Unsupported message type” |

**Sort for UI:** Request `sort=createdAt` (oldest first) so `ListView` top = older, bottom = newer (matches current scroll-to-bottom on send).

---

## 4. `peerPhone` — required input

WhatsApp APIs key on **`peerPhone`**, not `inquiryId`.

| Source | Status |
|--------|--------|
| `VendorInquiryRow.phoneDisplay` | Currently `'—'` until inquiry API exposes phone |
| `ListInquiryItem` | No phone field yet — add when backend provides |
| Dev/testing | Hard-code `919876543210` behind debug flag or env |

**Normalization helper** (use before every API call):

```dart
/// Strips +, spaces, dashes; returns null if not 10–15 digits.
String? normalizePeerPhone(String? raw);
```

**Plumbing:**

```dart
QnaNotes({
  required this.peerPhone,  // E.164 digits, no +
  this.inquiryId = '',
})
```

```dart
// inquiry_management_screen.dart
QnaNotes(
  inquiryId: widget.vendorRow?.bookingId ?? '',
  peerPhone: widget.vendorRow?.peerPhoneE164 ?? '',
)
```

Add `peerPhoneE164` on `VendorInquiryRow` when mapping from API (Phase 2).

If `peerPhone` is empty → bloc emits `failure` with message “Customer phone not available” (no send, no GET).

---

## 5. Architecture (mandatory — same as app)

### 5.1 Layers

| Layer | Responsibility | Location |
|-------|----------------|----------|
| **UI** | `QnaChatSectionBody`, composer, list — dispatch events only | `widgets/qna_chat/*`, `qna_notes.dart` |
| **BLoC** | Load, send, refresh, poll, pagination, `peerPhone` validation | `bloc/qna_chat/` |
| **Mapper** | DTO → `QnaChatMessage` | `features/.../mappers/whatsapp_message_mapper.dart` |
| **Repository** | Dio calls, error mapping — **no** `BuildContext` | `data/repositories/whatsapp_repository.dart` |
| **Retrofit** | Endpoints on same Dio instance | Extend `inquiry_api_client.dart` **or** `whatsapp_api_client.dart` + same `baseUrl` |
| **DTOs** | `json_serializable` | `data/models/whatsapp/` |

**Recommendation:** Add methods to existing `InquiryApiClient` (same `Apis.inquiryBaseUrl` + auth) — mirrors `listMembers` / `listInquiries`. If the file grows too large, split `WhatsAppApiClient` registered with the same `DioClient.getInstance()`.

### 5.2 BLoC rules

- **No `setState`** for messages, loading, send, or errors.
- UI uses `BlocBuilder` / `BlocConsumer` (already in `QnaChatMessageList`, `QnaChatComposer`).
- Inject `WhatsAppRepository` into `QnaChatBloc` via `get_it`.
- Remove `_mockSeedMessages()` when Phase 3 ships (keep behind `kDebugMode` flag only if needed for UI demos).

### 5.3 DI (`lib/di/injector.dart`)

```dart
sl.registerLazySingleton<WhatsAppRepository>(
  () => WhatsAppRepository(sl<InquiryApiClient>()),
);
sl.registerFactory(
  () => QnaChatBloc(whatsappRepository: sl<WhatsAppRepository>()),
);
```

### 5.4 State additions (`QnaChatState`)

| Field | Purpose |
|-------|---------|
| `peerPhone` | Normalized E.164 digits |
| `page`, `limit`, `totalItems`, `hasMore` | Pagination for GET messages |
| `isRefreshing` | Pull-to-refresh overlay |
| `isLoadingMore` | Prepend older page |
| `lastRefreshAt` | Optional poll throttle |

Events to add:

| Event | Purpose |
|-------|---------|
| `QnaChatStarted({ inquiryId, peerPhone })` | Validate phone → load page 1 |
| `QnaChatLoadMoreRequested` | `page + 1`, prepend older |
| `QnaChatRefreshRequested` | Re-fetch page 1 (same `sort`) |
| `QnaChatSendPressed` | POST send → refresh or optimistic merge |

---

## 6. File plan

```
lib/
├── core/network/
│   ├── apis.dart                          # optional path constants
│   └── inquiry_api_client.dart            # + whatsapp GET/POST (or whatsapp_api_client.dart)
├── data/
│   ├── models/whatsapp/
│   │   ├── send_whatsapp_message_request.dart
│   │   ├── send_whatsapp_message_response.dart
│   │   ├── list_whatsapp_conversations_response.dart
│   │   ├── list_whatsapp_messages_response.dart
│   │   └── whatsapp_message_item.dart
│   └── repositories/
│       └── whatsapp_repository.dart
├── features/presentation/inquiry_management/
│   ├── bloc/qna_chat/                     # wire repository; remove mock
│   ├── mappers/whatsapp_message_mapper.dart
│   ├── widget/qna_notes.dart              # peerPhone param
│   └── widgets/qna_chat/
│       ├── qna_chat_section_body.dart     # optional RefreshIndicator wrapper
│       └── qna_chat_message_list.dart     # pull-to-refresh, load-more at top
```

Run after new models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 7. UI touchpoints (`qna_chat_section_body.dart`)

Minimal changes — logic stays in bloc:

| Widget | Phase | Change |
|--------|-------|--------|
| `QnaChatSectionBody` | 5 | Wrap viewport in `RefreshIndicator` → `QnaChatRefreshRequested` |
| `QnaChatMessageList` | 3–5 | Loading / error / empty from `loadStatus`; scroll load-more at top |
| `QnaChatComposer` | 4 | Disable send when `peerPhone` empty or `sendStatus == sending` |
| `QnaNotes` | 2 | Pass `peerPhone`; `BlocConsumer` SnackBar on `sendErrorMessage` / `errorMessage` |

No layout redesign — only data wiring and refresh affordances.

---

# Implementation phases

Complete **in order**. Each phase must leave the app **buildable**.

---

## Phase 1 — Data layer (DTOs + Retrofit + repository)

**Goal:** Callable repository methods; **no** bloc/UI changes yet.

**DTOs** (`lib/data/models/whatsapp/`):

- `SendWhatsappMessageRequest` — `{ to, text }`
- `SendWhatsappMessageResponse` — `status`, `data.graph.messages[].id`
- `WhatsappMessageItem` — `wamid`, `direction`, `peerPhone`, `type`, `text`, `createdAt`, `waTimestamp?`
- `ListWhatsappMessagesData` — `peerPhone`, `items`, `page`, `limit`, `totalItems`, `totalPages`
- `ListWhatsappMessagesResponse` — `status`, `data`
- `ListWhatsappConversationsResponse` + item/lastMessage models (for Phase 8 or search)

**Retrofit** (on `InquiryApiClient`):

```dart
@POST('/api/v1/whatsapp/send')
Future<SendWhatsappMessageResponse> sendWhatsappMessage(
  @Body() SendWhatsappMessageRequest body,
);

@GET('/api/v1/whatsapp/conversations')
Future<ListWhatsappConversationsResponse> listWhatsappConversations(
  @Queries() Map<String, dynamic> queries,
);

@GET('/api/v1/whatsapp/conversations/{peerPhone}/messages')
Future<ListWhatsappMessagesResponse> listWhatsappMessages(
  @Path('peerPhone') String peerPhone,
  @Queries() Map<String, dynamic> queries,
);
```

**Query DTOs:** `ListWhatsappMessagesQuery` (`page`, `limit`, `sort`), `ListWhatsappConversationsQuery` (`page`, `limit`, `search`).

**`WhatsAppRepository`:**

- `Future<ListWhatsappMessagesResponse> listMessages(String peerPhone, ListWhatsappMessagesQuery query)`
- `Future<SendWhatsappMessageResponse> sendMessage(SendWhatsappMessageRequest request)`
- `Future<ListWhatsappConversationsResponse> listConversations(...)` (stub OK until Phase 8)
- Map `DioException`: 401 → `_UnauthorizedException`, 422 → parsed message, 502 → “WhatsApp service unavailable”

**DI:** Register `WhatsAppRepository`.

**Exit criteria:** Unit/manual call from a test or temporary debug button returns JSON; `build_runner` generated files committed.

---

## Phase 2 — `peerPhone` plumbing

**Goal:** Inquiry detail passes a real or test phone into the bloc.

**`VendorInquiryRow` / `ListInquiryItem`:**

- When API adds `phone` / `whatsappPhone` / `mobile`, map to `peerPhoneE164` via `normalizePeerPhone`.
- Until then: optional dev-only constant or field on row for QA (`919876543210`).

**`QnaNotes` / `inquiry_management_screen.dart`:**

- Add `peerPhone` constructor arg.
- `QnaChatStarted(inquiryId: ..., peerPhone: ...)` .

**`QnaChatBloc`:**

- Store `peerPhone` in state.
- If invalid/empty after normalize → `loadStatus: failure`, `errorMessage` from `StringConstant`.

**`normalizePeerPhone`:** `lib/core/utils/phone_utils.dart` (or under `mappers/`).

**Exit criteria:** Bloc logs/receives correct `peerPhone`; empty phone shows error UI in message list (no mock list).

---

## Phase 3 — Load messages (replace mock receive)

**Goal:** `QnaChatSectionBody` shows **real** thread from GET messages.

**Bloc `QnaChatStarted` / `QnaChatRefreshRequested`:**

1. `loadStatus: loading` (keep existing messages on refresh if desired).
2. `whatsappRepository.listMessages(peerPhone, page: 1, limit: 50, sort: 'createdAt')`.
3. Map `items` → `List<QnaChatMessage>` via mapper.
4. `loadStatus: success`, set `page`, `totalItems`, `hasMore`.

**Remove** `_mockSeedMessages()` from production path.

**`QnaChatMessageList`:** Show spinner when loading and empty; error + Retry dispatches `QnaChatRefreshRequested`.

**Exit criteria:** Opening inquiry chat loads messages from `localhost:5001` for configured `peerPhone`; inbound left, outbound right.

---

## Phase 4 — Send message (replace mock send)

**Goal:** Composer **POST** then UI updates.

**Bloc `QnaChatSendPressed`:**

1. Validate `messageDraft.trim()` and `peerPhone`.
2. `sendStatus: sending`.
3. `POST send` with `{ to: peerPhone, text: draft }`.
4. On success: clear draft, `sendStatus: idle`, either:
   - **(A)** `add(QnaChatRefreshRequested())` — simplest, always in sync with server, or
   - **(B)** optimistic right bubble + refresh in background.
5. On 422/502: `sendStatus: failure`, `sendErrorMessage`, SnackBar via `QnaNotes` listener.

**Composer:** Disable send while `sending` or invalid phone (already partially done).

**Exit criteria:** Sent text appears in thread after API + refresh; survives reload.

---

## Phase 5 — Pull-to-refresh + error UX

**Goal:** Match “Refresh → poll messages” from API doc.

**UI:**

- `RefreshIndicator` on `QnaChatSectionBody` viewport → `QnaChatRefreshRequested`.
- `BlocConsumer` on `QnaNotes`: SnackBar for send/load failures.

**Bloc:**

- `isRefreshing` flag so list doesn’t blank entire thread during refresh.

**Strings:** `StringConstant` for WhatsApp-specific errors (invalid phone, service unavailable).

**Exit criteria:** Pull down refreshes; 401 surfaces login message; 422 shows validation text.

---

## Phase 6 — Pagination (older messages)

**Goal:** Scroll to **top** loads previous page.

**Bloc `QnaChatLoadMoreRequested`:**

- If `isLoadingMore` or !`hasMore` → return.
- `page + 1`, same `sort=createdAt`.
- **Prepend** older items to `messages` (maintain chronological order for grouping).

**UI:** `ScrollController` at top threshold → dispatch load more (or explicit “Load older” if simpler).

**Exit criteria:** Long threads load beyond first 50 messages.

---

## Phase 7 — Polling for new inbound (optional v1.1)

**Goal:** New customer messages appear without manual refresh.

**Bloc:**

- `Timer.periodic` (e.g. 15–30s) while section expanded → `QnaChatRefreshRequested` with silent flag (no full-screen loader).
- Cancel timer on `dispose` / section collapsed.

**State:** `silentRefresh` to avoid scroll jump.

**Exit criteria:** Inbound webhook-stored messages show after interval while chat open.

---

## Phase 8 — Conversations list (future / optional)

**Goal:** `GET /conversations` for a **separate inbox screen** or phone lookup.

**Not required** for `qna_chat_section_body.dart` if inquiry always has `peerPhone`.

**If needed:** Search conversations by `search=9876` to pick `peerPhone` when inquiry has no phone.

**Exit criteria:** Document only unless product requests inbox UI.

---

## 8. Flutter flow summary (inquiry detail)

```
Login → SharedPrefUtilsKeys.userToken
       ↓
Open InquiryManagementScreen(vendorRow)
       ↓
QnaNotes(peerPhone: normalize(row.phone), inquiryId: row.bookingId)
       ↓
QnaChatStarted → GET /conversations/{peerPhone}/messages?page=1&limit=50&sort=createdAt
       ↓
QnaChatSectionBody → list + composer
       ↓
User sends → POST /whatsapp/send { to: peerPhone, text }
       ↓
QnaChatRefreshRequested (or poll) → GET messages again
```

---

## 9. Testing plan

| Phase | Manual test |
|-------|-------------|
| 1 | `curl` or Postman matches app; codegen builds |
| 2 | Empty phone → error; valid `919876543210` → passes normalize |
| 3 | GET returns thread; inbound left / outbound right |
| 4 | Send appears on server + in UI after refresh |
| 5 | Pull-to-refresh; 422 bad `to` shows message |
| 6 | Load more at top when `totalItems > 50` |
| 7 | Second device/webhook message appears after poll |

**Local server:** `BASE_URL=http://localhost:5001` — same as `Apis.inquiryBaseUrl`.

**Android emulator:** `http://10.0.2.2:5001` (document in `apis.dart` comment).

---

## 10. Out of scope (v1)

- Real-time WebSocket / Meta webhook in Flutter (backend only).
- Media messages (image/audio) — text only until API supports.
- Read receipts, typing indicators.
- Replacing `InquiryManagementBloc` or vendor table logic.
- Amendment-type sheet tied to WhatsApp (keep UI; no API unless backend adds field).

---

## 11. Checklist vs `inquiry_management_chats.md`

| Item | Status |
|------|--------|
| UI screenshot 2 (bubbles + composer) | Done (Phases 1–5 UI doc) |
| API integration | **This doc** (Phases 1–7) |
| Generic `/inquiries/{id}/qna-messages` | **Do not implement** — use WhatsApp paths above |

---

## 12. Summary

| Decision | Value |
|----------|--------|
| **Receive** | `GET /api/v1/whatsapp/conversations/{peerPhone}/messages` |
| **Send** | `POST /api/v1/whatsapp/send` |
| **Chat list** | `GET /api/v1/whatsapp/conversations` (optional / later) |
| **Bloc** | Extend existing `QnaChatBloc` + `WhatsAppRepository` |
| **Key param** | `peerPhone` (E.164, no `+`) |
| **Direction map** | `inbound` → left question, `outbound` → right answer |
| **UI file** | `qna_chat_section_body.dart` — refresh only; logic in bloc |

Implement phases **sequentially**; prefer one PR per phase for review.
