# PROJECT SOP — PocketOS Pro
## Standard Operating Procedure for AI-Assisted Development
### "How This OS Is Built, Verified, and Shipped"

**Document Version:** 1.0  
**Applies To:** Google Jules AI coding agent + any developer working on PocketOS Pro  
**Governing Rule:** This SOP overrides any general AI coding assumptions. When in doubt, this document wins.

---

## PART 1 — PROJECT PHILOSOPHY

PocketOS Pro is built on a single non-negotiable principle: **everything is real**. Every number on every screen comes from a real data source. Every command produces real output from real device data. Every tool writes to a real database. There are no hardcoded counts, no placeholder images, no simulated scan results, no "TODO: connect to real data" stubs left in shipped code.

This principle exists because PocketOS is positioning itself as a real OS, not a demo. When a user runs `nmap -p` and sees "320 photos found," those 320 photos must genuinely exist on their device. When `stats storage` shows "69.8% used," it must read the actual disk usage via `disk_space`. Anything less destroys the trust that the OS metaphor requires.

The second governing principle is **backend before frontend**. For every feature, every phase, every step — the data layer is built and verified before any widget is written. A screen must have a real service and a real repository returning real data before the BLoC is written, and the BLoC must be complete before the UI widget is built. This prevents the common AI-coding failure mode of building beautiful UI with no working data behind it.

---

## PART 2 — DEVELOPMENT WORKFLOW

### 2.1 The Five-Layer Build Order

For every feature, the AI coding agent follows this exact sequence. Skipping layers is not permitted.

**Layer 1 — Database:** If the feature needs persistent storage, define the SQLite table schema or Hive box structure first. Write the `CREATE TABLE` statement with all columns, constraints, and indexes. Run the migration. Verify the table exists by querying it. Insert one test row manually, query it back, delete it. Only after this verification does work proceed.

**Layer 2 — Repository:** Write the repository interface (abstract class in the domain layer) and its implementation (in the data layer). The implementation contains all raw SQL queries or Hive operations. Write every method the feature needs. Each method must be callable in isolation — the agent writes a temporary test call in `main.dart`, runs it in debug mode, verifies the result. Temporary test calls are removed before proceeding to the next layer.

**Layer 3 — Service:** The service orchestrates repositories and business logic. It knows nothing about Flutter widgets. It speaks in domain entities, not database models. Write the service, wire it into `get_it`, verify it resolves without error.

**Layer 4 — BLoC:** Write the BLoC events, states, and handler methods. The BLoC calls the service. It must handle all three state paths: loading/running, success, and error. Every `emit()` call must be reachable — there must be no dead code paths. Every `Equatable` `props` list must include all state fields.

**Layer 5 — UI:** Write the widgets. Every widget is either a `BlocBuilder`, a `BlocListener`, or a pure display widget with no business logic. Loading states show shimmer. Empty states show the terminal-style message. Error states show the error with a retry button.

### 2.2 Per-Feature Checklist

Before marking any feature as complete, the agent confirms all of the following:

The SQLite table is created by the migration and has the correct schema (confirmed via a SELECT query). The repository's every method returns real data — no method returns a hardcoded list. The service's every method has been called at least once in a real debug run. The BLoC covers loading, success, and error states. The UI shows loading shimmer during async operations. The UI shows an empty state when the data source returns zero results. The UI shows an error state when the service throws. The feature works after the app is killed and relaunched (data persists). `flutter analyze` has zero issues after adding this feature. The feature is accessible from BOTH the terminal and the graphical UI (unless it is a purely visual feature with no terminal equivalent).

---

## PART 3 — CODING STANDARDS

### 3.1 Naming Conventions

Files use `snake_case.dart` throughout. Classes use `PascalCase`. Variables and methods use `camelCase`. Constants use `kCamelCase` (e.g., `kDefaultPrompt`). Hive box names use `snake_case` strings. SQLite table names use `snake_case`. SQLite column names use `snake_case`. Route constants are defined in `router.dart` as `static const String kRouteName = '/route'` and used everywhere — never type route strings inline.

### 3.2 Import Organization

Every Dart file organizes imports in three sections separated by blank lines: (1) `dart:` imports, (2) `package:` imports, and (3) relative project imports. Within each section, alphabetical ordering. No unused imports — `flutter analyze` catches these and they must be fixed immediately.

### 3.3 No Business Logic in Widgets

Widgets are display-only. They call BLoC events on user interaction and read BLoC state to decide what to display. They never directly call services, repositories, or database operations. They never compute derived data from raw data — that computation belongs in the service or use case layer. A widget may call `context.read<SomeBloc>().add(SomeEvent())` and nothing more complex.

### 3.4 Error Handling Rules

Every async operation is wrapped in a `try/catch`. Caught exceptions are logged via `AppLogger.log(error.toString(), level: LogLevel.error, source: 'feature_name')` before re-throwing or converting to an error state. The `rethrow` keyword is used when the caller needs to handle the exception. The BLoC handles the final exception and emits an error state with the actual exception message — never a hardcoded `"Something went wrong"`. The UI displays the actual error message from the state.

Database operations specifically use this pattern:
```dart
Future<T> _dbOperation<T>(Future<T> Function(Database db) operation) async {
  try {
    return await operation(await _getDb());
  } on DatabaseException catch (e) {
    AppLogger.log('DB error: ${e.message}', level: LogLevel.error, source: 'database');
    rethrow;
  }
}
```

### 3.5 Streams and Subscriptions

Every `StreamSubscription` is stored as an instance variable and cancelled in `dispose()`. Every `StreamController` is closed in `dispose()`. Every BLoC is closed in the widget's `dispose()` via `context.read<SomeBloc>().close()` (or better, via `BlocProvider` which handles this automatically). If a `StreamController` can receive no listeners, it uses `.broadcast()`. The `SystemEventBus` uses a broadcast controller.

### 3.6 Hive vs SQLite Decision Rule

Use SQLite for: any data that needs to be queried, filtered, sorted, or joined with other data. Any data with relationships. Any data that benefits from full-text search. Any list of items that grows unboundedly (logs, history, media cache). Use Hive for: single-object settings (one settings object, not a list). Small caches with simple key lookup. Ephemeral data (notification queue, recent searches). Data that is read frequently and written rarely.

Never use Hive as a substitute for SQLite just because it is simpler — Hive is a key-value store, not a database. Using Hive to store a list of 5,000 media items would be a critical architectural error.

---

## PART 4 — WHAT THE AI AGENT MUST NEVER DO

This section defines absolute prohibitions. These are not suggestions — they are hard stops.

**Never return hardcoded data from a repository.** If a repository method returns `[MediaFile(name: 'photo1.jpg', ...)]` with literal values, that is a critical error. Every repository reads from a real data source (SQLite, Hive, device API).

**Never use `setState` in a screen.** The only permitted use of `setState` is inside small, isolated widgets that have purely local UI state with zero business logic — for example, the expand/collapse toggle in the JSON Viewer tree. Every screen that loads data, submits commands, or navigates uses BLoC.

**Never use Provider.** The state management for PocketOS is BLoC exclusively. No `ChangeNotifier`, no `ValueNotifier`, no `Provider` package outside of the single allowed exception: `DesktopWindowManager` uses `ChangeNotifier` because window positions are local UI state with no business logic. Every other stateful component uses BLoC.

**Never create a `Text` widget with hardcoded color that does not use the theme.** All colors are read from `Theme.of(context).colorScheme` or from `AppColors` constants. If a new screen hardcodes `Color(0xFF00E5FF)` inline in a `TextStyle`, that screen will break when the user switches to a different theme. Use `AppColors.accent` from the active theme instead.

**Never call `print()` in any file.** All logging goes through `AppLogger.log()`. `print()` calls are not removed in release builds — they must never be used. `debugPrint()` is permitted in development only.

**Never write a "TODO" comment in Phase 4 or Phase 5 output.** TODOs indicate incomplete work. If a feature is not done, it is not included in the deliverable. Partial features are worse than absent features because they create confusing states.

**Never use mock packages like `mockito` in production code.** Test infrastructure is separate from production code. If the agent imports a mock package into a production file, that is an error.

**Never add any package that is not in the approved list** from the Complete PRD Part A without first explaining why it is needed and what it replaces, then confirming before installing.

---

## PART 5 — VERIFICATION PROTOCOLS

### 5.1 After Every Step

After completing any numbered step in any phase, the agent performs these checks before declaring the step complete:

`flutter analyze` — must return exactly zero issues. If there are issues, they are fixed before proceeding. No exceptions for "minor warnings."

App launch verification — the app must launch successfully on an Android emulator or device, reach the launcher screen (or appropriate phase-current screen), and not crash within 30 seconds of normal use.

Feature smoke test — the specific feature built in this step is tested with real data. For a database step, real rows are inserted and queried. For a terminal command step, the command is typed and produces real non-hardcoded output. For a UI step, the screen displays real data from the service.

### 5.2 After Every Phase

After completing all steps in a phase, a full regression test covers every feature built in all previous phases. This catches regressions introduced by architectural changes. The test is manual but structured: the agent follows the "Phase Regression Script" which is a document listing one representative action for every feature (e.g., "run `nmap -p`, verify count matches actual photos on device"). The regression script is updated as new features are added.

### 5.3 The "Real Device Test"

At the end of Phase 4 and again at the end of Phase 5, the release APK (not debug) is installed on a real Android device. This is mandatory — emulators do not accurately replicate: media permission behavior, real file system access, real `disk_space` readings, real `battery_plus` readings, real biometric authentication. If anything fails on a real device that passed on emulator, it is a blocker — fix before publishing.

---

## PART 6 — PHASE TRANSITION CRITERIA

### From Phase 2 → Phase 3
Phase 2 is complete when: the boot screen runs the full sequence and checks real permissions; the terminal accepts all built-in commands and produces real output; `nmap -p`, `nmap -v`, and `nmap --year` all return real device media counts; the media screen shows real thumbnails from `photo_manager`; the files screen lists real device directories; the stats screen shows real storage numbers.

### From Phase 3 → Phase 4
Phase 3 is complete when: `pkg install/remove` works with real SQLite persistence; the `search` tool queries real SQLite tables; the `notes` tool reads and writes to the `notes` SQLite table; nmap advanced flags (`--size`, `--sort`, `--output detail`) work correctly; the 5 themes all apply correctly app-wide.

### From Phase 4 → Phase 5
Phase 4 is complete when: all 20+ tools produce real output from real data; desktop mode opens and 3 apps can be simultaneously windowed; multi-session terminal creates, persists, and restores sessions from SQLite; the vault stores and retrieves encrypted passwords after app kill; every mini-app (calculator, timer, QR, encoder, hash, archive, clipboard, process manager, task scheduler, workspace manager, system info, log viewer, diff, color, unit converter) is fully functional with real backend data.

### Phase 5 → Publish
Phase 5 is complete when every item in the Phase 5 QA checklist is confirmed. The app is submitted to Play Store internal testing and passes review (no policy violations, no crashes in pre-launch report). Version code is 150, version name is "1.5.0".

---

## PART 7 — GIT WORKFLOW

### Branch Structure
```
main          → production releases only (tagged v1.0.0, v1.3.0, v1.5.0)
develop       → integration branch — all features merge here first
phase-2       → Phase 2 work branch
phase-3       → Phase 3 work branch
phase-4       → Phase 4 work branch
phase-5       → Phase 5 work branch
feature/xxx   → individual feature branches, branched from phase-N
```

### Commit Message Format
Every commit uses this format:
```
type(scope): short description

type: feat | fix | refactor | style | docs | test | chore
scope: terminal | media | nmap | pkg | notes | vault | desktop | etc.

Example:
feat(nmap): implement --dup flag with DuplicateDetectWorker isolate
fix(vault): prevent vault crash on first launch when no master password set
refactor(terminal): migrate command history from Hive to SQLite
```

### What Goes in .gitignore
```
# Keys and secrets
android/key.properties
*.jks
*.keystore

# Build
build/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies

# IDE
.idea/
.vscode/
*.iml

# Local data (never commit device data)
*.db
*.db-shm
*.db-wal
```

---

## PART 8 — FILE STRUCTURE RULES

### Naming of Feature Folders
Every feature under `lib/features/` follows the exact Clean Architecture structure defined in the master PRD. New features added in Phase 4 and 5 follow the same structure. No feature may have its presentation layer directly access the data layer — it must always go through the domain layer.

### Shared vs Feature-Specific Widgets
A widget belongs in `lib/shared/widgets/` if it is used in 2 or more feature screens. A widget belongs in `lib/features/X/presentation/widgets/` if it is used only within feature X. This rule prevents circular imports. No feature may import from another feature's `presentation/` folder — only from `lib/shared/`.

### Tool Modules
Every tool under `lib/tools/` must extend `BaseTool` and be registered in `ToolRegistry`. The `ToolRegistry` is a map initialized at startup: `{name: tool_instance}`. Adding a new tool requires: (1) creating the tool file, (2) registering it in `ToolRegistry`, (3) adding it to `pkg_registry.json` with its metadata. These three steps are always done together.

---

## PART 9 — DEPENDENCY UPGRADE POLICY

During Phase 4 and 5, package upgrades should be conservative. The rule: if a package works correctly, do not upgrade it mid-phase. Package upgrades happen only at phase boundaries (start of a new phase). Before upgrading, run `flutter pub outdated` and review the changelog for breaking changes. Never run `flutter pub upgrade` blindly — upgrade packages one at a time and verify the app still builds and functions after each upgrade.

---

## PART 10 — SECURITY RULES

Every security requirement from the Complete PRD Part A section 18 is a hard requirement, not a guideline.

The vault master password is stored in `flutter_secure_storage` — this uses Android Keystore and is never accessible by other apps or from a backup. The AES-256 encryption key for vault entries is derived from the master password using PBKDF2 with 100,000 iterations — this is the industry minimum for password-derived key strengthening. The `encrypt` package's `Encrypter(AES(key, mode: AESMode.gcm))` is used — GCM mode provides both encryption and authentication.

No data from the `password_vault` table may ever appear in `system_logs`. The `pass` terminal command stores command history as `pass [masked]`, not the actual command with the password visible.

The release APK is built with `--obfuscate --split-debug-info=symbols/` to enable Dart obfuscation. This does not affect functionality but makes reverse engineering harder.

---

## PART 11 — WHAT v2.0 HOLDS (DO NOT BUILD NOW)

This section documents what is deliberately excluded from v1.5 so the agent does not accidentally build v2.0 features prematurely.

Real network scanning, packet analysis, or any tool that accesses external network addresses is v2.0 and requires a real backend. The terminal `ping`, `traceroute`, `curl`, or `wget` commands do not exist in v1.5 — typing them produces: `"This command requires network access. Coming in PocketOS v2.0"`.

A real package repository server (where `pkg install` fetches from an internet endpoint) is v2.0. In v1.5, `pkg install` only works from the bundled `pkg_registry.json` asset.

A real user account system, cloud sync, or cross-device data sharing is v2.0.

A real scripting engine (beyond the basic `.pos` script runner from Phase 3) with loops, conditionals, and variables is v2.0.

A real plugin/extension API that lets third-party developers create tools is v2.0.

Browser integration (a built-in browser, or "Chrome" as mentioned) is v2.5 — do not reference it in any v1.5 code.

Anything requiring internet access without explicit permission, or any SDK that phones home for analytics, is permanently prohibited in all versions.

---

## PART 12 — AGENT COMMUNICATION PROTOCOL

When Google Jules or any AI coding agent reaches a decision point — an ambiguity in the PRD, a dependency conflict, a design question, a blocker — it stops and reports the issue in this format:

```
AGENT STOP — DECISION REQUIRED

Phase: [current phase]
Step: [current step number]
Issue type: [Ambiguity | Conflict | Blocker | Architecture Question]
Description: [clear description of the issue]
Options considered:
  A) [first option and its tradeoffs]
  B) [second option and its tradeoffs]
Recommendation: [the agent's preferred option with reasoning]
Blocking: [yes if work cannot continue without this decision | no if work can continue elsewhere]
```

The agent does not make architectural assumptions and proceed. It does not silently pick the easier path. It surfaces the decision with full context so the product owner (Roshan) can make an informed choice.

This protocol applies to: choosing between two valid implementation approaches that have different tradeoffs, any time adding a package not in the approved list seems necessary, any time a device API behaves differently than the PRD assumes, any time a performance target seems unreachable with the current approach.

---

## PART 13 — THE NORTH STAR CHECK

Before submitting any work, the agent asks this question about the feature:

**"If a user who has never seen PocketOS runs this feature for the first time on their actual phone, will the output be real, meaningful, and based on their actual device data — with zero hardcoded content?"**

If the answer is yes → ship it. If the answer is no → do not ship it.

This is the north star check. It overrides every other consideration. A beautiful UI with fake data fails this check. A working feature with an ugly UI passes it (and can be improved in Phase 5). The north star is always real data first.

---

*PROJECT SOP — PocketOS Pro v1.5*  
*This document is the law. When code and SOP conflict, fix the code.*  
*Updated at every phase boundary.*
