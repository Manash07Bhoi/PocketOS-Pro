import 'dart:async';
import 'package:intl/intl.dart';
import 'command_parser.dart';
import 'event_bus.dart';
import '../../tools/base/base_tool.dart';
import '../../features/terminal/presentation/bloc/terminal_bloc.dart';
import '../../features/terminal/presentation/bloc/terminal_event.dart';
import '../utils/logger.dart';
import '../utils/system_log_entry.dart';

class CommandDispatcher {
  final TerminalBloc _terminalBloc;
  late final Map<String, BaseTool> _toolRegistry;
  StreamSubscription<ToolOutputLine>? _activeToolSubscription;

  CommandDispatcher(this._terminalBloc, this._toolRegistry);

  Future<void> dispatch(String input) async {
    final parsed = CommandParser.parse(input);
    if (parsed.command.isEmpty) {
      _terminalBloc.add(ExecutionCompleted());
      return;
    }

    if (_isBuiltinCommand(parsed.command)) {
      await _executeBuiltin(parsed);
      return;
    }

    final tool = _toolRegistry[parsed.command];
    if (tool != null) {
      await _executeTool(tool, parsed);
      return;
    }

    _terminalBloc.add(TerminalOutputReceived(ToolOutputLine('Command not found: ${parsed.command}', type: OutputType.error)));
    _terminalBloc.add(ExecutionCompleted());
  }

  void cancelActiveExecution() {
    _activeToolSubscription?.cancel();
    _activeToolSubscription = null;
    _terminalBloc.add(TerminalOutputReceived(const ToolOutputLine('^C (Execution cancelled)', type: OutputType.warning)));
    _terminalBloc.add(ExecutionCompleted());
  }

  bool _isBuiltinCommand(String command) {
    return ['help', 'clear', 'exit', 'open', 'date', 'whoami', 'uname', 'logs'].contains(command);
  }

  Future<void> _executeBuiltin(ParsedCommand parsed) async {
    switch (parsed.command) {
      case 'clear':
        _terminalBloc.add(ClearTerminal());
        break;
      case 'help':
        if (parsed.positionalArgs.isNotEmpty) {
          final target = parsed.positionalArgs.first;
          if (_toolRegistry.containsKey(target)) {
             _terminalBloc.add(TerminalOutputReceived(ToolOutputLine(_toolRegistry[target]!.helpText)));
          } else {
             _terminalBloc.add(TerminalOutputReceived(ToolOutputLine('No manual entry for $target', type: OutputType.error)));
          }
        } else {
          _terminalBloc.add(TerminalOutputReceived(const ToolOutputLine('Available commands:', type: OutputType.info)));
          _terminalBloc.add(TerminalOutputReceived(const ToolOutputLine('  help, clear, exit, open, date, whoami, uname, logs', type: OutputType.system)));
          if (_toolRegistry.isNotEmpty) {
            _terminalBloc.add(TerminalOutputReceived(const ToolOutputLine('\nInstalled tools:', type: OutputType.info)));
            for (final tool in _toolRegistry.values) {
              _terminalBloc.add(TerminalOutputReceived(ToolOutputLine('  ${tool.name.padRight(10)} - ${tool.description}', type: OutputType.system)));
            }
          }
        }
        break;
      case 'open':
        if (parsed.positionalArgs.isEmpty) {
          _terminalBloc.add(TerminalOutputReceived(const ToolOutputLine('Usage: open <app_name>', type: OutputType.error)));
        } else {
          final app = parsed.positionalArgs.first.toLowerCase();
          _terminalBloc.add(TerminalOutputReceived(ToolOutputLine('Opening $app...', type: OutputType.info)));
          String route = '';
          switch (app) {
            case 'media': route = '/media'; break;
            case 'files': route = '/files'; break;
            // Phase 3 Features:
            // case 'stats': route = '/stats'; break;
            // case 'settings': route = '/settings'; break;
          }
          if (route.isNotEmpty) {
            SystemEventBus.instance.emit(NavigationEvent(route));
          } else {
            _terminalBloc.add(TerminalOutputReceived(ToolOutputLine('App not found or not available in Phase 2: $app', type: OutputType.error)));
          }
        }
        break;
      case 'date':
        final formatted = DateFormat('EEE MMM dd HH:mm:ss yyyy').format(DateTime.now());
        _terminalBloc.add(TerminalOutputReceived(ToolOutputLine(formatted, type: OutputType.system)));
        break;
      case 'whoami':
        _terminalBloc.add(TerminalOutputReceived(const ToolOutputLine('user', type: OutputType.system)));
        break;
      case 'uname':
        final isAll = parsed.flags.containsKey('-a') || parsed.flags.containsKey('--all');
        _terminalBloc.add(TerminalOutputReceived(ToolOutputLine(isAll ? 'PocketOS Kernel 1.0.0-pro user@pocketos Mobile' : 'PocketOS', type: OutputType.system)));
        break;
      case 'logs':
         if (parsed.flags.containsKey('--clear')) {
            await AppLogger.clearLogs();
            _terminalBloc.add(TerminalOutputReceived(const ToolOutputLine('System logs cleared.', type: OutputType.success)));
         } else {
            int limit = 50;
            if (parsed.flags.containsKey('--tail')) {
              limit = int.tryParse(parsed.flags['--tail'] ?? '50') ?? 50;
            }

            LogLevel? levelFilter;
            if (parsed.flags.containsKey('--level')) {
               final lvlStr = parsed.flags['--level']?.toLowerCase();
               if (lvlStr == 'error') levelFilter = LogLevel.error;
               if (lvlStr == 'warn') levelFilter = LogLevel.warn;
               if (lvlStr == 'info') levelFilter = LogLevel.info;
               if (lvlStr == 'debug') levelFilter = LogLevel.debug;
            }

            final sourceFilter = parsed.flags['--source'];

            final logs = AppLogger.getLogs(limit: limit, level: levelFilter, source: sourceFilter);

            if (logs.isEmpty) {
              _terminalBloc.add(TerminalOutputReceived(const ToolOutputLine('No logs found.', type: OutputType.info)));
            } else {
              for (final log in logs) {
                final time = DateFormat('HH:mm:ss').format(log.timestamp);
                final lvlStr = log.level.name.toUpperCase().padRight(5);
                final srcStr = log.source.padRight(12);

                OutputType type = OutputType.system;
                if (log.level == LogLevel.error) type = OutputType.error;
                if (log.level == LogLevel.warn) type = OutputType.warning;

                _terminalBloc.add(TerminalOutputReceived(
                   ToolOutputLine('[$time] [$lvlStr] [$srcStr] ${log.message}', type: type)
                ));
              }
            }
         }
        break;
    }
    _terminalBloc.add(ExecutionCompleted());
  }

  Future<void> _executeTool(BaseTool tool, ParsedCommand parsed) async {
    final error = tool.validateArgs(parsed);
    if (error != null) {
      _terminalBloc.add(TerminalOutputReceived(ToolOutputLine(error, type: OutputType.error)));
      _terminalBloc.add(ExecutionCompleted());
      return;
    }
    _activeToolSubscription = tool.execute(parsed).listen(
      (line) => _terminalBloc.add(TerminalOutputReceived(line)),
      onError: (e) => _terminalBloc.add(TerminalOutputReceived(ToolOutputLine('Tool error: $e', type: OutputType.error))),
      onDone: () {
        _activeToolSubscription = null;
        _terminalBloc.add(ExecutionCompleted());
      },
    );
  }
}
