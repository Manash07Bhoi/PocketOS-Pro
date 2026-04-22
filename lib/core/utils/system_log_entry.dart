import 'package:hive/hive.dart';
part 'system_log_entry.g.dart';

enum LogLevel { info, warn, error, debug }

class LogLevelAdapter extends TypeAdapter<LogLevel> {
  @override final typeId = 100;
  @override LogLevel read(BinaryReader reader) => LogLevel.values[reader.readByte()];
  @override void write(BinaryWriter writer, LogLevel obj) => writer.writeByte(obj.index);
}

@HiveType(typeId: 3)
class SystemLogEntry extends HiveObject {
  @HiveField(0) final DateTime timestamp;
  @HiveField(1) final LogLevel level;
  @HiveField(2) final String source;
  @HiveField(3) final String message;

  SystemLogEntry({required this.timestamp, required this.level, required this.source, required this.message});
}
