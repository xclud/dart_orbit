part of '../orbit.dart';

/// Satellite pass.
class Pass {
  const Pass._(this.points, this.max, this.orbit);

  ///
  final List<PassPoint> points;

  ///
  final PassPoint max;

  ///
  final int orbit;

  /// Predict.
  static List<Pass> predict(
    Planet planet,
    LatLngAlt observer,
    List<Orbit> orbits,
  ) {
    List<Pass> ret = [];
    List<PassPoint> current = [];
    PassPoint? max;

    for (final orbit in orbits) {
      for (final point in orbit.points) {
        final ecf = point.state.r.toEcf(point.time.gmst);

        final eci = ecf.toEci(point.time.gmst);
        final doppler = point.state.dopplerFactor(eci);
        final topocentric = planet.topocentric(observer, ecf);
        final la = topocentric.toLookAngle();
        final passPoint = PassPoint._(point, ecf, topocentric, la, doppler);

        max ??= passPoint;

        if (la.elevation.degrees > max.lookAngle.elevation.degrees) {
          max = passPoint;
        }

        if (la.elevation.degrees < 0) {
          if (current.isNotEmpty) {
            ret.add(Pass._(current, max, orbit.index));

            current = [];
            max = null;
          }

          continue;
        }

        current.add(passPoint);
      }
    }

    if (current.isNotEmpty && max != null) {
      ret.add(Pass._(current, max, orbits.last.index));
    }

    return ret;
  }
}
