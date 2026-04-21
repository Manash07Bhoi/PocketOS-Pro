import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/utils/logger.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Lock portrait orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Initialize Hive
    await Hive.initFlutter();

    // Prepare for future boxes (no models yet)

    runApp(const PocketOSApp());
  }, (error, stack) {
    log('Global error: $error\n$stack');
  });
}
