/// Calculates the Julian date.
double julian(int year, double doy) {
  // Now calculate Julian date
  // Ref: "Astronomical Formulae for Calculators", Jean Meeus, pages 23-25

  year--;

  // Centuries are not leap years unless they divide by 400
  int A = year ~/ 100;
  int B = 2 - A + (A ~/ 4);

  double jan01 =
      (365.25 * year).toInt() + (30.6001 * 14).toInt() + 1720994.5 + B;

  return jan01 + doy;
}

/// Converts from Julian to [DateTime].
DateTime toTime(double j) {
  final double d2 = j + 0.5;
  final int Z = d2.toInt();
  final int alpha = (Z - 1867216.25) ~/ 36524.25;
  final int A = Z + 1 + alpha - (alpha ~/ 4);
  final int B = A + 1524;
  final int C = ((B - 122.1) ~/ 365.25);
  final int D = (365.25 * C).toInt();
  final int E = ((B - D) ~/ 30.6001);

  // For reference: the fractional day of the month can be
  // calculated as follows:
  //
  // double day = B - D - (int)(30.6001 * E) + F;

  int month = (E <= 13) ? (E - 1) : (E - 13);
  int year = (month >= 3) ? (C - 4716) : (C - 4715);

  final jdJan01 = julian(year, 1.0);
  double doy = j - jdJan01; // zero-relative

  final dtJan01 = DateTime.utc(year, 1, 1, 0, 0, 0);

  return dtJan01.add(Duration(seconds: (doy * 24.0 * 3600).toInt()));
}
