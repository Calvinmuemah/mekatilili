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
