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
├── game/                    # Godot 4 project
│   ├── assets/              # Sprites, UI elements, audio, palettes
│   ├── autoload/            # Global singletons (GameManager, SaveManager, etc.)
│   ├── data/                # JSON data for dialogue, quests, chapters, journal
│   ├── scenes/              # Game scenes (main, player, npcs, environments, ui)
│   ├── scripts/             # Modular GDScript code
│   └── project.godot        # Godot project definition
├── docs/                    # Design, Story, Architecture, Historical documentation
│   ├── game-design-document.md
│   ├── story.md
│   ├── architecture.md
│   └── historical-references.md
├── backend/                 # Prepared for future Node/Express API
├── admin/                   # Prepared for future React dashboard
└── README.md
```

---

## How to Run & Test
### Running with Godot 4.3:
```bash
# Open in Godot 4 Editor
godot --path game/

# Run the game directly
godot --path game/ scenes/main/SplashScreen.tscn
```

### Headless Verification / Tests:
```bash
godot --headless --path game/ -s tests/RunTests.gd
```
