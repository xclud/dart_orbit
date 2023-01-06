part of orbit;

/// Encapsulates geocentric coordinates.
class Geodetic {
  /// Creates a new instance of the class with the given components.
  const Geodetic({
    required this.latitude,
    required this.longitude,
    required this.altitude,
  });

  /// Latitude, in radians. A negative value indicates latitude south.
  final double latitude;

  /// Longitude, in radians. A negative value indicates longitude west.
  final double longitude;

  /// Altitude, in kilometers, above the ellipsoid model.
  final double altitude;
}
