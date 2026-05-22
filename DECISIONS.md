# Architecture Decision Records

## ADR #1 — State management: **Riverpod**

**Context:** Two apps share business logic via `shared`; UI needs testable, scoped state.

**Decision:** `flutter_riverpod` with `ProviderScope` at app root. Feature providers will wrap `AppServices` (Phase 4+).

**Alternatives considered:** Bloc (more boilerplate for 6h), Provider (less ergonomic for async streams).

---

## ADR #2 — Storage: **Hive + in-memory streams**

**Context:** Assessment requires local-first, no cloud backend, real-time feel.

**Decision:** `hive_flutter` per app (`guru_wtf_box`, `trainer_wtf_box`) + `LocalStore` broadcast streams. Cross-app sync via `token_server` `/sync/*` endpoints (Phase 4).

**Alternatives considered:** SQLite/drift (heavier setup), Firebase (allowed but skipped for speed).

---

## ADR #3 — RTC strategy: **100ms SDK + local token server**

**Context:** 100ms is mandatory; tokens must not ship in the client.

**Decision:**

1. On call **approve**, persist `RoomMeta` with `hmsRoomId` (from env default room or Management API later).
2. **Pre-join:** `GET http://10.0.2.2:3000/token?userId=&role=&roomId=`
3. Join with `hmssdk_flutter` + `permission_handler`

**Fallback:** If `.env` missing, token endpoint returns 503 with setup hint; document in README.

---

## ADR #4 — Cross-app data sync

**Context:** Two separate apps cannot share Hive boxes on Android without shared UID.

**Decision:** `token_server` in-memory sync store + periodic pull/push from `LocalChatService` (implement in Phase 4).
