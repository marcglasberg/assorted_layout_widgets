import 'dart:math';

import "package:align_positioned/align_positioned.dart";
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// /

enum SymbolType { plus, minus, times, check, equals, colon }

// /

/// Creates the symbol ("+", "-", "x", "✓", "=" or ":") requested in the [symbol] parameter,
/// with the size of the container, and the requested color.
///
/// The line width is proportional to the size of the container (see [widthRatio]),
/// but optionally limited by [minWidth] and [maxWidth].
///
/// For the equals symbol, the vertical distance between the bars is the line width.
///
/// For the colon symbol, [widthRatio], [minWidth] and [maxWidth] define the diameter
/// of the circles, which is also the vertical distance between them.
///
/// If [symbol] is changed to another one, there will be an animation between them.
///
class AnimatedSymbol extends StatefulWidget {
  //
  final Color color;
  final double widthRatio;
  final double? minWidth;
  final double? maxWidth;
  final SymbolType symbol;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Duration duration;

  const AnimatedSymbol(
    this.symbol,
    this.color, {
    Key? key,
    this.widthRatio = 0.15,
    this.minWidth,
    this.maxWidth,
    this.padding,
    this.width,
    this.height,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<AnimatedSymbol> createState() => _AnimatedSymbolState();
}

class _AnimatedSymbolState extends State<AnimatedSymbol> with SingleTickerProviderStateMixin {
  //
  /// Drives the animation to and from the colon symbol. It takes twice the [duration]:
  /// * 0.0: Not a colon. The bars form the other symbols, as usual.
  /// * 0.0 to 0.5: The bars move and turn into two small squares (with the size of
  ///   the colon circles), in the positions of the circles.
  /// * 0.5 to 1.0: The circles appear behind the squares, and the squares shrink until
  ///   they disappear, so that it looks like the squares became circles.
  /// * 1.0: A colon. Only the circles are visible.
  ///
  /// When leaving the colon, the same thing happens in reverse.
  late final AnimationController _colonController;

  /// The (non-colon) symbol whose bar rotations are used to rotate the colon squares.
  /// The squares are rotated by multiples of 90 degrees (which doesn't change how they
  /// look), closest to the bar rotations of this symbol. This avoids the bars spinning
  /// too much when they turn into squares, or when the squares turn back into bars.
  late SymbolType _colonRotationReference;

  /// Changing this recreates the bars, so that they jump to their new position
  /// without animating. This is only done while the bars are invisible.
  int _barsGeneration = 0;

  @override
  void initState() {
    super.initState();
    bool isColon = widget.symbol == SymbolType.colon;
    _colonController = AnimationController(
      vsync: this,
      duration: widget.duration * 2,
      value: isColon ? 1.0 : 0.0,
    );
    _colonRotationReference = isColon ? SymbolType.plus : widget.symbol;
  }

  @override
  void didUpdateWidget(AnimatedSymbol oldWidget) {
    super.didUpdateWidget(oldWidget);
    _colonController.duration = widget.duration * 2;

    if (widget.symbol == oldWidget.symbol) return;

    // Going to the colon.
    if (widget.symbol == SymbolType.colon) {
      if (_colonController.value == 0.0) _colonRotationReference = oldWidget.symbol;
      _colonController.forward();
    }
    //
    // Leaving the colon.
    else if (oldWidget.symbol == SymbolType.colon) {
      // The squares are invisible, so they may be rotated to be close to the new symbol.
      if (_colonController.value == 1.0) {
        _colonRotationReference = widget.symbol;
        _barsGeneration++;
      }
      _colonController.reverse();
    }
  }

  @override
  void dispose() {
    _colonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: LayoutBuilder(
          builder: (context, constraints) => AnimatedBuilder(
            animation: _colonController,
            builder: (context, _) => _symbolStack(constraints.biggest.shortestSide),
          ),
        ),
      ),
    );
  }

  Widget _symbolStack(double size) {
    double colonProgress = _colonController.value;

    bool showColonSquares = (widget.symbol == SymbolType.colon) || (colonProgress > 0.5);

    List<Widget> bars = showColonSquares //
        ? _colonSquares(size, colonProgress)
        : _bars(widget.symbol);

    return Stack(
      children: [
        if (colonProgress > 0.5) ..._colonCircles(size),
        KeyedSubtree(key: ValueKey('bar0-$_barsGeneration'), child: bars[0]),
        KeyedSubtree(key: ValueKey('bar1-$_barsGeneration'), child: bars[1]),
      ],
    );
  }

  List<Widget> _bars(SymbolType symbol) {
    if (symbol == SymbolType.plus)
      return _plus();
    else if (symbol == SymbolType.minus)
      return _minus();
    else if (symbol == SymbolType.times)
      return _times();
    else if (symbol == SymbolType.check)
      return _check();
    else if (symbol == SymbolType.equals)
      return _equals();
    else
      throw AssertionError(symbol);
  }

  List<Widget> _plus() => [
        _bar(rotateDegrees: 0),
        _bar(rotateDegrees: 90),
      ];

  List<Widget> _minus() => [
        // Uses two bars, so that it can transform into the other symbols.
        _bar(rotateDegrees: 0),
        _bar(rotateDegrees: 0),
      ];

  List<Widget> _times() => [
        _bar(rotateDegrees: 45),
        _bar(rotateDegrees: -45),
      ];

  List<Widget> _equals() => [
        // The gap between the bars is the line width.
        _bar(rotateDegrees: 0, moveByChildHeight: -1),
        _bar(rotateDegrees: 0, moveByChildHeight: 1),
      ];

  List<Widget> _check() {
    // Note: If minWidth is used, the bumpSize calculation will be off.
    double bumpSize = 1 + (widget.widthRatio - 0.15) * (1.35 - 1.0) / (0.4 - 0.15);

    const double angle = 135.0;
    const double horizontalDisplacement = 0.04;

    return [
      _bar(
        childWidthRatio: 0.8,
        moveByChildHeight: 0.5,
        moveByContainerHeight: -0.21 + horizontalDisplacement,
        moveByContainerWidth: -0.1 + horizontalDisplacement,
        rotateDegrees: angle,
        // color: Colors.green.withOpacity(0.5),
      ),
      _bar(
        rotateDegrees: 90 + angle,
        childWidthRatio: 0.42 * bumpSize,
        moveByContainerWidth: (bumpSize - 1) / 4.75 + horizontalDisplacement,
        moveByContainerHeight: -0.3 - horizontalDisplacement,
        moveByChildHeight: 0.5,
        // color: Colors.blue.withOpacity(0.5),
      ),
    ];
  }

  Widget _bar({
    double rotateDegrees = 0.0,
    double childWidthRatio = 1,
    double moveByChildWidth = 0.0,
    double moveByChildHeight = 0.0,
    double moveByContainerWidth = 0.0,
    double moveByContainerHeight = 0.0,
    double dx = 0.0,
    double dy = 0.0,
    Color? color,
  }) =>
      AnimatedAlignPositioned(
        duration: widget.duration,
        rotateDegrees: rotateDegrees,
        childWidthRatio: childWidthRatio,
        childHeightRatio: widget.widthRatio,
        minChildHeight: widget.minWidth,
        maxChildHeight: widget.maxWidth,
        moveByChildWidth: moveByChildWidth,
        moveByChildHeight: moveByChildHeight,
        moveByContainerWidth: moveByContainerWidth,
        moveByContainerHeight: moveByContainerHeight,
        dx: dx,
        dy: dy,
        child: Container(color: color ?? widget.color),
      );

  // ---------------------------------------------------------------------------
  // Colon.
  //
  // The code below is only used by the colon symbol, and by the animations to and
  // from the colon. It doesn't affect the other symbols, nor the animations between
  // them.

  /// The rotations of the two bars of the given (non-colon) symbol.
  /// These must be kept in sync with the rotations used by [_plus], [_minus],
  /// [_times], [_check] and [_equals].
  static (double, double) _barRotations(SymbolType symbol) {
    if (symbol == SymbolType.plus)
      return (0, 90);
    else if (symbol == SymbolType.minus)
      return (0, 0);
    else if (symbol == SymbolType.times)
      return (45, -45);
    else if (symbol == SymbolType.check)
      return (135, 225);
    else if (symbol == SymbolType.equals)
      return (0, 0);
    else
      return (0, 0);
  }

  /// The diameter of the colon circles, which is also the vertical distance between
  /// them. Uses the same calculation as the width of the bars.
  double _colonDiameter(double size) {
    double diameter = widget.widthRatio * size;
    if (widget.minWidth != null) diameter = max(diameter, widget.minWidth!);
    if (widget.maxWidth != null) diameter = min(diameter, widget.maxWidth!);
    return diameter;
  }

  /// The two bars, turned into squares in the positions of the colon circles.
  /// After the first half of the colon animation, the squares shrink until they
  /// disappear, revealing the circles behind them.
  List<Widget> _colonSquares(double size, double colonProgress) {
    double diameterRatio = (size == 0) ? 0.0 : _colonDiameter(size) / size;
    double scale = (colonProgress <= 0.5) ? 1.0 : (1.0 - (colonProgress - 0.5) * 2);
    var (rotation0, rotation1) = _barRotations(_colonRotationReference);

    return [
      _colonSquare(
          direction: -1, rotation: rotation0, diameterRatio: diameterRatio, scale: scale),
      _colonSquare(direction: 1, rotation: rotation1, diameterRatio: diameterRatio, scale: scale),
    ];
  }

  /// A bar turned into a square, in the position of the top ([direction] -1)
  /// or bottom ([direction] 1) circle of the colon.
  Widget _colonSquare({
    required int direction,
    required double rotation,
    required double diameterRatio,
    required double scale,
  }) {
    // A square looks the same when rotated by a multiple of 90 degrees.
    double rotateDegrees = (rotation / 90).round() * 90.0;

    // AlignPositioned rotates the child around the center of the container, after
    // moving it. So the child is moved to the unrotated position that ends up in
    // the circle center after the rotation. The distance between the centers of the
    // circles is twice the diameter, so that the gap between them is one diameter.
    double radians = rotateDegrees * pi / 180;
    double offset = direction * diameterRatio;

    Widget square = Container(color: widget.color);

    return AnimatedAlignPositioned(
      duration: widget.duration,
      rotateDegrees: rotateDegrees,
      childWidthRatio: diameterRatio,
      childHeightRatio: widget.widthRatio,
      minChildHeight: widget.minWidth,
      maxChildHeight: widget.maxWidth,
      moveByContainerWidth: offset * sin(radians),
      moveByContainerHeight: offset * cos(radians),
      child: (scale >= 1.0)
          ? square
          : (scale <= 0.0)
              ? const SizedBox()
              : Transform.scale(scale: scale, child: square),
    );
  }

  /// The two circles of the colon.
  List<Widget> _colonCircles(double size) {
    double diameter = _colonDiameter(size);
    double left = (size - diameter) / 2;

    Widget circle(double top) => Positioned(
          left: left,
          top: top,
          width: diameter,
          height: diameter,
          child: DecoratedBox(
            decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
          ),
        );

    return [
      circle(size / 2 - diameter * 1.5),
      circle(size / 2 + diameter * 0.5),
    ];
  }
}
