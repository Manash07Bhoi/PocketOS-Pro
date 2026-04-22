import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'widgets/storage_ring_chart.dart';
import 'widgets/horizontal_bar_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});
  @override Widget build(BuildContext context) {
    final yearData = {'2026': 234, '2025': 891, '2024': 780, '2023': 435};
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Stats', style: AppTypography.uiHeading), backgroundColor: AppColors.surface, leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.surfaceElev, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)), child: Column(children: [Text('Storage Overview', style: AppTypography.uiHeading), const SizedBox(height: 32), const Center(child: StorageRingChart(usedPercentage: 69.8)), const SizedBox(height: 32), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildStatCard('Used', '89.4 GB', AppColors.cyan), _buildStatCard('Free', '38.6 GB', AppColors.textSecondary)])])),
              const SizedBox(height: 24),
              Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.surfaceElev, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Media Summary', style: AppTypography.uiHeading), const SizedBox(height: 16), _buildSummaryRow('Photos', '2,340', '8.4 GB'), const SizedBox(height: 8), _buildSummaryRow('Videos', '187', '22.1 GB')])),
              const SizedBox(height: 24),
              Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.surfaceElev, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Media by Year', style: AppTypography.uiHeading), const SizedBox(height: 24), HorizontalBarChart(data: yearData)])),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildStatCard(String label, String value, Color color) { return Column(children: [Text(value, style: AppTypography.uiHeading.copyWith(color: color)), const SizedBox(height: 4), Text(label, style: AppTypography.systemLabel)]); }
  Widget _buildSummaryRow(String type, String count, String size) { return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(type, style: AppTypography.uiBody), Row(children: [Text(count, style: AppTypography.systemLabel), const SizedBox(width: 16), SizedBox(width: 80, child: Text(size, style: AppTypography.systemLabel, textAlign: TextAlign.right))])]); }
}
