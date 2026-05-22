# WTF Flutter Assessment — Guru ↔ Trainer (100ms)

Two Flutter apps (**Guru** = Member DK, **Trainer** = Aarav) sharing a `shared` package, with a local **token_server** for 100ms JWTs and cross-app sync.

| App | Persona | Run directory |
|-----|---------|---------------|
| Guru App | Member DK | `guru_app/` |
| Trainer App | Trainer Aarav | `trainer_app/` |

---

## Prerequisites

- **Flutter 3.x** — `flutter doctor` (Android toolchain recommended)
- **Android SDK** + emulator or physical device (iOS simulator also works for Trainer/Guru)
- **Node.js 18+** — for `token_server`
- **[100ms](https://dashboard.100ms.live) account** — App Access Key, Secret, Room ID, template with roles `member` + `trainer` (for video)

---

## One-time setup

From repo root `wtf_flutter_test/`:

```bash
# 1) Token server secrets (never commit .env)
cd token_server
cp ../.env.example .env
# Edit .env: HMS_APP_ACCESS_KEY, HMS_APP_SECRET, HMS_ROOM_ID
npm install

# 2) Flutter room id for approve/join flow (gitignored)
cd ../shared/lib/config
cp hms_secrets.example.dart hms_secrets.dart
# Set kDefaultHmsRoomId to the same HMS_ROOM_ID as token_server/.env

# 3) Flutter packages
cd ../../..
cd shared && flutter pub get
cd ../guru_app && flutter pub get
cd ../trainer_app && flutter pub get
```

See [SECURITY.md](SECURITY.md) for what must **not** be committed.

---

## Run token server

```bash
cd token_server
npm start
```

- Default: `http://localhost:3000`
- Android emulator apps use `http://10.0.2.2:3000` automatically (`SyncConfig`)
- Health check: `curl http://localhost:3000/health`

Details: [token_server/README.md](token_server/README.md)

---

## Run Guru App

**Terminal 2** (keep token server running):

```bash
cd guru_app
flutter run
```

- First launch: DK onboarding → assign trainer **Aarav**
- Home: Chat, Schedule Call, My Sessions
- DevPanel: floating **⋮** (logs, masked env)

---

## Run Trainer App

**Terminal 3**:

```bash
cd trainer_app
flutter run
```

- Login: **Aarav** (seed trainer)
- Home grid: Chats, Requests, Sessions

---

## Run tests (CI / local)

```bash
./scripts/run_tests.sh
```

16+ automated tests + `flutter analyze` on `shared`, `guru_app`, `trainer_app`.  
Manual end-to-end script: [TESTING.md](TESTING.md).

---

## Demo video

**Link (add before email submission):**  
`https://youtu.be/YOUR_VIDEO_ID` or Google Drive link

Record the **9-step reviewer script** in [TESTING.md](TESTING.md) (~3 minutes): login → chat → schedule → approve → join call → ratings → sessions list.

---

## Submission checklist

Before sending the repo link to WTF, confirm:

| # | Requirement | How to verify |
|---|-------------|---------------|
| 1 | Repo builds both apps | `flutter run` in `guru_app` + `trainer_app` |
| 2 | Token server runs locally + env sample | `npm start` + `.env.example` in repo |
| 3 | 100ms join on **both** apps | Approve call → Join → pre-join → in-call |
| 4 | Chat both ways + read receipts + typing | Two emulators + `token_server` |
| 5 | Scheduler approve/decline + conflict | Trainer Requests + duplicate slot test |
| 6 | Session logs after call | My Sessions / Sessions with rating |
| 7 | `AI_LEDGER.md` ≥ 10 entries | [AI_LEDGER.md](AI_LEDGER.md) |
| 8 | Demo video (9 steps) | Link in section above |
| 9 | No secrets in git | `git status` — no `.env` / `hms_secrets.dart` staged |

Full checklist copy: [SUBMISSION.md](SUBMISSION.md)

### Push to GitHub

```bash
git remote add origin https://github.com/YOUR_USER/wtf-flutter-test.git
git push -u origin main
```

### Email reply (template)

```
Repo: https://github.com/YOUR_USER/wtf-flutter-test
Demo: https://youtu.be/YOUR_VIDEO_ID
Time taken: ~X hours (optional)
Notes: token_server must be running for chat sync and video.
```

---

## Project structure

```
wtf_flutter_test/
├── README.md              ← you are here
├── AI_LEDGER.md           ← Cursor usage log (required)
├── TESTING.md             ← 9-step manual QA
├── SECURITY.md
├── SUBMISSION.md
├── scripts/run_tests.sh
├── token_server/
├── shared/
├── guru_app/
└── trainer_app/
```

---

## Feature status

| Phase | Status |
|-------|--------|
| Auth & home (DK / Aarav) | Done |
| Chat + sync + typing + read receipts | Done — needs `token_server` |
| Scheduler request / approve / decline | Done |
| 100ms video (pre-join, in-call, post-call) | Done — real 100ms creds required |
| Session logs + filters + sync | Done |
| UI polish, DevPanel, perf logs | Done |
| Tests + AI ledger | Done |

---

## Docs

- [ARCHITECTURE.md](ARCHITECTURE.md) — monorepo layout
- [DECISIONS.md](DECISIONS.md) — ADRs (Riverpod, Hive, 100ms)
- [AI_LEDGER.md](AI_LEDGER.md) — AI-assisted development log
- [Assessment brief](https://docs.google.com/document/d/1Qxr40N_neoHbrelAFiGVh1x03FA5EHbP303O5JdNBFc/edit)

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Chat not syncing | Start `token_server`; Android uses `10.0.2.2:3000` |
| Video token error | Fill `token_server/.env`; roles `member` / `trainer` |
| Room id mismatch | Same id in `.env` and `hms_secrets.dart` |
| `flutter test` fails on Hive | See `guru_app/test/test_bootstrap.dart` pattern |

Human-readable errors + **Copy error** in-app via `AppSnackbar`.
