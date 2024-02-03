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

void main() {
  test('Look Angle', () {
    final lookAngle = LookAngle(
      azimuth: 20,
      elevation: 30,
      range: 40,
      rate: 50,
    );

    expect(lookAngle.azimuth, 20);
    expect(lookAngle.elevation, 30);
    expect(lookAngle.range, 40);
    expect(lookAngle.rate, 50);
  });

  test('TLE Parse', () {
    final t = TwoLineElement.parseMany(tles);

    expect(t.length, 6);
    expect(t[4].name, 'VANGUARD 3');
  });
}
