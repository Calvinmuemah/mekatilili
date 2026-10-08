# Mekatilili wa Menza — Game Design Document (GDD)

## 1. High Concept & Vision
- **Title:** Mekatilili wa Menza: A Kenyan Historical Adventure
- **Genre:** 2D Narrative Exploration & Historical Adventure
- **Platform:** Android (Primary, Touch-first) / Desktop (Cross-platform testing)
- **Engine:** Godot 4.3 (GDScript, typed)
- **Core Philosophy:** Story > Culture > Exploration > Gameplay Complexity.

---

## 2. Core Gameplay Loops

### Exploration & Narrative Loop
```
[Explore Village / Environment]
           │
           ▼
[Interact with NPC / Environmental Object]
           │
           ▼
[Branching Dialogue / Cultural Discovery]
           │
           ▼
[Quest Objective Updated / Story State Changed]
           │
           ▼
[Journal Entry Unlocked / Historical Note Recorded]
           │
           ▼
[Story Event / Cinematic Trigger]
```

### Player Abilities
1. **Movement:** 8-directional smooth movement with walking animation states.
2. **Context-Sensitive Interaction:** Proximity detection with visual indicator and single-button/touch trigger (`Talk`, `Inspect`, `Gather`).
3. **Journal & Map Access:** In-game pause/HUD overlay containing Story logs, Active/Completed Quests, Historical background, and Collectibles inventory.

---

## 3. Visual & Aesthetic Guidelines
- **Color Palette:**
  - Deep Earth (`#3B2416`)
  - Terracotta (`#B85C38`)
  - Warm Gold (`#D9A441`)
  - Forest Green (`#315C3A`)
  - Sand (`#E8D3A8`)
  - Ivory (`#F7F0DE`)
  - Charcoal (`#211C18`)
- **Art Direction:** Stylized, warm earth tones, coastal Kenyan vegetation (coconut palms, baobab trees, tropical shrubbery, traditional makuti/thatched mud huts).
- **HUD & UI:** Minimal, non-intrusive, rounded corners, warm sand/deep earth panels, gold accents, comfortable touch hitboxes (min 48x48dp on mobile).

---

## 4. Systems Breakdown

### Dialogue System
- Data-driven (JSON files in `res://data/dialogue/`).
- Features: Typewriter effect, character portraits, emotional states, player response choices, signal emission on events, audio typing ticks.

### Quest System
- Data-driven (JSON files in `res://data/quests/`).
- States: `LOCKED`, `AVAILABLE`, `ACTIVE`, `COMPLETED`, `FAILED`.
- Multi-step objectives with automatic HUD objective updating and banner notifications.

### Save & Progression System
- Local JSON persistence in `user://save_game.json`.
- Versioned data schema (`version: 1`).
- Persists: current chapter, scene ID, player position, quest state, story flags, inventory/collectibles, journal unlocks, audio/gameplay settings.

### Audio Architecture
- Autoload `AudioManager` with smooth volume faders, bus management (Master, Music, SFX, Voice), procedural synthesis / fallback audio streams so missing sound files never crash the game.

### Input & Mobile Support
- Godot `InputMap` abstractions (`move_left`, `move_right`, `move_up`, `move_down`, `interact`, `journal`, `pause`).
- Reusable on-screen touch controls: Virtual Joystick (left) + Action Button (right) configured for mobile / touch devices.
