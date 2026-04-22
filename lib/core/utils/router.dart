import 'package:flutter/material.dart';
import '../../features/boot/presentation/boot_screen.dart';
import '../../features/launcher/presentation/launcher_screen.dart';
import '../../features/terminal/presentation/terminal_screen.dart';
import '../../features/files/presentation/files_screen.dart';
import '../../features/media/presentation/media_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/boot/presentation/permission_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

class AppRouter {
  static const String kBootRoute = '/boot';
  static const String kLauncherRoute = '/launcher';
  static const String kTerminalRoute = '/terminal';
  static const String kFilesRoute = '/files';
  static const String kMediaRoute = '/media';
  static const String kStatsRoute = '/stats';
  static const String kPermissionRoute = '/permission';
  static const String kSettingsRoute = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case kBootRoute: return MaterialPageRoute(builder: (_) => const BootScreen());
      case kLauncherRoute: return _fadeRoute(const LauncherScreen());
      case kTerminalRoute: return MaterialPageRoute(builder: (_) => const TerminalScreen());
      case kFilesRoute: return MaterialPageRoute(builder: (_) => const FilesScreen());
      case kMediaRoute: return MaterialPageRoute(builder: (_) => const MediaScreen());
      case kStatsRoute: return MaterialPageRoute(builder: (_) => const StatsScreen());
      case kPermissionRoute: return MaterialPageRoute(builder: (_) => const PermissionScreen());
      case kSettingsRoute: return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default: return MaterialPageRoute(builder: (_) => Scaffold(body: Center(child: Text('No route defined for ${settings.name}'))));
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}
