import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum Arrow {
  //
  /// No arrow.
  none,

  /// The arrow tip points up.
  top,

  /// The arrow tip points down.
  bottom,

  /// The arrow tip points to the right.
  right,

  /// The arrow tip points to the left.
  left,
}

/// Ready-made values for [SquircleBorder.superRadius], the number that
/// controls how the corner curve looks.
///
/// From most pointed to most round, the scale is:
///
/// [pointed] → [squarish] → [sameAsContinuousRectangle] → [squircle] →
/// [fatSquircle] → [veryFatSquircle] → [fatCircle] → [circle] →
/// [chamfer] (a straight chamfer cut)
///
/// See [SquircleBorder.superRadius] for how the number itself works.
class SuperRadius {
  //
  /// The exact same corner curve as Flutter's [ContinuousRectangleBorder]:
  /// smooth, gently rounded corners. This is the default of most
  /// [SquircleBorder] constructors.
  static const double sameAsContinuousRectangle = double.infinity;

  /// The corners bulge outward past the rectangle's corner, making each end
  /// of the shape look pointed. The most extreme look of the scale. Note the
  /// shape paints slightly outside its rectangle.
  static const double pointed = -4.0;

  /// Like [sameAsContinuousRectangle], but the corners bulge slightly
  /// outward, filling the corner area a bit more and reading as more
  /// "square". Note the shape paints slightly outside its rectangle.
  static const double squarish = -15.0;

  /// The classic squircle (superellipse) curve, like iOS app icons.
  static const double squircle = 5.0;

  /// A slightly rounder squircle.
  static const double fatSquircle = 4.0;

  /// Rounder still: between a squircle and a circle.
  static const double veryFatSquircle = 3.0;

  /// Almost circular, with just a trace of squircle.
  static const double fatCircle = 2.5;

  /// The closest single-cubic approximation of a true circular arc:
  /// `3 / (7 - 4√2)` ≈ 2.2335625, the classic `k = 4(√2 - 1)/3` circle
  /// approximation constant expressed as a superRadius. The curve touches
  /// the true arc at each corner's midpoint and deviates from it by at most
  /// about 0.03% of the radius, bulging slightly outward. With
  /// [SquircleBorder.stadium] this gives a regular [StadiumBorder]-like pill.
  static const double circle = 2.2335625;

  /// A straight chamfer: the corner is simply cut off with a straight line.
  /// The end of the scale, where no curve is left.
  static const double chamfer = 1.0;
}

/// A rounded-rectangle shape — a "squircle" — where two things are chosen
/// independently: how big the corners are, and how the corner curve looks.
///
/// **Corner size** is chosen by the constructor:
///
/// * [SquircleBorder] (the default constructor) — a fixed [borderRadius] in
///   logical pixels, used exactly like a [RoundedRectangleBorder].
///
/// * [SquircleBorder.proportional] — the corner size is a fraction of the
///   shape's own width and height, so the corners adapt automatically when
///   the shape resizes.
///
/// * [SquircleBorder.stadium] — the corner radius is half the shape's
///   shortest side, producing a pill, like [StadiumBorder].
///
/// * [SquircleBorder.arrow] — a pill where one end is shaped as an arrow tip.
///
/// **Corner style** is chosen by [superRadius], with ready-made values in
/// [SuperRadius]. The scale goes from corners that bulge outward and look
/// pointed ([SuperRadius.pointed], [SuperRadius.squarish]), through the
/// smooth [ContinuousRectangleBorder] curve (the default) and the classic
/// iOS-style squircle ([SuperRadius.squircle]), to plain circular corners
/// ([SuperRadius.circle]).
///
/// The border line ([side]) honors [BorderSide.strokeAlign]: by default it
/// is drawn fully inside the shape. Two ways of painting it are available,
/// chosen by [useCheapCalculation].
///
/// Use it anywhere Flutter accepts a [ShapeBorder], such as
/// [ShapeDecoration], [Material], buttons, or clippers:
///
/// ```dart
/// // A card with 16-pixel, iOS-style corners:
/// ShapeDecoration(
///   color: Colors.white,
///   shape: SquircleBorder(
///     borderRadius: BorderRadius.circular(16),
///     superRadius: SuperRadius.squircle,
///   ),
/// )
///
/// // A pill-shaped tag that adapts to its content:
/// SquircleBorder.stadium(superRadius: SuperRadius.squarish)
///
/// // A "next" button whose right end points like an arrow:
/// SquircleBorder.arrow(arrow: Arrow.right)
/// ```
///
/// For the geometrically inclined: each corner is a single cubic Bézier
/// curve whose control points sit at a distance of `radius / superRadius`
/// from the corner point, along the two edges that meet there. See
/// [superRadius] for what each range of values does to that curve.
///
class SquircleBorder extends OutlinedBorder {
  //
  /// Creates a [SquircleBorder] with a fixed corner size, given as a
  /// [borderRadius] in logical pixels — used exactly like a
  /// [RoundedRectangleBorder] or [ContinuousRectangleBorder].
  ///
  /// [borderRadius] says how big each corner is, and [superRadius] says how
  /// the curve looks inside it (see [SuperRadius] for the available styles).
  /// For example, a 16-pixel corner in the classic squircle style:
  ///
  /// ```dart
  /// SquircleBorder(
  ///   borderRadius: BorderRadius.circular(16),
  ///   superRadius: SuperRadius.squircle,
  /// )
  /// ```
  ///
  /// A radius too big to fit is automatically reduced to half the side it
  /// sits on, so the two corners of an edge never overlap.
  const SquircleBorder({
    super.side,
    this.borderRadius = BorderRadius.zero,
    this.superRadius = SuperRadius.sameAsContinuousRectangle,
    this.useCheapCalculation = true,
  }) : assert(superRadius >= 1.0 || superRadius <= -1.0),
       widthFactor = null,
       heightFactor = null,
       arrow = Arrow.none,
       _isStadium = false;

  /// Creates a [SquircleBorder] whose corner size is a fraction of the
  /// shape's own size instead of a fixed number of pixels. The corners are
  /// computed every time the shape is drawn, so they adapt automatically
  /// when the shape resizes.
  ///
  /// Each factor goes from 0.0 to 1.0 and says how much of the available
  /// space the corners take, in one direction:
  ///
  /// * Each corner reaches `widthFactor * width / 2` sideways. With
  ///   `widthFactor: 1.0` the two corners of an edge meet at its middle, so
  ///   no straight part is left; with `widthFactor: 0.5` each corner takes a
  ///   quarter of the width; and so on.
  ///
  /// * Each corner reaches `heightFactor * height / 2` up or down, in the
  ///   same way.
  ///
  /// For example, on a shape 200 pixels wide and 100 pixels tall,
  /// `widthFactor: 0.5, heightFactor: 0.8` gives corners that extend
  /// 50 pixels sideways and 40 pixels vertically.
  ///
  /// A null factor copies the pixel size computed by the other factor, which
  /// makes the corners symmetrical (circular). At least one factor must be
  /// given. For example, with `widthFactor: 0.1` and a null [heightFactor],
  /// a 300-pixel-wide shape gets corners of 15 pixels in both directions,
  /// no matter its height.
  ///
  /// With `widthFactor: 1.0, heightFactor: 1.0` no straight edges are left
  /// at all: the whole outline is one continuous curve that hugs the
  /// rectangle, like an ellipse does — a "stretched squircle".
  const SquircleBorder.proportional({
    super.side,
    this.superRadius = SuperRadius.sameAsContinuousRectangle,
    this.widthFactor,
    this.heightFactor,
    this.useCheapCalculation = true,
  }) : assert(superRadius >= 1.0 || superRadius <= -1.0),
       assert(widthFactor != null || heightFactor != null),
       assert(widthFactor == null || (widthFactor >= 0.0 && widthFactor <= 1.0)),
       assert(heightFactor == null || (heightFactor >= 0.0 && heightFactor <= 1.0)),
       borderRadius = BorderRadius.zero,
       arrow = Arrow.none,
       _isStadium = false;

  /// Creates a pill-shaped [SquircleBorder]: the corner radius is always
  /// half the shape's shortest side, computed every time the shape is drawn
  /// — the same rule as Flutter's [StadiumBorder].
  ///
  /// On a wide shape this means fully-round left and right ends joined by
  /// straight top and bottom edges; on a tall shape, fully-round top and
  /// bottom ends. The style of the round ends still comes from
  /// [superRadius]: with [SuperRadius.circle] the result is essentially a
  /// regular [StadiumBorder], while with [SuperRadius.squircle] the ends
  /// curve like squircles.
  ///
  /// Because it adapts to any size, this is a good default for buttons and
  /// tags that are sized by their content.
  const SquircleBorder.stadium({
    super.side,
    this.superRadius = SuperRadius.sameAsContinuousRectangle,
    this.useCheapCalculation = true,
  }) : assert(superRadius >= 1.0 || superRadius <= -1.0),
       borderRadius = BorderRadius.zero,
       widthFactor = null,
       heightFactor = null,
       arrow = Arrow.none,
       _isStadium = true;

  /// Creates a pill like [SquircleBorder.stadium], but with one end drawn as
  /// an arrow tip: the two corners on the [arrow] side are made much
  /// pointier (they use a fixed superRadius of 1.3), so that end looks like
  /// the head of an arrow. Useful for "next"/"previous" style buttons.
  ///
  /// The tip only appears where a round end exists for it to sharpen:
  ///
  /// - [Arrow.left] and [Arrow.right] need the shape to be wider than it is
  ///   tall. Otherwise the shape stays a plain pill.
  ///
  /// - [Arrow.top] and [Arrow.bottom] need it to be taller than it is wide.
  ///   Otherwise the shape stays a plain pill.
  ///
  /// [superRadius] styles the remaining corners, and defaults to
  /// [SuperRadius.squircle] — the classic arrow look.
  const SquircleBorder.arrow({
    super.side,
    this.superRadius = SuperRadius.squircle,
    required this.arrow,
    this.useCheapCalculation = true,
  }) : assert(superRadius >= 1.0 || superRadius <= -1.0),
       borderRadius = BorderRadius.zero,
       widthFactor = null,
       heightFactor = null,
       _isStadium = true;

  const SquircleBorder._({
    required super.side,
    required this.borderRadius,
    required this.superRadius,
    required this.widthFactor,
    required this.heightFactor,
    required this.arrow,
    required this.useCheapCalculation,
    required bool isStadium,
  }) : assert(superRadius >= 1.0 || superRadius <= -1.0),
       _isStadium = isStadium;

  /// The fixed size of each corner, in logical pixels, when this border was
  /// created with the default constructor.
  ///
  /// The other constructors compute the corner size from the shape's own
  /// size every time it is drawn, and ignore this field (it stays
  /// [BorderRadius.zero] for them).
  ///
  /// Negative values are treated as zero, and a radius too big to fit is
  /// reduced to half the side it sits on.
  final BorderRadiusGeometry borderRadius;

  /// The style of the corner curve: how round, square, or pointed the
  /// corners look. The corner size says how much space each corner takes;
  /// [superRadius] says how the curve fills that space. Ready-made values
  /// live in [SuperRadius].
  ///
  /// Precisely, the value sets how far each corner's Bézier control points
  /// sit from the corner point, as a fraction of the corner size
  /// (`offset = radius / superRadius`):
  ///
  /// * `double.infinity` (the default) puts them exactly on the corner
  ///   point, giving the exact same curve as [ContinuousRectangleBorder].
  ///
  /// * Large values, like [SuperRadius.squircle] (5.0), keep them close to
  ///   the corner: smooth, squircle-like curves.
  ///
  /// * [SuperRadius.circle] (≈2.234) closely reproduces a circular arc.
  ///
  /// * [SuperRadius.chamfer] (1.0) puts them on the curve's endpoints,
  ///   producing a straight chamfer — the corner is simply cut off.
  ///
  /// * Negative values, like [SuperRadius.squarish] (-15.0) and
  ///   [SuperRadius.pointed] (-4.0), push them *past* the corner, making
  ///   the corner bulge outward. The closer the value is to -1.0, the
  ///   stronger the bulge. Note the shape then paints slightly outside its
  ///   rectangle.
  ///
  /// The magnitude must be at least 1.0: values between -1.0 and 1.0 would
  /// fold the curve onto itself.
  final double superRadius;

  /// How far the corners reach sideways, as a fraction (0.0 to 1.0) of half
  /// the shape's width, when this border was created with
  /// [SquircleBorder.proportional] — see it for the details. Null for the
  /// other constructors.
  final double? widthFactor;

  /// The same as [widthFactor], but vertically: a fraction of half the
  /// shape's height.
  final double? heightFactor;

  /// Which end of the shape is drawn as an arrow tip, when this border was
  /// created with [SquircleBorder.arrow] — see it for the details.
  /// [Arrow.none] for the other constructors.
  final Arrow arrow;

  /// How the border line ([side]) is painted.
  ///
  /// * `true` (the default): the border is a single stroked line along the
  ///   border's centerline, with the corner radii adjusted so that the line
  ///   runs parallel to the shape's outline. This is the cheapest way to
  ///   paint it, and is accurate to a small fraction of the border width —
  ///   normally indistinguishable from the exact border.
  ///
  /// * `false`: the exact band the border covers — from its outer edge to
  ///   its inner edge — is computed and filled. The side of the band that
  ///   touches the shape's outline *is* the outline, so the border meets
  ///   the fill exactly, at the cost of building and filling a two-contour
  ///   path. Use this if a very thick border with an extreme [superRadius]
  ///   shows artifacts where it meets the fill.
  ///
  /// This only affects how the border line is painted. The shape's outline
  /// and interior ([getOuterPath], [getInnerPath]) are the same either way.
  final bool useCheapCalculation;

  /// Whether the corner radius is half the rectangle's shortest side,
  /// resolved when the shape is used. See [SquircleBorder.stadium].
  final bool _isStadium;

  /// The fixed superRadius of the two corners on the [arrow] side.
  static const double _arrowSuperRadius = 1.3;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(math.max(side.strokeInset, 0.0));

  @override
  ShapeBorder scale(double t) {
    return SquircleBorder._(
      side: side.scale(t),
      borderRadius: borderRadius * t,
      // superRadius and the factors are dimensionless ratios, so they do not scale.
      superRadius: superRadius,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      arrow: arrow,
      useCheapCalculation: useCheapCalculation,
      isStadium: _isStadium,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is SquircleBorder && _isSameModeAs(a)) {
      return SquircleBorder._(
        side: BorderSide.lerp(a.side, side, t),
        borderRadius: BorderRadiusGeometry.lerp(a.borderRadius, borderRadius, t)!,
        superRadius: _lerpSuperRadius(a.superRadius, superRadius, t),
        widthFactor: (widthFactor == null)
            ? null
            : lerpDouble(a.widthFactor, widthFactor, t),
        heightFactor: (heightFactor == null)
            ? null
            : lerpDouble(a.heightFactor, heightFactor, t),
        arrow: arrow,
        useCheapCalculation: useCheapCalculation,
        isStadium: _isStadium,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is SquircleBorder && _isSameModeAs(b)) {
      return SquircleBorder._(
        side: BorderSide.lerp(side, b.side, t),
        borderRadius: BorderRadiusGeometry.lerp(borderRadius, b.borderRadius, t)!,
        superRadius: _lerpSuperRadius(superRadius, b.superRadius, t),
        widthFactor: (widthFactor == null)
            ? null
            : lerpDouble(widthFactor, b.widthFactor, t),
        heightFactor: (heightFactor == null)
            ? null
            : lerpDouble(heightFactor, b.heightFactor, t),
        arrow: arrow,
        useCheapCalculation: b.useCheapCalculation,
        isStadium: _isStadium,
      );
    }
    return super.lerpTo(b, t);
  }

  /// Whether [other] resolves its corner radius the same way (fixed,
  /// proportional with the same set of factors, or stadium), so that the two
  /// borders can be smoothly interpolated.
  bool _isSameModeAs(SquircleBorder other) =>
      _isStadium == other._isStadium &&
      arrow == other.arrow &&
      (widthFactor == null) == (other.widthFactor == null) &&
      (heightFactor == null) == (other.heightFactor == null);

  /// Lerps the reciprocal (the control-point offset fraction, which is what
  /// varies linearly with the shape), so that `double.infinity` interpolates
  /// to finite values without producing NaN.
  static double _lerpSuperRadius(double a, double b, double t) =>
      1.0 / lerpDouble(1.0 / a, 1.0 / b, t)!;

  /// By how much a corner radius must change per pixel of outline offset,
  /// so that the offset outline stays parallel to the original.
  ///
  /// Shifting the shape's rectangle outward by `o` while keeping the radius
  /// would just translate each corner curve diagonally by `(o, o)`: correct
  /// along the straight edges, but √2 times too far at the middle of the
  /// corner, where the curve's normal points along the diagonal. Changing
  /// the radius by `o * factor` places the middle of the offset corner
  /// exactly `o` away from the original curve, while the curve's endpoints
  /// stay on the offset edges.
  ///
  /// The middle of the corner (the cubic's point at `t = 0.5`) sits at
  /// `radius * (1 + 3/superRadius) / 8` from the corner point, along each
  /// axis. Requiring it to move by `o/√2` per axis gives
  /// `factor = (8 − 4√2) / (1 + 3/superRadius)`.
  ///
  /// For [SuperRadius.circle] the factor is exactly 1.0 — offsetting a
  /// circular arc by `o` is the same as changing its radius by `o`. For a
  /// superRadius of exactly -3.0 the middle of the corner sits on the
  /// corner point itself and no radius change can move it, so the factor
  /// diverges; the radius clamping in [_getPath] then takes over.
  static double _radiusOffsetFactor(double superRadius) =>
      (8.0 - 4.0 * math.sqrt2) / (1.0 + 3.0 / superRadius);

  /// Builds the squircle path for [rRect]. A non-zero [offset] builds the
  /// outline shifted outward by that many pixels (inward when negative)
  /// while staying parallel to the original: the edges are moved by
  /// [offset], and each corner radius is adjusted by [offset] times
  /// [_radiusOffsetFactor].
  Path _getPath(RRect rRect, {double offset = 0.0}) {
    final double left = rRect.left - offset;
    final double right = rRect.right + offset;
    final double top = rRect.top - offset;
    final double bottom = rRect.bottom + offset;

    // An inward offset (like the inner path of a border thicker than the
    // shape itself) may swallow the shape entirely, leaving nothing.
    if (right < left || bottom < top) return Path();

    // The two corners on the arrow side use a fixed, pointier superRadius,
    // forming the arrow tip. A left/right arrow only applies when the rect
    // is wider than it is tall, and a top/bottom arrow only when it is
    // taller than it is wide.
    final bool hasArrow = switch (arrow) {
      Arrow.none => false,
      Arrow.left || Arrow.right => rRect.width > rRect.height,
      Arrow.top || Arrow.bottom => rRect.height > rRect.width,
    };

    double cornerSuperRadius(Arrow sideA, Arrow sideB) =>
        (hasArrow && (arrow == sideA || arrow == sideB))
        ? _arrowSuperRadius
        : superRadius;

    final double tlSuperRadius = cornerSuperRadius(Arrow.left, Arrow.top);
    final double trSuperRadius = cornerSuperRadius(Arrow.right, Arrow.top);
    final double brSuperRadius = cornerSuperRadius(Arrow.right, Arrow.bottom);
    final double blSuperRadius = cornerSuperRadius(Arrow.left, Arrow.bottom);

    double radiusDelta(double sr) =>
        (offset == 0.0) ? 0.0 : offset * _radiusOffsetFactor(sr);

    final double tlRadiusDelta = radiusDelta(tlSuperRadius);
    final double trRadiusDelta = radiusDelta(trSuperRadius);
    final double brRadiusDelta = radiusDelta(brSuperRadius);
    final double blRadiusDelta = radiusDelta(blSuperRadius);

    // Each radius is clamped to half its own side of the shape, so that the
    // two corners sharing an edge never overlap (which would produce strange
    // tie-fighter shapes).
    final double halfWidth = (right - left) / 2.0;
    final double halfHeight = (bottom - top) / 2.0;
    final double tlRadiusX = clampDouble(rRect.tlRadiusX + tlRadiusDelta, 0.0, halfWidth);
    final double tlRadiusY = clampDouble(rRect.tlRadiusY + tlRadiusDelta, 0.0, halfHeight);
    final double trRadiusX = clampDouble(rRect.trRadiusX + trRadiusDelta, 0.0, halfWidth);
    final double trRadiusY = clampDouble(rRect.trRadiusY + trRadiusDelta, 0.0, halfHeight);
    final double blRadiusX = clampDouble(rRect.blRadiusX + blRadiusDelta, 0.0, halfWidth);
    final double blRadiusY = clampDouble(rRect.blRadiusY + blRadiusDelta, 0.0, halfHeight);
    final double brRadiusX = clampDouble(rRect.brRadiusX + brRadiusDelta, 0.0, halfWidth);
    final double brRadiusY = clampDouble(rRect.brRadiusY + brRadiusDelta, 0.0, halfHeight);

    // Distance of a control point from its corner, along the adjacent edge.
    double dTl(double radius) => radius / tlSuperRadius;
    double dTr(double radius) => radius / trSuperRadius;
    double dBr(double radius) => radius / brSuperRadius;
    double dBl(double radius) => radius / blSuperRadius;

    // On each corner, the X radius is its horizontal extent and the Y radius
    // its vertical extent.
    return Path()
      ..moveTo(left, top + tlRadiusY)
      ..cubicTo(
        left,
        top + dTl(tlRadiusY),
        left + dTl(tlRadiusX),
        top,
        left + tlRadiusX,
        top,
      )
      ..lineTo(right - trRadiusX, top)
      ..cubicTo(
        right - dTr(trRadiusX),
        top,
        right,
        top + dTr(trRadiusY),
        right,
        top + trRadiusY,
      )
      ..lineTo(right, bottom - brRadiusY)
      ..cubicTo(
        right,
        bottom - dBr(brRadiusY),
        right - dBr(brRadiusX),
        bottom,
        right - brRadiusX,
        bottom,
      )
      ..lineTo(left + blRadiusX, bottom)
      ..cubicTo(
        left + dBl(blRadiusX),
        bottom,
        left,
        bottom - dBl(blRadiusY),
        left,
        bottom - blRadiusY,
      )
      ..close();
  }

  /// Resolves the corner radii for the given [rect]: the fixed
  /// [borderRadius], a fraction of the rect's size (proportional), or half
  /// its shortest side (stadium).
  BorderRadius _resolveBorderRadius(Rect rect, TextDirection? textDirection) {
    if (_isStadium) return BorderRadius.circular(rect.shortestSide / 2.0);

    if (widthFactor != null || heightFactor != null) {
      double? radiusX = (widthFactor == null) ? null : widthFactor! * rect.width / 2.0;
      double? radiusY = (heightFactor == null) ? null : heightFactor! * rect.height / 2.0;
      return BorderRadius.all(
        Radius.elliptical(radiusX ?? radiusY!, radiusY ?? radiusX!),
      );
    }

    return borderRadius.resolve(textDirection);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _getPath(
      _resolveBorderRadius(rect, textDirection).toRRect(rect),
      offset: -side.strokeInset,
    );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _getPath(_resolveBorderRadius(rect, textDirection).toRRect(rect));
  }

  @override
  SquircleBorder copyWith({
    BorderSide? side,
    BorderRadiusGeometry? borderRadius,
    double? superRadius,
    bool? useCheapCalculation,
  }) {
    return SquircleBorder._(
      side: side ?? this.side,
      borderRadius: borderRadius ?? this.borderRadius,
      superRadius: superRadius ?? this.superRadius,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      arrow: arrow,
      useCheapCalculation: useCheapCalculation ?? this.useCheapCalculation,
      isStadium: _isStadium,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (rect.isEmpty) {
      return;
    }
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        final RRect rRect = _resolveBorderRadius(rect, textDirection).toRRect(rect);

        if (useCheapCalculation || side.width == 0.0) {
          // A single stroked line along the border's centerline, which
          // [BorderSide.strokeAlign] places at an offset from the shape's
          // outline: with the default strokeAlignInside the stroke paints
          // fully inside the rect, consistent with [getInnerPath]. The
          // radius adjustment in [_getPath] keeps the centerline parallel
          // to the outline, so the stroke stays flush with the fill to
          // within a small fraction of the border width.
          canvas.drawPath(
            _getPath(rRect, offset: side.strokeOffset / 2.0),
            side.toPaint(),
          );
        }
        //
        else {
          // The exact band the border covers: the area between its outer
          // and inner edges, filled as a two-contour even-odd path. The
          // contour that touches the shape's outline is the outline
          // itself, so the border meets the fill exactly.
          final Path band = _getPath(rRect, offset: side.strokeOutset)
            ..addPath(_getPath(rRect, offset: -side.strokeInset), Offset.zero)
            ..fillType = PathFillType.evenOdd;
          canvas.drawPath(band, Paint()..color = side.color);
        }
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SquircleBorder &&
        other.side == side &&
        other.borderRadius == borderRadius &&
        other.superRadius == superRadius &&
        other.widthFactor == widthFactor &&
        other.heightFactor == heightFactor &&
        other.arrow == arrow &&
        other.useCheapCalculation == useCheapCalculation &&
        other._isStadium == _isStadium;
  }

  @override
  int get hashCode => Object.hash(
    side,
    borderRadius,
    superRadius,
    widthFactor,
    heightFactor,
    arrow,
    useCheapCalculation,
    _isStadium,
  );

  @override
  String toString() {
    return '${objectRuntimeType(this, 'SquircleBorder')}'
        '($side, $borderRadius, $superRadius, $widthFactor, $heightFactor, $arrow, '
        '$useCheapCalculation, $_isStadium)';
  }
}
