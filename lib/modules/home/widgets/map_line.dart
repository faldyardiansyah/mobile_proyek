import 'package:flutter/material.dart';

class MapLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.28)
      ..strokeWidth = 1;

    for (double x = -30; x < size.width; x += 34) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + 70, size.height),
        paint,
      );
    }

    for (double y = 8; y < size.height; y += 18) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + 28),
        paint,
      );
    }

    for (double x = 20; x < size.width; x += 45) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + 30, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}