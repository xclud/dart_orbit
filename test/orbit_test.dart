import 'package:test/test.dart';
import 'package:orbit/orbit.dart';

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
}
