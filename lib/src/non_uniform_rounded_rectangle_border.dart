import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A rectangular border with rounded corners.
///
/// Typically used with [ShapeDecoration] to draw a box with a rounded
/// rectangle.
///
/// The differences to a [RoundedRectangleBorder] are:
///
/// * You can hide some of the sides, by setting [hideTopSide],
/// [hideBottomSide], [hideRightSide] and [hideLeftSide] to false.
///
/// * A single [radius] will be used for the corners of all non-hidden sides.
///
/// See also:
///
///  * [BorderSide], which is used to describe each side of the box.
///  * [Border], which, when used with [BoxDecoration], can also
///    describe a rounded rectangle.
///
class NonUniformRoundedRectangleBorder extends OutlinedBorder {
  //
  /// Creates a rounded rectangle border.
  const NonUniformRoundedRectangleBorder({
    BorderSide side = const BorderSide(color: Colors.black, width: 2.0),
    this.radius = 4.0,
    this.hideTopSide = true,
    this.hideBottomSide = true,
    this.hideRightSide = true,
    this.hideLeftSide = true,
  }) : super(side: side);

  /// The radii of the border's rounded rectangle corners.
  final double radius;

  /// You can hide the top side by making [hideTopSide] false.
  final bool hideTopSide;

  /// You can hide the bottom side by making [hideBottomSide] false.
  final bool hideBottomSide;

  /// You can hide the right side by making [hideRightSide] false.
  final bool hideRightSide;

  /// You can hide the left side by making [hideLeftSide] false.
  final bool hideLeftSide;

  bool get showTopSide => !hideTopSide;

  bool get showBottomSide => !hideBottomSide;

  bool get showRightSide => !hideRightSide;

  bool get showLeftSide => !hideLeftSide;

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(side.width);
  }

  @override
  ShapeBorder scale(double t) {
    return NonUniformRoundedRectangleBorder(
      side: side.scale(t),
      radius: radius * t,
      hideTopSide: hideTopSide,
      hideBottomSide: hideBottomSide,
      hideRightSide: hideRightSide,
      hideLeftSide: hideLeftSide,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is NonUniformRoundedRectangleBorder) {
      return NonUniformRoundedRectangleBorder(
        side: BorderSide.lerp(a.side, side, t),
        radius: lerpDouble(a.radius, radius, t)!,
        hideTopSide: hideTopSide,
        hideBottomSide: hideBottomSide,
        hideRightSide: hideRightSide,
        hideLeftSide: hideLeftSide,
      );
    }

    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is NonUniformRoundedRectangleBorder) {
      return NonUniformRoundedRectangleBorder(
        side: BorderSide.lerp(side, b.side, t),
        radius: lerpDouble(radius, b.radius, t)!,
        hideTopSide: hideTopSide,
        hideBottomSide: hideBottomSide,
        hideRightSide: hideRightSide,
        hideLeftSide: hideLeftSide,
      );
    }

    return super.lerpTo(b, t);
  }

  /// Returns a copy of this [NonUniformRoundedRectangleBorder\ with the given fields
  /// replaced with the new values.
  @override
  NonUniformRoundedRectangleBorder copyWith({
    BorderSide? side,
    double? radius,
    bool? hideTopSide,
    bool? hideBottomSide,
    bool? hideRightSide,
    bool? hideLeftSide,
  }) {
    return NonUniformRoundedRectangleBorder(
      side: side ?? this.side,
      radius: radius ?? this.radius,
      hideTopSide: hideTopSide ?? this.hideTopSide,
      hideBottomSide: hideBottomSide ?? this.hideBottomSide,
      hideRightSide: hideRightSide ?? this.hideRightSide,
      hideLeftSide: hideLeftSide ?? this.hideLeftSide,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(_borderRadius(rect).resolve(textDirection).toRRect(rect).deflate(side.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(_borderRadius(rect).resolve(textDirection).toRRect(rect));
  }

  BorderRadius _borderRadius(Rect rect) {
    //
    var radius = min(this.radius, rect.shortestSide / 2);

    return BorderRadius.only(
      topLeft: (showTopSide && showLeftSide) ? Radius.circular(radius) : Radius.zero,
      topRight: (showTopSide && showRightSide) ? Radius.circular(radius) : Radius.zero,
      bottomLeft: (showBottomSide && showLeftSide) ? Radius.circular(radius) : Radius.zero,
      bottomRight: (showBottomSide && showRightSide) ? Radius.circular(radius) : Radius.zero,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    switch (side.style) {
      //
      case BorderStyle.none:
        break;
      //
      case BorderStyle.solid:
        var paint = side.toPaint();
        var path = _path(canvas, rect);
        canvas.drawPath(path, paint);
        break;
    }
  }

  Path _path(Canvas canvas, Rect rect) {
    //
    rect = rect.deflate(side.width / 2.0);
    final halfWidth = side.width / 2;
    var radius = max(0.0, this.radius - halfWidth);
    bool noRadius = (radius == 0.0);

    final Path path = Path();

    // No radius will be used.
    if (noRadius) {
      if (showTopSide)
        path
          ..moveTo(rect.left - halfWidth, rect.top)
          ..lineTo(rect.right + halfWidth, rect.top);

      if (showRightSide)
        path
          ..moveTo(rect.right, rect.top - halfWidth)
          ..lineTo(rect.right, rect.bottom + halfWidth);

      if (showBottomSide)
        path
          ..moveTo(rect.left - halfWidth, rect.bottom)
          ..lineTo(rect.right + halfWidth, rect.bottom);

      if (showLeftSide)
        path
          ..moveTo(rect.left, rect.top - halfWidth)
          ..lineTo(rect.left, rect.bottom + halfWidth);

      return path;
    }
    //
    // The given radius will be used.
    else {
      // Scale each radius to not exceed the size of the width/height of the Rect.
      double topLeftRadius = min(radius, rect.shortestSide / 2);
      double topRightRadius = min(radius, rect.shortestSide / 2);
      double bottomLeftRadius = min(radius, rect.shortestSide / 2);
      double bottomRightRadius = min(radius, rect.shortestSide / 2);

      final Rect topLeftCorner = Rect.fromLTWH(
        rect.left,
        rect.top,
        topLeftRadius * 2,
        topLeftRadius * 2,
      );

      final Rect topRightCorner = Rect.fromLTWH(
        rect.right - topRightRadius * 2,
        rect.top,
        topRightRadius * 2,
        topRightRadius * 2,
      );

      final Rect bottomRightCorner = Rect.fromLTWH(
        rect.right - bottomRightRadius * 2,
        rect.bottom - bottomRightRadius * 2,
        bottomRightRadius * 2,
        bottomRightRadius * 2,
      );

      final Rect bottomLeftCorner = Rect.fromLTWH(
        rect.left,
        rect.bottom - bottomLeftRadius * 2,
        bottomLeftRadius * 2,
        bottomLeftRadius * 2,
      );

      if (showTopSide && showRightSide && showBottomSide && showLeftSide)
        path
          ..moveTo(rect.left + topLeftRadius, rect.top)
          ..lineTo(rect.right - topRightRadius, rect.top)
          ..arcTo(topRightCorner, -pi / 2, pi / 2, true)
          ..lineTo(rect.right, rect.bottom - bottomRightRadius)
          ..arcTo(bottomRightCorner, 0, pi / 2, true)
          ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
          ..arcTo(bottomLeftCorner, pi / 2, pi / 2, true)
          ..lineTo(rect.left, rect.top + topLeftRadius)
          ..arcTo(topLeftCorner, pi, pi / 2, true);
      //
      else if (showTopSide && !showRightSide && showBottomSide && showLeftSide)
        path
          ..moveTo(rect.left + topLeftRadius, rect.top)
          ..lineTo(rect.right + halfWidth, rect.top)
          ..moveTo(rect.right + halfWidth, rect.bottom)
          ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
          ..arcTo(bottomLeftCorner, pi / 2, pi / 2, true)
          ..lineTo(rect.left, rect.top + topLeftRadius)
          ..arcTo(topLeftCorner, pi, pi / 2, true);
      //
      else if (showTopSide && showRightSide && !showBottomSide && showLeftSide)
        path
          ..moveTo(rect.left + topLeftRadius, rect.top)
          ..lineTo(rect.right - topRightRadius, rect.top)
          ..arcTo(topRightCorner, -pi / 2, pi / 2, true)
          ..lineTo(rect.right, rect.bottom + halfWidth)
          ..moveTo(rect.left, rect.bottom + halfWidth)
          ..lineTo(rect.left, rect.top + topLeftRadius)
          ..arcTo(topLeftCorner, pi, pi / 2, true);
      //
      else if (showTopSide && showRightSide && showBottomSide && !showLeftSide)
        path
          ..moveTo(rect.left - halfWidth, rect.top)
          ..lineTo(rect.right - topRightRadius, rect.top)
          ..arcTo(topRightCorner, -pi / 2, pi / 2, true)
          ..lineTo(rect.right, rect.bottom - bottomRightRadius)
          ..arcTo(bottomRightCorner, 0, pi / 2, true)
          ..lineTo(rect.left - halfWidth, rect.bottom);
      //
      else if (!showTopSide && showRightSide && showBottomSide && showLeftSide)
        path
          ..moveTo(rect.right, rect.top - halfWidth)
          ..lineTo(rect.right, rect.bottom - bottomRightRadius)
          ..arcTo(bottomRightCorner, 0, pi / 2, true)
          ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
          ..arcTo(bottomLeftCorner, pi / 2, pi / 2, true)
          ..lineTo(rect.left, rect.top - halfWidth);
      //
      else if (!showTopSide && !showRightSide && showBottomSide && showLeftSide)
        path
          ..moveTo(rect.right + halfWidth, rect.bottom)
          ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
          ..arcTo(bottomLeftCorner, pi / 2, pi / 2, true)
          ..lineTo(rect.left, rect.top - halfWidth);
      //
      else if (!showTopSide && showRightSide && !showBottomSide && showLeftSide)
        path
          ..moveTo(rect.right, rect.top - halfWidth)
          ..lineTo(rect.right, rect.bottom + halfWidth)
          ..moveTo(rect.left, rect.bottom + halfWidth)
          ..lineTo(rect.left, rect.top - halfWidth);
      //
      else if (!showTopSide && showRightSide && showBottomSide && !showLeftSide)
        path
          ..moveTo(rect.right, rect.top - halfWidth)
          ..lineTo(rect.right, rect.bottom - bottomRightRadius)
          ..arcTo(bottomRightCorner, 0, pi / 2, true)
          ..lineTo(rect.left - halfWidth, rect.bottom);
      //
      else if (showTopSide && !showRightSide && !showBottomSide && showLeftSide)
        path
          ..moveTo(rect.left, rect.bottom + halfWidth)
          ..lineTo(rect.left, rect.top + topLeftRadius)
          ..arcTo(topLeftCorner, pi, pi / 2, true)
          ..lineTo(rect.right + halfWidth, rect.top);
      //
      else if (showTopSide && !showRightSide && showBottomSide && !showLeftSide)
        path
          ..moveTo(rect.left - halfWidth, rect.top)
          ..lineTo(rect.right + halfWidth, rect.top)
          ..moveTo(rect.right + halfWidth, rect.bottom)
          ..lineTo(rect.left - halfWidth, rect.bottom);
      //
      else if (showTopSide && showRightSide && !showBottomSide && !showLeftSide)
        path
          ..moveTo(rect.left - halfWidth, rect.top)
          ..lineTo(rect.right - topRightRadius, rect.top)
          ..arcTo(topRightCorner, -pi / 2, pi / 2, true)
          ..lineTo(rect.right, rect.bottom + halfWidth);
      //
      else if (showTopSide && !showRightSide && !showBottomSide && !showLeftSide)
        path
          ..moveTo(rect.left - halfWidth, rect.top)
          ..lineTo(rect.right + halfWidth, rect.top);
      //
      else if (!showTopSide && showRightSide && !showBottomSide && !showLeftSide)
        path
          ..moveTo(rect.right, rect.top - halfWidth)
          ..lineTo(rect.right, rect.bottom + halfWidth);
      //
      else if (!showTopSide && !showRightSide && showBottomSide && !showLeftSide)
        path
          ..moveTo(rect.left - halfWidth, rect.bottom)
          ..lineTo(rect.right + halfWidth, rect.bottom);
      //
      else if (!showTopSide && !showRightSide && !showBottomSide && showLeftSide)
        path
          ..moveTo(rect.left, rect.top - halfWidth)
          ..lineTo(rect.left, rect.bottom + halfWidth);
    }

    return path;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NonUniformRoundedRectangleBorder &&
          runtimeType == other.runtimeType &&
          side == other.side && // Must explicitly check borderSide.
          radius == other.radius &&
          hideTopSide == other.hideTopSide &&
          hideBottomSide == other.hideBottomSide &&
          hideRightSide == other.hideRightSide &&
          hideLeftSide == other.hideLeftSide;

  @override
  int get hashCode =>
      hashValues(radius, side, hideTopSide, hideBottomSide, hideRightSide, hideLeftSide.hashCode);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'NonUniformRectangleBorder')}($side, $radius)';
  }
}
