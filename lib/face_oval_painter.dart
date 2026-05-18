import 'package:flutter/material.dart';

class FaceOvalPainter extends CustomPainter {
  final double progress;
  final bool detected;

  FaceOvalPainter({required this.progress, required this.detected});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width * 0.32;
    final ry = size.height * 0.42;
    final rect =
        Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2);

    // oval utama
    final ovalPaint = Paint()
      ..color = detected
          ? const Color(0xFF2ECC71)
          // ✅ FIX: withOpacity() diganti withValues(alpha:)
          : Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = detected ? 3.5 : 2.5;
    canvas.drawOval(rect, ovalPaint);

    // corner bracket
    final cornerPaint = Paint()
      ..color = detected ? const Color(0xFF2ECC71) : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const len = 20.0;
    canvas.drawLine(Offset(cx - rx + 2, cy - ry + len),
        Offset(cx - rx + 2, cy - ry + 2), cornerPaint);
    canvas.drawLine(Offset(cx - rx + 2, cy - ry + 2),
        Offset(cx - rx + len, cy - ry + 2), cornerPaint);
    canvas.drawLine(Offset(cx + rx - 2, cy - ry + len),
        Offset(cx + rx - 2, cy - ry + 2), cornerPaint);
    canvas.drawLine(Offset(cx + rx - 2, cy - ry + 2),
        Offset(cx + rx - len, cy - ry + 2), cornerPaint);
    canvas.drawLine(Offset(cx - rx + 2, cy + ry - len),
        Offset(cx - rx + 2, cy + ry - 2), cornerPaint);
    canvas.drawLine(Offset(cx - rx + 2, cy + ry - 2),
        Offset(cx - rx + len, cy + ry - 2), cornerPaint);
    canvas.drawLine(Offset(cx + rx - 2, cy + ry - len),
        Offset(cx + rx - 2, cy + ry - 2), cornerPaint);
    canvas.drawLine(Offset(cx + rx - 2, cy + ry - 2),
        Offset(cx + rx - len, cy + ry - 2), cornerPaint);

    // scan line
    if (!detected) {
      final scanY = cy - ry + (ry * 2 * progress);
      canvas.save();
      final clipPath = Path()..addOval(rect);
      canvas.clipPath(clipPath);
      final scanPaint = Paint()
        ..shader = LinearGradient(colors: [
          Colors.transparent,
          // ✅ FIX: withOpacity() diganti withValues(alpha:)
          const Color(0xFF2ECC71).withValues(alpha: 0.8),
          Colors.transparent,
        ]).createShader(Rect.fromLTWH(cx - rx, scanY - 1, rx * 2, 2));
      canvas.drawRect(Rect.fromLTWH(cx - rx, scanY - 1, rx * 2, 2), scanPaint);
      canvas.restore();
    }

    // centang saat terdeteksi
    if (detected) {
      final dotPaint = Paint()
        ..color = const Color(0xFF2ECC71)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy - ry - 14), 12, dotPaint);
      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final path = Path()
        ..moveTo(cx - 6, cy - ry - 14)
        ..lineTo(cx - 1, cy - ry - 8)
        ..lineTo(cx + 7, cy - ry - 19);
      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(FaceOvalPainter old) =>
      old.progress != progress || old.detected != detected;
}
