import 'package:flutter/material.dart';

class ViewportPainter extends CustomPainter {
  ViewportPainter(this.viewport);
  final Rect viewport;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2;

    //canvas.drawRect(viewport, paint);
    canvas.drawLine(viewport.topLeft, viewport.bottomLeft, paint);
    canvas.drawLine(viewport.topRight, viewport.bottomRight, paint);
  }

  @override
  bool shouldRepaint(covariant ViewportPainter oldDelegate) =>
      oldDelegate.viewport != viewport;
}
