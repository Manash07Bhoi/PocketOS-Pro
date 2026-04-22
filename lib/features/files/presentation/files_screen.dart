import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Files', style: AppTypography.uiHeading), backgroundColor: AppColors.surface, leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context))),
      body: SafeArea(
        child: Column(
          children: [
            Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), color: AppColors.surfaceElev, child: Text('/home/media/', style: AppTypography.systemLabel.copyWith(color: AppColors.cyanDim))),
            Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.folder_open, size: 64, color: AppColors.textDim), const SizedBox(height: 16), Text('No files mapped to virtual directory', style: AppTypography.uiBody.copyWith(color: AppColors.textSecondary))]))),
          ],
        ),
      ),
    );
  }
}
