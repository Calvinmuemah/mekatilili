# Mekatilili wa Menza — Client Delivery & Holiday Handover Guide
**Target Event:** Mashujaa Day (Heroes' Day) Celebration  
**Game Version:** `v1.0.0 (Complete 3-Chapter Production Release)`  
**Platform:** Android (Universal APK) & Desktop Demonstration  
**Status:** 100% Tested & Verified (18/18 Automated Test Suites Passing)

---

## 1. Deliverable Package & File Locations

All production-ready files are located in the repository ready for delivery:

| Deliverable | Location | Size | Description |
| :--- | :--- | :--- | :--- |
| **Android Game APK** | [`builds/android/mekatilili.apk`](file:///home/calvin/Desktop/mekatilili-game-starter/builds/android/mekatilili.apk) | 73.4 MB | Standalone signed Android installable package. |
| **Android Game APK (Mirrored)** | [`builds/android/mekatilili-wa-menza.apk`](file:///home/calvin/Desktop/mekatilili-game-starter/builds/android/mekatilili-wa-menza.apk) | 73.4 MB | Identical signed APK with full title in filename. |
| **Admin Portal Dashboard** | `http://localhost:3000` (or `admin/dist`) | Web | Real-time monitoring of registered players & unity metrics. |
| **Cloud API Backend** | `https://mekatilili.vercel.app/api/v1` | Cloud | Production authentication and progress synchronization. |

---

## 2. How to Send the Game to the Client

You can share the APK (`mekatilili.apk`) using any of the following methods:

### Method A: Direct Messaging (Fastest & Easiest)
- Send `builds/android/mekatilili.apk` directly via **WhatsApp**, **Telegram**, or **Signal**.
- Because the APK is **73.4 MB**, it is well within standard messaging attachment limits (WhatsApp supports up to 2GB).
- The client can tap the file right inside the chat to install.

### Method B: Cloud Storage Link (Google Drive / WeTransfer)
1. Upload `builds/android/mekatilili.apk` to **Google Drive**, **OneDrive**, or **Dropbox**.
2. Set link permissions to *"Anyone with the link can view/download"*.
3. Send the download link to the client with the installation instructions below.

### Method C: Direct USB Installation (For On-Site Setup)
Connect the client's Android phone or tablet to your computer via USB and run:
```bash
adb install -r builds/android/mekatilili.apk
```

---

## 3. Client Installation Instructions (Copy & Paste to Client)

You can copy and send this exact text message to your client:

> **🎮 HOW TO INSTALL MEKATILILI WA MENZA ON YOUR ANDROID PHONE/TABLET:**
>
> 1. **Download the file:** Tap the `mekatilili.apk` file to download it to your device.
> 2. **Install:** Tap on the downloaded file.
> 3. **Allow Installation (if prompted):**  
>    If your phone says *"For your security, your phone is not allowed to install unknown apps from this source"*:
>    - Tap **Settings**
>    - Switch ON **"Allow from this source"** (or tap "Install anyway")
>    - Tap **Back** and tap **Install**
> 4. **Launch:** Tap **Open** to begin the historical journey!
>
> 💡 *Note: The game works 100% OFFLINE. No internet connection is needed to play!*

---

## 4. Key Highlights for Tomorrow's Holiday Showcase

### 1. Offline-First Guarantee
- The entire game experience (Prologue cinematic, Levels 1 through 7, voiceovers, cultural dialogues, historical journal, and auto-saving) works **completely offline**.
- The client can showcase the game in halls, tents, schools, or outdoor grounds without needing Wi-Fi or cellular data.

### 2. Streamlined Controls
- **Movement:** Virtual on-screen joystick on the left thumb.
- **Interaction:** Dynamic glowing action button on the right thumb when near elders, villagers, council fires, or quest points.
- **Text-to-Speech Voiceover:** Automatically narrates Giriama elder dialogues aloud.
- **Top HUD:**
  - 📜 **Journal:** Historical codex of sacred Kaya customs, Giriama resistance oaths, and relics.
  - ⚙️ **Settings:** Voiceover toggles, master volume, and high-contrast settings.
  - ⏸️ **Pause / Save:** Instant manual save option (although auto-save occurs on every quest step!).

### 3. Story Arc Covered (Levels 1 to 11 — Complete 3 Acts)
- **Act I — Chapter 1: Whispers in the Palms (Levels 1–3):**
  - Meet Elder Mzee Fondo, learn the sacred Kaya customs, tend community cassava crops, confront colonial runners, and forge an alliance with Elder **Wanje wa Mwadorikola**.
- **Act II — Chapter 2: The Fire of Kifudu (Levels 4–7):**
  - Rally three village clusters, lead the historic assembly at Kaya Fungo swearing the sacred Mukushe resistance oath, confront British administrator Arthur Champion, trigger the legendary hen-and-chicks release, and sprint past colonial sentries.
- **Act III — Chapter 3: The Long Walk to Freedom (Levels 8–11):**
  - Experience the dramatic arrest cinematic at the coastal ridge, endure exile in Kisii Prison 1,000 km away in western Kenya, seize the warden's keys, execute the daring midnight breakout with Wanje, and trek across the Rift Valley and savannah back to sacred Kaya Fungo to reignite the 1914 Giriama Uprising!

---

## 5. Live Admin Dashboard (For Supervisors & Event Leads)

- Open `http://localhost:3000` in any web browser.
- Displays registered player accounts, community unity scores, chapter progression, and real-time telemetry.
- Includes a live search bar and filter controls by Chapter and Active status.

---

## 6. Pre-Event Checklist Before Handover

- [x] Test suite passing: 18/18 tests PASS (`RunTests.gd`)
- [x] APK exported & verified: `mekatilili.apk` & `mekatilili-wa-menza.apk` (Signed with Android v1, v2, v3)
- [x] Launcher Icon verified: Adaptive foreground & solid Deep Earth background (zero blue corner bleed)
- [x] UI Cards verified: Dynamic auto-stretching banner cards, centered objective boxes, and choice button layout
- [x] Level 11 verified: Water spring replenishment, herb gathering, scout evasion, and Kaya reunion
- [x] "Continue Journey" button tested: Transitions smoothly through all 3 Chapters
- [x] Offline mode verified: 100% offline-authoritative gameplay without requiring internet
- [x] Audio & TTS narration validated: Authentic Giriama ambient loops and elder voiceover
