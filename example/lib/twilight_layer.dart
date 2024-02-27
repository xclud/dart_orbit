import 'package:flutter/material.dart';
import 'package:map/map.dart';

import 'utils/twilight.dart';

/// Day and night border.
///
/// This class must be a child of [MapLayout].
class TwilightLayer extends StatefulWidget {
  /// Main constructor.
  const TwilightLayer({
    super.key,
    required this.transformer,
    required this.dateTime,
  });

  /// The transformer from parent.
  final MapTransformer transformer;

  /// Date and Time of Twilight.
  final DateTime dateTime;

  @override
  State<StatefulWidget> createState() => _TwilightLayerState();
}

class _TwilightLayerState extends State<TwilightLayer> {
  @override
  void didChangeDependencies() {
    final map = context.findAncestorWidgetOfExactType<MapLayout>();

    if (map == null) {
      throw Exception('TileLayer must be used inside a MapLayout.');
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final twilight = Twilight.civil(widget.dateTime);
    final viewport = widget.transformer.getViewport();
    return ShapeLayer(transformer: widget.transformer, shapes: [
      Shape(
        points: twilight.points,
        painter: (c, p, m) => _paintTwilight(c, p, twilight.delta, viewport),
      )
    ]);
  }
}

void _paintTwilight(
  Canvas canvas,
  List<Offset> points,
  double delta,
  Rect viewport,
) {
  final polyline = List<Offset>.from(points);

  if (delta < 0) {
    polyline.insert(0, viewport.topLeft);
    polyline.add(viewport.topRight);
  } else {
    polyline.insert(0, viewport.bottomLeft);
    polyline.add(viewport.bottomRight);
  }

  final path = Path()..addPolygon(polyline, true);
  final paint = Paint()
    ..color = Colors.black87
    ..strokeWidth = 1;

  paint.style = PaintingStyle.fill;
  paint.color = Colors.black26;
  canvas.drawPath(path, paint);

  paint.style = PaintingStyle.stroke;
  paint.color = Colors.black87;

  canvas.drawPath(path, paint);
}
