# PocketOS Pro — COMPLETE v1.5 PRD
## Missing Sections + Full OS Specification
### "A Real Personal Operating System — For Everyone. Powered by Real Data. Zero Mocks."

**Document Version:** 2.0  
**Covers:** All missing PRD gaps + v1.5 complete feature set  
**Build Order Rule:** LOCAL BACKEND FIRST → then every frontend screen  
**Non-negotiable:** No mock data. No placeholder. No fake output. Every screen reads from real local database or real device API.

---

## PART A — LOCAL BACKEND & DATABASE ARCHITECTURE
### ⚠️ BUILD THIS ENTIRE SECTION BEFORE WRITING A SINGLE WIDGET

The "local backend" of PocketOS is a structured, multi-layer data engine running entirely on-device. It behaves like a real server — with services, repositories, background workers, and a relational database — but everything executes locally in the Flutter process and its background isolates.

---

### A.1 Database Strategy Overview

PocketOS uses two complementary storage systems working together:

**sqflite** is the primary relational database engine, storing all structured, queryable data. Think of it as the PostgreSQL of PocketOS — it handles complex queries, joins, indexes, and transactions. Every tool result, every scanned file, every note, every installed package, every session lives here.

**Hive** handles fast key-value access for settings, command history, system logs, and any data that needs sub-millisecond reads without SQL overhead. Think of it as Redis sitting alongside the PostgreSQL.

**Flutter Isolates** serve as the background service layer — long-running workers that handle file scanning, duplicate detection, hash computation, and archive operations without blocking the UI thread.

---

### A.2 SQLite Database Schema (Complete)

**Database file:** `pocketos_main.db`  
**Location:** `getApplicationDocumentsDirectory()/pocketos/`  
**Version:** 1 (migration system built from day one)

```sql
-- ============================================
-- TABLE: installed_tools
-- Tracks every tool installed via pkg manager
-- ============================================
CREATE TABLE installed_tools (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  name         TEXT NOT NULL UNIQUE,
  version      TEXT NOT NULL,
  description  TEXT NOT NULL,
  author       TEXT DEFAULT 'PocketOS Team',
  installed_at INTEGER NOT NULL,   -- Unix timestamp
  updated_at   INTEGER,
  size_bytes   INTEGER DEFAULT 0,
  is_enabled   INTEGER DEFAULT 1,  -- 0=disabled, 1=enabled
  metadata     TEXT                -- JSON blob for extra data
);

-- ============================================
-- TABLE: media_cache
-- Scanned device media metadata cache
-- ============================================
CREATE TABLE media_cache (
  id             TEXT PRIMARY KEY,  -- photo_manager asset ID
  name           TEXT NOT NULL,
  path           TEXT,
  size_bytes     INTEGER NOT NULL,
  media_type     TEXT NOT NULL,     -- 'photo' | 'video' | 'audio'
  mime_type      TEXT,
  width          INTEGER,
  height         INTEGER,
  duration_ms    INTEGER,           -- for video/audio
  created_at     INTEGER NOT NULL,  -- Unix timestamp from EXIF/metadata
  modified_at    INTEGER NOT NULL,
  scan_date      INTEGER NOT NULL,  -- when PocketOS scanned it
  is_duplicate   INTEGER DEFAULT 0,
  duplicate_of   TEXT,              -- FK to media_cache.id
  hash_md5       TEXT,
  album_name     TEXT,
  latitude       REAL,
  longitude      REAL
);
CREATE INDEX idx_media_created ON media_cache(created_at);
CREATE INDEX idx_media_type ON media_cache(media_type);
CREATE INDEX idx_media_size ON media_cache(size_bytes);

-- ============================================
-- TABLE: notes
-- User notes created in Notes app or terminal
-- ============================================
CREATE TABLE notes (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  title      TEXT NOT NULL,
  content    TEXT NOT NULL DEFAULT '',
  tags       TEXT DEFAULT '',       -- comma-separated tags
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  is_pinned  INTEGER DEFAULT 0,
  is_deleted INTEGER DEFAULT 0,     -- soft delete
  color      TEXT DEFAULT '#1A1A24' -- hex background color
);
CREATE INDEX idx_notes_tags ON notes(tags);
CREATE VIRTUAL TABLE notes_fts USING fts5(title, content, content='notes', content_rowid='id');

-- ============================================
-- TABLE: terminal_sessions
-- Each terminal tab/session with its own history
-- ============================================
CREATE TABLE terminal_sessions (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  name         TEXT NOT NULL DEFAULT 'Terminal',
  created_at   INTEGER NOT NULL,
  last_used_at INTEGER NOT NULL,
  cwd          TEXT DEFAULT '/home',  -- current working directory
  env_vars     TEXT DEFAULT '{}',     -- JSON environment variables
  is_active    INTEGER DEFAULT 1
);

-- ============================================
-- TABLE: command_history
-- Per-session command history
-- ============================================
CREATE TABLE command_history (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id  INTEGER NOT NULL,
  command     TEXT NOT NULL,
  exit_code   INTEGER DEFAULT 0,
  executed_at INTEGER NOT NULL,
  duration_ms INTEGER DEFAULT 0,
  FOREIGN KEY (session_id) REFERENCES terminal_sessions(id) ON DELETE CASCADE
);
CREATE INDEX idx_cmd_session ON command_history(session_id);

-- ============================================
-- TABLE: system_logs
-- All OS-level events and tool executions
-- ============================================
CREATE TABLE system_logs (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp  INTEGER NOT NULL,
  level      TEXT NOT NULL,    -- 'INFO'|'WARN'|'ERROR'|'DEBUG'|'SYSTEM'
  source     TEXT NOT NULL,    -- 'kernel'|'nmap'|'fs'|'launcher'|etc.
  message    TEXT NOT NULL,
  data       TEXT              -- optional JSON payload
);
CREATE INDEX idx_logs_time ON system_logs(timestamp DESC);
CREATE INDEX idx_logs_level ON system_logs(level);

-- ============================================
-- TABLE: file_system_cache
-- Virtual + real file system index
-- ============================================
CREATE TABLE file_system_cache (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  path         TEXT NOT NULL UNIQUE,
  name         TEXT NOT NULL,
  parent_path  TEXT,
  node_type    TEXT NOT NULL,   -- 'file' | 'directory' | 'virtual'
  size_bytes   INTEGER DEFAULT 0,
  mime_type    TEXT,
  created_at   INTEGER,
  modified_at  INTEGER,
  permissions  TEXT DEFAULT 'rw-r--r--',
  is_hidden    INTEGER DEFAULT 0,
  is_virtual   INTEGER DEFAULT 0, -- 1 = PocketOS virtual node
  metadata     TEXT
);
CREATE INDEX idx_fs_parent ON file_system_cache(parent_path);

-- ============================================
-- TABLE: tasks
-- Task scheduler — scheduled and recurring tasks
-- ============================================
CREATE TABLE tasks (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  name         TEXT NOT NULL,
  description  TEXT,
  command      TEXT NOT NULL,   -- terminal command to execute
  schedule     TEXT,            -- cron-like: 'daily'|'weekly'|'once'|'interval:60'
  next_run_at  INTEGER,
  last_run_at  INTEGER,
  last_result  TEXT,
  is_enabled   INTEGER DEFAULT 1,
  created_at   INTEGER NOT NULL
);

-- ============================================
-- TABLE: workspaces
-- Named workspace configurations
-- ============================================
CREATE TABLE workspaces (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT NOT NULL,
  description TEXT,
  icon        TEXT DEFAULT '>_',
  config      TEXT NOT NULL,    -- JSON: open apps, terminal state, layout
  created_at  INTEGER NOT NULL,
  updated_at  INTEGER NOT NULL,
  is_default  INTEGER DEFAULT 0
);

-- ============================================
-- TABLE: clipboard_history
-- Clipboard manager entries
-- ============================================
CREATE TABLE clipboard_history (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  content     TEXT NOT NULL,
  content_type TEXT DEFAULT 'text',  -- 'text'|'command'|'path'
  source      TEXT,                  -- which app/tool created it
  created_at  INTEGER NOT NULL,
  is_pinned   INTEGER DEFAULT 0
);

-- ============================================
-- TABLE: hash_results
-- Saved hash computations
-- ============================================
CREATE TABLE hash_results (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  file_path   TEXT,
  input_text  TEXT,
  algorithm   TEXT NOT NULL,   -- 'md5'|'sha1'|'sha256'|'sha512'
  result      TEXT NOT NULL,
  computed_at INTEGER NOT NULL
);

-- ============================================
-- TABLE: calculator_history
-- Calculator expression history
-- ============================================
CREATE TABLE calculator_history (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  expression  TEXT NOT NULL,
  result      TEXT NOT NULL,
  computed_at INTEGER NOT NULL
);

-- ============================================
-- TABLE: app_sessions
-- Records of all opened apps (for process manager)
-- ============================================
CREATE TABLE app_sessions (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  app_name    TEXT NOT NULL,
  started_at  INTEGER NOT NULL,
  ended_at    INTEGER,
  pid         TEXT NOT NULL,  -- UUID simulating process ID
  memory_kb   INTEGER DEFAULT 0,
  status      TEXT DEFAULT 'running'  -- 'running'|'stopped'|'crashed'
);

-- ============================================
-- TABLE: password_vault
-- Local encrypted password store
-- ============================================
CREATE TABLE password_vault (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  title       TEXT NOT NULL,
  username    TEXT,
  password    TEXT NOT NULL,  -- AES-256 encrypted
  url         TEXT,
  notes       TEXT,
  category    TEXT DEFAULT 'general',
  created_at  INTEGER NOT NULL,
  updated_at  INTEGER NOT NULL,
  is_deleted  INTEGER DEFAULT 0
);

-- ============================================
-- TABLE: scan_profiles
-- Saved nmap scan configurations
-- ============================================
CREATE TABLE scan_profiles (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT NOT NULL,
  flags       TEXT NOT NULL,  -- JSON array of flags
  description TEXT,
  last_used   INTEGER,
  created_at  INTEGER NOT NULL
);
```

---

### A.3 Hive Boxes (Key-Value Layer)

Every Hive box has a defined purpose. No box is used for data that belongs in SQLite.

```dart
// Box: 'settings'          — AppSettings model (single object)
// Box: 'theme_prefs'       — ThemePreferences model
// Box: 'terminal_env'      — Map<String, String> environment variables
// Box: 'pkg_registry'      — Map<String, ToolManifest> available tools
// Box: 'fs_bookmarks'      — List<String> bookmarked paths
// Box: 'recent_files'      — List<RecentFile> last 20 accessed files
// Box: 'scan_cache_meta'   — ScanCacheMeta: last scan timestamp + counts
// Box: 'notification_queue'— List<SystemNotification>
// Box: 'qr_history'        — List<QrEntry> recent QR codes
// Box: 'encode_history'    — List<EncodeEntry>
// Box: 'unit_conv_history' — List<ConversionEntry>
```

---

### A.4 Service Layer Architecture

The service layer sits between repositories and BLoCs. Each service is a Dart class registered as a singleton via `get_it`. Services never touch UI code.

```
┌─────────────────────────────────────────────────────────────┐
│                       SERVICE LAYER                          │
├──────────────┬──────────────┬──────────────┬────────────────┤
│ MediaService │  FsService   │  PkgService  │  ToolService   │
│              │              │              │                │
│ .scan()      │ .ls()        │ .install()   │ .execute()     │
│ .filter()    │ .cd()        │ .remove()    │ .validate()    │
│ .getStats()  │ .info()      │ .list()      │ .getHelp()     │
│ .detectDups()│ .du()        │ .update()    │                │
├──────────────┼──────────────┼──────────────┼────────────────┤
│ NoteService  │ TaskService  │ LogService   │  VaultService  │
│ SessionSvc   │ ClipService  │ HashService  │  WorkspaceSvc  │
└──────────────┴──────────────┴──────────────┴────────────────┘
         ↓              ↓              ↓
┌─────────────────────────────────────────────────────────────┐
│                    REPOSITORY LAYER                          │
│  SQLite repos (sqflite) + Hive repos (hive_flutter)         │
└─────────────────────────────────────────────────────────────┘
         ↓              ↓              ↓
┌─────────────────────────────────────────────────────────────┐
│              DEVICE APIs + LOCAL STORAGE                     │
│  photo_manager | path_provider | file | sqflite | hive      │
└─────────────────────────────────────────────────────────────┘
```

---

### A.5 Background Isolate Workers

Heavy operations run in Flutter isolates to prevent any UI jank. The following operations MUST use isolates:

```dart
// lib/core/workers/

// MediaScanWorker — scans all device media, writes to SQLite
class MediaScanWorker {
  // Receives: ScanConfig
  // Executes: photo_manager.getAssetPathList() → parse metadata → batch insert to SQLite
  // Sends back: Stream<ScanProgress>
  // On complete: signals ScanComplete with summary
}

// DuplicateDetectWorker — finds duplicate files
class DuplicateDetectWorker {
  // Reads: media_cache from SQLite
  // Groups by: size_bytes → then compares names
  // Writes: is_duplicate flag back to SQLite
  // Sends back: Stream<int> progress
}

// HashWorker — computes file hashes
class HashWorker {
  // Reads: file bytes in chunks
  // Computes: MD5 | SHA1 | SHA256 | SHA512
  // Writes: to hash_results table
}

// ArchiveWorker — zip/unzip operations
class ArchiveWorker {
  // Uses: archive package
  // Runs compression in background
  // Reports: progress percentage
}

// IndexWorker — builds file system index
class IndexWorker {
  // Walks: device storage directories
  // Writes: file_system_cache table
  // Reports: files indexed count
}
```

---

### A.6 Dependency Injection (get_it)

```dart
// lib/core/di/service_locator.dart

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // 1. Database
  sl.registerSingletonAsync<AppDatabase>(() async {
    final db = AppDatabase();
    await db.initialize();
    return db;
  });
  
  // 2. Hive boxes
  sl.registerSingletonAsync<SettingsBox>(() async => SettingsBox()..open());
  
  // 3. Repositories
  sl.registerLazySingleton<MediaRepository>(() => MediaRepositoryImpl(sl()));
  sl.registerLazySingleton<NoteRepository>(() => NoteRepositoryImpl(sl()));
  sl.registerLazySingleton<LogRepository>(() => LogRepositoryImpl(sl()));
  sl.registerLazySingleton<FsRepository>(() => FsRepositoryImpl(sl()));
  sl.registerLazySingleton<PkgRepository>(() => PkgRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<VaultRepository>(() => VaultRepositoryImpl(sl()));
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));
  sl.registerLazySingleton<WorkspaceRepository>(() => WorkspaceRepositoryImpl(sl()));
  sl.registerLazySingleton<ClipboardRepository>(() => ClipboardRepositoryImpl(sl()));
  
  // 4. Services
  sl.registerLazySingleton<MediaService>(() => MediaService(sl()));
  sl.registerLazySingleton<FsService>(() => FsService(sl()));
  sl.registerLazySingleton<PkgService>(() => PkgService(sl(), sl()));
  sl.registerLazySingleton<ToolRegistry>(() => ToolRegistry(sl()));
  sl.registerLazySingleton<LogService>(() => LogService(sl()));
  sl.registerLazySingleton<NoteService>(() => NoteService(sl()));
  sl.registerLazySingleton<VaultService>(() => VaultService(sl()));
  sl.registerLazySingleton<TaskService>(() => TaskService(sl()));
  sl.registerLazySingleton<ClipboardService>(() => ClipboardService(sl()));
  sl.registerLazySingleton<HashService>(() => HashService(sl()));
  sl.registerLazySingleton<WorkspaceService>(() => WorkspaceService(sl()));
  
  // 5. Kernel
  sl.registerLazySingleton<CommandParser>(() => CommandParser());
  sl.registerLazySingleton<CommandDispatcher>(() => CommandDispatcher(sl()));
  sl.registerLazySingleton<SystemEventBus>(() => SystemEventBus());
  sl.registerLazySingleton<KernelService>(() => KernelService(sl(), sl(), sl()));
}
```

---

### A.7 Database Migration System

```dart
// lib/core/database/app_database.dart

class AppDatabase {
  static const int _currentVersion = 1;
  late Database _db;

  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'pocketos', 'pocketos_main.db');
    await Directory(dirname(path)).create(recursive: true);
    
    _db = await openDatabase(
      path,
      version: _currentVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    // Execute ALL CREATE TABLE statements from schema above
    // + CREATE INDEX statements
    // + INSERT default data (default workspace, default tools registry)
    await batch.commit();
    await _seedDefaultData(db);
  }

  Future<void> _seedDefaultData(Database db) async {
    // Seed: default workspace "Main"
    // Seed: built-in tools in installed_tools (nmap, fs, stats — pre-installed)
    // Seed: default terminal session
    // Seed: welcome note
  }
}
```

---

### A.8 Approved Additional Dependencies (v1.5)

```yaml
# Add to existing Phase 2 dependencies:

  # Database
  sqflite: ^2.3.2
  sqflite_migration_service: ^1.0.3

  # Dependency Injection
  get_it: ^7.6.7

  # Encryption (for vault)
  encrypt: ^5.0.3
  flutter_secure_storage: ^9.0.0

  # Hashing
  crypto: ^3.0.3

  # Archive/ZIP
  archive: ^3.4.10

  # QR Code
  qr_flutter: ^4.1.0
  mobile_scanner: ^4.0.0

  # Markdown rendering
  flutter_markdown: ^0.6.18

  # Connectivity (local only — for future)
  connectivity_plus: ^5.0.2

  # Device info (for uname command)
  device_info_plus: ^9.1.1

  # Battery info
  battery_plus: ^5.0.3

  # Sensors/Storage info
  disk_space: ^1.0.2

  # Url launcher (for help docs)
  url_launcher: ^6.2.4

  # Path manipulation
  path: ^1.9.0

  # UUID generation (for PIDs)
  uuid: ^4.3.3

  # Charts (for Stats app)
  fl_chart: ^0.66.0

  # Animations
  flutter_animate: ^4.5.0
  lottie: ^3.0.0

  # Scroll physics
  scrollable_positioned_list: ^0.3.8
```

---

## PART B — COMPLETE SCREEN CATALOG & UI SPECIFICATIONS

### Navigation Rule
Every screen is reachable either via the terminal (`open <appname>`) or via the graphical launcher tap. No screen is terminal-only or UI-only — both interfaces must reach every feature.

---

### SCREEN 01 — Splash Screen

**Route:** `/`  
**Duration:** 1.5 seconds, no user input  
**Purpose:** Brand entry point

**Visual Layout:**
The screen is pure `#0A0A0F` background with zero padding. Dead center sits the PocketOS logotype — the `>_` terminal symbol (72sp, JetBrains Mono Bold) rendered in `#00E5FF` with a three-layer neon bloom glow (tight core 6px blur, mid 18px blur, outer halo 40px blur). Below the symbol, `POCKETOS` in Rajdhani ExtraBold 16sp with 0.3em letter-spacing, color `#8888A0`. Below that, a 1px wide horizontal line of `#00E5FF` at 30% opacity, 48px wide, that pulses opacity from 30% to 80% on a 1-second loop. There are no other elements.

**Animation Sequence:**
The entire center group fades in from opacity 0 to 1 over 600ms with a simultaneous scale from 0.85 to 1.0 (ease-out curve). At 1,200ms the group fades back out over 300ms. Navigation to `/boot` happens at exactly 1,500ms.

**BLoC:** `SplashBloc` — single event `SplashStarted`, single non-idle state `SplashComplete` triggering navigation.

**Edge Cases:** If app is re-opened while already running (process not killed), splash is skipped — navigate directly to `/launcher`.

---

### SCREEN 02 — Boot Screen

**Route:** `/boot`  
**Duration:** ~3.5 seconds  
**Purpose:** OS initialization feel — the most important screen for OS authenticity

**Visual Layout:**
Full dark background (`#070710`). Top-left: a subtle scanline texture overlay (horizontal lines 1px height, 2px gap, `#FFFFFF` at 2% opacity). No navigation bars, no status bars — full immersive.

Content is a single `Column` left-aligned with `EdgeInsets.only(left: 24, top: 72)`. Each boot line is rendered in JetBrains Mono 13sp.

**Boot Sequence Lines (exact text, exact timing):**
```
Line 1:  "PocketOS v1.5 — Personal Mobile Operating System"   [white, t=0ms]
Line 2:  ""                                                     [blank, t=200ms]
Line 3:  "Initializing kernel services..."                     [dim, t=400ms]
Line 4:  "  [  OK  ] Loaded kernel modules"                    [green [OK], t=700ms]
Line 5:  "  [  OK  ] Started command dispatcher"               [green [OK], t=950ms]
Line 6:  "  [  OK  ] Mounted virtual file system"              [green [OK], t=1150ms]
Line 7:  "  [  OK  ] Initialized local database"               [green [OK], t=1350ms]
Line 8:  "  [  OK  ] Loaded tool registry (5 tools)"          [green [OK], t=1550ms]
Line 9:  "  [  OK  ] Started background service workers"       [green [OK], t=1750ms]
Line 10: "  [  OK  ] Requested media permissions"              [green [OK], t=2050ms]
Line 11: "  [  OK  ] Indexed file system"                      [green [OK], t=2300ms]
Line 12: "  [  OK  ] Started launcher"                         [green [OK], t=2500ms]
Line 13: ""                                                     [blank, t=2700ms]
Line 14: "PocketOS ready."                                      [cyan bold, t=2900ms]
Line 15: "Welcome back, user."                                  [dim white, t=3100ms]
```

Each `[  OK  ]` is rendered with `#00FF88` color. If a step genuinely fails (e.g., permission denied), line shows `[ WARN ]` in `#FFD700` with the actual reason. There is no fake status — Line 10 actually calls `PermissionService.hasMediaPermission()` and reflects the real result.

After Line 15 renders, a 400ms pause, then a smooth fade transition to `/launcher`.

**BLoC:** `BootBloc` with states `BootRunning(int step, List<BootLine> lines)` and `BootComplete`. The bloc truly runs `PermissionService.hasMediaPermission()` and `AppDatabase.isReady()` during lines 10 and 7.

---

### SCREEN 03 — Launcher (Home Screen)

**Route:** `/launcher`  
**Purpose:** Main OS home screen — the Android-style graphical entry to all apps

**Visual Layout — Top to Bottom:**

**Status Bar (height: 36px):**
Background `#0D0D14`, border-bottom 1px `#2A2A38`. Left side shows `user@pocketos` in JetBrains Mono 11sp `#00E5FF`. Center shows current time in `HH:mm` format, JetBrains Mono 13sp `#E8E8F0`. Right side shows battery icon + percentage (real via battery_plus), storage used percentage, and a cyan dot indicating all services running.

**Wallpaper Area:**
Behind the app grid sits the default wallpaper (bundled asset — the Boot Sequence wallpaper). There is a `BackdropFilter(ImageFilter.blur(sigmaX: 0, sigmaY: 0))` that can be increased when an app icon is long-pressed (frosted glass effect on long-press).

**Quick Stats Bar (height: 48px, below status bar):**
A horizontal row of 4 mini-stats chips, each a glass card: `📷 2,340 photos`, `🎬 187 videos`, `💾 69% used`, `⚡ 5 processes`. These are read in real-time from the SQLite cache. Tapping a chip navigates to the relevant app.

**App Grid:**
A responsive grid with 3 columns. Each app tile is a `GlassTile` widget (80px × 96px total including label). The icon area is 64px × 64px with a rounded-rect border (`#2A2A38` 1px, borderRadius 16px), semi-transparent dark fill (`#111118` at 85%), and the icon SVG/emoji centered at 28px. Below the icon, the app name in Inter 10sp `#8888A0`.

**Active/installed apps glow:** When an app is running (exists in `app_sessions` table with status=running), its tile border glows `#00E5FF` at 40% opacity with a 2px border width increase.

**Locked/installable apps:** Apps not yet installed are shown with a 40% opacity tile and a lock icon overlay. Tapping shows a toast: `"Run: pkg install <name> to unlock"`.

**App Grid — Complete App List:**

Row 1: Terminal · Files · Media  
Row 2: Stats · Notes · Package Manager  
Row 3: Search · Hash Tool · Encode/Decode  
Row 4: QR Tool · Calculator · Timer  
Row 5: Text Editor · Markdown Viewer · JSON Viewer  
Row 6: Archive Manager · Clipboard · Password Vault  
Row 7: Process Manager · Task Scheduler · Workspace Manager  
Row 8: System Info · Log Viewer · Diff Tool  
Row 9: Color Tool · Unit Converter · Settings  
Row 10: Desktop Mode (landscape) · [future slot] · [future slot]

**Dock (Bottom bar, height: 64px):**
Background `#0D0D14` with top border 1px `#2A2A38`. Contains 4 permanent shortcuts: Terminal (`>_`), Package Manager (`pkg`), Files (`fs`), Settings (`⚙`). Center of dock is a large FAB (52px diameter, `#00E5FF` background, `#0A0A0F` `>_` icon) that opens the terminal screen with a slide-up animation.

**Swipe Gestures:**
- Swipe left on launcher → App Drawer (alphabetical full list)
- Swipe up from bottom edge → opens recent apps / process manager
- Swipe down from status bar → opens Notification Center

**BLoC:** `LauncherBloc` reads `installed_tools` + `app_sessions` from SQLite and emits `LauncherLoaded(List<AppTile> tiles, List<QuickStat> stats)`. Subscribes to `SystemEventBus` for real-time status updates.

---

### SCREEN 04 — Terminal Screen

**Route:** `/terminal`  
**Purpose:** The core power-user interface — full bash-style terminal

**Visual Layout:**

**Terminal Header (height: 44px):**
Background `#070710`, no elevation. Left: three macOS-style dots (red `#FF5F57`, yellow `#FEBC2E`, green `#28C840`) at 12px diameter each. Center: `user@pocketos — bash` in JetBrains Mono 12sp `#8888A0`. Right: `+` icon (new tab), `⊞` icon (split view — Phase 4), `↗` icon (fullscreen).

**Tab Bar (height: 32px, visible when >1 tab):**
Horizontal scrollable row of session tabs. Each tab shows the session name (default: `bash`) in JetBrains Mono 11sp. Active tab has a 2px `#00E5FF` bottom border. Long-press to rename session. Swipe-close to kill session. Maximum 5 sessions.

**Output Area (flex: 1):**
A `CustomScrollView` with `SliverList` for terminal lines. Background `#070710`. Left padding 12px, right padding 12px. The list auto-scrolls to bottom when new output arrives. User can scroll up to review history — the auto-scroll pauses when user scrolls up, resumes when they scroll back to bottom.

Each output line is a `TerminalLine` widget (height: auto, min: 18px). Lines are typed character-by-character when `animated: true` (boot messages, tool output headers), or appear instantly when `animated: false` (fast query results). Lines that are very long wrap at screen width.

**Prompt Line (when idle):**
The current prompt string (`user@pocketos:~$`) in JetBrains Mono 13sp, color `#00FF88`. After the prompt, a blinking block cursor (`█`) in `#00E5FF`, blink period 800ms. When user begins typing, the cursor moves with the text.

**Input Row (height: 48px, bottom):**
Background `#0D0D14`, top border 1px `#1A1A24`. Left icon `>` in `#00FF88`. `TextField` with no decoration, JetBrains Mono 13sp, `#E8E8F0` text, no autocorrect, no autocapitalization. Right: send button (arrow icon) `#00E5FF`.

**Auto-complete Popup:**
When user presses Tab or types a partial command, a floating panel appears above the input row showing up to 5 matching completions. Dark glass background, each completion in JetBrains Mono 12sp, highlighted matching portion in `#00E5FF`. Arrow keys or tap to select.

**Terminal Color Codes (exact):**

| Output Type | Color | Usage |
|-------------|-------|-------|
| `system` | `#E8E8F0` | Normal output |
| `success` | `#00FF88` | ✔ confirmations |
| `error` | `#FF4444` | Error messages |
| `warning` | `#FFD700` | Warnings |
| `info` | `#4488FF` | Informational |
| `command` | `#555568` | Echoed input |
| `progress` | `#00E5FF` | Progress bars/scanning |
| `header` | `#00E5FF` bold | Section headers |
| `prompt` | `#00FF88` | The prompt string |
| `dim` | `#444458` | Low-importance text |

**Progress Bar Widget:**
When a tool is running a scan, a visual progress bar replaces the blinking cursor area:
```
[████████████░░░░░░░░] 63%  scanning photos...  (Ctrl+C to cancel)
```
The filled blocks are `#00E5FF`, empty blocks `#2A2A38`. This renders as a single terminal line, updated in-place via `replaceLastLine` mechanism.

**Multi-tab behavior:**
Each tab is an independent `TerminalSession` with its own command history, CWD, and output lines. Sessions persist across app restarts via `terminal_sessions` SQLite table. Output lines are stored in memory only (not persisted — too large). On app restart, sessions are restored with an empty output and the last command re-displayed.

**BLoC:** `TerminalBloc(sessionId: int)` — one BLoC per session tab.

---

### SCREEN 05 — Package Manager (UI Mode)

**Route:** `/pkg`  
**Terminal:** `pkg` (all commands)  
**Purpose:** Visual tool installation — like an app store for tools

**Visual Layout — Three Tab Structure:**

**Tab 1: Available**
A list of all installable tools from the registry (bundled JSON, never from internet). Each tool is a `PkgTile`: glass card with tool name (JetBrains Mono 14sp `#00E5FF`), version badge (small chip `#1A1A24`), one-line description (Inter 13sp `#8888A0`), category badge, and an `Install` button (if not installed) or `Installed ✔` indicator (if installed). Tapping a tile opens the Tool Detail screen.

**Tab 2: Installed**
Same list but filtered to installed tools only. Shows `Remove` button in red. Shows install date, version, and size.

**Tab 3: Updates**
Shows installed tools that have a newer version available. Since this is v1 offline, all tools show "Up to date ✓". In future, this connects to the repository.

**Tool Detail Screen (push from pkg list):**
Full screen: tool name, version, author, detailed description, list of all commands with examples, category, size. Install/Remove button at bottom.

---

### SCREEN 06 — Media App (nmap GUI counterpart)

**Route:** `/media`  
**Terminal:** `nmap` tool  
**Purpose:** Visual media library scanner and browser

**Visual Layout:**

**Header (44px):**
Title `Media` Inter SemiBold 16sp. Right: `⟳` re-scan button, filter funnel icon.

**Stats Shelf (80px):**
Three horizontal stat cards: `📷 Photos [count]`, `🎬 Videos [count]`, `💾 [total size]`. These pull real-time from `media_cache` table. If cache is empty (never scanned), shows `Tap ⟳ to scan`.

**Filter Bar (40px):**
Horizontal chip row: `All` · `Photos` · `Videos` · `[Year: 2026▾]` · `[Month ▾]` · `[Size ▾]`. Active filter chips glow `#00E5FF`. Year/Month show a bottom sheet picker on tap.

**Main Area — Grid View (default):**
3-column thumbnail grid. Each thumbnail is 110px × 110px with 2px gap. Photos load lazily via `photo_manager`. Below the thumbnail: filename (10sp, truncated) and size (9sp `#8888A0`). Videos show a play-button overlay and duration badge.

**List/Grid toggle** in top-right (two icon buttons).

**List View alternate:**
Each item is a row: thumbnail (48px) · name · size · date · type badge. Sortable by column header tap.

**Empty state:** Terminal-style message centered: `No media found. Adjust filters or run scan.` with a cyan `>_ nmap -a` chip below it that, when tapped, opens terminal and runs the scan command.

**Media Detail Bottom Sheet (on tap):**
Slides up from bottom. Shows: full-path, file name, size (formatted), dimensions (for photos), duration (for videos), creation date, modification date, album name, GPS coordinates (if available, shown as lat/lng — no map API). Two action buttons: `Copy Path` (to clipboard) and `Open in Terminal` (pre-fills `nmap --info` command).

**Scan Loading State:**
When scan is running, a `LinearProgressIndicator` in `#00E5FF` appears below the filter bar. Each 100 items processed, the stats shelf updates in real-time. No blocking spinner — the grid starts showing results as they arrive (streaming insert to grid).

---

### SCREEN 07 — Files App

**Route:** `/files`  
**Terminal:** `fs` tool  
**Purpose:** Full device file system browser

**Visual Layout:**

**Breadcrumb Bar (36px):**
Horizontal scrollable path. Each segment is a tappable chip: `home` › `DCIM` › `Camera`. Background `#1A1A24`, text JetBrains Mono 12sp `#8888A0`. Active (last) segment in `#E8E8F0`. Tap any segment to navigate there.

**Toolbar (36px):**
Sort dropdown (Name / Size / Date / Type) · Grid/List toggle · Hidden files toggle · Bookmark button.

**File List:**
Each item is a `FileListTile`: left icon (folder=`📁` cyan, image=`🖼` green, video=`🎬` blue, doc=`📄` grey, archive=`📦` yellow, other=`📎` dim). Name (Inter 13sp `#E8E8F0`). Subtitle: size + date (Inter 11sp `#8888A0`). Long-press context menu: Copy Path · Info · Open in Terminal · (future: Share).

**Bookmarks Sidebar (swipe right to reveal):**
Quick-access list: `Home` · `DCIM/Camera` · `Downloads` · `Documents` · user-added bookmarks. Icons `#00E5FF`.

**File Detail Panel (long-press → info):**
Bottom sheet with all metadata from `file_system_cache`: full path, exact size in bytes, MIME type, permissions string (`-rw-r--r--`), creation date, modification date. Action: `Copy path to clipboard`.

**Empty Directory State:** Shows `ls: directory is empty` in terminal style.

**Permission Error State:** Shows `Permission denied. Cannot read this directory.` in red terminal style.

---

### SCREEN 08 — Stats App

**Route:** `/stats`  
**Terminal:** `stats` tool  
**Purpose:** Visual analytics dashboard of device storage and media

**Visual Layout — Scrollable Dashboard:**

**Section 1 — Storage Ring (240px height):**
A `CustomPainter` ring chart centered. Outer ring shows total storage (128GB example). Inner fill represents used space. Three arc segments: `Media (31.7 GB, cyan)`, `Apps (22 GB, blue)`, `Other (35.7 GB, grey)`, `Free (38.6 GB, dim)`. Center text shows `69.8%` used in large JetBrains Mono with `Used` label below.

**Section 2 — Media Summary Cards (row):**
Two glass cards side-by-side: Photos card (`2,340 files · 8.4 GB`) and Videos card (`187 files · 22.1 GB`). Each shows an icon, count, size, and a mini sparkline drawn with `CustomPainter`.

**Section 3 — Year Breakdown Chart:**
Horizontal bar chart. Each year is a row: year label (JetBrains Mono) · bar (filled `#00E5FF` proportionally) · count label. Bars animate from 0 to full width on first render. Data from `media_cache` table: `SELECT strftime('%Y', datetime(created_at, 'unixepoch')) as year, COUNT(*) as cnt FROM media_cache GROUP BY year ORDER BY year DESC`.

**Section 4 — Top 10 Largest Files:**
List of 10 rows. Rank number (dim) · filename (truncated) · size badge (glass chip). Real query from `media_cache ORDER BY size_bytes DESC LIMIT 10`.

**Section 5 — Camera vs Screenshots Breakdown:**
Donut chart. `photo_manager` album name distinguishes camera roll from screenshots. Real data grouping.

**Section 6 — Activity Heatmap:**
A 7×52 grid (days of week × weeks) in the style of GitHub contributions. Each cell: if `media_cache` has photos on that date, cell color is `#00E5FF` scaled by count (0=`#1A1A24`, 1-5=`#004455`, 6-15=`#0097B2`, 16+=`#00E5FF`). This visualizes when the user takes the most photos.

---

### SCREEN 09 — Notes App

**Route:** `/notes`  
**Terminal:** `notes` tool  
**Purpose:** Persistent note-taking with tags and full-text search

**Visual Layout:**

**Search Bar (40px):** Glass input field, placeholder `Search notes...`, magnifier icon `#00E5FF`. Searches `notes_fts` virtual table for instant full-text results.

**Filter Chips (32px):** `All` · `Pinned` · tag chips (read from distinct tags in `notes` table).

**Notes Grid:**
Masonry-style grid (2 columns, `flutter_staggered_grid_view`). Each `NoteCard`: glass container with the note's color tint (from `color` column), title (Inter SemiBold 13sp), content preview (3 lines, Inter 12sp `#8888A0`), bottom row with date + tag chips. Pinned notes show a 📌 icon top-right. Long-press → context menu: Pin/Unpin · Change Color · Delete.

**FAB (bottom right):** `+` in `#00E5FF` — opens Note Editor.

**Note Editor Screen (push):**
Full screen. Top bar: back button · title input (JetBrains Mono 16sp, no border, placeholder `Title...`) · save button. Below: tag input row (chips with `×` to remove, `+` to add). Main area: multiline content text field (Inter 14sp `#E8E8F0`, no border). Bottom bar: character count · word count · last saved time. Auto-saves every 5 seconds via `debounce`. Color picker (6 preset colors) in a row at top.

---

### SCREEN 10 — Search App

**Route:** `/search`  
**Terminal:** `search` tool  
**Purpose:** Universal search across all device files, media, notes, and history

**Visual Layout:**

**Hero Search Bar (top, 56px):**
Large input field, immediately focused on screen open. Placeholder: `Search files, media, notes...` in JetBrains Mono 13sp. Below: scope filter chips: `All` · `Media` · `Files` · `Notes` · `Commands`.

**Recent Searches (when no input):**
List of last 10 searches from Hive `recent_searches` box with `×` to remove each.

**Results Section:**
Results grouped by type with section headers (`── Media ──`, `── Files ──`, `── Notes ──`). Each result row shows: type icon, name, path/content preview, size/date. Highlighted matching text in `#00E5FF`. Real-time results — search fires on each keystroke with 300ms debounce.

---

### SCREEN 11 — Hash Tool App

**Route:** `/hash`  
**Terminal:** `hash` tool  
**Purpose:** Compute and verify cryptographic hashes of files or text

**Visual Layout:**

**Input Mode Tabs:** `Text Input` · `File Input`

**Text Mode:**
Large multiline text field. Below: algorithm selector (MD5 · SHA-1 · SHA-256 · SHA-512) as toggle chips. `Compute` button in `#00E5FF`. Result area: monospace hash output in a selectable code block, `#00FF88` color. `Copy` button beside result. `Verify` input below (paste expected hash, shows ✔ or ✗).

**File Mode:**
A file path input (JetBrains Mono) with a `Browse` button that opens a simplified file picker (reads from `file_system_cache`). Selected file shows name, size, path. Same algorithm selector. `Compute Hash` button. Running a file hash over 10MB uses `HashWorker` isolate and shows progress bar. Result displayed identically to text mode.

**History Section:**
Last 20 hash computations from `hash_results` SQLite table. Each row: file/text preview · algorithm · hash (truncated) · timestamp.

---

### SCREEN 12 — Encode / Decode App

**Route:** `/encode`  
**Terminal:** `encode` tool  
**Purpose:** Text encoding and decoding (Base64, URL, Hex, ASCII)

**Visual Layout:**

**Mode Toggle (top):** `Encode` ↔ `Decode`

**Algorithm Selector:** `Base64` · `URL Encode` · `Hex` · `ASCII Codes` · `ROT13` · `Binary`

**Input Area:** Large multiline text field with character count badge.

**Output Area:** Readonly output field with copy button and character count. Auto-computes on input change (200ms debounce).

**Swap Button:** Large `⇅` button between input and output — swaps content (for quick decode-re-encode).

**History:** Last 10 from Hive `encode_history` box.

---

### SCREEN 13 — QR Tool App

**Route:** `/qr`  
**Terminal:** `qr` tool  
**Purpose:** Generate and scan QR codes

**Visual Layout — Two Tabs:**

**Generate Tab:**
Input text field (JetBrains Mono). Size slider (128px to 400px). Error correction selector (L/M/Q/H). Foreground color picker (6 presets: cyan, green, red, white, blue, yellow). Background always `#0A0A0F`. QR code renders live via `qr_flutter` package as the user types. Save QR button → saves to photos (uses `photo_manager` write — Phase 5). Share button.

**Scan Tab:**
Camera preview via `mobile_scanner`. Real-time QR detection. On scan: result displayed with copy button, type badge (URL / text / phone / email / geo), and relevant action button (open URL if applicable, though that requires `url_launcher` and internet connection — shown as disabled in offline mode with note).

**History:** Last 20 scanned/generated QR entries from Hive `qr_history`.

---

### SCREEN 14 — Calculator App

**Route:** `/calc`  
**Terminal:** `calc` tool  
**Purpose:** Scientific calculator with history

**Visual Layout:**

**Display (top 35%):**
Dark `#070710` panel. Secondary display (small): previous expression in JetBrains Mono 14sp `#555568`. Primary display: current value/result in JetBrains Mono 32sp `#E8E8F0`. No border, no background distinction.

**Keypad (bottom 65%):**
5 rows × 4 columns. Keys are `GestureDetector` containers with rounded rect shape (8px radius), background `#1A1A24`, text JetBrains Mono 18sp. Key categories:
- Function keys (`AC`, `±`, `%`, `÷`): background `#2A2A38`, text `#00E5FF`
- Operator keys (`×`, `−`, `+`, `=`): background `#004455`, text `#00E5FF`
- Number keys (`0`–`9`, `.`): background `#1A1A24`, text `#E8E8F0`
- Scientific row (swipe up to reveal): `sin`, `cos`, `tan`, `√`, `x²`, `π`, `e`, `log`

**History Drawer:**
Swipe from right → shows last 50 calculations from `calculator_history` SQLite. Tapping a history item pastes the expression back.

---

### SCREEN 15 — Timer App

**Route:** `/timer`  
**Terminal:** `timer` tool  
**Purpose:** Countdown and stopwatch

**Visual Layout — Two Tabs:**

**Countdown Tab:**
Center: large circular progress ring (`CustomPainter`, `#00E5FF` arc on `#1A1A24` track, 220px diameter). Inside: `MM:SS` in JetBrains Mono 48sp `#E8E8F0`. Below: `HH:MM:SS` time input (scroll wheels). Presets row: `1m` · `5m` · `10m` · `25m` (Pomodoro) · `30m` · `1h`. Start/Pause/Reset buttons.

**Stopwatch Tab:**
Large `MM:SS.cs` display (centiseconds). Lap button (records to list below). Lap list shows: lap number, split time, cumulative time. Real-time update at 10Hz.

**Background notification** when timer completes — uses flutter_local_notifications.

---

### SCREEN 16 — Text Editor App

**Route:** `/editor`  
**Terminal:** `edit <filename>` command  
**Purpose:** Plain text file editor with syntax highlighting for common formats

**Visual Layout:**

**Editor Toolbar (top, 36px):**
`← back` · filename (JetBrains Mono 12sp, tappable to rename) · unsaved indicator (`●` if unsaved) · `Save` · `⋮` menu (Find/Replace, Word wrap toggle, Encoding info).

**Line Numbers Gutter (left, 40px wide):**
`#0D0D14` background. Line numbers in JetBrains Mono 11sp `#444458`. Current line highlighted `#2A2A38`.

**Editor Area:**
JetBrains Mono 13sp, `#E8E8F0` text, cursor `#00E5FF`. Horizontal scroll disabled (word wrap default, toggleable). Current line background `#111118`. For `.json`, `.yaml`, `.md`, `.sh` files: basic keyword colorization.

**Find/Replace Panel (bottom sheet when activated):**
Find input (cyan outline) · Replace input · `←→` navigation between matches · `Replace` · `Replace All` · case sensitive toggle.

**Auto-save** every 30 seconds if content changed. Saves to `file_system_cache` path if editing a real file, or to Hive as virtual file if creating new.

---

### SCREEN 17 — Markdown Viewer App

**Route:** `/md`  
**Terminal:** `md <filename>` command  
**Purpose:** Render Markdown files with full formatting

**Visual Layout:**

**Source/Preview toggle** in header. Preview uses `flutter_markdown` widget with a custom dark theme stylesheet: headers in `#00E5FF`, code blocks in `#070710` with JetBrains Mono, links in `#4488FF`, blockquotes with `#00E5FF` left border. Source mode shows raw text in JetBrains Mono. Scroll sync between modes.

---

### SCREEN 18 — JSON Viewer App

**Route:** `/json`  
**Terminal:** `json <filename>` or `json --parse "<text>"` command  
**Purpose:** Parse, format, and explore JSON data

**Visual Layout:**

**Input Area (collapsible):** Multiline text field for pasting raw JSON. `Format` button auto-indents. `Validate` button shows schema errors.

**Tree View:**
A collapsible tree of JSON nodes. Each node type has a color: strings `#00FF88`, numbers `#4488FF`, booleans `#FFD700`, null `#FF4444`, objects/arrays `#00E5FF`. Expand/collapse with tap. Each node shows key name (Inter SemiBold) + value type badge + value preview. Long-press a value to copy it.

**Path Bar (bottom):** Shows the dot-notation path to the currently selected node (e.g., `data.users[0].name`).

---

### SCREEN 19 — Archive Manager App

**Route:** `/archive`  
**Terminal:** `arch` tool  
**Purpose:** Create and extract ZIP archives

**Visual Layout — Two Tabs:**

**Extract Tab:**
File path input (JetBrains Mono) with Browse. On file selection: shows archive contents in a tree-style list (read without extracting). Each entry: filename, compressed size, uncompressed size, compression ratio. `Extract All` button → destination path selector → progress bar (from `ArchiveWorker` isolate). `Extract Selected` for partial extraction.

**Create Tab:**
Drag (or browse) files to a list. Target archive name input. Compression level slider (Store / Fast / Normal / Maximum). `Create Archive` button → progress bar → completion.

---

### SCREEN 20 — Clipboard Manager App

**Route:** `/clip`  
**Terminal:** `clip` tool  
**Purpose:** Persistent clipboard history with pinning

**Visual Layout:**

**Active Clipboard (top card):**
Shows current clipboard content. `Copy` button (copies back). `Clear` button.

**History List:**
Cards from `clipboard_history` SQLite. Each card: content preview (3 lines max, JetBrains Mono 12sp), type badge (`text` / `command` / `path`), source app label (dim), timestamp. Pinned items shown first with `📌` badge. Swipe left to delete, swipe right to pin.

**Search bar** at top (searches content text via LIKE query on `clipboard_history`).

---

### SCREEN 21 — Password Vault App

**Route:** `/vault`  
**Terminal:** `pass` tool  
**Purpose:** Local encrypted password manager — no cloud

**Setup Flow (first launch):**
Full-screen: `Set Master Password` headline, two password fields (Inter 16sp), strength indicator bar (red → yellow → green), confirm button. Master password is hashed with SHA-256 and stored in `flutter_secure_storage`. It is never stored in plain text anywhere.

**Unlock Screen:**
Single password field (centered), biometric unlock button (fingerprint icon, uses `local_auth` package), `Unlock` button.

**Vault Home:**
List of password entries grouped by category. Each `VaultTile`: website favicon placeholder icon (initials-based, colored by hash of domain name), title, username (shown), password (shown as `●●●●●●●●`). Tap to reveal password (eye icon toggle). Long-press: Copy Username · Copy Password · Edit · Delete.

**Add/Edit Entry:**
Form: Title · Username · Password (with generator button) · URL · Category (picker) · Notes textarea. Password generator: length slider (8–64), toggles for uppercase/lowercase/numbers/symbols.

**AES-256 Encryption:** Every password field is encrypted via `encrypt` package before SQLite write. The key is derived from master password using PBKDF2.

---

### SCREEN 22 — Process Manager App

**Route:** `/proc`  
**Terminal:** `proc` tool  
**Purpose:** See all currently running PocketOS "processes" (apps and background workers)

**Visual Layout:**

**Summary Bar:** Total processes: N · Memory in use: X MB · Uptime: HH:MM:SS (since app launch).

**Process List:**
Each row: PID (short UUID, monospace), app name, status badge (`running` green / `idle` yellow / `stopped` grey), memory estimate (KB, simulated based on app type), started time, action button (Stop · Restart). Sorted by memory usage descending. Real data from `app_sessions` SQLite table.

**Terminal `proc kill <pid>`** updates `app_sessions` status to 'stopped' and emits `CloseAppEvent` on the system event bus. The relevant app then receives this event and closes itself.

---

### SCREEN 23 — Task Scheduler App

**Route:** `/task`  
**Terminal:** `task` tool  
**Purpose:** Schedule terminal commands to run automatically

**Visual Layout:**

**Task List:**
Each `TaskCard`: task name, command preview (JetBrains Mono `#00E5FF`), schedule description, next run time, last result (✔ / ✗ with error preview), enabled toggle switch. Long-press to edit or delete.

**Add Task Form (FAB → bottom sheet):**
Task name · Command input (JetBrains Mono, validated against command registry) · Schedule picker: `Once` (datetime) / `Daily` (time) / `Weekly` (day + time) / `Interval` (minutes) · Description · Save.

**Task execution:** `TaskService` uses a `Timer.periodic` in a background isolate that checks `tasks` table every minute, compares `next_run_at` against current time, and executes due tasks by injecting them into the active terminal session as programmatic commands.

---

### SCREEN 24 — Workspace Manager App

**Route:** `/ws`  
**Terminal:** `ws` tool  
**Purpose:** Save and restore named OS states (open apps, terminal session, layout)

**Visual Layout:**

**Workspace List:**
Each `WorkspaceCard`: workspace name, icon character, description, last used time, `Restore` button, `Update` button (saves current state), delete button. Default workspace `Main` is not deletable.

**New Workspace (FAB):**
Form: Name · Icon (character picker) · Description · Auto-snapshot of current state (open apps, terminal CWD, active theme). Save creates a row in `workspaces` SQLite with the current `app_sessions` state as JSON in `config`.

**Restoring a workspace** closes all current sessions, opens the apps listed in config, restores terminal CWD and theme from config.

---

### SCREEN 25 — System Info App

**Route:** `/sysinfo`  
**Terminal:** `sys` tool (or `uname -a`)  
**Purpose:** Complete device and OS information — like `neofetch` for PocketOS

**Visual Layout:**

**Top banner:** PocketOS ASCII art logo (rendered via Text widget, JetBrains Mono 10sp, cyan) on left. System summary on right.

**Info Cards (scrollable):**
- OS: `PocketOS v1.5` · Kernel: `Dart 3.x` · Build: `com.pocketos.pro`
- Device: Real values from `device_info_plus` (model, manufacturer, Android version, SDK level)
- CPU: Architecture (from device_info), core count
- Storage: Total/free (real from `disk_space` package)
- Battery: Level + charging status (real from `battery_plus`)
- RAM: Not directly available on Android — shows estimated from `app_sessions` total
- Screen: Resolution, density (from `MediaQueryData`)
- Uptime: Session uptime since app launch
- Installed tools: count from `installed_tools` SQLite

---

### SCREEN 26 — Log Viewer App

**Route:** `/logs`  
**Terminal:** `logs` command  
**Purpose:** Full system log browser

**Visual Layout:**

**Filter Row:** Level chips (`ALL` · `INFO` · `WARN` · `ERROR` · `DEBUG` · `SYSTEM`) · Source picker · Date range.

**Log List:**
Each row: colored level badge · timestamp (JetBrains Mono 11sp `#555568`) · source (dim cyan) · message. Row background subtly tinted by level (error rows have 5% red tint). Real-time updates via `StreamBuilder` on `LogRepository.watchLogs()` which uses SQLite `onChange` trigger via polling.

**Export:** Top-right `↑` button → exports all filtered logs to a `.txt` file in `/home/logs/`.

---

### SCREEN 27 — Diff Tool App

**Route:** `/diff`  
**Terminal:** `diff <file1> <file2>` command  
**Purpose:** Side-by-side text comparison

**Visual Layout:**

**Two file input bars** (top). Each has a path input (JetBrains Mono) + Browse button. A `Compare` button between them.

**Diff Output:**
Split-view (two columns) or unified view (toggle). Added lines: subtle `#00FF88` background tint with `+` gutter. Removed lines: `#FF4444` tint with `-` gutter. Unchanged lines: normal. JetBrains Mono 12sp throughout. Line numbers in gutter. Jump to next/prev diff buttons in toolbar. Summary bar: `+12 added · -7 removed · 3 changed`.

---

### SCREEN 28 — Color Tool App

**Route:** `/color`  
**Terminal:** `color` tool  
**Purpose:** Color picker, converter, and palette generator

**Visual Layout:**

**Color Swatch (240px × 240px):**
A 2D gradient picker (saturation × brightness plane) with a hue slider below. The selected color previews in a large swatch.

**Value Inputs:** HEX · RGB · HSL · HSV fields. All sync bidirectionally — editing any one updates all others.

**Palette Generator:**
Generates 5-color harmonies (complementary, analogous, triadic, tetradic). Tapping a harmony color selects it.

**Eye Dropper (Phase 5):** Screenshots current screen and lets user tap any pixel to select its color.

**History:** 16 most recent colors shown as small swatches. Tap to restore.

---

### SCREEN 29 — Unit Converter App

**Route:** `/unit`  
**Terminal:** `conv` tool  
**Purpose:** Convert between units across multiple categories

**Visual Layout:**

**Category Selector (horizontal scroll):**
Length · Area · Volume · Weight · Temperature · Speed · Time · Data · Energy · Pressure

**Converter:**
Two rows each with: value input (numeric keyboard) + unit selector (dropdown). The two rows auto-convert bidirectionally. Arrow button (`⇅`) to swap. Decimal precision slider (0–8).

**History:** Last 10 conversions from Hive `unit_conv_history`.

---

### SCREEN 30 — Settings App

**Route:** `/settings`  
**Purpose:** Full OS configuration

**Visual Layout — Settings Groups (scrollable list):**

**Appearance:**
- Theme: `Dark` · `AMOLED Black` · `Hacker Green` · `Cyber Blue` · `Kali Red`
- Wallpaper: 4 bundled options + `Set from gallery`
- Accent color: 8 preset swatches (user picks active)
- Launcher grid columns: 3 (default) / 4
- Show app descriptions on launcher: toggle

**Terminal:**
- Font size: Slider 10sp → 18sp
- Terminal font: JetBrains Mono (default) / Fira Code / Courier New
- Cursor style: Block / Underline / Bar
- Cursor blink: toggle
- Typing sound: toggle (uses `audioplayers` package, 1KB click WAV)
- Auto-complete: toggle
- Scroll sensitivity: slider

**Privacy & Security:**
- Password Vault: Change master password / Enable biometric
- Clipboard auto-clear: Off / After 1h / After 24h
- Clear scan cache

**System:**
- Media scan: Scan now / Auto-scan on launch (toggle) / Scan schedule
- Storage index: Re-index now / Show index stats
- Default workspace
- Reset all settings to default (destructive — confirmation dialog)

**Storage:**
- SQLite database size (read from file stats)
- Hive boxes total size
- Clear scan cache button
- Vacuum database button (runs SQLite VACUUM)

**About:**
- App name + version + build number
- Package ID
- Changelog (rendered Markdown in-app)
- Open source licenses (standard Flutter about page)

---

### SCREEN 31 — Desktop Mode (Landscape — Windowed UI)

**Route:** `/desktop`  
**Activation:** Rotate device to landscape + launcher `Desktop Mode` tile, or terminal `desktop` command  
**Purpose:** Multi-window windowed OS experience — like a real desktop

**Layout Architecture:**

**Top Menu Bar (32px):**
`🍎 PocketOS ▾` (OS menu) · `user@pocketos` · `[Time]` · right: battery + storage. The PocketOS menu opens: About · Preferences · Force Quit.

**Taskbar (bottom, 44px):**
Running app buttons (each: icon + name, active = bottom border `#00E5FF`). Right section: Quick actions (terminal, files, settings). Center: show/hide all windows (like Mission Control on Mac).

**Desktop Canvas:**
`#0A0A0F` background with the chosen wallpaper at lower opacity (30%). Apps open as floating, draggable, resizable windows.

**Window Structure (each app):**
- Title bar (32px): traffic-light dots + app name (center) + minimize/maximize/close
- Window body: full app UI rendered inside
- Resize handles on all 4 edges and corners
- Shadow: `#00E5FF` at 8% opacity, 20px blur
- Minimum size: 320×240px
- Maximum: screen bounds minus taskbar

**Window Manager Behavior:**
- Click title bar + drag: move window
- Click corner + drag: resize
- Double-click title bar: maximize/restore
- Minimize → app disappears from desktop but stays in taskbar
- Z-order: clicking a window brings it to front
- All window positions/sizes stored in `workspaces` JSON (restored with workspace)

**Side Panel (right edge, 200px, toggleable):**
Quick stats: battery, storage, top 5 running processes, quick-access bookmarks.

---

### SCREEN 32 — App Drawer (Swipe-left from Launcher)

**Route:** No separate route — overlay on `/launcher`  
**Purpose:** Alphabetical list of all apps

**Visual Layout:**
Full-screen overlay with blur behind it. A-Z index on right edge (tap to jump). Each row: app icon · name · description · arrow. Search bar at top. Installed badge for pkg-installed tools.

---

### SCREEN 33 — Notification Center (Swipe-down from status bar)

**Route:** Overlay  
**Purpose:** System notifications from tools and tasks

**Visual Layout:**
A panel slides down from the top. Each notification: icon · title (bold) · body · timestamp · dismiss button. Notifications come from: completed tasks, finished scans, hash operations complete, archive extraction complete. All stored in Hive `notification_queue`. `Clear All` button at bottom.

---

### SCREEN 34 — Permission Screen

**Route:** `/permission`  
**Trigger:** First launch or when permission is needed but not granted

**Visual Layout:**
No back button. Center: large lock icon in `#00E5FF`. Title: `Media Access Required` (Inter 20sp). Body paragraph explaining exactly why (Inter 14sp `#8888A0`): `PocketOS needs to read your photos and videos to provide real scan results. Your data never leaves this device.` Then two buttons: `Grant Access` (primary, `#00E5FF`) and `Skip for now` (text button). If skipped: terminal operates in limited mode with a persistent `[ WARN ] Media permission not granted` line.

---

## PART C — COMPLETE TERMINAL COMMAND REFERENCE

Every command listed here must be fully functional. No stubs, no "coming soon" output.

### C.1 Built-in Shell Commands

```
help                — List all commands
help <cmd>          — Show command detail
clear               — Clear output
exit                — Return to launcher
echo <text>         — Print text
whoami              — Show user info
uname               — OS info (reads device_info_plus)
uname -a            — Full OS info
date                — Current date/time
uptime              — Session uptime
history             — Full command history (reads SQLite)
history -n 20       — Last 20 commands
!!                  — Repeat last command
!<n>                — Repeat command #n from history
alias               — List aliases (reads from env)
alias ll='fs ls'    — Create alias (stored in terminal_sessions.env_vars)
export VAR=value    — Set env variable
env                 — List env variables
pwd                 — Print current working directory
cd <path>           — Change directory (updates session CWD)
```

### C.2 nmap — Media Scanner

```
nmap -p                    — Scan all photos
nmap -v                    — Scan all videos
nmap -a                    — Scan all media
nmap -d 01.04.2026 -p      — Photos from exact date
nmap --year 2024 -p        — Photos from year
nmap --month 4 -p          — Photos from month
nmap --size >5MB -p        — Photos > 5MB
nmap --size <1MB -p        — Photos < 1MB
nmap --dup -p              — Find duplicate photos
nmap --sort size -p        — Sort by size
nmap --sort date -p        — Sort by date
nmap --limit 10 -p         — Show top 10 only
nmap --output detail -p    — Detailed per-file output
nmap --output count -p     — Count only (default)
nmap --info <id>           — File detail by ID
nmap --help                — Show full help
```

### C.3 fs — File System

```
fs ls                      — List current dir
fs ls <path>               — List specific path
fs ls --sort size          — Sort by size
fs ls --all                — Include hidden files
fs cd <path>               — Change directory
fs cd ..                   — Parent directory
fs pwd                     — Current path
fs info <file>             — File metadata
fs tree                    — Directory tree
fs tree --depth 3          — Tree depth 3
fs du                      — Disk usage current dir
fs du <path>               — Disk usage path
fs bookmark <path>         — Add bookmark
fs bookmarks               — List bookmarks
fs open <file>             — Open in appropriate app
fs cp <src> <dst>          — Copy path to clipboard
```

### C.4 stats — Storage Statistics

```
stats                      — Full system stats
stats media                — Media breakdown
stats storage              — Storage usage
stats year 2024            — Stats for year
stats top                  — Top 10 largest files
stats types                — Breakdown by file type
stats --chart              — ASCII bar charts
```

### C.5 search — Universal Search

```
search "<query>"           — Search all
search "<query>" --media   — Media only
search "<query>" --files   — Files only
search "<query>" --notes   — Notes only
search --date 2024         — By year
search --type jpg          — By extension
search --size >5MB         — By size
```

### C.6 notes — Note Manager

```
notes new "Title"          — Create note (opens editor)
notes list                 — List all notes
notes list --tag work      — Filter by tag
notes open <id>            — Open note in UI
notes edit <id>            — Edit note in editor
notes delete <id>          — Delete (confirmation)
notes search "<query>"     — Full-text search
notes pin <id>             — Pin note
notes tag <id> "tag"       — Add tag
```

### C.7 pkg — Package Manager

```
pkg install <tool>         — Install tool
pkg remove <tool>          — Remove tool
pkg list                   — All available tools
pkg list --installed       — Installed only
pkg update                 — Refresh registry
pkg upgrade                — Upgrade all (shows status)
pkg info <tool>            — Tool details
pkg search <query>         — Search tools
```

### C.8 hash — Hash Generator

```
hash md5 "text"            — MD5 of text
hash sha256 "text"         — SHA-256 of text
hash sha512 "text"         — SHA-512 of text
hash md5 <filepath>        — MD5 of file
hash sha256 <filepath>     — SHA-256 of file
hash verify <hash> "text"  — Verify hash
hash list                  — Last 20 hashes (SQLite)
```

### C.9 encode — Encoder/Decoder

```
encode base64 "text"       — Base64 encode
decode base64 "text"       — Base64 decode
encode url "text"          — URL encode
decode url "text"          — URL decode
encode hex "text"          — To hex
decode hex "abcd..."       — From hex
encode rot13 "text"        — ROT13
encode binary "text"       — To binary
```

### C.10 qr — QR Code

```
qr gen "text"              — Generate QR (shows in terminal as ASCII art)
qr scan                    — Open camera scanner
qr history                 — Last 10 QR codes
```

### C.11 calc — Calculator

```
calc "2 + 2"               — Simple arithmetic
calc "sin(30)"             — Trigonometry
calc "sqrt(144)"           — Functions
calc "2^10"                — Power
calc history               — Last 10 calculations
```

### C.12 timer — Timer

```
timer 5m                   — 5 minute countdown
timer 1h30m                — 1 hour 30 min countdown
timer stop                 — Stop active timer
timer status               — Check remaining time
stopwatch start            — Start stopwatch
stopwatch stop             — Stop + show time
stopwatch lap              — Record lap
```

### C.13 arch — Archive Manager

```
arch list <file.zip>       — List archive contents
arch extract <file.zip>    — Extract to current dir
arch extract <file.zip> <dst> — Extract to destination
arch create <name.zip> <files...> — Create archive
arch info <file.zip>       — Archive metadata
```

### C.14 clip — Clipboard Manager

```
clip                       — Show current clipboard
clip add "text"            — Add to clipboard + history
clip list                  — Recent clipboard history
clip pin <id>              — Pin entry
clip clear                 — Clear clipboard
```

### C.15 pass — Password Vault

```
pass list                  — List all entries (titles only)
pass get <id>              — Show entry (password hidden)
pass copy <id>             — Copy password to clipboard
pass new                   — Create new entry (interactive)
pass delete <id>           — Delete entry
pass search "query"        — Search titles
pass gen                   — Generate random password
pass gen --length 20       — Generate with length
```

### C.16 proc — Process Manager

```
proc                       — List all processes
proc list                  — Same as proc
proc kill <pid>            — Stop process
proc info <pid>            — Process details
proc top                   — Live updating process list
```

### C.17 task — Task Scheduler

```
task list                  — List all tasks
task add "name" "cmd" daily 09:00  — Add daily task
task run <id>              — Run task now
task disable <id>          — Disable task
task enable <id>           — Enable task
task delete <id>           — Delete task
task history <id>          — Execution history
```

### C.18 ws — Workspace Manager

```
ws list                    — List workspaces
ws create "name"           — Create from current state
ws restore <name>          — Restore workspace
ws update <name>           — Update with current state
ws delete <name>           — Delete workspace
ws current                 — Show current workspace
```

### C.19 sys — System Info

```
sys                        — Full system info (neofetch style)
sys storage                — Storage breakdown
sys battery                — Battery info
sys device                 — Device hardware info
sys os                     — OS + framework info
sys perf                   — Performance snapshot
```

### C.20 logs — Log Viewer

```
logs                       — Last 50 logs
logs --tail 20             — Last 20 lines
logs --level error         — Errors only
logs --level warn          — Warnings only
logs --source nmap         — From nmap tool
logs --since 1h            — Last hour
logs --clear               — Clear all logs
logs --export              — Export to file
```

### C.21 diff — Diff Tool

```
diff <file1> <file2>       — Compare two files
diff --unified <f1> <f2>   — Unified diff format
diff --stat <f1> <f2>      — Summary stats only
```

### C.22 color — Color Tool

```
color #00E5FF              — Parse hex color
color rgb 0 229 255        — From RGB
color hsl 190 100 50       — From HSL
color pick                 — Open color picker UI
color palette "#00E5FF"    — Generate harmonies
```

### C.23 conv — Unit Converter

```
conv 100 cm m              — 100 cm to meters
conv 32 F C                — Fahrenheit to Celsius
conv 1 GB MB               — 1GB to MB
conv 100 mph kmh           — Speed conversion
conv list                  — List all categories
```

### C.24 open — App Opener

```
open terminal              — Terminal screen
open media                 — Media app
open files                 — Files app
open stats                 — Stats app
open notes                 — Notes app
open pkg                   — Package manager
open search                — Search app
open hash                  — Hash tool
open encode                — Encode/decode tool
open qr                    — QR tool
open calc                  — Calculator
open timer                 — Timer
open editor                — Text editor
open md                    — Markdown viewer
open json                  — JSON viewer
open archive               — Archive manager
open clip                  — Clipboard manager
open vault                 — Password vault
open proc                  — Process manager
open task                  — Task scheduler
open ws                    — Workspace manager
open sysinfo               — System info
open logs                  — Log viewer
open diff                  — Diff tool
open color                 — Color tool
open unit                  — Unit converter
open settings              — Settings
open desktop               — Desktop mode
```

---

## PART D — DESIGN TOKEN SYSTEM (COMPLETE)

### D.1 Full Color Token Table

```dart
// lib/core/theme/app_colors.dart
// ALL themes defined here. Only ONE is active at a time.

class DarkTheme {  // Default
  static const bg          = Color(0xFF0A0A0F);
  static const bgAlt       = Color(0xFF070710);
  static const surface     = Color(0xFF111118);
  static const surfaceEl   = Color(0xFF1A1A24);
  static const surfaceEl2  = Color(0xFF22222E);
  static const border      = Color(0xFF2A2A38);
  static const borderFocus = Color(0xFF00E5FF);
  static const accent      = Color(0xFF00E5FF);  // PRIMARY
  static const accentDim   = Color(0xFF0097B2);
  static const accentBg    = Color(0xFF002233);
  static const success     = Color(0xFF00FF88);
  static const successDim  = Color(0xFF00AA55);
  static const error       = Color(0xFFFF4444);
  static const warning     = Color(0xFFFFD700);
  static const info        = Color(0xFF4488FF);
  static const textPrimary = Color(0xFFE8E8F0);
  static const textSec     = Color(0xFF8888A0);
  static const textDim     = Color(0xFF444458);
  static const textInverse = Color(0xFF0A0A0F);
}

class AmoledTheme {
  static const bg     = Color(0xFF000000);
  static const accent = Color(0xFF00E5FF);
  // rest same as DarkTheme
}

class HackerGreenTheme {
  static const bg     = Color(0xFF050A05);
  static const accent = Color(0xFF00FF41);
  // text = Color(0xFFCCFFCC)
}

class CyberBlueTheme {
  static const bg     = Color(0xFF080D1A);
  static const accent = Color(0xFF4488FF);
}

class KaliRedTheme {
  static const bg     = Color(0xFF0A0005);
  static const accent = Color(0xFFFF004C);
}
```

### D.2 Typography Scale

```dart
// lib/core/theme/app_typography.dart

// Terminal font — use for ALL terminal content
static TextStyle term(double size, Color color, {FontWeight weight = FontWeight.normal}) =>
  GoogleFonts.jetBrainsMono(fontSize: size, color: color, fontWeight: weight, height: 1.5);

// UI font — use for ALL graphical UI
static TextStyle ui(double size, Color color, {FontWeight weight = FontWeight.normal}) =>
  GoogleFonts.inter(fontSize: size, color: color, fontWeight: weight);

// Defined styles:
// termXS:  term(10, textSecondary)
// termSM:  term(11, textSecondary)
// termMD:  term(13, textPrimary)
// termLG:  term(15, textPrimary, weight: Bold)
// termXL:  term(18, accent, weight: Bold)

// uiCaption:   ui(10, textDim)
// uiLabel:     ui(11, textSecondary)
// uiBody:      ui(13, textPrimary)
// uiBodyLarge: ui(15, textPrimary)
// uiTitle:     ui(18, textPrimary, weight: SemiBold)
// uiHeadline:  ui(22, textPrimary, weight: Bold)
// uiDisplay:   ui(32, textPrimary, weight: Bold)
```

### D.3 Shared Widgets Specification

**GlassContainer:**  
`Container` with `BackdropFilter(ImageFilter.blur(sigmaX: 8, sigmaY: 8))`, background `#111118` at 80% opacity, border 1px `#2A2A38`, borderRadius 12px, box-shadow `#00E5FF` 5% at 20px blur.

**NeonText:**  
`Text` with `TextStyle.shadows = [Shadow(color: accent at 80%, blur: 6), Shadow(color: accent at 40%, blur: 18), Shadow(color: accent at 20%, blur: 40)]`.

**OsButton (primary):**  
`ElevatedButton` with background `#00E5FF`, text `#0A0A0F` (inverse), Inter SemiBold 13sp. On press: brief scale down 0.97, 100ms. Disabled: background `#2A2A38`, text `#444458`.

**OsButton (ghost):**  
Transparent background, 1px border `#2A2A38`, text `#8888A0`. On press: background `#1A1A24`.

**ProgressBar:**  
`LinearProgressIndicator` themed with `#00E5FF` value color, `#1A1A24` background. Height 4px, borderRadius 2px.

**SystemBadge:**  
`Container` with 6px borderRadius, horizontal padding 8px, vertical 4px. Background and text color vary by variant: success (`#002C1A` bg, `#00FF88` text), error (`#2C0000`, `#FF4444`), warning (`#2C2000`, `#FFD700`), info (`#001A40`, `#4488FF`).

**GlowDivider:**  
A 1px `Container` with background gradient from transparent → `#00E5FF` at 40% → transparent. Width fills parent. Margin vertical 8px.

---

## PART E — ANIMATION SPECIFICATION

Every animation in PocketOS has a defined specification. No animation is improvised.

| Animation | Duration | Curve | Trigger |
|-----------|----------|-------|---------|
| Screen push | 250ms | easeInOutCubic | Navigation |
| Screen pop | 200ms | easeInCubic | Back button |
| App open from launcher | 300ms | easeOutBack | Tap tile |
| Terminal line appear | 15ms per char (animated) / instant | — | New output line |
| Boot line appear | varies (see boot) | — | Boot sequence |
| Progress bar fill | 400ms | easeInOut | Tool progress update |
| Stats chart draw | 800ms | easeOutQuart | Screen enter |
| Heatmap reveal | 600ms staggered | easeOut | Screen enter |
| Glass card shimmer (loading) | 1200ms loop | easeInOut | Loading state |
| Cursor blink | 800ms period | — | Terminal idle |
| Neon pulse | 2000ms loop | sinusoidal | Accent elements |
| FAB scale bounce | 150ms | easeOutBack | Tap |
| Bottom sheet slide | 300ms | easeOutCubic | Trigger |
| Notification slide | 250ms | easeOutCubic | New notification |
| Window drag | immediate | — | User input |
| Window snap | 200ms | easeOutCubic | Release at edge |

---

*End of COMPLETE v1.5 PRD — Missing Sections + Full OS Specification*
