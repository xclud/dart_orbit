import 'package:orbit/orbit.dart';
import 'package:orbit/src/sgp4.dart';

class Orbit {
  Orbit({
    required this.keplerianElements,
    required this.planet,
  }) : _norad = SGP4(keplerianElements, planet);

  final Planet planet;
  final KeplerianElements keplerianElements;
  final SGP4 _norad;

  OrbitalState getPosition(double minutesSinceEpoch) {
    return _norad.getPosition(minutesSinceEpoch);
  }

  OrbitalState getPositionByDateTime(DateTime utc) {
    return _norad.getPositionByDateTime(utc);
  }
}
