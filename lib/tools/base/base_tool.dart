import 'dart:async';
import '../../core/kernel/command_parser.dart';

enum OutputType { system, success, error, warning, info, command, progress }

class ToolOutputLine {
  final String text;
  final OutputType type;
  final bool animated;

  const ToolOutputLine(this.text, {this.type = OutputType.system, this.animated = false});
}

abstract class BaseTool {
  String get name;
  String get version;
  String get description;
  String get helpText;
  List<String> get supportedFlags;

  Stream<ToolOutputLine> execute(ParsedCommand command);
  String? validateArgs(ParsedCommand command);
}
