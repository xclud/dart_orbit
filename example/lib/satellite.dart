import 'dart:math';

import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';
import 'package:orbit/orbit.dart';

class SatelliteModel extends ChangeNotifier {
  SatelliteModel(this.gp)
      : sgp = SGP4(gp.keplerianElements, wgs84),
        _color = _nextColor(gp.name);

  final TwoLineElement gp;
  final SGP4 sgp;

  List<Orbit>? orbits;

  LookAngle? _lookAngle;

  LookAngle? get lastLookAngle => _lastLookAngle;
  LookAngle? get lookAngle => _lookAngle;

  set lookAngle(LookAngle? v) {
    _lastLookAngle = _lookAngle;
    _lookAngle = v;
    notifyListeners();
  }

  bool get rising {
    final lla = _lastLookAngle;
    final la = _lookAngle;

    return lla != null &&
        la != null &&
        la.elevation.degrees > lla.elevation.degrees;
  }

  bool get setting {
    final lla = _lastLookAngle;
    final la = _lookAngle;

    return lla != null &&
        la != null &&
        la.elevation.degrees < lla.elevation.degrees;
  }

  LookAngle? _lastLookAngle;
  LatLngAlt? location;
  List<LatLng>? visibility;

  bool _showGroundTrack = false;
  bool get showGroundTrack => _showGroundTrack;
  set showGroundTrack(bool v) {
    _showGroundTrack = v;
    notifyListeners();
  }

  Color _color;
  Color get color => _color;
  set color(Color v) {
    _color = v;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}

class MapModel {
  MapModel();

  final stations = _stations;

  final satellites = <SatelliteModel>[];
  final per = <String, PerStationPerSatellite>{};

  PerStationPerSatellite get(SatelliteModel satellite, Station station) {
    final key = '${satellite.gp.name}---${station.name}';
    var i = per[key];

    if (i != null) {
      return i;
    }

    i = PerStationPerSatellite._(satellite, station);
    per[key] = i;

    return i;
  }

  SatelliteModel? selection;

  void updateSatellites() {
    final now = DateTime.now().toUtc();

    for (final satellite in satellites) {
      final rv = satellite.sgp.getPositionByDateTime(now);

      final location = rv.r.toGeodeticByDateTime(wgs84, now);
      final ecf = rv.r.toEcfByDateTime(now);
      final lookAngle =
          wgs84.topocentric(stations[0].location, ecf).toLookAngle();

      satellite.lookAngle = lookAngle;
      satellite.location = location;
      satellite.visibility = wgs84.getGroundTrack(location);

      satellite.notify();
    }
  }

  /// Sorts TLEs by elevation.
  void sortByElevation(
    LatLngAlt observer,
    DateTime utc, [
    Planet planet = wgs84,
  ]) {
    //
    updateSatellites();

    satellites.sort((x, y) => (y.lookAngle?.elevation.degrees ?? -90)
        .compareTo(x.lookAngle?.elevation.degrees ?? -90));
  }
}

class Station {
  const Station(this.name, this.color, this.location);
  final String name;
  final Color color;
  final LatLngAlt location;
}

final model = MapModel();

final _colors = [
  Colors.brown,
  Colors.deepOrange,
  Colors.deepPurple,
  Colors.green,
  Colors.indigo,
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.orange,
  Colors.pink,
  Colors.teal,
  Colors.yellow,
];

Color _nextColor(String name) {
  final rnd = Random(name.hashCode);
  final i = rnd.nextInt(_colors.length);

  return _colors[i];
}

class PerStationPerSatellite {
  PerStationPerSatellite._(this.satellite, this.station);

  final SatelliteModel satellite;
  final Station station;

  List<Pass>? passes;
}

const _stations = [
  Station(
    'Mahdasht',
    Colors.purple,
    LatLngAlt(
      Angle.degree(35),
      Angle.degree(0),
      1.1859, // In km.
    ),
  ),
  Station(
    'Qeshm',
    Colors.amber,
    LatLngAlt(
      Angle.degree(26.6154292),
      Angle.degree(55.4829691),
      0.1859, // In km.
    ),
  ),
];
