part of '../orbit.dart';

/// RV Pair for satellite state.
class OrbitalState {
  /// The constructor.
  const OrbitalState(this.r, this.v);

  /// r
  final EarthCenteredInertial r;

  /// v
  final EarthCenteredInertial v;

  /// Calculate Doppler Factor.
  double dopplerFactor(EarthCenteredInertial observer) {
    const mfactor = 7.292115E-5;
    const c = 299792.458; // Speed of light in km/s

    final position = r;
    final velocity = v;

    final rangex = position.x - observer.x;
    final rangey = position.y - observer.y;
    final rangez = position.z - observer.z;

    final rangew =
        sqrt((rangex * rangex) + (rangey * rangey) + (rangez * rangez));

    final rangeVelx = velocity.x + mfactor * observer.y;
    final rangeVely = velocity.y - mfactor * observer.x;
    final rangeVelz = velocity.z;

    double sign(value) {
      return value >= 0 ? 1 : -1;
    }

    final rangeRate =
        (rangex * rangeVelx + rangey * rangeVely + rangez * rangeVelz) / rangew;

    final result = 1 + rangeRate / c * sign(rangeRate);

    return result;
  }
}
