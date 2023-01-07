import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';

extension PolylineExtension on Polyline {

  Polyline extrude() {
    return this;
  }
}

class Polygon {
  const Polygon({required this.data, required this.color});

  final List<LatLng> data;
  final Color color;
}

class PolygonCustomPainter extends CustomPainter {
  const PolygonCustomPainter({
    required this.transformer,
    required this.polygons,
  });

  final MapTransformer transformer;
  final List<Polygon> polygons;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    for (var polygon in polygons) {
      final basecolor = polygon.color.withAlpha(255);
      final points = transformer.toOffsetMany(polygon.data);

      Path f = Path();
      f.addPolygon(points.toList(), true);

      paint.color = basecolor.withOpacity(0.1);
      paint.style = PaintingStyle.fill;
      canvas.drawPath(f, paint);

      paint.color = basecolor;
      paint.style = PaintingStyle.stroke;
      canvas.drawPath(f, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
