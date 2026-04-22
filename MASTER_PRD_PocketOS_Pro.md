# MASTER PRD — PocketOS Pro
## "Your Personal Operating System — Control, Scan & Manage Your Data Like a Real System"

**Document Version:** 1.0  
**Status:** Production  
**App Name:** PocketOS  
**Package ID:** com.pocketos.pro  
**Platform:** Android (primary) · iOS · Web  
**Stack:** Flutter · BLoC · Clean Architecture · Hive · Material Design 3  
**Infrastructure:** 100% Offline · No Backend · No Tracking · No Premium Paywall (v1)

---

## TABLE OF CONTENTS

1. [Product Vision](#1-product-vision)
2. [Product Objectives](#2-product-objectives)
3. [Target Users](#3-target-users)
4. [System Architecture](#4-system-architecture)
5. [Terminal System](#5-terminal-system)
6. [Package Manager](#6-package-manager)
7. [Tool System](#7-tool-system)
8. [File System Module](#8-file-system-module)
9. [Media Analyzer Engine](#9-media-analyzer-engine)
10. [Analytics & Stats System](#10-analytics--stats-system)
11. [App Launcher (UI Mode)](#11-app-launcher-ui-mode)
12. [Mini Apps Suite](#12-mini-apps-suite)
13. [Sync Engine](#13-sync-engine)
14. [System Logs](#14-system-logs)
15. [Settings System](#15-settings-system)
16. [UI/UX Design System](#16-uiux-design-system)
17. [Screen Map (All Screens)](#17-screen-map-all-screens)
18. [Security & Privacy](#18-security--privacy)
19. [Performance Requirements](#19-performance-requirements)
20. [Deployment & Release](#20-deployment--release)
21. [Full Version Roadmap](#21-full-version-roadmap)
22. [Phase 2 PRD — Core OS (Publishable)](#22-phase-2-prd--core-os-publishable)
23. [Phase 3 PRD — Full OS Experience](#23-phase-3-prd--full-os-experience)

---

## 1. PRODUCT VISION

### What Is PocketOS Pro?

PocketOS Pro is a **real personal operating system** built inside a mobile app. It is not a gimmick UI, not a fake terminal, and not a productivity tool disguised as an OS. It is a **fully simulated, tool-driven, offline OS** that puts the power of Kali Linux / Termux / ParrotOS — but for *personal data management, not hacking* — directly in the user's pocket.

It combines:
- 🧑‍💻 **Terminal Interface** — bash-style command line (like Termux)
- 📱 **Graphical Launcher UI** — visual app grid (like Android / Windows)
- 🧰 **Real Tool Execution Engine** — installable tools that produce real results from real device data
- 📂 **Simulated File System** — navigable virtual filesystem layered over real device storage
- 📊 **Media Analyzer** — scan, filter, and analyze photos/videos with OS-style commands
- 📦 **Package Manager** — install/remove tools like `apt` on Debian or `pkg` on Termux

### Tagline
> **"Your personal operating system — control, scan, and manage your data like a real system."**

### What It Is NOT
- ❌ Not a hacking tool
- ❌ Not a network scanner
- ❌ Not a fake/simulation with hardcoded output
- ❌ Not a backend-connected cloud app
- ❌ Not a simple file manager with a terminal skin

---

## 2. PRODUCT OBJECTIVES

### Primary Objectives
| # | Objective | Success Metric |
|---|-----------|----------------|
| 1 | Deliver real OS feel with two interfaces (terminal + UI) | Users can switch seamlessly |
| 2 | Build real tool execution (no fake output) | nmap returns real device file counts |
| 3 | Package manager that installs/removes tools | pkg install/remove works with Hive persistence |
| 4 | Offline-first, zero backend | App works 100% without internet |
| 5 | Publishable v1 on Play Store | Passes review, no crashes on Android 8+ |

### Secondary Objectives
- Scalable tool plugin architecture for future tools
- Clean architecture enabling easy feature addition
- Premium UI that rivals Kali Linux's aesthetic on mobile

---

## 3. TARGET USERS

### Primary Users
| Segment | Why They Use PocketOS |
|---------|----------------------|
| Developers & Engineers | Terminal workflow, real tool feel |
| Tech Enthusiasts | OS simulation, power-user tools |
| Computer Science Students | Learn OS concepts hands-on |
| Android Power Users | Deep file/media management |

### Secondary Users
| Segment | Why They Use PocketOS |
|---------|----------------------|
| Content Creators | Scan + organize media library by date/size |
| General Users | Clean media viewer with stats |
| Privacy-Focused Users | Fully offline, no data leaves device |

---

## 4. SYSTEM ARCHITECTURE

### 4.1 Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                   │
│         Terminal UI  ←→  Launcher UI  ←→  App UIs        │
├─────────────────────────────────────────────────────────┤
│                       BLOC LAYER                         │
│   TerminalBloc  ·  LauncherBloc  ·  MediaBloc  ·  etc.   │
├─────────────────────────────────────────────────────────┤
│                       DOMAIN LAYER                       │
│        Use Cases · Entities · Repository Interfaces      │
├─────────────────────────────────────────────────────────┤
│                        DATA LAYER                        │
│     Hive Local DB  ·  Device Media API  ·  File API      │
└─────────────────────────────────────────────────────────┘
```

### 4.2 System Layers (6 Layers)

#### Layer 1 — Kernel Layer (Core Engine)
The core runtime of the OS. Manages:
- Command parsing and dispatch
- Tool lifecycle (install/run/uninstall)
- BLoC state orchestration
- Hive data persistence
- System event bus (terminal ↔ UI sync)

**Key Files:**
```
lib/core/kernel/
  ├── command_parser.dart       # Tokenizes and parses terminal input
  ├── command_dispatcher.dart   # Routes parsed commands to tools
  ├── tool_registry.dart        # Manages installed tools
  ├── event_bus.dart            # Terminal ↔ UI sync events
  └── system_state.dart         # Global OS state
```

#### Layer 2 — Terminal Layer
The primary power-user interface. Handles:
- Real-time command input with keyboard
- Output streaming (line-by-line rendering)
- Command history (up/down arrows)
- Auto-complete (Tab key)
- ANSI-style color output

#### Layer 3 — Package Manager Layer
Manages the tool ecosystem:
- Tool registry (JSON manifest stored in Hive)
- Install/remove lifecycle
- Simulated download progress animation
- Version tracking
- Dependency resolution (Phase 3)

#### Layer 4 — Tool Execution Layer
Each tool is an independent Dart module:
- Receives `ParsedCommand` object
- Accesses device APIs (media, files)
- Returns `ToolOutput` stream
- Has its own help docs accessible via `tool --help`

#### Layer 5 — App Layer (UI)
Graphical apps that mirror terminal tools:
- Files App ↔ `fs` tool
- Media App ↔ `nmap` tool
- Stats App ↔ `stats` tool
- Notes App ↔ `notes` tool

#### Layer 6 — Sync Layer
Bidirectional synchronization:
- Terminal `open media` → opens Media app UI
- Tapping Media app icon → logs `media.app launched` in terminal
- Shared event bus ensures both views stay consistent

### 4.3 Clean Architecture Folder Structure

```
lib/
├── core/
│   ├── kernel/
│   │   ├── command_parser.dart
│   │   ├── command_dispatcher.dart
│   │   ├── tool_registry.dart
│   │   ├── event_bus.dart
│   │   └── system_state.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_typography.dart
│   ├── utils/
│   │   ├── logger.dart
│   │   ├── permission_service.dart
│   │   ├── router.dart
│   │   └── formatters.dart
│   └── constants/
│       ├── commands.dart
│       └── app_constants.dart
│
├── features/
│   ├── boot/
│   │   ├── presentation/
│   │   │   └── boot_screen.dart
│   │   └── bloc/
│   │       ├── boot_bloc.dart
│   │       ├── boot_event.dart
│   │       └── boot_state.dart
│   │
│   ├── launcher/
│   │   ├── presentation/
│   │   │   └── launcher_screen.dart
│   │   └── bloc/
│   │
│   ├── terminal/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── command_model.dart
│   │   │   │   └── output_line_model.dart
│   │   │   └── repositories/
│   │   │       └── terminal_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── parsed_command.dart
│   │   │   │   └── tool_output.dart
│   │   │   ├── repositories/
│   │   │   │   └── terminal_repository.dart
│   │   │   └── use_cases/
│   │   │       ├── execute_command.dart
│   │   │       └── get_history.dart
│   │   └── presentation/
│   │       ├── terminal_screen.dart
│   │       ├── widgets/
│   │       │   ├── terminal_output_line.dart
│   │       │   ├── terminal_prompt.dart
│   │       │   └── terminal_input_field.dart
│   │       └── bloc/
│   │           ├── terminal_bloc.dart
│   │           ├── terminal_event.dart
│   │           └── terminal_state.dart
│   │
│   ├── package_manager/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── media/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── media_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── media_file.dart
│   │   │   └── use_cases/
│   │   │       ├── scan_photos.dart
│   │   │       ├── scan_videos.dart
│   │   │       └── filter_by_date.dart
│   │   └── presentation/
│   │       ├── media_screen.dart
│   │       └── bloc/
│   │
│   ├── files/
│   │   └── [same structure]
│   │
│   ├── stats/
│   │   └── [same structure]
│   │
│   └── notes/
│       └── [same structure]
│
├── tools/
│   ├── base/
│   │   └── base_tool.dart           # Abstract tool class
│   ├── nmap/
│   │   └── nmap_tool.dart
│   ├── fs/
│   │   └── fs_tool.dart
│   ├── stats/
│   │   └── stats_tool.dart
│   └── search/
│       └── search_tool.dart
│
├── shared/
│   ├── widgets/
│   │   ├── glass_container.dart
│   │   ├── neon_text.dart
│   │   ├── os_button.dart
│   │   └── system_badge.dart
│   └── models/
│       └── hive_tool_model.dart
│
├── app.dart
└── main.dart
```

---

## 5. TERMINAL SYSTEM

### 5.1 Terminal Prompt Format
```
user@pocketos:~$
user@pocketos:~/photos$
user@pocketos:~/files$
```

### 5.2 Command Lifecycle
```
User Input → Tokenizer → Parser → Dispatcher → Tool/Handler → Output Stream → Render
```

### 5.3 Built-in System Commands

| Command | Description | Example |
|---------|-------------|---------|
| `help` | List all commands + installed tools | `help` |
| `help <tool>` | Tool-specific help | `help nmap` |
| `clear` | Clear terminal output | `clear` |
| `exit` | Return to launcher | `exit` |
| `open <app>` | Open UI app | `open media` |
| `logs` | Show system logs | `logs` |
| `logs --tail 20` | Last 20 log lines | `logs --tail 20` |
| `echo <text>` | Print text | `echo Hello PocketOS` |
| `whoami` | Show user info | `whoami` |
| `uname` | Show OS info | `uname -a` |
| `date` | Show current date/time | `date` |
| `uptime` | Show session uptime | `uptime` |
| `history` | Command history | `history` |
| `!!` | Repeat last command | `!!` |

### 5.4 Command Parser Specification

**Input tokenization:**
```
"nmap -d 01.04.2026 -p --size >5MB"
→ { command: "nmap", flags: ["-d", "-p", "--size"], args: ["01.04.2026", ">5MB"] }
```

**Rules:**
- Single dash `-` = short flag
- Double dash `--` = long flag
- Values follow their flag with a space
- Quoted strings treated as single arg
- Case insensitive for commands, case sensitive for file paths

### 5.5 Output Rendering

Each output line has a type:
```dart
enum OutputType {
  system,     // White — normal system output
  success,    // Cyan — operation succeeded
  error,      // Red — error message
  warning,    // Yellow — warnings
  info,       // Blue-grey — informational
  command,    // Dim — echoed user input
  progress,   // Animated — loading/scanning
}
```

### 5.6 Terminal Features
- **Scrollable history** — all previous output scrollable upward
- **Keyboard shortcuts:**
  - `↑` / `↓` — navigate command history
  - `Tab` — auto-complete commands/tools
  - `Ctrl+C` — cancel running tool
  - `Ctrl+L` — clear screen
- **Blinking cursor** — authentic terminal cursor animation
- **Typing sound (optional)** — configurable in settings

---

## 6. PACKAGE MANAGER

### 6.1 Overview
The package manager gives PocketOS the real OS feel of Termux/APT. Users must *install* tools before using them — just like a real OS.

### 6.2 Commands

| Command | Description |
|---------|-------------|
| `pkg install <tool>` | Install a tool |
| `pkg remove <tool>` | Uninstall a tool |
| `pkg list` | List all available tools |
| `pkg list --installed` | List installed tools only |
| `pkg update` | Refresh tool registry |
| `pkg upgrade` | Upgrade all installed tools |
| `pkg info <tool>` | Show tool info/description |
| `pkg search <query>` | Search available tools |

### 6.3 Installation Behavior (Real OS Feel)
```
user@pocketos:~$ pkg install nmap

Reading package list...
Fetching tool manifest... [████████████████████] 100%
Installing nmap v1.2.0...
Setting up nmap...
✔ nmap successfully installed.

Run 'nmap --help' for usage.
```

### 6.4 Tool Registry (Hive Storage)
```dart
@HiveType(typeId: 0)
class InstalledTool {
  String name;
  String version;
  DateTime installedAt;
  String description;
  List<String> commands;
}
```

### 6.5 Available Tools (v1 Registry)

| Tool | Version | Description |
|------|---------|-------------|
| `nmap` | 1.0.0 | Media scanner — scan photos/videos by date, size, type |
| `fs` | 1.0.0 | File system navigator — browse device files |
| `stats` | 1.0.0 | Storage statistics — analyze device storage |
| `search` | 1.0.0 | Search engine — find files/media by query |
| `notes` | 1.0.0 | Note manager — create and manage notes |

---

## 7. TOOL SYSTEM

### 7.1 Base Tool Interface
```dart
abstract class BaseTool {
  String get name;
  String get version;
  String get description;
  String get helpText;
  
  Stream<ToolOutputLine> execute(ParsedCommand command);
  bool validateArgs(ParsedCommand command);
}
```

### 7.2 Tool: nmap — Media Scanner (CORE TOOL)

**Purpose:** Scan device photos/videos the same way nmap scans networks — but for personal media.

**Command Structure:**
```
nmap [flags] [arguments]
```

**Complete Flag Reference:**

| Flag | Long Form | Type | Description |
|------|-----------|------|-------------|
| `-p` | `--photos` | bool | Scan photos only |
| `-v` | `--videos` | bool | Scan videos only |
| `-a` | `--all` | bool | Scan all media |
| `-d` | `--date` | string | Filter by specific date (DD.MM.YYYY) |
| `--year` | `--year` | int | Filter by year |
| `--month` | `--month` | int | Filter by month (1-12) |
| `--size` | `--size` | string | Filter by size (>5MB, <10MB, =5MB) |
| `--dup` | `--duplicates` | bool | Find duplicate files |
| `--sort` | `--sort` | string | Sort by: date, size, name |
| `--limit` | `--limit` | int | Limit results count |
| `--output` | `--output` | string | Output format: list, count, detail |

**Usage Examples:**
```bash
# Scan all photos
nmap -p

# Scan all videos
nmap -v

# Scan everything
nmap -a

# Photos from specific date
nmap -d 01.04.2026 -p

# Photos from 2024
nmap --year 2024 -p

# Large photos (>5MB)
nmap -p --size >5MB

# Find duplicate photos
nmap -p --dup

# Detailed scan with all info
nmap -p --output detail

# Combined: large photos from 2024, detailed
nmap -p --year 2024 --size >2MB --output detail
```

**Output Format — Count Mode (default):**
```
Starting nmap scan...
Target: Photos
Filter: Year = 2024
[████████████████████] Scanning...

✔ Scan complete
  Photos found:     320
  Total size:       1.4 GB
  Largest file:     IMG_4567.jpg (12.3 MB)
  Oldest:           01.01.2024
  Newest:           31.12.2024
  Average size:     4.4 MB

Scan completed in 0.8s
```

**Output Format — Detail Mode:**
```
Starting nmap scan (detail mode)...

[001] IMG_0001.jpg    4.2 MB    01.01.2024    /DCIM/Camera/
[002] IMG_0002.jpg    3.8 MB    02.01.2024    /DCIM/Camera/
[003] VID_0001.mp4   28.4 MB    02.01.2024    /DCIM/Camera/
...

✔ 320 files scanned
```

**Output Format — Duplicate Mode:**
```
Scanning for duplicates...
Comparing file sizes and names...
[████████████████████] 100%

✔ Duplicates found: 12 pairs
  IMG_1234.jpg ↔ IMG_1234_copy.jpg (4.2 MB each)
  IMG_5678.jpg ↔ Screenshot_2024.jpg (2.1 MB each)
  ...

Total reclaimable space: 48.6 MB
```

**Real Data Requirements:**
- Uses `photo_manager` Flutter package to access real device media
- Returns actual metadata: date, size, path, dimensions
- No fake/hardcoded data ever
- Permissions required: READ_MEDIA_IMAGES, READ_MEDIA_VIDEO

---

### 7.3 Tool: fs — File System Navigator

**Purpose:** Navigate device file system with terminal commands.

**Commands:**
```bash
fs ls                        # List current directory
fs ls /sdcard/DCIM           # List specific directory
fs ls --sort size            # Sort by size
fs cd photos                 # Change to photos directory
fs cd ..                     # Go up one level
fs pwd                       # Print current directory
fs info IMG_1234.jpg         # Show file metadata
fs tree                      # Show directory tree (depth 2)
fs du                        # Disk usage summary
fs du /sdcard/DCIM           # Disk usage for specific dir
```

**Output Example (`fs ls`):**
```
/storage/emulated/0/DCIM/Camera

drwxr-xr-x  Camera/           -         01.04.2026
-rw-r--r--  IMG_0001.jpg      4.2 MB    01.04.2026
-rw-r--r--  IMG_0002.jpg      3.8 MB    31.03.2026
-rw-r--r--  VID_0001.mp4     28.4 MB    30.03.2026

4 items | 36.4 MB total
```

**Output Example (`fs info`):**
```
File: IMG_0001.jpg
Path: /storage/emulated/0/DCIM/Camera/IMG_0001.jpg
Size: 4.2 MB (4,404,200 bytes)
Type: JPEG Image
Date: 01.04.2026 14:32:11
Dimensions: 4000 × 3000 px
```

---

### 7.4 Tool: stats — Storage Statistics

**Purpose:** System-style storage and media analytics.

**Commands:**
```bash
stats                        # Full system stats
stats media                  # Media breakdown
stats storage                # Storage usage
stats --chart                # ASCII bar chart
```

**Output Example (`stats`):**
```
=== PocketOS System Stats ===

Storage Overview:
  Total:         128.0 GB
  Used:           89.4 GB  [███████░░] 69.8%
  Free:           38.6 GB

Media Summary:
  Photos:        2,340  (8.4 GB)
  Videos:          187  (22.1 GB)
  Screenshots:     934  (1.2 GB)
  Total media:   3,461  (31.7 GB)

Media by Year:
  2026:  [████░░░░░]   234 photos
  2025:  [████████░]   891 photos
  2024:  [████████░]   780 photos
  2023:  [██████░░░]   435 photos
```

---

### 7.5 Tool: search — File & Media Search

**Purpose:** Find files/media by name, date, type, or content.

**Commands:**
```bash
search "IMG"                 # Search by filename pattern
search --date 2024           # Search by year
search --type jpg            # Search by file type
search --size >5MB           # Search by size
search "birthday" --type jpg # Combined search
```

---

### 7.6 Tool: notes — Note Manager

**Purpose:** Create, list, and manage plain-text notes from terminal.

**Commands:**
```bash
notes new "Project ideas"    # Create new note
notes list                   # List all notes
notes open 1                 # Open note by ID
notes edit 1                 # Edit note by ID
notes delete 1               # Delete note
notes search "flutter"       # Search notes
```

---

## 8. FILE SYSTEM MODULE

### 8.1 Hybrid File System Model
PocketOS uses a hybrid file system:
- **Real layer:** Actual device storage accessed via Flutter file APIs
- **Virtual layer:** Simulated directory structure for OS feel

### 8.2 Virtual Directory Structure
```
user@pocketos:~$ ls

/home/
  ├── media/         → Device photos + videos
  ├── files/         → Device documents
  ├── notes/         → PocketOS notes (Hive)
  ├── logs/          → System logs (Hive)
  └── config/        → App settings (Hive)

/system/
  ├── tools/         → Installed tools registry
  ├── pkg/           → Package cache
  └── tmp/           → Temporary files
```

### 8.3 Supported File Operations
- Directory listing with permissions display
- File metadata reading (name, size, date, type)
- Basic navigation (cd, ls, pwd)
- File info detail view
- Disk usage calculation

### 8.4 File System UI (Graphical App)
- Folder-based visual browser
- Sort by: name, date, size, type
- Search within directory
- File detail panel (tap to expand)
- Grid/List toggle view

---

## 9. MEDIA ANALYZER ENGINE

### 9.1 Core Functions
The media engine powers both the `nmap` tool and the Media graphical app.

**Capabilities:**
| Function | Description | Data Source |
|----------|-------------|-------------|
| Scan photos | Read all device photos metadata | photo_manager API |
| Scan videos | Read all device videos metadata | photo_manager API |
| Filter by date | Return media from exact date | Metadata parsing |
| Filter by year/month | Return media from year or month | Metadata parsing |
| Filter by size | Return media above/below size threshold | File stat API |
| Sort results | Sort by date, size, name | Dart sorting |
| Duplicate detection | Compare size + filename patterns | Basic heuristic |
| Count aggregation | Count by year, month, type | Grouping logic |

### 9.2 Media Entity
```dart
class MediaFile {
  final String id;
  final String name;
  final String path;
  final int sizeBytes;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final MediaType type; // photo | video
  final int? width;
  final int? height;
  final Duration? duration; // for videos
}
```

### 9.3 Performance Requirements
- Initial scan of 1,000 photos: < 2 seconds
- Filter operation on scanned results: < 100ms
- No UI blocking — all scans run on background isolate
- Progressive loading — show results as they arrive (stream)
- Cached scan results stored in Hive (invalidated on permission change)

---

## 10. ANALYTICS & STATS SYSTEM

### 10.1 Data Collected (Local Only)
- Total photos count + total size
- Total videos count + total size
- Media grouped by year
- Media grouped by month
- Storage usage breakdown
- Largest files list (top 10)
- File type distribution

### 10.2 Stats Dashboard (UI)
The Stats graphical app shows:
- Storage usage ring chart (Canvas/CustomPainter)
- Year-by-year bar chart (Canvas)
- Media type pie breakdown
- Top 10 largest files list
- Quick scan trigger button

---

## 11. APP LAUNCHER (UI MODE)

### 11.1 Design
The launcher is a dark OS-style grid, resembling an Android home screen but with the aesthetic of a hacker terminal.

**Layout:**
- Grid: 3 columns × N rows
- Each app icon: 72px × 72px with glass card backing
- App name below icon
- Uninstalled apps shown as greyed-out (installable via pkg)
- Top bar: `user@pocketos` | time | battery indicator

### 11.2 Launcher Apps (v1)
| Icon | App Name | Status | Launches |
|------|----------|--------|----------|
| 🖥️ | Terminal | Built-in | Terminal screen |
| 📁 | Files | Built-in | Files app |
| 🖼️ | Media | Built-in | Media app |
| 📊 | Stats | Built-in | Stats app |
| 📝 | Notes | Installable | Notes app |
| 🔍 | Search | Installable | Search app |
| ⚙️ | Settings | Built-in | Settings screen |

### 11.3 Launcher Behaviors
- Long press on app → Show info (version, description)
- Swipe up from bottom → Open terminal
- Status bar shows: time, battery, storage usage %

---

## 12. MINI APPS SUITE

### 12.1 Notes App
- Create plain-text notes
- Title + body structure
- Tag system (comma-separated tags)
- Full-text search
- Stored in Hive
- Terminal counterpart: `notes` tool

### 12.2 Calculator App
- Standard arithmetic (+ - × ÷)
- History of last 10 calculations
- OS-style display (monospace font, dark theme)

### 12.3 Timer App
- Countdown timer
- Terminal command: `timer 25m` (Pomodoro)
- Visual progress ring
- Background notification when complete

### 12.4 Text Editor App
- Create/edit text files in virtual FS
- Monospace font (JetBrains Mono)
- Line numbers
- Word count display

---

## 13. SYNC ENGINE

### 13.1 Bidirectional Sync Behavior

| Terminal Action | UI Effect |
|----------------|-----------|
| `open media` | Opens Media app screen |
| `open files` | Opens Files app screen |
| `open notes` | Opens Notes app screen |
| `open stats` | Opens Stats app screen |
| `exit` | Returns to Launcher |

| UI Action | Terminal Log |
|-----------|-------------|
| Tap Media app | Logs: `media.app launched` |
| Tap Files app | Logs: `files.app launched` |
| Tap back | Logs: `returned to launcher` |
| nmap scan from UI | Logs full nmap command executed |

### 13.2 Event Bus Implementation
```dart
// Singleton event bus
class SystemEventBus {
  final StreamController<SystemEvent> _controller;
  
  void emit(SystemEvent event);
  Stream<SystemEvent> get stream;
}

sealed class SystemEvent {
  OpenAppEvent(String appName)
  CloseAppEvent(String appName)
  ToolExecutedEvent(String tool, String command)
  NavigationEvent(String path)
}
```

---

## 14. SYSTEM LOGS

### 14.1 Log Structure
```dart
class SystemLog {
  final DateTime timestamp;
  final LogLevel level;  // INFO | WARN | ERROR | DEBUG
  final String source;   // terminal | launcher | tool:nmap | etc.
  final String message;
}
```

### 14.2 Terminal Access
```bash
logs                         # Show recent 50 logs
logs --tail 20               # Last 20 lines
logs --level error           # Only errors
logs --source nmap           # Only nmap logs
logs --clear                 # Clear log history
```

### 14.3 Log Retention
- Maximum 1,000 entries stored in Hive
- Auto-rotate when full (remove oldest)
- Export to text file (Phase 3)

---

## 15. SETTINGS SYSTEM

### 15.1 Settings Categories

**Appearance:**
- Theme: Dark (default) | AMOLED Black | Hacker Green | Cyber Blue
- Accent color picker
- Terminal font size (10px – 16px)
- Terminal font: JetBrains Mono | Fira Code | Courier

**Terminal:**
- Typing sound: On/Off
- Cursor blink: On/Off
- Auto-complete: On/Off
- History limit: 100 / 500 / Unlimited

**System:**
- Media scan permission management
- Clear cached scan data
- Reset all settings to default
- Export logs

**About:**
- Version info
- Package ID
- Build number
- Changelog

---

## 16. UI/UX DESIGN SYSTEM

### 16.1 Color Palette

| Name | Hex | Usage |
|------|-----|-------|
| Background | `#0A0A0F` | Primary app background |
| Surface | `#111118` | Cards, panels |
| Surface Elevated | `#1A1A24` | Elevated elements |
| Border | `#2A2A38` | Card borders, dividers |
| Cyan Primary | `#00E5FF` | Primary accent, highlights |
| Cyan Dim | `#0097B2` | Secondary accent |
| Green Success | `#00FF88` | Success states, install done |
| Red Error | `#FF4444` | Error states |
| Yellow Warning | `#FFD700` | Warnings |
| Blue Info | `#4488FF` | Informational |
| Text Primary | `#E8E8F0` | Main text |
| Text Secondary | `#8888A0` | Dimmed text |
| Text Dim | `#444458` | Very dim text |

### 16.2 Typography

| Usage | Font | Size | Weight |
|-------|------|------|--------|
| Terminal output | JetBrains Mono | 13sp | Regular |
| Terminal prompt | JetBrains Mono | 13sp | Bold |
| UI Headings | Inter | 20sp | SemiBold |
| UI Body | Inter | 14sp | Regular |
| App names (launcher) | Inter | 11sp | Medium |
| System labels | JetBrains Mono | 11sp | Regular |

### 16.3 Design Language

**Glassmorphism Cards:**
```dart
Container(
  decoration: BoxDecoration(
    color: Color(0xFF111118).withOpacity(0.8),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Color(0xFF2A2A38), width: 1),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF00E5FF).withOpacity(0.05),
        blurRadius: 20,
        spreadRadius: 0,
      ),
    ],
  ),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: content,
  ),
)
```

**Neon Glow Text:**
```dart
Text(
  text,
  style: TextStyle(
    color: Color(0xFF00E5FF),
    shadows: [
      Shadow(color: Color(0xFF00E5FF).withOpacity(0.8), blurRadius: 8),
      Shadow(color: Color(0xFF00E5FF).withOpacity(0.4), blurRadius: 20),
    ],
  ),
)
```

### 16.4 Animations
- **Boot screen:** Typewriter text animation + scan line effect
- **Terminal output:** Lines render top-to-bottom with 20ms stagger
- **Progress bars:** Smooth fill animation at 60fps
- **App open transition:** Scale + fade (200ms)
- **Launcher appear:** Staggered grid item entrance (30ms per item)
- **Neon pulse:** Subtle glow pulse on accent elements (2s loop)

---

## 17. SCREEN MAP (ALL SCREENS)

| Screen | Route | Trigger |
|--------|-------|---------|
| Splash Screen | `/splash` | App launch |
| Boot Screen | `/boot` | After splash |
| Launcher | `/launcher` | After boot |
| Terminal | `/terminal` | Launcher tap / `exit` goes back |
| Media App | `/media` | Launcher tap / `open media` |
| Files App | `/files` | Launcher tap / `open files` |
| Stats App | `/stats` | Launcher tap / `open stats` |
| Notes App | `/notes` | Launcher tap / `open notes` |
| Settings | `/settings` | Settings icon |
| File Detail | `/files/detail` | Tap file in Files app |
| Permission Screen | `/permission` | First launch if no permission |

---

## 18. SECURITY & PRIVACY

- ✅ **Zero network access** — no HTTP calls, no analytics, no ads
- ✅ **Zero data exfiltration** — all data stays on device
- ✅ **Hive encryption** — sensitive data encrypted at rest (Phase 3)
- ✅ **Permission transparency** — clear explanation before requesting permissions
- ✅ **No tracking** — no Firebase, no Crashlytics, no analytics SDKs
- ✅ **No accounts** — no login, no registration, no email required
- ✅ **Open media access** — only reads metadata, never uploads or copies files

---

## 19. PERFORMANCE REQUIREMENTS

| Metric | Target |
|--------|--------|
| App cold start → Launcher | < 3 seconds |
| Boot animation duration | 2.5 seconds |
| nmap scan (500 photos) | < 1.5 seconds |
| nmap scan (5,000 photos) | < 5 seconds |
| Terminal command response | < 50ms |
| Screen navigation transition | < 200ms |
| Memory usage (idle) | < 80 MB |
| Memory usage (active scan) | < 150 MB |
| APK size (release) | < 25 MB |

---

## 20. DEPLOYMENT & RELEASE

### v1.0 (Phase 2 Complete) — Play Store
- Android 8.0+ (API 26+)
- APK + AAB release builds
- Play Store listing:
  - Category: Tools / Productivity
  - Target audience: Developers, Tech enthusiasts
  - Screenshots: 5 × Phone screenshots required

### v1.1 (Phase 3 Complete)
- iOS TestFlight beta
- Web (Flutter Web) — limited features

### Release Checklist
- [ ] All permissions declared in manifest
- [ ] Release signing configured
- [ ] ProGuard/R8 rules set
- [ ] Debug banner removed
- [ ] Logging disabled in release
- [ ] APK under 25MB
- [ ] Tested on Android 8, 10, 12, 13, 14
- [ ] No crashes in 30-minute session

---

## 21. FULL VERSION ROADMAP

| Version | Name | Key Features |
|---------|------|-------------|
| **v1.0** | Core OS | Terminal, nmap, fs, stats, media scan, launcher, boot |
| **v1.1** | Package System | Full pkg manager, search tool, notes tool |
| **v1.2** | Data Intelligence | Duplicate detection, size analytics, media timeline |
| **v2.0** | Full Personal OS | Plugin system, custom tools API, themes marketplace |
| **v2.5** | Power Tools | text editor, calculator, timer, session engine |
| **v3.0** | Elite OS | Scripting engine, custom commands, workflow automation |

---

## 22. PHASE 2 PRD — CORE OS (PUBLISHABLE)

> **Goal:** Build the complete functional core. After Phase 2, the app is publishable on the Play Store.

### Phase 2 Scope

**Duration:** 4–5 days  
**Output:** Fully publishable v1.0 APK

### 2.1 Boot & Splash System

**Splash Screen:**
- PocketOS logo (centered)
- Dark background
- 1.5s display → transition to Boot
- No user input needed

**Boot Screen (Critical for OS Feel):**
```
Initializing PocketOS v1.0...
Loading kernel modules...       [OK]
Starting terminal engine...     [OK]
Loading tool registry...        [OK]
Mounting file system...         [OK]
Requesting media permissions... [OK]
Starting launcher...            [OK]

PocketOS ready. Welcome, user.
```
- Each line types out with realistic delay (100–200ms per line)
- `[OK]` flashes cyan on appear
- After all lines: 500ms pause → fade to Launcher
- **Technical:** BootBloc manages sequence, each step is a BLoC state

### 2.2 Launcher UI

**Top Status Bar:**
```
user@pocketos    [14:32]    [69%]  [128GB]
```

**App Grid (3 columns):**
- Terminal, Files, Media, Stats, Settings, (+ locked slots)
- App icons use custom SVG/Canvas drawn icons (no external icon pack)
- Subtle grid shimmer animation on first appear
- Tap → navigate to app + log event
- Long press → show tooltip with app description

**Quick Terminal Button:**
- Bottom center FAB with `>_` symbol
- Glows cyan on hover/press

### 2.3 Terminal Screen (Full Implementation)

**Layout:**
```
┌─────────────────────────────────┐
│ ◉ PocketOS Terminal     ╳  □    │  ← Header
├─────────────────────────────────┤
│                                 │
│  user@pocketos:~$ help          │
│  Available commands:            │
│    help, clear, exit, open      │
│    open <app>  — launch app     │
│    logs        — system logs    │
│    pkg         — package mgr    │
│                                 │
│  user@pocketos:~$               │  ← Blinking cursor
├─────────────────────────────────┤
│  [_________________________] → │  ← Input field
└─────────────────────────────────┘
```

**Implementation Requirements:**
- Output rendered as `ListView` with reverse: false
- Auto-scroll to bottom on new output
- Input field always focused (keyboard stays open)
- History navigation with up/down hardware keys
- Output lines render with 20ms stagger animation
- `clear` command animates lines dissolving upward
- Monospace font throughout (JetBrains Mono)

**BLoC Events:**
```dart
sealed class TerminalEvent {
  SubmitCommand(String input)
  ClearTerminal()
  NavigateHistory(HistoryDirection direction)
  CancelExecution()
}

sealed class TerminalState {
  TerminalIdle(List<OutputLine> lines, String prompt)
  TerminalExecuting(List<OutputLine> lines, String activeCommand)
  TerminalError(List<OutputLine> lines, String error)
}
```

### 2.4 nmap Tool (Full Implementation)

**Phase 2 Flags:** `-p`, `-v`, `-a`, `-d`, `--year`, `--output`

**Real Implementation Steps:**
1. Request permission (permission_handler)
2. Load asset list using `photo_manager` package
3. Filter based on flags
4. Stream results back to terminal line-by-line
5. Show animated progress bar during scan
6. Cache results in Hive with timestamp

**nmap BLoC:**
```dart
sealed class NmapState {
  NmapIdle()
  NmapScanning(double progress, int found)
  NmapComplete(NmapResult result)
  NmapError(String message)
  NmapPermissionDenied()
}
```

**Progress Output (animated):**
```
Starting nmap scan...
Target: Photos  |  Filter: Year 2024
[████████████░░░░░░░░] 63%  •  scanning...
✔ 203 photos loaded  (still scanning...)
[████████████████████] 100%
✔ Scan complete: 320 photos found
```

### 2.5 Media Screen (UI Counterpart to nmap)

**Layout:**
- Top: stats bar (total count, total size)
- Filter row: All / Photos / Videos / [Year picker]
- Main area: Grid view (3 columns) with thumbnails
- Bottom: "Open in Terminal" button → pre-fills nmap command

**Behaviors:**
- Loading state: shimmer grid placeholders
- Empty state: terminal-style message ("No media found matching filter")
- Tap photo: shows metadata panel (name, size, date, dimensions)

### 2.6 Files Screen (fs tool UI counterpart)

**Layout:**
- Breadcrumb path bar: `/home/media/DCIM/Camera`
- File list: name + size + date
- Folder items shown first
- File detail on tap

### 2.7 Stats Screen (stats tool UI counterpart)

**Layout:**
- Storage ring: CustomPainter ring chart
- Media summary: Photos count/size, Videos count/size
- Year breakdown: Horizontal bar chart (CustomPainter)

### 2.8 Permission Flow

**First launch sequence:**
1. Boot completes
2. System checks READ_MEDIA_IMAGES permission
3. If not granted → Permission Explain Screen
4. Show: what permission is needed + why + "No data leaves your device"
5. Request permission
6. If denied → show limited mode warning in terminal
7. If granted → proceed normally

### 2.9 Dependencies (Phase 2 additions)

```yaml
dependencies:
  photo_manager: ^3.0.0        # Real media access
  google_fonts: ^6.1.0         # JetBrains Mono + Inter
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.2
  permission_handler: ^11.3.0
  intl: ^0.19.0                # Date formatting

dev_dependencies:
  build_runner: ^2.4.8
  hive_generator: ^2.0.1
```

### 2.10 Phase 2 Build Checklist

- [ ] Splash screen (1.5s, logo centered)
- [ ] Boot screen (animated typewriter, all 7 steps)
- [ ] Launcher (grid, status bar, FAB)
- [ ] Terminal (full input/output/history/scroll)
- [ ] Command parser (tokenizer + dispatcher)
- [ ] `help` command
- [ ] `clear` command
- [ ] `exit` command
- [ ] `open <app>` command
- [ ] `logs` command
- [ ] `uname` command
- [ ] `date` command
- [ ] `whoami` command
- [ ] nmap tool: `-p`, `-v`, `-a` flags
- [ ] nmap tool: `-d`, `--year` filters
- [ ] nmap tool: `--output detail` mode
- [ ] Media screen (grid, filter bar, stats)
- [ ] Files screen (list, breadcrumb, file detail)
- [ ] Stats screen (ring chart, bar chart)
- [ ] Permission screen (explain + request)
- [ ] Settings screen (theme, terminal config)
- [ ] System logs (Hive persistence, terminal access)
- [ ] Sync engine (terminal ↔ UI event bus)
- [ ] App tested on Android 8, 10, 13
- [ ] Release build (no debug banner, no logs)
- [ ] APK < 25MB

---

## 23. PHASE 3 PRD — FULL OS EXPERIENCE

> **Goal:** Transform v1.0 into a complete personal OS. After Phase 3, PocketOS rivals Termux in functionality depth.

**Duration:** 2–3 weeks post Phase 2  
**Output:** v1.1 Play Store update + iOS TestFlight

### 3.1 Package Manager (Full Implementation)

**Phase 3 pkg features:**
- `pkg install <tool>` with animated install sequence
- `pkg remove <tool>` with confirmation
- `pkg list` — formatted table of all tools
- `pkg update` — refresh registry (offline: from bundled JSON)
- `pkg upgrade` — show "up to date" for v1 tools
- `pkg info <tool>` — detailed tool information
- Tool registry stored as JSON in Hive
- Tools locked until installed (greyed in help, error if run directly)

### 3.2 New Tool: search

Full implementation of search tool:
- `search "query"` — filename search
- `search --date 2024` — by year
- `search --type jpg` — by extension
- `search --size >5MB` — by size threshold
- Results stream progressively to terminal

### 3.3 New Tool: notes (Full)

- `notes new "Title"` — creates note, opens editor
- `notes list` — all notes with ID, title, date
- `notes open <id>` — opens note in Notes UI app
- `notes delete <id>` — delete with confirmation
- `notes search "query"` — full-text search
- Notes UI App: list view + editor view (JetBrains Mono)

### 3.4 nmap v2 Flags

Add to existing nmap:
- `--size >5MB` / `<5MB` — size filtering
- `--dup` — duplicate detection (size + name heuristic)
- `--sort date` / `--sort size` / `--sort name`
- `--limit <n>` — limit output lines
- `--month <1-12>` — filter by month

### 3.5 Duplicate Detection Engine

**Algorithm:**
1. Group photos by file size
2. Within same-size groups, compare first 50 chars of filename
3. Flag as "likely duplicate" if size within 1KB AND similar name
4. Present pairs in terminal output
5. Option: `nmap --dup --clean` → list candidates for deletion (never auto-delete)

### 3.6 Media Timeline UI

**New Media screen tab: Timeline**
- Vertical timeline grouped by month/year
- Section headers: "April 2026 (48 photos)"
- Scrollable photo grid within each section
- Jump-to-year shortcut bar on right edge

### 3.7 Stats v2

Additional stats in `stats` tool and Stats app:
- Day-of-week photo frequency (when do you take most photos?)
- Photo count trend chart (month-over-month)
- Top 10 largest files list
- "Camera vs Screenshots" breakdown

### 3.8 Custom Themes

**Available themes (Settings → Appearance):**
- 🖤 **Dark** (default) — `#0A0A0F` bg, cyan accent
- ⬛ **AMOLED Black** — pure `#000000` bg
- 💚 **Hacker Green** — `#0A0A0F` bg, `#00FF41` green accent (Matrix)
- 💙 **Cyber Blue** — `#080D1A` bg, `#4488FF` blue accent
- 🔴 **Kali Red** — `#0A0005` bg, `#FF004C` red accent (Kali Linux inspired)

### 3.9 Terminal Scripting (Phase 3 Bonus)

Simple script runner:
- Create `.pos` script files (PocketOS Script)
- Run with: `run myscript.pos`
- Supports: sequential commands, comments with `#`
- Example:
```bash
# My daily scan script
nmap -p --year 2026
stats media
logs --tail 10
```

### 3.10 Phase 3 Build Checklist

- [ ] pkg install/remove/list/update/info
- [ ] search tool (full flags)
- [ ] notes tool + Notes UI app
- [ ] nmap v2: --size, --dup, --sort, --limit, --month
- [ ] Duplicate detection engine
- [ ] Media timeline view
- [ ] Stats v2 (charts, trends)
- [ ] 5 custom themes
- [ ] Settings: all theme + terminal options
- [ ] PocketOS Script (.pos) runner
- [ ] Calculator mini app
- [ ] Timer mini app
- [ ] Text editor mini app
- [ ] Changelog screen
- [ ] iOS build + TestFlight submission
- [ ] Web build (Flutter Web, limited)

---

*Document End — PocketOS Pro Master PRD v1.0*  
*Built with the philosophy: "Real tools. Real data. Real OS."*
