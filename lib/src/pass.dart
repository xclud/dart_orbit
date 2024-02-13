part of '../orbit.dart';

/// Satellite pass.
class Pass {
  const Pass._(this.points, this.max);

  ///
  final List<PassPoint> points;

  ///
  final PassPoint max;

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
        final topocentric = planet.topocentric(observer, ecf);
        final la = topocentric.toLookAngle();
        final passPoint = PassPoint(point, ecf, topocentric, la);

        max ??= passPoint;

        if (la.elevation.degrees > max.lookAngle.elevation.degrees) {
          max = passPoint;
        }

        if (la.elevation.degrees < 0) {
          if (current.isNotEmpty) {
            ret.add(Pass._(current, max));

            current = [];
          }

          continue;
        }

        current.add(passPoint);
      }
    }

    if (current.isNotEmpty && max != null) {
      ret.add(Pass._(current, max));
    }

    return ret;
  }
}
