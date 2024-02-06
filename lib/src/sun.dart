// ignore_for_file: non_constant_identifier_names

part of '../orbit.dart';

enum _CalculationMode {
  //SPA_ZA, //calculate zenith and azimuth
  incidence, //calculate zenith, azimuth, and incidence
  rts, //calculate zenith, azimuth, and sun rise/transit/set values
  all, //calculate all SPA output values
}

int _validateInputs(_Date date, _SPAData spa, LatLng latLng) {
  if ((date.year < -2000) || (date.year > 6000)) return 1;
  if ((date.month < 1) || (date.month > 12)) return 2;
  if ((date.day < 1) || (date.day > 31)) return 3;
  if ((date.Hour < 0) || (date.Hour > 24)) return 4;
  if ((date.Minute < 0) || (date.Minute > 59)) return 5;
  if ((date.Second < 0) || (date.Second >= 60)) return 6;
  if ((spa.pressure < 0) || (spa.pressure > 5000)) return 12;
  if ((spa.temperature <= -273) || (spa.temperature > 6000)) return 13;
  if ((date.Hour == 24) && (date.Minute > 0)) return 5;
  if ((date.Hour == 24) && (date.Second > 0)) return 6;

  if ((spa.deltaT).abs() > 8000) return 7;
  if ((latLng.longitude).abs() > 180) return 9;
  if ((latLng.latitude).abs() > 90) return 10;
  if ((spa.atmosphericRefraction).abs() > 5) return 16;

  if ((spa.function == _CalculationMode.incidence) ||
      (spa.function == _CalculationMode.all)) {
    if ((spa.slope).abs() > 360) return 14;
    if ((spa.azimuthRotation).abs() > 360) return 15;
  }

  return 0;
}

const _pi = 3.1415926535897932384626433832795028841971;
const _sunRadius = 0.26667;

const _jdMinus = 0;
const _jdZero = 1;
const _jdPlus = 2;
const _jdCount = 3;

class _T3<T> {
  const _T3(this.a, this.b, this.c);
  final double a;
  final double b;
  final double c;
}

class _T4<T> {
  const _T4(this.a, this.b, this.c, this.d);
  final T a;
  final T b;
  final T c;
  final T d;
}

class _T5<T> {
  const _T5(this.a, this.b, this.c, this.d, this.e);
  final T a;
  final T b;
  final T c;
  final T d;
  final T e;
}

class _YP {
  const _YP(this.y, this.pe);

  final _T5<int> y;
  final _T4<double> pe;
}

const List<List<_T3<double>>> _l = [
  [
    _T3(175347046.0, 0, 0),
    _T3(3341656.0, 4.6692568, 6283.07585),
    _T3(34894.0, 4.6261, 12566.1517),
    _T3(3497.0, 2.7441, 5753.3849),
    _T3(3418.0, 2.8289, 3.5231),
    _T3(3136.0, 3.6277, 77713.7715),
    _T3(2676.0, 4.4181, 7860.4194),
    _T3(2343.0, 6.1352, 3930.2097),
    _T3(1324.0, 0.7425, 11506.7698),
    _T3(1273.0, 2.0371, 529.691),
    _T3(1199.0, 1.1096, 1577.3435),
    _T3(990, 5.233, 5884.927),
    _T3(902, 2.045, 26.298),
    _T3(857, 3.508, 398.149),
    _T3(780, 1.179, 5223.694),
    _T3(753, 2.533, 5507.553),
    _T3(505, 4.583, 18849.228),
    _T3(492, 4.205, 775.523),
    _T3(357, 2.92, 0.067),
    _T3(317, 5.849, 11790.629),
    _T3(284, 1.899, 796.298),
    _T3(271, 0.315, 10977.079),
    _T3(243, 0.345, 5486.778),
    _T3(206, 4.806, 2544.314),
    _T3(205, 1.869, 5573.143),
    _T3(202, 2.458, 6069.777),
    _T3(156, 0.833, 213.299),
    _T3(132, 3.411, 2942.463),
    _T3(126, 1.083, 20.775),
    _T3(115, 0.645, 0.98),
    _T3(103, 0.636, 4694.003),
    _T3(102, 0.976, 15720.839),
    _T3(102, 4.267, 7.114),
    _T3(99, 6.21, 2146.17),
    _T3(98, 0.68, 155.42),
    _T3(86, 5.98, 161000.69),
    _T3(85, 1.3, 6275.96),
    _T3(85, 3.67, 71430.7),
    _T3(80, 1.81, 17260.15),
    _T3(79, 3.04, 12036.46),
    _T3(75, 1.76, 5088.63),
    _T3(74, 3.5, 3154.69),
    _T3(74, 4.68, 801.82),
    _T3(70, 0.83, 9437.76),
    _T3(62, 3.98, 8827.39),
    _T3(61, 1.82, 7084.9),
    _T3(57, 2.78, 6286.6),
    _T3(56, 4.39, 14143.5),
    _T3(56, 3.47, 6279.55),
    _T3(52, 0.19, 12139.55),
    _T3(52, 1.33, 1748.02),
    _T3(51, 0.28, 5856.48),
    _T3(49, 0.49, 1194.45),
    _T3(41, 5.37, 8429.24),
    _T3(41, 2.4, 19651.05),
    _T3(39, 6.17, 10447.39),
    _T3(37, 6.04, 10213.29),
    _T3(37, 2.57, 1059.38),
    _T3(36, 1.71, 2352.87),
    _T3(36, 1.78, 6812.77),
    _T3(33, 0.59, 17789.85),
    _T3(30, 0.44, 83996.85),
    _T3(30, 2.74, 1349.87),
    _T3(25, 3.16, 4690.48),
  ],
  [
    _T3(628331966747.0, 0, 0),
    _T3(206059.0, 2.678235, 6283.07585),
    _T3(4303.0, 2.6351, 12566.1517),
    _T3(425.0, 1.59, 3.523),
    _T3(119.0, 5.796, 26.298),
    _T3(109.0, 2.966, 1577.344),
    _T3(93, 2.59, 18849.23),
    _T3(72, 1.14, 529.69),
    _T3(68, 1.87, 398.15),
    _T3(67, 4.41, 5507.55),
    _T3(59, 2.89, 5223.69),
    _T3(56, 2.17, 155.42),
    _T3(45, 0.4, 796.3),
    _T3(36, 0.47, 775.52),
    _T3(29, 2.65, 7.11),
    _T3(21, 5.34, 0.98),
    _T3(19, 1.85, 5486.78),
    _T3(19, 4.97, 213.3),
    _T3(17, 2.99, 6275.96),
    _T3(16, 0.03, 2544.31),
    _T3(16, 1.43, 2146.17),
    _T3(15, 1.21, 10977.08),
    _T3(12, 2.83, 1748.02),
    _T3(12, 3.26, 5088.63),
    _T3(12, 5.27, 1194.45),
    _T3(12, 2.08, 4694),
    _T3(11, 0.77, 553.57),
    _T3(10, 1.3, 6286.6),
    _T3(10, 4.24, 1349.87),
    _T3(9, 2.7, 242.73),
    _T3(9, 5.64, 951.72),
    _T3(8, 5.3, 2352.87),
    _T3(6, 2.65, 9437.76),
    _T3(6, 4.67, 4690.48),
  ],
  [
    _T3(52919.0, 0, 0),
    _T3(8720.0, 1.0721, 6283.0758),
    _T3(309.0, 0.867, 12566.152),
    _T3(27, 0.05, 3.52),
    _T3(16, 5.19, 26.3),
    _T3(16, 3.68, 155.42),
    _T3(10, 0.76, 18849.23),
    _T3(9, 2.06, 77713.77),
    _T3(7, 0.83, 775.52),
    _T3(5, 4.66, 1577.34),
    _T3(4, 1.03, 7.11),
    _T3(4, 3.44, 5573.14),
    _T3(3, 5.14, 796.3),
    _T3(3, 6.05, 5507.55),
    _T3(3, 1.19, 242.73),
    _T3(3, 6.12, 529.69),
    _T3(3, 0.31, 398.15),
    _T3(3, 2.28, 553.57),
    _T3(2, 4.38, 5223.69),
    _T3(2, 3.75, 0.98),
  ],
  [
    _T3(289.0, 5.844, 6283.076),
    _T3(35, 0, 0),
    _T3(17, 5.49, 12566.15),
    _T3(3, 5.2, 155.42),
    _T3(1, 4.72, 3.52),
    _T3(1, 5.3, 18849.23),
    _T3(1, 5.97, 242.73),
  ],
  [
    _T3(114.0, 3.142, 0),
    _T3(8, 4.13, 6283.08),
    _T3(1, 3.84, 12566.15),
  ],
  [
    _T3(1, 3.14, 0),
  ]
];

const List<List<_T3<double>>> _b = [
  [
    _T3(280.0, 3.199, 84334.662),
    _T3(102.0, 5.422, 5507.553),
    _T3(80, 3.88, 5223.69),
    _T3(44, 3.7, 2352.87),
    _T3(32, 4, 1577.34),
  ],
  [
    _T3(9, 3.9, 5507.55),
    _T3(6, 1.73, 5223.69),
  ]
];

const List<List<_T3<double>>> _r = [
  [
    _T3(100013989.0, 0, 0),
    _T3(1670700.0, 3.0984635, 6283.07585),
    _T3(13956.0, 3.05525, 12566.1517),
    _T3(3084.0, 5.1985, 77713.7715),
    _T3(1628.0, 1.1739, 5753.3849),
    _T3(1576.0, 2.8469, 7860.4194),
    _T3(925.0, 5.453, 11506.77),
    _T3(542.0, 4.564, 3930.21),
    _T3(472.0, 3.661, 5884.927),
    _T3(346.0, 0.964, 5507.553),
    _T3(329.0, 5.9, 5223.694),
    _T3(307.0, 0.299, 5573.143),
    _T3(243.0, 4.273, 11790.629),
    _T3(212.0, 5.847, 1577.344),
    _T3(186.0, 5.022, 10977.079),
    _T3(175.0, 3.012, 18849.228),
    _T3(110.0, 5.055, 5486.778),
    _T3(98, 0.89, 6069.78),
    _T3(86, 5.69, 15720.84),
    _T3(86, 1.27, 161000.69),
    _T3(65, 0.27, 17260.15),
    _T3(63, 0.92, 529.69),
    _T3(57, 2.01, 83996.85),
    _T3(56, 5.24, 71430.7),
    _T3(49, 3.25, 2544.31),
    _T3(47, 2.58, 775.52),
    _T3(45, 5.54, 9437.76),
    _T3(43, 6.01, 6275.96),
    _T3(39, 5.36, 4694),
    _T3(38, 2.39, 8827.39),
    _T3(37, 0.83, 19651.05),
    _T3(37, 4.9, 12139.55),
    _T3(36, 1.67, 12036.46),
    _T3(35, 1.84, 2942.46),
    _T3(33, 0.24, 7084.9),
    _T3(32, 0.18, 5088.63),
    _T3(32, 1.78, 398.15),
    _T3(28, 1.21, 6286.6),
    _T3(28, 1.9, 6279.55),
    _T3(26, 4.59, 10447.39),
  ],
  [
    _T3(103019.0, 1.10749, 6283.07585),
    _T3(1721.0, 1.0644, 12566.1517),
    _T3(702.0, 3.142, 0),
    _T3(32, 1.02, 18849.23),
    _T3(31, 2.84, 5507.55),
    _T3(25, 1.32, 5223.69),
    _T3(18, 1.42, 1577.34),
    _T3(10, 5.91, 10977.08),
    _T3(9, 1.42, 6275.96),
    _T3(9, 0.27, 5486.78),
  ],
  [
    _T3(4359.0, 5.7846, 6283.0758),
    _T3(124.0, 5.579, 12566.152),
    _T3(12, 3.14, 0),
    _T3(9, 3.63, 77713.77),
    _T3(6, 1.87, 5573.14),
    _T3(3, 5.47, 18849.23),
  ],
  [
    _T3(145.0, 4.273, 6283.076),
    _T3(7, 3.92, 12566.15),
  ],
  [
    _T3(4, 2.56, 6283.08),
  ]
];

const List<_YP> _ype = [
  _YP(_T5(0, 0, 0, 0, 1), _T4(-171996, -174.2, 92025, 8.9)),
  _YP(_T5(-2, 0, 0, 2, 2), _T4(-13187, -1.6, 5736, -3.1)),
  _YP(_T5(0, 0, 0, 2, 2), _T4(-2274, -0.2, 977, -0.5)),
  _YP(_T5(0, 0, 0, 0, 2), _T4(2062, 0.2, -895, 0.5)),
  _YP(_T5(0, 1, 0, 0, 0), _T4(1426, -3.4, 54, -0.1)),
  _YP(_T5(0, 0, 1, 0, 0), _T4(712, 0.1, -7, 0)),
  _YP(_T5(-2, 1, 0, 2, 2), _T4(-517, 1.2, 224, -0.6)),
  _YP(_T5(0, 0, 0, 2, 1), _T4(-386, -0.4, 200, 0)),
  _YP(_T5(0, 0, 1, 2, 2), _T4(-301, 0, 129, -0.1)),
  _YP(_T5(-2, -1, 0, 2, 2), _T4(217, -0.5, -95, 0.3)),
  _YP(_T5(-2, 0, 1, 0, 0), _T4(-158, 0, 0, 0)),
  _YP(_T5(-2, 0, 0, 2, 1), _T4(129, 0.1, -70, 0)),
  _YP(_T5(0, 0, -1, 2, 2), _T4(123, 0, -53, 0)),
  _YP(_T5(2, 0, 0, 0, 0), _T4(63, 0, 0, 0)),
  _YP(_T5(0, 0, 1, 0, 1), _T4(63, 0.1, -33, 0)),
  _YP(_T5(2, 0, -1, 2, 2), _T4(-59, 0, 26, 0)),
  _YP(_T5(0, 0, -1, 0, 1), _T4(-58, -0.1, 32, 0)),
  _YP(_T5(0, 0, 1, 2, 1), _T4(-51, 0, 27, 0)),
  _YP(_T5(-2, 0, 2, 0, 0), _T4(48, 0, 0, 0)),
  _YP(_T5(0, 0, -2, 2, 1), _T4(46, 0, -24, 0)),
  _YP(_T5(2, 0, 0, 2, 2), _T4(-38, 0, 16, 0)),
  _YP(_T5(0, 0, 2, 2, 2), _T4(-31, 0, 13, 0)),
  _YP(_T5(0, 0, 2, 0, 0), _T4(29, 0, 0, 0)),
  _YP(_T5(-2, 0, 1, 2, 2), _T4(29, 0, -12, 0)),
  _YP(_T5(0, 0, 0, 2, 0), _T4(26, 0, 0, 0)),
  _YP(_T5(-2, 0, 0, 2, 0), _T4(-22, 0, 0, 0)),
  _YP(_T5(0, 0, -1, 2, 1), _T4(21, 0, -10, 0)),
  _YP(_T5(0, 2, 0, 0, 0), _T4(17, -0.1, 0, 0)),
  _YP(_T5(2, 0, -1, 0, 1), _T4(16, 0, -8, 0)),
  _YP(_T5(-2, 2, 0, 2, 2), _T4(-16, 0.1, 7, 0)),
  _YP(_T5(0, 1, 0, 0, 1), _T4(-15, 0, 9, 0)),
  _YP(_T5(-2, 0, 1, 0, 1), _T4(-13, 0, 7, 0)),
  _YP(_T5(0, -1, 0, 0, 1), _T4(-12, 0, 6, 0)),
  _YP(_T5(0, 0, 2, -2, 0), _T4(11, 0, 0, 0)),
  _YP(_T5(2, 0, -1, 2, 1), _T4(-10, 0, 5, 0)),
  _YP(_T5(2, 0, 1, 2, 2), _T4(-8, 0, 3, 0)),
  _YP(_T5(0, 1, 0, 2, 2), _T4(7, 0, -3, 0)),
  _YP(_T5(-2, 1, 1, 0, 0), _T4(-7, 0, 0, 0)),
  _YP(_T5(0, -1, 0, 2, 2), _T4(-7, 0, 3, 0)),
  _YP(_T5(2, 0, 0, 2, 1), _T4(-7, 0, 3, 0)),
  _YP(_T5(2, 0, 1, 0, 0), _T4(6, 0, 0, 0)),
  _YP(_T5(-2, 0, 2, 2, 2), _T4(6, 0, -3, 0)),
  _YP(_T5(-2, 0, 1, 2, 1), _T4(6, 0, -3, 0)),
  _YP(_T5(2, 0, -2, 0, 1), _T4(-6, 0, 3, 0)),
  _YP(_T5(2, 0, 0, 0, 1), _T4(-6, 0, 3, 0)),
  _YP(_T5(0, -1, 1, 0, 0), _T4(5, 0, 0, 0)),
  _YP(_T5(-2, -1, 0, 2, 1), _T4(-5, 0, 3, 0)),
  _YP(_T5(-2, 0, 0, 0, 1), _T4(-5, 0, 3, 0)),
  _YP(_T5(0, 0, 2, 2, 1), _T4(-5, 0, 3, 0)),
  _YP(_T5(-2, 0, 2, 0, 1), _T4(4, 0, 0, 0)),
  _YP(_T5(-2, 1, 0, 2, 1), _T4(4, 0, 0, 0)),
  _YP(_T5(0, 0, 1, -2, 0), _T4(4, 0, 0, 0)),
  _YP(_T5(-1, 0, 1, 0, 0), _T4(-4, 0, 0, 0)),
  _YP(_T5(-2, 1, 0, 0, 0), _T4(-4, 0, 0, 0)),
  _YP(_T5(1, 0, 0, 0, 0), _T4(-4, 0, 0, 0)),
  _YP(_T5(0, 0, 1, 2, 0), _T4(3, 0, 0, 0)),
  _YP(_T5(0, 0, -2, 2, 2), _T4(-3, 0, 0, 0)),
  _YP(_T5(-1, -1, 1, 0, 0), _T4(-3, 0, 0, 0)),
  _YP(_T5(0, 1, 1, 0, 0), _T4(-3, 0, 0, 0)),
  _YP(_T5(0, -1, 1, 2, 2), _T4(-3, 0, 0, 0)),
  _YP(_T5(2, -1, -1, 2, 2), _T4(-3, 0, 0, 0)),
  _YP(_T5(0, 0, 3, 2, 2), _T4(-3, 0, 0, 0)),
  _YP(_T5(2, -1, 0, 2, 2), _T4(-3, 0, 0, 0)),
];

double _radToDeg(double radians) {
  return (180.0 / _pi) * radians;
}

double _degToRad(double degrees) {
  return (_pi / 180.0) * degrees;
}

double _integer(double value) {
  return value.toInt().toDouble();
}

double _limitDegrees(double degrees) {
  degrees /= 360.0;
  var limited = 360.0 * (degrees - degrees.floor());

  if (limited < 0) {
    limited += 360.0;
  }

  return limited;
}

double _limitDegrees180pm(double degrees) {
  degrees /= 360.0;
  var limited = 360.0 * (degrees - degrees.floor());
  if (limited < -180.0) {
    limited += 360.0;
  } else if (limited > 180.0) {
    limited -= 360.0;
  }

  return limited;
}

double _limitDegrees180(double degrees) {
  degrees /= 180.0;
  var limited = 180.0 * (degrees - degrees.floor());
  if (limited < 0) limited += 180.0;

  return limited;
}

double _limitZeroToOne(double value) {
  var limited = value - value.floor();
  if (limited < 0) limited += 1.0;

  return limited;
}

double _limitMinutes(double minutes) {
  double limited = minutes;

  if (limited < -20.0) {
    limited += 1440.0;
  } else if (limited > 20.0) {
    limited -= 1440.0;
  }

  return limited;
}

double _dayFracToLocalHour(double dayfrac, double timezone) {
  return 24.0 * _limitZeroToOne(dayfrac + timezone / 24.0);
}

double _thirdOrderPolynomial(double a, double b, double c, double d, double x) {
  return ((a * x + b) * x + c) * x + d;
}

double _julianDay(
  int year,
  int month,
  int day,
  int hour,
  int minute,
  double second,
  double timezone,
) {
  var dayDecimal =
      day + (hour - timezone + (minute + (second) / 60.0) / 60.0) / 24.0;

  if (month < 3) {
    month += 12;
    year--;
  }

  var julianDay = _integer(365.25 * (year + 4716.0)) +
      _integer(30.6001 * (month + 1)) +
      dayDecimal -
      1524.5;

  if (julianDay > 2299160.0) {
    double a = _integer(year / 100.0);
    julianDay += (2 - a + _integer(a / 4.0));
  }

  return julianDay;
}

double _julianCentury(double jd) {
  return (jd - 2451545.0) / 36525.0;
}

double _julianEphemerisDay(double jd, double deltaT) {
  return jd + deltaT / 86400.0;
}

double _julianEphemerisCentury(double jde) {
  return (jde - 2451545.0) / 36525.0;
}

double _julianEphemerisMillennium(double jce) {
  return (jce / 10.0);
}

double _earthPeriodicTermSummation(List<_T3<double>> terms, double jme) {
  double sum = 0;

  for (var i = 0; i < terms.length; i++) {
    sum += terms[i].a * cos(terms[i].b + terms[i].c * jme);
  }

  return sum;
}

double _earthValues(List<double> termSum, double jme) {
  double sum = 0;

  for (var i = 0; i < termSum.length; i++) {
    sum += termSum[i] * pow(jme, i);
  }
  sum /= 1.0e8;

  return sum;
}

double _earthHeliocentricLongitude(double jme) {
  final sum = List<double>.filled(_l.length, 0);

  for (int i = 0; i < _l.length; i++) {
    sum[i] = _earthPeriodicTermSummation(_l[i], jme);
  }

  return _limitDegrees(_radToDeg(_earthValues(sum, jme)));
}

double _earthHeliocentricLatitude(double jme) {
  final sum = List<double>.filled(_b.length, 0);

  for (int i = 0; i < sum.length; i++) {
    sum[i] = _earthPeriodicTermSummation(_b[i], jme);
  }

  return _radToDeg(_earthValues(sum, jme));
}

double _earthRadiusVector(double jme) {
  final sum = List<double>.filled(_r.length, 0);

  for (int i = 0; i < _r.length; i++) {
    sum[i] = _earthPeriodicTermSummation(_r[i], jme);
  }

  return _earthValues(sum, jme);
}

double _geocentricLongitude(double l) {
  double theta = l + 180.0;

  if (theta >= 360.0) theta -= 360.0;

  return theta;
}

double _geocentricLatitude(double b) {
  return -b;
}

double _meanElongationMoonSun(double jce) {
  return _thirdOrderPolynomial(
      1.0 / 189474.0, -0.0019142, 445267.11148, 297.85036, jce);
}

double _meanAnomalySun(double jce) {
  return _thirdOrderPolynomial(
      -1.0 / 300000.0, -0.0001603, 35999.05034, 357.52772, jce);
}

double _meanAnomalyMoon(double jce) {
  return _thirdOrderPolynomial(
      1.0 / 56250.0, 0.0086972, 477198.867398, 134.96298, jce);
}

double _argumentLatitudeMoon(double jce) {
  return _thirdOrderPolynomial(
      1.0 / 327270.0, -0.0036825, 483202.017538, 93.27191, jce);
}

double _ascendingLongitudeMoon(double jce) {
  return _thirdOrderPolynomial(
    1.0 / 450000.0,
    0.0020708,
    -1934.136261,
    125.04452,
    jce,
  );
}

double _xyTermSummation(_T5<int> t, _T5<double> x) {
  final sum = x.a * t.a + x.b * t.b + x.c * t.c + x.d * t.d + x.e * t.e;
  return sum;
}

class _Nutation {
  const _Nutation(this.longitude, this.obliquity);
  final double longitude;
  final double obliquity;
}

_Nutation _nutationLongitudeAndObliquity(double jce, _T5<double> x) {
  double sumPsi = 0;
  double sumEpsilon = 0;

  for (var i = 0; i < _ype.length; i++) {
    final ype = _ype[i];
    final xyTermSum = _degToRad(_xyTermSummation(ype.y, x));
    sumPsi += (ype.pe.a + jce * ype.pe.b) * sin(xyTermSum);
    sumEpsilon += (ype.pe.c + jce * ype.pe.d) * cos(xyTermSum);
  }

  final delPsi = sumPsi / 36000000.0;
  final delEpsilon = sumEpsilon / 36000000.0;

  return _Nutation(delPsi, delEpsilon);
}

double _eclipticMeanObliquity(double jme) {
  double u = jme / 10.0;

  return 84381.448 +
      u *
          (-4680.93 +
              u *
                  (-1.55 +
                      u *
                          (1999.25 +
                              u *
                                  (-51.38 +
                                      u *
                                          (-249.67 +
                                              u *
                                                  (-39.05 +
                                                      u *
                                                          (7.12 +
                                                              u *
                                                                  (27.87 +
                                                                      u *
                                                                          (5.79 +
                                                                              u * 2.45)))))))));
}

double _eclipticTrueObliquity(double deltaEpsilon, double epsilon0) {
  return deltaEpsilon + epsilon0 / 3600.0;
}

double _aberrationCorrection(double r) {
  return -20.4898 / (3600.0 * r);
}

double _apparentSunLongitude(double theta, double deltaPsi, double deltaTau) {
  return theta + deltaPsi + deltaTau;
}

double _greenwichMeanSiderealTime(double jd, double jc) {
  return _limitDegrees(280.46061837 +
      360.98564736629 * (jd - 2451545.0) +
      jc * jc * (0.000387933 - jc / 38710000.0));
}

double _greenwichSiderealTime(double nu0, double deltaPsi, double epsilon) {
  return nu0 + deltaPsi * cos(_degToRad(epsilon));
}

double _geocentricRightAscension(double lamda, double epsilon, double beta) {
  double lamdaRad = _degToRad(lamda);
  double epsilonRad = _degToRad(epsilon);

  return _limitDegrees(_radToDeg(atan2(
      sin(lamdaRad) * cos(epsilonRad) - tan(_degToRad(beta)) * sin(epsilonRad),
      cos(lamdaRad))));
}

double _geocentricDeclination(double beta, double epsilon, double lamda) {
  double betaRad = _degToRad(beta);
  double epsilonRad = _degToRad(epsilon);

  return _radToDeg(asin(
    sin(betaRad) * cos(epsilonRad) +
        cos(betaRad) * sin(epsilonRad) * sin(_degToRad(lamda)),
  ));
}

double _observerHourAngle(double nu, double longitude, double alphaDeg) {
  return _limitDegrees(nu + longitude - alphaDeg);
}

double _sunEquatorialHorizontalParallax(double r) {
  return 8.794 / (3600.0 * r);
}

class _Delta {
  const _Delta(this.deltaAlpha, this.deltaPrime);

  /// Sun Right Ascension Parallax \[degrees\].
  final double deltaAlpha;
  final double deltaPrime;
}

_Delta _rightAscensionParallaxAndTopocentricDec(
  double latitude,
  double altitude,
  double xi,
  double h,
  double delta,
) {
  final latRad = _degToRad(latitude);
  final xiRad = _degToRad(xi);
  final hRad = _degToRad(h);
  final deltaRad = _degToRad(delta);
  final u = atan(0.99664719 * tan(latRad));
  final y = 0.99664719 * sin(u) + altitude * sin(latRad) / 6378140.0;
  final x = cos(u) + altitude * cos(latRad) / 6378140.0;

  var deltaAlphaRad = atan2(
      -x * sin(xiRad) * sin(hRad), cos(deltaRad) - x * sin(xiRad) * cos(hRad));

  final deltaPrime = _radToDeg(atan2(
      (sin(deltaRad) - y * sin(xiRad)) * cos(deltaAlphaRad),
      cos(deltaRad) - x * sin(xiRad) * cos(hRad)));

  final deltaAlpha = _radToDeg(deltaAlphaRad);

  return _Delta(deltaAlpha, deltaPrime);
}

double _topocentricRightAscension(double alphaDeg, double deltaAlpha) {
  return alphaDeg + deltaAlpha;
}

double _topocentricLocalHourAngle(double h, double deltaAlpha) {
  return h - deltaAlpha;
}

double _topocentricElevationAngle(
    double latitude, double deltaPrime, double hPrime) {
  double latRad = _degToRad(latitude);
  double deltaPrimeRad = _degToRad(deltaPrime);

  return _radToDeg(
    asin(sin(latRad) * sin(deltaPrimeRad) +
        cos(latRad) * cos(deltaPrimeRad) * cos(_degToRad(hPrime))),
  );
}

double _atmosphericRefractionCorrection(
    double pressure, double temperature, double atmosRefract, double e0) {
  double delE = 0;

  if (e0 >= -1 * (_sunRadius + atmosRefract)) {
    delE = (pressure / 1010.0) *
        (283.0 / (273.0 + temperature)) *
        1.02 /
        (60.0 * tan(_degToRad(e0 + 10.3 / (e0 + 5.11))));
  }

  return delE;
}

double _topocentricElevationAngleCorrected(double e0, double deltaE) {
  return e0 + deltaE;
}

double _topocentricZenithAngle(double e) {
  return 90.0 - e;
}

double _topocentricAzimuthAngleAstro(
    double hPrime, double latitude, double deltaPrime) {
  double hPrimeRad = _degToRad(hPrime);
  double latRad = _degToRad(latitude);

  return _limitDegrees(_radToDeg(atan2(
      sin(hPrimeRad),
      cos(hPrimeRad) * sin(latRad) -
          tan(_degToRad(deltaPrime)) * cos(latRad))));
}

double _topocentricAzimuthAngle(double azimuthAstro) {
  return _limitDegrees(azimuthAstro + 180.0);
}

double _surfaceIncidenceAngle(
    double zenith, double azimuthAstro, double azmRotation, double slope) {
  double zenithRad = _degToRad(zenith);
  double slopeRad = _degToRad(slope);

  return _radToDeg(acos(cos(zenithRad) * cos(slopeRad) +
      sin(slopeRad) *
          sin(zenithRad) *
          cos(_degToRad(azimuthAstro - azmRotation))));
}

double _sunMeanLongitude(double jme) {
  return _limitDegrees(280.4664567 +
      jme *
          (360007.6982779 +
              jme *
                  (0.03032028 +
                      jme *
                          (1 / 49931.0 +
                              jme * (-1 / 15300.0 + jme * (-1 / 2000000.0))))));
}

double _equationOfTime(double m, double alpha, double delPsi, double epsilon) {
  return _limitMinutes(
      4.0 * (m - 0.0057183 - alpha + delPsi * cos(_degToRad(epsilon))));
}

double _approxSunTransitTime(double alphaZero, double longitude, double nu) {
  return (alphaZero - longitude - nu) / 360.0;
}

double _sunHourAngleAtRiseSet(
    double latitude, double deltaZero, double h0Prime) {
  double h0 = -99999;
  double latitudeRad = _degToRad(latitude);
  double deltaZeroRad = _degToRad(deltaZero);
  double argument =
      (sin(_degToRad(h0Prime)) - sin(latitudeRad) * sin(deltaZeroRad)) /
          (cos(latitudeRad) * cos(deltaZeroRad));

  if (argument.abs() <= 1) h0 = _limitDegrees180(_radToDeg(acos(argument)));

  return h0;
}

class _RiseTransitSet {
  const _RiseTransitSet(this.rise, this.transit, this.set);
  final double rise;
  final double set;
  final double transit;
}

_RiseTransitSet _approxSunRiseAndSet(double t, double h0) {
  double h0Dfrac = h0 / 360.0;

  final rise = _limitZeroToOne(t - h0Dfrac);
  final set = _limitZeroToOne(t + h0Dfrac);
  final transit = _limitZeroToOne(t);

  return _RiseTransitSet(rise, transit, set);
}

double _rtsAlphaDeltaPrime(List<double> ad, double n) {
  double a = ad[_jdZero] - ad[_jdMinus];
  double b = ad[_jdPlus] - ad[_jdZero];

  if ((a).abs() >= 2.0) a = _limitZeroToOne(a);
  if ((b).abs() >= 2.0) b = _limitZeroToOne(b);

  return ad[_jdZero] + n * (a + b + (b - a) * n) / 2.0;
}

double _rtsSunAltitude(double latitude, double deltaPrime, double hPrime) {
  double latitudeRad = _degToRad(latitude);
  double deltaPrimeRad = _degToRad(deltaPrime);

  return _radToDeg(asin(sin(latitudeRad) * sin(deltaPrimeRad) +
      cos(latitudeRad) * cos(deltaPrimeRad) * cos(_degToRad(hPrime))));
}

double _sunRiseAndSet(
  double m,
  double h,
  double deltaPrime,
  double latitude,
  double hPrime,
  double h0Prime,
) {
  return m +
      (h - h0Prime) /
          (360.0 *
              cos(_degToRad(deltaPrime)) *
              cos(_degToRad(latitude)) *
              sin(_degToRad(hPrime)));
}

void _geocentricSunRightAscensionAndDeclination(_SPAData spa) {
  spa.Jc = _julianCentury(spa.Jd);

  spa.Jde = _julianEphemerisDay(spa.Jd, spa.deltaT);
  spa.Jce = _julianEphemerisCentury(spa.Jde);
  spa.Jme = _julianEphemerisMillennium(spa.Jce);

  spa.L = _earthHeliocentricLongitude(spa.Jme);
  spa.B = _earthHeliocentricLatitude(spa.Jme);
  spa.R = _earthRadiusVector(spa.Jme);

  spa.Theta = _geocentricLongitude(spa.L);
  spa.Beta = _geocentricLatitude(spa.B);

  final x0 = _meanElongationMoonSun(spa.Jce);
  final x1 = _meanAnomalySun(spa.Jce);
  final x2 = _meanAnomalyMoon(spa.Jce);
  final x3 = _argumentLatitudeMoon(spa.Jce);
  final x4 = _ascendingLongitudeMoon(spa.Jce);

  final x = _T5<double>(x0, x1, x2, x3, x4);

  spa.X0 = _meanElongationMoonSun(spa.Jce);
  spa.X1 = _meanAnomalySun(spa.Jce);
  spa.X2 = _meanAnomalyMoon(spa.Jce);
  spa.X3 = _argumentLatitudeMoon(spa.Jce);
  spa.X4 = _ascendingLongitudeMoon(spa.Jce);

  spa.X = x;

  final nutation = _nutationLongitudeAndObliquity(spa.Jce, x);
  spa.nutationLongitude = nutation.longitude;
  spa.nutationObliquity = nutation.obliquity;

  spa.Epsilon0 = _eclipticMeanObliquity(spa.Jme);
  spa.Epsilon = _eclipticTrueObliquity(spa.nutationObliquity, spa.Epsilon0);

  spa.DelTau = _aberrationCorrection(spa.R);
  spa.Lamda =
      _apparentSunLongitude(spa.Theta, spa.nutationLongitude, spa.DelTau);
  spa.Nu0 = _greenwichMeanSiderealTime(spa.Jd, spa.Jc);
  spa.Nu = _greenwichSiderealTime(spa.Nu0, spa.nutationLongitude, spa.Epsilon);

  spa.Alpha = _geocentricRightAscension(spa.Lamda, spa.Epsilon, spa.Beta);
  spa.Delta = _geocentricDeclination(spa.Beta, spa.Epsilon, spa.Lamda);
}

void _calculateEOTAndSunRiseTransitSet(
  _Date date,
  _SPAData spa,
  LatLng latLng,
  double timezone,
) {
  final alpha = List<double>.filled(_jdCount, 0);
  final delta = List<double>.filled(_jdCount, 0);
  final h0Prime = -1 * (_sunRadius + spa.atmosphericRefraction);

  final sunRts = spa.clone();

  final m = _sunMeanLongitude(spa.Jme);
  spa.Eot = _equationOfTime(m, spa.Alpha, spa.nutationLongitude, spa.Epsilon);

  sunRts.Jd = _julianDay(date.year, date.month, date.day, 0, 0, 0, 0);

  _geocentricSunRightAscensionAndDeclination(sunRts);
  var nu = sunRts.Nu;

  sunRts.deltaT = 0;
  sunRts.Jd--;

  for (var i = 0; i < _jdCount; i++) {
    _geocentricSunRightAscensionAndDeclination(sunRts);
    alpha[i] = sunRts.Alpha;
    delta[i] = sunRts.Delta;
    sunRts.Jd++;
  }

  final transit = _approxSunTransitTime(alpha[_jdZero], latLng.longitude, nu);
  var h0 = _sunHourAngleAtRiseSet(latLng.latitude, delta[_jdZero], h0Prime);

  if (h0 >= 0) {
    final mRts = _approxSunRiseAndSet(transit, h0);
    final nuRise = nu + 360.985647 * mRts.rise;
    final nuSet = nu + 360.985647 * mRts.set;
    final nuTransit = nu + 360.985647 * mRts.transit;

    final nRise = mRts.rise + spa.deltaT / 86400.0;
    final nSet = mRts.set + spa.deltaT / 86400.0;
    final nTransit = mRts.transit + spa.deltaT / 86400.0;

    final alphaPrimeRise = _rtsAlphaDeltaPrime(alpha, nRise);
    final alphaPrimeSet = _rtsAlphaDeltaPrime(alpha, nSet);
    final alphaPrimeTransit = _rtsAlphaDeltaPrime(alpha, nTransit);

    final deltaPrimeRise = _rtsAlphaDeltaPrime(delta, nRise);
    final deltaPrimeSet = _rtsAlphaDeltaPrime(delta, nSet);
    final deltaPrimeTransit = _rtsAlphaDeltaPrime(delta, nTransit);

    final hPrimeRise =
        _limitDegrees180pm(nuRise + latLng.longitude - alphaPrimeRise);
    final hPrimeSet =
        _limitDegrees180pm(nuSet + latLng.longitude - alphaPrimeSet);
    final hPrimeTransit =
        _limitDegrees180pm(nuTransit + latLng.longitude - alphaPrimeTransit);

    final hRtsRise =
        _rtsSunAltitude(latLng.latitude, deltaPrimeRise, hPrimeRise);
    final hRtsSet = _rtsSunAltitude(latLng.latitude, deltaPrimeSet, hPrimeSet);
    final hRtsTransit =
        _rtsSunAltitude(latLng.latitude, deltaPrimeTransit, hPrimeTransit);

    spa.Srha = hPrimeRise;
    spa.Ssha = hPrimeSet;
    spa.Sta = hRtsTransit;

    spa.Suntransit =
        _dayFracToLocalHour(mRts.transit - hPrimeTransit / 360.0, timezone);

    spa.Sunrise = _dayFracToLocalHour(
        _sunRiseAndSet(
          mRts.rise,
          hRtsRise,
          deltaPrimeRise,
          latLng.latitude,
          hPrimeRise,
          h0Prime,
        ),
        timezone);

    spa.Sunset = _dayFracToLocalHour(
      _sunRiseAndSet(
        mRts.set,
        hRtsSet,
        deltaPrimeSet,
        latLng.latitude,
        hPrimeSet,
        h0Prime,
      ),
      timezone,
    );
  } else {
    spa.Srha =
        spa.Ssha = spa.Sta = spa.Suntransit = spa.Sunrise = spa.Sunset = -99999;
  }
}

/// Calculates the look angles for the specified [observer].
LookAngle getSunLookAngle(DateTime utc, LatLng observer, double altitude) {
  final timezone = observer.longitude * 15; // lng / 360.0 * 24.0;

  final hour = timezone;
  final min = 60.0 * (hour - hour.toInt());
  final sec = 60.0 * (min - min.toInt());
  final mil = 1000.0 * (sec - sec.toInt());
  final mic = 1000.0 * (mil - mil.toInt());

  utc = utc.toUtc();
  utc = utc.add(
    Duration(
      hours: hour.toInt(),
      minutes: min.toInt(),
      seconds: sec.toInt(),
      milliseconds: mil.toInt(),
      microseconds: mic.toInt(),
    ),
  );

  final date = _Date(utc.year, utc.month, utc.day, utc.hour, utc.minute,
      utc.second.toDouble());

  final spa = _SPAData();

  _getSunLookAngle(date, spa, observer, timezone, altitude);

  return LookAngle(
    azimuth: spa.Azimuth,
    elevation: spa.elevation,
    range: spa.R * 149597870.7,
  );
}

/// [altitude] Observer elevation \[meters\]. valid range: -6500000 or higher meters,    error code: 11
int _getSunLookAngle(
    _Date date, _SPAData spa, LatLng latLng, double timezone, double altitude) {
  var result = _validateInputs(date, spa, latLng);

  if (result != 0) {
    return result;
  }

  spa.Jd = _julianDay(
    date.year,
    date.month,
    date.day,
    date.Hour,
    date.Minute,
    date.Second,
    timezone,
  );

  _geocentricSunRightAscensionAndDeclination(spa);

  spa.observerHourAngle = _observerHourAngle(
    spa.Nu,
    latLng.longitude,
    spa.Alpha,
  );

  spa.Xi = _sunEquatorialHorizontalParallax(spa.R);

  final delta = _rightAscensionParallaxAndTopocentricDec(
    latLng.latitude,
    altitude,
    spa.Xi,
    spa.observerHourAngle,
    spa.Delta,
  );

  spa.DeltaPrime = delta.deltaPrime;

  spa.AlphaPrime = _topocentricRightAscension(spa.Alpha, delta.deltaAlpha);
  spa.HPrime =
      _topocentricLocalHourAngle(spa.observerHourAngle, delta.deltaAlpha);

  spa.elevation =
      _topocentricElevationAngle(latLng.latitude, spa.DeltaPrime, spa.HPrime);
  spa.DelE = _atmosphericRefractionCorrection(
      spa.pressure, spa.temperature, spa.atmosphericRefraction, spa.elevation);
  spa.E = _topocentricElevationAngleCorrected(spa.elevation, spa.DelE);

  spa.zenith = _topocentricZenithAngle(spa.E);
  spa.AzimuthAstro = _topocentricAzimuthAngleAstro(
      spa.HPrime, latLng.latitude, spa.DeltaPrime);
  spa.Azimuth = _topocentricAzimuthAngle(spa.AzimuthAstro);

  if ((spa.function == _CalculationMode.incidence) ||
      (spa.function == _CalculationMode.all)) {
    spa.incidence = _surfaceIncidenceAngle(
        spa.zenith, spa.AzimuthAstro, spa.azimuthRotation, spa.slope);
  }

  if ((spa.function == _CalculationMode.rts) ||
      (spa.function == _CalculationMode.all)) {
    _calculateEOTAndSunRiseTransitSet(date, spa, latLng, timezone);
  }

  return 0;
}

class _SPAData {
  //----------------------INPUT VALUES------------------------

  /// Difference between earth rotation time and terrestrial time
  /// It is derived from observation only and is reported in this
  /// bulletin: http://maia.usno.navy.mil/ser7/ser7.dat,
  /// where delta_t = 32.184 + (TAI-UTC) - DUT1
  /// valid range: -8000 to 8000 seconds, error code: 7
  double deltaT = 0;

  double pressure = 0; // Annual average local pressure [millibars]
  // valid range:    0 to 5000 millibars,       error code: 12

  double temperature = 0; // Annual average local temperature [degrees Celsius]
  // valid range: -273 to 6000 degrees Celsius, error code; 13

  // Surface slope (measured from the horizontal plane)
  // valid range: -360 to 360 degrees, error code: 14
  double slope = 0;

  /// Surface azimuth rotation (measured from south to projection of
  /// surface normal on horizontal plane, negative east)
  /// valid range: -360 to 360 degrees, error code: 15
  double azimuthRotation = 0;

  /// Atmospheric refraction at sunrise and sunset (0.5667 deg is typical)
  /// valid range: -5   to   5 degrees, error code: 16
  double atmosphericRefraction = 0;

  /// Switch to choose functions for desired output (from enumeration)
  _CalculationMode function = _CalculationMode.all;

  //-----------------Intermediate OUTPUT VALUES--------------------

  double Jd = 0; //Julian day
  double Jc = 0; //Julian century

  double Jde = 0; //Julian ephemeris day
  double Jce = 0; //Julian ephemeris century
  double Jme = 0; //Julian ephemeris millennium

  /// Earth Heliocentric Longitude \[degrees\].
  double L = 0;

  /// Earth heliocentric Latitude \[degrees\].
  double B = 0;

  /// Earth radius vector [Astronomical Units, AU].
  double R = 0;

  double Theta = 0; //geocentric longitude \[degrees\].
  double Beta = 0; //geocentric latitude \[degrees\].

  /// Mean elongation (moon-sun) \[degrees\].
  double X0 = 0;
  double X1 = 0; //mean anomaly (sun) \[degrees\].
  double X2 = 0; //mean anomaly (moon) \[degrees\].
  double X3 = 0; //argument latitude (moon) \[degrees\].
  double X4 = 0; //ascending longitude (moon) \[degrees\].

  _T5<double> X = _T5<double>(0, 0, 0, 0, 0);

  /// Nutation Longitude \[degrees\].
  double nutationLongitude = 0;

  /// Nutation Obliquity \[degrees\].
  double nutationObliquity = 0;

  double Epsilon0 = 0; //ecliptic mean obliquity [arc seconds]
  double Epsilon = 0; //ecliptic true obliquity  \[degrees\].

  /// Aberration correction \[degrees\].
  double DelTau = 0;

  /// Apparent sun longitude \[degrees\].
  double Lamda = 0;

  /// Greenwich mean sidereal time \[degrees\].
  double Nu0 = 0;

  /// Greenwich sidereal time \[degrees\].
  double Nu = 0;

  /// Geocentric Sun Right Ascension \[degrees\].
  double Alpha = 0;

  /// Geocentric Sun Declination \[degrees\].
  double Delta = 0;

  /// Observer hour angle \[degrees\].
  double observerHourAngle = 0;

  /// Sun Equatorial Horizontal Parallax \[degrees\].
  double Xi = 0;

  double DeltaPrime = 0; //topocentric sun declination \[degrees\].
  double AlphaPrime = 0; //topocentric sun right ascension \[degrees\].
  double HPrime = 0; //topocentric local hour angle \[degrees\].

  double elevation = 0; //topocentric elevation angle (uncorrected) \[degrees\].
  double DelE = 0; //atmospheric refraction correction \[degrees\].
  double E = 0; //topocentric elevation angle (corrected) \[degrees\].

  double Eot = 0; //equation of time [minutes]
  double Srha = 0; //sunrise hour angle \[degrees\].
  /// Sunset hour angle \[degrees\].
  double Ssha = 0;

  /// Sun transit altitude \[degrees\].
  double Sta = 0;

  //---------------------Final OUTPUT VALUES------------------------

  /// Topocentric Zenith Angle \[degrees\]
  double zenith = 0;

  /// Topocentric azimuth angle (westward from south) [for astronomers]
  double AzimuthAstro = 0;

  /// Topocentric azimuth angle (eastward from north) [for navigators and solar radiation]
  double Azimuth = 0;

  /// Surface incidence angle \[degrees\]
  double incidence = 0;

  /// Local sun transit time (or solar noon) [fractional hour]
  double Suntransit = 0;

  double Sunrise = 0; //local sunrise time (+/- 30 seconds) [fractional hour]
  double Sunset = 0; //local sunset time (+/- 30 seconds) [fractional hour]

  _SPAData clone() {
    final r = _SPAData();

    r.deltaT = deltaT;

    //r.Elevation = Elevation;

    r.pressure = pressure;

    r.temperature = temperature;

    r.slope = slope;

    r.azimuthRotation = azimuthRotation;

    r.atmosphericRefraction = atmosphericRefraction;

    r.function = function;

    r.Jd = Jd;
    r.Jc = Jc;

    r.Jde = Jde;
    r.Jce = Jce;
    r.Jme = Jme;

    r.L = L;
    r.B = B;
    r.R = R;

    r.Theta = Theta;
    r.Beta = Beta;

    r.X0 = X0;
    r.X1 = X1;
    r.X2 = X2;
    r.X3 = X3;
    r.X4 = X4;

    r.nutationLongitude = nutationLongitude;
    r.nutationObliquity = nutationObliquity;
    r.Epsilon0 = Epsilon0;
    r.Epsilon = Epsilon;

    r.DelTau = DelTau;
    r.Lamda = Lamda;
    r.Nu0 = Nu0;
    r.Nu = Nu;

    r.Alpha = Alpha;
    r.Delta = Delta;

    r.observerHourAngle = observerHourAngle;
    r.Xi = Xi;

    r.DeltaPrime = DeltaPrime;
    r.AlphaPrime = AlphaPrime;
    r.HPrime = HPrime;

    r.elevation = elevation;
    r.DelE = DelE;
    r.E = E;

    r.Eot = Eot;
    r.Srha = Srha;
    r.Ssha = Ssha;
    r.Sta = Sta;

    r.zenith = zenith;
    r.AzimuthAstro = AzimuthAstro;

    r.Azimuth = Azimuth;

    r.incidence = incidence;

    r.Suntransit = Suntransit;
    r.Sunrise = Sunrise;
    r.Sunset = Sunset;

    return r;
  }
}

class _Date {
  const _Date(
    this.year,
    this.month,
    this.day,
    this.Hour,
    this.Minute,
    this.Second,
  );

  /// 4-digit year, valid range: -2000 to 6000, error code: 1.
  final int year;

  /// 2-digit month, valid range: 1 to  12,  error code: 2.
  final int month;

  /// 2-digit day, valid range: 1 to  31,  error code: 3
  final int day;

  /// Observer local hour, valid range: 0 to  24,  error code: 4
  final int Hour;

  /// Observer local minute, valid range: 0 to  59,  error code: 5
  final int Minute;

  /// Observer local second, valid range: 0 to <60,  error code: 6
  final double Second;
}
