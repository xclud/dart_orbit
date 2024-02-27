import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlng/latlng.dart' as l;
import 'package:map/map.dart';
import 'package:orbit/orbit.dart';
import 'satellite_selection_dialog.dart';
import 'twilight_layer.dart';

import 'satellite.dart' as sat;
import 'package:file_picker/file_picker.dart';
import 'package:orbit/orbit.dart' as o;

import 'utils.dart';
import 'utils/viewport_painter.dart';

const pages = [-2, -1, 0, 1, 2];

MapStyle _currentMap = online;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  l.LatLng? mousePointer;

  final controller = MapController(
    location: sat.model.stations[0].location.toLatLng(),
    zoom: 2,
  );

  void _onDoubleTap(MapTransformer transformer, Offset position) {
    const delta = 0.5;
    final zoom = clamp(
      controller.zoom + delta,
      _currentMap.minZoom.toDouble(),
      _currentMap.maxZoom.toDouble(),
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
        _currentMap.minZoom.toDouble(),
        _currentMap.maxZoom.toDouble(),
      );

      setState(() {});
    } else if (scaleDiff < 0) {
      controller.zoom -= 0.02;

      controller.zoom = clamp(
        controller.zoom,
        _currentMap.minZoom.toDouble(),
        _currentMap.maxZoom.toDouble(),
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
  void initState() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        sat.model.updateSatellites();
        setState(() {});
      } else {
        timer.cancel();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final map = MapLayout(
      controller: controller,
      builder: (context, transformer) {
        final now = DateTime.now().toUtc();
        final markerWidgets = <Widget>[];
        final passPoints = <Widget>[];
        final mouse = mousePointer;

        final sunLocation = getSunLocation(now);
        final moonLocation = getMoonLocation(now);
        final sunPosition = transformer.toOffset(sunLocation);
        final moonPosition = transformer.toOffset(moonLocation);

        const sunSize = 48.0;
        const moonSize = 48.0;
        const stationSize = 36.0;
        const satelliteSize = 18.0;
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

        for (var station in sat.model.stations) {
          for (final page in pages) {
            final p =
                transformer.toOffset(station.location.toLatLng().page(page));

            markerWidgets.add(
              Positioned(
                left: p.dx - stationSize / 2,
                top: p.dy - stationSize / 2,
                width: stationSize,
                height: stationSize,
                child: Tooltip(
                  message: station.name,
                  child: Icon(
                    Icons.home,
                    color: station.color,
                    size: stationSize,
                  ),
                ),
              ),
            );
          }
        }

        for (final e in sat.model.satellites) {
          final location = e.location;
          final lookAngle = e.lookAngle;
          final visibility = e.visibility;
          if (location == null || lookAngle == null) {
            continue;
          }

          final coords = transformer.toOffset(location.toLatLng());

          final marker = Positioned(
            left: coords.dx - satelliteSize / 2,
            top: coords.dy - satelliteSize / 2,
            width: satelliteSize,
            height: satelliteSize,
            child: Tooltip(
              message:
                  '${e.gp.name}\nElevation: ${lookAngle.elevation.degrees.toStringAsFixed(2)}°\nAzimuth: ${lookAngle.azimuth.degrees.toStringAsFixed(2)}°\nAltitude: ${location.altitude.toStringAsFixed(2)} KM',
              child: Icon(
                Icons.circle,
                color: e.color,
                size: satelliteSize,
              ),
            ),
          );

          markerWidgets.add(marker);

          if (e.showGroundTrack && visibility != null) {
            final shapeLayer = ShapeLayer(transformer: transformer, shapes: [
              Shape(
                points: visibility,
                painter: (c, p, m) => _paintVisibility(c, p, m, e.color),
              )
            ]);
            markerWidgets.add(shapeLayer);
          }

          for (final station in sat.model.stations) {
            final pre = sat.model.get(e, station);
            final passes = pre.passes;

            if (passes != null) {
              for (final pass in passes) {
                passPoints.add(
                    _buildPassPoint(station, transformer, pass.points.first));
                passPoints.add(_buildPassPoint(station, transformer, pass.max));
                passPoints.add(
                    _buildPassPoint(station, transformer, pass.points.last));
              }
            }
          }
        }

        String? mousePosition;
        if (mouse != null) {
          var lng = mouse.longitude.degrees % 360;
          while (lng >= 180) {
            lng -= 360;
          }
          while (lng <= -180) {
            lng += 360;
          }

          mousePosition =
              '${mouse.latitude.degrees.toStringAsFixed(2)}°, ${lng.toStringAsFixed(2)}°';
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
                    _currentMap.minZoom.toDouble(),
                    _currentMap.maxZoom.toDouble(),
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
                        imageUrl: _currentMap.url(z, x, y),
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  ...markerWidgets,
                  ShapeLayer(
                    transformer: transformer,
                    shapes: [
                      ..._getSatellitePassShapes(sat.model, transformer),
                      ..._getSatelliteOrbitShapes(sat.model.satellites),
                    ],
                  ),
                  ...passPoints,
                  TwilightLayer(
                    transformer: transformer,
                    dateTime: now,
                  ),
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
    );

    final satPanel = Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 160,
          maxWidth: 320,
        ),
        child: Listener(
          behavior: HitTestBehavior.opaque,
          child: Opacity(
            opacity: 0.95,
            child: Theme(
              data: ThemeData.dark(),
              child: Material(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView(
                        primary: false,
                        children: sat.model.satellites
                            .map(
                              (e) => SatelliteListItem(
                                satellite: e,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const Divider(),
                    ButtonBar(
                      alignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () async {
                            final observer = sat.model.stations[0].location;
                            final now = DateTime.now().toUtc();
                            sat.model.sortByElevation(observer, now);

                            setState(() {});
                          },
                          tooltip: 'Sort',
                          icon: const Icon(Icons.arrow_circle_down_sharp),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final mapToolbar = Positioned(
      bottom: 48,
      right: 8,
      child: PopupMenuButton<MapStyle>(
        initialValue: _currentMap,
        icon: const Icon(Icons.layers),
        tooltip: 'Map Layers',
        onSelected: ((value) {
          _currentMap = value;
          controller.zoom = clamp(
            controller.zoom,
            _currentMap.minZoom.toDouble(),
            _currentMap.maxZoom.toDouble(),
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
    );

    final body = Stack(
      children: [
        map,
        mapToolbar,
        if (sat.model.satellites.isNotEmpty) satPanel
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Satellite Tracker'),
        actions: [
          IconButton(
            onPressed: () async {
              final picked = await FilePicker.platform.pickFiles(
                withData: true,
                type: FileType.custom,
                allowedExtensions: [
                  'txt',
                  'tle',
                ],
              );

              if (!context.mounted) {
                return;
              }

              if (picked == null) {
                return;
              }

              final data = String.fromCharCodes(picked.files[0].bytes!);
              final fromFile = o.TwoLineElement.parseMany(data);

              if (fromFile.isEmpty) {
                return;
              }

              final now = DateTime.now().toUtc();
              final m = sat.MapModel();
              m.satellites.addAll(
                fromFile.map(
                  (e) => sat.SatelliteModel(e),
                ),
              );

              final observer = sat.model.stations[0].location;
              m.sortByElevation(observer, now);

              final selection = await showDialog<List<sat.SatelliteModel>>(
                context: context,
                builder: (context) => Dialog(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SatelliteSelectionDialog(
                      model: m,
                    ),
                  ),
                ),
              );

              if (selection == null) {
                return;
              }

              for (var s in selection) {
                sat.model.satellites.add(s);
              }

              setState(() {});
            },
            tooltip: 'Add Satellite',
            icon: const Icon(Icons.satellite_alt),
          ),
        ],
      ),
      body: body,
    );
  }
}

const double rad2deg = 180.0 / pi;
const double deg2rad = pi / 180.0;

class MapStyle {
  MapStyle({
    required this.name,
    required String prefix,
    required String extension,
    this.minZoom = 2,
    this.maxZoom = 9,
  }) : url = X(prefix, extension).call;

  MapStyle.online({
    required this.name,
    this.minZoom = 2,
    this.maxZoom = 9,
  }) : url = Online().call;

  final String name;
  String Function(int z, int x, int y) url;
  final int minZoom;
  final int maxZoom;
}

class X {
  const X(this.prefix, this.extension);

  final String prefix;
  final String extension;

  String call(int z, int x, int y) {
    return '/map/$prefix/$z/$x/$y$extension';
  }
}

class Online {
  String call(int z, int x, int y) {
    //Google Maps
    final url =
        'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';

    return url;
  }
}

final google = MapStyle(
  name: 'Google',
  prefix: 'google',
  extension: '.png',
);
final imagery = MapStyle(
  name: 'Imagery',
  prefix: 'imagery',
  extension: '.webp',
);
final greyscale = MapStyle(
  name: 'Greyscale',
  prefix: 'greyscale',
  extension: '.png',
);

final carmela = MapStyle(
  name: 'Carmela',
  prefix: 'carmela',
  extension: '.png',
);

final dark = MapStyle(
  name: 'Dark',
  prefix: 'dark',
  extension: '.png',
);

final online = MapStyle.online(
  name: 'Google (Online)',
);

final mapStyles = [
  google,
  imagery,
  greyscale,
  carmela,
  dark,
  online,
];

class SatelliteListItem extends StatefulWidget {
  const SatelliteListItem({super.key, required this.satellite});

  final sat.SatelliteModel satellite;

  @override
  State<StatefulWidget> createState() => SatelliteListItemState();
}

class SatelliteListItemState extends State<SatelliteListItem> {
  @override
  void initState() {
    widget.satellite.addListener(_listen);
    super.initState();
  }

  @override
  void dispose() {
    widget.satellite.removeListener(_listen);
    super.dispose();
  }

  void _listen() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.satellite;
    final la = s.lookAngle;

    Widget? icon;

    if (s.rising) {
      icon = const Icon(Icons.arrow_upward);
    } else if (s.setting) {
      icon = const Icon(Icons.arrow_downward);
    }

    return ListTile(
      key: ValueKey(s.gp.name),
      dense: true,
      selectedTileColor: s.color.withOpacity(0.5),
      onTap: () {
        sat.model.selection = s;
        setState(() {});
      },
      onLongPress: () {
        final now = DateTime.now().toUtc();
        final orbs = s.sgp.propagate(now, pages);
        if (orbs.isNotEmpty) {
          s.orbits = orbs;

          for (final station in sat.model.stations) {
            final per = sat.model.get(s, station);
            per.passes = Pass.predict(l.wgs84, station.location, orbs);
          }
        }
      },
      selected: sat.model.selection == s,
      leading: icon,
      trailing: IconButton(
        onPressed: () {
          setState(() {
            s.showGroundTrack = !s.showGroundTrack;
          });
        },
        icon: Icon(
          s.showGroundTrack ? Icons.circle : Icons.circle_outlined,
          color: s.color,
          size: 24,
        ),
      ),
      title: Text(s.gp.name),
      subtitle: la != null
          ? Text(
              'Elevation: ${la.elevation.degrees.toStringAsFixed(2)}°, Azimuth: ${la.azimuth.degrees.toStringAsFixed(2)}°',
            )
          : null,
    );
  }
}

void _paintOrbit(
  Canvas canvas,
  List<Offset> points,
  Object? metadata,
  Color color,
  double strokeWidth,
) {
  final path = Path()..addPolygon(points, false);
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth;

  canvas.drawPath(path, paint);
}

void _paintPassToStation(
  Canvas canvas,
  List<Offset> points,
  Object? metadata,
  MapTransformer transformer,
  Color stationColor,
  l.LatLng stationLocation,
  Pass pass,
  double strokeWidth,
) {
  final p = transformer.toOffset(stationLocation);
  final pnt = [p, ...points, p];
  final path = Path()..addPolygon(pnt, true);
  final paint = Paint()
    ..color = stationColor.withOpacity(0.4)
    ..style = PaintingStyle.fill
    ..strokeWidth = strokeWidth;

  canvas.drawPath(path, paint);
}

void _paintVisibility(
    Canvas canvas, List<Offset> points, Object? metadata, Color color) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  final basecolor = color.withAlpha(255);

  final path = Path()..addPolygon(points, true);

  paint.color = basecolor.withOpacity(0.4);
  paint.style = PaintingStyle.fill;
  canvas.drawPath(path, paint);

  paint.color = basecolor;
  paint.style = PaintingStyle.stroke;
  canvas.drawPath(path, paint);
}

Iterable<Shape> _getSatellitePassShapes(
  sat.MapModel model,
  MapTransformer transformer,
) {
  List<Shape> ret = [];

  for (final station in sat.model.stations) {
    for (final s in model.satellites) {
      final pre = sat.model.get(s, station);
      final passes = pre.passes;
      if (passes == null) {
        continue;
      }

      ret.addAll(_getPassToStationShapes(passes, transformer, station));
    }
  }

  return ret;
}

Iterable<Shape> _getSatelliteOrbitShapes(List<sat.SatelliteModel> sats) {
  List<Shape> ret = [];

  for (final s in sats) {
    final orbits = s.orbits;
    if (orbits == null) {
      continue;
    }

    ret.addAll(_getOrbitShapes(orbits, s.color));
  }

  return ret;
}

Iterable<Shape> _getOrbitShapes(List<Orbit> orbits, Color color) {
  return orbits.map(
    (orbit) => Shape(
      points: orbit.points
          .map(
            (e) => l.LatLng.degree(
              e.location.latitude.degrees,
              e.location.longitude.degrees,
            ),
          )
          .toList(),
      painter: (c, s, m) => _paintOrbit(c, s, m, color, 2),
    ),
  );
}

Iterable<Shape> _getPassToStationShapes(
  List<Pass> passes,
  MapTransformer transformer,
  sat.Station station,
) {
  return passes.map((pass) {
    return Shape(
      points:
          pass.points.map((point) => point.point.location.toLatLng()).toList(),
      painter: (c, s, m) => _paintPassToStation(
        c,
        s,
        m,
        transformer,
        station.color,
        station.location.toLatLng().page(pass.orbit),
        pass,
        8,
      ),
    );
  });
}

Widget _buildPassPoint(
    sat.Station station, MapTransformer transformer, PassPoint point) {
  const satelliteSize = 8.0;
  final az = point.lookAngle.azimuth.degrees.toStringAsFixed(2);
  final el = point.lookAngle.elevation.degrees.toStringAsFixed(2);
  final time = point.point.time.toDateTime().toLocal().toString();
  final doppler = point.dopplerFactor.toStringAsFixed(16);

  final lines = [
    'Look: A: $az, E: $el',
    'Time: $time',
    'Doppler: $doppler',
  ];

  final maxOffset = transformer.toOffset(point.point.location.toLatLng());

  final t = Positioned(
    left: maxOffset.dx - satelliteSize / 2,
    top: maxOffset.dy - satelliteSize / 2,
    child: Tooltip(
      message: lines.join('\n'),
      child: Icon(
        Icons.circle,
        color: station.color,
        size: satelliteSize,
      ),
    ),
  );

  return t;
}

extension _X on l.LatLng {
  l.LatLng page(int i) {
    return l.LatLng.degree(latitude.degrees, longitude.degrees + i * 360);
  }
}
