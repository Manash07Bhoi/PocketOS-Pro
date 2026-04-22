import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CustomAppIcons {
  static Widget get terminalIcon => CustomPaint(size: const Size(36, 36), painter: _TerminalIconPainter());
  static Widget get filesIcon => CustomPaint(size: const Size(36, 36), painter: _FilesIconPainter());
  static Widget get mediaIcon => CustomPaint(size: const Size(36, 36), painter: _MediaIconPainter());
  static Widget get statsIcon => CustomPaint(size: const Size(36, 36), painter: _StatsIconPainter());
  static Widget get settingsIcon => CustomPaint(size: const Size(36, 36), painter: _SettingsIconPainter());
  static Widget get notesIcon => CustomPaint(size: const Size(36, 36), painter: _NotesIconPainter());
  static Widget get searchIcon => CustomPaint(size: const Size(36, 36), painter: _SearchIconPainter());
}

class _TerminalIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.cyan..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final path = Path()..moveTo(size.width * 0.2, size.width * 0.3)..lineTo(size.width * 0.5, size.height * 0.5)..lineTo(size.width * 0.2, size.height * 0.7);
    canvas.drawPath(path, paint);
    canvas.drawLine(Offset(size.width * 0.55, size.height * 0.7), Offset(size.width * 0.8, size.height * 0.7), paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FilesIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.cyanDim..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final path = Path()..moveTo(size.width * 0.1, size.height * 0.3)..lineTo(size.width * 0.4, size.height * 0.3)..lineTo(size.width * 0.5, size.height * 0.4)..lineTo(size.width * 0.9, size.height * 0.4)..lineTo(size.width * 0.9, size.height * 0.8)..lineTo(size.width * 0.1, size.height * 0.8)..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MediaIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.blue..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final borderRect = Rect.fromLTWH(size.width * 0.1, size.height * 0.2, size.width * 0.8, size.height * 0.6);
    canvas.drawRect(borderRect, paint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), 4, paint);
    final path = Path()..moveTo(size.width * 0.1, size.height * 0.8)..lineTo(size.width * 0.4, size.height * 0.5)..lineTo(size.width * 0.6, size.height * 0.7)..lineTo(size.width * 0.7, size.height * 0.6)..lineTo(size.width * 0.9, size.height * 0.8);
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatsIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.green..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(size.width * 0.2, size.height * 0.5, size.width * 0.15, size.height * 0.3), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.45, size.height * 0.3, size.width * 0.15, size.height * 0.5), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.7, size.height * 0.2, size.width * 0.15, size.height * 0.6), paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SettingsIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.textSecondary..style = PaintingStyle.stroke..strokeWidth = 2.0;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), size.width * 0.2, paint);
    for (int i = 0; i < 8; i++) {
        canvas.save();
        canvas.translate(size.width / 2, size.height / 2);
        canvas.rotate(i * (3.14159 / 4));
        canvas.drawLine(Offset(0, size.width * 0.2), Offset(0, size.width * 0.3), paint);
        canvas.restore();
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NotesIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.yellow..style = PaintingStyle.stroke..strokeWidth = 2.0;
    canvas.drawRect(Rect.fromLTWH(size.width * 0.2, size.height * 0.2, size.width * 0.6, size.height * 0.6), paint);
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.4), Offset(size.width * 0.7, size.height * 0.4), paint);
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.6), Offset(size.width * 0.6, size.height * 0.6), paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SearchIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.textPrimary..style = PaintingStyle.stroke..strokeWidth = 2.0;
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.4), size.width * 0.2, paint);
    canvas.drawLine(Offset(size.width * 0.55, size.height * 0.55), Offset(size.width * 0.8, size.height * 0.8), paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
