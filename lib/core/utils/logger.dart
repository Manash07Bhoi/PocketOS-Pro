import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'system_log_entry.dart';

class AppLogger {
  static const String _boxName = 'system_logs';
  static Box<SystemLogEntry>? _logBox;

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(100)) Hive.registerAdapter(LogLevelAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SystemLogEntryAdapter());
    _logBox = await Hive.openBox<SystemLogEntry>(_boxName);
  }

  static void log(String message, {LogLevel level = LogLevel.info, String? source}) {
    assert(() {
      debugPrint('[${level.name.toUpperCase()}] ${source ?? 'system'}: $message');
      return true;
    }());

    // Asynchronous non-blocking write to avoid UI stutter
    Future.microtask(() => _storeLog(SystemLogEntry(
      timestamp: DateTime.now(),
      level: level,
      source: source ?? 'system',
      message: message,
    )));
  }

  static Future<void> _storeLog(SystemLogEntry entry) async {
    if (_logBox == null || !_logBox!.isOpen) return;
    try {
      await _logBox!.add(entry);
      if (_logBox!.length > 1000) {
        final keysToDelete = _logBox!.keys.take(_logBox!.length - 1000);
        await _logBox!.deleteAll(keysToDelete);
      }
    } catch (e) {
      debugPrint('Failed to store log: $e');
    }
  }

  static List<SystemLogEntry> getLogs({int? limit, LogLevel? level, String? source}) {
    if (_logBox == null || !_logBox!.isOpen) return [];
    var logs = _logBox!.values.toList();
    if (level != null) logs = logs.where((l) => l.level == level).toList();
    if (source != null) logs = logs.where((l) => l.source == source).toList();
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (limit != null && logs.length > limit) logs = logs.sublist(0, limit);
    return logs.reversed.toList();
  }

  static Future<void> clearLogs() async {
    if (_logBox != null && _logBox!.isOpen) await _logBox!.clear();
  }
}
