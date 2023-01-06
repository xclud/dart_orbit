part of orbit;

/// RV Pair for satellite state.
class OrbitalState {
  /// The constructor.
  const OrbitalState(this.r, this.v);

  /// r
  final EarthCenteredInertial r;

  /// v
  final EarthCenteredInertial v;
}
