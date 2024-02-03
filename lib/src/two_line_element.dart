part of '../orbit.dart';

/// Represents a TLE record.
class TwoLineElement {
  /// Main constructor.
  const TwoLineElement(this.name, this.keplerianElements);

  /// Parser constructor.
  factory TwoLineElement.parse(String contents) {
    final lines = contents.replaceAll('\r', '').split('\n');
    String name = '<NoName>';
    String line1 = '';
    String line2 = '';

    if (lines.length == 2) {
      line1 = lines[0];
      line2 = lines[1];
    } else if (lines.length == 3) {
      name = lines[0];
      line1 = lines[1];
      line2 = lines[2];
    } else {
      throw Exception('Invalid TLE file (found ${lines.length} lines)');
    }

    return TwoLineElement._parseLines(name, line1, line2);
  }

  factory TwoLineElement._parseLines(String name, String line1, String line2) {
    if (name.startsWith('0 ')) {
      name = name.substring(2);
    }

    final epochS = line1.substring(18, 14).trim();
    final eccentricityS = line2.substring(26, 7).trim();
    final meanMotionS = line2.substring(52, 11).trim();
    final inclinationS = line2.substring(8, 8).trim();
    final raanS = line2.substring(17, 8).trim();
    final meanAnomalyS = line2.substring(43, 8).trim();
    final argumentOfPeriapsisS = line2.substring(34, 8).trim();
    final dragS = line1.substring(53, 8);

    final epoch = double.parse(epochS);
    final eccentricity = double.parse('0.$eccentricityS');
    final meanMotion = double.parse(meanMotionS);
    final inclination = double.parse(inclinationS);
    final rightAscensionOfAscendingNode = double.parse(raanS);
    final meanAnomaly = double.parse(meanAnomalyS);
    final argumentOfPeriapsis = double.parse(argumentOfPeriapsisS);
    final drag = _expToDecimal(dragS);

    final ke = KeplerianElements(
      epoch: epoch,
      eccentricity: eccentricity,
      meanMotion: meanMotion,
      inclination: inclination,
      rightAscensionOfAscendingNode: rightAscensionOfAscendingNode,
      meanAnomaly: meanAnomaly,
      argumentOfPeriapsis: argumentOfPeriapsis,
      drag: drag,
    );

    final tle = TwoLineElement(name, ke);

    return tle;
  }

  /// Satellite name.
  final String name;

  /// Keplerian Elements.
  final KeplerianElements keplerianElements;

  /// Parse multiple TLE records.
  static List<TwoLineElement> parseMany(String contents) {
    final lines = contents.replaceAll('\r', '').split('\n');
    int curLineNum = 0;

    final tles = <TwoLineElement>[];

    while (curLineNum < lines.length) {
      final curLine = lines[curLineNum];

      if (curLine.startsWith('1 ')) {
        final nxtLine = lines[curLineNum + 1];
        final tle = TwoLineElement._parseLines('<No Name>', curLine, nxtLine);

        tles.add(tle);
        curLineNum += 2;
      } else {
        final line1 = lines[curLineNum + 1];
        final line2 = lines[curLineNum + 2];
        final tle = TwoLineElement._parseLines(curLine, line1, line2);

        tles.add(tle);
        curLineNum += 3;
      }
    }

    return tles;
  }
}

double _expToDecimal(String str) {
  final sign = str.substring(0, 1);
  final mantissa = str.substring(1, 5);
  final exponent = str.substring(6, 2).trim();

  var val = double.parse('${sign}0.${mantissa}e$exponent');

  return val;
}
