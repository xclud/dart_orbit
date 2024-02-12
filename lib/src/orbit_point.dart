part of '../orbit.dart';

/// An orbital point in time.
class OrbitPoint {
  ///
  OrbitPoint(this.time, this.state, this.location);

  ///
  final double time;

  ///
  final OrbitalState state;

  ///
  final LatLngAlt location;
}
