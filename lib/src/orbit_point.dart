part of '../orbit.dart';

/// An orbital point in time.
class OrbitPoint {
  ///
  const OrbitPoint(this.time, this.state, this.location);

  ///
  final Julian time;

  ///
  final OrbitalState state;

  ///
  final LatLngAlt location;
}

///
class PassPoint {
  ///
  const PassPoint._(
    this.point,
    this.ecf,
    this.topocentric,
    this.lookAngle,
    this.dopplerFactor,
  );

  ///
  final OrbitPoint point;

  ///
  final EarthCenteredEarthFixed ecf;

  ///
  final Topocentric topocentric;

  ///
  final LookAngle lookAngle;

  /// Doppler factor at this point.
  final double dopplerFactor;
}
