# 100ms Token Server

Local HTTP server for WTF Flutter assessment.

## Setup

```bash
cd token_server
cp ../.env.example .env
# Edit .env with 100ms Dashboard → Developer → App Credentials
npm install
npm start
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Server status |
| GET | `/token?userId=&role=&roomId=` | 100ms auth JWT |
| GET/POST | `/sync/messages` | Cross-app chat sync (dev) |
| GET/POST | `/sync/calls` | Cross-app call requests sync (dev) |

## Emulator URL

- Android emulator → host machine: `http://10.0.2.2:3000`
- iOS simulator: `http://localhost:3000`
- Physical device: use your machine LAN IP, e.g. `http://192.168.1.x:3000`

## Test

```bash
curl "http://localhost:3000/health"
curl "http://localhost:3000/token?userId=dk&role=member&roomId=YOUR_ROOM_ID"
```
