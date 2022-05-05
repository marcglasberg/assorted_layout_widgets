import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

/// Draws a rounded rectangle around an [InputDecorator]'s container.
///
/// The differences to an [OutlineInputBorder] are:
///
/// * It doesn't add a gap when the input decorator's label is floating.
/// For this reason you should not use it with a floating label.
///
/// * You can to hide some of the sides, by setting [hideTopSide],
/// [hideBottomSide], [hideRightSide] and [hideLeftSide] to false.
///
/// * A single [radius] will be used for the corners of all non-hidden sides.
///
/// See also:
///
///  * [OutlineInputBorder], an [InputDecorator] border which draws a
///    rounded rectangle around the input decorator's container.
///  * [UnderlineInputBorder], the default [InputDecorator] border which
///    draws a horizontal line at the bottom of the input decorator's container.
///  * [InputDecoration], which is used to configure an [InputDecorator].
///
class NonUniformOutlineInputBorder extends InputBorder {
  /// Creates a rounded rectangle outline border for an [InputDecorator].
  ///
  /// If the [borderSide] parameter is [BorderSide.none], it will not draw a
  /// border. However, it will still define a shape (which you can see if
  /// [InputDecoration.filled] is true).
  ///
  /// If an application does not specify a [borderSide] parameter of
  /// value [BorderSide.none], the input decorator substitutes its own, using
  /// [copyWith], based on the current theme and [InputDecorator.isFocused].
  ///
  /// The [radius] parameter defaults to corners of 4.0 pixels of circular radius.
  ///
  /// See also:
  ///
  ///  * [InputDecoration.floatingLabelBehavior], which should be set to
  ///    [FloatingLabelBehavior.never] when used with [NonUniformOutlineInputBorder].
  ///
  const NonUniformOutlineInputBorder({
    BorderSide borderSide = const BorderSide(),
    this.radius = 4.0,
    this.hideTopSide = false,
    this.hideBottomSide = false,
    this.hideRightSide = false,
    this.hideLeftSide = false,
  }) : super(borderSide: borderSide);

  /// The radii of the border's rounded rectangle corners.
  final double radius;

  double get topLeftRadius => (showTopSide && showLeftSide) ? radius : 0.0;

  double get topRightRadius => (showTopSide && showRightSide) ? radius : 0.0;

  double get bottomLeftRadius => (showBottomSide && showLeftSide) ? radius : 0.0;

  double get bottomRightRadius => (showBottomSide && showRightSide) ? radius : 0.0;

  @override
  bool get isOutline => true;

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
  NonUniformOutlineInputBorder copyWith({
    BorderSide? borderSide,
    double? radius,
    double? gapPadding,
    bool? hideTopSide,
    bool? hideBottomSide,
    bool? hideRightSide,
    bool? hideLeftSide,
  }) {
    return NonUniformOutlineInputBorder(
      borderSide: borderSide ?? this.borderSide,
      radius: radius ?? this.radius,
      hideTopSide: hideTopSide ?? this.hideTopSide,
      hideBottomSide: hideBottomSide ?? this.hideBottomSide,
      hideRightSide: hideRightSide ?? this.hideRightSide,
      hideLeftSide: hideLeftSide ?? this.hideLeftSide,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(borderSide.width);
  }

  @override
  NonUniformOutlineInputBorder scale(double t) {
    return NonUniformOutlineInputBorder(
      borderSide: borderSide.scale(t),
      radius: radius * t,
      hideTopSide: hideTopSide,
      hideBottomSide: hideBottomSide,
      hideRightSide: hideRightSide,
      hideLeftSide: hideLeftSide,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is NonUniformOutlineInputBorder) {
      final NonUniformOutlineInputBorder outline = a;
      return NonUniformOutlineInputBorder(
        radius: lerpDouble(outline.radius, radius, t)!,
        borderSide: BorderSide.lerp(outline.borderSide, borderSide, t),
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
    if (b is NonUniformOutlineInputBorder) {
      final NonUniformOutlineInputBorder outline = b;
      return NonUniformOutlineInputBorder(
        radius: lerpDouble(radius, outline.radius, t)!,
        borderSide: BorderSide.lerp(borderSide, outline.borderSide, t),
        hideTopSide: hideTopSide,
        hideBottomSide: hideBottomSide,
        hideRightSide: hideRightSide,
        hideLeftSide: hideLeftSide,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(
          _borderRadius(rect).resolve(textDirection).toRRect(rect).deflate(borderSide.width));
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

  /// Draw a rounded rectangle around [rect] using [borderRadius].
  ///
  /// The [borderSide] defines the line's color and weight.
  ///
  /// The top side of the rounded rectangle may be interrupted by a single gap
  /// if [gapExtent] is non-null. In that case the gap begins at
  /// `gapStart - gapPadding` (assuming that the [textDirection] is [TextDirection.ltr]).
  /// The gap's width is `(gapPadding + gapExtent + gapPadding) * gapPercentage`.
  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart = 0.0,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    var paint = borderSide.toPaint();
    var path = _path(canvas, rect);
    canvas.drawPath(path, paint);
  }

  Path _path(Canvas canvas, Rect rect) {
    //
    rect = rect.deflate(borderSide.width / 2.0);
    final halfWidth = borderSide.width / 2;
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
      other is NonUniformOutlineInputBorder &&
          runtimeType == other.runtimeType &&
          borderSide == other.borderSide && // Must explicitly check borderSide.
          radius == other.radius &&
          hideTopSide == other.hideTopSide &&
          hideBottomSide == other.hideBottomSide &&
          hideRightSide == other.hideRightSide &&
          hideLeftSide == other.hideLeftSide;

  @override
  int get hashCode =>
      radius.hashCode ^
      borderSide.hashCode ^
      hideTopSide.hashCode ^
      hideBottomSide.hashCode ^
      hideRightSide.hashCode ^
      hideLeftSide.hashCode;
}
