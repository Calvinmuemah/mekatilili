# Mekatilili wa Menza — REST API Documentation (v1)

Base URL: `https://mekatilili.vercel.app/api/v1` (or `http://localhost:5000/api/v1` for local development)

---

## 1. System Health
### `GET /health`
Returns system status.
```json
{
  "success": true,
  "data": {
    "status": "ok",
    "service": "mekatilili-backend",
    "timestamp": "2026-10-08T10:00:00.000Z"
  }
}
```

---

## 2. Player Authentication
### `POST /auth/register`
Body:
```json
{
  "email": "player@example.com",
  "username": "warrior1913",
  "password": "Password123!",
  "displayName": "Mekatilili Fan"
}
```
Response `201 Created`:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "player@example.com",
      "username": "warrior1913",
      "display_name": "Mekatilili Fan"
    },
    "token": "jwt_token_here"
  }
}
```

### `POST /auth/login`
Body:
```json
{
  "emailOrUsername": "warrior1913",
  "password": "Password123!"
}
```

### `GET /auth/me`
Headers: `Authorization: Bearer <player_token>`

---

## 3. Admin Authentication & RBAC
### `POST /admin/auth/login`
Body:
```json
{
  "email": "admin@mekatilili.org",
  "password": "AdminPass123!"
}
```
Response:
```json
{
  "success": true,
  "data": {
    "admin": {
      "id": "uuid",
      "email": "admin@mekatilili.org",
      "name": "Lead Administrator",
      "role": "SUPER_ADMIN"
    },
    "token": "admin_jwt_token"
  }
}
```

---

## 4. Public Content Endpoints (Game Client & Players)
### `GET /content/bundle`
Returns all published chapters, quests, objectives, NPCs, dialogues, collectibles, journal, and historical references in a single payload for client synchronization.

### `GET /content/chapters`
Returns array of published chapters.

### `GET /content/quests`
Returns array of published quests and active objectives.

### `GET /content/npcs`
Returns active village NPCs.

### `GET /content/dialogues/:id`
Returns dialogue tree with branches and choices.

---

## 5. Admin Content Management Endpoints (Protected)
Headers: `Authorization: Bearer <admin_token>`

- `GET /admin/content/chapters`
- `POST /admin/content/chapters`
- `PUT /admin/content/chapters/:id`
- `PATCH /admin/content/chapters/:id/status`
- `DELETE /admin/content/chapters/:id`
- `GET /admin/content/quests`
- `POST /admin/content/quests`
- `PUT /admin/content/quests/:id`
- `DELETE /admin/content/quests/:id`
- `GET /admin/content/npcs`
- `POST /admin/content/npcs`
- `PUT /admin/content/npcs/:id`
- `DELETE /admin/content/npcs/:id`
- `GET /admin/content/dialogues`
- `POST /admin/content/dialogues`
- `PUT /admin/content/dialogues/:id`
- `DELETE /admin/content/dialogues/:id`
- `GET /admin/content/collectibles`
- `POST /admin/content/collectibles`
- `PUT /admin/content/collectibles/:id`
- `DELETE /admin/content/collectibles/:id`
- `GET /admin/content/journal`
- `POST /admin/content/journal`
- `GET /admin/content/history`
- `POST /admin/content/history`
- `GET /admin/content/players`

---

## 6. Player Progress & Local-First Cloud Save
Headers: `Authorization: Bearer <player_token>`

### `GET /player/progress`
Retrieves saved progress, completed quests, collectibles, and story flags.

### `POST /player/sync`
Synchronizes client state with server.
Body:
```json
{
  "chapter": 1,
  "scene": "res://scenes/environments/VillageLevel.tscn",
  "progressPercentage": 100,
  "communityUnity": 100,
  "playerPosition": { "x": 730, "y": 530 },
  "collectibles": ["calabash_palm", "kaya_herbs", "colonial_notice"],
  "storyFlags": {
    "nyevu_reassured": true,
    "fondo_agreed": true,
    "wanje_allied": true
  }
}
```

---

## 7. Analytics
### `POST /analytics/event`
Body:
```json
{
  "eventType": "CHAPTER_COMPLETED",
  "chapterId": "chapter_1",
  "metadata": {
    "playtime_seconds": 320,
    "collectibles_found": 3
  }
}
```

### `GET /analytics/dashboard`
Headers: `Authorization: Bearer <admin_token>`
Returns summary statistics: total players, published content metrics, and event distribution.
