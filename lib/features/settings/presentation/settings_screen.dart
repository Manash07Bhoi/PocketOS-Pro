import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'dart:ui';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _typingSound = true; bool _cursorBlink = true; bool _autoComplete = true;

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Settings', style: AppTypography.uiHeading), backgroundColor: AppColors.surface, leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Appearance'),
            _buildGlassCard(child: Column(children: [_buildListTile(title: 'Theme', subtitle: 'Dark (Default)', icon: Icons.palette, onTap: () {}), _buildDivider(), _buildListTile(title: 'Terminal Font', subtitle: 'JetBrains Mono', icon: Icons.font_download, onTap: () {})])),
            const SizedBox(height: 24),
            _buildSectionHeader('Terminal'),
            _buildGlassCard(child: Column(children: [_buildSwitchTile(title: 'Typing Sound', value: _typingSound, icon: Icons.keyboard, onChanged: (val) => setState(() => _typingSound = val)), _buildDivider(), _buildSwitchTile(title: 'Cursor Blink', value: _cursorBlink, icon: Icons.text_fields, onChanged: (val) => setState(() => _cursorBlink = val)), _buildDivider(), _buildSwitchTile(title: 'Auto-Complete', value: _autoComplete, icon: Icons.auto_awesome, onChanged: (val) => setState(() => _autoComplete = val))])),
            const SizedBox(height: 24),
            _buildSectionHeader('System'),
            _buildGlassCard(child: Column(children: [_buildListTile(title: 'Permissions', subtitle: 'Manage access to local files', icon: Icons.security, onTap: () => Navigator.pushNamed(context, '/permission')), _buildDivider(), _buildListTile(title: 'Clear Cache', subtitle: 'Remove cached scan data', icon: Icons.delete_outline, onTap: () {})])),
            const SizedBox(height: 24),
            _buildSectionHeader('About'),
            _buildGlassCard(child: Column(children: [_buildListTile(title: 'PocketOS Pro', subtitle: 'Version 1.0.0+1', icon: Icons.info_outline)])),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) { return Padding(padding: const EdgeInsets.only(left: 8, bottom: 8), child: Text(title, style: AppTypography.systemLabel.copyWith(color: AppColors.cyanDim))); }
  Widget _buildGlassCard({required Widget child}) { return Container(decoration: BoxDecoration(color: AppColors.surfaceElev.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, width: 1), boxShadow: [BoxShadow(color: AppColors.cyan.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: 0)]), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: child))); }
  Widget _buildDivider() { return const Divider(height: 1, thickness: 1, color: AppColors.border, indent: 56); }
  Widget _buildListTile({required String title, String? subtitle, required IconData icon, VoidCallback? onTap}) { return ListTile(leading: Icon(icon, color: AppColors.cyan), title: Text(title, style: AppTypography.uiBody), subtitle: subtitle != null ? Text(subtitle, style: AppTypography.systemLabel.copyWith(color: AppColors.textSecondary)) : null, trailing: onTap != null ? const Icon(Icons.chevron_right, color: AppColors.textSecondary) : null, onTap: onTap); }
  Widget _buildSwitchTile({required String title, required bool value, required IconData icon, required ValueChanged<bool> onChanged}) { return SwitchListTile(value: value, onChanged: onChanged, title: Text(title, style: AppTypography.uiBody), secondary: Icon(icon, color: AppColors.cyan), activeTrackColor: AppColors.cyanDim.withValues(alpha: 0.4), inactiveThumbColor: AppColors.textSecondary, inactiveTrackColor: AppColors.border); }
}
