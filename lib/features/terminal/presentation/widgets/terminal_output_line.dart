import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../tools/base/base_tool.dart';

class TerminalOutputLineWidget extends StatelessWidget {
  final ToolOutputLine line;
  const TerminalOutputLineWidget({super.key, required this.line});
  @override Widget build(BuildContext context) {
    Color textColor;
    switch (line.type) {
      case OutputType.system: textColor = AppColors.textPrimary; break;
      case OutputType.success: textColor = AppColors.cyan; break;
      case OutputType.error: textColor = AppColors.red; break;
      case OutputType.warning: textColor = AppColors.yellow; break;
      case OutputType.info: textColor = AppColors.blue; break;
      case OutputType.command: textColor = AppColors.textDim; break;
      case OutputType.progress: textColor = AppColors.green; break;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(line.text, style: AppTypography.terminalText.copyWith(color: textColor)),
    );
  }
}
