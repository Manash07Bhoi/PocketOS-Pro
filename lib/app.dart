import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/boot/boot_screen.dart';

class PocketOSApp extends StatelessWidget {
  const PocketOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const BootScreen(),
    );
  }
}
