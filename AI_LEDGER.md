# AI Ledger

> WTF Flutter Assessment — documents how Cursor was used.  
> **Minimum met:** 14 entries · 7+ commits · Coding + Debugging + Refactor sections.

---

## Coding with AI

### Prompt #1 — Monorepo scaffold

- **Tool:** Cursor (Claude)
- **Intent:** Scaffold monorepo per assessment — `shared`, `guru_app`, `trainer_app`, `token_server`, models, ADRs
- **Output:** Folder structure, Hive `LocalStore`, seed DK/Aarav, Riverpod apps, Express token + sync stubs
- **Used in:** commit `90bdc52` — `feat: WTF assessment monorepo with auth, chat sync, and token server`

---

### Prompt #2 — Implementation guide

- **Tool:** Cursor
- **Intent:** Turn Google Doc assessment into phased build plan
- **Output:** `IMPLEMENTATION_STEPS.md` (parent `assign/` folder)
- **Used in:** Planning only (not in app binary)

---

### Prompt #3 — Chat (Phase 4)

- **Tool:** Cursor
- **Intent:** Real-time-style chat — list, conversation, typing, read receipts, cross-app sync
- **Output:** `SyncChatService`, `ChatListScreen`, `ConversationScreen`, `ChatSyncClient`, `/sync/messages`, `/sync/typing`
- **Used in:** commit `90bdc52` — `shared/lib/services/chat_service.dart`, `screens/conversation_screen.dart`

---

### Prompt #4 — Chat sync wiring

- **Tool:** Cursor
- **Intent:** Merge remote messages on poll; Android emulator → `http://10.0.2.2:3000`
- **Output:** 800ms poll in `SyncChatService`, cleartext + INTERNET in Android manifests
- **Used in:** commit `90bdc52` — guru_app + trainer_app chat E2E

---

### Prompt #5 — Scheduler (Phase 5)

- **Tool:** Cursor
- **Intent:** 3-day calendar, 30-min slots, request/approve/decline, slot conflict
- **Output:** `ScheduleCallScreen`, `TrainerRequestsScreen`, `MyRequestsScreen`, `SyncCallService`, `/sync/calls`
- **Used in:** commit `d4c4a0a` — `feat(schedule): call request, approve/decline, and cross-app sync`

---

### Prompt #6 — 100ms video (Phase 6)

- **Tool:** Cursor
- **Intent:** Pre-join preview, in-call UI, JWT from token server, post-call rating sheets
- **Output:** `PreJoinScreen`, `MeetingScreen`, `JoinCallFlow`, `RtcTokenService`, platform permissions
- **Used in:** commit `cad004a` — `feat(rtc): 100ms pre-join, in-call UI, and post-call session flow`

---

### Prompt #7 — Session logs (Phase 7)

- **Tool:** Cursor
- **Intent:** Sessions list with filters, detail sheet, share text, cross-app log sync
- **Output:** `SessionsListScreen`, `SyncLogService`, `/sync/sessions`, `session_log_utils_test.dart`
- **Used in:** commit `07942a1` — `feat(sessions): logs list, filters, and cross-app sync`

---

### Prompt #8 — UI polish (Phase 8)

- **Tool:** Cursor
- **Intent:** Section 4 design — spacing, skeletons, error+retry, CTA hierarchy, motion
- **Output:** `AppSpacing`, `loading_skeleton`, `error_state`, `app_buttons`, `appPageRoute`, bubble slide-in
- **Used in:** commit `0d175b2` — `feat(ui): polish spacing, skeletons, motion, and error states`

---

### Prompt #9 — Observability (Phase 9)

- **Tool:** Cursor
- **Intent:** DevPanel + human-readable errors with copy action
- **Output:** Enhanced `dev_panel.dart`, `app_snackbar.dart`, `humanize_error.dart`, `LogEntry` + `[PERF]`-ready tags
- **Used in:** commit `0a67578` — `feat(dx): dev panel and structured logging`

---

### Prompt #10 — Security & performance (Phase 10)

- **Tool:** Cursor
- **Intent:** Gitignored secrets, token server docs, perf budgets in DevPanel
- **Output:** `SECURITY.md`, `token_server/README.md`, `PerfTracker`, `[PERF]` logs on cold start / chat / RTC
- **Used in:** commit `2ae6017` — `docs(security): env gitignore, token server README, and perf budgets`

---

### Prompt #11 — Tests (Phase 11)

- **Tool:** Cursor
- **Intent:** Automated quality gates + 9-step manual QA script for demo video
- **Output:** `TESTING.md`, `scripts/run_tests.sh`, widget tests (guru/trainer), `log_service_test.dart`
- **Used in:** commit (pending) — `test: quality gates and manual QA script` — *AI-assisted via Cursor*

---

## Debugging with AI

### Prompt #12 — Cross-app chat not syncing

- **Tool:** Cursor
- **Intent:** Guru message not visible on Trainer emulator
- **Output:** Confirmed `token_server` must run; sync base URL `10.0.2.2:3000` on Android; documented in README + `humanizeError()` for connection refused
- **Used in:** `SyncConfig`, `TESTING.md` manual step 3; commit `90bdc52` / Phase 9 `AppSnackbar`

---

### Prompt #13 — 100ms / room configuration

- **Tool:** Cursor
- **Intent:** User pasted dashboard room id; avoid committing secrets in `.env.example`
- **Output:** Gitignored `hms_secrets.dart` + `hms_secrets.example.dart`; real room only in local `.env` / `hms_secrets.dart`
- **Used in:** `.gitignore`, `SECURITY.md`; commits `07942a1`, `2ae6017`

---

### Prompt #14 — Widget tests `MissingPluginException`

- **Tool:** Cursor
- **Intent:** `flutter test` failed on `path_provider` / Hive in guru_app
- **Output:** `test/test_bootstrap.dart` with fake `PathProviderPlatform` before `AppServices.init()`
- **Used in:** `guru_app/test/`, `trainer_app/test/` — Phase 11 (uncommitted)

---

### Prompt #15 — HMS in-call errors

- **Tool:** Cursor
- **Intent:** Surface 100ms failures with actionable copy + copy payload for reviewers
- **Output:** `AppSnackbar.showError` in `MeetingScreen.onHMSError`; pre-join retry + copy on token failure
- **Used in:** commit `0a67578` — `meeting_screen.dart`, `prejoin_screen.dart`

---

## Refactor with AI

### Prompt #16 — `LocalLogService` → `SyncLogService`

- **Tool:** Cursor
- **Intent:** Session logs visible on both apps after calls
- **Output:** Merge/push pattern matching chat/calls; `GET/POST /sync/sessions`; poll hook in `AppServices`
- **Used in:** commit `07942a1` — `log_service.dart`, `chat_sync_client.dart`

---

### Prompt #17 — Room id out of tracked `.env.example`

- **Tool:** Cursor
- **Intent:** Prevent accidental push of real `HMS_ROOM_ID` via example file
- **Output:** Placeholder-only `.env.example`; `kDefaultHmsRoomId` in gitignored `hms_secrets.dart`; export via `call_service.dart`
- **Used in:** commit `07942a1` — `shared/lib/config/hms_secrets.example.dart`

---

### Prompt #18 — Phase 12 ledger completion

- **Tool:** Cursor
- **Intent:** Meet assessment AI documentation requirements (≥10 entries, sections, commit map)
- **Output:** This file — structured Coding / Debugging / Refactor + commit SHAs
- **Used in:** Phase 12 submission checklist

---

## Commit index (AI-assisted)

| SHA | Message | AI note |
|-----|---------|---------|
| `90bdc52` | feat: WTF assessment monorepo… | Scaffold, auth, chat sync — **Cursor** |
| `d4c4a0a` | feat(schedule): call request… | Scheduler — **Cursor** |
| `cad004a` | feat(rtc): 100ms pre-join… | Video RTC — **Cursor** |
| `07942a1` | feat(sessions): logs list… | Sessions + secrets layout — **Cursor** |
| `0d175b2` | feat(ui): polish spacing… | UI polish — **Cursor** |
| `0a67578` | feat(dx): dev panel… | DX / errors — **Cursor** |
| `2ae6017` | docs(security): env gitignore… | Security + perf — **Cursor** |

> For new commits, include in body: `AI-assisted: Cursor (see AI_LEDGER.md)`.

---

## How reviewers can verify

1. Open **DevPanel (⋮)** on Guru or Trainer home — tagged logs `[CHAT]`, `[RTC]`, `[SCHEDULE]`, `[AUTH]`, `[PERF]`.
2. Run `./scripts/run_tests.sh` — 16+ unit/widget tests.
3. Follow **9-step script** in [TESTING.md](TESTING.md) for manual/demo validation.
