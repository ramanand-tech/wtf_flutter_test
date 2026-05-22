# 100ms Token Server

Local HTTP server for the WTF Flutter assessment. **Do not deploy as-is** — dev sync has no authentication.

## Security

1. Copy env from the repo root (placeholders only):

   ```bash
   cp ../.env.example .env
   ```

2. Edit `token_server/.env` with [100ms Dashboard](https://dashboard.100ms.live) → Developer → App Credentials.

3. **Never commit** `.env` — it is gitignored. See [SECURITY.md](../SECURITY.md).

4. Server logs mask keys at startup (`abcd…wxyz`).

## Setup & run

```bash
cd token_server
cp ../.env.example .env
# Edit .env: HMS_APP_ACCESS_KEY, HMS_APP_SECRET, HMS_ROOM_ID
npm install
npm start
```

Default port: **3000** (`TOKEN_SERVER_PORT` in `.env`).

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Server status + masked config |
| GET | `/token?userId=&role=&roomId=` | 100ms auth JWT (roles: `member`, `trainer`) |
| GET/POST | `/sync/messages` | Cross-app chat sync (dev) |
| GET/POST | `/sync/calls` | Call request sync (dev) |
| GET/POST | `/sync/sessions` | Session log sync (dev) |
| POST | `/sync/typing` | Typing indicator broadcast (dev) |

## Emulator / device URLs

| Target | Base URL |
|--------|----------|
| Android emulator → host | `http://10.0.2.2:3000` |
| iOS simulator | `http://127.0.0.1:3000` |
| Physical device | Your machine LAN IP, e.g. `http://192.168.1.10:3000` |

Flutter reads the Android URL from `SyncConfig.defaultBaseUrl` in `shared`.

## 100ms template

- Roles **`member`** and **`trainer`** (lowercase) must exist on your template.
- Use one room id in `HMS_ROOM_ID` for local dev.
- Copy the same room id to `shared/lib/config/hms_secrets.dart` (from `hms_secrets.example.dart`).

## Test

```bash
curl -s "http://localhost:3000/health" | jq .
curl -s "http://localhost:3000/token?userId=member_dk&role=member&roomId=YOUR_ROOM_ID" | jq .
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `401` / token error | Check access key + secret in `.env` |
| Flutter cannot connect | Emulator uses `10.0.2.2`, not `localhost` |
| Wrong role | Template must expose `member` and `trainer` |
