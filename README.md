# Mekatilili wa Menza — A Kenyan Historical Adventure

A professionally crafted, historically inspired 2D story-driven adventure game about **Mekatilili wa Menza**, the legendary Giriama resistance leader who led the 1913–1914 anti-colonial struggle in coastal Kenya.

Built with **Godot 4.3 (GDScript)** with an Android-first design and desktop cross-compatibility.

---

## Game Overview
- **Protagonist:** Mekatilili wa Menza (Mnyazi wa Menza)
- **Setting:** 1913 Coastal Kenya (Giriama hinterland, Ulungu village, Kaya Fungo)
- **Genre:** 2D Narrative Exploration & Historical Adventure
- **Core Design Principle:** **STORY > CULTURE > EXPLORATION > GAMEPLAY COMPLEXITY**

---

## Key Features in Vertical Slice MVP
1. **Prologue & Splash Screen:** Warm Kenyan atmosphere, historical branding.
2. **Cinematic Main Menu:** Animated background, New Game, Continue (disabled if no save), Settings, and About screens.
3. **Historical Intro Cinematic:** Establishing the Giriama culture, colonial taxation crisis, and Mekatilili's identity.
4. **Playable Coastal Giriama Village:**
   - Traditional thatched homes (*nyumba za vidzo*), baobab trees, coconut palms, and crop fields.
   - Smooth 8-directional character movement and camera tracking.
5. **NPC & Dialogue System:**
   - Interactive village characters (Villager Nyevu, Warrior Charo, Elder Mzee Fondo, Advisor Wanje).
   - Rich typewriter dialogue, portraits, player choices, and story triggers.
6. **Data-Driven Quests & Objectives:**
   - Active quest tracking, on-screen dynamic objective HUD, completion banners.
   - Multi-stage Chapter 1 narrative arc: from gathering village support to defying colonial decrees.
7. **Interactive Objects & Collectibles:**
   - Cultural artifacts (Traditional Gourds, Kaya Herb Pouches, Colonial Decrees).
   - Dynamic Journal with Story, Quests, Historical Notes, and Collectibles.
8. **Save & Progression System:**
   - Versioned JSON persistence (`user://save_game.json`).
   - Seamless Save/Load across sessions.
9. **Touch & Mobile Controls:**
   - Virtual on-screen joystick and context action buttons optimized for Android phones.
   - Responsive landscape layout with safe zones.
10. **Settings & Pause Menus:**
    - Master, Music, SFX volume controls.
    - Text speed, UI scaling, and progress reset confirmation.

---

## Controls
| Action | Keyboard / Desktop | Android / Mobile |
|---|---|---|
| Move | `W, A, S, D` or Arrow Keys | Left Virtual Joystick |
| Interact / Advance | `E` or `Space` or `Enter` | On-Screen [INTERACT] Button |
| Journal | `J` or `Tab` | On-Screen [JOURNAL] Icon |
| Pause / Menu | `Escape` | On-Screen [PAUSE] Icon |

---

## Project Structure
```
mekatilili-game/
├── game/                    # Godot 4 project (100% offline-playable)
│   ├── assets/              # Sprites, UI elements, audio, palettes
│   ├── autoload/            # Global singletons (GameManager, SaveManager, etc.)
│   ├── data/                # JSON data for dialogue, quests, chapters, journal
│   ├── scenes/              # Game scenes (main, player, npcs, environments, ui)
│   ├── scripts/             # Modular GDScript code
│   └── project.godot        # Godot project definition
├── backend/                 # Node.js + Express + PostgreSQL API
│   ├── src/                 # Controllers, Services, Repositories (pg parameterized SQL)
│   ├── database/            # 13 SQL migrations + seeds
│   └── tests/               # Jest test suite (16 tests)
├── admin/                   # React + TypeScript + Vite CMS Dashboard
│   ├── src/                 # Chapters, Quests, NPCs, Dialogue Editor, Collectibles, Analytics
│   └── dist/                # Production build
├── docs/                    # Game Design, Story, Architecture, API documentation
└── docker-compose.yml       # PostgreSQL database & optional services container
```

---

## How to Run & Test

### 1. Godot 4.3 Client (Playable Offline Game)
The game runs 100% offline with zero cloud dependency.
```bash
# Open in Godot 4 Editor
godot --path game/

# Run the game directly
godot --path game/ scenes/main/SplashScreen.tscn

# Run headless test suite (11/11 tests verify offline-first systems, network, auth, sync, and telemetry)
godot --headless --path game/ -s tests/RunTests.gd
```

See [docs/integration.md](file:///home/calvin/Desktop/mekatilili-game-starter/docs/integration.md) for complete details on offline saves, cloud synchronization, and telemetry.

### 2. Backend (Node.js + Express + PostgreSQL)
```bash
cd backend

# Install dependencies
npm install

# Run database migrations
npm run migrate

# Seed initial admin & Chapter 1 content
npm run seed

# Run automated test suite (16 tests)
npm test

# Start API server (port 5000)
npm run dev
```

**Default Admin Credentials:**
- Email: `admin@mekatilili.org`
- Password: `AdminPass123!`

### 3. Admin Dashboard (React + TypeScript + Vite)
```bash
cd admin

# Install dependencies
npm install

# Run development server
npm run dev

# Build production bundle
npm run build
```
The dashboard will run at `http://localhost:5173` and connect to the backend at `http://localhost:5000/api/v1`.

