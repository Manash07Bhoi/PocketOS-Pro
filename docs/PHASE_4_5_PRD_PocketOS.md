# PocketOS Pro — PHASE 4 & PHASE 5 PRD
## Path to v1.5 — Full OS Experience Ready for Publish

**Document Version:** 1.0  
**Phase 4 Output:** v1.3 — Advanced Tools + Desktop Mode  
**Phase 5 Output:** v1.5 — Full OS Polish + Play Store Publish  
**Build Rule:** Local backend/services completed in full before any UI widget is written. Zero mocks, zero placeholders, zero dummy data at every stage.

---

# PHASE 4 PRD — ADVANCED OS (v1.2 → v1.3)

## Overview

Phase 4 transforms PocketOS from a functional tool app into a genuine personal operating system. By the end of Phase 4, the app has 20+ working tools, a full package manager UI, desktop windowed mode, multi-session terminal, workspace management, and the complete mini-app suite. It is feature-complete for power users — developers, students, and tech enthusiasts can use it daily.

**Estimated Duration:** 10–14 days  
**Target Version:** v1.3.0  
**Prerequisite:** Phase 2 and Phase 3 must be fully complete and verified crash-free on Android 8, 10, 13.

---

## PHASE 4 — STEP 1: DATABASE AND SERVICE INFRASTRUCTURE UPGRADE

### What to build first

Before touching a single widget, the entire local backend described in Part A of the Complete PRD must exist and be tested. This means every SQLite table is created, every migration runs cleanly, every service class is instantiated, every repository is wired into `get_it`. The AI coding agent must complete and verify the following before writing any UI code for Phase 4.

**Database initialization verification checklist:**
The agent runs the app in debug mode and confirms that `pocketos_main.db` is created at the correct path (`getApplicationDocumentsDirectory()/pocketos/pocketos_main.db`). All 14 tables exist with the correct schema. The default seed data is present — one default workspace row named "Main", three pre-installed tools (nmap, fs, stats), one default terminal session row, and one welcome note. Foreign key constraints are enforced (`PRAGMA foreign_keys = ON` confirmed via a test query).

**Service locator verification:** Every service registered in `get_it` can be resolved without error. The agent writes a brief `main.dart`-level assertion that calls `sl<MediaService>()`, `sl<LogService>()`, `sl<NoteService>()`, etc. and verifies no exceptions. Only after this verification does Phase 4 UI work begin.

**New dependencies to add:** `sqflite`, `get_it`, `encrypt`, `flutter_secure_storage`, `crypto`, `archive`, `qr_flutter`, `mobile_scanner`, `flutter_markdown`, `device_info_plus`, `battery_plus`, `disk_space`, `uuid`, `fl_chart`, `flutter_animate`, `path`. These are added to `pubspec.yaml` and verified with `flutter pub get` before any usage.

---

## PHASE 4 — STEP 2: KERNEL UPGRADE (COMMAND SYSTEM EXPANSION)

### Command Dispatcher Enhancement

The existing basic command dispatcher from Phase 2 must be upgraded to handle the full command set described in Part C of the Complete PRD. The upgrade works as follows.

The `CommandDispatcher` maintains a `Map<String, BaseTool>` that maps command names to their tool instances. Before dispatching, it checks whether the requested tool exists in the `installed_tools` SQLite table. If the tool is not installed, it returns an error line: `"tool not found: <name>. Run 'pkg install <name>' to install it."` This is a real SQLite read — not a hardcoded check.

The dispatcher also handles built-in shell commands (`clear`, `history`, `echo`, `env`, `export`, `alias`, `!!`) which are not tools — they are handled directly by the dispatcher without going through the tool registry.

**Terminal session CWD tracking:** The `TerminalSession` entity gains a `cwd` field (String, default `/home`). Every `fs cd` command updates this field in both memory and SQLite. Every subsequent `fs ls` call with no path argument uses the session's current `cwd`. The prompt string updates dynamically: if `cwd` is `/home`, prompt shows `user@pocketos:~$`. If `cwd` is `/home/media`, it shows `user@pocketos:~/media$`.

**Command history with SQLite:** The existing Hive-based history must be migrated to SQLite `command_history` table. The `history` command reads from SQLite: `SELECT command FROM command_history WHERE session_id = ? ORDER BY executed_at DESC LIMIT 200`. The `!!` command fetches the most recent row and re-dispatches it. `!<n>` fetches by offset.

---

## PHASE 4 — STEP 3: PACKAGE MANAGER — FULL IMPLEMENTATION

### pkg service

The `PkgService` reads the tool registry from a bundled JSON asset (`assets/pkg_registry.json`). This file is bundled inside the Flutter app — no internet required. It lists every available tool with its name, version, description, author, size, commands, category, and dependencies. On first launch, `PkgService.initRegistry()` parses this file and populates the Hive `pkg_registry` box.

The `pkg install <name>` flow works as follows. The service finds the tool in the registry (Hive lookup). If already installed (SQLite `installed_tools` check), it emits: `"nmap is already installed (v1.0.0)"`. Otherwise, it streams a realistic installation animation: `"Reading package list..."` → 300ms pause → `"Fetching tool manifest... [████████████░░░░░░░░] 60%"` → 400ms → `"[████████████████████] 100%"` → `"Installing <name> v<version>..."` → 200ms → `"Setting up <name>..."` → 150ms → `"✔ <name> successfully installed."` → insert row to `installed_tools`. The progress animation is a `Stream<String>` generated with `Stream.periodic` and `yield*` — every frame is a new string sent to the terminal output stream.

The `pkg remove <name>` flow emits a confirmation prompt: `"Remove <name>? [y/N]"`. The terminal waits for a single `y` or `n` keypress input (the terminal BLoC enters a special `AwaitingConfirmation` state). On `y`, it deletes from SQLite and Hive, emits: `"✔ <name> removed."`. On `n`, emits: `"Aborted."`.

### Package Manager UI Screen

The graphical Package Manager screen reads directly from `installed_tools` SQLite and Hive `pkg_registry`. There is zero hardcoded data. The "Available" tab queries: all tools from Hive registry that are not in `installed_tools`. The "Installed" tab queries: `SELECT * FROM installed_tools ORDER BY installed_at DESC`. The "Updates" tab runs a comparison between Hive registry versions and installed versions — all tools show "Up to date" in v1 since all versions match.

The `Install` button on each tile triggers the same `PkgService.install()` stream as the terminal command — the UI shows a `LinearProgressIndicator` in the tile while installing. After completion, the tile updates to show the "Installed ✔" state. The UI subscribes to the same installation stream that the terminal uses — the same underlying service, two different presentation surfaces.

---

## PHASE 4 — STEP 4: MULTI-SESSION TERMINAL

The terminal screen gains tab support. Each tab corresponds to one `TerminalSession` row in SQLite. The session ID is the BLoC identifier.

**Tab creation:** Tapping the `+` icon in the terminal header creates a new session row in SQLite (`INSERT INTO terminal_sessions ...`), instantiates a new `TerminalBloc` with the new session ID, and adds a new tab to the tab bar. The new session starts with an empty output and the default prompt.

**Tab switching:** Tapping a tab saves the current scroll position and output list to the `TerminalBloc`'s state, then loads the selected session's BLoC. Sessions retain their output in memory while the app is running. On app restart, sessions are restored from SQLite but with empty in-memory output (the last 5 commands are re-displayed as "session restored" context).

**Tab renaming:** Long-press on a tab → inline rename text field → press Enter → updates `terminal_sessions.name` in SQLite.

**Tab closing:** Swipe-down on a tab → updates `terminal_sessions.is_active = 0` in SQLite → removes tab from UI. The last tab cannot be closed. The `TerminalBloc` for the closed session is disposed.

---

## PHASE 4 — STEP 5: NOTES APP — FULL IMPLEMENTATION

The Notes app reads and writes exclusively from the `notes` SQLite table with full-text search via the `notes_fts` virtual table.

**Creating a note:** `NoteService.createNote(title, content, tags)` inserts into `notes` and immediately inserts into `notes_fts`. The ID returned is used to navigate to the Note Editor screen.

**Full-text search:** The search bar in the Notes home uses SQLite FTS5: `SELECT n.* FROM notes n JOIN notes_fts ON notes_fts.rowid = n.id WHERE notes_fts MATCH ? AND n.is_deleted = 0 ORDER BY rank`. This is a real FTS query — not a LIKE query. Results highlight matching terms in the preview by comparing the query tokenization to the content.

**Auto-save:** The Note Editor uses a `StreamSubscription` on a `debounce(Duration(seconds: 5))` of the content `TextEditingController`. Every debounce fire calls `NoteService.updateNote(id, content: currentContent)` which runs `UPDATE notes SET content = ?, updated_at = ? WHERE id = ?` AND `UPDATE notes_fts SET content = ? WHERE rowid = ?`.

**Soft delete:** `NoteService.deleteNote(id)` sets `is_deleted = 1` — never a hard DELETE. The notes list query always filters `WHERE is_deleted = 0`. A "Recently Deleted" section in the filter chips shows soft-deleted notes with a 30-day recovery window.

---

## PHASE 4 — STEP 6: NMAP TOOL — ADVANCED FLAGS

Phase 4 adds the remaining nmap flags from the command reference: `--size`, `--dup`, `--sort`, `--limit`, `--month`, `--info`.

**`--size` filter:** The `MediaRepository.scanStream(filter)` method accepts a `SizeFilter` object with `min` and `max` fields. These translate to SQLite: `WHERE size_bytes > ? AND size_bytes < ?`. The value parsing (`>5MB`, `<10MB`, `=5MB`) is handled by a `SizeFilterParser` utility class.

**`--dup` flag:** Triggers the `DuplicateDetectWorker` isolate. The worker reads all `media_cache` rows with `size_bytes` grouped, finds groups with >1 member, checks filename similarity, and updates `is_duplicate = 1` and `duplicate_of = <id>` for matches. The terminal streams progress and then emits the final list of duplicate pairs. The query for results: `SELECT * FROM media_cache WHERE is_duplicate = 1 ORDER BY size_bytes DESC`.

**`--sort` flag:** Appended as `ORDER BY` to the SQLite query. `--sort size` → `ORDER BY size_bytes DESC`. `--sort date` → `ORDER BY created_at DESC`. `--sort name` → `ORDER BY name ASC`.

**`--info <id>` flag:** Reads a single row from `media_cache` by the file's asset ID. If not in cache, reads directly from `photo_manager` by ID. Outputs a full detail block in the terminal.

---

## PHASE 4 — STEP 7: ALL MINI APPS + TOOLS

### Build order (strict — each must be fully backend-complete before UI):

**Step 7a — Hash Tool**  
`HashService` uses Dart's `crypto` package. Text hashing is synchronous and instantaneous. File hashing for files >5MB is sent to `HashWorker` isolate via `compute()`. Results are inserted into `hash_results` SQLite table with `RETURNING id` to get the new row's ID. The terminal `hash` command and the Hash Tool UI both call `HashService` — same implementation, two surfaces.

**Step 7b — Encode/Decode Tool**  
All encoding is pure Dart math — no packages needed beyond `dart:convert`. Base64 uses `base64.encode/decode`. URL encoding uses `Uri.encodeFull/decodeFull`. Hex conversion is a custom utility function in `lib/core/utils/hex_utils.dart`. Results are appended to Hive `encode_history`. The terminal `encode`/`decode` commands call the same `EncoderService`.

**Step 7c — QR Tool**  
Generate tab: `qr_flutter` `QrImageView` widget renders in real-time from the input text. The QR widget's `data` parameter is updated via a `TextEditingController` listener. The terminal `qr gen "text"` command outputs an ASCII art QR code — this is achieved by rendering the QR matrix to a string using the `qr` Dart package directly. Scan tab: `mobile_scanner` `MobileScannerController` — real camera, real QR detection. Results stored in Hive `qr_history`.

**Step 7d — Calculator**  
Uses the `math_expressions` Dart package for expression parsing and evaluation. This handles `sin(30)`, `sqrt(144)`, `2^10`, etc. — real mathematical expression parsing, not a switch-case. History stored in `calculator_history` SQLite. The terminal `calc "expr"` command calls the same `CalculatorService.evaluate(expression)` method.

**Step 7e — Timer**  
`TimerService` maintains an active countdown using `Timer.periodic(Duration(seconds: 1), ...)`. State is a `TimerState` record: `{remaining: Duration, status: TimerStatus}`. The BLoC subscribes to the service's `Stream<TimerState>`. The terminal `timer 5m` command parses the duration string (`5m` → 300 seconds), calls `TimerService.start(duration)`, and emits the initial confirmation. The timer runs in the background even if the terminal session changes.

**Step 7f — Text Editor**  
`FileEditorService` reads files from the device using `File(path).readAsString()` for real files, or from a Hive virtual file box for virtual files. Writes use `File(path).writeAsString(content)`. Auto-save uses a `StreamController` with `debounce` from `rxdart`. The "file modified" indicator (unsaved dot) is managed by comparing the current content hash to the last-saved hash using MD5.

**Step 7g — Markdown Viewer**  
Reads file content from `FileEditorService.read(path)`. The `flutter_markdown` widget renders it with a custom dark `MarkdownStyleSheet`. The source/preview toggle is a `bool` in the `MarkdownBloc` state — no complexity beyond toggling a widget.

**Step 7h — JSON Viewer**  
`JsonService.parse(input)` calls `jsonDecode(input)` — standard Dart. On invalid JSON, it returns a `JsonParseError` with position information (from the `FormatException`). The tree view is a recursive widget: `JsonNodeWidget` renders objects, arrays, strings, numbers, booleans, and null nodes with their respective styles. Expand/collapse state is a `Map<String, bool>` stored in the widget's local state (this is the one exception to "no setState" — purely UI expand/collapse state with no business logic).

**Step 7i — Archive Manager**  
`ArchiveService` uses the `archive` Dart package. List operation: `ZipDecoder().decodeBytes(File(path).readAsBytesSync())` and iterate `archive.files`. This is synchronous for small archives; the `ArchiveWorker` isolate handles files >10MB. Create: `ZipEncoder().encode(archive)` where `archive` has files added from device storage paths. Progress tracking uses `Stream.periodic` to estimate progress by bytes processed.

**Step 7j — Clipboard Manager**  
`ClipboardService` wraps both Flutter's `Clipboard.setData/getData` AND the `clipboard_history` SQLite table. Every `ClipboardService.copy(content, source)` call sets the system clipboard AND inserts into SQLite. The history list reads from SQLite directly. Pinned items use `UPDATE clipboard_history SET is_pinned = 1`. The clear button calls both `Clipboard.setData(ClipboardData(text: ''))` and deletes un-pinned rows from SQLite.

**Step 7k — Password Vault**  
`VaultService` initializes by reading the master password hash from `flutter_secure_storage`. The AES-256 key is derived from the master password using PBKDF2: `Pbkdf2(MacAlgorithm: HMAC-SHA256, iterations: 100000, bits: 256)`. Every `createEntry(title, username, password, ...)` encrypts the password field before SQLite insert. Every `getEntry(id)` decrypts after reading. The vault is locked (shows unlock screen) after 5 minutes of inactivity — a `Timer` in `VaultService` resets on each access.

**Step 7l — Process Manager**  
`AppSessionService` maintains the `app_sessions` SQLite table. Every `open <app>` command (or UI tap) calls `AppSessionService.startSession(appName)` which inserts a row with a UUID PID, `started_at = now()`, `status = 'running'`. Every app close calls `AppSessionService.endSession(pid)` which updates `ended_at = now()` and `status = 'stopped'`. The Process Manager screen reads running sessions with `SELECT * FROM app_sessions WHERE status = 'running' ORDER BY started_at DESC`. `proc kill <pid>` updates the row to `status = 'stopped'` AND emits a `CloseAppEvent(appName)` on the `SystemEventBus`.

**Step 7m — Task Scheduler**  
`TaskService` uses a `Timer.periodic(Duration(minutes: 1), _checkDueTasks)` started from `main.dart` (outside the widget tree). `_checkDueTasks` queries `SELECT * FROM tasks WHERE is_enabled = 1 AND next_run_at <= strftime('%s', 'now')`. For each due task, it injects the task's `command` string into the active terminal session via `SystemEventBus.emit(ExecuteCommandEvent(command))`. It then updates `last_run_at`, calculates and updates `next_run_at` based on schedule, and stores the result in `last_result`.

**Step 7n — Workspace Manager**  
`WorkspaceService.captureCurrentState()` reads: current `app_sessions` (running apps), active terminal session CWD, current theme from settings. Serializes to JSON and stores in `workspaces.config`. `WorkspaceService.restoreWorkspace(id)` reads the JSON config, emits `CloseAllAppsEvent` on the bus, waits 500ms, then emits `OpenAppEvent` for each app in the config, sets terminal CWD, and applies the stored theme.

**Step 7o — System Info**  
`SysInfoService.gather()` returns a `SystemInfo` object populated from real device APIs: `DeviceInfoPlugin().androidInfo` for device model, manufacturer, SDK version, brand; `BatteryPlus().batteryLevel` and `batteryState`; `DiskSpace.getFreeDiskSpace` and `getTotalDiskSpace`; `MediaQueryData` for screen resolution and density. There is no hardcoded device information anywhere.

---

## PHASE 4 — STEP 8: DESKTOP MODE IMPLEMENTATION

Desktop mode is the most technically complex feature in Phase 4. It requires a custom window management system built in Flutter.

### Window Manager Architecture

The `DesktopWindowManager` is a `ChangeNotifier` (used only here — not BLoC, because window positions are purely UI state) that maintains a `List<WindowState>`. Each `WindowState` contains: `id` (UUID), `appName`, `position` (Offset), `size` (Size), `isMinimized` (bool), `isMaximized` (bool), `zIndex` (int).

The desktop canvas is a `Stack` with each window as a `Positioned` child. The `Positioned` parameters are set from `WindowState.position` and `WindowState.size`. The `Stack` has `clipBehavior: Clip.hardEdge` to prevent windows from escaping the screen.

### Window Dragging

Each window's title bar is wrapped in a `GestureDetector`. `onPanUpdate` fires during drag: `windowManager.moveWindow(id, details.delta)` updates `position += delta` and calls `notifyListeners()`. The `Stack` rebuilds, moving the `Positioned` widget. Because only the window's `Positioned` wrapper rebuilds (not the app content inside), the app content inside the window does not flicker.

### Window Resizing

Each of the 4 edges and 4 corners of a window has a `GestureDetector` with a specific resize direction. `onPanUpdate` for the right edge: `windowManager.resizeWindow(id, deltaWidth: details.delta.dx)` clamps new width to `[320, screenWidth]`. Bottom edge: `deltaHeight`. Bottom-right corner: both. Top edge: adjusts both `position.dy` and `height` simultaneously (the window appears to resize from the top). This prevents the window from "jumping" on top-edge resize.

### App Rendering Inside Windows

Each app is rendered inside the window body using `Navigator.of(context)` with a separate navigation stack. This means the app's own internal navigation (e.g., File Detail inside Files app) works independently for each window. Each app window gets its own `MultiBlocProvider` with its own BLoC instances — so two File windows can be open simultaneously without state collision.

### Taskbar

The taskbar at the bottom reads from `DesktopWindowManager.windows`. Each button shows the app's icon and name. Clicking a button: if the window is minimized, it restores it (sets `isMinimized = false`, calls `notifyListeners()`). If the window is visible, clicking minimizes it. A subtle `#00E5FF` dot below the button indicates the window is currently visible (not minimized).

### Orientation Detection

Desktop mode activates via the `open desktop` command or by tapping the Launcher tile. Inside desktop mode, the system UI uses `SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])` to force landscape. When the user leaves desktop mode (taps the `Exit Desktop` button in the OS menu), orientation is set back to portrait.

---

## PHASE 4 — STEP 9: NOTIFICATION CENTER + SYSTEM BUS UPGRADE

The `SystemEventBus` gains a `notifications` stream. Every time a long-running operation completes (nmap scan, archive extraction, hash of large file, task execution), the completing service calls `SystemEventBus.notify(SystemNotification(title, body, source))`. The notification is stored in Hive `notification_queue`.

The notification center overlay reads from Hive `notification_queue`. It renders as a sliding panel from the top (same animation style as Android's quick settings). Each notification card is swipeable to dismiss — swipe dismissal calls `NotificationService.dismiss(id)` which removes the Hive entry. "Clear all" calls `NotificationService.clearAll()` which clears the entire Hive box.

---

## PHASE 4 — STEP 10: SEARCH APP — FULL IMPLEMENTATION

The Search app calls `SearchService.search(query, scope)` which runs parallel queries:

Media search queries `media_cache` SQLite: `SELECT * FROM media_cache WHERE name LIKE ? LIMIT 20` for file name search, combined with date/type/size filters if specified.

Notes search uses the `notes_fts` FTS5 virtual table: `SELECT n.* FROM notes n JOIN notes_fts f ON f.rowid = n.id WHERE f MATCH ? AND n.is_deleted = 0`.

Files search queries `file_system_cache` SQLite: `SELECT * FROM file_system_cache WHERE name LIKE ? LIMIT 20`.

Command history search queries `command_history` SQLite: `SELECT DISTINCT command FROM command_history WHERE command LIKE ? LIMIT 10`.

All queries run via `Future.wait([...])` in parallel for speed. Results arrive within 100ms for a 10,000-entry database on a mid-range device.

---

## PHASE 4 — STEP 11: LOG VIEWER APP — FULL IMPLEMENTATION

The Log Viewer uses `LogRepository.watchLogs(filter)` which returns a `Stream<List<SystemLog>>`. The stream is implemented as a polling `Stream.periodic(Duration(seconds: 3), _pollLogs)` where `_pollLogs` runs the filtered query against `system_logs` SQLite. This gives near-real-time updates without requiring SQLite change listeners (which are unavailable on mobile).

The export function reads all filtered logs, formats them as plain text (`[TIMESTAMP] [LEVEL] [SOURCE]: message\n` per line), and writes to a file at `/home/logs/pocketos_export_<timestamp>.txt` using `File.writeAsString`. A terminal line confirms: `"✔ Logs exported to ~/logs/export_<timestamp>.txt"`.

---

## PHASE 4 COMPLETION CRITERIA

Before Phase 5 begins, ALL of the following must be verified:

Every SQLite table exists and is queryable with real data. Every tool command in Part C produces real output (never a placeholder). The package manager installs/removes tools correctly — reinstalling nmap after removing it produces the same functionality. The desktop mode opens, windows drag/resize, and at least 3 apps work simultaneously in windows. Multi-session terminal creates, switches, and closes sessions correctly. All mini apps use their respective SQLite tables for persistence. Notes survive app kill and restart. Vault master password survives app kill and restart. `flutter analyze` shows zero issues. App is tested on Android 8, 10, 13, and verified crash-free in a 30-minute session.

---

# PHASE 5 PRD — FULL OS v1.5 + PLAY STORE PUBLISH

## Overview

Phase 5 is the polish, completion, and publishing phase. The gap between Phase 4 output (functional) and Phase 5 output (publishable) is entirely about quality: every screen must feel finished, every edge case handled, every loading/empty/error state present, performance optimized, and the Play Store listing prepared.

**Estimated Duration:** 7–10 days  
**Target Version:** v1.5.0  
**Prerequisite:** Phase 4 fully complete and verified.

---

## PHASE 5 — STEP 1: LOADING, EMPTY, AND ERROR STATES (ALL SCREENS)

Every screen in PocketOS must have three non-happy-path states. This step goes through every screen and implements them.

**Loading state pattern:** A `ShimmerLoadingWidget` that shows placeholder cards in the same layout as the real content, animating a shimmer gradient from `#111118` to `#1A1A24`. This is built as a reusable widget: `ShimmerCard(width, height, borderRadius)`. It uses `flutter_animate`'s `shimmer()` extension method.

**Empty state pattern:** A centered column with: a terminal-style monospace message (e.g., `"no media found"` in `#444458` JetBrains Mono 14sp), a dim description below it, and if applicable, a cyan chip with a relevant action (e.g., `>_ nmap -a` to trigger a scan). Empty states never show generic "Nothing here" text — they always explain why and what to do.

**Error state pattern:** A centered column with `[ERROR]` in `#FF4444` JetBrains Mono 13sp, the error message in `#8888A0`, and a `Retry` button. The error message comes from the actual exception — no hardcoded error messages.

Screens requiring all three states: Media App, Files App, Stats App, Notes App, Search App, Hash Tool, Log Viewer, Package Manager, Process Manager, Task Scheduler, Workspace Manager, Vault App, Archive Manager. The terminal screen itself has no loading/empty/error states — the terminal is always interactive.

---

## PHASE 5 — STEP 2: COMPLETE SETTINGS SYSTEM

The Settings app is fully implemented in Phase 5. Each setting must actually do something — no setting is a stub.

**Theme switching:** `ThemeService.applyTheme(AppTheme theme)` writes to Hive `settings` box, then calls `SystemEventBus.emit(ThemeChangedEvent(theme))`. The root `MaterialApp` wraps its `theme` property in a `BlocBuilder<ThemeCubit, AppTheme>` so that the entire app re-themes without restart. All 5 themes (Dark, AMOLED, Hacker Green, Cyber Blue, Kali Red) must be tested — every screen must look correct in all themes.

**Wallpaper switching:** `WallpaperService.setWallpaper(WallpaperAsset asset)` writes the selected asset path to Hive `settings`. The Launcher screen reads this and shows the selected wallpaper. The `Set from gallery` option uses `photo_manager` to let the user pick a photo, copies it to `getApplicationDocumentsDirectory()/pocketos/wallpaper.jpg`, and stores that path. The image is displayed with `Image.file(File(path))`.

**Font size:** `TerminalThemeService.setFontSize(double size)` writes to Hive and emits a `TerminalFontSizeChanged` event. Every `TerminalLine` widget reads from a `TerminalThemeCubit` so all open terminal sessions update simultaneously.

**Biometric unlock for vault:** `local_auth` package. The toggle in Settings calls `LocalAuthentication().isDeviceSupported()` — if false, shows a toast `"Biometric authentication not supported on this device"` and the toggle cannot be enabled.

**Auto-clear clipboard:** A `Timer` in `ClipboardService` fires after the configured duration and calls `Clipboard.setData(ClipboardData(text: ''))` plus deletes un-pinned SQLite rows.

**Re-index file system:** Triggers `IndexWorker` isolate. Shows progress in Settings screen as a `LinearProgressIndicator` with count: `"Indexing... 1,234 files indexed"`. On completion: `"✔ File index updated: 45,678 files"`.

**Vacuum database:** Calls `AppDatabase.vacuum()` which runs `PRAGMA VACUUM` on the SQLite database. Before: show file size. After: show new file size. Typical result: 5–20% size reduction.

---

## PHASE 5 — STEP 3: PERFORMANCE OPTIMIZATION

Every performance target from the Complete PRD Part A must be verified with actual measurement.

**App cold start → Launcher target: under 3 seconds.** To achieve this, the splash screen starts the database initialization in parallel rather than sequentially. The boot screen's animation plays while database init continues in the background. The boot sequence lines 7 and 10 (`[OK] Initialized local database`, `[OK] Requested media permissions`) reflect the real completion status.

**nmap scan target: under 2 seconds for 1,000 photos, under 5 seconds for 5,000.** This is achieved by running the `photo_manager.getAssetPathList` call in a background isolate and streaming results to the terminal in batches of 50. The SQLite batch insert uses `db.batch()` rather than individual inserts. Measure actual time using `Stopwatch` in the `NmapTool.execute` method and include the duration in the output: `"Scan completed in 0.8s"`.

**Terminal command response target: under 50ms.** The `CommandDispatcher.dispatch` method is wrapped with a `Stopwatch`. If any command takes over 200ms, it triggers in an isolate instead of the main thread. Built-in commands (clear, history, echo) should respond in under 5ms.

**Memory usage target: under 80MB idle, under 150MB during active scan.** Use Flutter DevTools memory profiler to verify. The main optimization is ensuring the media thumbnail grid uses `photo_manager`'s `ThumbnailData` rather than full-resolution images. Each thumbnail is loaded at 110×110px maximum. The `ListView`/`GridView` builders must use `const` constructors wherever possible.

**APK size target: under 30MB.** After `flutter build apk --release --split-per-abi`, the arm64-v8a APK must be under 30MB. Use `flutter build apk --analyze-size` to identify large assets. All bundled wallpaper assets must be JPEG at 80% quality, maximum 1920×4160px. The `pkg_registry.json` bundled asset should be plain JSON (no minification needed at this scale).

---

## PHASE 5 — STEP 4: COMPLETE UI POLISH

### Glass Components Standardization
Every card, panel, and overlay must use the `GlassContainer` widget. No raw `Container` with hardcoded colors should exist in any screen. Run a search for `Container(color:` and `DecoratedBox` usage and replace all with `GlassContainer` or a themed equivalent.

### Animation completeness
Every screen entry animation must be present. Use `flutter_animate`'s `.fadeIn(duration: 300.ms)` and `.slideY(begin: 0.05, duration: 300.ms)` on the main content column of every screen. Stagger the animation for lists: each list item delays by `50.ms * index` using `AnimateList`. The stats charts animate on entry using `TweenAnimationBuilder<double>` driving the `CustomPainter`'s fill percentage.

### Keyboard and input edge cases
Every text field in the app must handle: very long input (no overflow), empty input (no crash), special characters including emoji (no crash), paste from clipboard. The terminal input field specifically must handle multi-line paste — when the user pastes text containing newlines, each line is treated as a separate command submitted sequentially.

### Dark mode consistency check
Explicitly verify every screen in all 5 themes. Common issues to fix: hardcoded white text that disappears on AMOLED black, hardcoded `#0A0A0F` that looks wrong on Hacker Green theme, status bar icon color (use `SystemChrome.setSystemUIOverlayStyle` in every screen's `initState` to match the screen's theme).

---

## PHASE 5 — STEP 5: ONBOARDING FLOW

First-time users need an onboarding sequence. This runs only on first launch (detected by checking if `settings` Hive box has an `onboardingComplete = true` key).

The onboarding is a 4-screen `PageView` inserted between the boot screen and the launcher:

**Page 1 — Welcome:** `>_  Welcome to PocketOS` centered. Subtitle: `Your personal operating system. Powered by your real data.` Next button.

**Page 2 — Two Interfaces:** Side-by-side: a terminal mockup on the left showing `nmap -p`, an app launcher grid on the right. Text: `Use the terminal like a power user, or tap through apps like a normal user. Same system. Your choice.` 

**Page 3 — Permission Request:** The permission explanation screen content (from Screen 34 in the Complete PRD) embedded here. The actual `requestMediaPermission()` call fires from this page. If granted: brief success animation, continue. If denied: shows limited mode warning, continue.

**Page 4 — Start:** Full cyan background with `PocketOS` in inverse color. `You're ready.` button → sets `onboardingComplete = true` in Hive → navigates to launcher.

---

## PHASE 5 — STEP 6: ADVANCED NMAP FEATURES + SCAN PROFILES

**Scan profiles:** `ScanProfileService` reads/writes from `scan_profiles` SQLite. The terminal command `nmap --save-profile "My Photos 2026"` saves the current flags as a profile. `nmap --load-profile "My Photos 2026"` loads and applies them. `nmap --profiles` lists all saved profiles. The Package Manager UI screen gains a "Profiles" tab in the Media app showing saved scan configurations as cards.

**Media timeline view:** The Media app gains a "Timeline" tab. The query is: `SELECT date(created_at, 'unixepoch') as day, COUNT(*) as count FROM media_cache WHERE media_type = 'photo' GROUP BY day ORDER BY day DESC`. This produces a day-by-day count. Rendered as a `SliverList` with section headers for each month (`"April 2026 (48 photos)"`), then a 3-column thumbnail grid for that month's photos using lazy loading.

**Stats v2 — Photo frequency heatmap:** The query `SELECT strftime('%w', datetime(created_at, 'unixepoch')) as dow, COUNT(*) as cnt FROM media_cache WHERE media_type = 'photo' GROUP BY dow` gives a day-of-week breakdown. Rendered as 7 horizontal bars in the Stats app showing which days the user takes the most photos. Real data, real insight.

---

## PHASE 5 — STEP 7: APP DRAWER IMPLEMENTATION

The App Drawer is a full-screen overlay triggered by swiping left from the launcher. It is implemented as a `showGeneralDialog` with a slide-in animation from the right.

The app list reads from: built-in apps (hardcoded in `AppRegistry`) plus installed tools from SQLite `installed_tools`. These are merged, sorted alphabetically, and grouped by first letter. The A-Z index on the right uses a `GestureDetector` over a `Column` of letter indicators — drag detection maps the drag position to a letter and calls `scrollController.scrollTo(index: indexOfLetter(letter))`.

---

## PHASE 5 — STEP 8: KEYBOARD SHORTCUTS (PHYSICAL KEYBOARD SUPPORT)

For users with Bluetooth keyboards or in desktop mode, PocketOS supports physical keyboard shortcuts:

The root `MaterialApp`'s `FocusManager` is configured to route keyboard events. A `RawKeyboardListener` at the root app level intercepts shortcuts and emits them on the `SystemEventBus`. Terminal shortcuts are handled by the terminal's own `RawKeyboardListener`:

`Ctrl+C` cancels the running tool (sets `TerminalBloc` to idle state, disposes tool stream subscription). `Ctrl+L` calls `ClearTerminal` event. `Ctrl+T` creates a new terminal tab. `Ctrl+W` closes the current tab. `Ctrl+Tab` cycles to the next tab. `↑` / `↓` navigate command history. `Tab` triggers auto-complete.

In desktop mode, `Ctrl+Alt+T` opens a new terminal window. `Alt+F4` closes the focused window. `Super` key (Meta) shows all windows (Mission Control view).

---

## PHASE 5 — STEP 9: PLAY STORE RELEASE PREPARATION

### Release Build Configuration

`android/app/build.gradle` must be fully configured for release:
- `applicationId "com.pocketos.pro"` confirmed
- `minSdkVersion 26` (Android 8.0)
- `targetSdkVersion 34` (Android 14 — current target)
- `compileSdkVersion 34`
- `versionCode 150` (v1.5.0 = 150)
- `versionName "1.5.0"`
- ProGuard rules for sqflite, hive, encrypt packages

`flutter build apk --release --split-per-abi` produces 3 APKs (armeabi-v7a, arm64-v8a, x86_64). The AAB `flutter build appbundle --release` is the primary Play Store submission format.

**Release signing:** A keystore must be created and referenced in `build.gradle` via `signingConfigs`. The keystore file path and passwords must be stored in a local `key.properties` file that is `.gitignore`d.

### ProGuard Rules

```
# sqflite
-keep class io.flutter.plugins.** { *; }

# hive  
-keep class com.pocketos.** { *; }

# encrypt
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# mobile_scanner
-keep class com.google.zxing.** { *; }
```

### AndroidManifest.xml Final State

```xml
<manifest>
  <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
  <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
      android:maxSdkVersion="32"/>
  <uses-permission android:name="android.permission.CAMERA"/>
  <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
  <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
  <uses-permission android:name="android.permission.VIBRATE"/>

  <application
    android:label="PocketOS"
    android:icon="@mipmap/ic_launcher"
    android:roundIcon="@mipmap/ic_launcher_round"
    android:requestLegacyExternalStorage="false"
    android:allowBackup="false">
    
    <activity
      android:name=".MainActivity"
      android:exported="true"
      android:screenOrientation="sensor">
      <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
      </intent-filter>
    </activity>
  </application>
</manifest>
```

Note: `android:screenOrientation="sensor"` allows portrait (phone mode) and landscape (desktop mode) both. The orientation lock is enforced programmatically per-screen.

### Play Store Listing Requirements

**App name:** PocketOS — Personal Mobile OS  
**Short description (80 chars):** `A real personal OS. Terminal + GUI. Scan, manage, and control your data.`  
**Full description:** 4,000 character max. Must include: what PocketOS is, who it is for, key features list, privacy statement (no internet, no tracking), tool list, terminal command examples.

**Screenshots required (phone):** 5 minimum. Suggested: (1) Boot screen, (2) Launcher with all apps, (3) Terminal running nmap scan, (4) Media app with photo grid, (5) Desktop mode with 2 windows open.

**Feature graphic:** 1024×500px — the Boot Sequence wallpaper cropped to 16:9 with `PocketOS v1.5` text overlaid.

**Category:** Tools  
**Content rating:** Everyone  
**Privacy policy URL required:** Must be hosted somewhere (even a static GitHub Pages page works).

---

## PHASE 5 — STEP 10: FINAL QA CHECKLIST

Before submitting to Play Store, every item on this checklist must be confirmed:

**Functionality:** Every command in Part C of the Complete PRD executes and produces real output on a physical device. The package manager installs and removes tools correctly. Desktop mode opens and shows 3 apps in windows simultaneously. The vault unlock works after app kill/restart. Tasks execute on schedule. Workspaces save and restore correctly.

**Data integrity:** Kill the app while a note is being auto-saved. Reopen — the note is intact or shows the last auto-save point. Kill the app during an nmap scan. Reopen — the media cache shows the partial scan results (not corrupted). Kill the app during archive extraction. Reopen — no crash, partial extraction is visible.

**Performance:** Cold start under 3 seconds on a 3-year-old mid-range device. nmap scan of 1,000 photos under 2 seconds. No ANR (Application Not Responding) dialog in any scenario. No visible frame drops during terminal output animation.

**Device compatibility:** Tested on Android 8.0 (API 26), Android 10 (API 29), Android 12 (API 31), Android 13 (API 33), Android 14 (API 34). Media permissions work correctly on each SDK version. The permission code uses SDK version branching: API 33+ uses `READ_MEDIA_IMAGES` and `READ_MEDIA_VIDEO`; API 32 and below uses `READ_EXTERNAL_STORAGE`.

**Crashlytics-free verification:** The release build does not contain Firebase, Crashlytics, or any analytics SDK. Confirm with `apkanalyzer dex packages --defined-only app-release.apk | grep -i firebase` — must return nothing.

**Security:** The vault master password cannot be extracted from the APK (it is in `flutter_secure_storage`, backed by Android Keystore on Android 6+). The vault passwords in SQLite are AES-256 encrypted — a SQLite browser viewing the database cannot see plain-text passwords. The terminal command history does not store passwords entered via `pass new` interactive mode (that input mode uses a masked field and the command is stored as `pass new [masked]`).

**APK size:** `flutter build appbundle --release` + Play Store auto-splitting produces under 30MB for arm64-v8a. Verify with Play Console's APK analyzer after first upload.

---

## PHASE 5 COMPLETION = v1.5 PUBLISHED

After every item on the Phase 5 QA checklist is confirmed, the AAB is uploaded to Play Store internal testing, then closed testing with 20 testers, then open testing for 2 weeks, then production release.

**v1.5.0 — PocketOS Pro is live.**

The OS is now a real, publishable product. Power users have a genuine terminal-driven personal data OS. Normal users have a premium dark-themed app suite. Students have an educational OS to learn from. The foundation is set for v2.0 where the real backend, network tools, and 600+ tool ecosystem begins.

---

*End of Phase 4 + Phase 5 PRD — PocketOS Pro v1.5*
