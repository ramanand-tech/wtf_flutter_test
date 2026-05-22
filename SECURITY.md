# Security — WTF Flutter Assessment

## What is safe to commit

| File | Purpose |
|------|---------|
| `.env.example` | Placeholders only — copy to `token_server/.env` locally |
| `shared/lib/config/hms_secrets.example.dart` | Placeholder room id — copy to `hms_secrets.dart` locally |
| `token_server/README.md` | Setup docs, no secrets |

## Never commit

| Path | Reason |
|------|--------|
| `token_server/.env` | 100ms access key + secret + room id |
| `shared/lib/config/hms_secrets.dart` | Real HMS room id for approve/join flow |
| Root `.env` | If used for local overrides |

These paths are listed in `.gitignore`.

## Token server

- JWTs are minted **only** on the Node server using `HMS_APP_SECRET`.
- Flutter apps call `GET /token` — they never embed the app secret.
- Startup logs mask credentials (`mask()` in `index.js`).

## Before push

```bash
git status
# Ensure .env and hms_secrets.dart are NOT staged
git grep -E 'HMS_APP_SECRET=|access_key.*[a-zA-Z0-9]{20}' -- ':!*.example' ':!.env.example'
```

## Local-only sync API

`/sync/*` endpoints hold in-memory dev data with **no auth**. Use only on emulator/LAN during the assessment — not for production.
