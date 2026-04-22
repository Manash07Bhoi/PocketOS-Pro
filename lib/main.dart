import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/utils/logger.dart';
import 'core/utils/system_log_entry.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Lock portrait orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Initialize Hive
    await Hive.initFlutter();

    // Initialize system logger
    await AppLogger.init();

    // Prepare for future boxes (no models yet)

    runApp(const PocketOSApp());
  }, (error, stack) {
    AppLogger.log('Global error: $error\n$stack', level: LogLevel.error, source: 'system_uncaught');
  });
}
