class ParsedCommand {
  final String command;
  final Map<String, String?> flags;
  final List<String> positionalArgs;
  final String rawInput;

  ParsedCommand({
    required this.command,
    required this.flags,
    required this.positionalArgs,
    required this.rawInput,
  });
}

class CommandParser {
  static ParsedCommand parse(String input) {
    if (input.trim().isEmpty) return ParsedCommand(command: '', flags: {}, positionalArgs: [], rawInput: input);
    final tokens = _tokenize(input);
    if (tokens.isEmpty) return ParsedCommand(command: '', flags: {}, positionalArgs: [], rawInput: input);

    final command = tokens.first.toLowerCase();
    final flags = <String, String?>{};
    final args = <String>[];

    int i = 1;
    while (i < tokens.length) {
      if (tokens[i].startsWith('-')) {
        if (i + 1 < tokens.length && !tokens[i + 1].startsWith('-')) {
          flags[tokens[i]] = tokens[i + 1];
          i += 2;
        } else {
          flags[tokens[i]] = null;
          i++;
        }
      } else {
        args.add(tokens[i]);
        i++;
      }
    }
    return ParsedCommand(command: command, flags: flags, positionalArgs: args, rawInput: input);
  }

  static List<String> _tokenize(String input) {
    final tokens = <String>[];
    var currentToken = StringBuffer();
    bool inQuotes = false;
    String quoteChar = '';

    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      if (inQuotes) {
        if (char == quoteChar) {
          inQuotes = false;
          tokens.add(currentToken.toString());
          currentToken.clear();
        } else {
          currentToken.write(char);
        }
      } else {
        if (char == ' ' || char == '\t') {
          if (currentToken.isNotEmpty) {
            tokens.add(currentToken.toString());
            currentToken.clear();
          }
        } else if (char == '"' || char == '\'') {
          if (currentToken.isNotEmpty) {
            tokens.add(currentToken.toString());
            currentToken.clear();
          }
          inQuotes = true;
          quoteChar = char;
        } else {
          currentToken.write(char);
        }
      }
    }
    if (currentToken.isNotEmpty) tokens.add(currentToken.toString());
    return tokens;
  }
}
