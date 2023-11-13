part of '../orbit.dart';

/// Earth-centered inertial (ECI) coordinate frames have their origins at the center of
/// mass of [Planet] and are fixed with respect to the stars.
class EarthCenteredInertial {
  /// The default constructor.
  EarthCenteredInertial(this.x, this.y, this.z);

  /// X Coordinate.
  final double x;

  /// Y Coordinate.
  final double y;

  /// Z Coordinate.
  final double z;
}
