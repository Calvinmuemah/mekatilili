# Mekatilili wa Menza — Technical Architecture & Code Standards

## 1. System Overview
The project is built with **Godot Engine 4.3** using typed **GDScript**. It follows a modular, decoupled architecture driven by Godot signals and event buses.

```
                          ┌───────────────────────────┐
                          │       SceneManager        │
                          └─────────────┬─────────────┘
                                        │
           ┌────────────────────────────┼───────────────────────────┐
           ▼                            ▼                           ▼
┌─────────────────────┐      ┌─────────────────────┐     ┌─────────────────────┐
│     GameManager     │      │     SaveManager     │     │    AudioManager     │
│  - Game State       │      │  - JSON persistence │     │  - Sound busses     │
│  - Chapter Loop     │      │  - Versioned schema │     │  - Crossfades       │
└──────────┬──────────┘      └─────────────────────┘     └─────────────────────┘
           │
           ├────────────────────────────┐
           ▼                            ▼
┌─────────────────────┐      ┌─────────────────────┐
│    DialogueManager  │      │    QuestManager     │
│  - JSON parsing     │      │  - Objective states │
│  - Choices & Events │      │  - Tracking & HUD   │
└──────────┬──────────┘      └──────────┬──────────┘
           │                            │
           └──────────────┬─────────────┘
                          ▼
               ┌─────────────────────┐
               │    StoryManager     │
               │  - Global flags     │
               │  - Journal logs     │
               └─────────────────────┘
```

---

## 2. Autoload Services (Singletons)

All autoloads reside under `res://autoload/`:

| Singleton | Script Path | Responsibility |
|---|---|---|
| `GameManager` | `res://autoload/GameManager.gd` | Global game state, pause handling, new game/continue coordination |
| `SaveManager` | `res://autoload/SaveManager.gd` | Versioned file serialization to `user://save_game.json` |
| `SceneManager` | `res://autoload/SceneManager.gd` | Smooth screen fades and scene transitions |
| `AudioManager` | `res://autoload/AudioManager.gd` | Audio playback, bus volume controls, sound effects |
| `DialogueManager`| `res://autoload/DialogueManager.gd`| Dialogue orchestration, typing effects, player choices |
| `QuestManager` | `res://autoload/QuestManager.gd` | Quest tracking, objectives, completion events |
| `StoryManager` | `res://autoload/StoryManager.gd` | Story flags, Journal entries, Collectibles inventory |

---

## 3. Directory Structure

```
game/
├── project.godot
├── assets/
│   ├── characters/       # Mekatilili, Elders, Villagers, Colonial figures
│   ├── environments/     # Village huts, Baobab trees, Palms, Shamba crops
│   ├── ui/               # UI textures, 9-patches, frames, joystick assets
│   ├── icons/            # HUD icons, quest markers, collectibles
│   ├── audio/            # Music, SFX, voice clips
│   └── fonts/            # Display & body typography
├── autoload/             # Global Singletons
├── data/
│   ├── chapters/         # Chapter definitions (JSON)
│   ├── dialogue/         # Dialogue trees (JSON)
│   ├── quests/           # Quest & objective data (JSON)
│   ├── npcs/             # NPC metadata (JSON)
│   └── collectibles/     # Artifact & lore entries (JSON)
├── scenes/
│   ├── cinematics/       # IntroCinematic, ChapterCutscenes
│   ├── environments/     # Playable village, Kaya, hinterland levels
│   ├── main/             # SplashScreen, MainMenu
│   ├── npcs/             # Reusable NPC scene
│   ├── player/           # Reusable Player scene
│   └── ui/               # HUD, DialogueBox, Journal, PauseMenu, Settings, TouchControls
├── scripts/
│   ├── core/             # Base classes (Interactable, TriggerArea)
│   ├── player/           # PlayerController, InteractionDetector
│   ├── npc/              # NPCController
│   └── ui/               # Screen scripts
└── tests/                # Test runners and headless verification
```

---

## 4. Coding Conventions
- **Strong Typing:** Annotate function parameters, return types, and class variables (e.g., `var health: int = 100`, `func start_quest(quest_id: String) -> bool:`).
- **Class Names:** Use PascalCase for custom classes (`class_name Interactable extends Area2D`).
- **Signal Decoupling:** Components emit signals rather than calling tight parent methods.
- **Fail-Safe & Defensive:** Always check `FileAccess.file_exists()` before opening, provide fallback strings/textures if missing, and print descriptive warnings without crashing.

---

## 5. Backend Architecture (Node.js + Express + PostgreSQL)

The backend provides content management, cloud save syncing, and telemetry without compromising offline playability.

### Layered Flow
```
Incoming HTTP Request
   │
   ▼
Routes (/api/v1/...) ──► Middleware (JWT, Roles, Validation)
   │
   ▼
Controllers (Extract and shape request data)
   │
   ▼
Services (Business logic, hashing, rule enforcement)
   │
   ▼
Repositories (Direct parameterized SQL queries via 'pg')
   │
   ▼
PostgreSQL Database
```

### Key Principles
- **No ORM:** All SQL is written as parameterized queries through `pg` for performance, predictability, and complete query control.
- **Offline-First Contract:** The Godot client never blocks or depends on the backend for local gameplay. The backend is an optional enhancement for content updates, telemetry, and cross-device sync.
- **Role-Based Access Control:** Dual auth systems separate players (`users` table) from system operators (`admins` table with `SUPER_ADMIN`, `CONTENT_EDITOR`, `ANALYST` roles).

---

## 6. Admin Frontend Architecture (React + TypeScript + Vite)

The admin dashboard provides a content management workspace for writers, historians, and designers.

### Tech Stack
- React 18 + TypeScript + Vite
- TanStack Query (React Query) for server state caching and optimistic updates
- React Router DOM v6 for authenticated page routing
- Lucide React for consistent icons
- Historical color system reflecting coastal Kenyan palette:
  - Deep Earth (`#3B2416`)
  - Terracotta (`#B85C38`)
  - Warm Gold (`#D9A441`)
  - Forest Green (`#315C3A`)
  - Sand (`#E8D3A8`)
  - Ivory (`#F7F0DE`)
  - Charcoal (`#211C18`)

### Key Admin Modules
1. **Dashboard:** High-level metrics, active players, and recent telemetry events.
2. **Chapters:** Chapter lifecycle management (`DRAFT`, `PUBLISHED`, `ARCHIVED`).
3. **Quests & Objectives:** Narrative quests, objective types (`TALK_TO_NPC`, `COLLECT_ITEM`, etc.).
4. **NPC Cast:** Elders, villagers, advisors, and historical personas.
5. **Interactive Dialogue Editor:** Node-tree graph editor with live in-game dialogue simulator.
6. **Cultural Collectibles:** Sacred artifacts, regalia, and Giriama cultural context.
7. **Lore Codex / Journal:** Story codex, historical biographies, and oral traditions.
8. **Historical Citations:** Archival sources and academic reference verification.
9. **Player Progress:** User accounts, community unity scores, and chapter progress.
10. **Telemetry & Analytics:** Real-time event ingestion stream and frequency analytics.

