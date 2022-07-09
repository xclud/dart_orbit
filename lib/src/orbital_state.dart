import 'package:orbit/orbit.dart';

class OrbitalState {
  const OrbitalState(this.r, this.v);

  final EarthCenteredInertial r;
  final EarthCenteredInertial v;
}
