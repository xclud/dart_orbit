part of '../orbit.dart';

/// An orbital point in time.
class OrbitPoint {
  ///
  OrbitPoint(this.minutesSinceEpoch, this.state, this.location);

  ///
  final double minutesSinceEpoch;

  ///
  final OrbitalState state;

  ///
  final LatLngAlt location;
}
