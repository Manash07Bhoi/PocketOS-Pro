import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/permission_service.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});
  @override State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _isRequesting = false;

  Future<void> _requestPermission() async {
    setState(() => _isRequesting = true);
    final granted = await PermissionService.requestMediaPermission();
    setState(() => _isRequesting = false);
    if (granted && mounted) {
      Navigator.pushReplacementNamed(context, '/launcher');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied. Running in limited mode.', style: AppTypography.systemLabel), backgroundColor: AppColors.red),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/launcher');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.security, size: 80, color: AppColors.cyan),
              const SizedBox(height: 32),
              Text('System Access Required', style: AppTypography.uiHeading, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.surfaceElev, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.folder_shared, color: AppColors.blue, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Media Access', style: AppTypography.uiBody.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('PocketOS needs access to photos and videos to allow the nmap tool and Media app to scan your local storage.', style: AppTypography.systemLabel.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.privacy_tip, color: AppColors.green, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('100% Offline', style: AppTypography.uiBody.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Your data never leaves your device. No analytics, no tracking, no cloud uploads. Period.', style: AppTypography.systemLabel.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isRequesting ? null : _requestPermission,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyan, foregroundColor: AppColors.background, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: _isRequesting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background)) : Text('Grant Permission', style: AppTypography.uiBody.copyWith(fontWeight: FontWeight.bold, color: AppColors.background)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/launcher'),
                child: Text('Continue in Limited Mode', style: AppTypography.systemLabel.copyWith(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
