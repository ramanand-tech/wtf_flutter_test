require('dotenv').config();
const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.TOKEN_SERVER_PORT || 3000;
const APP_ACCESS_KEY = process.env.HMS_APP_ACCESS_KEY;
const APP_SECRET = process.env.HMS_APP_SECRET;
const DEFAULT_ROOM_ID = process.env.HMS_ROOM_ID;

/** In-memory sync store for cross-app chat (local dev). */
const syncStore = {
  messages: [],
  callRequests: [],
  sessionLogs: [],
  typing: null,
};

function mask(value) {
  if (!value || value.length < 8) return '[unset]';
  return `${value.slice(0, 4)}…${value.slice(-4)}`;
}

function buildAuthToken({ userId, role, roomId }) {
  if (!APP_ACCESS_KEY || !APP_SECRET || !roomId) {
    return null;
  }
  const payload = {
    access_key: APP_ACCESS_KEY,
    room_id: roomId,
    user_id: userId,
    role,
    type: 'app',
    version: 2,
    iat: Math.floor(Date.now() / 1000),
    nbf: Math.floor(Date.now() / 1000),
  };
  return jwt.sign(payload, APP_SECRET, {
    algorithm: 'HS256',
    expiresIn: '24h',
    jwtid: uuidv4(),
  });
}

app.get('/health', (_req, res) => {
  res.json({ ok: true, creds: APP_ACCESS_KEY ? 'configured' : 'missing' });
});

/**
 * GET /token?userId=&role=&roomId=
 * Returns 100ms auth token for pre-join / join.
 */
app.get('/token', (req, res) => {
  const userId = req.query.userId || 'user_dev';
  const role = req.query.role || 'member';
  const roomId = req.query.roomId || DEFAULT_ROOM_ID;

  console.log(`[RTC] token request userId=${userId} role=${role} room=${mask(roomId)}`);

  if (!roomId) {
    return res.status(400).json({
      error: 'roomId required. Set HMS_ROOM_ID in .env or pass ?roomId=',
    });
  }

  const token = buildAuthToken({ userId, role, roomId });
  if (!token) {
    return res.status(503).json({
      error: '100ms credentials not configured',
      hint: 'Copy .env.example to token_server/.env and add HMS_APP_ACCESS_KEY, HMS_APP_SECRET, HMS_ROOM_ID',
      devMode: true,
    });
  }

  res.json({ token, roomId, role, userId });
});

// --- Cross-app sync (optional, for two apps on same machine) ---
app.get('/sync/messages', (_req, res) => res.json(syncStore.messages));
app.post('/sync/messages', (req, res) => {
  syncStore.messages = req.body.messages || [];
  res.json({ ok: true, count: syncStore.messages.length });
});

app.get('/sync/calls', (_req, res) => res.json(syncStore.callRequests));
app.post('/sync/calls', (req, res) => {
  syncStore.callRequests = req.body.callRequests || [];
  res.json({ ok: true });
});

app.get('/sync/typing', (_req, res) => {
  if (syncStore.typing && syncStore.typing.expiresAt < Date.now()) {
    syncStore.typing = null;
  }
  res.json(syncStore.typing || {});
});

app.post('/sync/typing', (req, res) => {
  const { chatId, userId } = req.body;
  syncStore.typing = {
    chatId: chatId || '',
    userId: userId || '',
    expiresAt: Date.now() + 800,
  };
  res.json({ ok: true });
});

app.get('/sync/sessions', (_req, res) => res.json(syncStore.sessionLogs));
app.post('/sync/sessions', (req, res) => {
  syncStore.sessionLogs = req.body.sessionLogs || [];
  res.json({ ok: true, count: syncStore.sessionLogs.length });
});

app.listen(PORT, () => {
  console.log(`Token server http://localhost:${PORT}`);
  console.log(`HMS key: ${mask(APP_ACCESS_KEY)} room: ${mask(DEFAULT_ROOM_ID)}`);
});
