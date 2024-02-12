import 'dart:math';

import 'package:latlng/latlng.dart';

const double _r2d = 180 / pi;
const double _d2r = pi / 180;

_SunEclipticPosition _sunEclipticPosition(double julianDay) {
  /* Compute the position of the Sun in ecliptic coordinates at
			 julianDay.  Following
			 http://en.wikipedia.org/wiki/Position_of_the_Sun */
  // Days since start of J2000.0
  var n = julianDay - 2451545.0;
  // mean longitude of the Sun
  var L = 280.460 + 0.9856474 * n;
  L %= 360;
  // mean anomaly of the Sun
  var g = 357.528 + 0.9856003 * n;
  g %= 360;
  // ecliptic longitude of Sun
  var lambda = L + 1.915 * sin(g * _d2r) + 0.02 * sin(2 * g * _d2r);
  // distance from Sun in AU
  var radius = 1.00014 - 0.01671 * cos(g * _d2r) - 0.0014 * cos(2 * g * _d2r);
  return _SunEclipticPosition(lambda: lambda, radius: radius);
}

double _eclipticObliquity(double julianDay) {
  // Following the short term expression in
  // http://en.wikipedia.org/wiki/Axial_tilt#Obliquity_of_the_ecliptic_.28Earth.27s_axial_tilt.29
  var n = julianDay - 2451545.0;
  // Julian centuries since J2000.0
  var T = n / 36525;
  var epsilon = 23.43929111 -
      T *
          (46.836769 / 3600 -
              T *
                  (0.0001831 / 3600 +
                      T *
                          (0.00200340 / 3600 -
                              T * (0.576e-6 / 3600 - T * 4.34e-8 / 3600))));
  return epsilon;
}

_AlphaDelta _sunEquatorialPosition(double sunEclLng, double eclObliq) {
  /* Compute the Sun's equatorial position from its ecliptic
		 * position. Inputs are expected in degrees. Outputs are in
		 * degrees as well. */
  var alpha = atan(cos(eclObliq * _d2r) * tan(sunEclLng * _d2r)) * _r2d;
  var delta = asin(sin(eclObliq * _d2r) * sin(sunEclLng * _d2r)) * _r2d;

  var lQuadrant = (sunEclLng / 90.0).floor() * 90;
  var raQuadrant = (alpha / 90.0).floor() * 90;
  alpha = alpha + (lQuadrant - raQuadrant);

  return _AlphaDelta(alpha: alpha, delta: delta);
}

Angle _hourAngle(Angle lng, _AlphaDelta sunPos, Angle gst) {
  /* Compute the hour angle of the sun for a longitude on
		 * Earth. Return the hour angle in degrees. */
  final lst = gst.degrees + lng.degrees / 15;
  return Angle.degree(lst * 15 - sunPos.alpha);
}

double _latitude(Angle ha, _AlphaDelta sunPos) {
  /* For a given hour angle and sun position, compute the
		 * latitude of the terminator in degrees. */
  var lat = atan(-cos(ha.radians) / tan(sunPos.delta * _d2r)) * _r2d;
  return lat;
}

class _SunEclipticPosition {
  _SunEclipticPosition({required this.lambda, required this.radius});

  final double lambda;
  final double radius;
}

class _AlphaDelta {
  _AlphaDelta({required this.alpha, required this.delta});

  final double alpha;
  final double delta;
}

class Twilight {
  factory Twilight.civil(DateTime time, [double resolution = 0.1]) {
    final julianDay = time.julian;

    final gst = julianDay.gmst;
    var latLng = <LatLng>[];

    var sunEclPos = _sunEclipticPosition(julianDay.value);
    var eclObliq = _eclipticObliquity(julianDay.value);
    var sunEqPos = _sunEquatorialPosition(sunEclPos.lambda, eclObliq);
    for (var i = 0; i <= 360 * resolution; i++) {
      final lng = Angle.degree(-180 + i / resolution);
      final ha = _hourAngle(lng, sunEqPos, gst);
      latLng.add(LatLng(Angle.degree(_latitude(ha, sunEqPos)), lng));
    }

    return Twilight._(latLng, sunEqPos.delta);
  }

  Twilight._(this.polyline, this.delta);
  final List<LatLng> polyline;
  final double delta;
}
