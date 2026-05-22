# WTF Flutter Assessment — Guru ↔ Trainer (100ms)

Monorepo: **Guru App** (Member DK) + **Trainer App** (Aarav) + **shared** package + **token_server**.

## Prerequisites

- Flutter 3.x (`flutter doctor`)
- Node.js 18+ (token server)
- Android emulator or device
- [100ms](https://dashboard.100ms.live) app credentials (for video — Phase 6)

## Quick start

### 1. Token server

```bash
cd token_server
cp ../.env.example .env
# Fill HMS_APP_ACCESS_KEY, HMS_APP_SECRET, HMS_ROOM_ID
npm install
npm start
```

### 2. Shared package & apps

```bash
cd shared && flutter pub get && flutter test
cd ../guru_app && flutter pub get && flutter run
# Second terminal:
cd trainer_app && flutter pub get && flutter run
```

## Project structure

```
wtf_flutter_test/
├── README.md
├── AI_LEDGER.md
├── ARCHITECTURE.md
├── DECISIONS.md
├── token_server/
├── shared/
├── guru_app/
└── trainer_app/
```

## Scaffold status

| Phase | Status |
|-------|--------|
| Repo scaffold | Done |
| Models + services + Hive | Done |
| Guru onboarding + home | Done |
| Trainer login + home | Done |
| Chat (Phase 4) | Done — needs `token_server` running |
| Scheduler (Phase 5) | Done — request / approve / decline + sync |
| 100ms video (Phase 6) | Done — requires `token_server/.env` with real 100ms creds |
| Session logs (Phase 7) | Done — filters, detail sheet, cross-app sync via `/sync/sessions` |

### Chat + schedule test (two apps)

1. `cd token_server && npm start`
2. Run guru_app + trainer_app on emulators
3. **Chat:** Guru → Chat → `Hi Coach 👋` → Trainer → Chats → reply
4. **Schedule:** Guru → Schedule Call → pick Today + slot + note `Macros review` → Request
5. Trainer → Requests → Approve → Guru → My Requests / Chat system message
6. **Decline test:** new request → Trainer Decline with reason → DK sees declined copy
7. **Video:** After approve, both tap **Join Call** (debug: join window relaxed) → pre-join → in-call → end → rating/notes
8. **Sessions:** Guru → My Sessions / Trainer → Sessions — filter chips, tap row for notes; pull-to-refresh syncs logs

### 100ms setup (required for video)

1. Create app at https://dashboard.100ms.live
2. Copy `token_server/.env` from `.env.example` (real keys + room id — **not committed**)
3. Copy `shared/lib/config/hms_secrets.example.dart` → `hms_secrets.dart` (same room id for Flutter approve flow)
4. Template roles must include `member` and `trainer` (lowercase)
5. `npm start` in `token_server/` before joining calls

Never put real keys or room ids in `.env.example` — that file is pushed to Git.

## Demo video

_Add YouTube/Drive link before submission._

## Assessment doc

https://docs.google.com/document/d/1Qxr40N_neoHbrelAFiGVh1x03FA5EHbP303O5JdNBFc/edit
