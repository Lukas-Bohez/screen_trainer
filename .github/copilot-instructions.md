# ScreenTrainer — GitHub Copilot Master Instructions

> Place this file at `.github/copilot-instructions.md` in the new repo root.
> Copilot will automatically load it as project-level context for every chat and inline suggestion.

---

---

## 0. Product Strategy, Behavioral Design & Market Positioning

### 0.1 Elevator Pitch (two versions)

**One-liner:** "Your screen is behind a curtain. Do 10 push-ups. The curtain opens."

**Investor/pitch version:** "ScreenTrainer is the only habit-enforcement app that turns every
device in your home into a connected exercise sensor. A child doing push-ups in the living
room unlocks the TV. A teen doing squats with their phone in their pocket unlocks the
laptop. The multiplayer household is the moat — zero cloud, zero subscription, zero cheating."

---

### 0.2 Market Research & Competitive Gaps (May 2026)

| App | Platforms | Mechanic | Critical weaknesses |
|---|---|---|---|
| **Pushscroll** | Android, iOS | Push-ups unlock per-app minutes; pose detection | Subscription-only (#1 complaint in reviews); per-app blocking only (easily bypassed); 2 exercises for most of its life; no gacha/themes; no TV/desktop; no companion device; no family profiles |
| **RepUnlock** | iOS only | Reps unlock specific apps | iOS only; subscription-only; bare UI; zero gamification |
| **Workout Quest** | iOS/Android | RPG fitness tracker | No screen enforcement — a gym logger, not a habit enforcer |
| **Zombies, Run!** | iOS/Android | Story-driven running | Running only; no screen-time link |

**What Play Store reviewers of Pushscroll say they want and aren't getting:**
a free tier to try before subscribing; more exercises beyond push-ups; visual customisation;
social/family features; no paywall on core functions. Every one of these is a ScreenTrainer
default.

---

### 0.3 The Defensible Moat — "The Multiplayer Household"

ScreenTrainer's architectural moat is not a feature list — it's a **zero-cloud peer-to-peer
sensor network** that competitors cannot replicate with a UI update:

- A phone strapped to a child's wrist streams 50 Hz IMU data over local Wi-Fi to the TV.
- The TV verifies reps. The child did not touch the TV. No QR code needed after initial pair.
- Three family members each add a phone as a companion → 25× XP bonus kicks in → the
  household is now collectively invested in each other's exercise.
- This network is local-only. No data leaves the house. No server to maintain. No GDPR risk.
- Once a family has paired three devices and built a streak together, the switching cost to
  any competitor is enormous.

**Pitch sentence:** "We turned every phone in your home into a gym sensor. No cloud. No
subscription. No cheating."

---

### 0.4 Behavioral Psychology — The Hook Model

ScreenTrainer is designed around Nir Eyal's Hook Model, extended with long-term intrinsic
motivation bridges:

```
TRIGGER  → system-level curtain appears; phone vibrates; can't be dismissed
ACTION   → physical movement (lowest-friction version: manual tap; highest: pose detection)
REWARD   → Rep Coins + gacha pull reveal; rarity particle burst; curtain lifts dramatically
INVESTMENT → streak built; collection growing; household ranking improving; profile personalised
```

**The extrinsic→intrinsic bridge (why users stay after the novelty wears off):**

- Weeks 1–2: Gacha novelty drives compliance. The curtain is a puzzle the user wants to
  solve. Variable reward (what rarity will I pull?) is powerful at this stage.
- Weeks 3–6: Streaks and badges become identity markers. The user is now a "7-day streak
  person." Breaking it feels like a loss, not just missing a reward.
- Month 2+: Physical results reinforce the loop from outside the app. The app is now a
  habit anchor, not a motivation source. This is the goal. At this stage the curtain can
  feel less like a barrier and more like a ritual.

**The design implication:** UI microcopy must shift tone as streaks grow. Early: "Earn your
screen time!" Late: "Your streak: 42 days. You've done 1,840 push-ups." Let the numbers
speak. The app becomes a mirror.

---

### 0.5 User Personas

Two fundamentally different people interact with ScreenTrainer. Code, copy, and UX flows
must account for both.

#### Persona A — The Configurator (sets up the app, may not use it daily)

- **Who:** A parent, guardian, or self-disciplined adult configuring for someone else
  (or for a future version of themselves).
- **Tech comfort:** Variable — assumes a less tech-savvy parent should be able to complete
  onboarding without a tutorial. Taps "next" on permission screens without reading them.
- **Goal:** Set it and forget it. The app should "just work" and be hard to uninstall/bypass.
- **Fear:** The child disables it the moment the parent leaves the room.
- **Design mandate for Configurator flows:**
  - Onboarding uses plain language. No jargon. Every permission screen explains *why* in
    one sentence: "This lets the curtain appear over all apps, including games."
  - PIN/biometric lock is offered immediately after the first profile is created, before
    the parent leaves the screen.
  - Permissions are requested one at a time with a clear visual progress indicator.
    Never dump all permission dialogs at once — this causes abandonment.
  - A "test the curtain now" button at the end of onboarding builds confidence before
    the parent hands the device to a child.

#### Persona B — The End User (lives inside the curtain daily)

- **Who:** A child (8–14), teen (14–18), or self-improving adult.
- **Tech comfort:** Native. Knows every system bypass. Will try all of them once.
- **Goal (stated):** Get past the curtain as fast as possible.
- **Goal (actual, after week 2):** Beat yesterday's rep count. Pull the next gacha. Maintain
  the streak.
- **Fear:** Being locked out when they're tired, sick, or in an emergency.
- **Design mandate for End User flows:**
  - The exercise UI is the most polished screen in the app. It should feel like a game
    loading screen, not a homework assignment.
  - Rep counter animations are large, satisfying, and immediate.
  - Every completed rep gets haptic + visual feedback. No rep goes unacknowledged.
  - The "I can't exercise right now" path must exist and be reachable — but with friction
    (see §0.6 Sick Day mechanic).

---

### 0.6 Friction Mitigation — The Sick Day & Hardware Failure Protocol

#### The Sick Day Mechanic (anti-churn safety valve)

Rage-uninstalling is the #1 retention killer for enforcement apps. To prevent it:

- **Adult / self-configured profiles:** A "Not today" button is always visible on the
  curtain. Tapping it requires biometric confirmation, then offers: skip this session
  (costs 50 Rep Coins), reduce target reps by 50% (costs 10 Rep Coins), or a free skip
  if the user hasn't skipped in 7 days. Coins already earned are never taken away.
- **Child profiles (parent-controlled):** The Sick Day bypass is configured by the
  Configurator in advance. Options: PIN entry only (parent enters PIN remotely or
  in person); a substitute cognitive task (e.g., 5-minute reading timer); or a
  pre-set emergency bypass window (e.g., "allow skipping on weekends").
- **Streak protection:** A 24-hour "streak freeze" item can be crafted from Fabric Scraps.
  One freeze can be held at a time. This is the only use for scraps outside the gacha shop —
  it ties the collection system to real-world wellbeing.
- **Implementation note:** The Sick Day path must be clearly available but not *obvious*.
  It should require one deliberate extra tap to find, so it isn't accidentally hit.

#### Hardware Failure Graceful Degradation

Physical training environments are variable. Code must never punish the user for hardware
limitations outside their control:

| Failure | Detection | Graceful response |
|---|---|---|
| Poor lighting → ML Kit fails | `PoseDetectionException` or confidence < 0.4 | Auto-switch to `AccelerometerStrategy`; show "Low light detected — using motion sensor" toast |
| Camera permission denied | `CameraException.permissionDenied` | Fall back to `AccelerometerStrategy` silently; prompt permission again only on next app open |
| Camera hardware absent (TV, desktop) | `Platform.isAndroid && !hasCameraFeature` | Skip pose detection entirely; use accelerometer or manual |
| Accelerometer unavailable | `SensorNotFoundException` | Fall back to manual tap mode; show explanation once |
| Manual tap mode | User choice or forced fallback | 0.5× XP, 0 Rep Coins — clearly labelled so the user understands the tradeoff, not punished |
| Companion disconnects mid-session | WebSocket close event | Continue session at 1× multiplier; show "Companion disconnected" banner; auto-reconnect attempt ×3 |

**The rule:** the app must always offer *a path to unlock* regardless of hardware state.
A user who cannot exercise should be able to unlock via the Sick Day mechanic. A user whose
camera is broken should be able to earn their screen time via accelerometer. No dead ends.

---

### 0.7 Monetisation Model

- **Core app: free forever.** Curtain, exercise detection, all scheduling, all exercises,
  basic cosmetics. No feature is paywalled.
- **Rep Coins: earned by reps only.** Never sold. Play Store gambling policy safe because
  there is no real-money path to gacha currency.
- **Trainer Pass (one-time IAP, not a subscription):** Unlocks 3 exclusive Legendary items
  per gacha track and doubles the seasonal banner pool size. Does not affect exercise
  detection, rep counting, or any gameplay mechanic. This is the ethical answer to
  Pushscroll's "#1 complaint: subscription or nothing."
- **Streak Freezes:** Craftable from Fabric Scraps only. Cannot be purchased. This keeps
  the anti-churn mechanic fully within the earned-reward loop.

---

## 1. Project Overview

**ScreenTrainer** is a cross-platform Flutter application that hides the device screen
behind an animated curtain and only reveals it after the user completes a configurable
physical challenge (push-ups counted by camera/accelerometer, a timed plank, a step
count, etc.). Its core purpose is to make screen time feel *earned*, combating passive
scrolling and sedentary habits — especially for children and teens.

The app runs on **Android phone**, **Android TV**, **ChromeOS**, **Windows**, **Linux**,
and **macOS**. It is published to the **Google Play Store** (phone + TV + ChromeOS) and
as direct-download binaries for desktop platforms.

Two types of people interact with every ScreenTrainer installation (see §0.5 for full
personas):
- **The Configurator** — the parent, guardian, or self-disciplined adult who sets up
  schedules, profiles, and PIN locks. Onboarding must be completable by a non-technical
  user in under 5 minutes.
- **The End User** — the child, teen, or adult who lives behind the curtain daily.
  Their primary interface is the exercise screen; it must feel like a game, not a chore.

Every product and UX decision in this codebase should be evaluated through the lens of
both personas simultaneously. A feature that delights the End User but lets them easily
bypass the lock is not acceptable. A feature that gives the Configurator control but
creates a frustrating dead-end for the End User will cause uninstalls.

---

## 2. Sibling Project — my_flutter_app

The sibling project lives at **`../my_flutter_app/`** (or the path explicitly passed at
session start — always confirm it exists with `ls ../my_flutter_app/` before reading).
**Read it before touching a single file in ScreenTrainer.** Here is exactly what to read
and what to extract from each file:

### Files to read and what to take from them

| File | What to extract |
|---|---|
| `pubspec.yaml` | Exact Flutter + Dart SDK constraints; exact version strings for every shared dep (provider, flutter_local_notifications, shared_preferences, fl_chart, lottie, battery_plus, media_kit, sensors_plus, permission_handler, etc.). Never guess a version — copy it. |
| `analysis_options.yaml` | Copy verbatim into ScreenTrainer root. |
| `lib/src/app.dart` | How `MultiProvider` is wired at the root; how `MaterialApp` receives the theme; how `ChangeNotifierProvider` wraps each service. Mirror this pattern exactly. |
| `lib/src/state/app_controller.dart` | The `ChangeNotifier` + `Provider` state pattern; how `notifyListeners()` is called; how settings are read from `SharedPreferences` at init. `ScreenTrainerController` should follow the same shape. |
| `lib/src/screens/home_screen.dart` | The `NavigationRail` implementation with 13 destinations; how selected index is managed; how content area switches. ScreenTrainer uses the same rail, just with different screens. |
| `lib/src/services/download_service.dart` | Service class shape: constructor injection, `ChangeNotifier`, `StreamController` pattern for progress reporting. All ScreenTrainer services follow this shape. |
| `lib/src/services/coordinator_service.dart` | WebSocket reconnect with exponential backoff — copy this pattern for `CompanionService`. |
| `lib/src/services/computation_service.dart` | `Isolate.run` + battery-aware scheduling pattern — copy for `MovementAnalyser` isolate. |
| `lib/src/services/dlna_discovery_service.dart` | mDNS/SSDP scan pattern — adapt for companion device discovery (`_screentrainer._tcp`). |
| `lib/src/services/local_media_server.dart` | `dart:io HttpServer` + `Range` header pattern — useful if ScreenTrainer ever streams exercise videos. |
| `lib/src/screens/compute_screen.dart` | Gamification UI patterns (tiers, progress bars, live stats) — mirror for the gacha + stats screen. |
| `android/app/build.gradle` | Signing config block and `key.properties` loading pattern — replicate for ScreenTrainer's keystore. |
| `scripts/build_linux_wsl.sh` | Build helper script pattern — add `scripts/generate_icons.sh` following the same shell style. |
| `.vscode/settings.json` | Copy launch configs and Dart/Flutter extension settings. |

### CI/CD workflows — CRITICAL distinction

The sibling project has **two separate workflow files** with distinct responsibilities:

**`.github/workflows/ci.yml`** — runs on every push and PR to `main`:
- `flutter pub get`
- `flutter analyze`
- `flutter test` (conditional)
- Does **not** build release binaries. Does **not** create GitHub Releases.

**`.github/workflows/release.yml`** — runs on `v*` tag pushes:
- Builds all platform binaries (Windows, Linux, Android split-per-abi)
- Packages artifacts (zip / tar.gz)
- Creates a GitHub Release with all binaries attached
- ⚠️ **The release logic in the sibling's `release.yml` is broken.** Read it to understand
  the structure and intent, but **rewrite it from scratch** for ScreenTrainer using the
  correct modern Actions:

```yaml
# Correct pattern for ScreenTrainer's release.yml
# Use these — not the deprecated ones in the sibling:
- uses: actions/upload-artifact@v4        # NOT v2 or v3
- uses: actions/download-artifact@v4      # NOT v2 or v3
- uses: ncipollo/release-action@v1        # NOT actions/create-release (deprecated)
  with:
    artifacts: "dist/*"
    generateReleaseNotes: true
    tag: ${{ github.ref_name }}
```

ScreenTrainer's `release.yml` must have these jobs and correct `needs:` chains:

```
on:
  push:
    tags: ['v*']

jobs:
  build-android  (ubuntu-latest)  → uploads artifact "android-apks"
  build-windows  (windows-latest) → uploads artifact "windows-build"
  build-linux    (ubuntu-latest)  → uploads artifact "linux-build"
  build-macos    (macos-latest)   → uploads artifact "macos-build"
  release        (ubuntu-latest)
    needs: [build-android, build-windows, build-linux, build-macos]
    → downloads all four artifacts
    → packages them (zip / tar.gz)
    → ncipollo/release-action to create GitHub Release
```

Android build job must include:
```yaml
- name: Set up JDK 17
  uses: actions/setup-java@v4
  with: { java-version: '17', distribution: 'temurin' }

- name: Decode keystore
  if: secrets.KEYSTORE_BASE64 != ''
  run: |
    echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/keystore.jks
    cat > android/key.properties <<EOF
    storePassword=${{ secrets.KEYSTORE_PASSWORD }}
    keyPassword=${{ secrets.KEY_PASSWORD }}
    keyAlias=${{ secrets.KEY_ALIAS }}
    storeFile=keystore.jks
    EOF

- run: flutter build apk --release --split-per-abi
- run: flutter build appbundle --release   # for Play Store
```

macOS build job must code-sign if `APPLE_CERTIFICATE` secret is present (optional,
graceful skip if absent — same pattern as the sibling's optional keystore).

### Binary naming convention (from sibling)

The sibling names its output binary `my_flutter_app` (Windows: `my_flutter_app.exe`,
Linux: `my_flutter_app`). ScreenTrainer should name its binary `screen_trainer`
(Windows: `screen_trainer.exe`) — set via `project-name` in `flutter create` and
confirm in `windows/runner/main.cpp` and `linux/CMakeLists.txt`.

---

## 3. Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                         Flutter UI Layer                         │
│  AdaptiveShell (NavigationRail phone/desktop | D-pad TV)         │
│  CurtainOverlay  ──►  ExerciseChallenge  ──►  SuccessAnimation  │
├──────────────────────────────────────────────────────────────────┤
│                       State Management                           │
│  ScreenTrainerController (ChangeNotifier + Provider)             │
│  CurtainState { locked | unlocking | open | cooldown }          │
├───────────────┬──────────────────┬───────────────────────────────┤
│  Services     │  Services        │  Services                     │
│               │                  │                               │
│ OverlayService│ ExerciseService  │ ScheduleService               │
│ (Android OVL) │ (camera/accel)   │ (time windows, cooldowns)    │
│               │                  │                               │
│ UsageService  │ CameraService    │ NotificationService           │
│ (UsageStats)  │ (ML Kit pose)    │ (flutter_local_notifications) │
│               │                  │                               │
│ SettingsRepo  │ ProfileService   │ GamificationService           │
│ (shared_prefs)│ (multi-user)     │ (streaks, badges, XP)        │
├───────────────┴──────────────────┴───────────────────────────────┤
│                     Platform / Native Layer                      │
│  Android: WindowManager overlay, AccessibilityService,           │
│           UsageStatsManager, ForegroundService                   │
│  Desktop: always-on-top window, system tray icon                 │
│  All:     camera, accelerometer (sensors_plus)                   │
└──────────────────────────────────────────────────────────────────┘
```

### State machine for the curtain

```
LOCKED ──(challenge started)──► UNLOCKING ──(reps complete)──► OPEN
  ▲                                                               │
  └──────────────(cooldown expires / new session)────────────────┘
                       COOLDOWN (timer ticking)
```

---

## 4. Directory Structure

```
lib/
  main.dart                      # Entry point; platform-aware bootstrap
  src/
    app.dart                     # MaterialApp, theme, Provider tree
    state/
      screen_trainer_controller.dart   # Central ChangeNotifier
      curtain_state.dart               # Enum + model
    screens/
      home_screen.dart           # Adaptive shell (phone / TV / desktop)
      curtain_screen.dart        # Full-screen curtain overlay
      exercise_screen.dart       # Active challenge UI
      settings_screen.dart       # All user preferences
      schedule_screen.dart       # Time-window configuration
      profile_screen.dart        # Multi-profile management
      stats_screen.dart          # Usage history, streaks, badges
      onboarding_screen.dart     # First-run wizard
    widgets/
      curtain_widget.dart        # Animated teal curtain (matches icon)
      rep_counter_widget.dart    # Live rep count + camera preview
      exercise_card.dart         # Challenge type selector card
      tv_focus_wrapper.dart      # D-pad focusable container
    services/
      overlay_service.dart       # Android SYSTEM_ALERT_WINDOW management
      exercise_service.dart      # Rep detection (pose / accel / manual)
      camera_service.dart        # ML Kit Pose Detection wrapper
      schedule_service.dart      # Lock windows, cooldown timers
      usage_service.dart         # Android UsageStatsManager wrapper
      notification_service.dart  # flutter_local_notifications
      settings_repository.dart   # SharedPreferences abstraction
      profile_service.dart       # Multi-user profile CRUD
      gamification_service.dart  # XP, streaks, badge unlock logic
      sick_day_service.dart      # Bypass logic, streak freeze, substitute tasks
    models/
      challenge_config.dart      # Exercise type, target reps, rest time
      schedule_window.dart       # Start/end time, days of week
      profile.dart               # Per-user settings + stats
      badge.dart                 # Gamification badge model
    theme/
      app_theme.dart             # Material 3 teal + gold palette
      tv_theme.dart              # Larger touch targets for TV
    utils/
      platform_utils.dart        # isAndroidTV(), isDesktop(), etc.
      permission_utils.dart      # Permission request flows
      strings.dart               # All user-facing copy; tone variants by streak length
android/
  app/
    src/main/
      kotlin/.../
        MainActivity.kt
        OverlayService.kt        # Kotlin foreground service
        AccessibilityWatcher.kt  # Detect foreground app changes
        UsageStatsHelper.kt      # Wrap UsageStatsManager
assets/
  icons/
    app_icon.jpg                 # Source icon (convert on first run)
  sounds/
    curtain_open.mp3
    rep_counted.mp3
  animations/
    curtain_open.json            # Lottie animation
.github/
  workflows/
    ci.yml
  copilot-instructions.md        # ← this file
```

---

## 5. Feature Requirements

### 5.1 Core — Curtain & Lock

- **Full-screen curtain overlay** rendered as an animated teal drape matching the app icon.
- On Android: drawn via `WindowManager` + `SYSTEM_ALERT_WINDOW` so it covers all other apps.
  Use a Kotlin `ForegroundService` (`OverlayService.kt`) that Flutter talks to via a
  `MethodChannel` (`com.screentrainer/overlay`).
- On desktop: launch an always-on-top Flutter window that covers the primary display.
- Curtain lifts with a smooth physics-based slide animation (top → bottom reveal) when the
  challenge is complete.

### 5.2 Exercise Challenges

Support at least these challenge types (selectable per profile):

| Type            | Detection method                        | Fallback          |
|-----------------|-----------------------------------------|-------------------|
| Push-ups        | ML Kit Pose Detection (camera)          | Manual tap count  |
| Squats          | ML Kit Pose Detection (camera)          | Manual tap count  |
| Plank hold      | Accelerometer stillness (sensors_plus)  | Timer             |
| Walking steps   | `pedometer` package (step sensor)       | Manual entry      |
| Manual count    | Large tap button on screen              | (always available)|

Rep detection logic lives in `ExerciseService`. Each exercise type is a strategy class
implementing `ExerciseStrategy { Stream<int> repStream; Future<void> start(); void stop(); }`.

### 5.3 Scheduling

- Users define **time windows** when the curtain is active (e.g. "weekdays 21:00–07:00").
- A **daily screen-time budget** triggers the curtain when exceeded (uses `UsageStatsManager`
  on Android; a best-effort foreground-window watcher on desktop via `local_notifier`).
- **Cooldown**: after earning screen time, a configurable cooldown (e.g. 30 min) restarts the
  lock. Show a countdown widget in the notification shade.

### 5.4 Profiles

- Support multiple profiles (children, adults, custom) with independent configs.
- PIN/biometric lock to prevent profile switching or settings edits.
- Parent profile can manage child profiles.

### 5.5 Gamification & Gacha

#### Currency & Pulls

- **Rep Coins** — earned 1:1 per completed rep. The primary gacha currency; never purchasable
  with real money (keeps the app ethical and avoids app store gambling policy issues).
- **Curtain Tokens** — bonus currency for streaks, first daily challenge, and milestone events.
- **Pull cost**: 10 Rep Coins per single pull; 90 for a 10-pull (one guaranteed rare+).

#### Gacha Pool — Two tracks: Curtain Cosmetics + App Themes

There are two separate gacha pools, both fed by the same Rep Coins. The player chooses
which pool to pull from at the pull screen.

**Track A — Curtain Cosmetics** (the curtain the user sees every time the screen locks)

| Rarity   | Drop rate | Examples                                                       |
|----------|-----------|----------------------------------------------------------------|
| Common   | 60 %      | Solid colour curtains (red, purple, navy, forest green)        |
| Rare     | 25 %      | Patterned curtains (stripes, polka dots, brick wall, night sky)|
| Epic     | 12 %      | Animated curtains (rain drops, falling leaves, pixel fire)     |
| Legendary| 3 %       | Physics curtain (cloth sim), holographic foil, "invisible" curtain (frosted glass blur) |

**Track B — App Themes** (recolours the entire ScreenTrainer UI)

| Rarity   | Drop rate | Examples                                                                         |
|----------|-----------|----------------------------------------------------------------------------------|
| Common   | 60 %      | Single-accent recolours: Crimson, Ocean, Forest, Monochrome                      |
| Rare     | 25 %      | Dual-tone palettes: Sunset (orange+pink), Arctic (cyan+white), Dusk (navy+gold)  |
| Epic     | 12 %      | Gradient themes: Aurora (animated gradient UI), Lava, Deep Sea                   |
| Legendary| 3 %       | Full theme overhauls: Retro CRT (scanlines + green phosphor), Neon Tokyo (cyberpunk), Paper (skeuomorphic notebook aesthetic) |

A `ThemeItem` extends `GachaItem` with a `ColorScheme colorScheme` and an optional
`ThemeOverride` that can swap fonts, icon packs, and animation curves for Legendary tiers.
Apply via `Theme.of(context)` replacement in `app.dart`; the active theme is stored in
`SettingsRepository`.

**Shared gacha mechanics (both tracks)**

- **Pity counter**: separate per track; 80-pull hard pity, soft pity from 65 (+1% Legendary/pull).
- **Duplicates** → Fabric Scraps (curtains) or Dye Vials (themes); craft specifics in the shop.
- **Daily free pull**: one pull per day per track if ≥1 challenge completed.
- **Streak multiplier**: 7-day streak → double Rep Coins that day.
- **Seasonal banners**: rate-up featured Legendary; one per track; config in local JSON asset.
- **Trainer Pass** (one-time IAP): +3 exclusive Legendaries per track added to seasonal pool only.

#### Pull Animation

- Full-screen animated reveal: curtain sweeps in from both sides, pauses, then dramatically
  drops to reveal the reward card.
- For Track B (theme) reveals: the UI behind the curtain *transitions live* into the new
  theme as the curtain drops — instant "wow, my app looks different now" moment.
- Use a `Lottie` animation (`assets/animations/gacha_pull.json`) with a shimmer fallback.
- Rarity particle burst: common = none, rare = sparkles, epic = confetti, legendary = screen
  shake + golden particles via `CustomPainter`.

#### Collection Screen

- Two tabs: "Curtains" and "Themes".
- Locked items shown as silhouettes with rarity colour border.
- Tap a collected item to **preview it live** (curtain drops in preview; theme recolours the
  collection screen itself in real time before confirming).
- "Set Active" button. "Owned X / Y" per rarity tier.
- Fabric Scraps / Dye Vials balance shown; craft button opens the shop.

#### Other Gacha-Adjacent Loops

- **Daily spin**: one free pull per day per track on challenge completion.
- **Streak multiplier**: 7-day streak doubles Rep Coin yield.
- **Seasonal banners**: rate-up pool from local JSON; new banners ship without a code change.
- **Fabric Scraps / Dye Vials shop**: spend shards to craft specific Epic/Legendary items.
- **"Pull party" bonus**: when a companion is connected and confirms a rep, the pull
  animation includes a second pair of hands grabbing the curtain — social moment.

### 5.6 Standalone Phone Mode

The app must be fully usable with only a single phone — no companion device, no TV. This is
the primary onboarding experience for most users.

#### Full-Screen Overlay (Anti-Cheat)

On Android, the curtain is drawn as a `WindowManager` overlay with these flags:

```kotlin
// OverlayService.kt
WindowManager.LayoutParams(
    WindowManager.LayoutParams.MATCH_PARENT,
    WindowManager.LayoutParams.MATCH_PARENT,
    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
        or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN
        or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
    PixelFormat.TRANSLUCENT
)
```

This draws above **all** apps including the launcher, Recent Apps, and the notification
shade pull-down. The user cannot switch apps to bypass the lock.

Additional hardening:
- **Block Recent Apps button**: set `FLAG_SECURE` on the overlay window so screenshots
  and the recents thumbnail show a black frame instead of app content.
- **Detect overlay dismissal attempts**: register a `BroadcastReceiver` for
  `Intent.ACTION_CLOSE_SYSTEM_DIALOGS` — if the user tries to open the power menu or
  assistant, the overlay re-draws itself within 50 ms.
- **Reboot persistence**: `RECEIVE_BOOT_COMPLETED` broadcast restores the overlay state
  on device restart if a session was active.
- **Accessibility service watcher** (`AccessibilityWatcher.kt`): monitors
  `TYPE_WINDOW_STATE_CHANGED` events. If ScreenTrainer is force-stopped via Settings,
  the foreground service re-launches via `JobScheduler` within 30 s.

#### Standalone Exercise Flow (phone only)

1. Screen locks → overlay appears with curtain animation.
2. User taps "Start Challenge" on the overlay.
3. Camera opens in a small PiP-style preview at the bottom of the overlay.
4. ML Kit Pose Detection counts reps in real time; rep counter increments visibly.
5. **On each confirmed rep**: `HapticFeedback.heavyImpact()` + a brief green flash on the
   overlay border. This is the satisfying feedback loop that keeps users honest.
6. **On challenge complete**:
   - `Vibration.vibrate(pattern: [0, 200, 100, 400])` — two distinct pulses, so the user
     feels it even with the screen off.
   - Transition to `CurtainState.pendingReveal` — **do not lift the curtain yet**.
   - Register a `BroadcastReceiver` for `Intent.ACTION_SCREEN_ON`.
   - When `ACTION_SCREEN_ON` fires (or immediately if the screen is already on):
     - Curtain lifts with physics-based slide animation revealing the screen beneath.
     - XP + Rep Coins awarded; if enough for a pull, a "You can pull!" badge appears.
     - Unregister the receiver.
   - While in `pendingReveal` with the screen off, keep showing the closed curtain so
     the user wakes up to the satisfying lift rather than an already-open screen.
   - Add a `pendingReveal` visual state to `curtain_widget.dart`: a subtle gold shimmer
     pulses on the curtain edge to signal "you've earned it — turn the screen on".

```dart
// In CurtainState enum
enum CurtainState { locked, unlocking, pendingReveal, open, cooldown }

// In ScreenTrainerController
void _onChallengeComplete() {
  _state = CurtainState.pendingReveal;
  notifyListeners();
  HapticFeedback.heavyImpact();
  Vibration.vibrate(pattern: [0, 200, 100, 400]);
  _awardXpAndCoins();          // award immediately on completion
  _screenOnSubscription = _screenStateStream.listen((on) {
    if (on) _revealCurtain();
  });
  // If screen is already on, reveal immediately
  if (_isScreenOn) _revealCurtain();
}

void _revealCurtain() {
  _screenOnSubscription?.cancel();
  _state = CurtainState.open;
  notifyListeners();           // triggers SlideTransition in curtain_widget.dart
  _startCooldownTimer();
}
```

Listen to screen state via a `MethodChannel` event stream from `OverlayService.kt`,
which registers/unregisters the `ACTION_SCREEN_ON` / `ACTION_SCREEN_OFF` receiver and
forwards events to Flutter.

7. Session timer starts when `CurtainState.open`; when it expires the curtain drops again.

#### Standalone fallback (no camera / camera denied)

- Use accelerometer peak detection from `MovementAnalyser` as primary rep counter.
- Show "Move your phone like this" animated diagram matching the exercise (push-up =
  phone on floor, squats = phone in pocket).
- Manual tap mode always available as last resort (counts at 0.5× XP, no Rep Coins).

#### Model sketch (gacha)

```dart
enum GachaRarity { common, rare, epic, legendary }
enum GachaTrack { curtain, theme }

class GachaItem {
  final String id;
  final String name;
  final GachaRarity rarity;
  final GachaTrack track;
  final String assetPath;      // Lottie / shader / colour hex
  final bool isAnimated;
}

class ThemeItem extends GachaItem {
  final ColorScheme colorScheme;
  final ThemeOverride? override; // fonts, icon pack, animation curves (Legendary only)
}

class GachaPool {
  final GachaTrack track;
  final List<GachaItem> items;
  final Map<GachaRarity, double> weights;
  final int pityThreshold;     // 80
  final int softPityStart;     // 65
  GachaItem roll(Random rng, int currentPity);
}

class GachaService extends ChangeNotifier {
  Future<List<GachaItem>> pullSingle(GachaTrack track);
  Future<List<GachaItem>> pullTen(GachaTrack track);
  int get repCoins;
  int pityCounter(GachaTrack track);
  List<GachaItem> get ownedItems;
  GachaItem? get activeCurtain;
  ThemeItem? get activeTheme;
  void setActiveCurtain(GachaItem item);
  void setActiveTheme(ThemeItem item);
}
```



#### Concept

Any device running ScreenTrainer can act as a **primary** (the locked screen) or a
**companion** (the movement sensor). A phone strapped to the user's wrist or laid on their
back while doing push-ups streams accelerometer + gyroscope data to the primary over the
local Wi-Fi network. The primary verifies real movement and awards a **10× XP multiplier**
and **10× Rep Coin multiplier** for every companion-confirmed rep.

```
[Android TV / Chromebook / Desktop]          [Phone in pocket / on wrist]
        PRIMARY                   ←——  WebSocket ——→      COMPANION
  shows curtain + challenge UI              streams IMU data
  counts reps from companion data           runs MovementAnalyser
  awards 10× XP on verified rep            shows "connected" status
```

A single user can pair multiple companions simultaneously (e.g. phone on wrist AND a
second phone on ankle for squat detection). Rep counts are merged and de-duplicated by
timestamp on the primary.

#### Device Discovery — mDNS (same pattern as DLNA in my_flutter_app)

Use the `nsd_android` + `multicast_dns` packages to advertise and discover peers:

- **Service type**: `_screentrainer._tcp`
- **Primary** advertises the service when a challenge is active.
- **Companion** scans for `_screentrainer._tcp` services and shows a list of found primaries.
- Fallback: manual IP entry (same pattern as DLNA manual IP in my_flutter_app).

#### Pairing Flow

1. Primary starts challenge → begins mDNS advertisement → shows QR code containing
   `screentrainer://pair?host=<IP>&port=<PORT>&session=<UUID>`.
2. Companion scans QR (or picks from mDNS list) → opens WebSocket → sends `HELLO` with
   device name and sensor capabilities.
3. Primary accepts → sends `SESSION_CONFIG` (exercise type, target reps, sensitivity).
4. Companion streams `IMU_FRAME` messages at 50 Hz.
5. Primary sends `REP_CONFIRMED` or `REP_REJECTED` per detected rep.
6. On challenge complete, primary sends `SESSION_END` with final stats.

#### WebSocket Protocol (JSON over `ws://`)

```jsonc
// Companion → Primary
{ "type": "HELLO",      "deviceName": "Lukas's Pixel 9", "capabilities": ["accel","gyro","pose"] }
{ "type": "IMU_FRAME",  "ts": 1716000000123, "ax": 0.12, "ay": -9.7, "az": 0.34,
                         "gx": 0.01, "gy": 0.02, "gz": 0.00 }

// Primary → Companion
{ "type": "SESSION_CONFIG", "exercise": "pushup", "targetReps": 10, "sensitivity": "normal" }
{ "type": "REP_CONFIRMED",  "repNumber": 3, "multiplier": 10 }
{ "type": "SESSION_END",    "totalReps": 10, "xpAwarded": 1000, "coinsAwarded": 100 }

// Bidirectional
{ "type": "PING" }
{ "type": "PONG" }
{ "type": "DISCONNECT", "reason": "challenge_complete" }
```

#### MovementAnalyser — rep detection from raw IMU

Lives in `services/movement_analyser.dart`. Processes the `IMU_FRAME` stream using a
sliding-window peak-detection algorithm:

- **Push-up**: detects the down→up Z-axis acceleration signature (~1.5 g peak).
- **Squat**: detects the down→up Y-axis signature with gyroscope pitch confirmation.
- **Plank**: detects sustained near-zero variance across all axes for `targetSeconds`.
- **Steps**: peak detection on the magnitude vector `sqrt(ax²+ay²+az²)` crossing a threshold.

Sensitivity levels (`normal` / `strict` / `easy`) adjust the peak threshold and minimum
time between reps to prevent cheating by shaking the phone.

```dart
// services/movement_analyser.dart
class MovementAnalyser {
  final ExerciseType exerciseType;
  final SensitivityLevel sensitivity;

  Stream<RepEvent> get repStream;          // emits on each confirmed rep
  Stream<double> get intensityStream;      // 0.0–1.0 for live feedback bar

  void ingestFrame(ImuFrame frame);
  void reset();
}
```

#### CompanionService

```dart
// services/companion_service.dart
enum DeviceRole { primary, companion }

class CompanionService extends ChangeNotifier {
  DeviceRole role;
  List<DiscoveredDevice> nearbyPrimaries;    // mDNS scan results
  List<ConnectedCompanion> connectedCompanions;  // on primary side

  // Primary side
  Future<void> startAdvertising(SessionConfig config);
  Future<void> stopAdvertising();
  Stream<ImuFrame> get mergedImuStream;      // from all companions, de-duped
  int get activeCompanionCount;

  // Companion side
  Future<void> connectTo(DiscoveredDevice device);
  Future<void> connectToManualIp(String ip, int port);
  Future<void> startStreaming();             // begins 50 Hz IMU broadcast
  Future<void> disconnect();

  // Shared
  String get pairingQrData;                 // URI for QR code
}
```

#### Companion UI (phone in companion mode)

- **Big green pulsing circle** showing "Connected to [TV name]" — reassuring at a glance
  when the phone is on the floor during push-ups.
- **Intensity bar** driven by `MovementAnalyser.intensityStream` — bounces with movement,
  so users can see the phone is picking them up.
- **Rep flash** — full-screen green flash + haptic on each confirmed `REP_CONFIRMED`.
- **Minimal UI** so it works even when the phone screen dims; keep the service alive as
  a foreground service so Android doesn't kill it mid-workout.

#### Multiplier Rules

| Scenario                               | XP multiplier | Rep Coin multiplier |
|----------------------------------------|:-------------:|:-------------------:|
| No companion connected                 |      1×       |         1×          |
| ≥1 companion connected, rep confirmed  |     10×       |        10×          |
| Companion connected, rep self-reported |      2×       |         2×          |
| 3+ companions all confirm same rep     |     25×       |        25×          |

The "25× for 3 companions" tier exists purely for the scenario where a family sets up
multiple devices — it's a discovery moment that will drive word-of-mouth.

#### Security

- Session UUID in the pairing URI prevents strangers on the same Wi-Fi joining a session.
- All WebSocket messages are validated against the session UUID; unknown senders are dropped.
- No data leaves the local network; there is no cloud component.

### 5.7 Adaptive UI (phone / TV / desktop)

- Phone & desktop: `NavigationRail` (matches my_flutter_app pattern).
- **Android TV**: replace NavigationRail with a left-side `FocusTraversalGroup` D-pad menu.
  All interactive elements wrapped in `tv_focus_wrapper.dart`. Font sizes ×1.5.
  Leanback launcher activity declared in `AndroidManifest.xml`.
- ChromeOS: treat as phone form-factor with mouse/keyboard support enabled.

### 5.7 Settings (mirroring my_flutter_app settings pattern)

- Theme: dark / light / system
- Challenge type & target reps per profile
- Schedule windows
- Cooldown duration
- Biometric / PIN lock toggle
- Notification preferences
- About / licenses / version

---

## 6. Android-Specific Implementation

### Required permissions (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE"/>
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS"
    tools:ignore="ProtectedPermissions"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<!-- Screen state (no permission needed, but declare receiver) -->
<!-- ACTION_SCREEN_ON and ACTION_SCREEN_OFF are not grantable — just register in code -->
<!-- TV -->
<uses-feature android:name="android.hardware.touchscreen" android:required="false"/>
<uses-feature android:name="android.software.leanback" android:required="false"/>
```

### Leanback / Android TV launcher

```xml
<activity android:name=".MainActivity" ...>
  <!-- phone intent filter already present -->
  <intent-filter>
    <action android:name="android.intent.action.MAIN"/>
    <category android:name="android.intent.category.LEANBACK_LAUNCHER"/>
  </intent-filter>
</activity>
```

### MethodChannels

| Channel                        | Methods (Flutter → Kotlin)                                |
|-------------------------------|-----------------------------------------------------------|
| `com.screentrainer/overlay`   | `showOverlay()`, `hideOverlay()`, `isOverlayShowing()`   |
| `com.screentrainer/usage`     | `getTodayUsageMs(packageName)`, `hasUsagePermission()`   |
| `com.screentrainer/system`    | `requestOverlayPermission()`, `openAccessibilitySettings()`|

---

## 7. CI/CD Pipeline

ScreenTrainer uses the same **two-file** workflow split as the sibling:

### `ci.yml` — quality gate (push + PR to main)

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.x', channel: stable }
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
```

No build jobs, no release logic here. This keeps CI fast (< 3 min) on every commit.

### `release.yml` — build + publish (v* tags only)

**Write this from scratch** — do not copy the sibling's broken release.yml.
Use `actions/upload-artifact@v4`, `actions/download-artifact@v4`, and
`ncipollo/release-action@v1`. Full structure:

```yaml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { java-version: '17', distribution: 'temurin' }
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.x', channel: stable }
      - run: flutter pub get
      - name: Decode keystore (optional)
        if: ${{ secrets.KEYSTORE_BASE64 != '' }}
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/keystore.jks
          printf "storePassword=${{ secrets.KEYSTORE_PASSWORD }}\n\
          keyPassword=${{ secrets.KEY_PASSWORD }}\n\
          keyAlias=${{ secrets.KEY_ALIAS }}\n\
          storeFile=keystore.jks" > android/key.properties
      - run: flutter build apk --release --split-per-abi
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v4
        with:
          name: android-apks
          path: |
            build/app/outputs/flutter-apk/app-*-release.apk
            build/app/outputs/bundle/release/app-release.aab

  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.x', channel: stable }
      - run: flutter pub get
      - run: flutter build windows --release
      - name: Zip output
        run: Compress-Archive -Path build\windows\x64\runner\Release\* -DestinationPath ScreenTrainer-Windows.zip
        shell: pwsh
      - uses: actions/upload-artifact@v4
        with: { name: windows-build, path: ScreenTrainer-Windows.zip }

  build-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: sudo apt-get update && sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.x', channel: stable }
      - run: flutter pub get
      - run: flutter build linux --release
      - run: tar -czf ScreenTrainer-Linux.tar.gz -C build/linux/x64/release/bundle .
      - uses: actions/upload-artifact@v4
        with: { name: linux-build, path: ScreenTrainer-Linux.tar.gz }

  build-macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.x', channel: stable }
      - run: flutter pub get
      - run: flutter build macos --release
      - run: |
          cd build/macos/Build/Products/Release
          zip -r ScreenTrainer-macOS.zip ScreenTrainer.app
          mv ScreenTrainer-macOS.zip ${{ github.workspace }}/
      - uses: actions/upload-artifact@v4
        with: { name: macos-build, path: ScreenTrainer-macOS.zip }

  release:
    runs-on: ubuntu-latest
    needs: [build-android, build-windows, build-linux, build-macos]
    permissions:
      contents: write
    steps:
      - uses: actions/download-artifact@v4
        with: { path: dist/ }
      - name: Flatten dist
        run: find dist -mindepth 2 -type f -exec mv {} dist/ \;
      - uses: ncipollo/release-action@v1
        with:
          artifacts: "dist/*"
          generateReleaseNotes: true
          tag: ${{ github.ref_name }}
          token: ${{ secrets.GITHUB_TOKEN }}
```

### Android signing secrets

Same secret names as the sibling project:

| Secret              | Value                        |
|---------------------|------------------------------|
| `KEYSTORE_BASE64`   | `base64 -i your.jks`        |
| `KEYSTORE_PASSWORD` | Keystore password            |
| `KEY_ALIAS`         | Key alias                    |
| `KEY_PASSWORD`      | Key password                 |

Without secrets, Android builds are debug-signed — still installable for testing.

### Triggering a release

```bash
git tag v0.1.0 -m "Initial release"
git push origin v0.1.0
```

---

## 8. Icon Conversion

The source icon is `assets/icons/app_icon.jpg` (the teal curtain + smiley face design).
On first scaffold, generate a script `scripts/generate_icons.sh` that:

1. Uses `flutter_launcher_icons` package to generate all required sizes from the JPG.
2. Generates the Android TV banner (`assets/icons/tv_banner.png`, 320×180) — placeholder
   until the real banner is provided. The placeholder should be the icon centered on a teal
   background with "ScreenTrainer" in white text.
3. `pubspec.yaml` entry:

```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icons/app_icon.jpg"
  adaptive_icon_background: "#B2EBF2"   # light teal
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"
  min_sdk_android: 21
  web:
    generate: false
  windows:
    generate: true
    image_path: "assets/icons/app_icon.jpg"
    icon_size: 256
  macos:
    generate: true
    image_path: "assets/icons/app_icon.jpg"
```

---

## 9. Key Packages

Read exact version strings from `../my_flutter_app/pubspec.yaml` and copy them literally.
Do not invent semver ranges. Packages annotated "(sibling)" must match the sibling exactly:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State
  provider:              # copy from sibling

  # Persistence
  shared_preferences:    # copy from sibling

  # Notifications
  flutter_local_notifications:  # copy from sibling

  # Camera & ML
  camera: ^0.11.0
  google_mlkit_pose_detection: ^0.11.0

  # Sensors
  sensors_plus:          # copy from sibling
  pedometer: ^4.0.0

  # Charts (stats screen)
  fl_chart:              # copy from sibling

  # Animations
  lottie:                # copy from sibling

  # Biometric
  local_auth: ^2.2.0

  # Icons
  flutter_launcher_icons: ^0.13.1  # dev_dependency

  # Adaptive / TV
  flutter_adaptive_scaffold: ^0.2.0

  # Companion device / local network
  nsd_android: ^0.2.0              # mDNS advertisement + discovery (Android)
  multicast_dns: ^0.3.4            # mDNS for desktop/macOS/Linux
  web_socket_channel: ^3.0.0       # WebSocket client + server
  qr_flutter: ^4.1.0               # QR code display (primary pairing screen)
  mobile_scanner: ^5.2.0           # QR code scan (companion pairing screen)
  wakelock_plus: ^1.2.0            # keep screen on during companion streaming

  # Permission handling
  permission_handler: ^11.3.0

  # Gacha / particles
  confetti: ^0.7.0                # confetti burst on epic/legendary reveals
```

---

## 10. Coding Conventions & Execution Mandate

### 10.1 Code Quality Rules (same as my_flutter_app)

- **Dart style**: `flutter analyze` must pass with zero errors/warnings before any commit.
- **Naming**: `snake_case` files, `PascalCase` classes, `camelCase` variables.
- **Services**: stateless where possible; inject via `Provider` in `app.dart`.
- **No `BuildContext` in services**: pass callbacks or use `StreamController`.
- **Platform guards**: wrap all platform-specific calls in `if (Platform.isAndroid)` or
  `kIsWeb` guards; never let desktop code crash on a missing Android plugin.
- **TV guards**: use `PlatformUtils.isAndroidTV()` (check `android.software.leanback`
  feature) to swap `NavigationRail` for D-pad menu.
- **Commits**: conventional commits (`feat:`, `fix:`, `chore:`, `docs:`).
- **No `print()`**: use a `LogService` with `debugPrint` in debug mode only.
- **No hardcoded strings** in UI: all user-facing copy goes in a `strings.dart` constant
  file from day one, to make future localisation trivial.

### 10.2 The "No Placeholder" Mandate

**Never generate stub, mock, or TODO-only implementations.**

Every file Copilot creates must be production-ready and compilable. Specifically:

- `ExerciseService` must have a working `ManualCountStrategy` and `AccelerometerStrategy`
  from the first commit — not a `// TODO: implement` body.
- `GachaService` must perform real weighted rolls against a real seeded pool — not return
  hardcoded items.
- `OverlayService.kt` must register real `WindowManager` params — not log "overlay shown".
- `MovementAnalyser` must run in a real `Isolate` with real peak detection logic — not a
  counter that increments on a timer.
- CI workflows must run successfully on first push — not contain placeholder secrets or
  broken step references.

If a full implementation requires an asset that doesn't exist yet (e.g. a Lottie file),
use a graceful shimmer fallback with a clear `// ASSET_PENDING: replace with lottie`
comment — but the surrounding logic (state transitions, coin awards, haptics) must be
fully wired and functional.

### 10.3 Product Micro-Decision Rules

When Copilot encounters an ambiguous product decision during implementation, apply these
rules in order:

1. **Never create a dead end.** There must always be a path to unlock the screen, even
   if camera, accelerometer, and companion all fail. See §0.6 degradation table.
2. **Never punish hardware failure.** If detection degrades, tell the user clearly and
   offer the next best option. Do not silently award 0 reps.
3. **Configurator controls are biometric/PIN gated by default.** Any screen that modifies
   schedules, profiles, or bypass rules must require authentication before opening.
   Unauthenticated users see a lock icon, not an error.
4. **Tone shifts with streak length.** Microcopy in the curtain screen and challenge
   complete screen should vary based on `StreakService.currentStreak`:
   - 0–6 days: motivational ("Earn it! You've got this.")
   - 7–29 days: affirming ("Day 12. You're building something real.")
   - 30+ days: identity-based ("42 days. 1,840 push-ups. This is who you are now.")
5. **The exercise screen is the hero screen.** It receives the most visual polish.
   Rep counter animations, haptics, and the curtain-lift reveal are never "good enough"
   — they are iterated until they feel genuinely satisfying.
6. **Rep Coins are awarded on challenge complete, not on curtain open.** The reward
   moment is finishing the exercise, not seeing the screen. This is intentional — it
   trains the brain to associate the good feeling with the physical effort, not the
   screen access.

### 10.4 Accessibility Baseline

- All interactive elements have semantic labels for screen readers.
- Minimum touch target: 48×48 dp (Flutter default; do not shrink it).
- Colour contrast: all text meets WCAG AA (4.5:1 for body, 3:1 for large text).
- The curtain overlay must be navigable via switch access (for users with motor
  disabilities who use accessibility services) — the challenge start button must be
  reachable without a touch screen.

---



## 11. First Tasks for Copilot (in order)

### Phase 0 — Read the sibling (mandatory before any code)

1. **Confirm** the sibling exists: `ls ../my_flutter_app/` — if not found, ask for the
   correct path before proceeding.
2. **Read** these files in order:
   - `../my_flutter_app/pubspec.yaml` → note every dependency version
   - `../my_flutter_app/analysis_options.yaml` → copy verbatim
   - `../my_flutter_app/.github/workflows/ci.yml` → note quality job structure
   - `../my_flutter_app/.github/workflows/release.yml` → read for intent, rewrite for ScreenTrainer
   - `../my_flutter_app/lib/src/app.dart` → note MultiProvider wiring
   - `../my_flutter_app/lib/src/state/app_controller.dart` → note ChangeNotifier shape
   - `../my_flutter_app/lib/src/screens/home_screen.dart` → note NavigationRail pattern
   - `../my_flutter_app/lib/src/services/coordinator_service.dart` → note WebSocket pattern
   - `../my_flutter_app/lib/src/services/computation_service.dart` → note Isolate pattern
   - `../my_flutter_app/android/app/build.gradle` → note signing config block
3. **Do not generate a single file** until all of the above are read.

### Phase 1 — Scaffold & infrastructure

4. **Scaffold**: `flutter create --org com.screentrainer --project-name screen_trainer .`
5. **Copy** `analysis_options.yaml` from sibling verbatim.
6. **Write** `pubspec.yaml` using exact versions from sibling for shared deps; use pinned
   versions from §9 for ScreenTrainer-specific deps. Run `flutter pub get` and confirm
   zero errors before proceeding.
7. **Write** both workflow files:
   - `ci.yml` — quality gate only (pub get, analyze, test). Mirror sibling structure.
   - `release.yml` — full build + release pipeline written from scratch per §7.
     **Do not copy the sibling's release.yml**; use `actions/*@v4` and `ncipollo/release-action@v1`.
8. **Create** the full directory structure from §4.
9. **Create** `scripts/generate_icons.sh` — runs `flutter pub run flutter_launcher_icons`
   and generates the TV banner placeholder (320×180 teal background + "ScreenTrainer" text
   using ImageMagick or Pillow, whichever is available on the runner).

### Phase 2 — Core curtain loop

10. **Implement** `app_theme.dart` — Material 3, teal seed `#00ACC1`, gold accent `#FFB300`,
    `ThemeService` ChangeNotifier that swaps active `ThemeItem` from gacha at runtime.
11. **Implement** `screen_trainer_controller.dart` — `CurtainState` enum + ChangeNotifier
    with `lockScreen()`, `startChallenge()`, `completeChallenge()`, `openScreen()` and
    cooldown timer. Wire into `app.dart` MultiProvider following sibling pattern.
12. **Implement** `curtain_widget.dart` — full-screen teal drape, `SlideTransition` reveal,
    rarity-tinted border when a gacha cosmetic is active.
13. **Implement** `OverlayService.kt` + `MethodChannel('com.screentrainer/overlay')` —
    `WindowManager` overlay with anti-cheat flags (see §5.6). Foreground service keepalive.
    `AccessibilityWatcher.kt` + `UsageStatsHelper.kt` as described in §6.
14. **Implement** `ExerciseService` with `ManualCountStrategy` and `AccelerometerStrategy`
    first (no camera dependency → tests pass on CI runners that have no camera).
    `PoseDetectionStrategy` is a follow-up task once manual works end-to-end.
15. **Wire** standalone phone flow: lock → challenge → rep haptic + border flash → complete
    vibration pattern → curtain lift → XP/coin award → "Pull!" badge if threshold reached.

### Phase 3 — Home shell & screens

16. **Implement** `home_screen.dart` — `NavigationRail` for phone/desktop (mirroring
    sibling's 13-tab pattern; ScreenTrainer has fewer tabs initially), D-pad
    `FocusTraversalGroup` menu for Android TV. Use `PlatformUtils.isAndroidTV()` guard.
17. **Implement** `onboarding_screen.dart` — two distinct flows:
    - **Configurator flow** (first launch, no profiles yet): plain-language permission
      explanations, one permission at a time (overlay → camera → usage stats →
      notifications), PIN/biometric setup, "test the curtain" button before handing
      to child. See §0.5 Persona A design mandates.
    - **End User first-run** (profile already configured): exercise tutorial only —
      how to do a rep, what the rep counter looks like, what the curtain lift feels like.
      One demo rep required before the real session starts.
18. **Implement** `profile_screen.dart` with full PIN/biometric gate on all Configurator
    controls. Unauthenticated users see a lock icon, never an error message.
19. **Implement** `SickDayService` + the "Not today" path on the curtain overlay:
    - Adult/self profiles: biometric confirm → skip options (costs Rep Coins per §0.6).
    - Child profiles: PIN entry or substitute task (configured by Configurator).
    - Streak freeze: craftable item consumed here; deducted from `GachaService` inventory.
    - The "Not today" button is one deliberate extra tap from the main curtain — visible
      but not prominent.
20. **Implement** `settings_screen.dart` and `schedule_screen.dart` with full content
    (not stubs). Configurator-only sections are PIN-gated per rule in §10.3.
21. **Implement** `stats_screen.dart` — fl_chart bar chart of daily reps, line chart of
    screen-time budget, streak calendar heatmap. Microcopy tone varies by streak length
    per §10.3 rule 4.

### Phase 4 — Gacha system

22. **Implement** `GachaPool` + `GachaService` (both tracks: curtain + theme) with weighted
    roll, per-track pity counters, duplicate → shard conversion. Seed with placeholder
    assets (solid colours only; no Lottie dependency yet).
23. **Implement** `GachaPullScreen` — shimmer → reveal → rarity particle burst. Theme track
    reveal transitions the screen into the new theme live as the curtain drops.
24. **Implement** `CollectionScreen` — two tabs, silhouettes for unowned, live preview on
    tap, "Set Active" button.
25. **Wire** `GachaService.activeTheme` into `ThemeService` in `app.dart` so switching the
    active theme re-renders the whole app immediately.
26. **Wire** gacha sidebar into `stats_screen.dart`: Rep Coin balance, pity progress bars
    for both tracks, "Pull ×1" and "Pull ×10" buttons.

### Phase 5 — Companion device

27. **Implement** `CompanionService` — mDNS advertise/scan, WebSocket server+client,
    session UUID auth, merged IMU stream. Copy WebSocket reconnect pattern from
    `../my_flutter_app/lib/src/services/coordinator_service.dart`.
28. **Implement** `MovementAnalyser` — sliding-window peak detection as a Dart `Isolate`
    (copy isolation pattern from sibling's `computation_service.dart`).
29. **Implement** `PairingScreen` — QR display + scanner + mDNS device list + manual IP.
30. **Implement** companion mode UI (pulsing circle, intensity bar, rep flash, foreground
    keepalive) and wire `10×`/`25×` multipliers into `GachaService` and `GamificationService`.

### Phase 6 — Polish & release

31. **Flesh out** all stub screens from Phase 3 with real content.
32. **Add** `PoseDetectionStrategy` to `ExerciseService`.
33. **Write** `README.md` following the same structure and section order as
    `../my_flutter_app/README.md` (features table, architecture diagram, CI/CD badges,
    building from source, downloads, license).
34. **Tag** `v0.1.0` and verify the `release.yml` pipeline produces four artifacts and a
    GitHub Release with all binaries attached.

---

## 12. Part 2 — TV Banner (pending)

The Android TV banner asset (`assets/icons/tv_banner.png`, 320×180 px) will be provided in
the next message. When received:

1. Replace the placeholder banner generated in step 13 above.
2. Re-run `flutter_launcher_icons` to regenerate Android assets.
3. Verify the banner appears correctly in the leanback launcher.

---

## 13. Out of Scope (for now)

- iOS App Store distribution (no Apple developer account yet).
- Web target.
- Server-side leaderboards or cloud sync.
- In-app purchases.

---

*End of master instructions. Update this file as features are added or conventions change.*