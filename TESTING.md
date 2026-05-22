# Testing — Phase 11

## Automated tests (required)

From repo root `wtf_flutter_test/`:

```bash
# Shared — models, validators, scheduler, session duration, perf
cd shared && flutter pub get && flutter test

# App widget smoke tests
cd ../guru_app && flutter pub get && flutter test
cd ../trainer_app && flutter pub get && flutter test
```

### Minimum coverage checklist

| Requirement | Test file |
|-------------|-----------|
| Message serialization | `shared/test/message_test.dart` |
| Scheduler — no past time / conflict | `shared/test/call_service_test.dart`, `validators_test.dart` |
| Log duration calculation | `shared/test/log_service_test.dart`, `session_log_utils_test.dart` |

### Static analysis

```bash
cd shared && flutter analyze
cd ../guru_app && flutter analyze
cd ../trainer_app && flutter analyze
```

Target: **zero issues** (warnings/info).

### Release build (optional before submit)

```bash
cd guru_app && flutter build apk --debug
cd ../trainer_app && flutter build apk --debug
```

## Manual QA — 9-step reviewer script

Use **two emulators** + `token_server` running (`npm start`).

| # | Steps | Pass |
|---|--------|------|
| 1 | Trainer app → login **Aarav** | ☐ |
| 2 | Guru app → DK onboarding → assign **Aarav** | ☐ |
| 3 | DK sends `Hi Coach 👋` → Trainer sees unread → reply | ☐ |
| 4 | DK schedules **today 6:00 PM**, note `Macros review` | ☐ |
| 5 | Trainer **approves** → system message + Upcoming Call | ☐ |
| 6 | Both **Join** → pre-join preview → connect in room | ☐ |
| 7 | Trainer mute/video/flip → Member sees update | ☐ |
| 8 | End call → DK **5★** + note → Trainer notes | ☐ |
| 9 | **Sessions** list — latest on top with rating + duration | ☐ |

Record this flow in your **3-minute demo video** for submission.

## One-shot script

```bash
./scripts/run_tests.sh
```
