import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:example/utils/map_source.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
import 'package:orbit/orbit.dart';

import 'utils.dart';
import 'utils/twilight.dart';
import 'utils/twilight_painter.dart';
import 'utils/viewport_painter.dart';

class _PositionLookAngle {
  const _PositionLookAngle(this.location, this.position, this.lookAngle);
  final LatLng location;
  final Offset position;
  final LookAngle lookAngle;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng? mousePointer;
  MapStyle currentMap = mapStyles[0];

  final observers = <LatLng>[];

  @override
  void initState() {
    for (int i = -18; i <= 18; i++) {
      for (int j = -8; j <= 8; j++) {
        observers.add(LatLng(j * 10, i * 20));
      }
    }
    super.initState();
  }

  final controller = MapController(
    location: const LatLng(0, 0),
    zoom: 3,
  );

  void _onDoubleTap(MapTransformer transformer, Offset position) {
    const delta = 0.5;
    final zoom = clamp(
      controller.zoom + delta,
      currentMap.minZoom.toDouble(),
      currentMap.maxZoom.toDouble(),
    );

    transformer.setZoomInPlace(zoom, position);
    setState(() {});
  }

  Offset? _dragStart;
  double _scaleStart = 1.0;
  void _onScaleStart(ScaleStartDetails details) {
    _dragStart = details.focalPoint;
    _scaleStart = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, MapTransformer transformer) {
    final scaleDiff = details.scale - _scaleStart;
    _scaleStart = details.scale;

    if (scaleDiff > 0) {
      controller.zoom += 0.02;

      controller.zoom = clamp(
        controller.zoom,
        currentMap.minZoom.toDouble(),
        currentMap.maxZoom.toDouble(),
      );

      setState(() {});
    } else if (scaleDiff < 0) {
      controller.zoom -= 0.02;

      controller.zoom = clamp(
        controller.zoom,
        currentMap.minZoom.toDouble(),
        currentMap.maxZoom.toDouble(),
      );
      setState(() {});
    } else {
      final now = details.focalPoint;
      var diff = now - _dragStart!;
      _dragStart = now;

      final h = transformer.constraints.maxHeight;

      final vp = transformer.getViewport();
      if (diff.dy < 0 && vp.bottom - diff.dy < h) {
        diff = Offset(diff.dx, 0);
      }

      if (diff.dy > 0 && vp.top - diff.dy > 0) {
        diff = Offset(diff.dx, 0);
      }

      transformer.drag(diff.dx, diff.dy);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orbit'),
        actions: [
          PopupMenuButton<MapStyle>(
            initialValue: currentMap,
            icon: const Icon(Icons.layers),
            tooltip: 'Map Layers',
            onSelected: ((value) {
              currentMap = value;
              controller.zoom = clamp(
                controller.zoom,
                currentMap.minZoom.toDouble(),
                currentMap.maxZoom.toDouble(),
              );

              setState(() {});
            }),
            itemBuilder: (context) {
              return mapStyles
                  .map(
                    (e) => PopupMenuItem<MapStyle>(
                      value: e,
                      child: ListTile(
                        title: Text(e.name),
                        dense: true,
                      ),
                    ),
                  )
                  .toList();
            },
          ),
        ],
      ),
      body: MapLayout(
        controller: controller,
        builder: (context, transformer) {
          final now = DateTime.now().toUtc();
          final markerWidgets = <Widget>[];
          final mouse = mousePointer;

          final civil = Twilight.civil(now);
          final polyline = transformer.toOffsetMany(civil.polyline).toList();
          final viewport = transformer.getViewport();

          if (civil.delta < 0) {
            polyline.insert(0, viewport.topLeft);
            polyline.add(viewport.topRight);
          } else {
            polyline.insert(0, viewport.bottomLeft);
            polyline.add(viewport.bottomRight);
          }

          final pla = observers
              .map(
                (e) => _PositionLookAngle(
                  e,
                  transformer.toOffset(e),
                  getSunLookAngle(now, e, 0),
                ),
              )
              .toList();

          final sunLocation = getSunLocation(now);
          final moonLocation = getMoonLocation(now);
          final sunPosition = transformer.toOffset(sunLocation);
          final moonPosition = transformer.toOffset(moonLocation);
          const sunSize = 48.0;
          const moonSize = 48.0;
          markerWidgets.add(
            Positioned(
              left: sunPosition.dx - sunSize / 2,
              top: sunPosition.dy - sunSize / 2,
              width: sunSize,
              height: sunSize,
              child: const Tooltip(
                message: 'Sun',
                child: Icon(
                  Icons.sunny,
                  color: Colors.orange,
                  size: sunSize,
                ),
              ),
            ),
          );

          markerWidgets.add(
            Positioned(
              left: moonPosition.dx - moonSize / 2,
              top: moonPosition.dy - moonSize / 2,
              width: moonSize,
              height: moonSize,
              child: Tooltip(
                message: 'Moon',
                child: Icon(
                  Icons.nightlight,
                  color: Colors.yellowAccent.withOpacity(0.8),
                  size: moonSize,
                ),
              ),
            ),
          );

          markerWidgets.addAll(pla.map(
            (op) => Positioned(
              left: op.position.dx - sunSize / 2,
              top: op.position.dy - sunSize / 2,
              width: sunSize,
              height: sunSize,
              child: Tooltip(
                message:
                    'Look Angle\nElevation: ${op.lookAngle.elevation}\nAzimuth: ${op.lookAngle.azimuth}',
                child: Transform.rotate(
                  angle: op.lookAngle.azimuth.radians,
                  child: Icon(
                    Icons.arrow_circle_up,
                    color: op.lookAngle.elevation.degrees > 0
                        ? Colors.green.shade900
                        : Colors.red,
                    size: sunSize,
                  ),
                ),
              ),
            ),
          ));

          String? mousePosition;
          if (mouse != null) {
            var lng = mouse.longitude % 360;
            while (lng >= 180) {
              lng -= 360;
            }
            while (lng <= -180) {
              lng += 360;
            }

            mousePosition =
                '${mouse.latitude.toStringAsFixed(2)}°, ${lng.toStringAsFixed(2)}°';
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: ((details) {
              final tap = transformer.toLatLng(details.localPosition);
              final latlng = '${tap.latitude}, ${tap.longitude}';
              final snackBar = SnackBar(
                action: SnackBarAction(
                  label: 'Copy',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: latlng));
                  },
                ),
                content: Text(latlng),
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }),
            onDoubleTapDown: (details) => _onDoubleTap(
              transformer,
              details.localPosition,
            ),
            onScaleStart: _onScaleStart,
            onScaleUpdate: (details) => _onScaleUpdate(details, transformer),
            child: MouseRegion(
              onHover: ((event) {
                mousePointer = transformer.toLatLng(event.position);

                setState(() {});
              }),
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    final delta = event.scrollDelta;
                    final zoom = clamp(
                      controller.zoom - delta.dy / 1000.0,
                      currentMap.minZoom.toDouble(),
                      currentMap.maxZoom.toDouble(),
                    );

                    transformer.setZoomInPlace(zoom, event.position);

                    setState(() {});
                  }
                },
                child: Stack(
                  children: [
                    TileLayer(
                      builder: (context, x, y, z) {
                        final tilesInZoom = pow(2.0, z).floor();

                        while (x < 0) {
                          x += tilesInZoom;
                        }
                        while (y < 0) {
                          y += tilesInZoom;
                        }

                        x %= tilesInZoom;
                        y %= tilesInZoom;

                        return CachedNetworkImage(
                          imageUrl: currentMap.url(z, x, y),
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    ...markerWidgets,
                    CustomPaint(painter: TwilightPainter(polyline)),
                    if (mousePosition != null)
                      Align(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: Container(
                          color: Colors.black12,
                          padding: const EdgeInsets.all(8.0),
                          child: Text(mousePosition),
                        ),
                      ),
                    CustomPaint(
                      painter: ViewportPainter(
                        transformer.getViewport(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

const double rad2deg = 180.0 / pi;
const double deg2rad = pi / 180.0;
