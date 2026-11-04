import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/games/counting_the_net_game.dart';
import 'package:mobile/features/games/figure_ink.dart';
import 'package:mobile/features/games/flow_net_geometry.dart';
import 'package:mobile/features/games/seepage_figures.dart';

import 'support/fonts.dart';

/// The sheet-pile flow net is computed, not sketched: these hold it to what
/// a textbook net is. Set FLOW_NET_PNG to also write the drawings out, at
/// three times size, to build/flow_net/.
void main() {
  final nets = {
    for (final r in netRounds) (r.net.channels, r.net.drops): r.net,
  };

  test('the rounds use the three nets this test covers', () {
    expect(nets.keys.toSet(), {(4, 12), (6, 12), (4, 18)});
  });

  for (final (channels, drops) in nets.keys) {
    group('$channels channels, $drops drops', () {
      final g = FlowNetGeometry(channels, drops);

      test('draws exactly the counts the question gives', () {
        // The pile and the rock are the outer flow lines, so the lines
        // drawn between them are one fewer than the channels; the two
        // ground surfaces are the outer equipotentials.
        expect(g.flowLines(), hasLength(channels - 1));
        expect(g.equipotentials(), hasLength(drops - 1));
      });

      test('the lines cross at right angles and the cells are square', () {
        const h = 1e-5;
        final half = drops ~/ 2;
        for (var i = 0.5; i < channels; i += 1) {
          for (var j = 0.5; j < half; j += 1) {
            final (x0, y0) = g.node(i, j);
            final (xa, ya) = g.node(i + h, j); // across the flow
            final (xb, yb) = g.node(i, j + h); // along the flow
            final ax = (xa - x0) / h, ay = (ya - y0) / h;
            final bx = (xb - x0) / h, by = (yb - y0) / h;
            final cos =
                (ax * bx + ay * by) /
                (math.sqrt(ax * ax + ay * ay) * math.sqrt(bx * bx + by * by));
            expect(cos.abs(), lessThan(0.01), reason: 'cell ($i, $j)');
            final aspect =
                math.sqrt(ax * ax + ay * ay) / math.sqrt(bx * bx + by * by);
            expect(aspect, closeTo(1, 0.01), reason: 'cell ($i, $j)');
          }
        }
      });

      test('no two flow lines cross, nor two equipotentials', () {
        expect(_crossings(g.flowLines()), 0);
        expect(_crossings(g.equipotentials()), 0);
      });

      test('flow lines go down, under the toe, and up, symmetric', () {
        for (final line in g.flowLines()) {
          expect(line.first.$2, closeTo(0, 1e-6)); // leaves the ground
          expect(line.last.$2, closeTo(0, 1e-6)); // comes back up to it
          expect(line.first.$1, closeTo(-line.last.$1, 1e-9));
          final deepest = line.map((p) => p.$2).reduce(math.max);
          expect(deepest, greaterThan(g.pileDepth)); // passes under the toe
          expect(deepest, lessThan(1)); // above the rock
        }
      });

      test('equipotentials run from the rock to the pile', () {
        for (final line in g.equipotentials()) {
          expect(line.first.$2, closeTo(1, 1e-6));
          expect(line.last.$1, closeTo(0, 1e-6));
          expect(line.last.$2, lessThanOrEqualTo(g.pileDepth + 1e-6));
        }
      });
    });
  }

  test(
    'square cells: more drops for the same channels means a deeper pile',
    () {
      expect(FlowNetGeometry(6, 12).pileDepth, closeTo(0.5, 1e-6));
      expect(FlowNetGeometry(4, 12).pileDepth, closeTo(0.762, 0.001));
      expect(FlowNetGeometry(4, 18).pileDepth, closeTo(0.926, 0.001));
    },
  );

  group('drawn', () {
    setUpAll(loadBrandFonts);
    const write = bool.fromEnvironment('FLOW_NET_PNG');

    for (final net in nets.values) {
      for (final width in [340.0, 620.0]) {
        testWidgets('${net.channels}x${net.drops} at $width', (t) async {
          const scale = 3.0;
          final size = Size(width, 216);
          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder)..scale(scale);
          canvas.drawRect(Offset.zero & size, Paint()..color = panelBase);
          FlowNetPainter(net: net, answered: false).paint(canvas, size);
          final picture = recorder.endRecording();
          if (!write) return;
          await t.runAsync(() async {
            final image = await picture.toImage(
              (width * scale).round(),
              (216 * scale).round(),
            );
            final png = await image.toByteData(format: ui.ImageByteFormat.png);
            File(
                'build/flow_net/net_${net.channels}x${net.drops}_'
                '${width.round()}.png',
              )
              ..createSync(recursive: true)
              ..writeAsBytesSync(png!.buffer.asUint8List());
          });
        });
      }
    }
  });
}

int _crossings(List<List<(double, double)>> lines) {
  bool cross(
    (double, double) p,
    (double, double) q,
    (double, double) r,
    (double, double) s,
  ) {
    double side((double, double) a, (double, double) b, (double, double) c) =>
        (b.$1 - a.$1) * (c.$2 - a.$2) - (b.$2 - a.$2) * (c.$1 - a.$1);
    final d1 = side(r, s, p), d2 = side(r, s, q);
    final d3 = side(p, q, r), d4 = side(p, q, s);
    return d1 * d2 < 0 && d3 * d4 < 0;
  }

  var n = 0;
  for (var a = 0; a < lines.length; a++) {
    for (var b = a + 1; b < lines.length; b++) {
      for (var i = 0; i + 1 < lines[a].length; i++) {
        for (var j = 0; j + 1 < lines[b].length; j++) {
          if (cross(
            lines[a][i],
            lines[a][i + 1],
            lines[b][j],
            lines[b][j + 1],
          )) {
            n++;
          }
        }
      }
    }
  }
  return n;
}
