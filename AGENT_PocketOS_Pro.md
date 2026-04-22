# AGENT.md — PocketOS Pro
## AI Coding Agent Instructions for Google Jules

> This file is the single source of truth for all AI coding agents working on PocketOS Pro.
> Read this ENTIRE file before writing a single line of code.

---

## PROJECT IDENTITY

| Field | Value |
|-------|-------|
| **Project Name** | PocketOS Pro |
| **App Display Name** | PocketOS |
| **Package ID** | com.pocketos.pro |
| **Version** | 1.0.0+1 |
| **Framework** | Flutter (Dart) |
| **Min SDK** | Android API 26 (Android 8.0) |
| **Architecture** | Clean Architecture + BLoC |
| **State Management** | flutter_bloc |
| **Local Storage** | Hive |
| **Design System** | Material Design 3 (dark only) |
| **Network** | ZERO — fully offline, no HTTP calls |
| **Backend** | NONE — no server, no Firebase, no cloud |

---

## CRITICAL RULES (READ BEFORE ANYTHING ELSE)

### ❌ NEVER DO THESE — ABSOLUTE PROHIBITIONS

```
❌ Never use fake/hardcoded data for nmap scan results
❌ Never use fake file counts, sizes, or dates
❌ Never make any HTTP requests or use any network calls
❌ Never add Firebase, Crashlytics, Analytics, or any tracking SDK
❌ Never implement network scanning (this is NOT a hacking tool)
❌ Never add a premium/paywall feature
❌ Never use Provider — use ONLY flutter_bloc + BLoC pattern
❌ Never skip Clean Architecture layers (data → domain → presentation)
❌ Never put business logic in UI widgets or screens
❌ Never put more than one BLoC event in a single BLoC class that exceeds its scope
❌ Never use setState() except for purely local UI state with zero business logic
❌ Never create circular dependencies between features
❌ Never import a feature's internal files from another feature (use shared/ only)
❌ Never delete or modify existing Phase 1 structure unless explicitly told to
❌ Never auto-delete any user files — only suggest, never execute
❌ Never add dependencies not listed in the approved list below
```

### ✅ ALWAYS DO THESE — MANDATORY STANDARDS

```
✅ Use REAL device data — photo_manager for real media metadata
✅ Stream nmap results progressively (don't wait for all results)
✅ Every tool must extend BaseTool abstract class
✅ All Hive operations wrapped in try/catch
✅ All permission requests go through PermissionService
✅ Every screen must have a corresponding BLoC (no stateful screens without BLoC)
✅ All strings in const or l10n (no magic strings in business logic)
✅ Every BLoC state must extend Equatable
✅ All async operations must handle errors with proper error states
✅ Use JetBrains Mono for ALL terminal/monospace text
✅ Use Inter for ALL UI (non-terminal) text
✅ Background color MUST be #0A0A0F everywhere
✅ Primary accent MUST be #00E5FF (cyan)
✅ Test on Android API 26, 29, 33 minimum
```

---

## PROJECT STRUCTURE (MANDATORY — DO NOT DEVIATE)

```
pocketos_pro/
├── android/
│   └── app/
│       └── src/main/
│           └── AndroidManifest.xml
├── lib/
│   ├── core/
│   │   ├── kernel/
│   │   │   ├── command_parser.dart
│   │   │   ├── command_dispatcher.dart
│   │   │   ├── tool_registry.dart
│   │   │   ├── event_bus.dart
│   │   │   └── system_state.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_typography.dart
│   │   ├── utils/
│   │   │   ├── logger.dart
│   │   │   ├── permission_service.dart
│   │   │   ├── router.dart
│   │   │   └── formatters.dart
│   │   └── constants/
│   │       ├── commands.dart
│   │       └── app_constants.dart
│   │
│   ├── features/
│   │   ├── boot/
│   │   │   ├── presentation/
│   │   │   │   └── boot_screen.dart
│   │   │   └── bloc/
│   │   │       ├── boot_bloc.dart
│   │   │       ├── boot_event.dart
│   │   │       └── boot_state.dart
│   │   ├── launcher/
│   │   │   ├── presentation/
│   │   │   │   ├── launcher_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── app_icon_tile.dart
│   │   │   │       └── status_bar.dart
│   │   │   └── bloc/
│   │   │       ├── launcher_bloc.dart
│   │   │       ├── launcher_event.dart
│   │   │       └── launcher_state.dart
│   │   ├── terminal/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── command_model.dart
│   │   │   │   │   └── output_line_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── terminal_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── parsed_command.dart
│   │   │   │   │   └── tool_output.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── terminal_repository.dart
│   │   │   │   └── use_cases/
│   │   │   │       ├── execute_command.dart
│   │   │   │       └── get_history.dart
│   │   │   └── presentation/
│   │   │       ├── terminal_screen.dart
│   │   │       ├── widgets/
│   │   │       │   ├── terminal_output_line.dart
│   │   │       │   ├── terminal_prompt.dart
│   │   │       │   └── terminal_input_field.dart
│   │   │       └── bloc/
│   │   │           ├── terminal_bloc.dart
│   │   │           ├── terminal_event.dart
│   │   │           └── terminal_state.dart
│   │   ├── media/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── media_file_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── media_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── media_file.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── media_repository.dart
│   │   │   │   └── use_cases/
│   │   │   │       ├── scan_media.dart
│   │   │   │       └── filter_media.dart
│   │   │   └── presentation/
│   │   │       ├── media_screen.dart
│   │   │       └── bloc/
│   │   │           ├── media_bloc.dart
│   │   │           ├── media_event.dart
│   │   │           └── media_state.dart
│   │   ├── files/
│   │   │   └── [same clean arch structure]
│   │   └── stats/
│   │       └── [same clean arch structure]
│   │
│   ├── tools/
│   │   ├── base/
│   │   │   └── base_tool.dart
│   │   ├── nmap/
│   │   │   ├── nmap_tool.dart
│   │   │   └── nmap_result.dart
│   │   ├── fs/
│   │   │   └── fs_tool.dart
│   │   └── stats/
│   │       └── stats_tool.dart
│   │
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── glass_container.dart
│   │   │   ├── neon_text.dart
│   │   │   ├── os_button.dart
│   │   │   └── progress_bar.dart
│   │   └── models/
│   │       └── hive_tool_model.dart
│   │
│   ├── app.dart
│   └── main.dart
│
├── pubspec.yaml
└── AGENT.md
```

---

## APPROVED DEPENDENCIES

Only use these packages. Adding ANY other package requires explicit approval.

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5

  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.2

  # Media Access (REAL device media)
  photo_manager: ^3.0.0

  # Permissions
  permission_handler: ^11.3.0

  # Fonts
  google_fonts: ^6.1.0

  # Date/Time
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.8
  hive_generator: ^2.0.1
  flutter_lints: ^3.0.0
```

---

## COLOR SYSTEM (EXACT HEX — DO NOT MODIFY)

```dart
// lib/core/theme/app_colors.dart

class AppColors {
  // Backgrounds
  static const background     = Color(0xFF0A0A0F);  // MUST be this exact value
  static const surface        = Color(0xFF111118);
  static const surfaceElev    = Color(0xFF1A1A24);
  static const border         = Color(0xFF2A2A38);

  // Accents
  static const cyan           = Color(0xFF00E5FF);  // PRIMARY ACCENT
  static const cyanDim        = Color(0xFF0097B2);
  static const green          = Color(0xFF00FF88);  // success
  static const red            = Color(0xFFFF4444);  // error
  static const yellow         = Color(0xFFFFD700);  // warning
  static const blue           = Color(0xFF4488FF);  // info

  // Text
  static const textPrimary    = Color(0xFFE8E8F0);
  static const textSecondary  = Color(0xFF8888A0);
  static const textDim        = Color(0xFF444458);

  // Terminal specific
  static const termBg         = Color(0xFF070710);
  static const termCursor     = Color(0xFF00E5FF);
  static const termPrompt     = Color(0xFF00FF88);
}
```

---

## TYPOGRAPHY RULES

```dart
// Terminal text — ALWAYS JetBrains Mono
TextStyle terminalText = GoogleFonts.jetBrainsMono(
  color: AppColors.textPrimary,
  fontSize: 13,
  height: 1.5,
);

// UI text — ALWAYS Inter
TextStyle uiHeading = GoogleFonts.inter(
  color: AppColors.textPrimary,
  fontSize: 18,
  fontWeight: FontWeight.w600,
);
```

---

## BLOC PATTERN STANDARDS

### Every BLoC must follow this exact pattern:

```dart
// EVENTS — sealed class
sealed class TerminalEvent extends Equatable {
  const TerminalEvent();
  @override List<Object?> get props => [];
}

class SubmitCommand extends TerminalEvent {
  final String input;
  const SubmitCommand(this.input);
  @override List<Object?> get props => [input];
}

// STATES — sealed class
sealed class TerminalState extends Equatable {
  const TerminalState();
  @override List<Object?> get props => [];
}

class TerminalIdle extends TerminalState {
  final List<OutputLine> lines;
  final String prompt;
  const TerminalIdle({required this.lines, required this.prompt});
  @override List<Object?> get props => [lines, prompt];
}

// BLOC
class TerminalBloc extends Bloc<TerminalEvent, TerminalState> {
  TerminalBloc() : super(const TerminalIdle(lines: [], prompt: 'user@pocketos:~\$')) {
    on<SubmitCommand>(_onSubmitCommand);
  }
  
  Future<void> _onSubmitCommand(SubmitCommand event, Emitter emit) async {
    // Implementation
  }
}
```

---

## COMMAND PARSER SPECIFICATION

```dart
// lib/core/kernel/command_parser.dart

class ParsedCommand {
  final String command;         // e.g. "nmap"
  final Map<String, String?> flags; // e.g. {"-p": null, "-d": "01.04.2026"}
  final List<String> positionalArgs; // e.g. ["file.txt"]
  final String rawInput;        // original input string
}

// Parser behavior:
// "nmap -p"                → command:"nmap", flags:{"-p":null}
// "nmap -d 01.04.2026 -p"  → command:"nmap", flags:{"-d":"01.04.2026", "-p":null}
// "open media"             → command:"open", positionalArgs:["media"]
// "pkg install nmap"       → command:"pkg", positionalArgs:["install","nmap"]
```

---

## BASE TOOL CONTRACT

```dart
// lib/tools/base/base_tool.dart

abstract class BaseTool {
  String get name;
  String get version;
  String get description;
  String get helpText;
  List<String> get supportedFlags;

  // Returns a stream of output lines
  Stream<ToolOutputLine> execute(ParsedCommand command);

  // Returns null if valid, error string if invalid
  String? validateArgs(ParsedCommand command);
}

class ToolOutputLine {
  final String text;
  final OutputType type;
  final bool animated; // if true, characters render one-by-one
  const ToolOutputLine(this.text, {this.type = OutputType.system, this.animated = false});
}

enum OutputType { system, success, error, warning, info, command, progress }
```

---

## NMAP IMPLEMENTATION GUIDE

```dart
// lib/tools/nmap/nmap_tool.dart

class NmapTool extends BaseTool {
  final MediaRepository mediaRepo;
  
  @override
  Stream<ToolOutputLine> execute(ParsedCommand cmd) async* {
    // 1. Validate
    final error = validateArgs(cmd);
    if (error != null) {
      yield ToolOutputLine('Error: $error', type: OutputType.error);
      return;
    }
    
    // 2. Check permission
    final hasPermission = await PermissionService.hasMediaPermission();
    if (!hasPermission) {
      yield ToolOutputLine('Permission denied. Run: permission grant media', type: OutputType.error);
      return;
    }
    
    // 3. Build filter from flags
    final filter = NmapFilter.fromCommand(cmd);
    
    // 4. Show starting message
    yield ToolOutputLine('Starting nmap scan...', type: OutputType.info);
    yield ToolOutputLine('Target: ${filter.targetLabel}', type: OutputType.info);
    if (filter.dateFilter != null) {
      yield ToolOutputLine('Filter: ${filter.dateFilter}', type: OutputType.info);
    }
    
    // 5. Stream REAL results from device
    int count = 0;
    int totalBytes = 0;
    
    await for (final media in mediaRepo.scanStream(filter)) {
      count++;
      totalBytes += media.sizeBytes;
      
      // Yield progress every 50 items
      if (count % 50 == 0) {
        yield ToolOutputLine(
          'Scanning... $count files found',
          type: OutputType.progress,
        );
      }
    }
    
    // 6. Final output — REAL data only
    yield ToolOutputLine('');
    yield ToolOutputLine('✔ Scan complete', type: OutputType.success);
    yield ToolOutputLine('  Files found:    $count', type: OutputType.system);
    yield ToolOutputLine('  Total size:     ${formatBytes(totalBytes)}', type: OutputType.system);
  }
}
```

---

## BOOT SEQUENCE IMPLEMENTATION

```dart
// The boot sequence MUST show these exact lines with these exact delays:

final bootSteps = [
  BootStep('Initializing PocketOS v1.0...', delay: 0),
  BootStep('Loading kernel modules...       [OK]', delay: 300),
  BootStep('Starting terminal engine...     [OK]', delay: 500),
  BootStep('Loading tool registry...        [OK]', delay: 400),
  BootStep('Mounting file system...         [OK]', delay: 350),
  BootStep('Requesting media permissions... [OK]', delay: 600),
  BootStep('Starting launcher...            [OK]', delay: 300),
  BootStep('', delay: 200),
  BootStep('PocketOS ready. Welcome, user.', delay: 500),
];

// Total boot time: ~3.15 seconds
// After last step: 500ms pause → navigate to Launcher
```

---

## TERMINAL PROMPT FORMAT

```dart
// lib/core/constants/app_constants.dart

// Default prompt
const String kDefaultPrompt = 'user@pocketos:~\$';

// Directory-aware prompt
String buildPrompt(String currentPath) {
  final shortPath = currentPath.replaceFirst('/home/user', '~');
  return 'user@pocketos:$shortPath\$';
}

// Examples:
// user@pocketos:~$
// user@pocketos:~/photos$
// user@pocketos:~/files/DCIM$
```

---

## HIVE TYPE IDs (RESERVED — DO NOT CHANGE)

```dart
// Type IDs are permanent once data is stored
// NEVER change these numbers

@HiveType(typeId: 0)  InstalledTool
@HiveType(typeId: 1)  OutputLineModel
@HiveType(typeId: 2)  CommandHistoryItem
@HiveType(typeId: 3)  SystemLogEntry
@HiveType(typeId: 4)  NoteModel
@HiveType(typeId: 5)  ScanCacheEntry
```

---

## ANDROID MANIFEST REQUIREMENTS

```xml
<!-- AndroidManifest.xml must have ALL of these -->

<!-- Media permissions -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
<!-- Fallback for Android < 13 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32"/>

<!-- App label -->
<application android:label="PocketOS" ...>
```

---

## ROUTING SYSTEM

```dart
// lib/core/utils/router.dart

// Routes
const String kSplashRoute     = '/';
const String kBootRoute       = '/boot';
const String kLauncherRoute   = '/launcher';
const String kTerminalRoute   = '/terminal';
const String kMediaRoute      = '/media';
const String kFilesRoute      = '/files';
const String kStatsRoute      = '/stats';
const String kNotesRoute      = '/notes';
const String kSettingsRoute   = '/settings';
const String kPermissionRoute = '/permission';

// Navigation rules:
// /          → /boot (always, no back)
// /boot      → /launcher (always, no back)
// /launcher  → /terminal (back: /launcher)
// /launcher  → /media    (back: /launcher)
// /terminal  → exit = pop to /launcher
```

---

## PERMISSION SERVICE

```dart
// lib/core/utils/permission_service.dart

class PermissionService {
  static Future<bool> hasMediaPermission() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkVersion();
      if (sdkInt >= 33) {
        return await Permission.photos.isGranted &&
               await Permission.videos.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    }
    return false;
  }

  static Future<PermissionResult> requestMediaPermission() async {
    // Platform-aware permission request
    // Returns: granted | denied | permanentlyDenied
  }
}
```

---

## EVENT BUS (TERMINAL ↔ UI SYNC)

```dart
// lib/core/kernel/event_bus.dart

class SystemEventBus {
  static final SystemEventBus _instance = SystemEventBus._();
  static SystemEventBus get instance => _instance;
  
  final _controller = StreamController<SystemEvent>.broadcast();
  Stream<SystemEvent> get stream => _controller.stream;
  
  void emit(SystemEvent event) => _controller.add(event);
}

sealed class SystemEvent {}
class OpenAppEvent extends SystemEvent { final String appName; ... }
class CloseAppEvent extends SystemEvent { final String appName; ... }
class ToolExecutedEvent extends SystemEvent { final String tool, command; ... }
class NavigationEvent extends SystemEvent { final String path; ... }
```

---

## LOGGER

```dart
// lib/core/utils/logger.dart

class AppLogger {
  static void log(String message, {LogLevel level = LogLevel.info, String? source}) {
    // In debug: print to console
    // In release: suppress all logs
    // Store in Hive: LogEntry(timestamp, level, source, message)
    
    assert(() {
      debugPrint('[${level.name.toUpperCase()}] ${source ?? 'system'}: $message');
      return true;
    }());
    
    _storeLog(SystemLogEntry(
      timestamp: DateTime.now(),
      level: level,
      source: source ?? 'system',
      message: message,
    ));
  }
}
```

---

## PHASE IMPLEMENTATION ORDER

### Phase 2 — Build in this exact order:

```
Step 1:  core/theme/ (colors, typography, theme)
Step 2:  core/kernel/command_parser.dart
Step 3:  tools/base/base_tool.dart
Step 4:  features/boot/ (BLoC + UI)
Step 5:  features/launcher/ (BLoC + UI)
Step 6:  features/terminal/ (full — domain → data → presentation → BLoC)
Step 7:  core/kernel/command_dispatcher.dart (wire parser to terminal BLoC)
Step 8:  Built-in commands: help, clear, exit, open, date, whoami, uname
Step 9:  features/media/ (domain → data → presentation → BLoC)
Step 10: tools/nmap/nmap_tool.dart (wire to real photo_manager)
Step 11: features/files/ (basic implementation)
Step 12: features/stats/ (basic charts with CustomPainter)
Step 13: core/kernel/event_bus.dart (terminal ↔ UI sync)
Step 14: Permission screen + PermissionService
Step 15: Settings screen
Step 16: System logs (Hive + terminal command)
Step 17: Full QA pass + release build
```

---

## CODE QUALITY STANDARDS

```
✅ All public methods have dartdoc comments
✅ No TODO comments left in Phase 2 deliverable
✅ flutter analyze returns ZERO issues
✅ No unused imports
✅ No unused variables
✅ All Hive models have generated type adapters
✅ All async gaps handled (no unawaited futures)
✅ All StreamControllers closed in dispose()
✅ All BLoCs closed in screen dispose()
✅ No hardcoded strings in business logic
```

---

## WHAT TO OUTPUT AFTER EACH PHASE STEP

After completing each numbered step above, output:
1. List of files created/modified
2. `flutter analyze` result (must be clean)
3. Confirmation that app runs without crash
4. Any blockers or decisions needed

---

## FINAL REMINDER

> PocketOS Pro is a **personal data OS**, NOT a hacking tool.  
> The `nmap` command scans **user's own photos/videos** — never networks.  
> All data stays **100% on device** — no uploads, no internet, no tracking.  
> The product must feel like **Termux** but work like **a personal data manager**.

---

*AGENT.md — PocketOS Pro v1.0*  
*Do not modify this file without updating the version number.*
