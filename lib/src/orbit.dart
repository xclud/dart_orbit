part of '../orbit.dart';

/// Orbit data.
class Orbit {
  /// The constructor.
  Orbit._(
    this.points,
    this.index,
  );

  /// Points in each Orbit.
  final List<OrbitPoint> points;

  /// Orbit index.
  final int index;
}
