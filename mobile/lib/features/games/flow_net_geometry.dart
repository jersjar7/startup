import 'dart:math' as math;

/// The true flow net under a single sheet pile driven part way into a
/// permeable layer that sits on impervious rock, worked out with the
/// conformal map rather than drawn by eye, so the lines really do cross at
/// right angles and the cells really are squares.
///
/// Lengths are in layer thicknesses: x runs from the pile (x = 0) towards
/// the downstream side, y runs DOWN from the ground surface (0) to the rock
/// (1). The upstream half is the mirror image.
///
/// The map, for the downstream half (by symmetry the line straight under
/// the toe is the equipotential halfway down the head):
///
///   u = a + ib in the rectangle 0 <= a <= K(m), 0 <= b <= K'(m)
///   s = sn^2(u | m),  w = 2ms - 1,  z = acosh(w) / pi
///
/// The edge a = K is the pile face, a = 0 the rock (both flow lines); the
/// edge b = 0 is the line under the toe, b = K' the downstream ground (both
/// equipotentials). Equal steps in a and b are equal shares of the flow and
/// equal drops of head, and a step of K/Nf across matching a step of
/// K'/(Nd/2) along is what makes the cells square. That fixes m, and m
/// fixes how deep the pile goes: cos(pi * depth) = 2m - 1.
class FlowNetGeometry {
  FlowNetGeometry._(this.channels, this.drops, this.m, this.pileDepth);

  /// The net with [channels] flow channels and [drops] equipotential drops
  /// (an even number: half on each side of the pile).
  factory FlowNetGeometry(int channels, int drops) {
    assert(channels >= 1 && drops >= 2 && drops.isEven);
    final ratio = drops / (2 * channels); // K'(m) / K(m)
    // K'/K falls as m rises, so a plain bisection finds it.
    var lo = 1e-12, hi = 1 - 1e-12;
    for (var i = 0; i < 200; i++) {
      final mid = (lo + hi) / 2;
      if (_ellipK(1 - mid) / _ellipK(mid) > ratio) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    final m = (lo + hi) / 2;
    final depth = math.acos(2 * m - 1) / math.pi;
    return FlowNetGeometry._(channels, drops, m, depth);
  }

  final int channels;
  final int drops;

  /// The parameter of the map.
  final double m;

  /// How far the pile goes into the layer, as a fraction of its thickness.
  final double pileDepth;

  double get _k => _ellipK(m);
  double get _kp => _ellipK(1 - m);

  /// Where the point (a, b) of the rectangle lands, as (x, y).
  (double, double) at(double a, double b) {
    // sn of a complex argument, from the real functions of each part.
    final (s, c, d) = _jacobi(a, m);
    final (s1, c1, d1) = _jacobi(b, 1 - m);
    final den = c1 * c1 + m * s * s * s1 * s1;
    final snRe = s * d1 / den;
    final snIm = c * d * s1 * c1 / den;
    // w = 2m sn^2 - 1
    final wRe = 2 * m * (snRe * snRe - snIm * snIm) - 1;
    final wIm = 2 * m * (2 * snRe * snIm);
    final (zRe, zIm) = _acosh(wRe, wIm);
    // Rounding leaves points on the pile face a hair either side of it;
    // this half of the net never goes past the pile.
    return (math.max(0, zRe / math.pi), zIm / math.pi);
  }

  /// The interior flow lines, each from the upstream ground, down, under
  /// the toe and up to the downstream ground: [channels] - 1 of them. The
  /// pile faces and the rock are the first and last flow lines and are
  /// drawn as the structure.
  List<List<(double, double)>> flowLines({int samples = 40}) {
    final lines = <List<(double, double)>>[];
    for (var i = 1; i < channels; i++) {
      final a = _k * i / channels;
      final half = <(double, double)>[];
      for (var n = 0; n <= samples; n++) {
        // Bunched towards both ends, where the line turns fastest.
        final t = (1 - math.cos(math.pi * n / samples)) / 2;
        half.add(at(a, _kp * t));
      }
      lines.add([for (final (x, y) in half.reversed) (-x, y), ...half.skip(1)]);
    }
    return lines;
  }

  /// The interior equipotentials, upstream to downstream: [drops] - 1 of
  /// them, each from the rock up to a face of the pile (the middle one
  /// from the rock up to the toe). The two ground surfaces are the first
  /// and last.
  List<List<(double, double)>> equipotentials({int samples = 32}) {
    final half = drops ~/ 2;
    List<(double, double)> line(int j) => [
      for (var n = 0; n <= samples; n++)
        at(_k * (1 - math.cos(math.pi * n / samples)) / 2, _kp * j / half),
    ];
    return [
      for (var j = half - 1; j >= 1; j--)
        [for (final (x, y) in line(j)) (-x, y)],
      line(0),
      for (var j = 1; j < half; j++) line(j),
    ];
  }

  /// Where flow line [i] (0 = the rock, [channels] = the pile) meets
  /// equipotential [j] (0 = under the toe, drops/2 = the ground), on the
  /// downstream side. For checking the net.
  (double, double) node(double i, double j) =>
      at(_k * i / channels, _kp * j / (drops ~/ 2));
}

/// The complete elliptic integral of the first kind, K(m), by the
/// arithmetic-geometric mean.
double _ellipK(double m) {
  var a = 1.0, b = math.sqrt(1 - m);
  for (var i = 0; i < 40 && (a - b).abs() > 1e-16 * a; i++) {
    final next = (a + b) / 2;
    b = math.sqrt(a * b);
    a = next;
  }
  return math.pi / (2 * a);
}

/// The Jacobi functions sn, cn, dn of a real argument, by the descending
/// arithmetic-geometric mean (Abramowitz and Stegun 16.4).
(double, double, double) _jacobi(double u, double m) {
  if (m < 1e-14) return (math.sin(u), math.cos(u), 1);
  final as = <double>[1];
  final cs = <double>[math.sqrt(m)];
  var b = math.sqrt(1 - m);
  var n = 0;
  while (cs[n].abs() > 1e-15 && n < 40) {
    final a = as[n];
    as.add((a + b) / 2);
    cs.add((a - b) / 2);
    b = math.sqrt(a * b);
    n++;
  }
  var phi = math.pow(2, n) * as[n] * u;
  for (var k = n; k >= 1; k--) {
    phi = (phi + math.asin(cs[k] / as[k] * math.sin(phi))) / 2;
  }
  final sn = math.sin(phi);
  final cn = math.cos(phi);
  return (sn, cn, math.sqrt(1 - m * sn * sn));
}

/// acosh of a complex number, principal branch: log(w + sqrt(w-1) sqrt(w+1)).
(double, double) _acosh(double re, double im) {
  final (ar, ai) = _sqrt(re - 1, im);
  final (br, bi) = _sqrt(re + 1, im);
  final pr = re + ar * br - ai * bi;
  final pi = im + ar * bi + ai * br;
  return (math.log(math.sqrt(pr * pr + pi * pi)), math.atan2(pi, pr));
}

(double, double) _sqrt(double re, double im) {
  final r = math.sqrt(re * re + im * im);
  final sr = math.sqrt((r + re) / 2);
  final si = math.sqrt(math.max(0, (r - re) / 2));
  return (sr, im < 0 ? -si : si);
}
