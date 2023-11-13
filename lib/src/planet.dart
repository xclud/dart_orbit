part of '../orbit.dart';

/// Abstract planet for calculations.
abstract class Planet {
  /// The constructor.
  const Planet({
    required this.radius,
    required this.mu,
    required this.j2,
    required this.j3,
    required this.j4,
    required this.flattening,
  });

  /// Radius of the planet in Kilometers.
  final double radius;

  /// Gravitational constant.
  final double mu;

  /// j2
  final double j2;

  /// j3
  final double j3;

  /// j4
  final double j4;

  /// Flattening of the planet.
  final double flattening;
}

/// Represents Earth planet.
class Earth extends Planet {
  const Earth._({
    required double radius,
    required double mu,
    required double j2,
    required double j3,
    required double j4,
    required double flattening,
  }) : super(
          radius: radius,
          mu: mu,
          j2: j2,
          j3: j3,
          j4: j4,
          flattening: flattening,
        );

  /// Represents a WGS72 Earth.
  factory Earth.wgs72() => _wgs72;

  /// Represents a WGS84 Earth.
  factory Earth.wgs84() => _wgs84;

  static const _wgs72 = Earth._(
    radius: 6378.135,
    mu: 398600.8,
    j2: 0.0010826162,
    j3: -0.00000253881,
    j4: -0.00000165597,
    flattening: 1 / 298.26,
  );

  static const _wgs84 = Earth._(
    radius: 6378.137,
    mu: 398600.5,
    j2: 0.00108262998905,
    j3: -0.00000253215306,
    j4: -0.00000161098761,
    flattening: 1 / 298.257223563,
  );
}
