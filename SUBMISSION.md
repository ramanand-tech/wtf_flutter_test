# Submission — WTF Flutter Engineer Assessment

Use this page when sending the project to reviewers.

## Pre-flight (5 min)

```bash
cd wtf_flutter_test
./scripts/run_tests.sh          # all tests + analyze
cd token_server && npm start   # leave running
# flutter run guru_app + trainer_app on two emulators
```

- [ ] `./scripts/run_tests.sh` exits 0
- [ ] `token_server` health: `curl http://localhost:3000/health`
- [ ] No secrets staged: `git status` (no `.env`, no `hms_secrets.dart`)

## Feature checklist (Section 13)

- [ ] **Guru app** builds and runs (`guru_app`)
- [ ] **Trainer app** builds and runs (`trainer_app`)
- [ ] **Token server** runs from `.env.example` copy + [token_server/README.md](token_server/README.md)
- [ ] **100ms** join works on Guru and Trainer (after approve)
- [ ] **Chat** both ways, read receipts, typing indicator
- [ ] **Scheduler** approve, decline, slot conflict message
- [ ] **Session logs** after call with rating + notes on both apps
- [ ] **AI_LEDGER.md** — ≥ 10 entries ([AI_LEDGER.md](AI_LEDGER.md))
- [ ] **Demo video** (~3 min) — 9 steps in [TESTING.md](TESTING.md)

## Demo video script (9 steps)

| Step | Action |
|------|--------|
| 1 | Trainer app → login **Aarav** |
| 2 | Guru app → DK onboarding → assign **Aarav** |
| 3 | DK sends `Hi Coach 👋` → Trainer unread → reply |
| 4 | DK schedules today **6:00 PM**, note `Macros review` |
| 5 | Trainer **approves** → system message + upcoming call |
| 6 | Both **Join** → pre-join preview → connected room |
| 7 | Trainer mute/camera → Member sees update |
| 8 | End call → DK **5★** + note → Trainer notes |
| 9 | **Sessions** list — latest on top with duration + rating |

## GitHub

```bash
git remote add origin <your-repo-url>
git push -u origin main
```

Ensure repository is **public** or shared with reviewers per WTF instructions.

## Email template

```
Subject: WTF Flutter Assessment — [Your Name]

Hi,

Please find my submission:

Repository: https://github.com/<user>/<repo>
Demo video: https://youtu.be/<id>  (or Google Drive)

Setup: See README.md — token_server + two Flutter apps.
AI usage: AI_LEDGER.md (Cursor-assisted implementation).

Optional: Time taken ~__ hours.

Thanks,
[Name]
```

## README link for reviewers

Point reviewers to:

1. [README.md](README.md) — run instructions
2. [TESTING.md](TESTING.md) — manual QA
3. [AI_LEDGER.md](AI_LEDGER.md) — AI transparency
