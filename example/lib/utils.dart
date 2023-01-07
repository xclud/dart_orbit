double lerp(double a, double b, double t) {
  return a * (1.0 - t) + b * t;
}

double clamp(double x, double min, double max) {
  if (x < min) x = min;
  if (x > max) x = max;

  return x;
}
