# AI Ledger

> Maintain during the assessment. Minimum 10 meaningful entries before submission.

---

### Prompt #1

- **Tool:** Cursor (Claude)
- **Intent:** Scaffold monorepo per WTF assessment doc — `shared`, `guru_app`, `trainer_app`, `token_server`, models, ADRs
- **Output:** Full folder structure, Hive services, seed DK/Aarav, Riverpod apps, Node token endpoint
- **Used in:** Initial scaffold commit — `wtf_flutter_test/`

---

### Prompt #2

- **Tool:** Cursor
- **Intent:** Step-by-step implementation guide from Google Doc export
- **Output:** `IMPLEMENTATION_STEPS.md` (parent folder)
- **Used in:** Planning only

---

### Prompt #3

- **Tool:** Cursor
- **Intent:** Phase 4 chat — SyncChatService, token_server sync, bubbles, typing, read receipts
- **Output:** `SyncChatService`, `ChatListScreen`, `ConversationScreen`, `/sync/typing`
- **Used in:** `feat(chat): list, conversation, typing, read receipts`

### Prompt #4

- **Tool:** Cursor
- **Intent:** Cross-app message merge + poll every 800ms via `http://10.0.2.2:3000`
- **Output:** `ChatSyncClient`, Android cleartext + INTERNET
- **Used in:** guru_app + trainer_app chat flow

### Prompt #5

- **Tool:** Cursor
- **Intent:** Phase 5 schedule — 3-day calendar, 30-min slots, SyncCallService, trainer approve/decline
- **Output:** `schedule_call_screen`, `trainer_requests_screen`, `my_requests_screen`, call sync on token_server
- **Used in:** `feat(schedule): request, approve, decline with conflict check`

### Prompt #6

- **Tool:** Cursor
- **Intent:** Phase 6 — hmssdk pre-join preview, meeting UI, token fetch, post-call sheets
- **Output:** `PreJoinScreen`, `MeetingScreen`, `JoinCallFlow`, Android/iOS AV permissions
- **Used in:** `feat(rtc): 100ms join/prejoin/in-call`

<!-- Add entries as you build: debugging, refactors, etc. -->
