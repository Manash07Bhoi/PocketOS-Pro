import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'widgets/status_bar.dart';
import 'widgets/app_icon_tile.dart';
import 'widgets/custom_icons.dart';

class LauncherScreen extends StatelessWidget {
  const LauncherScreen({super.key});

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const StatusBar(),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3, padding: const EdgeInsets.all(24), mainAxisSpacing: 32, crossAxisSpacing: 24,
                children: [
                  AppIconTile(appName: 'Terminal', icon: CustomAppIcons.terminalIcon, tooltip: 'Built-in Terminal Emulator', onTap: () => Navigator.pushNamed(context, '/terminal')),
                  AppIconTile(appName: 'Files', icon: CustomAppIcons.filesIcon, tooltip: 'File System Navigator', onTap: () => Navigator.pushNamed(context, '/files')),
                  AppIconTile(appName: 'Media', icon: CustomAppIcons.mediaIcon, tooltip: 'Media Scanner & Viewer', onTap: () => Navigator.pushNamed(context, '/media')),
                  AppIconTile(appName: 'Stats', icon: CustomAppIcons.statsIcon, tooltip: 'System & Storage Stats', onTap: () => Navigator.pushNamed(context, '/stats')),
                  AppIconTile(appName: 'Settings', icon: CustomAppIcons.settingsIcon, tooltip: 'System Configuration', onTap: () => Navigator.pushNamed(context, '/settings')),
                  AppIconTile(appName: 'Notes', icon: CustomAppIcons.notesIcon, isInstalled: false, tooltip: 'Install via pkg manager', onTap: () {}),
                  AppIconTile(appName: 'Search', icon: CustomAppIcons.searchIcon, isInstalled: false, tooltip: 'Install via pkg manager', onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.cyan.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)]),
        child: FloatingActionButton(onPressed: () => Navigator.pushNamed(context, '/terminal'), backgroundColor: AppColors.surfaceElev, child: CustomAppIcons.terminalIcon),
      ),
    );
  }
}
