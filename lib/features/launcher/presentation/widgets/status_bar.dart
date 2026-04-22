import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class StatusBar extends StatefulWidget {
  const StatusBar({super.key});
  @override State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  late Timer _timer;
  late String _timeString;
  @override void initState() {
    super.initState();
    _timeString = DateFormat('HH:mm').format(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      final formatted = DateFormat('HH:mm').format(DateTime.now());
      if (formatted != _timeString) setState(() => _timeString = formatted);
    });
  }
  @override void dispose() { _timer.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('user@pocketos', style: AppTypography.systemLabel),
          Text('[$_timeString]    [69%]  [128GB]', style: AppTypography.systemLabel),
        ],
      ),
    );
  }
}
