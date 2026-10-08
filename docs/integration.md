# Mekatilili wa Menza — Integration & Offline-First Sync Architecture

This document describes the integration between the **Godot 4.3 Android game client**, the **Node.js + Express backend**, and the **PostgreSQL database**.

---

## 1. Core Architectural Principle

```
┌────────────────────────────────────────────────────────┐
│             THE OFFLINE-FIRST PRINCIPLE                │
│                                                        │
│  The game client is 100% playable without an internet  │
│  connection, without an account, and without servers.  │
│  The backend is strictly an optional enhancement for: │
│    • Cross-device cloud save synchronization           │
│    • Over-the-air content pack updates                 │
│    • Privacy-focused gameplay telemetry                │
└────────────────────────────────────────────────────────┘
```

---

## 2. System Architecture

```
                          ┌────────────────────────┐
                          │   Godot Game Client    │
                          │   (Android / Desktop)  │
                          └───────────┬────────────┘
                                      │
                         Is Internet Available?
                               /             \
                             NO               YES
                             │                 │
                             ▼                 ▼
                     Save Locally to     ApiClient.gd
                     user://save_game    (Token Bearer Auth)
                     sync_status=PENDING       │
                                               ▼
                                      Express REST API (v1)
                                               │
                                      ┌────────┴────────┐
                                      ▼                 ▼
                                 PostgreSQL        Telemetry
                                 Database          Stream
```

---

## 3. Godot Autoload Services

| Singleton | Script Path | Responsibility |
|---|---|---|
| `ApiClient` | `res://autoload/ApiClient.gd` | Reusable HTTP engine supporting GET, POST, PUT, PATCH, DELETE, base URL config, timeout protection, and bearer auth injection. |
| `NetworkManager` | `res://autoload/NetworkManager.gd` | Connectivity observer (`ONLINE`, `OFFLINE`, `UNKNOWN`), non-intrusive polling, `network_status_changed` signal. |
| `AuthManager` | `res://autoload/AuthManager.gd` | Player identity, optional account login, registration, guest mode, session persistence in `user://auth_session.json`. |
| `SaveManager` | `res://autoload/SaveManager.gd` | Authoritative local save serialization (`user://save_game.json`), version 2 metadata, migration logic, and backup creation (`user://save_game.bak`). |
| `SyncManager` | `res://autoload/SyncManager.gd` | Deterministic cloud save synchronization, conflict resolution ("latest valid save wins"), and local backup preservation. |
| `ContentSyncManager` | `res://autoload/ContentSyncManager.gd` | Content bundle update verification (`/content/bundle`), schema validation, fail-safe fallback to bundled assets if network fails. |
| `TelemetryManager` | `res://autoload/TelemetryManager.gd` | Privacy-preserving gameplay metrics, local queueing (`user://telemetry_queue.json`), and background non-blocking flushing. |

---

## 4. Local-First Save & Cloud Sync Workflow

### Local Save Flow
1. Player reaches checkpoint or completes objective.
2. `SaveManager.save_game()` serializes:
   - `version: 2`
   - `last_modified_at: ISO8601`
   - `sync_status: "PENDING"`
   - `device_id: "dev_..."`
   - `chapter`, `player_position`, `quests`, `story_flags`, `collectibles`, `journal`, `community_support`.
3. Written directly to `user://save_game.json`.
4. Emits `save_written` signal.

### Background Cloud Sync Flow
1. `SyncManager` checks:
   - `NetworkManager.is_online() == true`
   - `AuthManager.is_authenticated() == true`
2. If both conditions are met:
   - Requests remote progress via `GET /api/v1/player/progress`.
   - Compares chapter and timestamp:
     - **If Remote is Further/Newer:** Preserves local save as `user://save_game.bak`, activates cloud progress, and updates `sync_status = "SYNCED"`.
     - **If Local is Newer/Equal:** Sends sync payload to `POST /api/v1/player/sync`, updates `sync_status = "SYNCED"`.
3. If network fails or times out:
   - Updates `sync_status = "FAILED"`.
   - **Local game continues without interruption or error modals.**

---

## 5. Content Synchronization & Safety Guardrails

- Base release content is bundled inside `res://data/` with version `1.0.0` defined in `res://data/content_version.json`.
- When online, `ContentSyncManager.check_for_updates()` checks `GET /api/v1/content/bundle`.
- If a newer version is found:
  1. Validates required schema: chapters, quests, npcs, dialogues, collectibles, journal.
  2. If valid: Creates backup in `user://content_backup/`, writes bundle to `user://content/active_bundle.json`.
  3. If invalid or corrupted: **Rejects downloaded content, keeps existing local content, and continues gameplay.**
  4. If server returns 404, 500, or times out: **Silently logs warning and plays bundled content.**

---

## 6. Telemetry & Privacy Standards

- Events recorded: `GAME_STARTED`, `SESSION_STARTED`, `CHAPTER_STARTED`, `CHAPTER_COMPLETED`, `QUEST_STARTED`, `QUEST_COMPLETED`, `DIALOGUE_VIEWED`, `CHOICE_SELECTED`, `COLLECTIBLE_FOUND`.
- **Privacy Protections:**
  - Zero PII (no user real names, no email addresses, no passwords, no tokens).
  - No location tracking, contacts, or microphone permissions.
- **Offline Queue:**
  - Events are buffered in `user://telemetry_queue.json` (max 200 events).
  - When connection is restored, flushed in non-blocking batches of 5 events.
  - Telemetry errors never block game execution.

---

## 7. Configuring the Backend API Endpoint

By default, the Godot client targets:
```
http://localhost:5000/api/v1
```

To configure custom endpoints (e.g., local LAN IP for physical Android testing or production server):
Create `user://api_config.json` on the device:
```json
{
  "base_url": "http://192.168.1.100:5000/api/v1"
}
```
Or set `ApiClient.set_base_url("https://api.yourdomain.org/api/v1")` programmatically.
