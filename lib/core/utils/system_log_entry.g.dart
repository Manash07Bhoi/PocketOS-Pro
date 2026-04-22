// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_log_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SystemLogEntryAdapter extends TypeAdapter<SystemLogEntry> {
  @override
  final int typeId = 3;

  @override
  SystemLogEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SystemLogEntry(
      timestamp: fields[0] as DateTime,
      level: fields[1] as LogLevel,
      source: fields[2] as String,
      message: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SystemLogEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.source)
      ..writeByte(3)
      ..write(obj.message);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemLogEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
