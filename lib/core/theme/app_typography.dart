import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Terminal text — ALWAYS JetBrains Mono
  static final TextStyle terminalText = GoogleFonts.jetBrainsMono(
    color: AppColors.textPrimary,
    fontSize: 13,
    height: 1.5,
  );

  static final TextStyle terminalPrompt = GoogleFonts.jetBrainsMono(
    color: AppColors.termPrompt,
    fontSize: 13,
    fontWeight: FontWeight.bold,
    height: 1.5,
  );

  static final TextStyle systemLabel = GoogleFonts.jetBrainsMono(
    color: AppColors.textPrimary,
    fontSize: 11,
    height: 1.5,
  );

  // UI text — ALWAYS Inter
  static final TextStyle uiHeading = GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle uiBody = GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle appName = GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}
