import 'package:latlng/latlng.dart';
import 'package:test/test.dart';
import 'package:orbit/orbit.dart';

const tles = r'''
0 VANGUARD 1
1     5U 58002B   23365.57064687  .00000316  00000-0  43126-3 0  9991
2     5  34.2390 206.9464 1841775  48.1863 326.2040 10.85148002345707
0 VANGUARD 2
1    11U 59001A   23365.80807678  .00001240  00000-0  65797-3 0  9994
2    11  32.8670 238.7632 1458801 354.0171   4.4583 11.87486202770220
0 VANGUARD R/B
1    12U 59001B   23365.78901814  .00000312  00000-0  18880-3 0  9999
2    12  32.8959 145.6874 1658950  35.9316 334.2191 11.45913264670694
0 VANGUARD R/B
1    16U 58002A   23365.18016934  .00000671  00000-0  91862-3 0  9996
2    16  34.2799  24.5062 2021849 284.8182  53.8103 10.49020915594448
0 VANGUARD 3
1    20U 59007A   23365.82972211  .00000936  00000-0  36459-3 0  9992
2    20  33.3538 252.5367 1656794 290.4425  52.6310 11.58032405380279
0 EXPLORER 7
1    22U 59009A   23364.86772884  .00009996  00000-0  62956-3 0  9999
2    22  50.2790 140.4162 0119851 171.6568 188.6413 15.03917591418854
''';

const oscar = r'''OSCAR 7 (AO-7)
1 07530U 74089B   13001.41953037  .00000001  00000-0  27778-3 0  5711
2 07530 101.4185 357.0759 0011588 254.1624 275.4154 12.53593399744888''';

const sl31155 = r'''STARLINK-31155          
1 58728U 24005A   24036.91667824  .00091608  00000+0  36484-2 0  9999
2 58728  43.0002  49.7284 0001969 257.5625   0.2160 15.24223380  5747''';
void main() {
  test('Look Angle', () {
    final lookAngle = LookAngle(
      azimuth: Angle.degree(20),
      elevation: Angle.degree(30),
      range: 40,
    );

    expect(lookAngle.azimuth.degrees, 20);
    expect(lookAngle.elevation.degrees, 30);
    expect(lookAngle.range, 40);
  });

  test('TLE Parse', () {
    final t = TwoLineElement.parseMany(tles);

    expect(t.length, 6);
    expect(t[4].name, 'VANGUARD 3');
  });

  test('SGP4', () {
    final t = TwoLineElement.parse(sl31155);

    final sgp = SGP4(t.keplerianElements, wgs84);
    final observer = LatLngAlt(
      Angle.degree(35.764472),
      Angle.degree(50.786492),
      1185.9,
    );
    final g = DateTime.utc(2024, 2, 6, 21, 0, 0);
    final rv = sgp.getPositionByDateTime(g);
    final ecf = rv.r.toEcfByDateTime(g);
    final tp = wgs84.topocentric(observer, ecf);
    final la = tp.toLookAngle();

    print(la);

    expect(g.year, 2024);
    //expect(la.azimuth.radians, 5.478036739113396);
    //expect(rv.r.y, 5986.06723066486);
    //expect(rv.r.z, 5041.366013551259);
  });
}
