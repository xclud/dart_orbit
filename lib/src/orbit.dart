part of orbit;

/// The main class to start orbit calculation.
class Orbit {
  /// The constructor.
  Orbit({
    required this.keplerianElements,
    required this.planet,
  }) : _norad = SGP4(keplerianElements, planet);

  /// planet
  final Planet planet;

  /// keplerianElements
  final KeplerianElements keplerianElements;

  /// _norad
  final SGP4 _norad;

  /// The orbital state of a satellite in time.
  OrbitalState getPosition(double minutesSinceEpoch) {
    return _norad.getPosition(minutesSinceEpoch);
  }

  /// The orbital state of a satellite in time.
  OrbitalState getPositionByDateTime(DateTime utc) {
    return _norad.getPositionByDateTime(utc);
  }
}
