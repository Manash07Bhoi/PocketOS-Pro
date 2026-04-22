import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HorizontalBarChart extends StatelessWidget {
  final Map<String, int> data;
  const HorizontalBarChart({super.key, required this.data});
  @override Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    return Column(
      children: data.entries.map((entry) {
        final percentage = maxValue > 0 ? entry.value / maxValue : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SizedBox(width: 50, child: Text(entry.key, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
              const SizedBox(width: 8),
              Expanded(child: Stack(children: [Container(height: 12, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(6))), FractionallySizedBox(widthFactor: percentage, child: Container(height: 12, decoration: BoxDecoration(color: AppColors.cyanDim, borderRadius: BorderRadius.circular(6))))])),
              const SizedBox(width: 8),
              SizedBox(width: 40, child: Text('${entry.value}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), textAlign: TextAlign.right)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
