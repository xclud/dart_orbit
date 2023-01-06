part of orbit;

/// Encapsulates topo-centric coordinates.
class LookAngle {
  /// Creates a new instance of the class from the given components.
  const LookAngle({
    required this.azimuth,
    required this.elevation,
    required this.range,
    required this.rate,
  });

  /// The azimuth, in radians.
  final double azimuth;

  /// The elevation, in radians.
  final double elevation;

  /// The range, in kilometers.
  final double range;

  /// The range rate, in kilometers per second.
  /// A negative value means "towards observer".
  final double rate;
}
