import 'dart:ui';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Samples [path] on a grid of points covering [rect], returning the
/// contains() result for each point, so two paths can be compared
/// geometrically.
List<bool> samplesOf(Path path, Rect rect) => [
  for (var i = 0; i <= 30; i++)
    for (var j = 0; j <= 30; j++)
      path.contains(
        Offset(rect.left + rect.width * i / 30, rect.top + rect.height * j / 30),
      ),
];

void main() {
  group('superRadius validation', () {
    test('Accepts negative values with magnitude >= 1.', () {
      expect(
        () => const SquircleBorder(superRadius: SuperRadius.squarish),
        returnsNormally,
      );
      expect(
        () => const SquircleBorder(superRadius: SuperRadius.pointed),
        returnsNormally,
      );
      expect(() => const SquircleBorder(superRadius: -1.0), returnsNormally);
      expect(
        () => const SquircleBorder.stadium(superRadius: SuperRadius.squarish),
        returnsNormally,
      );
    });

    test('Rejects magnitudes below 1, including zero.', () {
      expect(() => SquircleBorder(superRadius: 0.5), throwsAssertionError);
      expect(() => SquircleBorder(superRadius: 0.0), throwsAssertionError);
      expect(() => SquircleBorder(superRadius: -0.5), throwsAssertionError);
    });

    test('Negative superRadius bulges the corner outward.', () {
      var rect = const Rect.fromLTWH(0, 0, 100, 100);
      var radius = BorderRadius.circular(30);
      var squircle = SquircleBorder(
        borderRadius: radius,
        superRadius: SuperRadius.squircle,
      );
      var squarish = SquircleBorder(
        borderRadius: radius,
        superRadius: SuperRadius.squarish,
      );

      // The squircle (5.0) corner curve passes through (6, 6), while the
      // squarish (-15.0) curve bulges closer to the corner, through (3, 3).
      expect(squircle.getOuterPath(rect).contains(const Offset(4, 4)), isFalse);
      expect(squarish.getOuterPath(rect).contains(const Offset(4, 4)), isTrue);
    });
  });

  group('SquircleBorder.proportional', () {
    test('Requires at least one factor, each within 0 to 1.', () {
      expect(() => SquircleBorder.proportional(), throwsAssertionError);
      expect(() => SquircleBorder.proportional(widthFactor: 1.5), throwsAssertionError);
      expect(() => SquircleBorder.proportional(heightFactor: -0.1), throwsAssertionError);
      expect(
        () => const SquircleBorder.proportional(widthFactor: 1.0, heightFactor: 0.0),
        returnsNormally,
      );
    });

    test('Radius is factor * side / 2 on each axis.', () {
      // A chamfer (superRadius 1.0) cuts a straight line between the curve
      // endpoints, so containment reduces to x/rx + y/ry >= 1 at each corner.
      // Rect 200x100 with widthFactor 0.5, heightFactor 0.8: rx=50, ry=40.
      var border = const SquircleBorder.proportional(
        superRadius: 1.0,
        widthFactor: 0.5,
        heightFactor: 0.8,
      );
      var path = border.getOuterPath(const Rect.fromLTWH(0, 0, 200, 100));

      // Center.
      expect(path.contains(const Offset(100, 50)), isTrue);

      // 10/50 + 10/40 = 0.45 < 1: cut off, at all four corners.
      expect(path.contains(const Offset(10, 10)), isFalse);
      expect(path.contains(const Offset(190, 10)), isFalse);
      expect(path.contains(const Offset(190, 90)), isFalse);
      expect(path.contains(const Offset(10, 90)), isFalse);

      // 40/50 + 35/40 = 1.675 > 1: inside, at all four corners.
      expect(path.contains(const Offset(40, 35)), isTrue);
      expect(path.contains(const Offset(160, 35)), isTrue);
      expect(path.contains(const Offset(160, 65)), isTrue);
      expect(path.contains(const Offset(40, 65)), isTrue);
    });

    test('A null factor copies the radius resolved by the other factor.', () {
      // Rect 300x100 with widthFactor 0.1: rx = 15px, and ry copies the same
      // 15px (not 0.1 of the height, which would be 5px).
      var border = const SquircleBorder.proportional(superRadius: 1.0, widthFactor: 0.1);
      var path = border.getOuterPath(const Rect.fromLTWH(0, 0, 300, 100));

      // 5/15 + 5/15 = 0.67 < 1: cut off. If ry were 5px instead, this would
      // read 5/15 + 5/5 = 1.33 and the point would be inside.
      expect(path.contains(const Offset(5, 5)), isFalse);

      // 12/15 + 12/15 = 1.6 > 1: inside.
      expect(path.contains(const Offset(12, 12)), isTrue);
    });
  });

  group('SquircleBorder.stadium', () {
    test('Equals a fixed border with radius shortestSide / 2.', () {
      var stadium = const SquircleBorder.stadium(superRadius: SuperRadius.squircle);

      var wide = const Rect.fromLTWH(0, 0, 300, 120);
      var wideFixed = SquircleBorder(
        borderRadius: BorderRadius.circular(60),
        superRadius: SuperRadius.squircle,
      );
      expect(
        samplesOf(stadium.getOuterPath(wide), wide),
        samplesOf(wideFixed.getOuterPath(wide), wide),
      );

      var tall = const Rect.fromLTWH(0, 0, 100, 400);
      var tallFixed = SquircleBorder(
        borderRadius: BorderRadius.circular(50),
        superRadius: SuperRadius.squircle,
      );
      expect(
        samplesOf(stadium.getOuterPath(tall), tall),
        samplesOf(tallFixed.getOuterPath(tall), tall),
      );
    });
  });

  group('Elliptical corner radii', () {
    test('The X radius is the horizontal extent, on every corner.', () {
      // A chamfer with rx=40, ry=10 on a 200x100 rect: a point 30px into the
      // corner horizontally and 2px vertically satisfies
      // 30/40 + 2/10 = 0.95 < 1, so it is cut off. With swapped axes
      // (rx=10, ry=40) it would read 30/10 + 2/40 = 3.05 and be inside.
      var border = const SquircleBorder(
        borderRadius: BorderRadius.all(Radius.elliptical(40, 10)),
        superRadius: 1.0,
      );
      var path = border.getOuterPath(const Rect.fromLTWH(0, 0, 200, 100));

      expect(path.contains(const Offset(30, 2)), isFalse); // Top-left.
      expect(path.contains(const Offset(170, 2)), isFalse); // Top-right.
      expect(path.contains(const Offset(170, 98)), isFalse); // Bottom-right.
      expect(path.contains(const Offset(30, 98)), isFalse); // Bottom-left.
    });
  });

  group('Lerp', () {
    test('Interpolates smoothly between two borders of the same mode.', () {
      var a = SquircleBorder(
        borderRadius: BorderRadius.circular(20),
        superRadius: SuperRadius.squarish,
      );
      var b = SquircleBorder(
        borderRadius: BorderRadius.circular(40),
        superRadius: SuperRadius.squircle,
      );
      var mid = ShapeBorder.lerp(a, b, 0.5) as SquircleBorder;

      expect(mid.borderRadius, BorderRadius.circular(30));

      // Reciprocal lerp: 1 / (0.5 * (1/-15 + 1/5)) = 15.
      expect(mid.superRadius, closeTo(15.0, 1e-9));

      var pa = const SquircleBorder.proportional(widthFactor: 0.2);
      var pb = const SquircleBorder.proportional(widthFactor: 0.6);
      var pMid = ShapeBorder.lerp(pa, pb, 0.5) as SquircleBorder;
      expect(pMid.widthFactor, closeTo(0.4, 1e-9));
      expect(pMid.heightFactor, isNull);
    });

    test('Falls back to a discrete switch across different modes.', () {
      var fixed = SquircleBorder(borderRadius: BorderRadius.circular(20));
      var stadium = const SquircleBorder.stadium();
      expect(ShapeBorder.lerp(fixed, stadium, 0.25), same(fixed));
      expect(ShapeBorder.lerp(fixed, stadium, 0.75), same(stadium));

      var w = const SquircleBorder.proportional(widthFactor: 0.5);
      var h = const SquircleBorder.proportional(heightFactor: 0.5);
      expect(ShapeBorder.lerp(w, h, 0.25), same(w));

      // Arrows in different directions cannot be interpolated.
      var leftArrow = const SquircleBorder.arrow(Arrow.left);
      var rightArrow = const SquircleBorder.arrow(Arrow.right);
      expect(ShapeBorder.lerp(leftArrow, rightArrow, 0.25), same(leftArrow));

      // Same-direction arrows interpolate smoothly.
      var mid =
          ShapeBorder.lerp(
                const SquircleBorder.arrow(
                  Arrow.right,
                  superRadius: SuperRadius.squarish,
                ),
                const SquircleBorder.arrow(
                  Arrow.right,
                  superRadius: SuperRadius.squircle,
                ),
                0.5,
              )
              as SquircleBorder;
      expect(mid.superRadius, closeTo(15.0, 1e-9));
      expect(mid.arrow, Arrow.right);
    });

    test('Takes useCheapCalculation from the destination border.', () {
      var a = SquircleBorder(borderRadius: BorderRadius.circular(10));
      var b = SquircleBorder(
        borderRadius: BorderRadius.circular(20),
        useCheapCalculation: false,
      );
      var lerped = ShapeBorder.lerp(a, b, 0.5)! as SquircleBorder;
      expect(lerped.useCheapCalculation, isFalse);
    });
  });

  group('Equivalence with the legacy squircle shapes', () {
    //
    var rects = [
      const Rect.fromLTWH(0, 0, 300, 120), // Wider than tall.
      const Rect.fromLTWH(0, 0, 80, 240), // Taller than wide.
      const Rect.fromLTWH(0, 0, 100, 100), // Square.
    ];

    var superRadii = [
      SuperRadius.squircle,
      SuperRadius.squarish,
      SuperRadius.fatCircle,
    ];

    test('Stadium matches the flat-sides squircle shape.', () {
      for (var superRadius in superRadii) {
        for (var rect in rects) {
          var a = SquircleBorder.stadium(superRadius: superRadius).getOuterPath(rect);
          var b = legacyOuterPath(rect, superRadius);
          expect(
            samplesOf(a, rect.deflate(1.0)),
            samplesOf(b, rect.deflate(1.0)),
            reason: 'superRadius $superRadius, rect $rect',
          );
        }
      }
    });

    test('Proportional(1, 1) matches the rounded-sides squircle shape.', () {
      for (var superRadius in superRadii) {
        for (var rect in rects) {
          var a = SquircleBorder.proportional(
            widthFactor: 1.0,
            heightFactor: 1.0,
            superRadius: superRadius,
          ).getOuterPath(rect);
          var b = legacyOuterPath(rect, superRadius, hasRoundedSides: true);
          expect(
            samplesOf(a, rect.deflate(1.0)),
            samplesOf(b, rect.deflate(1.0)),
            reason: 'superRadius $superRadius, rect $rect',
          );
        }
      }
    });

    test('Arrow matches the legacy arrow shape.', () {
      var rect = const Rect.fromLTWH(0, 0, 300, 120);
      for (var superRadius in superRadii) {
        for (var arrow in [Arrow.left, Arrow.right]) {
          var a = SquircleBorder.arrow(
            arrow,
            superRadius: superRadius,
          ).getOuterPath(rect);
          var b = legacyOuterPath(rect, superRadius, arrow: arrow);
          expect(
            samplesOf(a, rect.deflate(1.0)),
            samplesOf(b, rect.deflate(1.0)),
            reason: 'superRadius $superRadius, arrow $arrow',
          );
        }
      }
    });

    test('Arrow is ignored on square and taller-than-wide rects.', () {
      for (var rect in [
        const Rect.fromLTWH(0, 0, 100, 100),
        const Rect.fromLTWH(0, 0, 80, 240),
      ]) {
        var a = const SquircleBorder.arrow(Arrow.right).getOuterPath(rect);
        var b = const SquircleBorder.stadium(
          superRadius: SuperRadius.squircle,
        ).getOuterPath(rect);
        expect(
          samplesOf(a, rect.deflate(1.0)),
          samplesOf(b, rect.deflate(1.0)),
          reason: 'rect $rect',
        );
      }
    });
  });

  group('Vertical arrows', () {
    test('Top/bottom arrows are the transpose of left/right arrows.', () {
      var wide = const Rect.fromLTWH(0, 0, 300, 120);
      var tall = const Rect.fromLTWH(0, 0, 120, 300);

      // Transposing (x, y) -> (y, x) maps the tall rect onto the wide rect,
      // the top edge onto the left edge, and the bottom edge onto the right
      // edge.
      var pairs = {Arrow.top: Arrow.left, Arrow.bottom: Arrow.right};

      for (var superRadius in [SuperRadius.squircle, SuperRadius.squarish]) {
        pairs.forEach((vertical, horizontal) {
          var tallPath = SquircleBorder.arrow(
            vertical,
            superRadius: superRadius,
          ).getOuterPath(tall);
          var widePath = SquircleBorder.arrow(
            horizontal,
            superRadius: superRadius,
          ).getOuterPath(wide);

          var area = tall.deflate(1.0);
          for (var i = 0; i <= 30; i++) {
            for (var j = 0; j <= 30; j++) {
              var x = area.left + area.width * i / 30;
              var y = area.top + area.height * j / 30;
              expect(
                tallPath.contains(Offset(x, y)),
                widePath.contains(Offset(y, x)),
                reason: 'superRadius $superRadius, $vertical vs $horizontal at ($x, $y)',
              );
            }
          }
        });
      }
    });

    test('Top/bottom arrows are ignored on square and wider-than-tall rects.', () {
      for (var rect in [
        const Rect.fromLTWH(0, 0, 100, 100),
        const Rect.fromLTWH(0, 0, 300, 120),
      ]) {
        for (var arrow in [Arrow.top, Arrow.bottom]) {
          var a = SquircleBorder.arrow(arrow).getOuterPath(rect);
          var b = const SquircleBorder.stadium(
            superRadius: SuperRadius.squircle,
          ).getOuterPath(rect);
          expect(
            samplesOf(a, rect.deflate(1.0)),
            samplesOf(b, rect.deflate(1.0)),
            reason: 'rect $rect, arrow $arrow',
          );
        }
      }
    });
  });

  group('strokeAlign', () {
    //
    var rect = const Rect.fromLTWH(0, 0, 100, 100);

    SquircleBorder borderWith(double align) =>
        SquircleBorder(side: BorderSide(width: 10.0, strokeAlign: align));

    test('dimensions shrink as the stroke moves outward.', () {
      expect(
        borderWith(BorderSide.strokeAlignInside).dimensions,
        const EdgeInsets.all(10.0),
      );
      expect(
        borderWith(BorderSide.strokeAlignCenter).dimensions,
        const EdgeInsets.all(5.0),
      );
      expect(borderWith(BorderSide.strokeAlignOutside).dimensions, EdgeInsets.zero);
    });

    test('getInnerPath deflates by the part of the stroke that is inside.', () {
      Rect innerBounds(double align) => borderWith(align).getInnerPath(rect).getBounds();

      expect(
        innerBounds(BorderSide.strokeAlignInside),
        const Rect.fromLTWH(10, 10, 80, 80),
      );
      expect(
        innerBounds(BorderSide.strokeAlignCenter),
        const Rect.fromLTWH(5, 5, 90, 90),
      );
      expect(innerBounds(BorderSide.strokeAlignOutside), rect);
    });

    test('getInnerPath is empty when the border swallows the shape.', () {
      var inner = SquircleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(width: 300),
      ).getInnerPath(rect);
      expect(inner.getBounds().isEmpty, isTrue);
    });
  });

  group('paint', () {
    //
    var rect = const Rect.fromLTWH(0, 0, 120, 80);

    /// Paints [border] on a real canvas, just to prove it does not throw.
    void paintBorder(SquircleBorder border) {
      var recorder = PictureRecorder();
      var canvas = Canvas(recorder);
      border.paint(canvas, rect, textDirection: TextDirection.ltr);
      recorder.endRecording();
    }

    var aligns = [
      BorderSide.strokeAlignInside,
      BorderSide.strokeAlignCenter,
      BorderSide.strokeAlignOutside,
    ];

    test('Shifts the stroke centerline per the alignment.', () {
      var square = const Rect.fromLTWH(0, 0, 100, 100);

      Rect strokeCenterlineBounds(double align) {
        var canvas = _RecordingCanvas();
        SquircleBorder(
          side: BorderSide(width: 10.0, strokeAlign: align),
        ).paint(canvas, square);
        return canvas.path!.getBounds();
      }

      // With a 10px stroke: fully inside spans 0..10 from the edge
      // (centerline 5px in), centered spans -5..5, and fully outside spans
      // -10..0 (centerline 5px out).
      expect(
        strokeCenterlineBounds(BorderSide.strokeAlignInside),
        const Rect.fromLTWH(5, 5, 90, 90),
      );
      expect(strokeCenterlineBounds(BorderSide.strokeAlignCenter), square);
      expect(
        strokeCenterlineBounds(BorderSide.strokeAlignOutside),
        const Rect.fromLTWH(-5, -5, 110, 110),
      );
    });

    for (var cheap in [true, false]) {
      test('Does not throw for any strokeAlign (cheap: $cheap).', () {
        for (var align in aligns) {
          paintBorder(
            SquircleBorder(
              borderRadius: BorderRadius.circular(28),
              superRadius: SuperRadius.squircle,
              useCheapCalculation: cheap,
              side: BorderSide(width: 8, strokeAlign: align),
            ),
          );
        }
      });

      test('Does not throw on exotic shapes (cheap: $cheap).', () {
        for (var border in [
          SquircleBorder.stadium(
            superRadius: SuperRadius.pointed,
            useCheapCalculation: cheap,
            side: const BorderSide(width: 10),
          ),
          SquircleBorder.proportional(
            widthFactor: 1.0,
            heightFactor: 1.0,
            useCheapCalculation: cheap,
            side: const BorderSide(width: 6, strokeAlign: 0.5),
          ),
          SquircleBorder.arrow(
            Arrow.right,
            useCheapCalculation: cheap,
            side: const BorderSide(width: 4),
          ),
          // A border much thicker than the shape: the inner path vanishes.
          SquircleBorder(
            borderRadius: BorderRadius.circular(28),
            useCheapCalculation: cheap,
            side: const BorderSide(width: 300),
          ),
          // A zero-width (hairline) border.
          SquircleBorder(
            borderRadius: BorderRadius.circular(28),
            useCheapCalculation: cheap,
            side: const BorderSide(width: 0),
          ),
        ]) {
          paintBorder(border);
        }
      });
    }
  });

  group('Offset outlines stay parallel to the shape', () {
    //
    var rect = const Rect.fromLTWH(0, 0, 120, 80);

    // For each superRadius style, the inner path (the fill boundary moved
    // inward by the 8-pixel inside border) must sit close to 8 pixels from
    // the outer path everywhere — in particular along the corner diagonal,
    // where the old rect-deflation approach was off by up to 40%.
    for (var (name, superRadius) in [
      ('sameAsContinuousRectangle', SuperRadius.sameAsContinuousRectangle),
      ('squircle', SuperRadius.squircle),
      ('circle', SuperRadius.circle),
      ('chamfer', SuperRadius.chamfer),
    ]) {
      test('inner path is ~8px inside the outer path ($name)', () {
        var border = SquircleBorder(
          borderRadius: BorderRadius.circular(28),
          superRadius: superRadius,
          side: const BorderSide(width: 8),
        );
        var outer = border.getOuterPath(rect);
        var inner = border.getInnerPath(rect);

        // Sample points along the top-left corner diagonal, from the corner
        // inward: the inner boundary must start 8px (±0.4px) after the outer
        // boundary does.
        double outerEdge = double.nan, innerEdge = double.nan;
        for (double d = 0.0; d < 40.0; d += 0.01) {
          var probe = Offset(d * 0.7071, d * 0.7071);
          if (outerEdge.isNaN && outer.contains(probe)) outerEdge = d;
          if (innerEdge.isNaN && inner.contains(probe)) innerEdge = d;
        }
        expect(innerEdge - outerEdge, closeTo(8.0, 0.4));

        // And along the top edge's middle, it must be exactly 8px.
        expect(outer.contains(const Offset(60, 0.01)), isTrue);
        expect(inner.contains(const Offset(60, 7.9)), isFalse);
        expect(inner.contains(const Offset(60, 8.1)), isTrue);
      });
    }

    test('for SuperRadius.circle, the offset curve is exact', () {
      // Offsetting a circular arc is the same as shrinking its radius, so
      // the inner path of a circle-cornered squircle must be the same
      // squircle with radius 28−8 = 20 on the deflated rect.
      var border = SquircleBorder(
        borderRadius: BorderRadius.circular(28),
        superRadius: SuperRadius.circle,
        side: const BorderSide(width: 8),
      );
      var inner = border.getInnerPath(rect);
      var expected = SquircleBorder(
        borderRadius: BorderRadius.circular(20),
        superRadius: SuperRadius.circle,
      ).getOuterPath(rect.deflate(8));

      for (double d = 0.0; d < 40.0; d += 0.5) {
        var probe = Offset(8 + d * 0.7071, 8 + d * 0.7071);
        expect(inner.contains(probe), expected.contains(probe));
      }
    });

    test('the exact band (useCheapCalculation: false) is bounded by the outline', () {
      // The band is outerPath minus innerPath. Points just inside the
      // outline belong to the band; points just outside it do not.
      var border = SquircleBorder(
        borderRadius: BorderRadius.circular(28),
        superRadius: SuperRadius.squircle,
        useCheapCalculation: false,
        side: const BorderSide(width: 8),
      );
      var outer = border.getOuterPath(rect);
      var inner = border.getInnerPath(rect);
      var band = Path.combine(PathOperation.difference, outer, inner);

      // On the corner diagonal, the band spans [outline, outline + 8].
      var outerEdge = double.nan;
      for (double d = 0.0; d < 40.0; d += 0.01) {
        var probe = Offset(d * 0.7071, d * 0.7071);
        if (outer.contains(probe)) {
          outerEdge = d;
          break;
        }
      }
      Offset diag(double d) => Offset(d * 0.7071, d * 0.7071);
      expect(band.contains(diag(outerEdge + 0.1)), isTrue);
      expect(band.contains(diag(outerEdge - 0.1)), isFalse);
      expect(band.contains(diag(outerEdge + 7.5)), isTrue);
      expect(band.contains(diag(outerEdge + 8.5)), isFalse);
    });
  });

  group('copyWith and equality', () {
    test('copyWith preserves the radius mode and useCheapCalculation.', () {
      expect(
        const SquircleBorder.stadium().copyWith(superRadius: 5.0),
        const SquircleBorder.stadium(superRadius: 5.0),
      );
      expect(
        const SquircleBorder.proportional(widthFactor: 0.5).copyWith(superRadius: 3.0),
        const SquircleBorder.proportional(widthFactor: 0.5, superRadius: 3.0),
      );

      var exact = SquircleBorder(
        borderRadius: BorderRadius.circular(16),
        useCheapCalculation: false,
      );
      expect(exact.copyWith(superRadius: 5.0).useCheapCalculation, isFalse);
      expect(exact.copyWith(useCheapCalculation: true).useCheapCalculation, isTrue);
    });

    test('Borders with the same fields but different modes are not equal.', () {
      expect(const SquircleBorder.stadium(), isNot(const SquircleBorder()));
      expect(
        const SquircleBorder.arrow(Arrow.right),
        isNot(const SquircleBorder.arrow(Arrow.left)),
      );
      expect(
        const SquircleBorder.arrow(Arrow.right, superRadius: 5.0),
        isNot(const SquircleBorder.stadium(superRadius: 5.0)),
      );
    });

    test('Equality and hashCode include useCheapCalculation.', () {
      var a = SquircleBorder(borderRadius: BorderRadius.circular(16));
      var b = SquircleBorder(borderRadius: BorderRadius.circular(16));
      var c = SquircleBorder(
        borderRadius: BorderRadius.circular(16),
        useCheapCalculation: false,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });
}

/// Captures the path given to [Canvas.drawPath], so tests can inspect where
/// [SquircleBorder.paint] strokes the border.
class _RecordingCanvas implements Canvas {
  Path? path;

  @override
  void drawPath(Path path, Paint paint) => this.path = path;

  @override
  void noSuchMethod(Invocation invocation) {}
}

// -----------------------------------------------------------------------------
// Reference implementation: the path math of the deleted SquircleOutlinedBorder
// (previously also duplicated as _SquircleBorder), copied verbatim so the tests
// above can pin that SquircleBorder reproduces the exact same shapes.

Path legacyOuterPath(
  Rect rect,
  double superRadius, {
  bool hasRoundedSides = false,
  Arrow arrow = Arrow.none,
}) {
  if (hasRoundedSides || (rect.width == rect.height))
    return _legacyRoundSides(rect, superRadius);
  else
    return (rect.width > rect.height)
        ? _legacyFlatSidesWide(rect, superRadius, arrow)
        : _legacyFlatSidesTall(rect, superRadius);
}

Path _legacyRoundSides(Rect rect, double superRadius) {
  var width = rect.width / 2;
  var height = rect.height / 2;

  final dx = width / superRadius;
  final dy = height / superRadius;

  return Path()
    ..moveTo(rect.topCenter.dx, rect.topCenter.dy)
    ..relativeCubicTo(width - dx, 0.0, width, dy, width, height)
    ..relativeCubicTo(0.0, height - dy, -dx, height, -width, height)
    ..relativeCubicTo(-(width - dx), 0.0, -width, -dy, -width, -height)
    ..relativeCubicTo(0.0, dy - height, dx, -height, width, -height)
    ..close();
}

Path _legacyFlatSidesWide(Rect rect, double superRadius, Arrow arrow) {
  var height = rect.height / 2;
  var flatWidth = (rect.width - rect.height).abs();
  var roundWidth = height;

  var superRadiusRight = (arrow == Arrow.right) ? 1.3 : superRadius;
  final dxRight = roundWidth / superRadiusRight;
  final dyRight = height / superRadiusRight;

  var superRadiusLeft = (arrow == Arrow.left) ? 1.3 : superRadius;
  final dxLeft = roundWidth / superRadiusLeft;
  final dyLeft = height / superRadiusLeft;

  return Path()
    ..moveTo(rect.topCenter.dx, rect.topCenter.dy)
    ..relativeLineTo(flatWidth / 2, 0.0)
    ..relativeCubicTo(roundWidth - dxRight, 0.0, roundWidth, dyRight, roundWidth, height)
    ..relativeCubicTo(0.0, height - dyRight, -dxRight, height, -roundWidth, height)
    ..relativeLineTo(-flatWidth, 0.0)
    ..relativeCubicTo(
      -(roundWidth - dxLeft),
      0.0,
      -roundWidth,
      -dyLeft,
      -roundWidth,
      -height,
    )
    ..relativeCubicTo(0.0, dyLeft - height, dxLeft, -height, roundWidth, -height)
    ..close();
}

Path _legacyFlatSidesTall(Rect rect, double superRadius) {
  var width = rect.width / 2;
  var flatHeight = (rect.width - rect.height).abs();
  var roundHeight = width;

  final dx = width / superRadius;
  final dy = roundHeight / superRadius;

  return Path()
    ..moveTo(rect.topCenter.dx, rect.topCenter.dy)
    ..relativeCubicTo(width - dx, 0.0, width, dy, width, roundHeight)
    ..relativeLineTo(0.0, flatHeight)
    ..relativeCubicTo(0.0, roundHeight - dy, -dx, roundHeight, -width, roundHeight)
    ..relativeCubicTo(-(width - dx), 0.0, -width, -dy, -width, -roundHeight)
    ..relativeLineTo(0.0, -flatHeight)
    ..relativeCubicTo(0.0, dy - roundHeight, dx, -roundHeight, width, -roundHeight)
    ..close();
}