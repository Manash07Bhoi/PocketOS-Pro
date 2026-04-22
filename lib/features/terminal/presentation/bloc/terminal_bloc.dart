import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../tools/base/base_tool.dart';
import '../../../../core/kernel/command_dispatcher.dart';
import 'terminal_event.dart';
import 'terminal_state.dart';
import '../../../../tools/nmap/nmap_tool.dart';
import '../../../../features/media/data/repositories/media_repository_impl.dart';

class TerminalBloc extends Bloc<TerminalEvent, TerminalState> {
  final List<String> _history = [];
  int _historyIndex = -1;
  late final CommandDispatcher _dispatcher;

  TerminalBloc() : super(const TerminalIdle(lines: [], prompt: 'user@pocketos:~\$')) {
    final toolRegistry = <String, BaseTool>{
       'nmap': NmapTool(MediaRepositoryImpl()),
    };
    _dispatcher = CommandDispatcher(this, toolRegistry);

    on<SubmitCommand>(_onSubmitCommand);
    on<ClearTerminal>(_onClearTerminal);
    on<NavigateHistory>(_onNavigateHistory);
    on<CancelExecution>(_onCancelExecution);
    on<TerminalOutputReceived>(_onTerminalOutputReceived);
    on<ExecutionCompleted>(_onExecutionCompleted);
  }

  void setToolRegistry(Map<String, BaseTool> toolRegistry) {
    _dispatcher = CommandDispatcher(this, toolRegistry);
  }

  Future<void> _onSubmitCommand(SubmitCommand event, Emitter<TerminalState> emit) async {
    final input = event.input.trim();
    if (input.isEmpty) return;

    _history.add(input);
    _historyIndex = _history.length;

    final updatedLines = List<ToolOutputLine>.from(state.lines)..add(ToolOutputLine('${state.prompt} $input', type: OutputType.command));
    emit(TerminalExecuting(lines: updatedLines, prompt: state.prompt, activeCommand: input));
    _dispatcher.dispatch(input);
  }

  void _onClearTerminal(ClearTerminal event, Emitter<TerminalState> emit) {
    emit(TerminalIdle(lines: const [], prompt: state.prompt));
  }

  void _onCancelExecution(CancelExecution event, Emitter<TerminalState> emit) {
    _dispatcher.cancelActiveExecution();
  }

  void _onNavigateHistory(NavigateHistory event, Emitter<TerminalState> emit) {
    if (_history.isEmpty) return;
    if (event.direction == HistoryDirection.up) {
      if (_historyIndex > 0) _historyIndex--;
    } else {
      if (_historyIndex < _history.length - 1) {
        _historyIndex++;
      } else {
        _historyIndex = _history.length;
        emit(TerminalIdle(lines: state.lines, prompt: state.prompt, currentInput: ''));
        return;
      }
    }
    emit(TerminalIdle(lines: state.lines, prompt: state.prompt, currentInput: _history[_historyIndex]));
  }

  void _onTerminalOutputReceived(TerminalOutputReceived event, Emitter<TerminalState> emit) {
    final updatedLines = List<ToolOutputLine>.from(state.lines)..add(event.outputLine);
    if (state is TerminalExecuting) {
      emit(TerminalExecuting(lines: updatedLines, prompt: state.prompt, activeCommand: (state as TerminalExecuting).activeCommand));
    } else {
      emit(TerminalIdle(lines: updatedLines, prompt: state.prompt));
    }
  }

  void _onExecutionCompleted(ExecutionCompleted event, Emitter<TerminalState> emit) {
     emit(TerminalIdle(lines: state.lines, prompt: state.prompt));
  }
}
