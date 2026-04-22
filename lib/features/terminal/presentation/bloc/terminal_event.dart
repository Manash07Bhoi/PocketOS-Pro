import 'package:equatable/equatable.dart';

enum HistoryDirection { up, down }

sealed class TerminalEvent extends Equatable {
  const TerminalEvent();
  @override List<Object?> get props => [];
}

class SubmitCommand extends TerminalEvent {
  final String input;
  const SubmitCommand(this.input);
  @override List<Object?> get props => [input];
}

class ClearTerminal extends TerminalEvent {}

class NavigateHistory extends TerminalEvent {
  final HistoryDirection direction;
  const NavigateHistory(this.direction);
  @override List<Object?> get props => [direction];
}

class CancelExecution extends TerminalEvent {}

class TerminalOutputReceived extends TerminalEvent {
  final dynamic outputLine;
  const TerminalOutputReceived(this.outputLine);
  @override List<Object?> get props => [outputLine];
}

class ExecutionCompleted extends TerminalEvent {}
