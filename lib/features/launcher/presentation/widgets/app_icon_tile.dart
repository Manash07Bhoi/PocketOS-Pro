import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'dart:ui';

class AppIconTile extends StatelessWidget {
  final String appName;
  final Widget icon;
  final bool isInstalled;
  final VoidCallback onTap;
  final String tooltip;

  const AppIconTile({super.key, required this.appName, required this.icon, this.isInstalled = true, required this.onTap, required this.tooltip});

  @override Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip, textStyle: AppTypography.systemLabel,
      decoration: BoxDecoration(color: AppColors.surfaceElev, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(4)),
      child: InkWell(
        onTap: isInstalled ? onTap : null, borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isInstalled ? 1.0 : 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [BoxShadow(color: AppColors.cyan.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: 0)],
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(12), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Center(child: icon))),
              ),
              const SizedBox(height: 8),
              Text(appName, style: AppTypography.appName, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
