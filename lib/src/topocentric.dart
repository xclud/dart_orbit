part of '../orbit.dart';

/// Topocentric parameters.
class Topocentric {
  /// The constructor.
  const Topocentric({
    required this.south,
    required this.east,
    required this.normal,
  });

  /// South
  final double south;

  /// East
  final double east;

  /// Normal
  final double normal;
}
