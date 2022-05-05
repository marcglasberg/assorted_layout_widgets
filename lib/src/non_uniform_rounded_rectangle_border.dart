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
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.hideTopSide = false,
    this.hideBottomSide = false,
    this.hideRightSide = false,
    this.hideLeftSide = false,
  }) : super(side: side);

  /// The radii of the border's rounded rectangle corners.
  final BorderRadius borderRadius;

  double get topLeftRadius => borderRadius.topLeft.x;

  double get topRightRadius => borderRadius.topRight.x;

  double get bottomLeftRadius => borderRadius.bottomLeft.x;

  double get bottomRightRadius => borderRadius.bottomRight.x;

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
      borderRadius: borderRadius * t,
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
        borderRadius: BorderRadius.lerp(a.borderRadius, borderRadius, t)!,
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
        borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!,
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
    BorderRadius? borderRadius,
    bool? hideTopSide,
    bool? hideBottomSide,
    bool? hideRightSide,
    bool? hideLeftSide,
  }) {
    return NonUniformRoundedRectangleBorder(
      side: side ?? this.side,
      borderRadius: borderRadius ?? this.borderRadius,
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
    var tlRadius = min(topLeftRadius, rect.shortestSide / 2);
    var trRadius = min(topRightRadius, rect.shortestSide / 2);
    var blRadius = min(bottomLeftRadius, rect.shortestSide / 2);
    var brRadius = min(bottomRightRadius, rect.shortestSide / 2);

    return BorderRadius.only(
      topLeft: (showTopSide && showLeftSide) ? Radius.circular(tlRadius) : Radius.zero,
      topRight: (showTopSide && showRightSide) ? Radius.circular(trRadius) : Radius.zero,
      bottomLeft: (showBottomSide && showLeftSide) ? Radius.circular(blRadius) : Radius.zero,
      bottomRight: (showBottomSide && showRightSide) ? Radius.circular(brRadius) : Radius.zero,
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

    var tlRadius = max(0.0, this.topLeftRadius - halfWidth);
    var trRadius = max(0.0, this.topRightRadius - halfWidth);
    var blRadius = max(0.0, this.bottomLeftRadius - halfWidth);
    var brRadius = max(0.0, this.bottomRightRadius - halfWidth);

    final Path path = Path();

    // Scale each radius to not exceed the size of the width/height of the Rect.
    double topLeftRadius = min(tlRadius, rect.shortestSide / 2);
    double topRightRadius = min(trRadius, rect.shortestSide / 2);
    double bottomLeftRadius = min(blRadius, rect.shortestSide / 2);
    double bottomRightRadius = min(brRadius, rect.shortestSide / 2);

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

    double initialGap = (topLeftRadius == 0.0 ? -halfWidth : 0);

    if (showTopSide && showRightSide && showBottomSide && showLeftSide)
      path
        ..moveTo(rect.left + topLeftRadius + initialGap, rect.top)
        ..lineTo(rect.right - topRightRadius, rect.top)
        ..arcToIf(topRightCorner, -pi / 2, pi / 2, true, ifRadiusNonZero: topRightRadius)
        ..lineTo(rect.right, rect.bottom - bottomRightRadius)
        ..arcToIf(bottomRightCorner, 0, pi / 2, true, ifRadiusNonZero: bottomRightRadius)
        ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
        ..arcToIf(bottomLeftCorner, pi / 2, pi / 2, true, ifRadiusNonZero: bottomLeftRadius)
        ..lineTo(rect.left, rect.top + topLeftRadius)
        ..arcToIf(topLeftCorner, pi, pi / 2, true, ifRadiusNonZero: topLeftRadius);
    //
    else if (showTopSide && !showRightSide && showBottomSide && showLeftSide)
      path
        ..moveTo(rect.left + topLeftRadius + initialGap, rect.top)
        ..lineTo(rect.right + halfWidth, rect.top)
        ..moveTo(rect.right + halfWidth, rect.bottom)
        ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
        ..arcToIf(bottomLeftCorner, pi / 2, pi / 2, true, ifRadiusNonZero: bottomLeftRadius)
        ..lineTo(rect.left, rect.top + topLeftRadius)
        ..arcToIf(topLeftCorner, pi, pi / 2, true, ifRadiusNonZero: topLeftRadius);
    //
    else if (showTopSide && showRightSide && !showBottomSide && showLeftSide)
      path
        ..moveTo(rect.left + topLeftRadius + initialGap, rect.top)
        ..lineTo(rect.right - topRightRadius, rect.top)
        ..arcToIf(topRightCorner, -pi / 2, pi / 2, true, ifRadiusNonZero: topRightRadius)
        ..lineTo(rect.right, rect.bottom + halfWidth)
        ..moveTo(rect.left, rect.bottom + halfWidth)
        ..lineTo(rect.left, rect.top + topLeftRadius)
        ..arcToIf(topLeftCorner, pi, pi / 2, true, ifRadiusNonZero: topLeftRadius);
    //
    else if (showTopSide && showRightSide && showBottomSide && !showLeftSide)
      path
        ..moveTo(rect.left - halfWidth, rect.top)
        ..lineTo(rect.right - topRightRadius, rect.top)
        ..arcToIf(topRightCorner, -pi / 2, pi / 2, true, ifRadiusNonZero: topRightRadius)
        ..lineTo(rect.right, rect.bottom - bottomRightRadius)
        ..arcToIf(bottomRightCorner, 0, pi / 2, true, ifRadiusNonZero: bottomRightRadius)
        ..lineTo(rect.left - halfWidth, rect.bottom);
    //
    else if (!showTopSide && showRightSide && showBottomSide && showLeftSide)
      path
        ..moveTo(rect.right, rect.top - halfWidth)
        ..lineTo(rect.right, rect.bottom - bottomRightRadius)
        ..arcToIf(bottomRightCorner, 0, pi / 2, true, ifRadiusNonZero: bottomRightRadius)
        ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
        ..arcToIf(bottomLeftCorner, pi / 2, pi / 2, true, ifRadiusNonZero: bottomLeftRadius)
        ..lineTo(rect.left, rect.top - halfWidth);
    //
    else if (!showTopSide && !showRightSide && showBottomSide && showLeftSide)
      path
        ..moveTo(rect.right + halfWidth, rect.bottom)
        ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
        ..arcToIf(bottomLeftCorner, pi / 2, pi / 2, true, ifRadiusNonZero: bottomLeftRadius)
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
        ..arcToIf(bottomRightCorner, 0, pi / 2, true, ifRadiusNonZero: bottomRightRadius)
        ..lineTo(rect.left - halfWidth, rect.bottom);
    //
    else if (showTopSide && !showRightSide && !showBottomSide && showLeftSide)
      path
        ..moveTo(rect.left, rect.bottom + halfWidth)
        ..lineTo(rect.left, rect.top + topLeftRadius)
        ..arcToIf(topLeftCorner, pi, pi / 2, true, ifRadiusNonZero: topLeftRadius)
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
        ..arcToIf(topRightCorner, -pi / 2, pi / 2, true, ifRadiusNonZero: topRightRadius)
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
    // }

    return path;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NonUniformRoundedRectangleBorder &&
          runtimeType == other.runtimeType &&
          side == other.side && // Must explicitly check borderSide.
          borderRadius == other.borderRadius &&
          hideTopSide == other.hideTopSide &&
          hideBottomSide == other.hideBottomSide &&
          hideRightSide == other.hideRightSide &&
          hideLeftSide == other.hideLeftSide;

  @override
  int get hashCode => hashValues(
        borderRadius,
        side,
        hideTopSide,
        hideBottomSide,
        hideRightSide,
        hideLeftSide.hashCode,
      );

  @override
  String toString() {
    return '${objectRuntimeType(this, 'NonUniformRectangleBorder')}($side)';
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

extension _PathExtension on Path {
  void arcToIf(Rect rect, double startAngle, double sweepAngle, bool forceMoveTo,
      {required double ifRadiusNonZero}) {
    if (ifRadiusNonZero != 0.0) arcTo(rect, startAngle, sweepAngle, forceMoveTo);
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
