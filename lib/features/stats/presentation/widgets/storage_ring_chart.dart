import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'dart:math';

class StorageRingChart extends StatelessWidget {
  final double usedPercentage;
  const StorageRingChart({super.key, required this.usedPercentage});
  @override Widget build(BuildContext context) { return SizedBox(width: 200, height: 200, child: CustomPaint(painter: _RingChartPainter(usedPercentage: usedPercentage))); }
}

class _RingChartPainter extends CustomPainter {
  final double usedPercentage;
  _RingChartPainter({required this.usedPercentage});
  @override void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2); final radius = min(size.width / 2, size.height / 2) - 10;
    final trackPaint = Paint()..color = AppColors.border..style = PaintingStyle.stroke..strokeWidth = 15..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);
    final usedPaint = Paint()..color = AppColors.cyan..style = PaintingStyle.stroke..strokeWidth = 15..strokeCap = StrokeCap.round;
    final sweepAngle = 2 * pi * (usedPercentage / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweepAngle, false, usedPaint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
