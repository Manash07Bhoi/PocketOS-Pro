import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const background     = Color(0xFF0A0A0F);  // MUST be this exact value
  static const surface        = Color(0xFF111118);
  static const surfaceElev    = Color(0xFF1A1A24);
  static const border         = Color(0xFF2A2A38);

  // Accents
  static const cyan           = Color(0xFF00E5FF);  // PRIMARY ACCENT
  static const cyanDim        = Color(0xFF0097B2);
  static const green          = Color(0xFF00FF88);  // success
  static const red            = Color(0xFFFF4444);  // error
  static const yellow         = Color(0xFFFFD700);  // warning
  static const blue           = Color(0xFF4488FF);  // info

  // Text
  static const textPrimary    = Color(0xFFE8E8F0);
  static const textSecondary  = Color(0xFF8888A0);
  static const textDim        = Color(0xFF444458);

  // Terminal specific
  static const termBg         = Color(0xFF070710);
  static const termCursor     = Color(0xFF00E5FF);
  static const termPrompt     = Color(0xFF00FF88);
}
