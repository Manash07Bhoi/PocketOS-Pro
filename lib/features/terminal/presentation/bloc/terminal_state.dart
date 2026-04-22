import 'package:equatable/equatable.dart';
import '../../../../tools/base/base_tool.dart';

sealed class TerminalState extends Equatable {
  final List<ToolOutputLine> lines;
  final String prompt;
  final String currentInput;

  const TerminalState({required this.lines, required this.prompt, required this.currentInput});
  @override List<Object?> get props => [lines, prompt, currentInput];
}

class TerminalIdle extends TerminalState {
  const TerminalIdle({required super.lines, required super.prompt, super.currentInput = ''});
}

class TerminalExecuting extends TerminalState {
  final String activeCommand;
  const TerminalExecuting({required super.lines, required super.prompt, required this.activeCommand, super.currentInput = ''});
  @override List<Object?> get props => [lines, prompt, currentInput, activeCommand];
}

class TerminalError extends TerminalState {
  final String error;
  const TerminalError({required super.lines, required super.prompt, required this.error, super.currentInput = ''});
  @override List<Object?> get props => [lines, prompt, currentInput, error];
}
